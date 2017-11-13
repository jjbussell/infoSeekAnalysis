#ifndef __ODOR_ASSOC_H_INCLUDED__
#define __ODOR_ASSOC_H_INCLUDED__

extern int trialType;
extern int valves3a[];
extern int valves3b[];
extern int valves1[];
extern int valves2[];
extern int valves4[];
extern int valves5[];
extern int control;
extern int controls[];
extern int infoPort;
extern int randPort;
extern int infoControl;
extern int randControl;
extern int portSensors[];
extern int controlList[];
extern int infoSide;
extern int randSide;
extern int infoOdors[];
extern int randOdors[];
extern bool odorValveOpen;
extern bool centerOdorValveOpen;
extern int currentCenterOdor;
extern int centerOdor;
extern int choiceOdor;
extern int infoOdor;
extern int randOdor;
extern int infoWater;
extern int randWater;
extern int waterValves[];

extern void printer(int, int, int);

void setCenterOdor(void);

void setSide(void);

void odorOn(int);

void odorOff(int);

void centerOdorOn(int);

void centerOdorOff(int);

void centerOdorOnPID(int);

void centerOdorOffPID(int);

void controlOff(int);

void controlOn(int);

#endif
