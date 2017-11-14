#include "TrialParamsAssoc.h"
#include "Arduino.h"

// To determine the reward size and odor of the trial
void pickTrialParams(int currentTrialType){
//  Serial.println("pickTrialParams()");
  switch (currentTrialType) {
      case 1:
        currentOdor = plus1;
        reward = 1;
        break;
      case 2:
        currentOdor = plus2;
        reward = 1;
        break;
      case 3:
        currentOdor = minus1;
        reward = 1;
        break;
      case 4:
        currentOdor = minus2;
        reward = 1;
        break;
      case 5:
        currentOdor = 7;
        reward = 1;
        break;     
  }
}


void newBlock(){
  Serial.println("newBlock()");
  
  for (int v = 0; v < 5; v++){
    lastBlock[v] = block[v];
  }

  if (trialTypes == 1){
    block[0]=random(1,6);
    while(block[0]==lastBlock[4]){
      block[0] = random(1,5);
    }
  
    block[1]=random(1,6);
  
    while(block[1]==block[0]){
    block[1]=random(1,6);
    }
  
    block[2]=random(1,6);
  
    while(block[2]==block[0]||block[2]==block[1]){
      block[2]=random(1,6);
    }
  
    block[3]=random(1,6);
  
    while(block[3]==block[0]||block[3]==block[1]||block[3]==block[2]){
      block[3]=random(1,6);
    }
  
    block[4]=random(1,6);
  
    while(block[4]==block[0]||block[4]==block[1]||block[4]==block[2]||block[4]==block[3]){
      block[4]=random(1,6);
    }
  }

   else{
    for (int w = 0; w < 5; w++){
      block[w] = 5;
    }
   }
   
   Serial.print("block = ");
   for (int w = 0; w < 5; w++){
     Serial.println(block[w]);
     }
}
