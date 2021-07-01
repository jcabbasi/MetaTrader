//+------------------------------------------------------------------+
//|                                             JcSirous03182020.mq4 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Jc"
#property link      "Jc"
#property version   "1.00"
#property strict
//--- input parameters
input int      MAfast=21;
input int      MAslow=35;
input int      MAdiffRange=10;
input int      TPone=500;
input int      TPtwo=30;
input int      SLone=100;
input int      Buymax=4;
input int      Sellmax=4;
input int      StopYes=1;
input int      Buydist=200;
input int      Selldist=200;
input double      volumePerTrade=1.0;


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {


   int countme=0;
   return(0);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {

   int OrderCount=0;
   int Counter =0;
   for(Counter = 0; Counter <= OrdersTotal()-1; Counter++)
     {
      OrderSelect(Counter,SELECT_BY_POS);
      if(OrderType() == OP_BUY)
        {
         OrderCount++;
        }
     }
   int BUYorders=OrderCount;
   int SELLorders=OrdersTotal()-BUYorders;
//

   double CurrentAskPrice = Ask;
   double FastMA = iMA(NULL,0,MAfast,0,0,0,0);
   double SlowMA = iMA(NULL,0,MAslow,0,0,0,0);
   string curr= Symbol();
   double UsePoint = PipPoint(curr);
   double diffMA= FastMA-SlowMA;
   double pipDiff= diffMA/UsePoint; // pip difference between slow and fast MA


   double tradeVol=0.1;

   int inters = CheckIntersection();

//------------------------------------BUY:
   if(inters==1) //for BUY: Check Indicator
     {


        
     CloseOpenOrder();
 
     OrderSend(Symbol(),OP_SELL,tradeVol,Bid,0,0,0,"Buy Order",0,0,Green);
                      
                      

     }
     
//------------------------------------------ SELL ------------------------------------------


   if(inters==2) //for Sell: Check Indicator
     {
     Print("SELL:  ", inters);
     CloseOpenOrder();
     OrderSend(Symbol(),OP_BUY,tradeVol,Bid,0,StopYes*(CurrentAskPrice+UsePoint*SLone),CurrentAskPrice-UsePoint*TPone,
                         "Buy Order",0,0,Red);
     }

       

//+------------------------------------------------------------------+
//---------Modifying Open Orders



   return(0);

  }




////+------------------------------------------------------------------+

// Pip Point Function
double PipPoint(string Currency)
  {
   double CalcPoint;
   int CalcDigits = MarketInfo(Currency,MODE_DIGITS);
   if(CalcDigits == 2 || CalcDigits == 3)
      double CalcPoint = 0.01;
   else
      if(CalcDigits == 4 || CalcDigits == 5)
         CalcPoint = 0.0001;
   return(CalcPoint);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CheckIntersection()
  {
   double FastMAPrev = iMA(NULL,0,MAfast,0,0,0,1);
   double SlowMAPrev = iMA(NULL,0,MAslow,0,0,0,1);

   double FastMA = iMA(NULL,0,MAfast,0,0,0,0);
   double SlowMA = iMA(NULL,0,MAslow,0,0,0,0);

   double slopeFast= FastMA-FastMAPrev;
   double slopeSlow= SlowMA-SlowMAPrev;

   double difPrev=FastMAPrev-SlowMAPrev;
   double difNow =FastMA-SlowMA;

   if(difPrev<0 && difNow>0)
     {
      //BUY
      return(1);
     }
   if(difPrev>0 && difNow<0)
     {
      //SELL
      return(2);
     }


   return (0);



  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double lastBuyOrderAskPrice()
  {
   int Counter=0;
   long  lastTime=0;
   double askprice=0;
   for(Counter = 0; Counter <= OrdersTotal()-1; Counter++)
     {
      OrderSelect(Counter,SELECT_BY_POS);

      if(OrderType() == OP_BUY)
        {

         long  Newtime = OrderGetInteger(ORDER_TIME_SETUP_MSC);
         if(Newtime>lastTime)
           {
            double askprice = OrderGetDouble(ORDER_PRICE_OPEN);
            lastTime=Newtime;
           }
        }
     }
   return(askprice);

  }

//+------------------------------------------------------------------+
double lastSellOrderAskPrice()
  {
   double askprice=0;
   int Counter=0;
   datetime  lastTime=0;
   for(Counter = 0; Counter <= OrdersTotal()-1; Counter++)
     {
      OrderSelect(Counter,SELECT_BY_POS);
      if(OrderType() == OP_SELL)
        {

         datetime  Newtime = OrderGetInteger(ORDER_TIME_SETUP);
         if(Newtime>lastTime)
           {
            double askprice = OrderGetDouble(ORDER_PRICE_OPEN);
            lastTime=Newtime;
           }
        }
     }
   return(askprice);

  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OpenOrderModifer(double UsePoint)
  {
   double safeStopPip=50;
   int Counter=0;
   for(Counter = 0; Counter <= OrdersTotal()-1; Counter++)
     {
      OrderSelect(Counter,SELECT_BY_POS);

      if(OrderType() == OP_BUY)
        {

         double OpenPrice = OrderGetDouble(ORDER_PRICE_OPEN);
         double PriceDifference=(Ask-OpenPrice)/UsePoint;
         if(PriceDifference>safeStopPip)
           {
            int  BuyTicket = OrderTicket();
            bool TicketMod = OrderModify(BuyTicket,OrderOpenPrice(),NormalizeDouble(OrderOpenPrice()+5*UsePoint,Digits ),0,0);
           }
        }
      if(OrderType() == OP_SELL)
        {

         double OpenPrice = OrderGetDouble(ORDER_PRICE_OPEN);
         double PriceDifference=(Ask-OpenPrice)/UsePoint;
         if(PriceDifference<-safeStopPip)
           {
            int  BuyTicket = OrderTicket();
            bool TicketMod = OrderModify(BuyTicket,OrderOpenPrice(),NormalizeDouble(OrderOpenPrice()-5*UsePoint,Digits ),0,0);
           }
        }

     }
  }
  
void CloseOpenOrder()
  {
 
   int Counter=0;
   for(Counter = 0; Counter <= OrdersTotal()-1; Counter++)
     {
      OrderSelect(Counter,SELECT_BY_POS);
        if(OrderType() == OP_BUY)
        {    
            int  Order_Ticket = OrderTicket();
                OrderClose(Order_Ticket,OrderLots(),Bid,0,Red);
                }
        if(OrderType() == OP_SELL)
        {    
            int  Order_Ticket = OrderTicket();
                OrderClose(Order_Ticket,OrderLots(),Ask,0,Red);
                }                
        }

   }
    
//+------------------------------------------------------------------+
