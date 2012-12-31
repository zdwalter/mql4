#property copyright "Walter Zheng"
#property link      "http://zdwalter.info"

//variables
int handle;
string t;
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
{
    //----
    handle = FileOpen(Symbol()+".data",FILE_BIN|FILE_WRITE,',');
    t = TimeToStr(TimeCurrent());
    //----
    return(0);
}
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
{
    //----
    FileClose(handle);
    //----
    return(0);
}
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
string s;
string now;

int start()
{
    //----
    now = TimeToStr(TimeCurrent());
    if (now != t) {
      Print(now);
      t = now;
    }
    s = " "+Bid;   
    FileWriteString(handle, s, StringLen(s));
    //----
    return(0);
}
//+------------------------------------------------------------------+
