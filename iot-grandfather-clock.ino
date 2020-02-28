# Copyright <senorjp@gmail.com> Jan 2020
#
#include <Servo.h> 
#include <ESP8266WiFi.h>
#include <WiFiClient.h>
#include <ESP8266WebServer.h>
#include <ESP8266mDNS.h>
#include <EEPROM.h>
#include <SNTPtime.h>


#define servoEnable D1
#define factoryResetMagic 248

const char *ssid = "your_ssid";
const char *password = "your_wifi_password";
const char *mdnsName = "donger"; // http://*mdnsName.local

int aMin = 0;
int aReady = 0;
int aReadyDelay = 0;
int aMax = 0;
int aDelay = 0;
int aFactoryReset = 0;
int aTimeZone = 0;
char aNTPServer[60];
int aChimeFrom = 0;
int aChimeTo = 0;
int aMultiDelay=0;

ESP8266WebServer server ( 80 );

SNTPtime NTPch("ch.pool.ntp.org");
strDateTime dateTime;

byte dongArmed = 0;
byte lastHour = 0;

int servoPinA = D5;
 
Servo servoA;  

uint addr = 0;

struct { 
  uint min = 0;
  uint max = 180;
  uint ready = 90;
  uint delay = 500;
  uint readydelay = 500;
  uint factoryreset;
  int timezone = 0;
  char ntpserver[60];
  uint chimefrom = 0;
  uint chimeto = 0;
  uint multidelay = 0;
} settings;

//int angle = 0;   // servo position in degrees 



void handleRoot() {
  char temp[2000];

  dateTime = NTPch.getTime(aTimeZone, 1); // get time from internal clock
  //NTPch.printDateTime(dateTime);

  
  byte actualHour = dateTime.hour;
  byte actualMinute = dateTime.minute;
  byte actualsecond = dateTime.second;
  int actualyear = dateTime.year;
  byte actualMonth = dateTime.month;
  byte actualday = dateTime.day;
  byte actualdayofWeek = dateTime.dayofWeek;
        
  snprintf ( temp, 2000,

"<html>\
  <head>\
    <title>Donger</title>\
    <style>\
      body { background-color: #cccccc; font-family: Arial, Helvetica, Sans-Serif; Color: #000088; }\
    </style>\
  </head>\
  <body>%i-%02i-%02i %02i:%02i:%02i<br>\
    <form action='/dong'>repeat <input type='text' name='repeat' value='1'><br> <input type='submit' value='Dong'></form><hr>\
    <form action='/configure'>min <input type='text' name='min' value='%i'><br>ready <input type='text' name='ready' value='%i'><br>readydelay <input type='text' name='readydelay' value='%i'><br>max <input type='text' name='max' value='%i'><br>delay <input type='text' name='delay' value='%i'><br>multidelay <input type='text' name='multidelay' value='%i'><br>chime from <input type='text' name='chimefrom' value='%i'><br>chime to <input type='text' name='chimeto' value='%i'><br>timezone <input type='text' name='timezone' value='%i'><br> ntpserver <input type='text' name='ntpserver' value='%s'><br> factory reset <input type='checkbox' name='factoryreset' value='1'><br> <input type='submit' value='Set'></form>\
  </body>\
</html>", actualyear, actualMonth, actualday, actualHour, actualMinute, actualsecond, aMin, aReady, aReadyDelay, aMax, aDelay, aMultiDelay, aChimeFrom, aChimeTo, aTimeZone, aNTPServer);
  server.send ( 200, "text/html", temp );
}

void handleNotFound() {
   String message = "File Not Found\n\n";
  message += "URI: ";
  message += server.uri();
  message += "\nMethod: ";
  message += ( server.method() == HTTP_GET ) ? "GET" : "POST";
  message += "\nArguments: ";
  message += server.args();
  message += "\n";

  for ( uint8_t i = 0; i < server.args(); i++ ) {
    message += " " + server.argName ( i ) + ": " + server.arg ( i ) + "\n";
  }

  server.send ( 404, "text/plain", message );
}



void doDong() 
{ 
  int repeat = 0;
  
  repeat = atoi(server.arg("repeat").c_str());

  if (repeat < 1) repeat = 1;
  
  multiDong(repeat);            

  handleRoot();
}


void multiDong(int dongs) 
{ 
  int repeat = 0;
  int i=0;
  unsigned long time_now = 0;
  
  repeat = dongs;

  if (repeat == 0) repeat = 1;
  digitalWrite(servoEnable, HIGH);

  //servoA.write(aMin);
  //delay(600);

  servoA.write(aReady);
  
  time_now = millis();
  while(millis() < time_now + aReadyDelay) {
     ESP.wdtFeed();
  }

  for (i=0; i < repeat; i++ ) {
    
   Serial.println ( "DONG!" );                         

    servoA.write(aMax);              
  time_now = millis();
  while(millis() < time_now + aDelay) {
    //foo
     ESP.wdtFeed();
  }

  // Don't hold ready position if last multidong, just go back to amin
  if(true || i<repeat-1) {
    servoA.write(aReady);
    time_now = millis();
    while(millis() < time_now + aMultiDelay) {
       ESP.wdtFeed();
    }
  }
  
  }
  
  servoA.write(aMin);

  time_now = millis();
  while(millis() < time_now + aReadyDelay) {
     ESP.wdtFeed();
  }
              
  digitalWrite(servoEnable, LOW);
}
void doConfigure() { 

  aMin = atoi(server.arg("min").c_str());
  aReady = atoi(server.arg("ready").c_str());
  aReadyDelay = atoi(server.arg("readydelay").c_str());
  aMax = atoi(server.arg("max").c_str());
  aDelay = atoi(server.arg("delay").c_str());
  aTimeZone = atoi(server.arg("timezone").c_str());
  strcpy(aNTPServer, server.arg("ntpserver").c_str());
  aFactoryReset = atoi(server.arg("factoryreset").c_str());
  aChimeFrom = atoi(server.arg("chimefrom").c_str());
  aChimeTo = atoi(server.arg("chimeto").c_str());
  aMultiDelay = atoi(server.arg("multidelay").c_str());
  
  if (aFactoryReset == 1) {
    doFactoryReset();
  }
  else {
    settings.min = aMin;
    settings.ready = aReady;
    settings.readydelay = aReadyDelay;
    settings.max = aMax;
    settings.delay = aDelay;
    settings.timezone = aTimeZone;
    strcpy(settings.ntpserver, aNTPServer);
    settings.chimefrom = aChimeFrom;
    settings.chimeto = aChimeTo;
    settings.multidelay = aMultiDelay;
    
    EEPROM.put(addr,settings);
    EEPROM.commit();
  }
  doDong();
}


void getSettings() {

  EEPROM.get(addr,settings);
  aMin = settings.min;
  aReady = settings.ready;
  aReadyDelay = settings.readydelay;
  aMax = settings.max;
  aDelay = settings.delay;
  aTimeZone = settings.timezone;
  strcpy(aNTPServer, settings.ntpserver);
  aChimeFrom = settings.chimefrom;
  aChimeTo = settings.chimeto;
  aMultiDelay = settings.multidelay;
  aFactoryReset = (int) settings.factoryreset;
 /// factory reset not working with settings  try updating the aFactorReset and check that instead
}

void doFactoryReset() {
  // Do factory reset
  
  /*
  settings.min = 97;
  settings.ready = 108;
  settings.readydelay = 1000;
  settings.max = 116;
  settings.delay = 153;
  settings.factoryreset = 245; // Magic number
  settings.timezone = -5.0; // Eastern
  strcpy(settings.ntpserver, "ch.pool.ntp.org");
  settings.chimefrom = 7;
  settings.chimeto = 22;
  */
  
  settings.factoryreset = factoryResetMagic; // Magic number
  settings.min = 85;
  settings.ready = 80;
  settings.readydelay = 300;
  settings.max = 130;
  settings.delay = 40;
  settings.timezone = -5.0; // Eastern
  strcpy(settings.ntpserver, "ch.pool.ntp.org");
  settings.chimefrom = 6;
  settings.chimeto = 22;
  settings.multidelay = 2500;

  EEPROM.put(addr,settings);
  EEPROM.commit();

  getSettings();
}

void setup ( void ) {
  
  Serial.begin ( 115200 );
  
  EEPROM.begin(512);

  getSettings();

  if (aFactoryReset != factoryResetMagic) {
    Serial.println ( "Factory Reset: First / Update" );
    doFactoryReset();
  }
  

  WiFi.mode ( WIFI_STA );
  WiFi.begin ( ssid, password );
  Serial.println ( "" );

  // Wait for connection
  while ( WiFi.status() != WL_CONNECTED ) {
    delay ( 500 );
    Serial.print ( "." );
  }

  Serial.println ( "" );
  Serial.print ( "Connected to " );
  Serial.println ( ssid );
  Serial.print ( "IP address: " );
  Serial.println ( WiFi.localIP() );
  
  Serial.println ( "" );
  Serial.print ( "Getting time from NTP server" );

  while (!NTPch.setSNTPtime()) Serial.print("."); // set internal clock
  Serial.println();
  Serial.println("Time set");

        
  if ( MDNS.begin ( mdnsName ) ) {
    Serial.println ( "MDNS responder started" );
  }

  server.on ( "/", handleRoot );
  server.on ( "/dong", doDong );
  server.on ( "/configure", doConfigure );
  server.onNotFound ( handleNotFound );
  server.begin();
  Serial.println ( "HTTP server started" );

  servoA.attach(servoPinA); 
                              
  servoA.write(aMin);               

  pinMode(servoEnable, OUTPUT);
  digitalWrite(servoEnable, LOW);
  
  
}

void loop ( void ) {
  
  server.handleClient();

  dateTime = NTPch.getTime(aTimeZone, 1); // get time from internal clock
  
  byte actualHour = dateTime.hour;
  //byte actualMinute = dateTime.minute;
  //actualHour = actualMinute; // minutely for testing
  
  if (dongArmed == 1 && lastHour != actualHour) {

    if (actualHour >= aChimeFrom && actualHour <= aChimeTo) {
      
      Serial.println("Hourly Dongin'!");
      if (actualHour > 12) {
        multiDong(actualHour - 12); // AM/PM conversion
      }
      else {
        multiDong(actualHour);
      }

    }
    dongArmed = 0;
    lastHour = actualHour;

    // Synch internal clock
    Serial.println ( "Hope to get time from NTP server" );
    NTPch.setSNTPtime();

  }
  if (lastHour != actualHour) {
    dongArmed = 1;
  }

}




 
 
