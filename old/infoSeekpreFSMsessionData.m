clear;
close all;

ports = [1,3]; % port sensor IDs

%% load previous data
prompt = {'Load data file? 1 = yes, 0 = no'};
dlg_title = 'Load data?';
num_lines = 1;
defaultans = {'1'};
loadData = inputdlg(prompt,dlg_title,num_lines,defaultans);
loadData = str2num(cell2mat(loadData));

if loadData == 1
    [datafilename,datapathname]=uigetfile('*.mat', 'Choose processed data file to load');
    fname=fullfile(datapathname,datafilename); 
    load(fname); % opens structure "a" with previos data, if available
end

%% LOAD NEW DATA

% prompt
prompt = {'Add new data? 1 = yes, 0 = no'};
dlg_title = 'New data?';
num_lines = 1;
defaultans = {'1'};
newData = inputdlg(prompt,dlg_title,num_lines,defaultans);
newData = str2num(cell2mat(newData));

if newData == 1
    % select folder with new data file(s) to load
    pathname=uigetdir;
    files=dir([pathname,'/*.csv']);
    numFiles = size(files,1);

    f = 1;


    %% FOR EACH FILE
    for f = 1:numFiles
        filename = files(f).name;

        fname = fullfile(pathname,filename); % report
        dayPlace = strfind(filename,'_');

        mouse = cellstr(filename(1:dayPlace-1));
        day = filename(dayPlace(1)+1:dayPlace(2)-1);

        data = [];

        if csvread(fname,28,0,[28,0,28,0]) == 0
            data = csvread(fname,28,0);

            sessionParams(:,f) = csvread(fname,1,1,[1,1,27,1]); % report        
        else if csvread(fname,27,0,[27,0,27,0]) == 0
            data = csvread(fname,27,0);

            sessionParams(:,f) = vertcat(csvread(fname,1,1,[1,1,26,1]), 0); % report

            else
                data = csvread(fname,26,0);
                sessionParams(:,f) = vertcat(csvread(fname,1,1,[1,1,25,1]), 0, 0); % report           
            end
        end

        infoSide = sessionParams(5,f);
        info = ports(infoSide+1); % set for each session
        rand = setdiff(ports,info);
        odorDelay = sessionParams(16,f);
        odorTime = sessionParams(17,f);
        rewardDelay = sessionParams(18,f);
        rewardWait = odorDelay + odorTime + rewardDelay;
        interval = sessionParams(24,f);

        % SAVE SESSION PARAMETERS
        sessionLength = (data(end,1)-data(1,1))/1000; % report
        totalTime = data(end,1);

        sessionSummary = cat(2, sessionParams(:,f)', sessionLength);
        sessionSummary = num2cell(sessionSummary);
        sessionSummary = [filename,mouse,day,sessionSummary];
        
        
%% IMAGING

    % Pull imaging frame timestamps
    images = [];
    images = data(data(:,3) == 20, 1);
    images = [zeros(size(images,1),1) images];
    images(:,1) = f;    


     %%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% TRIALS
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        header = {'Trial_Num','Trial_Start','Trial_Type','Corr_Center_Entry','First_Center_Entry',...
            'Center_EntryCt','Center_Exit',...
            'GoCue','Reward_Entry','Reward_Port','Correct_Choice','Reward_Entry_First','Info'};    

        trialCt = max(data(:,2));

        trials = zeros(trialCt,16);    
        trials(:,1) = 1:trialCt;

        trialStarts = data(data(:,3) == 10,:);

        % trial type time (of first center entry of new trial) and type

        if size(trialStarts,1) > trialCt-2
            for ts = 0:trialCt-1
               if isempty(find(trialStarts(:,2) == 0,1,'last'))
                   ts = ts+1;
                   startIdx = find(trialStarts(:,2) == ts,1,'last');
                   trials(ts,[2 3]) = trialStarts(startIdx,[1 4]);
               else
                   startIdx = find(trialStarts(:,2) == ts,1,'last');
                   trials(ts+1,[2 3]) = trialStarts(startIdx,[1 4]); % time of start and trial type
               end
            end
        else
            for ts=1:trialCt
               firstTrial = data(find(data(:,2) == ts,1,'first'),1);
               startDiff = firstTrial - trialStarts(:,1);
               startDiff(startDiff < 0) = inf;
               [~,startIdx] = min(startDiff);
               trials(ts,[2 3]) = trialStarts(startIdx,[1 4]); 
            end

        end

        %% ENTRIES   
        entries = [];
        exits = [];
        centerEntries = [];
        centerExits = [];
        rewardEntries = [];
        rewardExits = [];

        entries = data(data(:,3) == 2,:);
        exits = data(data(:,3) == 6,:);
        centerEntries = entries(entries(:,4) == 4,:);
        rewardEntries = entries(entries(:,4) ~= 4,:);
        centerExits = exits(exits(:,4) == 4,:);
        rewardExits = exits(exits(:,4) ~= 4,:);


    %%  center entries

        centerEntriesCorr = [];
        centerEntryCorrIdx = [];
        centerExitIdx = [];
        centerExitsCorr = [];
        centerEntryFirst = [];
        centerEntryCount = [];
        firstCenterExits = [];
        centerEntriesAllCorr = {};
        centerExitDiff = [];
        
 %%       
        for e = 1:size(centerEntries,1)
            centerExitDiff = centerExits(:,1) - centerEntries(e,1);
            centerExitDiff(centerExitDiff < 0) = inf;
            [centerExitVal,centerExitIdx] = min(centerExitDiff);
            if isinf(centerExitVal)
                centerEntries(e,6) = totalTime;
            else
                centerEntries(e,6) = centerExits(centerExitIdx,1); % matching center exit
            end
        end

        % dwell time
        centerEntries(:,7) = centerEntries(:,6)-centerEntries(:,1); % dwell time
        
        centerEntries(:,8) = f; % file

%%

        centerEntriesCorr = centerEntries(centerEntries(:,5) == 1,:); % correct center entries

        
        for r = 1:trialCt

            if ~isempty(find(centerEntriesCorr(:,2) == r))
                centerEntryCorrIdx(r,1) = max(find(centerEntriesCorr(:,2) == r)); % index of last correct center entry of that trial
                centerEntryCorrIdx(r,2) = centerEntriesCorr(centerEntryCorrIdx(r,1),1); % time of last correct center entry
                centerEntryFirstIdx = min(find(centerEntriesCorr(:,2) == r)); % index of first correct center entry in that trial
                centerEntryFirst(r,1) = centerEntriesCorr(centerEntryFirstIdx,1); % time of first center entry
                centerEntryCount(r) = sum(centerEntriesCorr(:,2) == r);

                % center exit
                centerExitDiff = centerExits(:,1) - centerEntryCorrIdx(r,2); % find closest center entry
                centerExitDiff(centerExitDiff<0) = inf;
                [centerExitVal,centerExitIdx] = min(centerExitDiff);
                if isfinite(centerExitVal)
                    centerExitsCorr(r,1) = centerExits(centerExitIdx,1);
                else
                    centerExitsCorr(r,1) = centerEntryCorrIdx(r,2);
                end

                % exit of first center entry
                centerExitFirstDiff = centerExits(:,1) - centerEntryFirst(r,1); % find closest center entry
                centerExitFirstDiff(centerExitFirstDiff<0) = inf;
                [centerExitFirstVal,centerExitFirstIdx] = min(centerExitFirstDiff);
                if isfinite(centerExitFirstVal)
                    centerEntryFirst(r,2) = centerExits(centerExitFirstIdx,1); % time of first center exit
                else
                    centerEntryFirst(r,2) = centerEntryFirst(r,1);
                end

                % all entries and exits
                allTrialCenterExits = [];
                allTrialCenterEntries = [];

                allTrialCenterEntries = centerEntriesCorr(centerEntriesCorr(:,2)==r,1);

                for ee = 1:size(allTrialCenterEntries,1)
                    centerExitAllDiff = centerExits(:,1) - allTrialCenterEntries(ee);
                    centerExitAllDiff(centerExitAllDiff<=0) = inf;
                    [centerExitAllVal, centerExitAllIdx] = min(centerExitAllDiff);
                    if isfinite(centerExitAllVal)
                        allTrialCenterExits(ee) = centerExits(centerExitAllIdx,1);
                    else
                        allTrialCenterExits(ee) = 0;
                    end
                end
                centerEntriesAllCorr{r,1} = allTrialCenterEntries;
                centerEntriesAllCorr{r,3} = allTrialCenterExits;

            else
                centerEntryCorrIdx(r,1) = r; % ???????
                centerEntryCorrIdx(r,2:3) = 0;
                centerEntryFirst(r,1:2) = 0;
                centerEntryCount(r) = 0;
                centerExitsCorr(r,1) = 0;
                centerEntriesAllCorr{r,1} = 0;
            end

            centerEntryCorrIdx(r,3) = sum(centerEntriesCorr(:,2) == r); % number of correct center entries

            centerEntriesAllCorr{r,2} = f;   
        end

        trials(:,4) = centerEntryCorrIdx(:,2); % time of last corr entry (sets ITI)
        trials(:,5) = centerEntryFirst(:,1); % time of first corr entry
        trials(:,6) = centerEntryCount;
        trials(:,7) = centerExitsCorr;

        firstCenterExits(:,1) = centerEntryFirst(:,2); 

        %% reward available / goCue

        rewardStarts = [];
        rewardStarts = data(data(:,3) == 1,:); % col 1 = time of goCue!

        for r = 1:size(rewardStarts,1)
            rTrial = rewardStarts(r,2);
            rStart = rewardStarts(r,1);
            trials(rTrial,8) = rStart;
        end
        
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% REWARD ENTRY
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        % find exit for each reward entry / dwell time
        for e = 1:size(rewardEntries,1)
            rewardExitDiff = rewardExits(:,1) - rewardEntries(e,1);
            rewardExitDiff(rewardExitDiff < 0) = inf;
            [rewardExitVal,rewardExitIdx] = min(rewardExitDiff);
            if isinf(rewardExitVal)
                rewardEntries(e,6) = totalTime;
            else
                rewardEntries(e,6) = rewardExits(rewardExitIdx,1); % matching reward exit
            end
        end

        % dwell time
        rewardEntries(:,7) = rewardEntries(:,6)-rewardEntries(:,1); % dwell time
        
        rewardEntries(:,8) = f; % file

    %% IN TRIALS    
        % only in trial entries
        rewardEntriesTrials = [];
        rewardEntriesTrials = rewardEntries(rewardEntries(:,5)~=2,:);
        
        % first inTrial entry after goCue is choice/first entry (will count
        % even if in next trial? what about multi entries in next trial for
        % prior goCue?)
        % last inTrial entry before reward (but if no reward??)  

        % entries per trial
        rewardEntryCount = [];

        % total correct reward port time
        rewardEntriesCorr = [];
        rewardEntriesCorr = rewardEntriesTrials(rewardEntriesTrials(:,5) == 1 | rewardEntriesTrials(:,5) == 3,:);

        % first reward entry
        rewardEntriesChoices = [];
        rewardEntriesChoices = rewardEntriesTrials(rewardEntriesTrials(:,5)<2,:);

        for t = 1:trialCt
            rewardEntryCount(t,1) = sum(rewardEntriesCorr(:,2) == t);
            rewardEntryGoDiff = rewardEntriesTrials(:,1) - trials(t,4); % find first after go cue (can be in next trial)
            rewardEntryGoDiff(rewardEntryGoDiff < 0) = inf;
            [entryVal,entryIdx] = min(rewardEntryGoDiff);
            if entryVal >= interval
                entryIdx = [];
            end
%             entryIdx = find(rewardEntriesChoices(:,2) == t,1,'first'); % first entry (for choice)
            if isempty(entryIdx) % can be true but found in next
               trials(t,9:13) = 0; 
            else
               trials(t,9:13) = rewardEntriesTrials(entryIdx,[1,4:7]); % first entry time, port, correct choice
            end
        end


    %% ALL ENTRIES FOR A TRIAL
        % all reward entries and exits
        allTrialRewardEntries = [];
        allTrialRewardExits = [];
        totalRewardEntries = [];

        for r=1:trialCt
            if ~isempty(find(rewardEntriesTrials(:,2) == r))
                allTrialRewardEntries = rewardEntriesTrials(rewardEntriesTrials(:,2) == r,1);
                allTrialRewardExits = rewardEntriesTrials(rewardEntriesTrials(:,2) == r,6);
                allTrialRewardEntriesCorrect = rewardEntriesTrials(rewardEntriesTrials(:,2) == r,5);
                allTrialRewardEntriesPort = rewardEntriesTrials(rewardEntriesTrials(:,2) == r,4);

                totalRewardEntries{r,1} = allTrialRewardEntries; % all entries
                totalRewardEntries{r,2} = allTrialRewardExits; % all exits
                totalRewardEntries{r,3} = allTrialRewardEntriesCorrect; % correct
                totalRewardEntries{r,4} = allTrialRewardEntriesPort; % port
                totalRewardEntries{r,5} = f; % file
            else
                totalRewardEntries{r,1} = 0;
                totalRewardEntries{r,2} = 0;
                totalRewardEntries{r,3} = 0;
                totalRewardEntries{r,4} = 0;
                totalRewardEntries{r,5} = f;
            end
        end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% CORR TRIALS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        % CORRTRIALS = trials with center complete and correct entry
        corrTrials = [];
        if ~isempty(trials(:,11) == 1)
            corrTrials = trials(trials(:,11) == 1,[1:10,12:13]); % takes out correct so just entries and port
        else corrTrials = [];
        end
        corrTrialCt = size(corrTrials,1);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %% ODOR AND REWARD SIZE ASSIGNED  

        trialParams = [];
        trialParams = data(data(:,3) == 17,:);
        corrTrials(:,13:14) = 0;
        for p = 1:size(trialParams,1)
            paramsIdx = trialParams(p,2);
            corrTrialParamIdx = find(corrTrials(:,1) == paramsIdx);
            corrTrials(corrTrialParamIdx,13) = trialParams(p,4); % reward size
            corrTrials(corrTrialParamIdx,14) = trialParams(p,5); % odor
        end
        
    %% ODOR TIMES
    
        odorOn = []; odorOnCenter = []; odorOnSide = [];
        odorOn = data(data(:,3) == 3,:);
%         odorOff = data(data(:,3) == 5,:);
        odorOnCenter = odorOn(odorOn(:,5) == 0,:);
%         odorOffCenter = odorOff(odorOff(:,5) == 0,:);
        odorOnSide = odorOn(odorOn(:,5) == 1,:);
%         odorOffSide = odorOff(odorOff(:,5) == 1,:);
        
        
        centerOdorOns = zeros(size(centerEntriesCorr,1),1);
        for c = 1:size(centerEntriesCorr,1) % each correct center entry
            odorDiffCenter = odorOnCenter(:,1) - centerEntriesCorr(c,1);
            odorDiffCenter(odorDiffCenter<0) = inf;
            [~,odorCenterIdx] = min(odorDiffCenter);
            if centerEntriesCorr(c,6) - odorOnCenter(odorCenterIdx,1) > 0
                centerOdorOns(c,1) = odorOnCenter(odorCenterIdx,1);
            end
        end
        
        sideOdorOns = zeros(size(rewardEntriesTrials,1),1); % on for each entry in a trial
        for o = 1:size(rewardEntriesTrials,1)
           odorDiffSide = odorOnSide(:,1) - rewardEntriesTrials(o,1); % each correct reward entry since no odor otherwise
           odorDiffSide(odorDiffSide<0) = inf;
           [odorSideVal,odorSideIdx] = min(odorDiffSide);
           if rewardEntriesTrials(o,6) - odorOnSide(odorSideIdx,1) > 0
               if (isfinite(odorSideVal)) 
                    sideOdorOns(o,1) = odorOnSide(odorSideIdx,1);
               end
           end
        end
        
        % odor1 = rewardEntriesCorr(:,6) - sideOdorOns;

    %% reward delivery time

        rewardOn = [];
        rewardOn = data(data(:,3) == 7,:); % reward delivery
        corrTrials(:,15) = 0;
        for rt = 1 : corrTrialCt
           rewardOnIdx = find(rewardOn(:,2) == corrTrials(rt,1),1,'last');
           if ~isempty(rewardOnIdx)
               corrTrials(rt,15) = rewardOn(rewardOnIdx,1);
           else corrTrials(rt,15) = 0;
           end
        end
    %     [rewarded, rewardOnIndex] = ismember(corrTrials(:,1),rewardOn(:,2));
    %     corrTrials(rewarded,15) = rewardOn(rewarded,1);

    %% reward entry

        % find reward entry closest to delivery and pull that exit time
        % if no delivery, take last reward entry if any, else 0
        
        for r = 1:corrTrialCt
           if corrTrials(r,15) > 0 % if reward time reached in port
               rewardEntryDiff = corrTrials(r,15) - rewardEntriesTrials(:,1); 
               rewardEntryDiff(rewardEntryDiff < 0) = inf;
               [~,rewardEntryIdx] = min(rewardEntryDiff);
               if isempty(rewardEntryIdx)
                   corrTrials(r,16:17) = 0;
                   rewardEntryOdorOn(r,1) = 0;
               else
                corrTrials(r,16:17) = rewardEntriesTrials(rewardEntryIdx,[1,6]);
                rewardEntryOdorOn(r,1) = sideOdorOns(rewardEntryIdx,1); % odor on time for each "final" center entry per trial
               end
           else
%                corrTrials(r,16:17) = 0;
                lastIdx = find(rewardEntriesTrials(:,2) == corrTrials(r,1),1,'last');
                if ~isempty(lastIdx)
                    corrTrials(r,16:17) = rewardEntriesTrials(lastIdx,[1,6]);
                else corrTrials(r,16:17) = 0;
                end
           end
        end

    %% REWARDS GIVEN

        bigRewards = data(data(:,3) == 15,:);
        smallRewards = data(data(:,3) == 16,:);
        bigRewardCt = size(bigRewards,1); % report
        smallRewardCt = size(smallRewards,1); % report
        rewardCts = bigRewardCt + smallRewardCt; % report
        bigRewardTime = sessionParams(19);
        smallRewardTime = sessionParams(20);
        bigReward = (bigRewardTime * 40)/1000;
        smallReward = (smallRewardTime * 40)/1000;
        rewardAmount = bigRewardCt * (bigRewardTime * 40)/1000 + smallRewardCt * (smallRewardTime * 40)/1000; % report
        bigRewardsLeft = sum(bigRewards(:,5) == 1);
        bigRewardsRight = sum(bigRewards(:,5) == 3);
        smallRewardsLeft = sum(smallRewards(:,5) == 1);
        smallRewardsRight = sum(smallRewards(:,5) == 3);

        
%% REWARD AMOUNTS GIVEN

        rewardEvents= data(data(:,3) == 15 | data(:,3) == 16,[2 3]);

        reward = zeros(corrTrialCt,1);
       
        for tt = 1:corrTrialCt
            rewardTrial = corrTrials(tt,1);
            rewardIdx = find(rewardEvents(:,1) == rewardTrial,1,'last');
            if ~isempty(rewardIdx)
                reward(tt,1) = rewardEvents(rewardIdx,2);
            end
        end        

        reward(reward == 15) = 1;
        reward(reward == 16) = 0;


    %% COMPLETE TRIALS

        completeTrials = [];
        completeTrials = data(data(:,3) == 18,[2 1]);
        
        % need to change based on time not trial number!!
        corrTrials(:,18) = ismember(corrTrials(:,1),completeTrials(:,1));
        corrTrials(:,19) = 0;

        for c = 1:corrTrialCt
            trialNum = corrTrials(c,1);
            if corrTrials(c,18) > 0
                completeIdx = find(completeTrials(:,1) == trialNum,1,'last');
                completeTime = completeTrials(completeIdx,2);
                corrTrials(c,19) = completeTime;
            else
               corrTrials(c,19) = 0; 
            end
        end

    %% TRIAL LENGTH

        trialLength = zeros(corrTrialCt,1);
        for tt = 1:corrTrialCt-1
            trialLength(tt) = corrTrials(tt+1,2) - corrTrials(tt,4);
        end
        trialLength(corrTrialCt) = NaN;
        
    %% ASSIGN INFO/RANDOM

        infoCorrFlag = zeros(corrTrialCt,1);
        infoCorrFlag(corrTrials(:,10) == info) = 1;
        corrTrials(:,20) = infoCorrFlag;

        infoFlag = zeros(trialCt,1);
        infoFlag(trials(:,11) == info) = 1;
        trials(:,14) = infoFlag;    

    %%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%  TYPES
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        infoRand = corrTrials(:,20);
        rewards = corrTrials(:,13); %what size was assigned
        type = corrTrials(:,3);

        typeCol = size(corrTrials,2)+1;
        corrTrials(:,typeCol) = 0; % column for trial types

        for t = 1:corrTrialCt
            if type(t) == 1
                if infoRand(t) == 1 && rewards(t) == 1
                    corrTrials(t,typeCol) = 1; % infoChoiceBig
                else if infoRand(t) == 1 && rewards(t) == 0
                        corrTrials(t,typeCol) = 2; % infoChoiceSmall
                    else if infoRand(t) == 0 && rewards(t) == 1
                            corrTrials(t,typeCol) = 3; % randChoiceBig
                        else corrTrials(t,typeCol) = 4; % randChoiceSmall
                        end
                    end
                end
            else
                if type(t) == 2 % info forced
                    if rewards(t) == 1
                        corrTrials(t,typeCol) = 5; % infoForcedBig
                    else corrTrials(t,typeCol) = 6; % infoForcedSmall
                    end
                else
                    if rewards(t) == 1
                        corrTrials(t,typeCol) = 7; % randForcedBig
                    else corrTrials(t,typeCol) = 8; % randForcedSmall
                    end
                end
            end
        end

        corrTrials(:,typeCol+1) = 0;
        corrTrials(2:end,typeCol+1) = corrTrials(1:end-1,typeCol);   

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% LICKS
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        lickHeader =  {'lick_time', 'trial', 'entry_num', 'entry_time',...
            'entry_correct', 'entry_port','time_from_entry','trial_idx',...
            'trial_type','trial_choice_port','time_from_correct_center_entry'};     
        
        licks = [];
        licks = data(data(:,3) == 4,[1 2]); % lick time and trial
        licks(:,3:13) = 0; % preallocate

        for l = 1:size(licks,1)
            lickEntDiff = [];
            lickExitDiff = [];
            lickEntDiff = licks(l,1) - rewardEntriesCorr(:,1);
            lickEntDiff(lickEntDiff<0) = inf;
            [~,lickEntIdx] = min(lickEntDiff);
            lickExitDiff = licks(l,1) - rewardEntriesCorr(:,1);
            lickExitDiff(lickExitDiff<0) = inf;
            [~,lickExitIdx] = min(lickExitDiff);
            if ~isempty(lickExitIdx) & ~isempty(lickEntDiff)
                if lickExitIdx < lickEntIdx
                    lickIdx = lickExitIdx;
                else
                    lickIdx = lickEntIdx;
                end
                licks(l,3) = lickIdx; % entry number
                licks(l,[4 5 6]) = rewardEntriesCorr(lickIdx,[1 5 4]); % entry time, correct, port
                licks(l,7) = licks(l,1) - rewardEntriesCorr(lickIdx,1); % time from entry
                % need trial type and center entry time
                lickTrialIdx = find(corrTrials(:,1) == licks(l,2));
                if ~isempty(lickTrialIdx)
                    licks(l,8) = lickTrialIdx; % index into corrTrials
                    licks(l,9) = corrTrials(lickTrialIdx,3); % trial type
                    licks(l,10) = corrTrials(lickTrialIdx,10); % entry port
                    licks(l,11) = licks(l,1) - corrTrials(lickTrialIdx,4); % time from center correct time
                    licks(l,12) = corrTrials(lickTrialIdx,15); % trial outcome delivery
                    licks(l,13) = licks(l,12) - licks(l,1); % want time from outcome! can bootstrap odor on from that
                end
            end
        end

        %% % only licks with correct entry/trial

        %% NO NEED ALL ENTRIES IN THAT TRIAL IN CORRECT PORT! (trial progressed so some entries scored 2)
        trialLicks = [];
    %     corrLickFlag = licks(:,5) == 1 | licks(:,5) == 3;
        corrLickFlag = licks(:,5) > 0 & licks(:,6) == licks(:,10); % want not incorrect and port = correct
        trialLicks = licks(corrLickFlag,:);

        anticipateLicks = [];
        anticipateLicks = trialLicks(:,11) < rewardWait;
%         anticipateLicks = trialLicks(:,13) > 0;
        anticipateTrialNums = [];
        anticipateTrialNums = trialLicks(anticipateLicks,2);

        earlyLicks = [];
        earlyLicks = trialLicks(:,11) < odorDelay;
%         earlyLicks = trialLicks(:,1) < trialLicks(:,12) - rewardDelay - odorTime;
        earlyTrialNums = [];
        earlyTrialNums = trialLicks(earlyLicks,2);
        
        betweenLicks = [];
        betweenLicks = trialLicks(:,11) >= odorDelay & trialLicks(:,11) < rewardWait;
%         betweenLicks = trialLicks(:,1) >= trialLicks(:,12) - rewardDelay - odorTime & trialLicks(:,13) > 0;
        betweenTrialNums = [];
        betweenTrialNums = trialLicks(betweenLicks,2);

        waterLicks = [];
        waterLicks = trialLicks(:,11) >= rewardWait;
%         waterLicks = trialLicks(:,13) <= 0;
        waterLicksTrialNums = [];
        waterLicksTrialNums = trialLicks(waterLicks,2);

        anticipateLickCt = [];
        earlyLickCt = [];
        waterLickCt = [];
        rewardPortTime = [];
        betweenLickCt = [];
               
        for t = 1:corrTrialCt
           trialNum = corrTrials(t,1);
           lickCt(t,1) = sum(trialLicks(:,2) == trialNum);
           anticipateLickCt(t,1) = sum(anticipateTrialNums == trialNum);
           earlyLickCt(t,1) = sum(earlyTrialNums == trialNum);
           betweenLickCt(t,1) = sum(betweenTrialNums == trialNum);
           waterLickCt(t,1) = sum(waterLicksTrialNums == trialNum);
           rewardPortTime(t,1) = sum(rewardEntriesCorr(rewardEntriesCorr(:,2) == trialNum,7));
        end


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% ALL TRIALS TOGETHER
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        headerCorrTrials = {'Orig_Trial_Num','Trial_Start','Trial_Type',...
        'Corr_Center_Entry','First_Center_Entry','Center_Entry_Ct','Center_Exit',...
        'GoCue','First_Reward_Entry','Reward_Port','First_Reward_Exit','First_Dwell',...
        'Reward_Size','Odor','Reward_Delivery','Reward_Entry','Reward_Exit','Complete','Complete_Time',...
        'Info','Type','Last_Type','Licks',...
        'Anticip_Licks','Early_Licks'};

        headerAllCorr = {'File','Orig_Trial_Num','Trial_Start','Trial_Type',...
        'Corr_Center_Entry','First_Center_Entry','Center_Entry_Ct','Center_Exit',...
        'GoCue','First_Reward_Entry','Reward_Port','First_Reward_Exit','First_Dwell',...
        'Reward_Size','Odor','Reward_Delivery','Reward_Entry','Reward_Exit',...
        'Complete','Complete_Time','Info',...
        'Type','Last_Type','Licks',...
        'Anticip_Licks','Early_Licks'};

        headerAll = {'Day','File','Orig_Trial_Num','Trial_Start','Trial_Type',...
        'Corr_Center_Entry','First_Center_Entry','Center_Entry_Ct','Center_Exit',...
        'GoCue','First_Reward_Entry','Reward_Port','Correct','First_Reward_Exit','First_Dwell','Info'};


        trials = [zeros(trialCt,1) trials];
        trials(:,1) = f;

        corrTrials = [zeros(size(corrTrials,1),1) corrTrials];
        corrTrials(:,1) = f;

        licks(:,size(licks,2)+1) = f;


        %% PUTTING FILES TOGETHER

        files(f).name = files(f).name;
    %     files(f).folder = files(f).folder;
        files(f).date = files(f).date;
        files(f).bytes = files(f).bytes;
        files(f).isdir = files(f).isdir;
        files(f).datenum = files(f).datenum;
        files(f).day = filename(dayPlace(1)+1:dayPlace(2)-1);
        files(f).mouseName = cellstr(filename(1:dayPlace-1));
        files(f).sessionLength = sessionLength;
        files(f).infoSide = infoSide;
        files(f).info = info;
        files(f).rand = rand;
        files(f).odorDelay = odorDelay;
        files(f).odorTime = odorTime;
        files(f).rewardDelay = rewardDelay;
        files(f).rewardWait = rewardWait;
        files(f).odors = sessionParams([6:12],f);
        files(f).centerDelay = sessionParams(13,f);
        files(f).centerOdorTime = sessionParams(14,f);
        files(f).startDelay = sessionParams(15,f);
        files(f).bigRewardTime = sessionParams(19,f);
        files(f).smallRewardTime = sessionParams(20,f);
        files(f).infoRewardProb = sessionParams(21,f);
        files(f).randRewardProb = sessionParams(22,f);
        files(f).rewardLatency = sessionParams(23,f);
        files(f).interval = sessionParams(24,f);
        files(f).timeout = sessionParams(26,f);
        files(f).box = sessionParams(27,f);
        files(f).trialCt = trialCt;
    %     files(f).odorA;
    %     files(f).odorB;
    %     files(f).odorC;
    %     files(f).odorD;
    %     files(f).mouse;
    %     files(f).day;

        if isfield(files, 'folder')
            files = rmfield(files,'folder');
        end

        if f == 1

            allSummary = sessionSummary;

            allData = data;              
            allTrials = trials;
            allCorrTrials = corrTrials;
            allLicks = licks;
            allCenterFirsts = centerEntryFirst;
            allMice = repmat(mouse,corrTrialCt,1);
            allCenterEntries = centerEntries;
            allCenterExits = centerExits;
            allRewardEntries = totalRewardEntries;
            allCenterEntriesAllCorr = centerEntriesAllCorr;
            allAnticipatoryLicks = anticipateLickCt;
            allBetweenLicks = betweenLickCt;
            allEarlyLicks = earlyLickCt;
            allWaterLicks = waterLickCt;
            allRewardPortTime = rewardPortTime;
            allFirstCenterExits = firstCenterExits;
            allRewardEntryCount = rewardEntryCount;
            allTrialLength = trialLength;
            allReward = reward;
            allCenterOdorOns = centerOdorOns;
            allSideOdorOns = sideOdorOns;
            allCenterEntriesCorr = centerEntriesCorr;
            allRewardEntriesOdor = rewardEntriesTrials;
            allRewardEntryOdorOn = rewardEntryOdorOn;
            
            allImages = images;


        else

            allSummary(end+1,:) = sessionSummary;

            allData = [allData; data];        
            allTrials = [allTrials; trials];
            allCorrTrials = [allCorrTrials; corrTrials];
            if ~isempty(licks)
                allLicks = [allLicks; licks];
            end
            allCenterFirsts = [allCenterFirsts; centerEntryFirst];
            allMice = [allMice; repmat(mouse,corrTrialCt,1)];
            allCenterEntries = [allCenterEntries; centerEntries];
            allCenterExits = [allCenterExits; centerExits];
            allRewardEntries = [allRewardEntries; totalRewardEntries];
            allCenterEntriesAllCorr = [allCenterEntriesAllCorr; centerEntriesAllCorr];
            allAnticipatoryLicks = [allAnticipatoryLicks; anticipateLickCt];            
            allBetweenLicks = [allBetweenLicks; betweenLickCt];
            allEarlyLicks = [allEarlyLicks; earlyLickCt];
            allWaterLicks = [allWaterLicks; waterLickCt];
            allRewardPortTime = [allRewardPortTime; rewardPortTime];
            allFirstCenterExits = [allFirstCenterExits; firstCenterExits];
            allRewardEntryCount = [allRewardEntryCount; rewardEntryCount];
            allTrialLength = [allTrialLength; trialLength];
            allReward = [allReward; reward];
            allCenterOdorOns = [allCenterOdorOns; centerOdorOns];
            allSideOdorOns = [allSideOdorOns; sideOdorOns];
            allCenterEntriesCorr = [allCenterEntriesCorr; centerEntriesCorr];
            allRewardEntriesOdor = [allRewardEntriesOdor; rewardEntriesTrials];
            allRewardEntryOdorOn = [allRewardEntryOdorOn; rewardEntryOdorOn];
            allImages = [allImages; images];
            
        end

        trialCts(f) = trialCt;
        corrTrialCts(f) = corrTrialCt;

        lastTrials = cumsum(trialCts);
        lastCorrTrials = cumsum(corrTrialCts);

    end


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% ADD THESE FILES TO a.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if exist('a','var') == 0

        a = struct;

        a.files = files;
        a.numFiles = numFiles;
        a.allSummary = allSummary;
        a.data = allData;

        a.fileAll = allTrials(:,1);
        a.trialAll = allTrials(:,2);
        a.trialStartAll = allTrials(:,3);
        a.trialTypeAll = allTrials(:,4);
        a.initiatingCenterEntryAll = allTrials(:,5);
        a.firstCenterEntryAll = allTrials(:,6);
        a.firstCenterExitAll = allFirstCenterExits;
        a.centerEntryCtAll = allTrials(:,7);
        a.initiatingCenterExitAll = allTrials(:,8);
        a.goCueAll = allTrials(:,9);
        a.firstRewardEntryAll = allTrials(:,10);
        a.portChoiceAll = allTrials(:,11);
        a.correctAll = allTrials(:,12);
        a.firstRewardExitAll = allTrials(:,13);
        a.file = allCorrTrials(:,1);
        a.mouse = allMice;
        a.trial = allCorrTrials(:,2);
        a.trialStart = allCorrTrials(:,3);
        a.trialType = allCorrTrials(:,4);
        a.initiatingCenterEntry = allCorrTrials(:,5);
        a.firstCenterEntry = allCorrTrials(:,6);
        a.centerEntryCt = allCorrTrials(:,7);
        a.initiatingCenterExit = allCorrTrials(:,8);
        a.goCue = allCorrTrials(:,9);
        a.firstRewardEntry = allCorrTrials(:,10);
        a.portChoice = allCorrTrials(:,11);
        a.firstRewardExit = allCorrTrials(:,12);
        a.firstDwellTime = allCorrTrials(:,13);
        a.rewardSize = allCorrTrials(:,14);
        a.odor2 = allCorrTrials(:,15);
        a.rewardDelivery = allCorrTrials(:,16);
        a.rewardEntry = allCorrTrials(:,17);
        a.rewardExit = allCorrTrials(:,18);
        a.rewardEntryCt = allRewardEntryCount;
        a.complete = allCorrTrials(:,19);
        a.completeTime = allCorrTrials(:,20);
        a.info = allCorrTrials(:,21);
        a.type = allCorrTrials(:,22);
        a.lastType = allCorrTrials(:,23);
        a.anticipatoryLicks = allAnticipatoryLicks;
        a.betweenLicks = allBetweenLicks;
        a.earlyLicks = allEarlyLicks;
        a.waterLicks = allWaterLicks;
        a.rewardPortTime = allRewardPortTime;
        a.lickFile = allLicks(:,14);
        a.lickTime = allLicks(:,1);
        a.lickEntry = allLicks(:,3);
        a.lickTimeFromEntry = allLicks(:,7);
        a.lickCorrect = allLicks(:,5);
        a.lickPort = allLicks(:,6);
        a.lickEntryTime = allLicks(:,4);
        a.lickTrial = allLicks(:,2);
        a.lickTrialIdx = allLicks(:,8);
        a.lickTimeFromInitiatingCenterEntry = allLicks(:,11);
        a.lickTimeFromOutcome = allLicks(:,13);
        a.lickTrialType = allLicks(:,9);
        a.lickTrialPort = allLicks(:,10);
        a.centerEntriesFile = allCenterEntriesAllCorr(:,2);
        a.centerEntriesAll = allCenterEntriesAllCorr(:,1);
        a.centerExitsAll = allCenterEntriesAllCorr(:,3);
        a.allRewardEntriesFile = allRewardEntries(:,5);
        a.allRewardEntries = allRewardEntries(:,1);
        a.allRewardExits = allRewardEntries(:,2);
        a.allRewardEntriesCorrect = allRewardEntries(:,3);
        a.allRewardEntriesPort = allRewardEntries(:,4);
        a.corrTrialCts = corrTrialCts;
        a.trialLength = allTrialLength;
        a.reward = allReward;
        a.sideOdorOn = allSideOdorOns;
        a.centerOdorOn = allCenterOdorOns;
        a.centerEntriesCorr = allCenterEntriesCorr;
        a.rewardEntriesOdor = allRewardEntriesOdor;
        a.rewardEntryOdorOn = allRewardEntryOdorOn;
        
        a.images = allImages;

    else
        a.files = [a.files; files];
        a.numFiles = a.numFiles + numFiles;

        a.allSummary = [a.allSummary; allSummary];
        a.data = [a.data; allData];

        a.fileAll = [a.fileAll; allTrials(:,1) + max(a.fileAll)];
        a.trialAll = [a.trialAll; allTrials(:,2)];
        a.trialStartAll = [a.trialStartAll; allTrials(:,3)];
        a.trialTypeAll = [a.trialTypeAll; allTrials(:,4)];
        a.initiatingCenterEntryAll = [a.initiatingCenterEntryAll; allTrials(:,5)];
        a.firstCenterEntryAll = [a.firstCenterEntryAll; allTrials(:,6)];
        a.firstCenterExitAll = [a.firstCenterExitAll; allFirstCenterExits];
        a.centerEntryCtAll = [a.centerEntryCtAll; allTrials(:,7)];
        a.initiatingCenterExitAll = [a.initiatingCenterExitAll; allTrials(:,8)];
        a.goCueAll = [a.goCueAll; allTrials(:,9)];
        a.firstRewardEntryAll = [a.firstRewardEntryAll; allTrials(:,10)];
        a.portChoiceAll = [a.portChoiceAll; allTrials(:,11)];
        a.correctAll = [a.correctAll; allTrials(:,12)];
        a.firstRewardExitAll = [a.firstRewardExitAll; allTrials(:,13)];
        a.file = [a.file; allCorrTrials(:,1) + max(a.file)];
        a.mouse = [a.mouse; allMice];
        a.trial = [a.trial; allCorrTrials(:,2)];
        a.trialStart = [a.trialStart; allCorrTrials(:,3)];
        a.trialType = [a.trialType; allCorrTrials(:,4)];
        a.initiatingCenterEntry = [a.initiatingCenterEntry; allCorrTrials(:,5)];
        a.firstCenterEntry = [a.firstCenterEntry; allCorrTrials(:,6)];
        a.centerEntryCt = [a.centerEntryCt; allCorrTrials(:,7)];
        a.initiatingCenterExit = [a.initiatingCenterExit; allCorrTrials(:,8)];
        a.goCue = [a.goCue; allCorrTrials(:,9)];
        a.firstRewardEntry = [a.firstRewardEntry; allCorrTrials(:,10)];
        a.portChoice = [a.portChoice; allCorrTrials(:,11)];
        a.firstRewardExit = [a.firstRewardExit; allCorrTrials(:,12)];
        a.firstDwellTime = [a.firstDwellTime; allCorrTrials(:,13)];
        a.rewardSize = [a.rewardSize; allCorrTrials(:,14)];
        a.odor2 = [a.odor2; allCorrTrials(:,15)];
        a.rewardDelivery = [a.rewardDelivery; allCorrTrials(:,16)];
        a.rewardEntry = [a.rewardEntry; allCorrTrials(:,17)];
        a.rewardExit = [a.rewardExit; allCorrTrials(:,18)];
        a.rewardEntryCt = [a.rewardEntryCt; allRewardEntryCount];
        a.complete = [a.complete; allCorrTrials(:,19)];
        a.completeTime = [a.completeTime; allCorrTrials(:,20)];
        a.info = [a.info; allCorrTrials(:,21)];
        a.type = [a.type; allCorrTrials(:,22)];
        a.lastType = [a.lastType; allCorrTrials(:,23)];
        a.anticipatoryLicks = [a.anticipatoryLicks; allAnticipatoryLicks];
        a.betweenLicks = [a.betweenLicks; allBetweenLicks];
        a.earlyLicks = [a.earlyLicks; allEarlyLicks];
        a.waterLicks = [a.waterLicks; allWaterLicks];
        a.rewardPortTime = [a.rewardPortTime; allRewardPortTime];    
        a.lickFile = [a.lickFile; allLicks(:,14)];
        a.lickTime = [a.lickTime; allLicks(:,1)];
        a.lickEntry = [a.lickEntry; allLicks(:,3)];
        a.lickTimeFromEntry = [a.lickTimeFromEntry; allLicks(:,7)];
        a.lickCorrect = [a.lickCorrect; allLicks(:,5)];
        a.lickPort = [a.lickPort; allLicks(:,6)];
        a.lickEntryTime = [a.lickEntryTime; allLicks(:,4)];
        a.lickTrial = [a.lickTrial; allLicks(:,2)];
        a.lickTrialIdx = [a.lickTrialIdx; allLicks(:,8)];
        a.lickTimeFromInitiatingCenterEntry = [a.lickTimeFromInitiatingCenterEntry; allLicks(:,10)];
        a.lickTrialType = [a.lickTrialType; allLicks(:,9)];
        a.lickTrialPort = [a.lickTrialPort; allLicks(:,10)];
        a.lickTimeFromOutcome = [a.lickTimeFromOutcome; allLicks(:,13)];
        a.centerEntriesFile = [a.centerEntriesFile; allCenterEntriesAllCorr(:,2)];
        a.centerEntriesAll = [a.centerEntriesAll; allCenterEntriesAllCorr(:,1)];
        a.centerExitsAll = [a.centerExitsAll; allCenterEntriesAllCorr(:,3)];
        a.allRewardEntriesFile = [a.allRewardEntriesFile; allRewardEntries(:,5)];
        a.allRewardEntries = [a.allRewardEntries; allRewardEntries(:,1)];
        a.allRewardExits = [a.allRewardExits; allRewardEntries(:,2)];
        a.allRewardEntriesCorrect = [a.allRewardEntriesCorrect; allRewardEntries(:,3)];
        a.allRewardEntriesPort = [a.allRewardEntriesPort; allRewardEntries(:,4)];
        a.corrTrialCts = [a.corrTrialCts corrTrialCts];
        a.trialLength = [a.trialLength; allTrialLength];
        a.reward = [a.reward; allReward];
        a.sideOdorOn = [a.sideOdorOn; allSideOdorOns];
        a.centerOdorOn = [a.centerOdorOn; allCenterOdorOns];
        a.centerEntriesCorr = [a.centerEntriesCorr; allCenterEntriesCorr];
        a.rewardEntriesOdor = [a.rewardEntriesOdor; allRewardEntriesOdor];
        a.rewardEntryOdorOn = [a.rewardEntryOdorOn; allRewardEntryOdorOn];
        
        a.images = [a.images; allImages];
        
    end
end

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  ANALYSIS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%

% DAYS

% assign day to each trial
days = a.allSummary(:,3);
% find unique days since multiple sessions some days
days = unique(days);
% assign numeric day to each file
for s = 1:size(a.allSummary,1)
   a.allSummary{s,30} = find(ismember(days,a.allSummary{s,3})); 
   a.files(f).day =a.allSummary{s,30};
end

a.fileDays = cell2mat(a.allSummary(:,30));

a.day=a.fileDays(a.file);

% %%%% CHANGED
% for t = 1:size(a.file,1)
%     a.day(t) = 1;
% %     a.day(t) = a.fileDays(a.file(t));
% end


%%
a.allTrialCt = size(a.fileAll,1);
a.allCorrTrialCt = size(a.file,1);
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ALL TRIALS

a.choice = a.trialTypeAll == 1;
a.infoForced = a.trialTypeAll == 2;
a.randForced = a.trialTypeAll == 3;

a.choiceTypeNames = {'InfoForced','RandForced','Choice'};
a.choiceTypeCts = [sum(a.infoForced) sum(a.randForced) sum(a.choice)];

% figure();
% bar(choiceTypeCts);
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
a.infoCorrTrials = a.info == 1;
a.randCorrTrials = a.info == 0;

type = a.type;
infoType = a;

   
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


%%
% BY PREVIOUS TRIAL

a.infoBigBefore = a.lastType == 1 | a.lastType == 5;
a.infoSmallBefore= a.lastType == 2 | a.lastType == 6;
a.randBigBefore = a.lastType == 3| a.lastType == 7;
a.randSmallBefore = a.lastType == 4| a.lastType == 8;

beforeType = a.lastType;
a.beforeTypeNames = {'InfoBigBefore','InfoSmallBefore','RandBigBefore',...
    'RandSmallBefore'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%
a.numFiles = size(a.files,1);

a.mouseList = unique(a.mouse);
a.mouseCt = size(a.mouseList,1);

a.mice = [];
for m = 1:a.mouseCt
  a.mice(:,m) = strcmp(a.mouse,a.mouseList(m))==1;
end

%%
a.dayCell = a.allSummary(:,3);
a.miceCell = a.allSummary(:,2);

for m = 1:a.mouseCt
   mouseFileIdx = strcmp(a.miceCell,a.mouseList{m});
   a.mouseDays{m} = unique(a.dayCell(mouseFileIdx));
   a.mouseDayCt(m) = size(a.mouseDays{m},1);
end

for fm = 1:a.numFiles
   a.fileMouse(fm) = find(strcmp(a.allSummary(fm,2),a.mouseList));
   a.fileDay(fm) = find(strcmp(a.allSummary(fm,3),a.mouseDays{1,a.fileMouse(fm)})); 
end

for tf = 1:size(a.file,1) % for each trial
   a.mouseDay(tf,1) = a.fileDay(a.file(tf));
%    a.mouseDay(tf,1) = 1;
end

% a.mouseDay = a.mouseDay';
% THIS IS IMPORTANT--WHAT DAY IT IS IN THAT MOUSE'S TRAINING

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
       a.typeSizesa.mouseDays(d,:,m) = [sum(a.infoBig(ok)) sum(a.infoSmall(ok)) sum(a.randBig(ok)) sum(a.randSmall(ok))];
       a.choiceTypeSizesa.mouseDays(d,:,m) = [sum(a.infoForcedCorr(ok)) sum(a.infoChoiceCorr(ok)) sum(a.randForcedCorr(ok)) sum(a.randChoiceCorr(ok))];
    end
end

%% LICK INDEX
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for f = 1:a.numFiles
    a.odorA(f,1) = cell2mat(a.allSummary(f,12));
    a.odorB(f,1) = cell2mat(a.allSummary(f,13));
    a.odorC(f,1) = cell2mat(a.allSummary(f,14));
    a.odorD(f,1) = cell2mat(a.allSummary(f,15));
    
end

for t = 1:a.allCorrTrialCt
    trialFile = a.file(t);
    a.odorAtrials(t,1) = a.odor2(t) == a.odorA(trialFile);
    a.odorBtrials(t,1) = a.odor2(t) == a.odorB(trialFile);
    a.odorCtrials(t,1) = a.odor2(t) == a.odorC(trialFile);
    a.odorDtrials(t,1) = a.odor2(t) == a.odorD(trialFile);
end
    

for m = 1:a.mouseCt
    for d = 1:a.mouseDayCt(m)
        ok = a.mouseDay == d & a.mice(:,m) == 1;
        a.Alicks(m,d) = sum(a.anticipatoryLicks(a.odorAtrials & ok));
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

%%  LICK ANALYSIS FOR ALL FILES

lickCorrTrials = a.lickTrialIdx>0;
trialLickCt = sum(lickCorrTrials);

a.lickCorrFiles = a.lickFile(lickCorrTrials);
a.lickCorrTrialNums = a.lickTrial(lickCorrTrials);
a.lickCorrTrialIdx = a.lickTrialIdx(lickCorrTrials);
a.lickCorrTypes = a.lickTrialType(lickCorrTrials);
a.lickCorrTime = a.lickTimeFromInitiatingCenterEntry(lickCorrTrials);
a.lickCorrOutcomeTime = a.lickTimeFromOutcome(lickCorrTrials);

%% DAY SUMMARY
for m = 1:a.mouseCt
    for d = 1:a.mouseDayCt(m)
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
        a.daySummary.percentInfo{m,d} = mean(a.info(ok & a.trialType == 1));
        a.daySummary.infoBigLicks{m,d} = a.AlicksBetween(m,d)/sum(a.odorAtrials & ok);
        a.daySummary.infoSmallLicks{m,d} = a.BlicksBetween(m,d)/sum(a.odorBtrials & ok);
        a.daySummary.randCLicks{m,d} = a.ClicksBetween(m,d)/sum(a.odorCtrials & ok);
        a.daySummary.randDLicks{m,d} = a.DlicksBetween(m,d)/sum(a.odorDtrials & ok);
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
        a.daySummary.trialLengthInfoForced{m,d} = nansum(a.trialLength(a.infoForcedCorr == 1 & ok == 1))/sum(~isnan(a.trialLength(a.infoForcedCorr == 1 & ok == 1)));
        a.daySummary.trialLengthInfoChoice{m,d} = nansum(a.trialLength(a.infoChoiceCorr == 1 & ok == 1))/sum(~isnan(a.trialLength(a.infoChoiceCorr == 1 & ok == 1)));
        a.daySummary.trialLengthRandForced{m,d} = nansum(a.trialLength(a.randForcedCorr == 1 & ok == 1))/sum(~isnan(a.trialLength(a.randForcedCorr == 1 & ok == 1)));
        a.daySummary.trialLengthRandChoice{m,d} = nansum(a.trialLength(a.randChoiceCorr == 1 & ok == 1))/sum(~isnan(a.trialLength(a.randChoiceCorr == 1 & ok == 1)));
        a.daySummary.completeInfoBig{m,d} = mean(a.complete(a.infoBig == 1 & ok == 1));
%         a.daySummary.completeInfoSmall{m,d} = sum(a.complete(a.infoSmall(ok)))/sum(a.infoSmall(ok));
        a.daySummary.completeInfoSmall{m,d} = mean(a.complete(a.infoSmall == 1 & ok == 1));
        a.daySummary.completeRandBig{m,d} = mean(a.complete(a.randBig == 1 & ok == 1));
        a.daySummary.completeRandSmall{m,d} = mean(a.complete(a.randSmall == 1 & ok == 1));
        a.daySummary.rewardInfoForced{m,d} = sum(a.reward(a.infoForcedCorr == 1 & ok == 1))/sum(a.infoForcedCorr(ok));
        a.daySummary.rewardInfoChoice{m,d} = sum(a.reward(a.infoChoiceCorr == 1 & ok == 1))/sum(a.infoChoiceCorr(ok));
        a.daySummary.rewardRandForced{m,d} = sum(a.reward(a.randForcedCorr == 1 & ok == 1))/sum(a.randForcedCorr(ok));
        a.daySummary.rewardRandChoice{m,d} = sum(a.reward(a.randChoiceCorr == 1 & ok == 1))/sum(a.randChoiceCorr(ok));
        a.daySummary.rewardRateInfoForced{m,d} = sum(a.reward(a.infoForcedCorr == 1 & ok == 1)) / nansum(a.trialLength(a.infoForcedCorr == 1 & ok == 1))*1000;
        a.daySummary.rewardRateInfoChoice{m,d} = sum(a.reward(a.infoChoiceCorr == 1 & ok == 1)) / nansum(a.trialLength(a.infoChoiceCorr == 1 & ok == 1))*1000;
        a.daySummary.rewardRateRandForced{m,d} = sum(a.reward(a.randForcedCorr == 1 & ok == 1)) / nansum(a.trialLength(a.randForcedCorr == 1 & ok == 1))*1000;
        a.daySummary.rewardRateRandChoice{m,d} = sum(a.reward(a.randChoiceCorr == 1 & ok == 1)) / nansum(a.trialLength(a.randChoiceCorr == 1 & ok == 1))*1000;        
%         a.daySummary.rewardRateInfoForced{m,d} = a.daySummary.rewardInfoForced{m,d}/a.daySummary.trialLengthInfoForced{m,d};
%         a.daySummary.rewardRateInfoChoice{m,d} = a.daySummary.rewardInfoChoice{m,d}/a.daySummary.trialLengthInfoChoice{m,d};
%         a.daySummary.rewardRateRandForced{m,d} = a.daySummary.rewardRandForced{m,d}/a.daySummary.trialLengthRandForced{m,d};
%         a.daySummary.rewardRateRandChoice{m,d} = a.daySummary.rewardRandChoice{m,d}/a.daySummary.trialLengthRandChoice{m,d};
    end
end


%% MOUSE LICKING SUMMARY

for m = 1:a.mouseCt
    mouseCellLicks{m}(1,:)= cell2mat(a.daySummary.infoBigLicks(m,:));
    mouseCellLicks{m}(2,:)= cell2mat(a.daySummary.infoSmallLicks(m,:));
    mouseCellLicks{m}(3,:)= cell2mat(a.daySummary.randCLicks(m,:));    
    mouseCellLicks{m}(4,:)= cell2mat(a.daySummary.randDLicks(m,:));
    
   mouseLicks{1,:,m} = a.daySummary.infoBigLicks(m,:); 
   mouseLicks{2,:,m} = a.daySummary.infoSmallLicks(m,:);
   mouseLicks{3,:,m} = a.daySummary.randCLicks(m,:);
   mouseLicks{4,:,m} = a.daySummary.randDLicks(m,:);   
end

%%
% PLOTTING

a.mColors = [0 176 80; 255 0 0; 0 176 240; 112 48 160; 234 132 20; 255 255 0; 204 0 204];
a.mColors = a.mColors./255;

dx = 0.2;
dy = 0.02;

odorDelay = 1300;
rewardWait = 3100;

plots = [1 1; 1 2; 2 1; 2 2];

purple = [121 32 196] ./ 255;
orange = [251 139 6] ./ 255;


%% PLOT DAY SUMMARIES BY MOUSE

for m = 1:a.mouseCt
    figure();
    
    fig = gcf;
    fig.PaperUnits = 'inches';
    fig.PaperPosition = [1 1 7 9];
    set(fig,'renderer','painters')
    
    ax = nsubplot(7,1,1,1);
    title(a.mouseList(m));
    ax.FontSize = 10;
%     ax.XTick = [1:5:a.mouseDayCt(m)];    
    ax.YTick = [0 0.25 0.50 0.75 1];
    ax.YLim = [0 1];
    plot(1:a.mouseDayCt(m),[cell2mat(a.daySummary.percentInfo(m,:))],'Color',a.mColors(m,:),'LineWidth',2,'Marker','o','MarkerFaceColor',a.mColors(m,:),'MarkerSize',4);
    plot([-10000000 1000000],[0.5 0.5],'k','xliminclude','off','color',[0.6 0.6 0.6],'LineWidth',2);
    plot([a.reverseDay(m)-0.5 a.reverseDay(m)-0.5],[-10000000 1000000],'k','yliminclude','off','xliminclude','off','LineWidth',4);
    ylabel('Info choice probability');
    xlabel('Day');
    hold off;

    ax = nsubplot(7,1,2,1);
    ax.FontSize = 10;
    ax.XTick = [0:5:max(cell2mat(a.daySummary.day(m,:)))];
    ax.YLim = [0 inf];
    plot(cell2mat(a.daySummary.randCLicks(m,:)),'Color','c','LineWidth',2,'Marker','o','MarkerFaceColor','c','MarkerSize',3);
    plot(cell2mat(a.daySummary.randDLicks(m,:)),'Color','b','LineWidth',2,'Marker','o','MarkerFaceColor','b','MarkerSize',3);
    plot(cell2mat(a.daySummary.infoBigLicks(m,:)),'Color','g','LineWidth',2,'Marker','o','MarkerFaceColor','g','MarkerSize',3);
    plot(cell2mat(a.daySummary.infoSmallLicks(m,:)),'Color','m','LineWidth',2,'Marker','o','MarkerFaceColor','m','MarkerSize',3);
    plot([a.reverseDay(m)-0.5 a.reverseDay(m)-0.5],[-10000000 1000000],'k','yliminclude','off','xliminclude','off','LineWidth',4);        
    ylabel('Anticipatory lick rate');
%     xlabel('Day');
    leg = legend(ax,'No Info - C','No Info - D','Info-Rew','Info-No Rew','Location','best','Orientation','horizontal');
    leg.Box = 'off';
    leg.FontWeight = 'bold';
    hold off;
    
    ax = nsubplot(7,1,3,1);
    ax.FontSize = 10;
    ax.XTick = [0:5:max(cell2mat(a.daySummary.day(m,:)))];
    ax.YLim = [0 inf];
    plot(cell2mat(a.daySummary.infoBigLicksWater(m,:)),'Color','g','LineWidth',2,'Marker','o','MarkerFaceColor','g','MarkerSize',3);
    plot(cell2mat(a.daySummary.infoSmallLicksWater(m,:)),'Color','m','LineWidth',2,'Marker','o','MarkerFaceColor','m','MarkerSize',3);
    plot(cell2mat(a.daySummary.randBigLicksWater(m,:)),'Color','c','LineWidth',2,'Marker','o','MarkerFaceColor','c','MarkerSize',3);
    plot(cell2mat(a.daySummary.randSmallLicksWater(m,:)),'Color','b','LineWidth',2,'Marker','o','MarkerFaceColor','b','MarkerSize',3);
    plot([a.reverseDay(m)-0.5 a.reverseDay(m)-0.5],[-10000000 1000000],'k','yliminclude','off','xliminclude','off','LineWidth',4);        
    ylabel('Post-outcome lick rate');
%     xlabel('Day');
    leg = legend(ax,'Info-Rew','Info-No Rew','No Info - Rew','No Info - No Rew','Location','best','Orientation','horizontal');
    leg.Box = 'off';
    leg.FontWeight = 'bold';
    hold off;
    
    ax = nsubplot(7,1,4,1);
    ax.FontSize = 10;
    ax.XTick = [0:5:max(cell2mat(a.daySummary.day(m,:)))];
    ax.YLim = [0 1];
    plot(cell2mat(a.daySummary.ARewards(m,:)),'Color','g','LineWidth',2,'Marker','o','MarkerFaceColor','g','MarkerSize',3);
    plot(cell2mat(a.daySummary.BRewards(m,:)),'Color','m','LineWidth',2,'Marker','o','MarkerFaceColor','m','MarkerSize',3);
    plot(cell2mat(a.daySummary.CRewards(m,:)),'Color','c','LineWidth',2,'Marker','o','MarkerFaceColor','c','MarkerSize',3);
    plot(cell2mat(a.daySummary.DRewards(m,:)),'Color','b','LineWidth',2,'Marker','o','MarkerFaceColor','b','MarkerSize',3);
    plot([a.reverseDay(m)-0.5 a.reverseDay(m)-0.5],[-10000000 1000000],'k','yliminclude','off','xliminclude','off','LineWidth',4);        
    ylabel('Reward Probability');
%     xlabel('Day');
    leg = legend(ax,'Info-Rew','Info-No Rew','No Info - C','No Info - D','Location','best','Orientation','horizontal');
    leg.Box = 'off';
    leg.FontWeight = 'bold';
    hold off;

    ax = nsubplot(7,1,5,1);
    ax.FontSize = 10;
    ax.XTick = [0:5:max(cell2mat(a.daySummary.day(m,:)))];
    ax.YTick = [0 0.25 0.50 0.75 1];
    ax.YLim = [0 1];
    plot(cell2mat(a.daySummary.completeRandBig(m,:)),'Color','c','LineWidth',2,'Marker','o','MarkerFaceColor','c','MarkerSize',3);
    plot(cell2mat(a.daySummary.completeRandSmall(m,:)),'Color','b','LineWidth',2,'Marker','o','MarkerFaceColor','b','MarkerSize',3);
    plot(cell2mat(a.daySummary.completeInfoBig(m,:)),'Color','g','LineWidth',2,'Marker','o','MarkerFaceColor','g','MarkerSize',3);
    plot(cell2mat(a.daySummary.completeInfoSmall(m,:)),'Color','m','LineWidth',2,'Marker','o','MarkerFaceColor','m','MarkerSize',3);    
    plot([a.reverseDay(m)-0.5 a.reverseDay(m)-0.5],[-10000000 1000000],'k','yliminclude','off','xliminclude','off','LineWidth',4);
    ylabel('% staying in port');
%     xlabel('Day');    
    leg = legend(ax,'No Info - Rew','No Info - No rew','Info-Rew','Info-No Rew','Location','best','Orientation','horizontal');
    leg.Box = 'off';
    leg.FontWeight = 'bold';
    hold off;

    ax = nsubplot(7,1,6,1);
    ax.FontSize = 10;
    ax.XTick = [0:5:max(cell2mat(a.daySummary.day(m,:)))];
    ax.YLim = [0 10000];
    plot(cell2mat(a.daySummary.trialLengthInfoForced(m,:)),'Color',orange,'LineWidth',2,'Marker','o','MarkerFaceColor',orange,'MarkerSize',3);
    plot(cell2mat(a.daySummary.trialLengthInfoChoice(m,:)),'Color',orange,'LineWidth',2,'Marker','o','MarkerFaceColor',orange,'MarkerSize',3,'LineStyle',':');
    plot(cell2mat(a.daySummary.trialLengthRandForced(m,:)),'Color',purple,'LineWidth',2,'Marker','o','MarkerFaceColor',purple,'MarkerSize',3);
    plot(cell2mat(a.daySummary.trialLengthRandChoice(m,:)),'Color',purple,'LineWidth',2,'Marker','o','MarkerFaceColor',purple,'MarkerSize',3,'LineStyle',':');
    plot([a.reverseDay(m)-0.5 a.reverseDay(m)-0.5],[-10000000 1000000],'k','yliminclude','off','xliminclude','off','LineWidth',4);
    ylabel('Trial duration(ms)');
%     xlabel('Day');
    leg = legend(ax,'Info Forced','Info Choice','No Info Forced','No Info Choice','Location','best','Orientation','horizontal');
    leg.Box = 'off';
    leg.FontWeight = 'bold';
    hold off;
    
    ax = nsubplot(7,1,7,1);
    ax.FontSize = 10;
    ax.XTick = [0:5:max(cell2mat(a.daySummary.day(m,:)))];
    ax.YLim = [0 0.5];
    plot(cell2mat(a.daySummary.rewardRateInfoForced(m,:)),'Color',orange,'LineWidth',2,'Marker','o','MarkerFaceColor',orange,'MarkerSize',3);
    plot(cell2mat(a.daySummary.rewardRateInfoChoice(m,:)),'Color',orange,'LineWidth',2,'Marker','o','MarkerFaceColor',orange,'MarkerSize',3,'LineStyle',':');
    plot(cell2mat(a.daySummary.rewardRateRandForced(m,:)),'Color',purple,'LineWidth',2,'Marker','o','MarkerFaceColor',purple,'MarkerSize',3);
    plot(cell2mat(a.daySummary.rewardRateRandChoice(m,:)),'Color',purple,'LineWidth',2,'Marker','o','MarkerFaceColor',purple,'MarkerSize',3,'LineStyle',':');
    plot([a.reverseDay(m)-0.5 a.reverseDay(m)-0.5],[-10000000 1000000],'k','yliminclude','off','xliminclude','off','LineWidth',4);
    ylabel('Reward Rate');
%     xlabel('Day');    
    leg = legend(ax,'Info Forced','Info Choice','No Info Forced','No Info Choice','Location','best','Orientation','horizontal');
    leg.Box = 'off';
    leg.FontWeight = 'bold';
    hold off;
end

%% SINGLE DAY PLOTS !!! ONLY FOR FIRST DAY !!!


for m = 1:a.mouseCt
    if a.mouseDayCt(m) == 1
        for d = 1:a.mouseDayCt(m)
    figure();   
    fig = gcf;
    fig.PaperUnits = 'inches';
    fig.PaperPosition = [1 1 7 9];
    set(fig,'renderer','painters')
    ax = nsubplot(1,1,1,1);
    ax.FontSize = 10;
    ax.YLim = [0 inf];
    title(a.mouseList(m));
    bar([a.daySummary.infoBigLicks{m,d},a.daySummary.infoSmallLicks{m,d},a.daySummary.randCLicks{m,d},a.daySummary.randDLicks{m,d}]);        
    ylabel('Anticipatory lick rate');
    ax.XTick = [1:4];
    ax.XTickLabel = {'Info Water', 'Info No Water', 'Rand C', 'Rand D'};
    hold off;
    
    figure();   
    fig = gcf;
    fig.PaperUnits = 'inches';
    fig.PaperPosition = [1 1 7 9];
    set(fig,'renderer','painters')
    ax = nsubplot(1,1,1,1);
    ax.FontSize = 10;
    ax.YLim = [0 inf];
    title(a.mouseList(m));
    bar([a.daySummary.infoBigLicksWater{m,d},a.daySummary.infoSmallLicksWater{m,d},a.daySummary.randCLicksWater{m,d},a.daySummary.randDLicksWater{m,d}]);        
    ylabel('Consummatory lick rate');
    ax.XTick = [1:4];
    ax.XTickLabel = {'Info Water', 'Info No Water', 'Rand C', 'Rand D'};
    hold off;
        end
    end
end

%%
% SAVE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

uisave({'a'},'infoSeekData.mat');

