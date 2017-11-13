#include "AssocStates.h"
#include "Arduino.h"


//// INTER_TRIAL_INTERVAL 15
void StateInterTrialInterval::s_setup()
{
  Serial.println("ITI");
//  Serial.println("setting duration");
  set_duration(interval);
  Serial.print("Completed Trials: ");
  Serial.println(TCount);
  Serial.print("CS+ 1 Trials: ");
  Serial.print(plus1Ct);
  Serial.print("   CS+ 2 Trials: ");
  Serial.println(plus2Ct);
  Serial.print("CS- 1 Trials: ");
  Serial.print(minus1Ct);
  Serial.print("   CS- 2 Trials: ");
  Serial.println(minus2Ct);
  Serial.print("US Trials: ");
  Serial.print(USCt);
  Serial.print("Reward Amount: ");
  Serial.println(rewardAmt);
}

void StateInterTrialInterval::s_finish()
{
//  Serial.println("ending ITI, move to WAIT_FOR_TRIAL");
  next_state = WAIT_FOR_TRIAL;   
}

//// WAIT_FOR_TRIAL 0
void StateWaitForTrial::s_setup()
{
  Serial.println("WAIT_FOR_TRIAL");
  trialStart = 0;
  trialCt++;
}

void StateWaitForTrial::s_finish()
{
//  Serial.println("end wait for trial, move to START_TRIAL");
  next_state = START_TRIAL;
}


//// START_TRIAL_DELAY 2
void StateStartTrialDelay::s_setup()
{
  Serial.println("DELAY for beep");
}

void StateStartTrialDelay::s_finish()
{
//  Serial.println("end start trial delay, move to WAIT_FOR_CENTER");
  Serial.println("WAIT_FOR_ENTRY");
  next_state = WAIT_FOR_ENTRY;
}


//// BASELINE 4
void StateBaseline::s_setup()
{
  Serial.println("BASELINE");
  printer(13,0,0);
}

void StateBaseline::loop()
{
  if (portFlag == 0){
    Serial.println("WAIT_FOR_ENTRY");
    timer = 0;
    // TURN OFF IMAGING
    next_state = WAIT_FOR_ENTRY;
  }
}

void StateBaseline::s_finish()
{
//  Serial.println("ending center odor delay, move to CENTER_ODOR");
  next_state = ODOR;
}

//// ODOR 5
void StateOdor::s_setup()
{
  // IF TRIALTYPE <> US
  odorOn(odor);
}

void StateOdor::loop()
{
  if (portFlag == 0){
    Serial.println("WAIT_FOR_ENTRY");
    if (odorValveOpen == 1){   
      odorOff(odor);
    }
    // TURN OFF IMAGING
    timer = 0;
    next_state = WAIT_FOR_ENTRY;
  }
}

void StateOdor::s_finish()
{
  if (odorValveOpen == 1){
    odorOff(odor);
  }
  next_state = DELAY;
}


//// DELAY 6
void StateDelay::s_setup()
{
  Serial.println("DELAY");
  buzzInterval = delay/10;
  change = 0;
  buzzCt = 0;
  lastBuzzCt = 0;
}

void StateDelay::loop(){

  //check if time to turn buzzer on
  if (currentTime >= lastBuzzerOff + buzzInterval) {
    tone(buzzer,8000);
//      Serial.print("t ");
//      Serial.print(currentTime);
//      Serial.println(" buzz");
    buzzCt++;
    lastBuzzerOn = currentTime;
    lastBuzzerOff = 1000000000000000000000;
  }

  // check if time to turn buzzer off
  if (currentTime >= lastBuzzerOn + 20) {
    noTone(buzzer);
    lastBuzzerOff = currentTime;
//      Serial.print("off ");
//      Serial.println(currentTime);
    lastBuzzerOn = 1000000000000000000000;
  }

  // check if time to decrease interval
  if (currentTime % (1000) == 0 & change == 0 ){
    buzzInterval = buzzInterval - 100;
//      Serial.print("I ");
//      Serial.print(currentTime);
//      Serial.print("interval ");
//      Serial.println(buzzInterval);
    change = 1;
    lastBuzzCt = buzzCt;
  }

  if (currentTime % (1000) != 0 & change == 1){
    change = 0;
  }
}

void StateRewardDelay::s_finish()
{
 Serial.println("end delay, move to OUTCOME");

  noTone(buzzer);
  int port;
  port = 5;
  
//  Serial.print("reward delay end ");
//  Serial.println(currentTime);
//
 Serial.print("current reward time (drops) ");
 Serial.println(currentRewardTime);

  Serial.print("lickRate = ");
  Serial.println(lickRate);

  rewardCount++;
  rewardDrops = currentRewardTime;
  Serial.print("reward drops = ");
  Serial.println(rewardDrops);

  if (reward == 1) {
    rewardBigCount++;
    Serial.println("Reward");
    printer(15, trialType, choice);
    
  }
  else {
    rewardSmallCount++;
    Serial.println("No reward");
    printer(16, trialType, choice);
  }

  next_state = OUTCOME;
}


//// TIMEOUT 11
void StateTimeout::s_setup(){
  printer(11,choice,0);
  Serial.println("TIMEOUT");
}

void StateTimeout::s_finish()
{
  next_state = INTER_TRIAL_INTERVAL;
}

//// REWARD_PAUSE 8
void StateRewardPause::s_setup(){
  Serial.println("REWARD PAUSE");
}

void StateRewardPause::s_finish(){
  next_state = OUTCOME;
}


