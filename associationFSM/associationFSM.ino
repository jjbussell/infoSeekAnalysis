/*
STATES:
 0 WAIT_FOR_TRIAL,
 1 START_TRIAL,
 2 START_TRIAL_DELAY,
 3 WAIT_FOR_ENTRY,
 4 BASELINE,
 5 ODOR,
 6 OUTCOME_DELAY,
 7 OUTCOME,
 8 REWARD_PAUSE
 9 REWARD_COMPLETE
 10 IMAGING_DELAY,
 11 TIMEOUT,
 12 INTER_TRIAL_INTERVAL
 */



#include <Arduino.h>
#include <Wire.h>
#include <MPR121.h>
#include "AssocStates.h"
#include "OdorAssoc.h"
#include "Printer.h"
#include "TrialParamsAssoc.h"


/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////

// GLOBAL VARIABLE DEFINITIONS

////////////////////////////////////////////////////////////////////////////////////////

// ARDUINO PINS
// MOVE THESE INTO CONFIG.H/PARAMETERS/JSON FILE with format extern int ...

int sensors[] = {0,1,2,3,4}; // Pins of IR beam sensors in the ports ANALOG
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
int block[5];
int lastBlock[5];
int trialNum;
int newTrial;
int trialCt;
int trialType;
int rewardDrops;
int currentOdor;
int reward;
int water;

//// SESSION DATA
int plus1Ct;
int plus2Ct;
int minus1Ct;
int minus2Ct;
int USCt;
int rewardAmt;
int TCount;

//// WITHIN-TRIAL DATA
int portFlag;
unsigned long trialStartTime; // Time of trial start
unsigned long entryTime; // Time of port entry
uint16_t sticky_touched = 0;
uint16_t lickCt;
uint16_t lastLickCt;
uint16_t lickRate;


//// ODORS
int odors[4];
int odorControl;                      


//// VALVE FLAGS
bool waterValveOpen;
bool odorValveOpen;

//// IMAGING-move into library?
unsigned long scopeTTLpulse;
unsigned long lastTTL;
unsigned long TTLcount;
int image;

//// FROM PYTHON--> these should also go into parameters file

int sessionEnd; // trigger to end session: 1 = manual, 2 = # of trials, 3 = time
int sessionTrials; // # of trials after which to end session
int imageFlag; // 1 = image, 0 = no imaging
int trialTypes; // 1 if all 5 with CS's, 2 if all US
unsigned long imagingTime; // time to keep imaging after reward
int port; // location of training. 1 = left, 3 = right.

int plus1; // CS+
int plus2; // CS+
int minus1; // CS-
int minus2; // CS-

unsigned long baseline; // time before center odor
unsigned long odorTime; // length of odor delivery (ms) in reward port
unsigned long delayTime; // time mouse must remain in port before reward delivery (ms) ///////////////// MUST BE MORE
int drops;
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
      imagingTime       =        Serial.parseInt();
      port              =        Serial.parseInt(); // 1 = left, 3 = right
      plus1             =        Serial.parseInt();
      plus2             =        Serial.parseInt();
      minus1            =        Serial.parseInt();
      minus2            =        Serial.parseInt();
      baseline          =        Serial.parseInt();
      odorTime          =        Serial.parseInt();
      delayTime         =        Serial.parseInt();
      drops             =        Serial.parseInt();
      interval          =        Serial.parseInt();
      TOU_THRESH        =        Serial.parseInt();
      REL_THRESH        =        Serial.parseInt();
      touch_right       =        Serial.parseInt();
      touch_left        =        Serial.parseInt();

      unsigned long entryThreshold = 20;
      int lickCheck = 1;

      rewardDropTime = 20;
      rewardPauseTime = 200;
      rewardAmt = 0;
      
      startTime = 0;
      currentTime = 0;
      trialStartTime = 0;
      entryTime = 0;
      trialCt = 0;
      trialType = 0;
      trialNum = 4;
      newTrial = 1;
      currentOdor = 7;
      reward = 0;
      lickCt = 0;
      lastLickCt = 0;
      lickRate = 0;

      portFlag = 0;

      odors[0] = plus1;
      odors[1] = plus2;
      odors[2] = minus1;
      odors[3] = minus2;

      if (imagingTime <= interval){
        imagingTime = interval;
      }


      scopeTTLpulse = 0;
      lastTTL = 0;
      TTLcount = 0;

      mpr121_setup(TOUCH_IRQ, TOU_THRESH, REL_THRESH);

      setSide(port);
      
      runSession = 1; // Start a session of trials

      startTime = millis(); // start the timer for this session

      printer(0, 0, 0);


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
        static StateStartTrialDelay state_start_trial_delay(200);
        static StateBaseline state_baseline(baseline);
        static StateOdor state_odor(odorTime);
        static StateOutcomeDelay state_outcome_delay(delayTime);
        static StateRewardPause state_reward_pause(rewardPauseTime);
        static StateTimeout state_timeout(baseline + odorTime + delayTime + drops*rewardDropTime + (drops-1)*rewardPauseTime);
        static StateImagingDelay state_imaging_delay(imagingTime);
        static StateInterTrialInterval state_inter_trial_interval(interval); // update each trial



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
        if (image == 1){
          readTTL();
//          Serial.println("image frame");
        }

        //// WATCH PORTS
        //// MOVE TO FUNCTIONS/LIBRARY
        if (beamBreak(port) == 1){ // is being broken
//        if (digitalRead(53) == LOW){ // TOUCHING
          if (portFlag == 0){ // if not currently broken
            Serial.println("Enter port");
            portFlag = 1;
            if (current_state == WAIT_FOR_ENTRY){
              printer(2,port,1);
            }
            else {
              printer(2, port, 0);
            }
          }
        }   
        
        else if (portFlag == 1){
          Serial.println("exit port");
          portFlag = 0;
          printer(6, port, 0);
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
//            if (newTrial == 1) {
              if (trialNum == 4){
                newBlock();
                trialNum = 0;  
              }
              else{
                trialNum++;
              }
              trialType = block[trialNum];
              pickTrialParams(trialType);      
//              newTrial = 0;      
//            }
            printer(10, trialType, currentOdor);
            trialStartTime = currentTime;
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

          case WAIT_FOR_ENTRY:
            if (portFlag == 1){
              entryTime = currentTime;
              Serial.println("ENTRY");
              next_state = BASELINE;
            }
            break;

          case BASELINE:
            state_baseline.run(currentTime);
            break;

          case ODOR:
            state_odor.run(currentTime);
            break;

          case OUTCOME_DELAY:
            state_outcome_delay.run(currentTime);
            break;

          case DELIVER_REWARD:
            if (rewardDrops > 0){
//            if (rewardDrops > 0 & reward == 1 & lickRate >0){
              Serial.println("DELIVER REWARD DROP");
              Serial.println("water on");
              digitalWrite(water, HIGH);
              printer(7, trialType, reward);
              waterValveOpen = true;
              rewardAmt = rewardAmt + 4;
            }

            delay(rewardDropTime);

            if (waterValveOpen) {
              Serial.println("water off");
              digitalWrite(water, LOW);
              waterValveOpen = false;
              printer(8, trialType, reward);
              rewardDrops = rewardDrops - 1;
              Serial.print("rewardDrops = ");
              Serial.println(rewardDrops);   
            }

            if (rewardDrops > 0){
              next_state = REWARD_PAUSE;
            }
            else{
              next_state = REWARD_COMPLETE;
            }
            break;

          case REWARD_PAUSE:
            state_reward_pause.run(currentTime);
            break;

          case REWARD_COMPLETE:
            Serial.println("TRIAL COMPLETE");
            printer(18,trialType,reward);
            if (trialType == 1){
              plus1Ct++;
            }
            else if (trialType == 2){
              plus2Ct++;
            }
            else if (trialType == 3){
              minus1Ct++;
            }
            else if (trialType == 4){
              minus2Ct++;
            }
            else if (trialType == 5){
              USCt++;
            }              
            TCount = plus1Ct + plus2Ct + minus1Ct + minus2Ct + USCt;
            rewardDrops = 0;
            //  Serial.println("end reward, move to ITI");
            next_state = IMAGING_DELAY;
            break;

          case IMAGING_DELAY:
            state_imaging_delay.run(currentTime);
            break;

          case TIMEOUT:
            state_timeout.run(currentTime);
            break;               

          case INTER_TRIAL_INTERVAL:
            state_inter_trial_interval.run(currentTime);
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
          
//          Serial.print(millis()-startTime);
//          Serial.print(",");
//          Serial.print(trialCt);
//          Serial.print(",");
//          Serial.print(22);
//          Serial.print(",");
//          Serial.print(current_state);
//          Serial.print(", ");
//          Serial.println(next_state);
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
  if (analogRead(sensorPin) < 400) {
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
  if (odorValveOpen == 1){
    odorOff(currentOdor);
    controlOn(1); // ensures control valves open for mineral oil air flow
    controlOn(2);
    controlOn(3);
  }         
  if (waterValveOpen) {
    digitalWrite(water, LOW);
  }
  Serial.println("12345");
}
