#ifndef __TRIALPARAMS_H_INCLUDED__
#define __TRIALPARAMS_H_INCLUDED__

extern int infoRewardProb;
extern int randRewardProb;
extern int odor;
extern unsigned long currentRewardTime;
extern int block[];
extern int blockSize;
extern int choiceBlockSize;
extern int choiceInfoBlock;
extern int choiceRandBlock;
extern int trialType;
extern int trialTypes;
extern int infoPort;
extern int randPort;
extern int reward;
extern unsigned long  infoBigRewardTime;
extern unsigned long infoSmallRewardTime;
extern unsigned long  randBigRewardTime;
extern unsigned long randSmallRewardTime;
extern int odorA;
extern int odorB;
extern int odorC;
extern int odorD;
extern int water;
extern int infoWater;
extern int randWater;

void blockSetup(void);

void newBlock(void);

void pickTrialParams(int);

int randomize(void);

#endif
