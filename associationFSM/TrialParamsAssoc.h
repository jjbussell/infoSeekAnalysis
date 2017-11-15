#ifndef __TRIALPARAMSASSOC_H_INCLUDED__
#define __TRIALPARAMSASSOC_H_INCLUDED__

extern int currentOdor;
extern int block[];
extern int reward;
extern int lastBlock[];
extern int plus1; // CS+
extern int plus2; // CS+
extern int minus1; // CS-
extern int minus2; // CS-
extern int trialTypes; // 1 = all types, 2 = US only

void pickTrialParams(int);

void newBlock(void);


#endif
