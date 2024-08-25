//+------------------------------------------------------------------+
//|                                                Market_Volume.mq5 |
//|                                           Copyright 2024, FaceND |
//|                                 https://github.com/FaceND/Volume |
//+------------------------------------------------------------------+
#property copyright     "Copyright 2024, FaceND"
#property link          "https://github.com/FaceND/Volume"
#property strict
#property indicator_chart_window
#property indicator_plots 0

input group "DATA"
input ENUM_APPLIED_VOLUME   VolumeType       = VOLUME_TICK;          // Volume type

input group "POSITION"
input ENUM_BASE_CORNER      CornerPosition   = CORNER_LEFT_UPPER;    // Position
input int                   X_Distance       = 10;                   // X distance from the corner
input int                   Y_Distance       = 20;                   // Y distance from the corner

input group "STYLE"
input color                 BidColor         = clrLimeGreen;         // Bid color
input color                 AskColor         = clrRed;               // Ask color
input color                 TextColor        = clrWhite;             // Text color
input int                   FontSize         = 10;                   // Font size

int last_index = 0;

long volumes;
double previous_price, current_price;

string obj_name   = "VolumeText";
string obj_volume = "Volume";

color volume_color, _BidColor, _AskColor;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   CreateObject(obj_name, "Volume", TextColor);
   CreateObject(obj_volume, NULL, TextColor);

   _BidColor = (BidColor==clrNONE) ? TextColor : BidColor;
   _AskColor = (AskColor==clrNONE) ? TextColor : AskColor;

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectDelete(0,obj_name);
   ObjectDelete(0,obj_volume);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int           rates_total,
                const int       prev_calculated,
                const datetime          &time[],
                const double            &open[],
                const double            &high[],
                const double             &low[],
                const double           &close[],
                const long       &tick_volume[],
                const long            &volume[],
                const int             &spread[])
  {
   //-- Get Volume
   if(VolumeType == VOLUME_REAL)
     {
      last_index = ArraySize(volume) - 1;
      volumes = volume[last_index];
     }
   else
     {
      last_index = ArraySize(tick_volume) - 1;
      volumes = tick_volume[last_index];
     }
   //+---------------------------------------------------------------+
   current_price = close[rates_total-1];
   //+---------------------------------------------------------------+
   SetObject();
   previous_price = current_price;
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Custom indicator Construction object function                    |
//+------------------------------------------------------------------+
void CreateObject(const string          name,
                  const string          text,
                  const color      textColor)
  {
   if(ObjectFind(0, name) < 0)
     {
      ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, name, OBJPROP_CORNER,  CornerPosition);
      ObjectSetInteger(0, name, OBJPROP_XDISTANCE,   X_Distance);
      ObjectSetInteger(0, name, OBJPROP_YDISTANCE,   Y_Distance);
      ObjectSetInteger(0, name, OBJPROP_COLOR,        textColor);
      ObjectSetInteger(0, name, OBJPROP_FONTSIZE,      FontSize);
      if(text == "" || text == NULL)
        {
         ObjectSetString(0, name, OBJPROP_TEXT, " ");
        }
      else
        {
         ObjectSetString(0, name, OBJPROP_TEXT, text);
        }
     }
  }
//+------------------------------------------------------------------+
//| Sets up the volume object                                        |
//+------------------------------------------------------------------+
void SetObject()
  {
   if(previous_price > current_price)
     {
      volume_color = _AskColor;
     }
   else if(previous_price < current_price)
     {
      volume_color = _BidColor;
     }
   else
     {
      volume_color = TextColor;
     }
   ObjectSetInteger(0, obj_volume, OBJPROP_COLOR, volume_color);
   ObjectSetString(0, obj_volume, OBJPROP_TEXT, "             " + FormatVolume(volumes));
  }
//+------------------------------------------------------------------+
//| Function to format volume value                                  |
//+------------------------------------------------------------------+
string FormatVolume(long volume)
  {
   string formattedVolume;
   if(volume >= 1000)
     {
      formattedVolume = DoubleToString(volume/1000.0, 3) + "K";
     }
   else
     {
      formattedVolume = IntegerToString(volume, 0);
     }
   return formattedVolume;
  }
//+------------------------------------------------------------------+