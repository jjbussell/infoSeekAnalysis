import serial
import time
import sys
import datetime
import os

############ OPEN PORT
# Open Arduino serial port
ser = serial.Serial("COM4", 115200)   # open serial port that Arduino is using
print "\nSerial port open"
sys.stdout.flush()

# delay for Arduino to setup
print "\nWaiting for Arduino setup\n"
sys.stdout.flush()
time.sleep(2)


############# FUNCTION DEFINITIONS
def timeStamp(fname, fmt='{fname}_%Y-%m-%d_%Hh-%Mm-%Ss'):
    return datetime.datetime.now().strftime(fmt).format(fname=fname)

def dir_timeStamp(fmt='%Y%m%d'):
    return datetime.datetime.now().strftime(fmt)

def num(s):
    try:
        return int(s)
    except ValueError:
        return -1
    return

##############  SET ARDUINO PARAMETERS  ############################

##############  SET ARDUINO PARAMETERS  ############################
mouse = 'JB181'
sessionEnd = '3'
sessionTrials = '1000000'
imageFlag = '0'
trialTypes = '5' # 1 = choice, 2 = info, 3 = random, 4 = forced, 6 = biased 5 = all three
infoSide = '0' #For now control1 goes to left port (looking from inside box), as do odors 0-2==INFO
infoOdor = '3'
randOdor = '0'
choiceOdor = '2'
odorA = '2'
odorB = '0'
odorC = '3' 
odorD = '1'
centerDelay = '0' #0
centerOdorTime = '200' #200, 0
startDelay = '0' #50, 0
odorDelay = '1200' #1300, 0
odorTime = '200'  #300, 0
rewardDelay = '3000' #1500, 0
bigRewardTime = '200' #100, 50 for training
smallRewardTime = '0' #0, 50 for training
infoRewardProb = '50' #50
randRewardProb = '50' #50
gracePeriod = '0' #4000, 1000000000
interval = '4000' #4500, 0
TOU_THRESH = '15'
REL_THRESH = '10'
touch_right = '3'
touch_left = '6'


#lick channel 3 and 6

###############################################################
# parameters in a list

parameters = [mouse, sessionEnd, sessionTrials, imageFlag,
              trialTypes, infoSide,
              infoOdor, randOdor, choiceOdor,
              odorA, odorB, odorC, odorD, centerDelay,
              centerOdorTime, startDelay, odorDelay, odorTime,
              rewardDelay, bigRewardTime, smallRewardTime,
              infoRewardProb, randRewardProb,
              gracePeriod, interval, TOU_THRESH, REL_THRESH, touch_right,
              touch_left]
              
fyle = parameters


############ CREATE FILE
filename = timeStamp(fyle[0])
filename = filename + ".csv"

dir_path = 'E:\\Dropbox\\Data\\Infoseek\\' + fyle[0] + '\\' + fyle[0] + '_' + dir_timeStamp()
filename = dir_path + '\\' + filename
if dir_path:
	if not os.path.isdir(dir_path):
		os.makedirs(dir_path)
	datalog = open(filename, "a+")
print 'File open:\n' + filename + '\n'
sys.stdout.flush()


########### RECORD PARAMETERS
# String of parameters and labels
sessionParams = ('Mouse,' + fyle[0] + ",\nSession End," +
                 fyle[1] + ',\nTrials in Session,' + fyle[2] + 
                 ',\nImaging Flag,' + fyle[3] + ',\nTrial Types,' 
                 + fyle[4] + ',\nInfo Side,' + fyle[5]
                 + ',\nInfo Odor,' + fyle[6]
                 + ',\nRand Odor,' + fyle [7] + ',\nChoice Odor,'
                 + fyle [8] + ',\nOdor A,' + fyle[9] + ',\nOdor B,' + fyle[10]
                 + ',\nOdor C,' + fyle[11] + ',\nOdor D,' + fyle[12]
                 + ',\nCenter Delay,' + fyle[13] + ',\nCenter Odor Time,'
                 + fyle[14] + ',\nStart Delay,'
                 + fyle[15] + ',\nOdor Delay,' + fyle[16] + ',\nOdor Time,'
                 + fyle[17] + ',\nReward Delay,' + fyle[18] 
                 + ',\nBig Reward Time,' + fyle[19] + ',\nSmall Reward Time,' 
                 + fyle[20] + ',\nInfo Reward Prob,' + fyle[21] 
                 + '\nRand Reward Prob,' + fyle[22] + ',\nGrace Period,' 
                 + fyle [23]+ ',\nInterval,' + fyle[24]  + ',\nTOU_THRESH,' + fyle[25]
                 + ',\nREL_THRESH,' + fyle[26] + ',\nTouch_Right,' + fyle[27]
                 + ',\nTouch_Left,' + fyle[28] + '\n')

datalog.write(sessionParams)


############ SEND TO ARDUINO
arduinoParams = '1' # Start with '1' to go into Arduino session
for n in range(1,len(fyle)): # take parameters after mouse name
    arduinoParams = arduinoParams + ',' + fyle[n]
sys.stdout.flush()
ser.write(arduinoParams)

print 'Ready\n'
sys.stdout.flush()



def inputType(data):
    first = data[0]
    try:
        return int(first) # int if data is numbers
    except ValueError:
        return -1 # -1 if data is text
    return

################ RECEIVE DATA
# Receive and save data, 1 line per loop
while True:
   currentInput = ser.readline().rstrip('\n')
   restart_cue = num(currentInput)
   if (restart_cue == 1003211238):
       print "End of session \n"
       sys.stdout.flush()
       break      
   if inputType(currentInput) == -1:
       print currentInput
       sys.stdout.flush()
   else:
       datalog.write(currentInput)


# Save and close file
datalog.close()

# Close serial port
ser.close() 
