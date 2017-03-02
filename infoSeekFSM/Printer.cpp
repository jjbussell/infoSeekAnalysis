#include "Arduino.h"
#include "Printer.h"


//////////////////////  PRINTER  ////////////////////////////////////////////
void printer (int event, int param, int correct) {
  currentTime = millis() - startTime; //get the current time in this session
  String comma = ",";
  String dataLog = currentTime + comma + trialCt + comma + event + comma + param + comma + correct;

  Serial.println(dataLog);
}
