#include "TrialParams.h"
#include "Arduino.h"

/////// REMEMBER TO CHANGE BLOCK COUNT IN SWITCHING TO NEW BLOCK AT TRIAL START!!!
////// ALSO REMEMBER TO COUNT UP CHOICE TRIALS!!!!

void blockSetup(void){
  float choicePercent;
  float infoPercent;
  float randPercent;
  float infoBlockCount;
  float randBlockCount;
  float choiceBlockCount;
  int blockTypeCounts[4];
  int blockTypes = [2,3,4,5];
  float choiceInfoBigSize;
  float choiceInfoSmallSize;
  float choiceRandBigSize;
  float choiceRandSmallSize;
  int choiceInfoBigCount;
  int choiceInfoSmallCount;
  int choiceRandBigCount;
  int choiceRandSmallCount;
  float blockTypeSize[4];
  int blockTypeCounts[4];
  int blockShuffle[blockSize];
  int blockTypeCount;
  int blockType;
  int startType;
  int typeStop = choiceBlockSize;
  int blockTypes[] = {2,3,4,5};
  int n;
  int temp;

  switch (trialTypes) {
    case 1: // choice
      choicePercent = 1; infoPercent = 0; randPercent = 0;
      break;
    case 2: // forced info
      choicePercent = 0; infoPercent = 1; randPercent = 0;
      break;
    case 3: // forced rand
      choicePercent = 0; infoPercent = 0; randPercent = 1;
      break;
    case 4: // forced info and forced rand alternating
      choicePercent = 0; infoPercent = 0.5; randPercent = 0.5;
      break;
    case 5: // all three alternating
      choicePercent = 0.334; infoPercent = 0.334; randPercent = 0.334;
      break;
    case 6: // biased, hardcode which
      choicePercent = 0; infoPercent = 0.85; randPercent = 0.15;
      break;
    case 7: // choice training info
      choicePercent = 0.5; infoPercent = 0.5; randPercent = 0;
      break;
    case 8: // choice training rand
      choicePercent = 0.5; infoPercent = 0; randPercent = 0.5;
      break;
  }

  randBlockCount = randPercent * (float)blockSize;
  infoBlockCount = infoPercent * (float)blockSize;
  choiceBlockCount = choicePercent * (float)blockSize;
  choiceBlockSize = (int)choiceBlockCount;

  choiceInfoBigSize = choiceBlockCount - (float)infoRewardProb/100*choiceBlockCount;
  choiceInfoSmallSize = choiceBlockCount - choiceInfoBigSize;
  choiceRandBigSize = choiceBlockCount - (float)randrewardProb/100*choiceBlockCount;
  choiceRandSmallSize = choiceBlockCount - choiceRandBigSize;

  choiceInfoBigCount = (int)choiceInfoBigSize;
  choiceInfoSmallCount =(int)choiceInfoSmallSize;
  choiceRandBigCount = (int)choiceRandBigSize;
  choiceRandSmallCount = (int)choiceRandSmallSize;

  for (int n=0;n<choiceBlockSize;n++){
    if (n<choiceInfoBigCount){
      choiceInfoBlock[n] = 1;
    }
    else {
      choiceInfoBlock[n] = 0;
    }
    if (n<choiceRandBigCount){
      choiceRandBlock[n] = 1;
    }
    else {
      choiceRandBlock[n] = 0;
    }
  }

  blockTypeSize[0] = infoBlockCount - (float)infoRewardProb/100*infoBlockCount; // info big
  blockTypeSize[1] = infoBlockCount - blockTypeSize[0]; // info small
  blockTypeSize[2] = randBlockCount-(float)randRewardProb/100*randBlockCount; // rand big
  blockTypeSize[3] = randBlockCount-blockTypeSize[2]; // rand small  

  for (int i = 0; i<4; i++){
    blockTypeCounts[i]=(int)blockTypeSize[i];
  }

  /// MAKE FULL BLOCK TO SHUFFLE
  for (int i=0; i<blockSize; i++){
    blockShuffle[i]=0;
  }

  // Place choice trials
  for (int i = 0; i<choiceBlockSize; i++){
    blockShuffle[i] = 1;
  }

  // Place info and random trials
  for (int i = 0; i<4; i++){
    blockTypeCount = blockTypeCounts[i];
    blockType = blockTypes[i];
    startType = typeStop; 
    for (int j = startType; j<blockTypeCount+startType; j++){
      blockShuffle[j] = blockType;
    }
    typeStop = startType+blockTypeCount;
  }

  // SHUFFLE BLOCK  

  for ( int p=0; p<blockSize; p++){
    block[p] = blockShuffle[p];
  }
  for (int i=0; i<blockSize; i++){
    n = random(0,blockSize);
    temp = block[n];
    block[n] = block[i];
    block[i] = temp;
  }    
}







////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


/*
 * move reward or not into trial type!
 * then, pickTrialParams just sets amount and odor (printout/repeat reward or not?)
 * want blocks of 12 (not 20!) trials:
 * 4 choice (2 big, 2 small), 4 info (2 big, 2 small), 4 rand (2 big, 2 small)-->6 types or 4 types
 * 1 1 2 2 3 3 4 4 5 5 6 6
 * 1 2 3 4 5 6 7 8 9 10 11 12
 * no, just do blocks of either 6 or 4 so
 * 1 2 3 4
 * rand(1-4)
 * 
 * newBlock vs pickTrialParams-->new block needs to pick the trial types in the pseudorandom way
 * 
 * randomTrial()
 * determineTrial()
 * 
 */



// To SET THE NUMBER OF DROPS AND WATER VALVE AND RANDOM ODOR AND REWARD IF CHOICE!
void pickTrialParams(int choice){

  // REWARD SIZE IS ALREADY SET
  
  unsigned long bigRewardTime;
  unsigned long smallRewardTime;
  
  // vals based on choice
  if (choice == 1){
    water = infoWater; // which valve
    bigRewardTime = infoBigRewardTime;
    smallRewardTime = infoSmallRewardTime;
  }
  else if (choice == 0){
    water = randWater;
    bigRewardTime = randBigRewardTime;
    smallRewardTime = randSmallRewardTime;
  }
  else {
    water = infoWater;
    smallRewardTime = infoSmallRewardTime;
    bigRewardTime = infoBigRewardTime;
  }

  if (reward == 1) {
    currentRewardTime = bigRewardTime;
  }
  else {
    currentRewardTime = smallRewardTime;
  }

  int odorPick;
  odorPick = randomize(randRewardProb); // 1 = OdorC, 0 = OdorD
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
int randomize(int prob) {
  int randVal = 0;
  long randNum = random(100);
  if (randNum < prob) {
    randVal = 1;
  }
  return randVal;
} 


///// SET BLOCK OF TRIAL TYPES
void newBlock(){
  // if trialTypes == 5, blocks of 6. if trialTypes == 4,7,8, blocks of 4. else, constant blocks of 6.
  // NO, blocks of 24 either way. If trialTypes == 5, 8 of each type, 2 big, 6 small. If trialTypes == 4, 12 of each type, 3 big, 9 small
  // trialTypes 5 array to shuffle

  // shuffle pre-set arrays of 24? make one for all possible options (reward probs and trialTypes)? Just give up on unequal reward probs? In that case set reward separately??

  // REWARD PROBS
  if (infoRewardProb == randRewardProb){
  
    switch (trialTypes) {
        case 1: // choice
          if (infoRewardProb == 100){
            for (int i=0; i < 24; i++){
              blockShuffle[i] = 1;
            }
          }
          else if (infoRewardProb == 50){
            blockShuffle = [1 1 1 1 1 1 1 1 1 1 1 1 1 2 2 2 2 2 2 2 2 2 2 2 2];
          }
          else if (infoRewardProb == 25){
          }
          for (int i=0; i < 24; i++){
            block[i] = 1;   
          }

          // first calc fraction info, random, choice
          // then have count of each type for reward array size
          // create final mini-arry for each choice type

//////////////////////////////////////////////////////////////////////////////////
          // these change based on trialtypes
          float randPercent = 0.333
          float infoPercent = 0.333
          float choicePercent = 0.334

          int blockCount = 24;

          int randBlockCount = randPercent * blockCount;
          infoBlockCount = infoPercent * blockCount;
          choiceBlockCount = choicePercent * blockCount;

          int blockTypeCounts[4];

          blockTypeCounts[0] = infoBlockCount - infoRewardProb/100*infoBlockCount; // info big
          blockTypeCounts[1] = infoBlockCount - blockInfoBigCount; // info small
          blockTypeCounts[2] = randBlockCount-randRewardProb/100*randBlockCount; // rand big
          blockTypeCounts[3] = randBlockCount-blockRandBigCount; // rand small

          int blockTypes = [2 3 4 5];

          choiceInfoBigCount = choiceBlockCount - infoRewardProb/100*choiceBlockCount;
          choiceInfoSmallCount = choiceBlockCount - choiceInfoBigCount;
          choiceRandBigCount = choiceBlockCount - randRewardProb/100*choiceBlockCount;
          choiceRandSmallCount = choiceBlockCount-choiceRandBigCount;

          int blockShuffle[blockCount];

          for (i = 0; i<choiceBlockCount; i++){
            blockShuffle[i] = 1;
            typeStop = choiceBlockCount;
          }

          for (i = 0; i<4; i++){
            blockTypeCount = blockTypeCounts[i];
            blockType = blockTypes[i];
            startType = typeStop+1;
            for (j = startType; j<blockTypeCount; j++){
              blockShuffle[j] = blockType;
            }
            typeStop = startType+blockTypeCount;
          }


          ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

          
          for (int i = 0; i < blockBigCount; i++){
            blockShuffle[i] = bigType;
          }
          for (int j = blockBigCount+1; j<24; j++){
            blockShuffle[j] = smallType;
          }
          
          break;
        case 2: // forced info
          for (int i=0; i < 24; i++){
            block6[i] = 2;   
          }
          break;
        case 3: // forced rand
          for (int i=0; i < 24; i++){
            block6[i] = 3;   
          }
          break;
        case 4: // alternate forced info and forced rand
          block4 = shuffleBlock();
          break;
        case 5: // all three trial types
          //
          block6 = shuffleBlock();
          break;
        case 7: // forced info or choice
          block4 = shuffleBlock();
          break;
        case 8: // forced rand or choice
          block4 = shuffleBlock();
          break;
    }
  }
 }


///// SET BLOCK OF TRIAL TYPES
void newBlock(){
  // if trialTypes == 5, blocks of 6. if trialTypes == 4,7,8, blocks of 4. else, constant blocks of 6.
  // put the trialTypes switch here!
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
