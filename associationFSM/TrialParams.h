#ifndef __TRIALPARAMS_H_INCLUDED__
#define __TRIALPARAMS_H_INCLUDED__

extern int infoRewardProb;
extern int randRewardProb;
extern int odor;
extern unsigned long currentRewardTime;
extern int block[];
extern int trialType;
extern int trialTypes;
extern int infoPort;
extern int randPort;
extern int reward;
extern unsigned long  bigRewardTime;
extern unsigned long smallRewardTime;
extern int odorA;
extern int odorB;
extern int odorC;
extern int odorD;
extern int water;
extern int infoWater;
extern int randWater;

//int lastBlock[20];
extern int lastBlock[];

void pickTrialParams(int);

int determineReward(int);

int randomize(void);

void newBlock(void);

int randomTrial(int);

int determineTrial (void);

int determineForcedTrial (void);

int determineBiasedTrial (void);

#endif
