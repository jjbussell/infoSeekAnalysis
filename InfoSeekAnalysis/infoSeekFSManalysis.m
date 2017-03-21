clear;
close all;

uiopen('.mat');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  ANALYSIS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% DAYS

% assign day to each trial
days = a.parameters(:,3);
% find unique days since multiple sessions some days
days = unique(days);
% assign numeric day to each file
for s = 1:size(a.parameters,1)
   a.parameters{s,30} = find(ismember(days,a.parameters{s,3})); 
   a.files(s).day =a.parameters{s,30};
end

a.fileDays = cell2mat(a.parameters(:,30));

a.day = a.fileDays(a.file);
a.dayAll = a.fileDays(a.fileAll);


%% TRIAL COUNTS

a.allTrialCt = size(a.trialNums,1);
a.allCorrTrialCt = size(a.corrTrials,1);

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ALL TRIALS

a.choiceTypeNames = {'InfoForced','RandForced','Choice'};
a.choiceTypeCts = [sum(a.infoForced) sum(a.randForced) sum(a.choiceTrials)];

% figure();
% bar(a.choiceTypeCts);
% title(mouse);
% set(gca, 'XTickLabel',a.choiceTypeNames);
% ylabel('Trial Counts');

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ALL CORRECT TRIALS

a.infoBig = a.type == 1 | a.type == 5;
a.infoSmall = a.type == 2 | a.type == 6;
a.randBig = a.type == 3| a.type == 7;
a.randSmall = a.type == 4 | a.type == 8;

a.typeNames = {'Info Water','Info None','Rand Water','Rand None'};
a.typeSizes = [sum(a.infoBig) sum(a.infoSmall) sum(a.randBig) sum(a.randSmall)];

% figure();
% bar(a.typeSizes);
% title(mouse);
% set(gca, 'XTickLabel',a.typeNames);
% ylabel('Correct Trial Counts');

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

a.rxnCorr = a.rxn(a.correct);
a.rxnInfoForcedCorr = a.rxnCorr(a.infoForcedCorr);
a.rxnInfoChoiceCorr = a.rxnCorr(a.infoChoiceCorr);
a.rxnRandForcedCorr = a.rxnCorr(a.randForcedCorr);
a.rxnRandChoiceCorr = a.rxnCorr(a.randChoiceCorr);

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
a.dayCell = a.parameters(:,3);
a.miceCell = a.parameters(:,2);

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

% FINDS REVERSE DAY (a.reverseDay(m,1)

infoSide = cell2mat({a.files.infoSide});

a.reverseFile = zeros(a.mouseCt,1);
a.reverseDay = zeros(a.mouseCt,1);
a.prereverseFiles = ones(a.numFiles,1); %flag 1 = file before reverse

for m = 1:a.mouseCt
    
    mouseFileCt(m,1) = sum(a.fileMouse == m);
    fileSums = [0; cumsum(mouseFileCt)];
    if mouseFileCt(m,1) > 1
        mouseInfoSideDiff = diff(infoSide(a.fileMouse == m));
        if sum(mouseInfoSideDiff) ~= 0        
            a.reverseFile(m,1) = max(find(mouseInfoSideDiff~=0)) + 1;    
            a.prereverseFiles(fileSums(m) + a.reverseFile(m,1) : fileSums(m+1)) = 0;
            mouseFileDays = a.fileDay(a.fileMouse == m);
            a.reverseDay(m,1) = mouseFileDays(a.reverseFile(m,1));
        end
    end
end

a.preReverse = ones(size(a.file,1),1);
for t = 1:size(a.file,1)
    a.preReverse(t,1) = a.prereverseFiles(a.file(t));
end

%% TRIAL TYPE COUNTS BY MOUSE BY DAY

for m = 1:a.mouseCt
    for d = 1:a.mouseDayCt(m)
       ok = a.mice(:,m) & a.mouseDay == d;
       a.typeSizesmouseDays(d,:,m) = [sum(a.infoBig(ok)) sum(a.infoSmall(ok)) sum(a.randBig(ok)) sum(a.randSmall(ok))];
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

for t = 1:a.allCorrTrialCt
    trialFile = a.file(t);
    a.odorAtrials(t,1) = a.trialParams(t,6) == a.odorA(trialFile);
    a.odorBtrials(t,1) = a.trialParams(t,6) == a.odorB(trialFile);
    a.odorCtrials(t,1) = a.trialParams(t,6) == a.odorC(trialFile);
    a.odorDtrials(t,1) = a.trialParams(t,6) == a.odorD(trialFile);
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


%% LICKS OVER TIME

win = 50;

% % time before odor on
% odorWait = files(f).centerDelay + files(f).centerOdorTime + ...
%     files(f).startDelay + 50 + files(f).odorDelay;
% % time before reward starts
% rewardWait = odorWait + files(f).odorTime + files(f).rewardDelay;

odorWait = 200 + 50 + 2000;
rewardWait = odorWait + 200 + 2000;
rewardWaitBin = ceil(rewardWait/win);

timeBins = (0:win:rewardWaitBin*win);

% % for ll = 1:size(a.lickFile,1)
% %     if a.lickTrial(ll)>0
% %         a.lickMouse(ll,1) = a.fileMouse(a.lickFile(ll));
% %         a.lickDay(ll,1) = a.fileDay(a.lickFile(ll)); 
% %     else
% %         a.lickMouse(ll,1) = 0;
% %         a.lickDay(ll,1) = 0;
% %     end        
% % end
% % 
% % a.lickCorrMouse = a.lickMouse(a.lickMouse(:,1)>0);
% % a.lickCorrDay = a.lickDay(a.lickDay(:,1)>0);
% 
% for ll = 1:size(a.lickCorrTime,1)
%    a.lickCorrMouse(ll,1) = a.fileMouse(a.lickCorrFiles(ll));
%    a.lickCorrDay(ll,1) = a.fileDay(a.lickCorrFiles(11));    
% end
%  
% for m = 1:a.mouseCt
%     for d = 1:a.mouseDayCt(m)
%         ok = a.lickCorrMouse == m & a.lickCorrDay == d;
%         infoBigLickProbDays{d,:,m} = histcounts(a.lickCorrTime(infoBigLickFlag(ok)),timeBinsDwellRelCenter);
%         infoBigLickProbDays{d,:,m} = cell2mat(infoBigLickProbDays(d,:,m))./a.typeSizesMouseDays(d,1,m);
%         infoSmallLickProbDays{d,:,m} = histcounts(a.lickCorrTime(infoSmallLickFlag(ok)),timeBinsDwellRelCenter);
%         infoSmallLickProbDays{d,:,m} = cell2mat(infoSmallLickProbDays(d,:,m))./a.typeSizesMouseDays(d,2,m);
%         randBigLickProbDays{d,:,m} = histcounts(a.lickCorrTime(randBigLickFlag(ok)),timeBinsDwellRelCenter);
%         randBigLickProbDays{d,:,m} = cell2mat(randBigLickProbDays(d,:,m))./a.typeSizesMouseDays(d,3,m);
%         randSmallLickProbDays{d,:,m} = histcounts(a.lickCorrTime(randSmallLickFlag(ok)),timeBinsDwellRelCenter);
%         randSmallLickProbDays{d,:,m} = cell2mat(randSmallLickProbDays(d,:,m))./a.typeSizesMouseDays(d,4,m);
%     end
%     
%     lickProbDays{:,:,m} = [cell2mat(infoBigLickProbDays(:,:,m)); cell2mat(infoSmallLickProbDays(:,:,m)); cell2mat(randBigLickProbDays(:,:,m)); cell2mat(randSmallLickProbDays(:,:,m))];
% end
% 
% 
% bins = [win/2:win:maxDwellRelCenter*win-win/2];   
% maxLicks = 1; % ylim


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% DAY SUMMARY
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for m = 1:a.mouseCt
    for d = 1:a.mouseDayCt(m)
        % OUTCOMES (all trials)
        a.daySummary.outcome{m,d} = a.outcome(a.mouseDayAll == d & a.miceAll(:,m) == 1);
        
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
        a.daySummary.totalRewards{m,d} = sum(a.reward(ok));
        a.daySummary.percentInfo{m,d} = mean(a.infoCorrTrials(ok & a.choiceCorrTrials == 1));
        a.daySummary.rxnInfoForced{m,d} = mean(a.rxnCorr(a.infoForcedCorr & ok));
        a.daySummary.rxnInfoChoice{m,d} = mean(a.rxnCorr(a.infoChoiceCorr & ok));
        a.daySummary.rxnRandForced{m,d} = mean(a.rxnCorr(a.randForcedCorr & ok));
        a.daySummary.rxnRandChoice{m,d} = mean(a.rxnCorr(a.randChoiceCorr & ok));
        a.daySummary.infoBigLicks{m,d} = a.AlicksBetween(m,d)/sum(a.odorAtrials & ok);
        a.daySummary.infoSmallLicks{m,d} = a.BlicksBetween(m,d)/sum(a.odorBtrials & ok);
        a.daySummary.randCLicks{m,d} = a.ClicksBetween(m,d)/sum(a.odorCtrials & ok);
        a.daySummary.randDLicks{m,d} = a.DlicksBetween(m,d)/sum(a.odorDtrials & ok);
        a.daySummary.infoBigLicksEarly{m,d} = a.AlicksEarly(m,d)/sum(a.odorAtrials & ok);
        a.daySummary.infoSmallLicksEarly{m,d} = a.BlicksEarly(m,d)/sum(a.odorBtrials & ok);
        a.daySummary.randCLicksEarly{m,d} = a.ClicksEarly(m,d)/sum(a.odorCtrials & ok);
        a.daySummary.randDLicksEarly{m,d} = a.DlicksEarly(m,d)/sum(a.odorDtrials & ok);
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
uisave({'a'},'infoSeekFSMDataAnalyzed.mat');