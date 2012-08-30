

int AttrNum = 62;
double inputs[62];
int AttrSize = 63;
int NodeNum = 31;
double SigmoidWeights[31][62] = { 
};

double LinearWeights[] = {};
int NodeSize = 32;
double Nodes[32];

//double e = 2.71828183;

double ex = 0.0;
int sigmod(double x)
{
   ex = 1/(1+MathExp(-x));
}

int i = 0;
int j = 0;
double score = 0.0;

extern int TakeProfit_L = 20;   // Take Profit in points
extern int StopLoss_L = 100;    // Stop Loss in points
extern int TakeProfit_S = 20;   // Take Profit in points
extern int StopLoss_S = 100;    // Stop Loss in points

bool AutoLot = true;
int ticket,cnt,tmp;
double closeprice;
int calcNet()
{

    for (i = 0; i < AttrNum; i++)
    {
        inputs[i] = inputs[i]/50; //normalize
        if (inputs[i] > 1) {
            inputs[i] = 1;
        } else if (inputs[i] < -1) {
            inputs[i] = -1;
        }
    }
    Nodes[0] = 1;
    for(i = 1; i <= NodeNum; i++)
    {
        Nodes[i] = SigmoidWeights[i-1][0];
        //printf("Node_%d: %f\n", i,  Nodes[i]);
        for (j = 1; j <= AttrNum; j++)
        {
            Nodes[i] = Nodes[i] + inputs[j-1] * SigmoidWeights[i-1][j];
        }
        //printf("Node %d: %f\n", i,  Nodes[i]);
        sigmod(Nodes[i]);
        Nodes[i] = ex;
        
        //printf("Node: %f\n", Nodes[i]);
    }
    score = 0.0;
    for (i = 0; i <= NodeNum; i++)
    {
        score = score + Nodes[i] * LinearWeights[i];
    }

    //return score;
}

//int min;
//int lastMin;
int init()
{
   //lastMin = TimeMinute(TimeCurrent());
   calcNet();
   Alert(score, " should be ",0.2992);
}

int globPos()
    // the function calculates big lot size
{
    int v1=GlobalVariableGet("globalPosic");
    GlobalVariableSet("globalPosic",v1+1);
    return(0);
}
int OpenLong(double volume=0.1)
    // the function opens a long position with lot size=volume 
{
    int slippage=10;
    string comment="20/200 expert v2 (Long)";
    color arrow_color=Red;
    int magic=0;

    //if (GlobalVariableGet("globalBalans")>AccountBalance()) volume=lot*BigLotSize;
    //  if (GlobalVariableGet("globalBalans")>AccountBalance()) if (AutoLot) LotSize();

    ticket=OrderSend(Symbol(),OP_BUY,volume,Ask,slippage,Ask-StopLoss_L*Point,
            Ask+TakeProfit_L*Point,comment,magic,0,arrow_color);

    GlobalVariableSet("globalBalans",AccountBalance());                    
    globPos();
    //  if (GlobalVariableGet("globalPosic")>25)
    //  {
    GlobalVariableSet("globalPosic",0);
    if (AutoLot) LotSize();
    //  }

    if(ticket>0)
    {
        if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))
        {
            return(0);
        }
        else
        {
            Print("OpenLong(),OrderSelect() - returned an error : ",GetLastError()); 
            return(-1);
        }   
    }
    else 
    {
        Print("Error opening Buy order : ",GetLastError()); 
        return(-1);
    }
}

int OpenShort(double volume=0.1)
    // The function opens a short position with lot size=volume
{
    int slippage=10;
    string comment="Gabriel Eze Junior >>>SHORT";
    color arrow_color=Red;
    int magic=0;  

    //if (GlobalVariableGet("globalBalans")>AccountBalance()) volume=lot*BigLotSize;

    ticket=OrderSend(Symbol(),OP_SELL,volume,Bid,slippage,Bid+StopLoss_S*Point,
            Bid-TakeProfit_S*Point,comment,magic,0,arrow_color);
    GlobalVariableSet("globalBalans",AccountBalance());
    globPos();
    //  if (GlobalVariableGet("globalPosic")>25)
    //  {
    GlobalVariableSet("globalPosic",0);
    if (AutoLot) LotSize();
    //  }

    if(ticket>0)
    {
        if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))
        {
            return(0);
        }
        else
        {
            Print("OpenShort(),OrderSelect() - returned an error : ",GetLastError()); 
            return(-1);
        }    
    }
    else 
    {
        Print("Error opening Sell order : ",GetLastError()); 
        return(-1);
    }
}

int Orders = 1;
int total;
int MaxOpenTime = 180;// seconds
double lot = 0.01;

int LotSize()
    // The function opens a short position with lot size=volume
{
    lot=MathMax(0.01*NormalizeDouble(AccountBalance()/25,0),0.01);
    //Print(lot,AccountBalance(),NormalizeDouble(AccountBalance()/25,0),NormalizeDouble(AccountBalance()/25,0)*0.01);

}

int t = 0;
int start()
{
   if (Volume[0] > 1) {
      return; // only new Bars
   }
   if (Period() != 1) {
      Alert("only works for 1Min");
      return; // only minutes bar
   }
   t++;
   if (t < 6) {
      return; // need more than 6 bars
   }

   // block of a trade validity time checking, if MaxOpenTime=0, do not check.
    total=OrdersTotal();
    if(MaxOpenTime>0)
    {
        for(cnt=0;cnt<total;cnt++)
        {
            if (OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES))
            {
                tmp = (TimeCurrent()-OrderOpenTime());
                if (((NormalizeDouble(tmp,8)-MaxOpenTime)>=0))
                {     
                    RefreshRates();
                    if (OrderType()==OP_BUY)
                        closeprice=Bid;
                    else  
                        closeprice=Ask;          
                    Print("close:", Bid, "-", Ask, ":", closeprice);
                    if (OrderClose(OrderTicket(),OrderLots(),closeprice,10,Green))
                    {
                        Print("Forced closing of the trade - ",OrderTicket());
                        OrderPrint();
                    }
                    else {
                        Print("OrderClose() in block of a trade validity time checking returned an error - ",GetLastError());        
                        Print(Bid, "-", Ask, ":", closeprice);
                    }
                } 
            }
            else 
                Print("OrderSelect() in block of a trade validity time checking returned an error - ",GetLastError());
        } 
   }
    
   total=OrdersTotal();
   if (total < Orders) 
   {
      for (i = 0; i < AttrNum; i++)
      {
         inputs[i] = (Close[AttrNum-i-1] - Close[AttrNum - i])*100000;
      }
      //Alert(inputs[0],",",inputs[1],",",inputs[2],",",inputs[3],",",inputs[4],",",inputs[5],",",inputs[6], " : ", Close[0]);
      calcNet();
      
      if (score > 0.9) {
      Alert(inputs[0],",",inputs[1],",",inputs[2],",",inputs[3],",",inputs[4],",",inputs[5],",",inputs[6], " : ", score);
         LotSize();
         OpenLong(lot);
      }
      else if (score < -0.9) {
      Alert(inputs[0],",",inputs[1],",",inputs[2],",",inputs[3],",",inputs[4],",",inputs[5],",",inputs[6], " : ", score);
         LotSize();
         OpenShort(lot);
      }
   }
}
