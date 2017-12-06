#include "AssocStates.h"
#include "Arduino.h"


//// WAIT_FOR_TRIAL 0
void StateWaitForTrial::s_setup()
{
  Serial.println("WAIT_FOR_TRIAL");
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
//  set_duration(baseline);
  Serial.println("BASELINE");

  if (imageFlag == 1){
      Serial.println("start imaging");
      digitalWrite(arduScope, LOW); //start imaging
      image = 1;
      printer(22,0,0);
  }

  printer(13,0,0);
}

void StateBaseline::loop()
{
  if (portFlag == 0){
    if (image == 1){
      image = 0;
      digitalWrite(arduScope, HIGH);   
      Serial.println("stop imaging");
      printer(23,0,0);         
    }
    timer = 0;
      Serial.println("WAIT_FOR_ENTRY");
    next_state = WAIT_FOR_ENTRY;
  }
}

void StateBaseline::s_finish()
{
  next_state = ODOR;
}

//// ODOR 5
void StateOdor::s_setup()
{
  Serial.println("ODOR");
  if (trialType < 5){
    controlOff(odorControl);
    odorOn(currentOdor);
    } 
}

void StateOdor::loop()
{
  if (portFlag == 0){
    Serial.println("Exit-->TIMEOUT");
    if (odorValveOpen == 1){   
      odorOff(currentOdor);
      controlOn(odorControl);
    }
//    if (image == 1){
//      image = 0;
//      digitalWrite(arduScope, HIGH);   
//      Serial.println("stop imaging");         
//    }
    next_state = TIMEOUT;
  }
}

void StateOdor::s_finish()
{
  if (odorValveOpen == 1){
    odorOff(currentOdor);
    controlOn(odorControl);
  }
  next_state = OUTCOME_DELAY;
}


//// OUTCOME_DELAY 6
void StateOutcomeDelay::s_setup()
{
  Serial.println("OUTCOME DELAY");
  buzzInterval = delayTime/10;
  change = 0;
  buzzCt = 0;
  lastBuzzCt = 0;
}

void StateOutcomeDelay::loop(){

  //check if time to turn buzzer on
  if (currentTime >= lastBuzzerOff + buzzInterval) {
//    tone(buzzer,8000);
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

  // timeout if leave
  if (portFlag == 0){
    Serial.println("Exit-->TIMEOUT");
    if (odorValveOpen == 1){   
      odorOff(currentOdor);
    }
    next_state = TIMEOUT;
  }

}

void StateOutcomeDelay::s_finish()
{
 Serial.println("end delay, move to DELIVER_REWARD");

  noTone(buzzer);
  
//  Serial.print("reward delay end ");
//  Serial.println(currentTime);

  // Serial.print("lickRate = ");
  // Serial.println(lickRate);

  if (reward == 1){
    rewardDrops = drops;
    printer(15,trialType,0);
  }
  else{
    rewardDrops = 0;
    printer(16,trialType,0);
  }
  
  Serial.print("reward drops = ");
  Serial.println(rewardDrops);

  next_state = DELIVER_REWARD;
}


//// REWARD_PAUSE 8
void StateRewardPause::s_setup(){
  Serial.println("REWARD PAUSE");
}

void StateRewardPause::s_finish(){
  next_state = DELIVER_REWARD;
}


//// IMAGING_DELAY 10
void StateImagingDelay::s_setup(){
  Serial.println("Still Imaging");
}

void StateImagingDelay::s_finish(){
  if (image == 1){
    image = 0;
    digitalWrite(arduScope, HIGH);   
    Serial.println("stop imaging");
    printer(23,0,0);         
  }

  next_state = INTER_TRIAL_INTERVAL;
}


//// TIMEOUT 11
void StateTimeout::s_setup(){
  set_duration((entryTime + baseline + odorTime + delayTime + drops*rewardDropTime + (drops-1)*rewardPauseTime + imagingTime) - currentTime);
  Serial.print("timeout duration = ");
  Serial.println((entryTime + baseline + odorTime + delayTime + drops*rewardDropTime + (drops-1)*rewardPauseTime + imagingTime) - currentTime);
  printer(11,trialType,0);
  Serial.println("TIMEOUT");
}

void StateTimeout::s_finish()
{
  if (image == 1){
    image = 0;
    digitalWrite(arduScope, HIGH);   
    Serial.println("stop imaging");
    printer(23,0,0);         
  }
   
  next_state = INTER_TRIAL_INTERVAL;
}


//// INTER_TRIAL_INTERVAL 12
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
  Serial.print("   Reward Amount: ");
  Serial.println(rewardAmt);
}

void StateInterTrialInterval::s_finish()
{
//  Serial.println("ending ITI, move to WAIT_FOR_TRIAL");
  next_state = WAIT_FOR_TRIAL;   
}

