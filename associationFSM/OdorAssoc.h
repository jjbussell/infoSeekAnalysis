#ifndef __ODOR_ASSOC_H_INCLUDED__
#define __ODOR_ASSOC_H_INCLUDED__

extern int trialType;
extern int valves3a[];
extern int valves3b[];
extern int valves1[];
extern int valves2[];
extern int valves4[];
extern int valves5[];
extern int controls[];
extern bool odorValveOpen;
extern int waterValves[];
extern int water;
extern int port;
extern int odors[];
extern int odorControl;

extern void printer(int, int, int);


void setSide(int);

void odorOn(int);

void odorOff(int);

void controlOff(int);

void controlOn(int);

#endif
