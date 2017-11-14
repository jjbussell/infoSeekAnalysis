#include "Arduino.h"
#include "Printer.h"
#include "OdorAssoc.h"


////////////////////  SWITCHING SIDES  ///////////////////////////////////
void setSide(int currentPort){
  if (currentPort == 1){
    for (int s = 0; s < 4; s++){
        digitalWrite(valves3a[odors[s]], HIGH);
        digitalWrite(valves3b[odors[s]], HIGH); 
      }
    delay(20);
    for (int s = 0; s < 4; s++){
      digitalWrite(valves3a[odors[s]], LOW);
      digitalWrite(valves3b[odors[s]], LOW);
    }

    odorControl = 1;
    water = waterValves[0];

    Serial.println("Port left."); // cycle valves3a = LEFT
  }
  else  {
    for (int s = 0; s < 4; s++){
      digitalWrite(valves3a[odors[s]], HIGH);
      digitalWrite(valves3b[odors[s]], HIGH);  
    }
    delay(20);
    for (int s = 0; s < 4; s++){
      digitalWrite(valves3a[odors[s]], LOW);
      digitalWrite(valves3b[odors[s]], LOW); 
    }

    odorControl = 2;
    water = waterValves[1];
    Serial.println("Port right.");  
  } 
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

