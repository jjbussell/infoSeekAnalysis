#include "Arduino.h"
#include "Printer.h"
#include "OdorAssoc.h"


////////////////////  SWITCHING SIDES  ///////////////////////////////////
void setSide(){
  if (infoSide == 0){
    for (int s = 0; s < 2; s++){
        digitalWrite(valves3a[infoOdors[s]], HIGH);
        digitalWrite(valves3b[randOdors[s]], HIGH); 
      }
    delay(20);
    for (int s = 0; s < 2; s++){
      digitalWrite(valves3a[infoOdors[s]], LOW);
      digitalWrite(valves3b[randOdors[s]], LOW);
    }
    Serial.println("Info side left."); // cycle valves3a = LEFT
    randSide = 1;
  }
  else  {
    for (int s = 0; s < 2; s++){
      digitalWrite(valves3a[randOdors[s]], HIGH);
      digitalWrite(valves3b[infoOdors[s]], HIGH);  
    }
    delay(20);
    for (int s = 0; s < 2; s++){
      digitalWrite(valves3a[randOdors[s]], LOW);
      digitalWrite(valves3b[infoOdors[s]], LOW); 
    }
    Serial.println("Info side right.");  
    randSide = 0;
  }  
  infoPort = portSensors[infoSide];
  randPort = portSensors[randSide];
  infoControl = controlList[infoSide];
  randControl = controlList[randSide]; 
  infoWater = waterValves[infoSide];
  randWater = waterValves[randSide];    
}

///////////////////  ODOR CONTROL  ////////////////////////

// To turn ON an odor
void odorOn (int rewardOdor) {
  digitalWrite (valves1[rewardOdor], HIGH);
  digitalWrite (valves2[rewardOdor], HIGH);
  odorValveOpen = 1;
  Serial.print("Odor on ");
  Serial.println(rewardOdor);
  printer(3, rewardOdor, 1);
}

// To turn OFF an odor
void odorOff (int rewardOdor) {
  digitalWrite (valves1[rewardOdor], LOW);
  digitalWrite (valves2[rewardOdor], LOW);
  odorValveOpen = 0;
  Serial.print("odor off ");
  Serial.println(rewardOdor);
  printer(5, rewardOdor, 1);
}



// To turn ON mineral oil 1 or 2 valves (mineral oil OFF, odor ON)
/* Mineral oil tubing goes to normally open port of valve,
turning on valve closes the port, valve must be ON for
odor delivery, otherwise OFF and mineral oil open to flow*/
void controlOff (int control) {
  if (control == 1)
  {
    digitalWrite (controls[0], HIGH);
    digitalWrite (controls[1], HIGH);
  }
  else if (control == 2) {
    digitalWrite (controls[2], HIGH);
    digitalWrite (controls[3], HIGH);
  }
  else{
    digitalWrite (controls[4], HIGH);
    digitalWrite (controls[5], HIGH);
  }
}


// To turn OFF mineral oil 1 or 2 valves (mineral oil ON, odor off)
/* Mineral oil tubing goes to normally open port of valve, turning
on valve closes the port, valve must be ON for odor delivery,
otherwise OFF and mineral oil open to flow*/
void controlOn (int control) {
  if (control == 1)
  {
    digitalWrite (controls[0], LOW);
    digitalWrite (controls[1], LOW);
  }
  else if (control == 2){
    digitalWrite (controls[2], LOW);
    digitalWrite (controls[3], LOW);
  }
  else {
    digitalWrite (controls[4], LOW);
    digitalWrite (controls[5], LOW);
  }
}

