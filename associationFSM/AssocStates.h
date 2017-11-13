#ifndef __ASSOC_STATES_H_INCLUDED__
#define __ASSOC_STATES_H_INCLUDED__


#include <TimedState.h>

#include "Printer.h"
#include "OdorAssoc.h"
#include "TrialParamsAssoc.h"

enum STATE_TYPE{
  WAIT_FOR_TRIAL,
  START_TRIAL,
  START_TRIAL_DELAY,
  WAIT_FOR_ENTRY,
  BASELINE,
  ODOR,
  OUTCOME_DELAY,
  DELIVER_REWARD,
  REWARD_PAUSE,
  REWARD_COMPLETE,
  IMAGING_DELAY,
  TIMEOUT,
  INTER_TRIAL_INTERVAL
};

extern STATE_TYPE next_state;
extern int centerFlag;
extern int infoFlag;
extern int randFlag;
extern int portFlag;
extern int choice;
extern int odor;
extern int water;
extern int TCount;
extern int plus1Ct;
extern int plus2Ct;
extern int minus1Ct;
extern int minus2Ct;
extern int USCt;
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
extern unsigned long delayTime;
extern unsigned long interval;
extern unsigned long currentTime;
extern int buzzer;
extern unsigned long bigRewardTime;
extern unsigned long smallRewardTime;
extern unsigned long rewardDelay;
extern int rewardDrops;
extern unsigned long currentRewardTime;
extern uint16_t lickRate;
extern int arduScope;
extern int image;
extern int imageFlag;


class StateWaitForTrial : public TimedState {
  protected:
    void s_setup();
    void s_finish();
  
  public:
    StateWaitForTrial(unsigned long d) : TimedState(d) { };
};


class StateStartTrialDelay : public TimedState {
  protected:
    void s_setup();
    void s_finish();
  
  public:
    StateStartTrialDelay(unsigned long d) : TimedState(d) { };
};


class StateBaseline : public TimedState {
  protected:
    void s_setup();
    void s_finish();
    void loop();
  
  public:
    StateBaseline(unsigned long d) : TimedState(d) { };
};

class StateOdor : public TimedState {
  protected:
    void s_setup();
    void s_finish();
    void loop();
  
  public:
    StateOdor(unsigned long d) : TimedState(d) { };
};


class StateOutcomeDelay : public TimedState {
  protected:
    void s_setup();
    void loop();
    void s_finish();
    unsigned long buzzInterval;
    unsigned long lastBuzzerOn;
    unsigned long lastBuzzerOff;
    int buzzCt;
    int lastBuzzCt;
    int change;
  
  public:
    StateOutcomeDelay(unsigned long d) : TimedState(d) { };
};


class StateRewardPause : public TimedState{
  protected:
    void s_setup();
    void s_finish();

  public:
    StateRewardPause(unsigned long d) : TimedState(d) { };
};


class StateImagingDelay : public TimedState{
  protected:
    void s_setup();
    void s_finish();

  public:
    StateImagingDelay(unsigned long d) : TimedState(d) { };
};


class StateInterTrialInterval : public TimedState {
  protected:
    void s_setup();
    void s_finish();
  
  public:
    StateInterTrialInterval(unsigned long d) : TimedState(d) { };
};


class StateTimeout : public TimedState {
  protected:
    void s_setup();
    void s_finish();
  
  public:
    StateTimeout(unsigned long d) : TimedState(d) { };
};

#endif
