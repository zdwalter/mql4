

int AttrNum = 6;
int AttrSize = 7;
int NodeNum = 8;
int NodeSize = 9;
double SigmoidWeights[8][7] = { 
    -3.913976787546473,-0.2313599551518332,0.5236001432677418,-0.4845809864446499,-1.4083950307732795,1.287376750722083,-0.5264231575656667,
    -3.913976787546436,-0.23135995515183705,0.5236001432677462,-0.48458098644462266,-1.4083950307733186,1.2873767507221023,-0.526423157565667,
    -6.929065365165638,12.09869113513589,0.9821355966782208,-7.123050813541049,-8.730448090297797,-1.5568348236624445,16.08873332916096, 
    -4.005582105006674,-0.48268529458389026,0.5626616568413977,-1.3371850422812415,-0.5757486224737444,1.129704995293283,-0.6140386949937038, 
    -5.605588993709541,-2.954917805544663,-0.7712750903894914,1.1371155281179022,-5.883052583755473,0.7370720278286179,8.745184054949203, 
    -6.426473639549075,0.5333329712155874,1.0485432353850368,-0.13458646385645023,-4.6493901907297435,-2.717720834103987,4.411246020941945, 
    -2.364890943711836,6.083368785427239,0.8374520085244727,-2.5463126598822807,-3.532514512670216,-1.127996080480351,9.828515657681725, 
    -5.934156796041374,4.166297964135294,-0.1983193188529508,3.715392584800632,0.6432877579595192,0.5086345706395629,-5.715624111817505 
};

double LinearWeights[] = {0.23639506168060795,-2.1963449552343928,-2.1963449552343364,-1.6983582933485568,-1.9425908418881845,1.623053239662827,-1.4992441114649555,2.1400374449877964,-0.8288289170627235};
double Nodes[9];

//double e = 2.71828183;

double ex = 0.0;
int sigmod(double x)
{
   ex = 1/(1+MathExp(-x));
}

double inputs[6];
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
                        Print("Forced closing of the trade - ?",OrderTicket());
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
