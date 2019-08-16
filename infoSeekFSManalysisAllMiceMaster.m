    % WANT DWELL TIME FOR REWARDED PORT ENTRY -- get entries

% "checking"/out of trial flow side entries--> GET ENTRIES!!!

% fix lick prob days for histogram

% LICKS NEEDS TO ACCOUNT FOR TIME/ERROR TRIALS!! AND LICKING AFTER TRIAL
% "ENDS"

% graph of all entries for each trial


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  ANALYSIS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
    a.FSM = ones(numel(a.file),1);
    a.FSMall = ones(numel(a.fileAll),1);
    a.trialAll = a.trialNums;
    a.trial = a.corrTrials;
    a.rxnAll = a.rxn;
    a.rxn = a.rxn(a.correct);
    a.odor2 = a.trialParams(:,6);
    a.trialLength = a.trialLength(a.correct);
    a.trialLengthCenterEntryCorr = a.trialLengthCenterEntry(a.correct);
    a.rewardAssigned = a.trialParams(:,5);
    if exist('a.deletedFiles')
        a.deletedFiles = a.deletedFiles;
    end
    
    a.rewards = [a.bigRewards; a.smallRewards];
    
% end

a.paramNames = {'File';'Mouse';'Day';'Session End';'Trials in Session';...
    'Imaging Flag';'Trial Types';'Info Side';'Info Odor';'Rand Odor';...
    'Choice Odor';'Odor A';'Odor B';'Odor C';'Odor D';'Center Delay';...
    'Center Odor Time';'Start Delay';'Odor Delay';'Odor Time';...
    'Reward Delay';'Info Big Reward Time';'Info Small Reward Time';...
    'Rand Big Reward Time';'Rand Small Reward Time';'Info Reward Prob';...
    'Rand Reward Prob';'Grace Period Reward Latency';'Interval';...
    'TOU_THRESH';'REL_THRESH Timeout';'Touch_Right';'Touch_Left';...
    'session time';'File Days'};

%% DAYS

% assign day to each trial
days = a.parameters(:,3);
% find unique days since multiple sessions some days
days = unique(days);
% assign numeric day to each file
for s = 1:size(a.parameters,1)
   a.parameters{s,35} = find(ismember(days,a.parameters{s,3})); 
   a.files(s).day = a.parameters{s,35};
end

a.fileDays = cell2mat(a.parameters(:,35));

a.day = a.fileDays(a.file);
a.dayAll = a.fileDays(a.fileAll);


%% TRIAL COUNTS

a.trialCt = size(a.fileAll,1);
a.corrTrialCt = size(a.file,1);

%% TYPES POSSIBLE
a.fileTrialTypes = zeros(numel(a.file),1);
for f = 1:a.numFiles
    a.fileTrialTypes(a.file == f) = a.parameters{f,7};
end

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


%%
a.mouseList = unique(a.mouseAll);
a.mouseCt = size(a.mouseList,1);

a.mice = [];
for m = 1:a.mouseCt
  a.mice(:,m) = strcmp(a.mouse,a.mouseList(m)) == 1;
  a.miceAll(:,m) = strcmp(a.mouseAll,a.mouseList(m)) == 1;
end

%% DAY AND MOUSE

a.dayCell = a.parameters(:,3); % names
a.miceCell = a.parameters(:,2); % names

if exist('a.deletedFiles')
a.dayCell(a.deletedFiles) = [];
a.miceCell(a.deletedFiles) = [];
end

for m = 1:a.mouseCt
   mouseFileIdx = strcmp(a.miceCell,a.mouseList{m});
   a.mouseDays{m} = unique(a.dayCell(mouseFileIdx)); % sorts
   a.mouseDayCt(m) = size(a.mouseDays{m},1);
end

for fm = 1:a.numFiles
   if exist('a.deletedFiles')
    if ismember(fm,a.deletedFiles)
       a.fileMouse(fm) = NaN;
       a.fileDay(fm) = NaN;
    end
   else
   a.fileMouse(fm) = find(strcmp(a.parameters(fm,2),a.mouseList));
   a.fileDay(fm) = find(strcmp(a.parameters(fm,3),a.mouseDays{1,a.fileMouse(fm)}));
   a.trialTypes(fm) = a.parameters{fm,7};
   end
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

%% MOUSE TRIAL TYPES

for m = 1:a.mouseCt
   a.mouseTrialTypes{m,1} = a.trialTypes(a.fileMouse == m); 
end

%% REWARD FLAG (SINCE REWARD IN uL)

a.rewardFlag = zeros(numel(a.rewardCorr),1);
a.rewardFlag(a.rewardCorr>0) = 1;

%% REVERSAL & CHOICES

% FINDS REVERSE DAY (a.reverseDay(m,1) AND TRIALS (a.preReverse)

a.fileInfoSide = cell2mat({a.files.infoSide});

% a.reverseFile = zeros(a.mouseCt,1);
% a.reverseDay = zeros(a.mouseCt,1);
a.reverseDay = cell(a.mouseCt,1);
a.prereverseFiles = ones(a.numFiles,1); %flag 1 = file with choices before reverse
a.prereverseFiles(cell2mat(a.parameters(:,7))~=5) = 0;
a.reverseFiles = zeros(a.numFiles,1); % flag 1 = file before first reverse, -1 = file during first reverse
% a.valueMice = zeros(a.mouseCt,1);

% TO FIX--SORT BY DAYS SO NO FALSE REVERSES!

for m = 1:a.mouseCt
    ok = a.mice(:,m) == 1;
    mouseFileCt(m,1) = sum(a.fileMouse == m);
    mouseFileTypes = cell2mat(a.parameters(a.fileMouse == m,7));
    mouseFilesIdx = find(a.fileMouse == m);
    mouseFileDays = a.fileDay(a.fileMouse == m);    
    [sortedMouseFileDays,mouseDateIdx] = sort(mouseFileDays); % day for each of that mouse's files
    sortedMouseFiles=mouseFilesIdx(mouseDateIdx);
    
    % initial info side
    a.initinfoside(m,1) =  a.files(find(a.fileMouse == m,1)).infoSide;
    
   if isempty(find(mouseFileTypes == 5,1))
      a.firstChoice(m,1) = 0;
      a.mouseChoiceDays{m} = [];
      a.firstChoiceDay(m,1) = 0;
      choiceDays =[];
   else
     choiceFile = sortedMouseFiles(find(mouseFileTypes(mouseDateIdx) == 5,1,'first'));
     a.firstChoice(m,1) = find(a.file == choiceFile,1); % within all that mouse's trials
     a.mouseChoiceDays{m} = unique(mouseFileDays(mouseFileTypes == 5));
     choiceDays = cell2mat(a.mouseChoiceDays(m));
     a.firstChoiceDay(m,1) = choiceDays(1); 
   end    
    
    if mouseFileCt(m,1) > 1

        mouseInfoSides = a.fileInfoSide(a.fileMouse == m);
        mouseInfoSideDiff = diff(mouseInfoSides(mouseDateIdx));
%         mouseInfoSideDiff = diff(a.fileInfoSide(a.fileMouse == m));
        
        if ~isempty(find(mouseInfoSideDiff) ~= 0)
            reversesIdx = find(mouseInfoSideDiff~=0); %into sorted list
            reverses = mouseDateIdx(reversesIdx); % into original list
            for r = 1:numel(reverses)
                a.reverseFileIdx{m,r} = reversesIdx(r) + 1; % of mouse files
                a.reverseFile{m,r} = reverses(r)+1; % FILE NUMBER, NOT ITS INDEX IF PULL FROM LIST
%                 a.reverseDay{m,r} = mouseFileDays(a.reverseFile{m,r});
                % first day during and first day after
                a.reverseDay{m,r} = sortedMouseFileDays(a.reverseFileIdx{m,r});
            end
            a.prereverseFiles(sortedMouseFiles(a.reverseFileIdx{m,1}:end)) = 0;
                        % FIX first choice file until reverse (all others
                        % set to zero for not relevant)
            a.reverseFiles(sortedMouseFiles(find(mouseFileTypes == 5,1,'first'):a.reverseFileIdx{m,1}-1)) = 1;
            if numel(reverses)>1 % during reverse
                a.reverseFiles(sortedMouseFiles(a.reverseFileIdx{m,1}:a.reverseFileIdx{m,2}-1)) = -1;
            else
                a.reverseFiles(sortedMouseFiles(a.reverseFileIdx{m,1}:end)) = -1;
            end
        else a.reverseDay{m,1} = 0;
        end
    else a.reverseDay{m,1} = 0;
    end   
end

    
a.preReverse = ones(size(a.file,1),1);
a.reverse = zeros(size(a.file,1),1);
for t = 1:size(a.file,1)
    a.preReverse(t,1) = a.prereverseFiles(a.file(t));
    a.reverse(t,1) = a.reverseFiles(a.file(t));
end

% NO LONGER USED??    
for m = 1:a.mouseCt
    ok = a.mice(:,m) == 1;
    okidx = find(ok);
    [~,sortidx] = sort(a.mouseDay(ok==1));
    oksorted = okidx(sortidx);
    mouseReverse = [];
    mousePrereverse = [];
    mouseTypes = [];
    
    mouseReverse = a.reverse(oksorted); % can be out of order!!
    mousePrereverse = a.preReverse(oksorted);
    mouseTypes = a.choiceTypeCorr(oksorted);
    
    if isempty(find(mouseReverse == -1,1))
       a.mouseReverseDays{m} = [];
       a.firstReverse(m,1) = 0;
       a.firstReverseChoice(m,1) = 0; % if empty
       a.lastReverse(m,1) = 0;
       reverseDays = [];       
       a.reverseChoiceDays(m) = 0;
       a.reverseTrainingDays(m) = 0;
       a.firstReverseInChoiceTrials(m,1) = 0;
    else
       a.mouseReverseDays{m} = unique(a.mouseDay(a.reverse == -1 & ok));
       % NOT NECESSARILY CORRECT WITHOUT SORTING
       a.firstReverse(m,1) = find(mouseReverse == -1,1,'first'); % within all that mouse's trials
       a.firstReverseChoice(m,1) = find(mouseTypes == 1 & mouseReverse == -1,1);
       a.lastReverse(m,1) = find(mousePrereverse == 0,1,'last');
       reverseDays = a.mouseReverseDays{m};
       choiceDays = cell2mat(a.mouseChoiceDays(m));
       a.reverseChoiceDays(m) = numel(choiceDays(ismember(a.mouseChoiceDays{m},a.mouseReverseDays{m})));
       a.reverseTrainingDays(m) = numel(reverseDays(~ismember(a.mouseReverseDays{m},a.mouseChoiceDays{m})));
       a.firstReverseInChoiceTrials(m,1) = find(a.preReverse==0 & ok,1);
    end  
end

a.trialsPreReverse = a.firstReverse - a.firstChoice;
a.choiceDaysPreReverse = cell2mat(a.reverseDay(:,1)) - a.firstChoiceDay;
a.trialsReverseTraining = a.firstReverseChoice - a.firstReverse;
a.trialsReverseWithChoices = a.lastReverse - a.firstReverseChoice;

%% INFOSIDE

for i = 1:size(a.file,1)
   a.infoSide(i,1) = a.files(a.file(i)).infoSide;
end

a.initinfoside_info = -ones(a.corrTrialCt,1); % initinfoside_info all trials. 1 if initinfoside, -1 if reversed
a.initinfoside_side = ones(a.corrTrialCt,1); % initinfoside_side all trials

for m = 1:a.mouseCt
    ok = a.mice(:,m) == 1;
    a.initinfoside_info(a.infoSide == a.initinfoside(m) & ok == 1) = 1;
end

%% CHOICES

% MAKE THESE INCLUDE REVERSE, THEN CAN DO AVERAGES AND LIMIT TO LAST X
% TRIALS/DAYS

a.choice_all = a.choiceCorr; % choice relative to initial info side, all trials
reverseFlag = a.initinfoside_info == -1;
a.choice_all(reverseFlag) = ~a.choice_all(reverseFlag);


for m = 1:a.mouseCt
   ok = a.mice(:,m) == 1 & a.choiceTypeCorr == 1;
   a.choiceAllbyMouse{m} = a.choiceCorr(ok);
   a.choiceAllTrialCt(m,1) = numel(a.choiceAllbyMouse{m});
   a.choicebyMouse{m} = a.choiceCorr(ok & a.preReverse == 1); % preReverse
   a.choiceTrialCt(m,1) = numel(a.choicebyMouse{m});
   a.cumChoiceByMouse{m} = cumsum(a.choicebyMouse{m});
   a.choiceRxnByMouse{m} = a.rxn(ok & a.preReverse == 1);
   a.choiceEarlyLicksByMouse{m} = a.earlyLicks(ok & a.preReverse == 1); % preReverse
   a.choiceAnticLicksByMouse{m} = a.betweenLicks(ok & a.preReverse == 1); % preReverse
   a.choiceRewardByMouse{m} = a.rewardFlag(ok & a.preReverse == 1); % preReverse
   a.choiceAllRxnByMouse{m} = a.rxn(ok);
   a.choiceAllEarlyLicksByMouse{m} = a.earlyLicks(ok);
   a.choiceAllAnticLicksByMouse{m} = a.betweenLicks(ok);
   a.choiceAllRewardByMouse{m} = a.rewardFlag(ok);
   a.preReverseByMouse{m} = a.preReverse(ok);
   a.reverseByMouse{m} = a.reverse(ok);
   a.choiceIISByMouse{m} = a.choice_all(ok);   
end

%% CURRENT AND CHOICE AND REVERSED AND FSM MICE

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
a.completeMice = find(~ismember(a.mouseList,a.currentMice));
a.completeMouseList = a.mouseList(a.completeMice);
if ~isempty(a.choiceMice)    
    currentChoiceFlag = ismember(a.currentMiceNums,a.choiceMice);
    a.currentChoiceMice = a.currentMiceNums(currentChoiceFlag);
    if sum(a.currentChoiceMice)>0
        a.currentChoiceMiceList = a.mouseList(a.currentChoiceMice);
    else
        a.currentChoiceMiceList  = [];
    end
else
    a.currentChoiceMice = [];
    a.currentChoiceMiceList = [];
end

if isfield(a,'reverseFile')
    for m = 1:size(a.reverseFile,1)
        if ~isempty(cell2mat(a.reverseFile(m,1)))
            a.reverseMice(m,1) = 1;
        else a.reverseMice(m,1) = 0;
        end
    end
    a.reverseMice = find(a.reverseMice);
%     a.reverseMice = find(cell2mat(a.reverseFile(:,1))>0);
else
    a.reverseMice = [];
end
a.reverseMiceList = a.mouseList(a.reverseMice);

% FSM mice
a.FSMmice = zeros(a.mouseCt,1);
for m = 1:a.mouseCt
    if sum(a.FSM(a.mice(:,m) == 1)) > 0
        a.FSMmice(m,1) = 1;
    end
end
a.FSMmouseIdx = find(a.FSMmice);

% no reward vs small reward mice
a.noneMice = zeros(a.mouseCt,1);
a.infoSmallRewardTime = [a.files.infoSmallRewardTime];
a.infoRewardProb = [a.files.infoRewardProb];

for m = 1:a.mouseCt  
    if sum(a.infoSmallRewardTime(a.fileMouse == m) == 0 & a.infoRewardProb(a.fileMouse == m) < 100)> 0
        a.noneMice(m,1) = 1;
    end
end

%% ALL PRE-REVERSE CHOICES ALIGNED TO START-ONLY FOR ALIGNING BY REVERSE?

% NO LONGER USED??

% a.choiceByMouse %a.meanChoicebyDay = mean(cell2mat(a.meanDayChoicesOrg),1,'omitnan');
a.maxChoiceTrials = max(a.choiceTrialCt);
a.choiceTrialsOrg = NaN(a.choiceMouseCt,a.maxChoiceTrials);

if a.maxChoiceTrials > 0
    for m = a.choiceMice(1):a.choiceMice(end)   
       a.choiceTrialsOrg(m,1:a.choiceTrialCt(m)) = a.choicebyMouse{m}; 
    end
end

%% ALL CHOICES ALIGNED TO REVERSE START

% NO LONGER USED??

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

%% MEAN CHOICES / STATS AND CHOICE RANGES - FIX

trialsToCount = 300;

if ~isempty(a.choiceMice)
    
    a.meanChoice = NaN(a.choiceMice(a.choiceMouseCt),3);
    a.choiceCI = NaN(a.choiceMice(a.choiceMouseCt),2);
    a.prefCI = NaN(a.choiceMice(a.choiceMouseCt),2);
    a.pref = NaN(a.choiceMice(a.choiceMouseCt),3);
    a.beta = NaN(a.choiceMice(a.choiceMouseCt),2);
    
%     for k = 1:numel(a.reverseMice)
%        m = a.reverseMice(k);
       
   for mm = 1:a.choiceMouseCt
       m = a.choiceMice(mm);
       
       choicesIIS = a.choiceIISByMouse{m}; % includes choice training??
       choices = a.choiceAllbyMouse{m};

       preReverseTrials = find(a.reverseByMouse{m} == 1,trialsToCount,'last');
       [a.pref(m,1),a.prefCI(m,1:2)] = binofit(sum(choicesIIS(preReverseTrials)==1),numel(choicesIIS(preReverseTrials)));

       if ismember(m,a.reverseMice)
         postReverseTrials = find(a.reverseByMouse{m} == -1,trialsToCount,'last'); % during reverse
         [a.pref(m,2),a.prefRevCI(m,1:2)] = binofit(sum(choicesIIS(postReverseTrials)==1),numel(choicesIIS(postReverseTrials)));
         [a.pref(m,4),a.prefRevCI(m,3:4)] = binofit(sum(choices(postReverseTrials)==1),numel(choices(postReverseTrials)));
       end

       ok = a.mice(:,m) == 1 & a.choiceTypeCorr == 1;

       choicePreRev = a.choice_all(ok & a.preReverse == 1);

       [a.meanChoice(m,1),a.choiceCI(m,1:2)] = binofit(sum(choicePreRev==1),numel(choicePreRev));
       
       % FOR FIRST REVERSE
       if ismember(m,a.reverseMice)
           choicePostRev = a.choice_all(ok & a.reverse==-1);
           [a.meanChoice(m,2),a.choiceRevCI(m,1:2)] = binofit(sum(choicePostRev==1),numel(choicePostRev));
           x = [a.initinfoside_side(ok) a.initinfoside_info(ok)];
           y = a.choice_all(ok);
           [~,~,a.stats(m)] = glmfit(x,y,'binomial','link','logit','constant','off');
           a.beta(m,:) = a.stats(m).beta;
           a.betaP(m,:) = a.stats(m).p;
       end
       
       a.meanChoice(m,3) = m;
 
   end

    a.meanChoice = a.meanChoice(a.meanChoice(:,3)>0,:);
    a.choiceCI = a.choiceCI(a.choiceCI(:,1)>0,:);
   
    allChoices = a.choiceCorr(a.choiceCorrTrials & a.preReverse == 1);
    [a.overallPref,a.overallCI] = binofit(sum(allChoices == 1),numel(allChoices));
    clear allChoices;
end

%% SORT BY INFO PREFERENCE
if ~isempty(a.choiceMice)
    [a.sortedChoice,a.sortIdx] = sortrows(a.meanChoice(~isnan(a.meanChoice(:,1)),:),1);
    a.sortedMouseList = a.choiceMiceList(a.sortIdx);
    a.sortedCI = a.choiceCI(a.sortIdx,:);

    % STATS

    a.icp_all = a.sortedChoice(:,1)*100;
    
%     a.icp_all = a.meanChoice(1:end-1,1)*100;
    
    a.overallP = signrank(a.icp_all-50);
        
end

%% DIFFERENT SIDE VALUES

% things to fix!
% a.values
% a.relValues
% a.mouseValueFinalDays
% a.mouseValueDays
% mouseProbDays

% HARDCODED-->CHANGE!!!!!!!!!!!!!!!
% HARD CODED TO CHANGE
a.doValue = 0;
if a.doValue == 1
    a.valueMiceInfo = [6 7 8 9]; % info side values changed
%     a.valueMiceNoInfo = [16 18 20 21]; % no info side values changed
else
    a.valueMiceInfo = [];
    a.valueMiceNoInfo = [];
end
a.valueMice = [a.valueMiceInfo a.valueMiceNoInfo];
a.valueMiceList = a.mouseList(a.valueMice);
a.valInfoMice = ismember(a.valueMice,a.valueMiceInfo);
a.valNoInfoMice = ismember(a.valueMice,a.valueMiceNoInfo);

% RELATIVE VALUES
for f = 1:a.numFiles
    a.fileValue(f,1) = a.parameters{f,22};
    a.fileValue(f,2) = a.parameters{f,24};
    a.fileValue(f,3) = a.fileValue(f,1) / a.fileValue(f,2); % info relative to rand
end

a.values = unique(a.fileValue(:,1:2));
a.infoValues = unique(a.fileValue(:,1));
a.randValues = unique(a.fileValue(:,2));
a.relValues = unique(a.fileValue(:,3));
a.rowValues = unique(a.fileValue(:,1:2),'rows');
a.rowValues(:,3) = a.rowValues(:,1)./a.rowValues(:,2);

if ~isempty(a.valueMice)
    for mm = 1:numel(a.valueMice)
       m = a.valueMice(mm);
       a.valueMouseFiles{mm,1} = find(a.fileMouse == m);
       if ismember(m,a.valueMiceInfo)
        a.valueMouseValues{mm,1} = a.fileValue(a.fileMouse==m,1);
       else
        a.valueMouseValues{mm,1} = a.fileValue(a.fileMouse==m,2);    
       end
       a.valueMouseRelValues{mm,1} = unique(a.fileValue(a.fileMouse==m,3));
    end

    % file within mouse's files after which value tests start
    % HARDCODED-->CHANGE!!!!!!!!!!!!!!!
     a.valueStarts = [35 40 48 50 57 59 77 54];


    % FIND LAST DAY AT EACH VALUE FOR EACH MOUSE
    for mm = 1:numel(a.valueMice)
       m = a.valueMice(mm); 
       allMouseValueFiles = a.valueMouseFiles{mm,1};
       mouseValueFiles = allMouseValueFiles(a.valueStarts(mm):end);
       allMouseValues = a.valueMouseValues{mm,1};
       mouseValues = allMouseValues(a.valueStarts(mm):end);
       a.mouseValueDays{mm,1} = a.fileDay(mouseValueFiles);
       a.mouseValueChangeFiles{mm,1}=mouseValueFiles(find(diff(mouseValues)~=0));
       % NOTE: choosing entire day from file before value changed
       a.mouseValueChangeDays{mm,1} = a.fileDay(a.mouseValueChangeFiles{mm,1});
       mouseValueChangeDays = a.mouseValueChangeDays{mm,1};
       a.mouseValueChangeValues{mm,1} = a.fileValue(a.mouseValueChangeFiles{mm,1},3);
       mouseValueChangeValues = a.mouseValueChangeValues{mm,1};
       for vv = 1:numel(a.relValues)
           v = a.relValues(vv);
           a.mouseValueFinalDays{mm,vv} = mouseValueChangeDays(mouseValueChangeValues == v);
       end
    end

    % Can pull daySummary.percentInfo for all value days (course of value
    % tradeoffs)

    %% CHOICES ON MOUSE VALUE FINAL DAYS (eventually trials of 2 days per value per mouse)

    for mm = 1:numel(a.valueMice)
       m = a.valueMice(mm);
       for vv = 1:numel(a.relValues)
           v = a.relValues(vv);
           days = a.mouseValueFinalDays{mm,vv};
           a.valueChoiceTrials{mm,vv} = a.choice_all(ismember(a.mouseDay,days) & a.mice(:,m) == 1 & a.choiceCorrTrials == 1);
           a.valChoiceMeanbyMouse(mm,vv) = nanmean(a.valueChoiceTrials{mm,vv});
           a.valChoiceSEMbyMouse(mm,vv) = sem(a.valueChoiceTrials{mm,vv});
       end
    end

    %% OVERALL CHOICES BY AMOUNT

    for vv = 1:numel(a.relValues)
        v = a.relValues(vv);
        a.valChoices{vv,1} = vertcat(a.valueChoiceTrials{:,vv});
        % info vs no info changed
        a.valChoices{vv,2} = vertcat(a.valueChoiceTrials{a.valInfoMice,vv});
    %     a.valChoices{vv,3} = vertcat(a.valueChoiceTrials{a.valNoInfoMice,vv});
        a.choiceByAmtMean(vv,1) = nanmean(a.valChoices{vv,1});
        a.choiceByAmtMean(vv,2) = nanmean(a.valChoices{vv,2});
    %     a.choiceByAmtMean(vv,3) = nanmean(a.valChoices{vv,3});
        a.choiceByAmtSEM(vv,1) = sem(a.valChoices{vv,1});
        a.choiceByAmtSEM(vv,2) = sem(a.valChoices{vv,2});
    %     a.choiceByAmtSEM(vv,3) = sem(a.valChoices{vv,3});

        [a.prefByAmt(vv,1),a.prefByAmtCI(vv,1:2)]=binofit(sum(a.valChoices{vv,1}),numel(a.valChoices{vv,1}));
        [a.prefByAmt(vv,2),a.prefByAmtCI(vv,3:4)]=binofit(sum(a.valChoices{vv,2}),numel(a.valChoices{vv,2}));
    %     [a.prefByAmt(vv,3),a.prefByAmtCI(vv,4:5)]=binofit(sum(a.valChoices{vv,3}),numel(a.valChoices{vv,3}));

    end

    %% HARDCODED OVERALL BY AMOUNT BY PROB

    for vv = 1:numel(a.relValues)
       v = a.relValues(vv);
        a.valChoicesProb{vv,1} = vertcat(a.valueChoiceTrials{1:2,vv});
        a.valChoicesProb{vv,2} = vertcat(a.valueChoiceTrials{3:4,vv});
    %     a.valChoicesProb{vv,3} = vertcat(a.valueChoiceTrials{5:8,vv});
        a.choiceByAmtProbMean(vv,1) = nanmean(a.valChoicesProb{vv,1});
        a.choiceByAmtProbMean(vv,2) = nanmean(a.valChoicesProb{vv,2});
    %     a.choiceByAmtProbMean(vv,3) = nanmean(a.valChoicesProb{vv,3});
        a.choiceByAmtProbSEM(vv,1) = sem(a.valChoicesProb{vv,1});
        a.choiceByAmtProbSEM(vv,2) = sem(a.valChoicesProb{vv,2});
    %     a.choiceByAmtProbSEM(vv,3) = sem(a.valChoicesProb{vv,3});
    end
end

%%
%  mean/SEM only the last 100 trials of that value!! no, ALL? What about
% repeated values?
% for mm = 1:numel(a.valueMice)
%     m = a.valueMice(mm);
%     mouseValFiles = a.valueFile{m,1};
%     mouseValDays = a.valueDays{m,1};
% %     mouseFileDays = a.fileDay(a.fileMouse == m);
%     for vv = 1:numel(a.values)
%        v = a.values(vv);
%        a.valFiles{mm,vv} = a.valueFileCat(a.valChange(:,1) == v & a.valChangeMouse(:,1) == m);
%        
%        currValFiles = find(ismember(mouseValFiles,a.valFiles{mm,vv}));
%        currValDays = mouseValDays(currValFiles);
%        currValDiff = [1 diff(currValDays)];
%        valSplit = find(currValDiff > 1);
%        if ~isempty(valSplit)
%            firstValDay = currValDays(valSplit-1);
%            secondValDay = currValDays(end);
%            valDays = [firstValDay, secondValDay];
%        elseif ~isempty(currValDays)
%            valDays = currValDays(end);
%        else
%            valDays = [];
%        end
%        % want to find last day in first string and last day in second
%        % string
%        
%        % get actual days/file numbers for valDays (by mouse) to get choices
%        
%        a.valChoiceFiles{mm,vv} = find(ismember(a.fileDay,valDays)&a.fileMouse==m);
%        a.valChoices{mm,vv} = a.choice_all(sum(a.file == a.valChoiceFiles{mm,vv},2)==1);
% %        a.valChoices{mm,vv} = a.choice_all(sum(a.file == a.valFiles{mm,vv},2)==1); % takes all choices from all files with those values
%        
%        currentValChoices = a.valChoices{mm,vv};
%        if numel(currentValChoices) >= 100
% %            a.valChoiceMeanbyMouse(mm,vv) = mean(currentValChoices(end-100:end));
% %            a.valChoiceSEMbyMouse(mm,vv) = sem(currentValChoices(end-100:end));
% %            a.choiceByAmtByMouse{mm,vv} = currentValChoices(end-99:end);
%            a.valChoiceMeanbyMouse(mm,vv) = mean(currentValChoices);
%            a.valChoiceSEMbyMouse(mm,vv) = sem(currentValChoices);
%            a.choiceByAmtByMouse{mm,vv} = currentValChoices;           
%        else
%            a.valChoiceMeanbyMouse(mm,vv) = NaN;
%            a.valChoiceSEMbyMouse(mm,vv) = NaN;
%            a.choiceByAmtByMouse{mm,vv} = NaN;
%        end
%     end
% end
% 
% for vv = 1:numel(a.values)
%    v = a.values(vv);
%    a.choiceByAmt{v,1} = cell2mat(a.choiceByAmtbyFile(a.valChange(:,1)==v,1));
%    currentChoiceByAmt = a.choiceByAmt{v,1};
% %    a.choiceByAmtMean(v,1) = mean(a.choiceByAmt{v,1});
% %    a.choiceByAmtSEM(v,1) = sem(a.choiceByAmt{v,1});
% end
% 
% for vv = 1:numel(a.values)
%     v = a.values(vv);
%     a.choiceByAmtMean(v,1) = nanmean(cell2mat(a.choiceByAmtByMouse(:,v)));
%     a.choiceByAmtSEM(v,1) = sem(cell2mat(a.choiceByAmtByMouse(:,v)));
% end

%% TRIAL TYPE COUNTS BY MOUSE BY DAY - UNUSED?

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

% a.odor2corr = a.odor2(a.correct);

for t = 1:a.corrTrialCt
    trialFile = a.file(t);
    a.odorAtrials(t,1) = a.odor2(t) == a.odorA(trialFile);
    a.odorBtrials(t,1) = a.odor2(t) == a.odorB(trialFile);
    a.odorCtrials(t,1) = a.odor2(t) == a.odorC(trialFile);
    a.odorDtrials(t,1) = a.odor2(t) == a.odorD(trialFile);
end

for m = 1:a.mouseCt
    for d = 1:a.mouseDayCt(m)
        ok = [];
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
        
        a.ARewards(m,d) = sum(a.rewardCorr(a.odorAtrials & ok));
        a.BRewards(m,d) = sum(a.rewardCorr(a.odorBtrials & ok));
        a.CRewards(m,d) = sum(a.rewardCorr(a.odorCtrials & ok));
        a.DRewards(m,d) = sum(a.rewardCorr(a.odorDtrials & ok));
        
        a.randBigRewards(m,d) = sum(a.rewardCorr(a.randBig & ok));
        a.randSmallRewards(m,d) = sum(a.rewardCorr(a.randSmall & ok));
    end
end


%% EARLY LICKS AND REACTION SPEED BY REVERSAL

% NEED TO FINISH

% use trials to count

a.rxnSpeed = 1./a.rxn;

a.goodRxn = a.rxn<8000 & a.rxn>100;

%% RXN and LICK INDEX RELATIVE TO INITIAL INFO SIDE


% a.initInfoLicks = mean(a.earlyLicks(a.initinfoside_info == 1));
% a.initNoInfoLicks = mean(a.earlyLicks(a.initinfoside_info == -1));
% a.earlyLickIdx = (a.initInfoLicks - a.initNoInfoLicks)/(a.initInfoLicks + a.initNoInfoLicks);
% 
% for m=1:a.mouseCt
%    ok = a.mice(:,m) == 1 & a.forcedCorrTrials == 1;
%    % pre-reverse, INFO
%    a.preRevEarlyLicks(m,1) = mean(a.earlyLicks(a.choice_all == 1 & a.preReverse == 1 & ok == 1));
%    a.preRevRxnSpeed(m,1) = mean(a.rxn(a.choice_all == 1 & a.preReverse == 1 & ok == 1));
%    % pre-reverse, NO INFO
%    a.preRevEarlyLicks(m,2) = mean(a.earlyLicks(a.choice_all == 0 & a.preReverse == 1 & ok == 1));
%    a.preRevRxnSpeed(m,2) = mean(a.rxn(a.choice_all == 0 & a.preReverse == 1 & ok == 1));
%    % pre-reverse diff p-val
%    [~,a.preRevEarlyLicks(m,3)] = ttest2(a.earlyLicks(a.choice_all == 1 & a.preReverse == 1 & ok == 1),a.earlyLicks(a.choice_all == 0 & a.preReverse == 1 & ok == 1));
%    [~,a.preRevRxnSpeed(m,3)] = ttest2(a.rxn(a.choice_all == 1 & a.preReverse == 1 & ok == 1),a.rxn(a.choice_all == 0 & a.preReverse == 1 & ok == 1));
%    % post-reverse, INITIAL INFO
%    a.postRevEarlyLicks(m,1) = mean(a.earlyLicks(a.choice_all == 1 & reverseFlag & ok == 1));
%    a.postRevRxnSpeed(m,1) = mean(a.rxn(a.choice_all == 1 & reverseFlag & ok == 1));
%    % post-reverse, INITIAL NO INFO
%    a.postRevEarlyLicks(m,2) = mean(a.earlyLicks(a.choice_all == 0 & reverseFlag & ok == 1));
%    a.postRevRxnSpeed(m,2) = mean(a.rxn(a.choice_all == 0 & reverseFlag & ok == 1));
%    % post-reverse diff p-val
%    [~,a.postRevEarlyLicks(m,3)] = ttest2(a.earlyLicks(a.choice_all == 1 == 1 & reverseFlag & ok == 1),a.earlyLicks(a.choice_all == 0 & reverseFlag & ok == 1));
%    [~,a.postRevRxnSpeed(m,3)] = ttest2(a.rxn(a.choice_all == 1 == 1 & reverseFlag & ok == 1),a.rxn(a.choice_all == 0 & reverseFlag & ok == 1));
%    
%    % pre-reverse
%    a.earlyLickIdx(m,1) = (a.preRevEarlyLicks(m,1)-a.preRevEarlyLicks(m,2))/(a.preRevEarlyLicks(m,1)+a.preRevEarlyLicks(m,2));
%    a.rxnSpeedIdx(m,1) = (a.preRevRxnSpeed(m,1)-a.preRevRxnSpeed(m,2))/(a.preRevRxnSpeed(m,1)+a.preRevRxnSpeed(m,2));
%    % post-reverse
%    a.earlyLickIdx(m,2) = (a.postRevEarlyLicks(m,1)-a.postRevEarlyLicks(m,2))/(a.postRevEarlyLicks(m,1)+a.postRevEarlyLicks(m,2));
%    a.rxnSpeedIdx(m,2) = (a.postRevRxnSpeed(m,1)-a.postRevRxnSpeed(m,2))/(a.postRevRxnSpeed(m,1)+a.postRevRxnSpeed(m,2)); 
% end

%%
% RELATIVE TO CURRENT INFO SIDE
for m=1:a.mouseCt
   ok1 = a.mice(:,m) == 1 & a.infoForcedCorr == 1 & a.preReverse == 1;
   okInfoPreRev = find(ok1==1,500,'last');
   ok2 = a.mice(:,m) == 1 & a.randForcedCorr == 1 & a.preReverse == 1;
   okRandPreRev = find(ok2==1,500,'last');
   ok3 = a.mice(:,m) == 1 & a.infoForcedCorr == 1 & a.preReverse == 0;
   okInfoPostRev = find(ok3==1,500,'last');
   ok4 = a.mice(:,m) == 1 & a.randForcedCorr == 1 & a.preReverse == 0;
   okRandPostRev = find(ok4==1,500,'last');
   % pre-reverse, INFO
   a.preRevEarlyLicks(m,1) = mean(a.earlyLicks(okInfoPreRev));
   a.preRevRxnSpeed(m,1) = mean(a.rxnSpeed(okInfoPreRev));
   a.preRevRxn(m,1) = mean(a.rxn(okInfoPreRev));
   % pre-reverse, NO INFO
   a.preRevEarlyLicks(m,2) = mean(a.earlyLicks(okRandPreRev));
   a.preRevRxnSpeed(m,2) = mean(a.rxnSpeed(okRandPreRev));
   a.preRevRxn(m,2) = mean(a.rxn(okRandPreRev));
   % pre-reverse diff p-val
   [~,a.preRevEarlyLicks(m,3)] = ttest2(a.earlyLicks(okInfoPreRev),a.earlyLicks(okRandPreRev));
   [~,a.preRevRxnSpeed(m,3)] = ttest2(a.rxnSpeed(okInfoPreRev),a.rxnSpeed(okRandPreRev));
   % post-reverse, INFO
   a.postRevEarlyLicks(m,1) = mean(a.earlyLicks(okInfoPostRev));
   a.postRevRxnSpeed(m,1) = mean(a.rxnSpeed(okInfoPostRev));
   % post-reverse, NO INFO
   a.postRevEarlyLicks(m,2) = mean(a.earlyLicks(okRandPostRev));
   a.postRevRxnSpeed(m,2) = mean(a.rxnSpeed(okRandPostRev));
   % post-reverse diff p-val
   [~,a.postRevEarlyLicks(m,3)] = ttest2(a.earlyLicks(okInfoPostRev),a.earlyLicks(okRandPostRev));
   [~,a.postRevRxnSpeed(m,3)] = ttest2(a.rxnSpeed(okInfoPostRev),a.rxnSpeed(okRandPostRev));
   
   % pre-reverse
   a.earlyLickIdx(m,1) = (a.preRevEarlyLicks(m,1)-a.preRevEarlyLicks(m,2))/(a.preRevEarlyLicks(m,1)+a.preRevEarlyLicks(m,2));
   a.rxnSpeedIdx(m,1) = (a.preRevRxnSpeed(m,1)-a.preRevRxnSpeed(m,2))/(a.preRevRxnSpeed(m,1)+a.preRevRxnSpeed(m,2));
   % post-reverse
   a.earlyLickIdx(m,2) = (a.postRevEarlyLicks(m,1)-a.postRevEarlyLicks(m,2))/(a.postRevEarlyLicks(m,1)+a.postRevEarlyLicks(m,2));
   a.rxnSpeedIdx(m,2) = (a.postRevRxnSpeed(m,1)-a.postRevRxnSpeed(m,2))/(a.postRevRxnSpeed(m,1)+a.postRevRxnSpeed(m,2)); 
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
            a.daySummary.finalOutcome{m,d} = a.finalOutcome(a.mouseDayAll == d & a.miceAll(:,m) == 1);
        end
        
        % OTHER (correct trials)
        ok = []; okAll = [];
        ok = a.mouseDay == d & a.mice(:,m) == 1;
        okAll = a.mouseDayAll == d & a.miceAll(:,m) == 1;
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
        if sum(ok)>0
            lastFileIdx = find(ok,1,'last');
            a.daySummary.infoBigAmt{m,d} = a.parameters{a.file(lastFileIdx),22};
            a.daySummary.randBigAmt{m,d} = a.parameters{a.file(lastFileIdx),24};
            a.daySummary.infoBigProb{m,d} = a.parameters{a.file(lastFileIdx),26};
            a.daySummary.randBigProb{m,d} = a.parameters{a.file(lastFileIdx),27};
            a.daySummary.rewardDelay{m,d} = a.parameters{a.file(lastFileIdx),21};             
        else
            lastFileIdx = find(okAll,1,'last');
            a.daySummary.infoBigAmt{m,d} = a.parameters{a.fileAll(lastFileIdx),22};
            a.daySummary.randBigAmt{m,d} = a.parameters{a.fileAll(lastFileIdx),24};
            a.daySummary.infoBigProb{m,d} = a.parameters{a.fileAll(lastFileIdx),26};
            a.daySummary.randBigProb{m,d} = a.parameters{a.fileAll(lastFileIdx),27};
            a.daySummary.rewardDelay{m,d} = a.parameters{a.fileAll(lastFileIdx),21};             
        end         
        a.daySummary.totalRewards{m,d} = sum(a.rewardCorr(ok));
        a.daySummary.totalTrials{m,d} = sum([a.daySummary.infoBig{m,d},a.daySummary.infoSmall{m,d},a.daySummary.randBig{m,d},a.daySummary.randSmall{m,d}]);
        a.daySummary.percentInfo{m,d} = nanmean(a.infoCorrTrials(ok & a.choiceCorrTrials == 1 & a.fileTrialTypes == 5));
        a.daySummary.percentIIS{m,d} = nanmean(a.choice_all(ok & a.choiceTypeCorr == 1 & a.fileTrialTypes == 5));
        a.daySummary.rxnInfoForced{m,d} = nanmean(a.rxn(a.infoForcedCorr & ok));
        a.daySummary.rxnInfoChoice{m,d} = nanmean(a.rxn(a.infoChoiceCorr & ok));
        a.daySummary.rxnRandForced{m,d} = nanmean(a.rxn(a.randForcedCorr & ok));
        a.daySummary.rxnRandChoice{m,d} = nanmean(a.rxn(a.randChoiceCorr & ok));
        a.daySummary.rxnSpeedIdx{m,d} = (nanmean(a.rxnSpeed(ok & a.forcedCorrTrials == 1 & a.choice_all == 1)) - nanmean(a.rxnSpeed(ok & a.forcedCorrTrials == 1 & a.choice_all == 0)))/(nanmean(a.rxnSpeed(ok & a.forcedCorrTrials == 1 & a.choice_all == 1)) + nanmean(a.rxnSpeed(ok & a.forcedCorrTrials == 1 & a.choice_all == 0)));
        a.daySummary.infoBigLicks{m,d} = a.AlicksBetween(m,d)/sum(a.odorAtrials & ok);
        a.daySummary.infoSmallLicks{m,d} = a.BlicksBetween(m,d)/sum(a.odorBtrials & ok);
        a.daySummary.randCLicks{m,d} = a.ClicksBetween(m,d)/sum(a.odorCtrials & ok);
        a.daySummary.randDLicks{m,d} = a.DlicksBetween(m,d)/sum(a.odorDtrials & ok);
        a.daySummary.earlyLickIdx{m,d} = (nanmean(a.earlyLicks(ok==1 & a.forcedCorrTrials == 1 & a.choice_all == 1)) - nanmean(a.earlyLicks(ok==1 & a.forcedCorrTrials == 1 & a.choice_all == 0)))/(nanmean(a.earlyLicks(ok==1 & a.forcedCorrTrials == 1 & a.choice_all == 1)) + nanmean(a.earlyLicks(ok==1 & a.forcedCorrTrials == 1 & a.choice_all == 0)));
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
        a.daySummary.trialLengthEntryInfoForced{m,d} = nansum(a.trialLengthCenterEntryCorr(a.infoForcedCorr == 1 & ok == 1))/sum(~isnan(a.trialLengthCenterEntryCorr(a.infoForcedCorr == 1 & ok == 1)));
        a.daySummary.trialLengthEntryInfoChoice{m,d} = nansum(a.trialLengthCenterEntryCorr(a.infoChoiceCorr == 1 & ok == 1))/sum(~isnan(a.trialLengthCenterEntryCorr(a.infoChoiceCorr == 1 & ok == 1)));
        a.daySummary.trialLengthEntryRandForced{m,d} = nansum(a.trialLengthCenterEntryCorr(a.randForcedCorr == 1 & ok == 1))/sum(~isnan(a.trialLengthCenterEntryCorr(a.randForcedCorr == 1 & ok == 1)));
        a.daySummary.trialLengthEntryRandChoice{m,d} = nansum(a.trialLengthCenterEntryCorr(a.randChoiceCorr == 1 & ok == 1))/sum(~isnan(a.trialLengthCenterEntryCorr(a.randChoiceCorr == 1 & ok == 1)));        
        a.daySummary.rewardInfoForced{m,d} = sum(a.reward(a.infoForced == 1 & okAll == 1))/sum(a.infoForced(okAll));
        a.daySummary.rewardRandForced{m,d} = sum(a.reward(a.randForced == 1 & okAll == 1))/sum(a.randForced(okAll));
        a.daySummary.rewardChoice{m,d} = sum(a.reward(a.choiceTrials == 1 & okAll == 1))/sum(a.choiceTrials(okAll));
%         a.daySummary.rewardInfoForced{m,d} = sum(a.rewardCorr(a.infoForcedCorr == 1 & ok == 1))/sum(a.infoForcedCorr(ok));
%         a.daySummary.rewardInfoChoice{m,d} = sum(a.rewardCorr(a.infoChoiceCorr == 1 & ok == 1))/sum(a.infoChoiceCorr(ok));
%         a.daySummary.rewardRandForced{m,d} = sum(a.rewardCorr(a.randForcedCorr == 1 & ok == 1))/sum(a.randForcedCorr(ok));
%         a.daySummary.rewardRandChoice{m,d} = sum(a.rewardCorr(a.randChoiceCorr == 1 & ok == 1))/sum(a.randChoiceCorr(ok));
        a.daySummary.rewardRateInfoForced{m,d} = sum(a.reward(a.infoForced == 1 & okAll == 1)) / nansum(a.trialLengthCenterEntry(a.infoForced == 1 & okAll == 1))*1000;
        a.daySummary.rewardRateRandForced{m,d} = sum(a.reward(a.randForced == 1 & okAll == 1)) / nansum(a.trialLengthCenterEntry(a.randForced == 1 & okAll == 1))*1000;
        a.daySummary.rewardRateChoice{m,d} = sum(a.reward(a.choiceTrials == 1 & okAll == 1)) / nansum(a.trialLengthCenterEntry(a.choiceTrials == 1 & okAll == 1))*1000;
        a.daySummary.rewardRateInfo{m,d} = sum(a.reward(a.choice(:,4) == 1 & okAll == 1)) / (nansum(a.trialLengthCenterEntry(a.choice(:,4) == 1 & okAll == 1))/1000/60);
        a.daySummary.rewardRateRand{m,d} = sum(a.reward(a.choice(:,4) == 0 & okAll == 1)) / (nansum(a.trialLengthCenterEntry(a.choice(:,4) == 0 & okAll == 1))/1000/60);
%         a.daySummary.rewardRateInfoForced{m,d} = sum(a.rewardCorr(a.infoForcedCorr == 1 & ok == 1)) / nansum(a.trialLengthCenterEntryCorr(a.infoForcedCorr == 1 & ok == 1))*1000;
%         a.daySummary.rewardRateInfoChoice{m,d} = sum(a.rewardCorr(a.infoChoiceCorr == 1 & ok == 1)) / nansum(a.trialLengthCenterEntryCorr(a.infoChoiceCorr == 1 & ok == 1))*1000;
%         a.daySummary.rewardRateRandForced{m,d} = sum(a.rewardCorr(a.randForcedCorr == 1 & ok == 1)) / nansum(a.trialLengthCenterEntryCorr(a.randForcedCorr == 1 & ok == 1))*1000;
%         a.daySummary.rewardRateRandChoice{m,d} = sum(a.rewardCorr(a.randChoiceCorr == 1 & ok == 1)) / nansum(a.trialLengthCenterEntryCorr(a.randChoiceCorr == 1 & ok == 1))*1000;        

    end
end

for mm = 1:sum(a.FSMmice)
    m=a.FSMmouseIdx(mm);
    if ismember(m,find(a.noneMice))
        a.infoCorrCodes = [11 13 14];
        a.infoIncorrCodes = [10 12 15];
        a.randCorrCodes = [17 19];
        a.randIncorrCodes = [16 18 20 21];
        a.choiceCorrCodes = [2 4 5 6 8];
        a.choiceIncorrCodes = [1 3 7 9];        
    else
        a.infoCorrCodes = [11 13];
        a.infoIncorrCodes = [10 12 14 15];
        a.randCorrCodes = [17 19];
        a.randIncorrCodes = [16 18 20 21];
        a.choiceCorrCodes = [2 4 6 8];
        a.choiceIncorrCodes = [1 3 5 7 9];  
%         a.infoIncorrCodes = [10 12 15]; 
    end
    for d = 1:a.mouseDayCt(m)
        outcomes = a.daySummary.finalOutcome{m,d};
        a.infoCorr{m,d} = sum(ismember(outcomes,a.infoCorrCodes))/(sum(ismember(outcomes,a.infoCorrCodes))+sum(ismember(outcomes,a.infoIncorrCodes)));
        a.infoIncorr{m,d} = sum(ismember(outcomes,a.infoIncorrCodes))/(sum(ismember(outcomes,a.infoCorrCodes))+sum(ismember(outcomes,a.infoIncorrCodes)));
        a.randCorr{m,d} = sum(ismember(outcomes,a.randCorrCodes))/(sum(ismember(outcomes,a.randCorrCodes))+sum(ismember(outcomes,a.randIncorrCodes)));
        a.randIncorr{m,d} = sum(ismember(outcomes,a.randIncorrCodes))/(sum(ismember(outcomes,a.randCorrCodes))+sum(ismember(outcomes,a.randIncorrCodes)));
        a.choiceIncorr{m,d} = sum(ismember(outcomes,a.choiceIncorrCodes))/(sum(ismember(outcomes,a.choiceCorrCodes))+sum(ismember(outcomes,a.choiceIncorrCodes)));
    end
end

%%
for m = 1:a.mouseCt
    infoBigProb = [];
    randBigProb = [];
    for d = 1:a.mouseDayCt(m)
        infoBigProb(d) = a.daySummary.infoBigProb{m,d};
        randBigProb(d) = a.daySummary.randBigProb{m,d};
    end
    a.infoBigProbs{m,1} = infoBigProb;
    a.randBigProbs{m,1} = randBigProb;
end

%% DAYS AROUND REVERSES

if ~isempty(a.reverseMice)

    a.reversalDays = NaN(numel(a.reverseMice),3);

    for m = 1:numel(a.reverseMice)
        mm=a.reverseMice(m);
        a.reversalDays(m,1) = a.reverseDay{mm,1}-1; % day prior to 1st reversal
        if size(a.reverseDay(mm,:),2) > 1
            if ~isempty(a.reverseDay{mm,2})
            a.reversalDays(m,2) = a.reverseDay{mm,2}-1; % day prior to second reversal

            % last day of second reversal (either r+3/last day or last day before get
            % ready for values)
            if ~ismember(mm,a.valueMice)
                if a.reverseDay{mm,2}+3 >= a.mouseDayCt(mm)
                    a.reversalDays(m,3) = a.mouseDayCt(mm);
                else
                    a.reversalDays(m,3) = a.reverseDay{mm,2}+3;
                end
            else
                mmm = find(a.valueMice == mm);
                mouseValueDays = a.mouseValueDays{mmm,1};
                if ismember(mmm,a.valueMiceInfo)
                    mouseProbDays = a.infoBigProbs{mm,1};
                else
                    mouseProbDays = a.randBigProbs{mm,1};
                end
                mouseValues = mouseProbDays(mouseValueDays);
                if sum(mouseValues > 25) > 0
                    a.reversalDays(m,3) = find(mouseProbDays==25,1,'last');
                else
                    a.reversalDays(m,3) = mouseValueDays(1);
                end
              end
            end
        end
    end

    %% CHOICE, RXN SPEED, EARLY LICKS, AND REWARD RATE AROUND REVERSALS

    a.reversalPrefs = NaN(numel(a.reverseMice),3);
    a.reversalRxn = NaN(numel(a.reverseMice),3);
    a.reversalLicks = NaN(numel(a.reverseMice),3);
    a.reversalMultiPrefs = NaN(numel(a.reverseMice),8);
    for m = 1:numel(a.reverseMice)
        mm = a.reverseMice(m);
        for n = 1:3
            if ~isnan(a.reversalDays(m,n))
                day = a.reversalDays(m,n);
            else
                if n>1 & a.mouseDayCt(mm)>a.reversalDays(m,n-1)
%                     day = a.reversalDays(m,n-1)+3;
                    day = a.mouseDayCt(mm);
                else
                    day = 0;
                end
            end
            if ~isnan(a.reversalDays(m,n))
                a.reversalPrefs(m,n) = a.daySummary.percentIIS{mm,day};
                if n == 1
                    for k = 1:4
%                         if ~isempty(a.daySummary.percentIIS{mm,a.reversalDays(m,n)+k-1})
                        if a.mouseDayCt(mm)>(day+k-1)
                            a.reversalMultiPrefs(m,k) = a.daySummary.percentIIS{mm,a.reversalDays(m,n)+k-1};
                        end
                    end
                elseif n==2
                    for k = 1:4
                        if ~isempty(a.daySummary.percentIIS{mm,a.reversalDays(m,n)+k-1})
                            a.reversalMultiPrefs(m,k+4) = a.daySummary.percentIIS{mm,a.reversalDays(m,n)+k-1};
                        end
                    end
                end
            else
                if n>1 & day>0
                    a.reversalPrefs(m,n) = a.daySummary.percentIIS{mm,day};
                end
            end
            if day > 0
    %             if isnan(a.daySummary.rxnSpeedIdx{m,a.reversalDays(m,n)})
    %                 a.reversalRxn(m,n) = a.daySummary.rxnSpeedIdx{m,a.reversalDays(m,n)-1};
    %             else
                    a.reversalRxn(m,n) = a.daySummary.rxnSpeedIdx{mm,day};
                    a.reversalRxnInfo(m,n) = a.daySummary.rxnInfoForced{mm,day};
                    a.reversalRxnRand(m,n) = a.daySummary.rxnRandForced{mm,day};
    %             end
    %             if isnan(a.daySummary.earlyLickIdx{m,a.reversalDays(m,n)})
    %                 a.reversalLicks(m,n) = a.daySummary.earlyLickIdx{m,a.reversalDays(m,n)-1};
    %             else
                    a.reversalLicks(m,n) = a.daySummary.earlyLickIdx{mm,day};
                    a.reversalInfoBigEarlyLicks(m,n) = a.daySummary.infoBigLicksEarly{mm,day};
                    a.reversalInfoSmallEarlyLicks(m,n) = a.daySummary.infoSmallLicksEarly{mm,day};
                    a.reversalRandCEarlyLicks(m,n) = a.daySummary.randCLicksEarly{mm,day};
                    a.reversalRandDEarlyLicks(m,n) = a.daySummary.randDLicksEarly{mm,day};
                    a.reversalInfoBigLicks(m,n) = a.daySummary.infoBigLicks{mm,day};
                    a.reversalInfoSmallLicks(m,n) = a.daySummary.infoSmallLicks{mm,day};
                    a.reversalRandCLicks(m,n) = a.daySummary.randCLicks{mm,day};
                    a.reversalRandDLicks(m,n) = a.daySummary.randDLicks{mm,day};
    %             end
    %             a.reversalRewardRateIdx(m,n) = (a.daySummary.rewardRateInfoForced{m,a.reversalDays(m,n)}-a.daySummary.rewardRateRandForced{m,a.reversalDays(m,n)})/(a.daySummary.rewardRateInfoForced{m,a.reversalDays(m,n)}+a.daySummary.rewardRateRandForced{m,a.reversalDays(m,n)});
                  if n==2
                    a.reversalRewardRateIdx(m,n) = (a.daySummary.rewardRateRandForced{mm,day}-a.daySummary.rewardRateInfoForced{mm,day});
                    a.reversalRewardRateInfo(m,n) = a.daySummary.rewardRateRand{mm,day};
                    a.reversalRewardRateRand(m,n) = a.daySummary.rewardRateInfo{mm,day};
                  else
                    a.reversalRewardRateIdx(m,n) = (a.daySummary.rewardRateInfoForced{mm,day}-a.daySummary.rewardRateRandForced{mm,day});   
                    a.reversalRewardRateInfo(m,n) = a.daySummary.rewardRateInfo{mm,day};
                    a.reversalRewardRateRand(m,n) = a.daySummary.rewardRateRand{mm,day};
                  end
            end
        end
    end

    %%
    
    if  ~isnan(a.reversalPrefs(:,2))
    
    a.meanReversalMultiPrefs = nanmean(a.reversalMultiPrefs);
    a.SEMReversalMultiPrefs = sem(a.reversalMultiPrefs);
    
%     a.meanReversalMultiPrefs = nanmean(a.reversalMultiPrefs(a.reversalMultiPrefs(:,1)>0.5,:));
%     a.SEMReversalMultiPrefs = sem(a.reversalMultiPrefs(a.reversalMultiPrefs(:,1)>0.5,:));

    a.reversalPrefs_stats = a.reversalPrefs*100;
    a.reversal1P = signrank(a.reversalPrefs_stats(:,1),a.reversalPrefs_stats(:,2));
    if ~isnan(a.reversalPrefs(:,3))
    a.reversal2P = signrank(a.reversalPrefs_stats(:,2),a.reversalPrefs_stats(:,3));
    a.reversalP = signrank(a.reversalPrefs_stats(:,1),a.reversalPrefs_stats(:,3));
    end

    a.reversalRxnP(1,1) = signrank(a.reversalRxn(:,1),a.reversalRxn(:,2));
    if ~isnan(a.reversalPrefs(:,3))
    a.reversalRxnP(1,2) = signrank(a.reversalRxn(:,2),a.reversalRxn(:,3));
    a.reversalRxnP(1,3) = signrank(a.reversalRxn(:,1),a.reversalRxn(:,3));
    end

    a.reversalLicksP(1,1) = signrank(a.reversalLicks(:,1),a.reversalLicks(:,2));
    if ~isnan(a.reversalPrefs(:,3))
    a.reversalLicksP(1,2) = signrank(a.reversalLicks(:,2),a.reversalLicks(:,3));
    a.reversalLicksP(1,3) = signrank(a.reversalLicks(:,1),a.reversalLicks(:,3));
    end

    a.reversalRewardRateP(1,1) = signrank(a.reversalRewardRateIdx(:,1),a.reversalRewardRateIdx(:,2));
    if ~isnan(a.reversalPrefs(:,3))
    a.reversalRewardRateP(1,2) = signrank(a.reversalRewardRateIdx(:,2),a.reversalRewardRateIdx(:,3));
    a.reversalRewardRateP(1,3) = signrank(a.reversalRewardRateIdx(:,1),a.reversalRewardRateIdx(:,3));
    end

    if ~isnan(a.reversalPrefs(:,3))
    for p =1:3
        a.reversalPVals(1,p) = signrank(a.reversalPrefs_stats(:,p)-50);
        a.reversalRxnPVals(1,p) = signrank(a.reversalRxn(:,p));
        a.reversalLicksPVals(1,p) = signrank(a.reversalLicks(:,p));
        a.reversalRewardRatePVals(1,p) = signrank(a.reversalRewardRateIdx(:,p));
    end
    end
    a.reversalRxnInfoRandP(1,1) = signrank(a.reversalRxnInfo(:,1),a.reversalRxnRand(:,1));
    a.reversalRewardRateInfoRandP(1,1) = signrank(a.reversalRewardRateInfo(:,1),a.reversalRewardRateRand(:,1));
    end
end

%% REVERSIBLE PREFERENCES

% a.prefFlag = zeros(size(a.pref));
% a.prefFlag(isnan(a.pref))=NaN;
% a.prefFlag(a.pref>=.5)=1;
a.prefFlag = zeros(size(a.mouseList,1),1);
a.prefFlag([1 3 5 6 13])=1;
a.prefFlag=a.prefFlag==1;

a.reversalPrefFlag = zeros(size(a.reverseMiceList,1),1);
a.reversalPrefFlag([1 3 5 6 11])=1;
a.reversalPrefFlag=a.reversalPrefFlag==1;
a.reversalPrefMice = find(a.reversalPrefFlag);

a.prefMice = find(a.prefFlag);
[~,a.trialMouse,~] = find(a.mice);

a.meanChoiceReal = NaN(a.choiceMice(a.choiceMouseCt),3);
a.choiceCIReal = NaN(a.choiceMice(a.choiceMouseCt),2);
a.prefCIReal = NaN(a.choiceMice(a.choiceMouseCt),2);
a.prefReal = NaN(a.choiceMice(a.choiceMouseCt),3);
a.betaReal= NaN(a.choiceMice(a.choiceMouseCt),2);

for mm = 1:sum(a.prefFlag)
       m = a.prefMice(mm);
       
       choicesIIS = a.choiceIISByMouse{m};
       choices = a.choiceAllbyMouse{m};

       preReverseTrials = find(a.reverseByMouse{m} == 1,trialsToCount,'last');
       [a.prefReal(m,1),a.prefCIReal(m,1:2)] = binofit(sum(choicesIIS(preReverseTrials)==1),numel(choicesIIS(preReverseTrials)));

         postReverseTrials = find(a.reverseByMouse{m} == -1,trialsToCount,'last');
         [a.prefReal(m,2),a.prefRevCIReal(m,1:2)] = binofit(sum(choicesIIS(postReverseTrials)==1),numel(choicesIIS(postReverseTrials)));
         [a.prefReal(m,3),a.prefRevCIReal(m,3:4)] = binofit(sum(choices(postReverseTrials)==1),numel(choices(postReverseTrials)));

       ok = a.mice(:,m) == 1 & a.choiceTypeCorr == 1;

       choicePreRev = a.choice_all(ok & a.preReverse == 1);

       [a.meanChoiceReal(m,1),a.choiceCIReal(m,1:2)] = binofit(sum(choicePreRev==1),numel(choicePreRev));
       

           choicePostRev = a.choice_all(ok & a.reverse==-1);
           [a.meanChoiceReal(m,2),a.choiceRevCIReal(m,1:2)] = binofit(sum(choicePostRev==1),numel(choicePostRev));
           x = [a.initinfoside_side(ok) a.initinfoside_info(ok)];
           y = a.choice_all(ok);
           [~,~,a.statsReal(m)] = glmfit(x,y,'binomial','link','logit','constant','off');
           a.betaReal(m,:) = a.statsReal(m).beta;
           a.betaPReal(m,:) = a.statsReal(m).p;

       
       a.meanChoiceReal(m,3) = m;
 
   end

    a.meanChoiceReal = a.meanChoiceReal(a.meanChoiceReal(:,3)>0,:);
    a.choiceCIReal = a.choiceCIReal(a.choiceCIReal(:,1)>0,:);
   
    allChoices = a.choiceCorr(a.choiceCorrTrials & a.preReverse == 1 & ismember(a.trialMouse,a.prefMice));
    [a.overallPrefReal,a.overallCIReal] = binofit(sum(allChoices == 1),numel(allChoices));
    clear allChoices;
    
%%

% a.revPrefMice = [2 4 5 10 16];
a.icp_realpref = a.meanChoiceReal(:,1)*100;
a.overallPrealpref = signrank(a.icp_realpref-50);


%% OPTO

% files with laser on == 1
a.optoFlag = cell2mat(a.parameters(:,5)) == 1;
a.optoMice = unique(a.fileMouse(a.optoFlag));
a.optoMiceList = a.mouseList(a.optoMice);

if ~isempty(a.optoMice)
    for m = 1:length(a.optoMice)
        mm = a.optoMice(m);
       a.laserStart(m,1) = find(a.fileMouse' == mm & a.optoFlag == 1,1);
       laserOnFiles = find(a.fileMouse' == mm & a.optoFlag == 1);
       laserOffFiles = find(a.fileMouse' == mm & a.optoFlag == 0);
       laserOffFiles = laserOffFiles(laserOffFiles  >= a.laserStart(m,1));
       if isempty(laserOffFiles)
           mouseFiles = find(a.fileMouse' == mm);
           laserOffFiles = mouseFiles(mouseFiles < a.laserStart(m,1));
       end
       a.laserDays{m,1} = unique(a.fileDay(laserOnFiles));
       a.laserDays{m,2} = unique(a.fileDay(laserOffFiles));

       % choice on laser on vs off days (but reversal and values!! and
       % training) need to calc time course of training!!
        a.laserChoice{m,1} = nanmean(cell2mat(a.daySummary.percentInfo(mm,a.laserDays{m,1})));
        a.laserChoice{m,2} = nanmean(cell2mat(a.daySummary.percentInfo(mm,a.laserDays{m,2})));
    end
end

%% OUTCOME/COMPLETE/IN PORT

for m = 1:a.mouseCt
    ok = a.miceAll(:,m) == 1;
    mouseOutcomes = a.finalOutcome(ok);
    % info choice big
    a.incomplete(m,1) =  sum(mouseOutcomes == 3)/sum(ismember(mouseOutcomes,[2 3]));
    % info choice small
    a.incomplete(m,2) =  sum(mouseOutcomes == 5)/sum(ismember(mouseOutcomes,[4 5]));
    % rand choice big
    a.incomplete(m,3) = sum(ismember(mouseOutcomes, [7]))/sum(ismember(mouseOutcomes, [6 7]));
    % rand choice small
    a.incomplete(m,4) =  sum(mouseOutcomes == 9)/sum(ismember(mouseOutcomes,[8 9]));    
    % info big
    a.incomplete(m,5) =  sum(mouseOutcomes == 12)/sum(ismember(mouseOutcomes,[11 12]));    
    % info small
    a.incomplete(m,6) =  sum(mouseOutcomes == 14)/sum(ismember(mouseOutcomes,[13 14]));
    % rand big
    a.incomplete(m,7) =  sum(mouseOutcomes == 18)/sum(ismember(mouseOutcomes,[17 18]));
    % rand small
    a.incomplete(m,8) =  sum(mouseOutcomes == 20)/sum(ismember(mouseOutcomes,[19 20]));
    for d = 1:a.mouseDayCt(m)
        mouseOutcomes = a.daySummary.finalOutcome{m,d};
        a.dayIncomplete(m,d,1) = sum(mouseOutcomes == 3)/sum(ismember(mouseOutcomes,[2 3]));
        a.dayIncomplete(m,d,2) = sum(mouseOutcomes == 5)/sum(ismember(mouseOutcomes,[4 5]));
        a.dayIncomplete(m,d,3) = sum(mouseOutcomes == 7)/sum(ismember(mouseOutcomes, [6 7]));
        a.dayIncomplete(m,d,4) = sum(mouseOutcomes == 9)/sum(ismember(mouseOutcomes,[8 9]));    
        a.dayIncomplete(m,d,5) = sum(mouseOutcomes == 12)/sum(ismember(mouseOutcomes,[11 12]));    
        a.dayIncomplete(m,d,6) = sum(mouseOutcomes == 14)/sum(ismember(mouseOutcomes,[13 14]));
        a.dayIncomplete(m,d,7) = sum(mouseOutcomes == 18)/sum(ismember(mouseOutcomes,[17 18]));
        a.dayIncomplete(m,d,8) = sum(mouseOutcomes == 20)/sum(ismember(mouseOutcomes,[19 20]));
    end
end

%%
save('infoSeekFSMDataAnalyzed.mat','a');

save(['infoSeekFSMDataAnalyzed' datestr(now,'yyyymmdd') 'realPref'],'a');