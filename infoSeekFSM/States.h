#ifndef __STATES_H_INCLUDED__
#define __STATES_H_INCLUDED__


#include <TimedState.h>

#include "Printer.h"
#include "Odor.h"
#include "TrialParams.h"

enum STATE_TYPE{
  WAIT_FOR_TRIAL,
  START_TRIAL,
  START_TRIAL_DELAY,
  WAIT_FOR_CENTER,
  CENTER_DELAY,
  CENTER_ODOR,
  CENTER_POSTODOR_DELAY,
  GO_CUE,
  GO_CUE_DELAY,
  RESPONSE,
  GRACE_PERIOD,
  WAIT_FOR_ODOR,
  SIDE_ODOR,
  REWARD_DELAY,
  REWARD,
  INTER_TRIAL_INTERVAL,
  TIMEOUT,
};

extern STATE_TYPE next_state;
extern int centerFlag;
extern int infoFlag;
extern int randFlag;
extern int choice;
extern int odor;
extern int water;
extern int cTCount;
extern int infoFCt;
extern int infoCCt;
extern int randFCt;
extern int randCCt;
extern int rewardAmt;
extern bool centerOdorValveOpen;
extern bool odorValveOpen;
extern bool waterValveOpen;
extern int rewardCount;
extern int rewardBigCount;
extern int rewardSmallCount;
extern int newTrial;
extern unsigned long trialStart;
extern unsigned long rxn;
extern unsigned long choiceStart;
extern unsigned long odorDelay;
extern unsigned long interval;
extern unsigned long currentTime;
extern unsigned long gracePeriod;
extern int buzzer;


class StateWaitForTrial : public TimedState {
  protected:
    void s_setup();
    void s_finish();
  
  public:
    StateWaitForTrial(unsigned long d) : TimedState(d) { };
};

class StateInterTrialInterval : public TimedState {
  protected:
    void s_setup();
    void s_finish();
  
  public:
    StateInterTrialInterval(unsigned long d) : TimedState(d) { };
};

class StateStartTrialDelay : public TimedState {
  protected:
    void s_setup();
    void s_finish();
  
  public:
    StateStartTrialDelay(unsigned long d) : TimedState(d) { };
};

//class StateWaitForCenter : public TimedState{
//  protected:
//    void s_setup();
//    void loop();
//    void s_finish();
//
//  public:
//    StateWaitForCenter(unsigned long d) : TimedState(d) { };
//};

class StateCenterDelay : public TimedState {
  protected:
    void s_setup();
    void s_finish();
    void loop();
  
  public:
    StateCenterDelay(unsigned long d) : TimedState(d) { };
};

class StateCenterOdor : public TimedState {
  protected:
    void s_setup();
    void s_finish();
    void loop();
  
  public:
    StateCenterOdor(unsigned long d) : TimedState(d) { };
};

class StateCenterPostOdorDelay : public TimedState {
  protected:
    void s_setup();
    void s_finish();
    void loop();
  
  public:
    StateCenterPostOdorDelay(unsigned long d) : TimedState(d) { };
};

class StateGoCueDelay : public TimedState {
  protected:
    void s_setup();
    void s_finish();
  
  public:
    StateGoCueDelay(unsigned long d) : TimedState(d) { };
};

class StateResponse : public TimedState{
  protected:
    void loop();
    void s_setup();
    void s_finish();

  public:
    StateResponse(unsigned long d) : TimedState(d) { };
};

class StateWaitForOdor : public TimedState{
  protected:
    void s_setup();
    void s_finish();

  public:
    StateWaitForOdor(unsigned long d) : TimedState(d){ };
};

class StateGracePeriod : public TimedState {
  protected:
    void s_setup();
    void s_finish();
    void loop();
  
  public:
    StateGracePeriod(unsigned long d) : TimedState(d) { };
};

class StateSideOdor : public TimedState {
  protected:
    void s_setup();
    void s_finish();
  
  public:
    StateSideOdor(unsigned long d) : TimedState(d) { };
};

class StateRewardDelay : public TimedState {
  protected:
    void s_setup();
    void s_finish();
  
  public:
    StateRewardDelay(unsigned long d) : TimedState(d) { };
};

class StateReward : public TimedState {
  protected:
    void s_setup();
    void s_finish();
    void loop();
  
  public:
    StateReward(unsigned long d) : TimedState(d) { };
};

class StateTimeout : public TimedState {
  protected:
    void s_setup();
    void s_finish();
  
  public:
    StateTimeout(unsigned long d) : TimedState(d) { };
};

#endif
