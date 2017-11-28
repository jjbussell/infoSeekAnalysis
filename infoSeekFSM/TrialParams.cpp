#include "TrialParams.h"
#include "Arduino.h"

// To determine the reward size and odor of the trial
void pickTrialParams(int choice){
  int probBig;
  unsigned long bigRewardTime;
  unsigned long smallRewardTime;
  
  // vals based on choice
  if (choice == 1){
    water = infoWater;
    probBig = infoRewardProb;
    bigRewardTime = infoBigRewardTime;
    smallRewardTime = infoSmallRewardTime;
  }
  else if (choice == 0){
    water = randWater;
    probBig = randRewardProb;
    bigRewardTime = randBigRewardTime;
    smallRewardTime = randSmallRewardTime;
  }
  else {
    water = infoWater;
    probBig = 0;
    smallRewardTime = infoSmallRewardTime;
    bigRewardTime = infoBigRewardTime;
  }

  reward = determineReward(probBig);

  if (reward == 1) {
    currentRewardTime = bigRewardTime;
  }
  else {
    currentRewardTime = smallRewardTime;
  }

  int odorPick;
  odorPick = determineReward(randRewardProb); // 1 = OdorC, 0 = OdorD
  if ((choice == 1) && (reward == 1)) {
    odor = odorA;
  }
  else if ((choice == 1) && (reward == 0)) {
    odor = odorB;
  }
  else if ((choice == 0) && (odorPick == 1)) {
    odor = odorC;
  }
  else if ((choice == 0) && (odorPick == 0)) {
    odor = odorD;
  }
  else { odor = 7;}
}

// To randomly determine big or small reward (1, 0 respectively)
// based on reward probability
int determineReward(int rewardProb) {
  int randVal = 0;
  long randNum = random(100);
  if (randNum < rewardProb) {
    randVal = 1;
  }
  return randVal;
} 


////////////////  RANDOMIZATION  /////////////////////////
// To randomize a value to 0 or 1
int randomize() {
  int randVal = 0;
  int randNum = random(10);
  if (randNum > 4) {
    randVal = 1;
  }
  return randVal;
}


///// SET BLOCK OF TRIAL TYPES
void newBlock(){
  for (int v = 0; v < 20; v++){
    lastBlock[v] = block[v];
  }

  for (int n=0; n < 3; n++){
    block[n] = randomTrial(trialTypes);   
  }

  if (trialTypes == 4 || trialTypes == 5){
    while (block[1] == block[0] && block[0] == lastBlock [20]){
      block[1] = randomTrial(trialTypes);
    }

    while (block[0] == lastBlock[20] && lastBlock[20] == lastBlock[19]){
      block[0] = randomTrial(trialTypes);
    }
    
    while (block[2] == block[1] && block[1] == block[0]){
      block[2] = randomTrial(trialTypes);
    }
    
    for (int i = 3; i < 20; i++){
      block[i] = randomTrial(trialTypes);
      while (block[i] == block[i-1] && block[i-1] == block[i-2]){
        block[i] = randomTrial(trialTypes); 
      }
    }
  }
  
  else {
    for (int m=3; m < 20; m++){
      block[m] = randomTrial(trialTypes);   
    }   
  }
}

int randomTrial(int trialTypes){
  int trialPick;
  int tempPick = 0;
  
  switch (trialTypes) {
      case 1:
        trialPick = 1;
        break;
      case 2:
        trialPick = 2;
        break;
      case 3:
        trialPick = 3;
        break;
      case 4:
        trialPick = determineForcedTrial();
        break;
      case 5:
        trialPick = determineTrial();
        break;
      case 6:
        trialPick = determineBiasedTrial();
        break;
      case 7: // forced info or choice
        tempPick = determineForcedTrial();
        if (tempPick == 3){
          trialPick = 1; 
        }
        else trialPick = 2;
        break;
      case 8: // forced rand or choice
        tempPick = determineForcedTrial();
        if (tempPick == 2){
          trialPick = 1; 
        }
        else trialPick = 3;
        break;      
  }
  return trialPick;
}

// To randomize trial type
// returns 1 = choice, 2 = force info, 3 = force random
int determineTrial () {
  int newTrialType;
  long randNum = random(90);
  if (randNum < 30) {
    newTrialType = 1;
  }
  else if (randNum < 60) {
    newTrialType = 2;
  }
  else {
    newTrialType = 3;
  }
  return newTrialType;
}

int determineForcedTrial () {
  int newTrialType;
  int randNum = random(100);
  if (randNum < 50) {
    newTrialType = 2;
  }
  else {
    newTrialType = 3;
  }
  return newTrialType;
}

int determineBiasedTrial () {
  int newTrialType;
  int randNum = random(100);
  if (randNum < 85) {
    newTrialType = 2;
  }
  else {
    newTrialType = 3;
  }
  return newTrialType;
}
