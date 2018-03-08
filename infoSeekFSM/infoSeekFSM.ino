/*
 * 
 * --mouse can't lick both at once?


PROBLEM WITH MARKING REWARD WHEN NOT IN PORT?--no?

NO CHOICE INDICATED WHEN CHOOSES IN GRACE PERIOD?!?!?

IMPROVEMENTS

--make com port and "box" based of a box variable!!
--chatter communications --> STOP BUTTON
--save mouse / session parameters
--parse trials and report: type, odors, time to start, center dwell, center entries, rxn, choice/timeout/correct, licks, dwell, reward 
--GUI to plot choices, correct, and control params
--python-based trial setting (scheduler and setter)
--move main loop out of waiting for python
--move physical pins into library / params file
--move imaging into library


STATES:
 0 WAIT_FOR_TRIAL,
 1 START_TRIAL,
 2 START_TRIAL_DELAY,
 3 WAIT_FOR_CENTER,
 4 CENTER_DELAY,
 5 CENTER_ODOR,
 6 CENTER_POSTODOR_DELAY,
 7 GO_CUE,
 8 GO_CUE_DELAY,
 9 RESPONSE,
 10 GRACE_PERIOD,
 11 WAIT_FOR_ODOR,
 12 SIDE_ODOR,
 13 REWARD_DELAY,
 14 DELIVER_REWARD,
 15 INTER_TRIAL_INTERVAL,
 16 TIMEOUT,
 17 REWARD_PAUSE
 18 REWARD_COMPLETE
 */



#include <Arduino.h>
#include <Wire.h>
#include <MPR121.h>
#include "States.h"
#include "Odor.h"
#include "Printer.h"
#include "TrialParams.h"


/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////

// GLOBAL VARIABLE DEFINITIONS

////////////////////////////////////////////////////////////////////////////////////////

// ARDUINO PINS
// MOVE THESE INTO CONFIG.H/PARAMETERS/JSON FILE with format extern int ...

int sensors[] = {0,1,2,3,4}; // Pins of IR beam sensors in the ports ANALOG
int portSensors[] = {sensors[1], sensors[3]}; // IR beam at the entrance of the port; 0 = inside chamber left
int centerPort = sensors[4]; // IR beam at entrance to center port
int valves1[] = {22, 24, 26, 28}; // Valves BEFORE odor bottles, odors 1-4 (valves 0-3)  
int valves2[] = {27, 29, 31, 33}; // Valves AFTER odor bottles, odors 1-4 (valves 0-3)  
int valves3a[] = {42,46,50,43}; // Latch valves 1-4 direction 1
int valves3b[] = {44,48,52,45}; // Latch valves 1-4 direction 2
int valves4[] = {30,38,36,34}; // Valves BEFORE odor bottles, odors 5-8 (TO CENTER PORT)
int valves5[] = {23,25,37,35}; // Valves AFTER odor bottles, odors 5-8 (TO CENTER PORT)
int controls[] = {8,9,10,11,12,13}; // before1, after1, before2, after2, before3, after3
int waterValves[] = {40, 41}; // Valves controlling water delivery; 0 = inside chamber left
int buzzer = 5;
int button = 2; // DIGITAL
int arduScope = 7;
int scopeArdu = 6;
int TOUCH_IRQ = 3;

/////////  OTHERS  ///////////////////////////////////////

unsigned long startTime; // Start time of session
unsigned long currentTime; // Frequently updated
int runSession;
unsigned long rewardPauseTime;
unsigned long rewardDropTime;

 // STATES
STATE_TYPE next_state;
//STATE_TYPE current_state;

///// PARAMS FOR TRIAL
int block[20];
int lastBlock[20];
int trialNum;
int newTrial;
int trialCt;
int trialType;
unsigned long currentRewardTime;
int rewardDrops;
int maxRewardDrops;
int rewardDropCount;
int odor;
int reward;
int water;
int currentCenterOdor;

//// SESSION DATA
int rewardCount;
int rewardBigCount;
int rewardSmallCount;

int infoFCt;
int infoCCt;
int randFCt;
int randCCt;
int rewardAmt;
int cTCount;

//// WITHIN-TRIAL DATA
int centerFlag;
int randFlag;
int infoFlag;
int choice;
unsigned long rxn; // Time of choice
unsigned long choiceStart; // Time of goCue
unsigned long trialStart; // Time of trial start
uint16_t sticky_touched = 0;
uint16_t lickCt;
uint16_t lastLickCt;
uint16_t lickRate;


//// PORTS AND ODORS AND WATER
int infoPort; // informative port entry sensor
int randPort; // random port entry sensor
int randSide;
int infoWater;
int randWater;
int controlList[] = {1,2};
int infoControl;
int randControl;
int centerControl = 3;
int infoOdors[2];
int randOdors[2];
int centerOdor;

//// VALVE FLAGS
bool waterValveOpen;
bool odorValveOpen;
bool centerOdorValveOpen;

//// IMAGING-move into library?
unsigned long scopeTTLpulse;
unsigned long lastTTL;
unsigned long TTLcount;
int image;
unsigned long lastImageChange;

//// FROM PYTHON--> these should also go into parameters file

int sessionEnd; // trigger to end session: 1 = manual, 2 = # of trials, 3 = time
int sessionTrials; // # of trials after which to end session
int imageFlag; // 1 = image, 0 = no imaging
int trialTypes; // 1 if all choice, 2 all info, 3 all random, 4 all forced, 5 mixed, 6 biased
int infoSide; // 0 = left, 1 = right

int infoOdor; // odor labels the informative port (can be either left or right)
int randOdor; // odor labels the uninformative port (can be either left or right)
int choiceOdor; // odor indicating both reward ports are availableand the animal must choose left or right
int odorA; // odor predicting reward
int odorB; // odor predicting no reward
int odorC; // uninformative odor
int odorD; // uninformative odor

unsigned long centerDelay; // time before center odor
unsigned long centerOdorTime; // length of center odor
unsigned long startDelay; // time after center odor before trial can start
unsigned long odorDelay; // time between go cue and odor delivery (ms)
unsigned long odorTime; // length of odor delivery (ms) in reward port
unsigned long rewardDelay; // time mouse must remain in port before reward delivery (ms) ///////////////// MUST BE MORE
unsigned long infoBigRewardTime;
unsigned long infoSmallRewardTime;
unsigned long randBigRewardTime;
unsigned long randSmallRewardTime;
int infoRewardProb;
int randRewardProb;
unsigned long gracePeriod; // additional time to enter reward port
unsigned long interval; // ITI

int TOU_THRESH; // lick sensor touch threshold
int REL_THRESH; // lick sensor release threshold
unsigned int touch_right; // lick sensor pin for right sensor
unsigned int touch_left; // lick sensor pin for left sensor


///////////////////////////////////////////////////////////////////////////////////////

// MAIN FUNCTIONS: SETUP AND LOOP

///////////////////////////////////////////////////////////////////////////////////////


void setup() {
  // Start serial communication
  Serial.begin(115200);

  // Set up pins
  for (int x = 0; x < 5; x++) {
    pinMode (sensors[x], INPUT);
  }
  
  for (int x = 0; x < 6; x++) {
    pinMode (controls[x], OUTPUT);
  }

  for (int y = 0; y < 4; y++) {
      pinMode (valves1[y], OUTPUT);
      pinMode (valves2[y], OUTPUT);
      pinMode (valves3a[y], OUTPUT);
      pinMode (valves3b[y], OUTPUT);
      pinMode (valves4[y], OUTPUT);
      pinMode (valves5[y], OUTPUT);
      digitalWrite(valves3a[y], LOW);
      digitalWrite(valves3b[y], LOW);
  }   

  for (int z = 0; z < 2; z++) {
    pinMode (waterValves[z], OUTPUT);
  }

  pinMode (button, INPUT);
  pinMode (buzzer, OUTPUT);

  // Imaging miniscope
  pinMode (arduScope, OUTPUT);
  pinMode (scopeArdu, INPUT);

  digitalWrite (arduScope, HIGH);
  digitalWrite (scopeArdu, LOW);

  
  // random number seed  
  randomSeed(analogRead(15));

  pinMode(TOUCH_IRQ, INPUT);
  digitalWrite(TOUCH_IRQ, HIGH); //enable pullup resistor
  Wire.begin();

  controlOn(1); // ensures control valves open for mineral oil air flow
  controlOn(2);
  controlOn(3);

}

void loop() {



  // Wait for signal to start session from Python
  
  // In the future, change this to chatter/trial setter/reset arduino when running session
  
  // Python handles file to save data
  if (Serial.available()) { // Ask if there's serial data available, i.e. Python has sent the digit 1 to start the trial
    char sessionStart = Serial.read(); // Get whatever is available on the serial port
    if (sessionStart == 49) { // 49 is the ASCII code for the digit 1

      //////////////////  GET PYTHON DATA  /////////////////////////////////////
      //read the parameter values sent from the python GUI
      sessionEnd        =        Serial.parseInt();
      sessionTrials     =        Serial.parseInt();
      imageFlag         =        Serial.parseInt();
      trialTypes        =        Serial.parseInt();
      infoSide          =        Serial.parseInt();
      infoOdor          =        Serial.parseInt();
      randOdor          =        Serial.parseInt();
      choiceOdor        =        Serial.parseInt();
      odorA             =        Serial.parseInt();
      odorB             =        Serial.parseInt();
      odorC             =        Serial.parseInt();
      odorD             =        Serial.parseInt();
      centerDelay       =        Serial.parseInt();
      centerOdorTime    =        Serial.parseInt();
      startDelay        =        Serial.parseInt();
      odorDelay         =        Serial.parseInt();
      odorTime          =        Serial.parseInt();
      rewardDelay       =        Serial.parseInt();
      infoBigRewardTime     =        Serial.parseInt();
      infoSmallRewardTime   =        Serial.parseInt();
      randBigRewardTime     =        Serial.parseInt();
      randSmallRewardTime   =        Serial.parseInt();
      infoRewardProb    =        Serial.parseInt();
      randRewardProb    =        Serial.parseInt();
      gracePeriod       =        Serial.parseInt();
      interval          =        Serial.parseInt();
      TOU_THRESH        =        Serial.parseInt();
      REL_THRESH        =        Serial.parseInt();
      touch_right       =        Serial.parseInt();
      touch_left        =        Serial.parseInt();
      optoFlag          =        Serial.parseInt();

      unsigned long entryThreshold = 20;
      int lickCheck = 1;

      rewardDropTime = 20;
      rewardPauseTime = 200;
      rewardAmt = 0;
      maxRewardDrops = max(infoBigRewardTime,randBigRewardTime);
      
      startTime = 0;
      currentTime = 0;
      trialStart = 0;
      choiceStart = 0;
      rxn = 0;
      trialCt = 0;
      trialType = 0;
      trialNum = 19;
      newTrial = 1;
      currentRewardTime = 0;
      odor = 7;
      rewardCount = 0;
      rewardBigCount = 0;
      rewardSmallCount = 0;
      lickCt = 0;
      lastLickCt = 0;
      lickRate = 0;

      centerFlag = 0;
      randFlag = 0;
      infoFlag = 0;
      choice = 2;

      scopeTTLpulse = 0;
      lastTTL = 0;
      TTLcount = 0;

      infoOdors[0] = odorA;
      infoOdors[1] = odorB;
      randOdors[0] = odorC;
      randOdors[1] = odorD;

      mpr121_setup(TOUCH_IRQ, TOU_THRESH, REL_THRESH);

      setSide();
      
      runSession = 1; // Start a session of trials

      startTime = millis(); // start the timer for this session

      printer(0, 0, 0);

      if (imageFlag == 1){
          digitalWrite(arduScope, LOW); //start imaging
          image = 1;
          lastImageChange = startTime;
      }


//      Serial.println("session start");

      
      ///////////////////////////  RUN THE SESSION  ///////////////////////////////////////////////////////////
      while (runSession == 1) {     // loop to stay in session

       /* Called over and over again. On each call, the behavior is determined
           by the current state.
        */
              
        currentTime = millis() - startTime; // get the current time in this session


        // STATE DEFINITIONS
        static STATE_TYPE current_state = WAIT_FOR_TRIAL;
        static StateWaitForTrial state_wait_for_trial(0);
        static StateInterTrialInterval state_inter_trial_interval(interval + random(1,1000)); // update each trial
        static StateStartTrialDelay state_start_trial_delay(200);
        static StateCenterDelay state_center_delay(centerDelay);
        static StateCenterOdor state_center_odor(centerOdorTime);
        static StateCenterPostOdorDelay state_center_postodor_delay(startDelay);
        static StateGoCueDelay state_go_cue_delay(50);
        static StateResponse state_response(odorDelay);
        static StateWaitForOdor state_wait_for_odor(odorDelay); // update when used!
        static StateGracePeriod state_grace_period(gracePeriod);
        static StateSideOdor state_side_odor(odorTime);
        static StateRewardDelay state_reward_delay(rewardDelay);
        static StateTimeout state_timeout(odorTime + rewardDelay + maxRewardDrops * rewardDropTime + (maxRewardDrops - 1) * rewardPauseTime);
        static StateRewardPause state_reward_pause(rewardPauseTime);


        uint16_t touched = 0;
        int licked = 0;
        
        ///////////////////////// CHECK IF TIME TO END //////////////////////////////////
        if (digitalRead(button) == LOW){ // 50 is the ASCII code for the digit 2
          Serial.println(" ");
          Serial.println("Session stop.");
          endingSession(currentTime);
          break;
        }
        
        // The next state, by default the same as the current state
        next_state = current_state;
        
        ///// ADD CHAT-BASED COMMUNICATIONS HERE

        //// LICKING
        touched = pollTouchInputs();
        if (touched != sticky_touched)
          {
//            Serial.print(" TCH ");
//            Serial.println(touched);
            sticky_touched = touched;

            if (get_touched_channel(touched,touch_right) == 1){
              licked = 1; //right
            }
            else if (get_touched_channel(touched,touch_left) == 1){
              licked = 2; //left
            }
            else licked = 0;
            if (licked > 0){
              Serial.print("licked ");
              Serial.println(licked);
              lickCt++;
              printer(4, licked, 0);
              licked = 0;
            }
          }

        //// GET LICK RATE (FOR DETERMINING REWARD)
        if (currentTime % 1000 == 0 & lickCheck == 1){
          lickRate = lickCt - lastLickCt;
//          Serial.print("lickRate = ");
//          Serial.println(lickRate);
          lastLickCt = lickCt;
          lickCheck = 0;
        }

          if (currentTime % 1000 != 0 & lickCheck == 0){
              lickCheck = 1;
            }



        //// CHECK FOR IMAGING /////////////////////
        // CHANGE HERE TO CHANGE TIME!!
        if (currentTime >= lastImageChange + 300000 & imageFlag == 1){
          if (image == 1){
            image = 0;
            digitalWrite(arduScope, HIGH);            
          }
          else {
            image = 1;
            digitalWrite(arduScope, LOW);
          }
          lastImageChange = currentTime;
        }


        
        if (image == 1){
          readTTL();
        }

        //// WATCH PORTS
        //// MOVE TO FUNCTIONS/LIBRARY
        if (beamBreak(centerPort) == 1){ // is being broken
//        if (digitalRead(53) == LOW){ // TOUCHING
          if (centerFlag == 0){ // if not currently broken
            Serial.println("Enter center");
            centerFlag = 1;
            if (current_state == WAIT_FOR_CENTER){
              printer(2,centerPort,1);
            }
            else {
              printer(2, centerPort, 0);
            }
          }   
        }
        else if (centerFlag == 1){
          Serial.println("exit center");
          centerFlag = 0;
          printer(6, centerPort, 0);
        }


        if (beamBreak(infoPort) == 1){ // is being broken
//        if (digitalRead(47) == LOW){
            if (infoFlag == 0){ // if not currently broken
            Serial.println("Enter info");
            infoFlag = 1;
            if (current_state == RESPONSE){
              printer(2,infoPort,1);
            }
            else {
              printer(2, infoPort, 0);
            }
          }   
        }
        else if (infoFlag == 1){
          Serial.println("exit info");
          infoFlag = 0;
          printer(6, infoPort, 0);
        }


        if (beamBreak(randPort) == 1){ // is being broken
//        if (digitalRead(49) == LOW){
            if (randFlag == 0){ // if not currently broken
            Serial.println("Enter random");
            randFlag = 1;
            if (current_state == RESPONSE){
              printer(2, randPort, 1);
            }
            else {
              printer(2, randPort, 0);            
            }
          }   
        }
        else if (randFlag == 1){
          Serial.println("exit random");
          randFlag = 0;
          printer(6, randPort, 0);
        }

        currentTime = millis()-startTime;
        
        // THE STATE MACHINE
        
        switch (current_state){

          case WAIT_FOR_TRIAL:
            state_wait_for_trial.run(currentTime);
            break;
          
          case START_TRIAL:

            // Need to move all of this and trial type, parameter picking to Python

            Serial.println();
            Serial.println("START_TRIAL");
            tone(buzzer,4000,200);
            if (newTrial == 1) {
              if (trialNum == 19){
                newBlock();
                trialNum = 0;  
              }
              else{
                trialNum++;
              }
              trialType = block[trialNum];
              setCenterOdor();      
              newTrial = 0;      
            }
            printer(10, trialType, infoSide);
            trialStart = currentTime;
            Serial.print("Trial num = ");
            Serial.println(trialCt);
            Serial.print("Trial type = ");
            Serial.println(trialType);

//            Serial.println("end start trial, move to START_TRIAL_DELAY");
            
            next_state = START_TRIAL_DELAY;        
            break;

          case START_TRIAL_DELAY:
            state_start_trial_delay.run(currentTime);
            break;

          case WAIT_FOR_CENTER:
            if (centerFlag == 1){
              Serial.println("CENTER START");
              next_state = CENTER_DELAY;
            }
            break;

          case CENTER_DELAY:
            state_center_delay.run(currentTime);
            break;

          case CENTER_ODOR:
            state_center_odor.run(currentTime);
            break;

          case CENTER_POSTODOR_DELAY:
            state_center_postodor_delay.run(currentTime);
            break;

          case GO_CUE:
            tone(buzzer,9000,50);
            Serial.println("GO_CUE");
            next_state = GO_CUE_DELAY;
            break;

          case GO_CUE_DELAY:
            state_go_cue_delay.run(currentTime);
            break;

          case RESPONSE:
            state_response.run(currentTime);
            break;

          case WAIT_FOR_ODOR:
            state_wait_for_odor.run(currentTime);
            break;

          case GRACE_PERIOD:
            state_grace_period.run(currentTime);
            break;

          case SIDE_ODOR:
            state_side_odor.run(currentTime);
            break;

          case REWARD_DELAY:
            state_reward_delay.run(currentTime);
            break;

          case DELIVER_REWARD:
            if (rewardDrops > 0){
//            if (rewardDrops > 0 & reward == 1 & lickRate >0){
              Serial.println("DELIVER REWARD DROP");
              Serial.println("water on");
              digitalWrite(water, HIGH);
              printer(7, choice, 0);
              waterValveOpen = true;
              rewardAmt = rewardAmt + 4;
            }

            delay(rewardDropTime);

            Serial.println("reward time delay");
            
            if (waterValveOpen) {
              Serial.println("water off");
              digitalWrite(water, LOW);
              waterValveOpen = false;
              printer(8, choice, 0);
              rewardDrops = rewardDrops - 1;
              Serial.print("rewardDrops = ");
              Serial.println(rewardDrops);   
            }

            rewardDropCount = rewardDropCount - 1;

            if (rewardDropCount > 0){
              next_state = REWARD_PAUSE;
            }
            else{
              next_state = REWARD_COMPLETE;
            }
            break;

          case INTER_TRIAL_INTERVAL:
            state_inter_trial_interval.run(currentTime);
            break;

          case TIMEOUT:
            state_timeout.run(currentTime);
            break;

          case REWARD_PAUSE:
            state_reward_pause.run(currentTime);
            break;

          case REWARD_COMPLETE:
              Serial.println("TRIAL COMPLETE");
              printer(18,trialType,choice);
              if (trialType == 1 && choice == 0){
                randCCt++;
              }
              else if (trialType == 1 && choice == 1){
                infoCCt++;
              }
              else if (trialType == 2 && choice == 1){
                infoFCt++;
              }
              else if (trialType == 3 && choice == 0){
                randFCt++;
              }
              cTCount = randCCt + infoCCt + infoFCt + randFCt;
              rewardDrops = 0;
              //  Serial.println("end reward, move to ITI");
              next_state = INTER_TRIAL_INTERVAL;
              break;
        }
      
        //// Update the state variable
        if (next_state != current_state)
        {
            
          Serial.print(currentTime);
          Serial.print(",");
          Serial.print(trialCt);
          Serial.print(",");
          Serial.print(21);
          Serial.print(",");
          Serial.print(current_state);
          Serial.print(",");
          Serial.println(next_state);
          
          Serial.print(millis()-startTime);
          Serial.print(",");
          Serial.print(trialCt);
          Serial.print(",");
          Serial.print(22);
          Serial.print(",");
          Serial.print(current_state);
          Serial.print(", ");
          Serial.println(next_state);
        }
        current_state = next_state;
        
//        return;
      }
    }
  }
}

///////////////  END LOOP  /////////////////////////////


////////////////////  READ TTL  ///////////////////////
void readTTL(){
  scopeTTLpulse = digitalRead(scopeArdu);

  if (scopeTTLpulse == 1 && lastTTL == 0){
    TTLcount = TTLcount + scopeTTLpulse;
    scopeTTLpulse = TTLcount;
    printer1P(20,TTLcount,0);
    lastTTL = 1;
    scopeTTLpulse = 0;
  }
  else{
    lastTTL = scopeTTLpulse;
    scopeTTLpulse = 0;
  }
}


/////////////////  BEAM BREAKS  /////////////////////////
int beamBreak(int sensorPin) {
  if (analogRead(sensorPin) < 250) {
    return 1;
  }

  else {
    return 0;
  }
}


//////////////  END SESSION  ////////////////////////////
void endingSession (unsigned long stopTime) {
  printer(9, 0, 0);
  Serial.println("Ending session");
  Serial.print("End time = ");
  Serial.println(stopTime);
  runSession = 0;
  digitalWrite(arduScope, HIGH);
  if (centerOdorValveOpen == 1){
    centerOdorOff(currentCenterOdor);
  }
  if (odorValveOpen == 1){
    odorOff(odor);
    // FIX
    if (choice == 1){
      controlOn(infoControl);
      digitalWrite(valves4[infoSide], LOW);
    }
    else if (choice == 0){
      controlOn(randControl);
      digitalWrite(valves4[randSide], LOW);
    }
  }         
  if (waterValveOpen) {
    digitalWrite(water, LOW);
  }
  Serial.println("1003211238");
}
