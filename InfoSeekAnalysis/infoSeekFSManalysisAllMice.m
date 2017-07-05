% add back lickProbDays

% LICKS NEEDS TO ACCOUNT FOR TIME/ERROR TRIALS!!

% add all mice aligned to reverse day & MEAN + error
% add all mice aligned to reverse day, trial-by-trial/sliding window
% all mice pre-reverse aligned to start & MEAN + error
% all mice pre-reverse aligned to start, trial-by-trial/sliding window
% Ethan's early lick index 
% Ethan's logit--choice, infoside, prereverse, trial type
% table


clear;
close all;

uiopen('.mat'); % pulls in data structure "a" with current data

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  ANALYSIS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% old data in structure "b"

prompt = {'Load old preFSM data file? 1 = yes, 0 = no'};
dlg_title = 'Load preFSM data?';
num_lines = 1;
defaultans = {'1'};
loadData = inputdlg(prompt,dlg_title,num_lines,defaultans);

loadData = str2num(cell2mat(loadData));

if loadData == 1
    [datafilename,datapathname]=uigetfile('*.mat', 'Choose old data file to load');
    fname=fullfile(datapathname,datafilename); 
    load(fname); % opens structure "b" with previous data, if available
    
    c = b;
    clear b;
    b = a;
    clear a;
    
    b.FSM = ones(numel(b.file),1);
    b.FSMall = ones(numel(b.fileAll),1);
    c.FSM = zeros(numel(c.file),1);
    c.FSMall = zeros(numel(c.fileAll),1);
    a.FSM = [b.FSM; c.FSM];
    a.FSMall = [b.FSMall; c.FSMall];
    
    c.parameters = [c.allSummary(:,1:30) cell(size(c.allSummary,1),1) c.allSummary(:,31)];   
    a.parameters = [b.parameters; c.parameters];
    
    a.numFiles = size(a.parameters,1);    

    f1 = struct2cell(b.files); f2 = struct2cell(c.files);    
    fileNames = [f1(1,:) f2(1,:)];
    infoSides = [f1(10,:) f2(9,:)];
    mouseNames = [f1(8,:) f2(7,:)];
    daysFromFiles = [f1(7,:) f2(6,:)];
    e = [fileNames;infoSides;mouseNames;daysFromFiles];
    fn = {'name';'infoSide';'mouseName';'day'};
    a.files = cell2struct(e,fn,1);

    a.fileAll = [b.fileAll; c.fileAll + b.numFiles];
    a.correct = [b.correct; c.correctAll];     
    a.infoForced = [b.infoForced; c.infoForced];
    a.randForced = [b.randForced; c.randForced];
    a.choiceTrials = [b.choiceTrials; c.choice];    
    a.file = [b.file; c.file + b.numFiles]; 
    a.type = [b.type; c.type];
    a.mouse = [b.mouse; c.mouse];
    a.mouseAll = [b.mouseAll; c.mouseAll];
    a.choiceCorr = [b.choiceCorr; c.info];
    a.choiceTypeCorr = [b.choiceTypeCorr; c.trialType];
        c.rxn = c.firstRewardEntry - c.goCue;
        c.rxn(c.firstRewardEntry == 0) = NaN;
    a.rxn  = [b.rxn(b.correct); c.rxn];
    a.odor2 = [b.trialParams(:,6); c.odor2];
    a.reward = [b.reward; c.reward];
    a.trialLength = [b.trialLength(b.correct); c.trialLength];
    a.anticipatoryLicks = [b.anticipatoryLicks; c.anticipatoryLicks];
    a.betweenLicks = [b.betweenLicks; c.betweenLicks];
    a.earlyLicks = [b.earlyLicks; c.earlyLicks];
    a.waterLicks = [b.waterLicks; c.waterLicks];
    a.outcome = [b.outcome; zeros(numel(b.fileAll),1)]; % outcome only calculated for FSM
    
    clear b; clear c;
    
else % only FSM files
    a.FSM = ones(numel(a.file),1);
    a.FSMall = ones(numel(a.fileAll),1);
    a.rxn = a.rxn(a.correct);
    a.odor2 = a.trialParams(:,6);
    a.trialLength = a.trialLength(a.correct);
end

%% DAYS

% assign day to each trial
days = a.parameters(:,3);
% find unique days since multiple sessions some days
days = unique(days);
% assign numeric day to each file
for s = 1:size(a.parameters,1)
   a.parameters{s,33} = find(ismember(days,a.parameters{s,3})); 
   a.files(s).day = a.parameters{s,33};
end

a.fileDays = cell2mat(a.parameters(:,33));

a.day = a.fileDays(a.file);
a.dayAll = a.fileDays(a.fileAll);


%% TRIAL COUNTS

a.trialCt = size(a.fileAll,1);
a.corrTrialCt = size(a.file,1);

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ALL TRIALS

a.choiceTypeNames = {'InfoForced','RandForced','Choice'};
a.choiceTypeCts = [sum(a.infoForced) sum(a.randForced) sum(a.choiceTrials)];


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ALL CORRECT TRIALS

a.infoBig = a.type == 1 | a.type == 5;
a.infoSmall = a.type == 2 | a.type == 6;
a.randBig = a.type == 3| a.type == 7;
a.randSmall = a.type == 4 | a.type == 8;

a.typeNames = {'Info Water','Info None','Rand Water','Rand None'};
a.typeSizes = [sum(a.infoBig) sum(a.infoSmall) sum(a.randBig) sum(a.randSmall)];

a.choiceCorrTrials = a.type < 5;
a.forcedCorrTrials = a.type > 4;
a.infoCorrTrials = a.choiceCorr == 1;
a.randCorrTrials = a.choiceCorr == 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
a.infoChoiceCorr = a.type == 1 | a.type == 2;
a.infoForcedCorr = a.type == 5 | a.type == 6;
a.randChoiceCorr = a.type == 3 | a.type == 4;
a.randForcedCorr = a.type == 7 | a.type == 8;

a.choiceCorrTypeNames = {'InfoForced','RandForced','InfoChoice',...
    'RandChoice'};
a.choiceTypeCtsCorr = [sum(a.infoForcedCorr) sum(a.randForcedCorr) sum(a.infoChoiceCorr) sum(a.randChoiceCorr)];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% REACTION TIMES

% by trial type

a.rxnInfoForcedCorr = a.rxn(a.infoForcedCorr);
a.rxnInfoChoiceCorr = a.rxn(a.infoChoiceCorr);
a.rxnRandForcedCorr = a.rxn(a.randForcedCorr);
a.rxnRandChoiceCorr = a.rxn(a.randChoiceCorr);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
a.mouseList = unique(a.mouse);
a.mouseCt = size(a.mouseList,1);

a.mice = [];
for m = 1:a.mouseCt
  a.mice(:,m) = strcmp(a.mouse,a.mouseList(m)) == 1;
  a.miceAll(:,m) = strcmp(a.mouseAll,a.mouseList(m)) == 1;
end

%%
a.dayCell = a.parameters(:,3); % names
a.miceCell = a.parameters(:,2); % names

for m = 1:a.mouseCt
   mouseFileIdx = strcmp(a.miceCell,a.mouseList{m});
   a.mouseDays{m} = unique(a.dayCell(mouseFileIdx));
   a.mouseDayCt(m) = size(a.mouseDays{m},1);
end

for fm = 1:a.numFiles
   a.fileMouse(fm) = find(strcmp(a.parameters(fm,2),a.mouseList));
   a.fileDay(fm) = find(strcmp(a.parameters(fm,3),a.mouseDays{1,a.fileMouse(fm)})); 
end

a.mouseDay = zeros(sum(a.corrTrialCt),1);
for tf = 1:sum(a.corrTrialCt) % for each trial
   a.mouseDay(tf,1) = a.fileDay(a.file(tf));
%    a.mouseDay(tf,1) = 1;
end

a.mouseDayAll = zeros(length(a.fileAll),1);
for tfa = 1:length(a.fileAll) % for each trial
   a.mouseDayAll(tfa,1) = a.fileDay(a.fileAll(tfa));
end

%% REVERSAL

% FINDS REVERSE DAY (a.reverseDay(m,1) AND TRIAL (a.preReverse)

infoSide = cell2mat({a.files.infoSide});

a.reverseFile = zeros(a.mouseCt,1);
a.reverseDay = zeros(a.mouseCt,1);
a.prereverseFiles = ones(a.numFiles,1); %flag 1 = file before reverse

for m = 1:a.mouseCt
    
    mouseFileCt(m,1) = sum(a.fileMouse == m);
    fileSums = [0; cumsum(mouseFileCt)];
    if mouseFileCt(m,1) > 1
        mouseInfoSideDiff = diff(infoSide(a.fileMouse == m));
        if ~isempty(find(mouseInfoSideDiff) ~= 0)       
%             a.reverseFile(m,1) = max(find(mouseInfoSideDiff~=0)) + 1;
            a.reverseFile(m,1) = find(mouseInfoSideDiff~=0,1,'first') + 1;
%             a.prereverseFiles(fileSums(m) + a.reverseFile(m,1) : fileSums(m+1)) = 0;
            mouseFilesIdx = find(a.fileMouse == m);
            a.prereverseFiles(mouseFilesIdx(a.reverseFile(m,1):end)) = 0;
            mouseFileDays = a.fileDay(a.fileMouse == m);
            a.reverseDay(m,1) = mouseFileDays(a.reverseFile(m,1));
        end
    end
end

a.preReverse = ones(size(a.file,1),1);
for t = 1:size(a.file,1)
    a.preReverse(t,1) = a.prereverseFiles(a.file(t));
end

%% INFOSIDE

for i = 1:size(a.file,1)
   a.infoSide(i,1) = a.files(a.file(i)).infoSide;  
end

%% REWARD FLAG

a.rewardFlag = zeros(numel(a.reward),1);
a.rewardFlag(a.reward>0) = 1;

%% CHOICES

% MAKE THESE INCLUDE REVERSE, THEN CAN DO AVERAGES AND LIMIT TO LAST X
% TRIALS/DAYS

a.choice_all = a.choiceCorr; % choice relative to initial info side, all trials
reverseFlag = a.preReverse == 0;
a.choice_all(reverseFlag) = ~a.choice_all(reverseFlag);

a.initinfoside_info = -ones(a.corrTrialCt,1); % initinfoside_info all trials

a.initinfoside_side = ones(a.corrTrialCt,1); % initinfoside_side all trials

for m = 1:a.mouseCt
    % initial info side
    a.initinfoside(m,1) =  a.files(find(a.fileMouse == m,1)).infoSide;
    ok = a.mice(:,m) == 1;
    a.initinfoside_info(a.infoSide == a.initinfoside(m) & ok == 1) = 1;
end


for m = 1:a.mouseCt
   ok = a.mice(:,m) == 1 & a.choiceTypeCorr == 1;
   a.choiceAllbyMouse{m} = a.choiceCorr(ok);
   a.choiceAllTrialCt(m,1) = numel(a.choiceAllbyMouse{m});
   a.choicebyMouse{m} = a.choiceCorr(ok & a.preReverse == 1); % preReverse
   a.choiceTrialCt(m,1) = numel(a.choicebyMouse{m});
   a.cumChoiceByMouse{m} = cumsum(a.choicebyMouse{m});
   a.choiceRxnByMouse{m} = a.rxn(ok & a.preReverse == 1);
   a.choiceEarlyLicksByMouse{m} = a.earlyLicks(ok & a.preReverse == 1);
   a.choiceAnticLicksByMouse{m} = a.betweenLicks(ok & a.preReverse == 1);
   a.choiceRewardByMouse{m} = a.rewardFlag(ok & a.preReverse == 1);
   a.choiceAllRxnByMouse{m} = a.rxn(ok);
   a.choiceAllEarlyLicksByMouse{m} = a.earlyLicks(ok);
   a.choiceAllAnticLicksByMouse{m} = a.betweenLicks(ok);
   a.choiceAllRewardByMouse{m} = a.rewardFlag(ok);
   a.preReverseByMouse{m} = a.preReverse(ok);
   a.choiceIISByMouse{m} = a.choice_all(ok);   
end

%% CURRENT AND CHOICE AND REVERSED MICE

% create list of mice with choices to cycle through and sort names

a.choiceMice = find(a.choiceTrialCt>0);
a.choiceMiceList = a.mouseList(a.choiceMice);
a.choiceMouseCt = numel(a.choiceMice);
a.preChoiceMice = find(a.choiceTrialCt == 0);

dayDates = datetime(cell2mat(a.parameters(:,3)),'InputFormat','yyyy-MM-dd');
today = max(dayDates);
currentDay = a.parameters(:,3) == today;
a.currentMice = unique(a.parameters(currentDay,2));
[~,a.currentMiceNums] = ismember(a.currentMice,a.mouseList);
[~,a.currentChoiceMice] = ismember(a.currentMiceNums,a.choiceMice);
a.currentChoiceMiceList = a.mouseList(a.currentChoiceMice);

a.reverseMice = find(a.reverseFile>0);
a.reverseMiceList = a.mouseList(a.reverseMice);

%% ALL PRE-REVERSE CHOICES ALIGNED TO START

% a.choiceByMouse %a.meanChoicebyDay = mean(cell2mat(a.meanDayChoicesOrg),1,'omitnan');
a.maxChoiceTrials = max(a.choiceTrialCt);
a.choiceTrialsOrg = NaN(a.choiceMouseCt,a.maxChoiceTrials);

if a.maxChoiceTrials > 0
    for m = a.choiceMice(1):a.choiceMice(end)   
       a.choiceTrialsOrg(m,1:a.choiceTrialCt(m)) = a.choicebyMouse{m}; 
    end
end

%% CHOICE AND REVERSE START

% FIND DAYS WITH CHOICE TRIALS
% ASK IF THEY ARE PREREVERSE

% a.firstChoice = first choice trial
% a.firstChoiceDay = first choice day
% a.firstReverse = first reverse trial
% a.reverseDay = first reverse day
% need reverse trianing trials
% total reverse trials

for m = 1:a.mouseCt
   ok = a.mice(:,m) == 1;
   mouseTypes = a.choiceTypeCorr(ok);
   mouseReverse = a.preReverse(ok);
   if isempty(find(mouseTypes == 1,1))
      a.firstChoice(m,1) = 0;
      a.mouseChoiceDays{m} = [];
      a.firstChoiceDay(m,1) = 0;
      choiceDays =[];
   else
     a.firstChoice(m,1) = find(mouseTypes == 1,1); % within all that mouse's trials
     a.mouseChoiceDays{m} = unique(a.mouseDay(find(a.choiceTypeCorr==1 & ok)));
     a.firstChoiceDay(m,1) = a.mouseDay(find(a.choiceTypeCorr==1 & ok,1)); 
     choiceDays = a.mouseChoiceDays{m};
   end
   if isempty(find(mouseReverse == 0,1))
       a.mouseReverseDays{m} = [];
       a.firstReverse(m,1) = 0;
       a.firstReverseChoice(m,1) = 0; % if empty
       a.lastReverse(m,1) = 0;
       reverseDays = [];       
       a.reverseChoiceDays(m) = 0;
       a.reverseTrainingDays(m) = 0;
       a.firstReverseInChoiceTrials(m,1) = 0;
   else
       a.mouseReverseDays{m} = unique(a.mouseDay(find(a.preReverse==0 & ok)));
       a.firstReverse(m,1) = find(mouseReverse == 0,1); % within all that mouse's trials
       a.firstReverseChoice(m,1) = find(mouseTypes == 1 & mouseReverse == 0,1);
       a.lastReverse(m,1) = find(mouseReverse == 0,1,'last');
       reverseDays = a.mouseReverseDays{m};
       a.reverseChoiceDays(m) = numel(choiceDays(ismember(a.mouseChoiceDays{m},a.mouseReverseDays{m})));
       a.reverseTrainingDays(m) = numel(reverseDays(~ismember(a.mouseReverseDays{m},a.mouseChoiceDays{m})));
       reverse = a.preReverseByMouse{m};
       a.firstReverseInChoiceTrials(m,1) = find(reverse==0,1);
   end
end

a.trialsPreReverse = a.firstReverse - a.firstChoice;
a.choiceDaysPreReverse = a.reverseDay - a.firstChoiceDay;
a.trialsReverseTraining = a.firstReverseChoice - a.firstReverse;
a.trialsReverseWithChoices = a.lastReverse - a.firstReverseChoice;

%% ALL CHOICES ALIGNED TO REVERSE START

% find first reverse trial within choicesand then max pre and post, create NaN array
% will with data for each mouse

maxChoiceAllTrials = max(a.firstReverseInChoiceTrials) + max(a.choiceAllTrialCt - a.firstReverseInChoiceTrials)+1;
a.commonReverse = max(a.firstReverseInChoiceTrials); % first reversed choice trial
a.choiceTrialsOrgRev = NaN(a.mouseCt,maxChoiceAllTrials);

% if ~isempty(a.choiceMice)
%     for m = a.choiceMice(1):a.choiceMice(end) 
%        % relative to reverse start
%        % postReverse = choices(a.firstReverseInChoiceTrials(m,1):a.choiceAllTrialCt(m,1));
%        % preReverse = choices(1:a.firstReverseInChoiceTrials(m,1)-1);
% 
%        choices = a.choiceAllbyMouse{m};
% 
%        a.choiceTrialsOrgRev(m,a.commonReverse - a.firstReverseInChoiceTrials(m,1)+1 : a.commonReverse-1) = choices(1:a.firstReverseInChoiceTrials(m,1)-1);
%        a.choiceTrialsOrgRev(m,a.commonReverse : a.commonReverse + a.choiceAllTrialCt(m,1)-a.firstReverseInChoiceTrials(m,1)) = choices(a.firstReverseInChoiceTrials(m,1):a.choiceAllTrialCt(m,1));  
%     end
% end

%% MEAN CHOICES / STATS AND CHOICE RANGES

% TAKE NON-REVERSE MICE OUT OF GLM CALCS

trialsToCount = 500;

if ~isempty(a.choiceMice)
    for m = a.reverseMice(1):a.reverseMice(end) 

       choicesIIS = a.choiceIISByMouse{m};

       preReverseTrials = find(a.preReverseByMouse{m} == 1,trialsToCount,'last');
       postReverseTrials = find(a.preReverseByMouse{m} == 0,trialsToCount,'last');

       [a.pref(m,1),a.prefCI(m,1:2)] = binofit(sum(choicesIIS(preReverseTrials)==1),numel(choicesIIS(preReverseTrials)));
       [a.pref(m,2),a.prefRevCI(m,1:2)] = binofit(sum(choicesIIS(postReverseTrials)==1),numel(choicesIIS(postReverseTrials)));

       ok = a.mice(:,m) == 1 & a.choiceTypeCorr == 1;

       choicePreRev = a.choice_all(ok & a.preReverse == 1);
       choicePostRev = a.choice_all(ok & reverseFlag);

       [a.meanChoice(m,1),a.choiceCI(m,1:2)] = binofit(sum(choicePreRev==1),numel(choicePreRev));
       [a.meanChoice(m,2),a.choiceRevCI(m,1:2)] = binofit(sum(choicePostRev==1),numel(choicePostRev));
       a.meanChoice(m,3) = m;

%        disp(['mouse ' num2str(m)]);
       x = [a.initinfoside_side(ok) a.initinfoside_info(ok)];
       y = a.choice_all(ok);
       [~,~,a.stats(m)] = glmfit(x,y,'binomial','link','logit','constant','off');
       a.beta(m,:) = a.stats(m).beta;
       a.betaP(m,:) = a.stats(m).p;
    end

    allChoices = a.choiceCorr(a.choiceCorrTrials & a.preReverse == 1);
    [a.overallPref,a.overallCI] = binofit(sum(allChoices == 1),numel(allChoices));
    clear allChoices;
end

%% CHOICE BY DAY - SKIP 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% THIS IS THE SAME AS a.daySummary.percentInfo

% NOT GONNA WORK FOR MICE WITH NO CHOICES??

% need to make pre-reverse?!? rel to initial info side?!?

% for m = 1:a.mouseCt
%     for d = 1:a.mouseDayCt(m)
%        ok = a.mice(:,m) & a.mouseDay == d;
%        a.choicesbyDay{m,d} = a.choiceCorr(ok & a.choiceTypeCorr == 1);
%        a.meanDayChoice{m,d} = mean(a.choicesbyDay{m,d});
%     end
% end
% 
% for m = 1:a.mouseCt
%     choiceDays = find(~isnan(cell2mat(a.meanDayChoice(m,:))));
%     choiceDayCt(m) = size(choiceDays,2);
%     a.choiceDays{m,:} = choiceDays;
%     for dd = 1:size(choiceDays,2)
%         a.meanDayChoicesOrg{m,dd} = a.meanDayChoice{m,choiceDays(dd)};
%     end    
% end
% 
% %% ALIGN TO REVERSAL
% 
% % FINDS a.revChoiceDays(m,:), the days in a.mouseDay for each mouse to calculate aligned values
% 
% for m = 1:a.mouseCt
%     choiceReverseDay(m) = find(a.choiceDays{m,:} == a.reverseDay(m));
% end
% 
% a.commonReverse = max(choiceReverseDay)-1;
% postReverseDayCt = choiceDayCt - choiceReverseDay;
% % maxPostReverse = max(cell2mat(postReverseDays));
% % DAY TO ALIGN REVERSALS
% revAlign = a.commonReverse+1;
% 
% a.meanDayChoicesRevOrg = cell(a.mouseCt);
% for m=1:a.mouseCt
%     preReverseDays{m} = a.choiceDays{m,1}(1):choiceReverseDay(m);
%     postReverseDays{m} = choiceReverseDay(m)+1:choiceReverseDay(m) + postReverseDayCt(m);
%     mouseDayswRev{m} = [preReverseDays{m} postReverseDays{m}]; % same as choice days!
%     for d = 1:choiceReverseDay(m)
%        a.meanDayChoicesRevOrg(m,revAlign-choiceReverseDay(m)+d) = a.meanDayChoicesOrg(m,d); 
%     end
%     for d = 1:choiceDayCt(m)-choiceReverseDay(m)
%        a.meanDayChoicesRevOrg(m,revAlign+d) = a.meanDayChoicesOrg(m,choiceReverseDay(m)+d); 
%     end
%     a.revChoiceDays{m,:} = find(~cellfun(@isempty,a.meanDayChoicesRevOrg(m,:)));
% end
% 
% a.meanDayChoicesRevOrg(cellfun(@isempty,a.meanDayChoicesRevOrg(:,:))) = {NaN};
% a.dayswRev = size(a.meanDayChoicesRevOrg,2);
% 
% a.meanChoicebyRevDay = mean(cell2mat(a.meanDayChoicesRevOrg),1,'omitnan');
% a.semChoicebyRevDay = sem(cell2mat(a.meanDayChoicesRevOrg));
% 
% a.totalChoiceDays = size(a.meanDayChoicesRevOrg,2);
% 
% 
% %% CALCULATE COMMON DAY FOR EACH TRIAL
% 
% % a.allDay is the day from 1:totalchoicedays for each trial, aligned to
% % reversal
% 
% a.allDay = zeros(size(a.mouseDay,1),1);
% for m = 1:a.mouseCt
%     revChoiceDays = a.revChoiceDays{m,1};
%     choiceDays = a.choiceDays{m,1};
%     for d = 1:size(revChoiceDays,2)
%         corrDay = revChoiceDays(d);
%         ok = a.mice(:,m) == 1 & a.mouseDay == choiceDays(d);
%         a.allDay(ok) = corrDay;
%     end
% end
% 
% % test mean choices
% 
% % for d = 1:a.totalChoiceDays
% %    ok = a.allDay == d & a.trialType == 1;
% %    overallDayMean(d) = mean(a.info(ok));  
% % end

%% SORT BY INFO PREFERENCE
if ~isempty(a.choiceMice)
    [a.sortedChoice,a.sortIdx] = sortrows(a.meanChoice,1);
    a.sortedMouseList = a.choiceMiceList(a.sortIdx);
    a.sortedCI = a.choiceCI(a.sortIdx,:);

    %% STATS

    a.icp_all = a.sortedChoice(:,1)*100;
    a.overallP = signrank(a.icp_all-50);
end

%% TRIAL TYPE COUNTS BY MOUSE BY DAY

for m = 1:a.mouseCt
    for d = 1:a.mouseDayCt(m)
       ok = a.mice(:,m) & a.mouseDay == d;
       a.typeSizesMouseDays(d,:,m) = [sum(a.infoBig(ok)) sum(a.infoSmall(ok)) sum(a.randBig(ok)) sum(a.randSmall(ok))];
       a.choiceTypeSizesmouseDays(d,:,m) = [sum(a.infoForcedCorr(ok)) sum(a.infoChoiceCorr(ok)) sum(a.randForcedCorr(ok)) sum(a.randChoiceCorr(ok))];
    end
end

%% LICK INDEX
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for f = 1:a.numFiles
    a.odorA(f,1) = cell2mat(a.parameters(f,12));
    a.odorB(f,1) = cell2mat(a.parameters(f,13));
    a.odorC(f,1) = cell2mat(a.parameters(f,14));
    a.odorD(f,1) = cell2mat(a.parameters(f,15));   
end

for t = 1:a.corrTrialCt
    trialFile = a.file(t);
    a.odorAtrials(t,1) = a.odor2(t) == a.odorA(trialFile);
    a.odorBtrials(t,1) = a.odor2(t) == a.odorB(trialFile);
    a.odorCtrials(t,1) = a.odor2(t) == a.odorC(trialFile);
    a.odorDtrials(t,1) = a.odor2(t) == a.odorD(trialFile);
end

for m = 1:a.mouseCt
    for d = 1:a.mouseDayCt(m)
        ok = a.mouseDay == d & a.mice(:,m) == 1;
        a.Alicks(m,d) = sum(a.anticipatoryLicks(a.odorAtrials & ok)); % anticipateLickCt
        a.Blicks(m,d) = sum(a.anticipatoryLicks(a.odorBtrials & ok));
        a.Clicks(m,d) = sum(a.anticipatoryLicks(a.odorCtrials & ok));
        a.Dlicks(m,d) = sum(a.anticipatoryLicks(a.odorDtrials & ok));
        
        a.AlicksBetween(m,d) = sum(a.betweenLicks(a.odorAtrials & ok));
        a.BlicksBetween(m,d) = sum(a.betweenLicks(a.odorBtrials & ok));
        a.ClicksBetween(m,d) = sum(a.betweenLicks(a.odorCtrials & ok));
        a.DlicksBetween(m,d) = sum(a.betweenLicks(a.odorDtrials & ok));        
                
        a.AlicksEarly(m,d) = sum(a.earlyLicks(a.odorAtrials & ok));
        a.BlicksEarly(m,d) = sum(a.earlyLicks(a.odorBtrials & ok));
        a.ClicksEarly(m,d) = sum(a.earlyLicks(a.odorCtrials & ok));
        a.DlicksEarly(m,d) = sum(a.earlyLicks(a.odorDtrials & ok));
        a.randBigLicksEarly(m,d) = sum(a.earlyLicks(a.randBig & ok));
        a.randSmallLicksEarly(m,d) = sum(a.earlyLicks(a.randSmall & ok));
        
        a.AlicksWater(m,d) = sum(a.waterLicks(a.odorAtrials & ok));
        a.BlicksWater(m,d) = sum(a.waterLicks(a.odorBtrials & ok));
        a.ClicksWater(m,d) = sum(a.waterLicks(a.odorCtrials & ok));
        a.DlicksWater(m,d) = sum(a.waterLicks(a.odorDtrials & ok));
        a.randBigLicksWater(m,d) = sum(a.waterLicks(a.randBig & ok));
        a.randSmallLicksWater(m,d) = sum(a.waterLicks(a.randSmall & ok));
        
        a.lickIdxInfo(m,d) = a.AlicksBetween(m,d)/(a.AlicksBetween(m,d)+a.BlicksBetween(m,d));
        a.lickIdxRand(m,d) = a.ClicksBetween(m,d)/(a.ClicksBetween(m,d)+a.DlicksBetween(m,d));
        
        a.lickIndex(m,d) = (a.AlicksBetween(m,d) + a.BlicksBetween(m,d))/(a.ClicksBetween(m,d) + a.DlicksBetween(m,d));
        
        a.ARewards(m,d) = sum(a.reward(a.odorAtrials & ok));
        a.BRewards(m,d) = sum(a.reward(a.odorBtrials & ok));
        a.CRewards(m,d) = sum(a.reward(a.odorCtrials & ok));
        a.DRewards(m,d) = sum(a.reward(a.odorDtrials & ok));
        
        a.randBigRewards(m,d) = sum(a.reward(a.randBig & ok));
        a.randSmallRewards(m,d) = sum(a.reward(a.randSmall & ok));
    end
end


%% EARLY LICKS BY REVERSAL

% NEED TO FINISH

a.initInfoLicks = mean(a.earlyLicks(a.initinfoside_info == 1));
a.initNoInfoLicks = mean(a.earlyLicks(a.initinfoside_info == -1));
a.earlyLickIdx = (a.initInfoLicks - a.initNoInfoLicks)/(a.initInfoLicks + a.initNoInfoLicks);

for m=1:a.mouseCt
   ok = a.mice(:,m) == 1;
   % pre-reverse, INFO
   a.preRevEarlyLicks(m,1) = mean(a.earlyLicks(a.initinfoside_info == 1 & a.preReverse == 1 & ok == 1));
   % pre-reverse, NO INFO
   a.preRevEarlyLicks(m,2) = mean(a.earlyLicks(a.initinfoside_info == -1 & a.preReverse == 1 & ok == 1));
   % post-reverse, INFO
   a.postRevEarlyLicks(m,1) = mean(a.earlyLicks(a.initinfoside_info == 1 & reverseFlag & ok == 1));
   % post-reverse, NO INFO
   a.postRevEarlyLicks(m,2) = mean(a.earlyLicks(a.initinfoside_info == -1 & reverseFlag & ok == 1));
end

% [(mean licks to initial-info side) - (mean licks to initial-noinfo side)]
% / [(mean licks to initial-info side) + (mean licks to initial-noinfo side)]
% 
% I then calculated it separately for each animal, and separately for their pre-reversal and post-reversal data. I defined its significance as a simple t-test comparing the licks to the two sides:

% ttest2(mean licks to initial-info side, mean licks to initial-noinfo side)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% DAY SUMMARY
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for m = 1:a.mouseCt
    for d = 1:a.mouseDayCt(m)
        % OUTCOMES (all trials)        
        if sum(a.FSMall(a.miceAll(:,m) == 1)>0)
            a.daySummary.outcome{m,d} = a.outcome(a.mouseDayAll == d & a.miceAll(:,m) == 1);
        end
        
        % OTHER (correct trials)
        ok = [];
        ok = a.mouseDay == d & a.mice(:,m) == 1;
        a.daySummary.mouse{m,d} = m;
        a.daySummary.mouseName{m,d} = a.mouseList{m};
        a.daySummary.day{m,d} = d;
        a.daySummary.infoForced{m,d} = sum(a.infoForcedCorr(ok));
        a.daySummary.infoChoice{m,d} = sum(a.infoChoiceCorr(ok));
        a.daySummary.randForced{m,d} = sum(a.randForcedCorr(ok));
        a.daySummary.randChoice{m,d} = sum(a.randChoiceCorr(ok));
        a.daySummary.infoBig{m,d} = sum(a.infoBig(ok));
        a.daySummary.infoSmall{m,d} = sum(a.infoSmall(ok));
        a.daySummary.randBig{m,d} = sum(a.randBig(ok));
        a.daySummary.randSmall{m,d} = sum(a.randSmall(ok));
        lastFileIdx = find(ok,1,'last');
        a.daySummary.infoBigProb{m,d} = a.parameters{a.file(lastFileIdx),24};
        a.daySummary.totalRewards{m,d} = sum(a.reward(ok));
        a.daySummary.totalTrials{m,d} = sum([a.daySummary.infoBig{m,d},a.daySummary.infoSmall{m,d},a.daySummary.randBig{m,d},a.daySummary.randSmall{m,d}]);
        a.daySummary.percentInfo{m,d} = mean(a.infoCorrTrials(ok & a.choiceCorrTrials == 1));
        a.daySummary.rxnInfoForced{m,d} = mean(a.rxn(a.infoForcedCorr & ok));
        a.daySummary.rxnInfoChoice{m,d} = mean(a.rxn(a.infoChoiceCorr & ok));
        a.daySummary.rxnRandForced{m,d} = mean(a.rxn(a.randForcedCorr & ok));
        a.daySummary.rxnRandChoice{m,d} = mean(a.rxn(a.randChoiceCorr & ok));
        a.daySummary.infoBigLicks{m,d} = a.AlicksBetween(m,d)/sum(a.odorAtrials & ok);
        a.daySummary.infoSmallLicks{m,d} = a.BlicksBetween(m,d)/sum(a.odorBtrials & ok);
        a.daySummary.randCLicks{m,d} = a.ClicksBetween(m,d)/sum(a.odorCtrials & ok);
        a.daySummary.randDLicks{m,d} = a.DlicksBetween(m,d)/sum(a.odorDtrials & ok);
        a.daySummary.infoBigLicksEarly{m,d} = a.AlicksEarly(m,d)/sum(a.odorAtrials & ok);
        a.daySummary.infoSmallLicksEarly{m,d} = a.BlicksEarly(m,d)/sum(a.odorBtrials & ok);
        a.daySummary.randCLicksEarly{m,d} = a.ClicksEarly(m,d)/sum(a.odorCtrials & ok);
        a.daySummary.randDLicksEarly{m,d} = a.DlicksEarly(m,d)/sum(a.odorDtrials & ok);
        a.daySummary.randBigLicksEarly{m,d} = a.randBigLicksEarly(m,d)/sum(a.randBig & ok);
        a.daySummary.randSmallLicksEarly{m,d} = a.randSmallLicksEarly(m,d)/sum(a.randSmall & ok);                
        a.daySummary.infoBigLicksWater{m,d} = a.AlicksWater(m,d)/sum(a.odorAtrials & ok);
        a.daySummary.infoSmallLicksWater{m,d} = a.BlicksWater(m,d)/sum(a.odorBtrials & ok);
        a.daySummary.randCLicksWater{m,d} = a.ClicksWater(m,d)/sum(a.odorCtrials & ok);
        a.daySummary.randBigLicksWater{m,d} = a.randBigLicksWater(m,d)/sum(a.randBig & ok);
        a.daySummary.randSmallLicksWater{m,d} = a.randSmallLicksWater(m,d)/sum(a.randSmall & ok);
        a.daySummary.randDLicksWater{m,d} = a.DlicksWater(m,d)/sum(a.odorDtrials & ok); 
        a.daySummary.ARewards{m,d} = a.ARewards(m,d)/sum(a.odorAtrials & ok);
        a.daySummary.BRewards{m,d} = a.BRewards(m,d)/sum(a.odorBtrials & ok);
        a.daySummary.CRewards{m,d} = a.CRewards(m,d)/sum(a.odorCtrials & ok);
        a.daySummary.DRewards{m,d} = a.DRewards(m,d)/sum(a.odorDtrials & ok);
        a.daySummary.randBigRewards{m,d} = a.randBigRewards(m,d)/sum(a.randBig & ok);
        a.daySummary.randSmallRewards{m,d} = a.randSmallRewards(m,d)/sum(a.randSmall & ok);
        a.daySummary.trialLengthInfoForced{m,d} = nansum(a.trialLength(a.infoForcedCorr == 1 & ok == 1))/sum(~isnan(a.trialLength(a.infoForcedCorr == 1 & ok == 1)));
        a.daySummary.trialLengthInfoChoice{m,d} = nansum(a.trialLength(a.infoChoiceCorr == 1 & ok == 1))/sum(~isnan(a.trialLength(a.infoChoiceCorr == 1 & ok == 1)));
        a.daySummary.trialLengthRandForced{m,d} = nansum(a.trialLength(a.randForcedCorr == 1 & ok == 1))/sum(~isnan(a.trialLength(a.randForcedCorr == 1 & ok == 1)));
        a.daySummary.trialLengthRandChoice{m,d} = nansum(a.trialLength(a.randChoiceCorr == 1 & ok == 1))/sum(~isnan(a.trialLength(a.randChoiceCorr == 1 & ok == 1)));
        a.daySummary.rewardInfoForced{m,d} = sum(a.reward(a.infoForcedCorr == 1 & ok == 1))/sum(a.infoForcedCorr(ok));
        a.daySummary.rewardInfoChoice{m,d} = sum(a.reward(a.infoChoiceCorr == 1 & ok == 1))/sum(a.infoChoiceCorr(ok));
        a.daySummary.rewardRandForced{m,d} = sum(a.reward(a.randForcedCorr == 1 & ok == 1))/sum(a.randForcedCorr(ok));
        a.daySummary.rewardRandChoice{m,d} = sum(a.reward(a.randChoiceCorr == 1 & ok == 1))/sum(a.randChoiceCorr(ok));
        a.daySummary.rewardRateInfoForced{m,d} = sum(a.reward(a.infoForcedCorr == 1 & ok == 1)) / nansum(a.trialLength(a.infoForcedCorr == 1 & ok == 1))*1000;
        a.daySummary.rewardRateInfoChoice{m,d} = sum(a.reward(a.infoChoiceCorr == 1 & ok == 1)) / nansum(a.trialLength(a.infoChoiceCorr == 1 & ok == 1))*1000;
        a.daySummary.rewardRateRandForced{m,d} = sum(a.reward(a.randForcedCorr == 1 & ok == 1)) / nansum(a.trialLength(a.randForcedCorr == 1 & ok == 1))*1000;
        a.daySummary.rewardRateRandChoice{m,d} = sum(a.reward(a.randChoiceCorr == 1 & ok == 1)) / nansum(a.trialLength(a.randChoiceCorr == 1 & ok == 1))*1000;        
    end
end

%%
uisave({'a'},'infoSeekFSMDataAnalyzedComplete.mat');