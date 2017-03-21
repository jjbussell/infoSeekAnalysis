%% TO FIX

% a.fileAll uses file nums from current batch not total/cumulative!!
% trials that get started but don't get to trialParams
% (['JB167_2017-03-14_11h-05m-02s.csv'] orig)

%%
clear;
close all;

% MAKE DYNAMIC
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
        data = csvread(fname,27,0);
        sessionParams(:,f) = csvread(fname,1,1,[1,1,26,1]); % report           
           
        b = struct;

        infoSide = sessionParams(5,f);
        info = ports(infoSide+1); % set for each session
        rand = setdiff(ports,info);
        odorDelay = sessionParams(16,f);
        odorTime = sessionParams(17,f);
        rewardDelay = sessionParams(18,f);
        interval = sessionParams(24,f);

% SAVE SESSION PARAMETERS
        sessionLength = (data(end,1)-data(1,1))/1000; % report
        totalTime = data(end,1);

        sessionParameters = cat(2, sessionParams(:,f)', sessionLength);
        sessionParameters = num2cell(sessionParameters);
        sessionParameters = [filename,mouse,day,sessionParameters];
        
        files(f).name = files(f).name;
    %     files(f).folder = files(f).folder;
        files(f).date = files(f).date;
        files(f).bytes = files(f).bytes;
        files(f).totalTime = totalTime;
        files(f).isdir = files(f).isdir;
        files(f).datenum = files(f).datenum;
        files(f).day = day;
        files(f).mouseName = cellstr(filename(1:dayPlace-1));
        files(f).sessionLength = sessionLength;
        files(f).infoSide = infoSide;
        files(f).info = info;
        files(f).rand = rand;
        files(f).odorDelay = odorDelay;
        files(f).odorTime = odorTime;
        files(f).rewardDelay = rewardDelay;
        files(f).interval = interval;
        files(f).odors = sessionParams([6:12],f);
        files(f).centerDelay = sessionParams(13,f);
        files(f).centerOdorTime = sessionParams(14,f);
        files(f).startDelay = sessionParams(15,f);
        files(f).bigRewardTime = sessionParams(19,f);
        files(f).smallRewardTime = sessionParams(20,f);
        files(f).infoRewardProb = sessionParams(21,f);
        files(f).randRewardProb = sessionParams(22,f);
        files(f).gracePeriod = sessionParams(23,f);
        files(f).timeout = sessionParams(26,f);
        if isfield(files, 'folder')
            files = rmfield(files,'folder');
        end


%% TRIAL COUNTS

        trialCt = max(data(:,2));
        b.trialNums(:,1) = 1:trialCt;
        
        trialStarts = data(data(:,3) == 10,:);
        b.trialStart = data(data(:,3) == 10,:);
        
        % + numFiles
        b.fileAll(1:trialCt,1) = f;
        
        
%% STATE TRANSITIONS (real time)

        transitions = [];
        transitions = data(data(:,3) == 22,:);
        transitions = [zeros(size(transitions,1),1) transitions];
        transitions(:,1) = f;
        
% These changed when states changed!
% FIRST
% 9_10	response to waitforodor
% 9_11	response to grace
% 11_10	grace to wait for odor
% 11_16	grace to timeout
% 
% THEN March 14-19?	
% 	
% 9_11	response to waitforodor
% 9_10	response to grace
% 10_16	grace to timeout
% 10_12	grace to sideodor

        
        b.txn0_1 = transitions(transitions(:,5) == 0 & transitions(:,6) == 1,[1 2 3 5 6]);
        b.txn1_2 = transitions(transitions(:,5) == 1 & transitions(:,6) == 2,[1 2 3 5 6]);
        b.txn2_3 = transitions(transitions(:,5) == 2 & transitions(:,6) == 3,[1 2 3 5 6]);
        b.txn3_4 = transitions(transitions(:,5) == 3 & transitions(:,6) == 4,[1 2 3 5 6]);
        b.txn4_5 = transitions(transitions(:,5) == 4 & transitions(:,6) == 5,[1 2 3 5 6]);
        b.txn5_6 = transitions(transitions(:,5) == 5 & transitions(:,6) == 6,[1 2 3 5 6]);
        b.txn6_7 = transitions(transitions(:,5) == 6 & transitions(:,6) == 7,[1 2 3 5 6]);
        b.txn7_8 = transitions(transitions(:,5) == 7 & transitions(:,6) == 8,[1 2 3 5 6]);
        b.txn8_9 = transitions(transitions(:,5) == 8 & transitions(:,6) == 9,[1 2 3 5 6]);
        b.txn9_11 = transitions(transitions(:,5) == 9 & transitions(:,6) == 11,[1 2 3 5 6]);
        b.txn9_10 = transitions(transitions(:,5) == 9 & transitions(:,6) == 10,[1 2 3 5 6]);
        b.txn10_12 = transitions(transitions(:,5) == 10 & transitions(:,6) == 12,[1 2 3 5 6]);
        b.txn11_12 = transitions(transitions(:,5) == 11 & transitions(:,6) == 12,[1 2 3 5 6]);
        b.txn12_13 = transitions(transitions(:,5) == 12 & transitions(:,6) == 13,[1 2 3 5 6]);
        b.txn13_14 = transitions(transitions(:,5) == 13 & transitions(:,6) == 14,[1 2 3 5 6]);
        b.txn14_15 = transitions(transitions(:,5) == 14 & transitions(:,6) == 15,[1 2 3 5 6]);
        b.txn15_0 = transitions(transitions(:,5) == 15 & transitions(:,6) == 0,[1 2 3 5 6]);
        b.txn4_3 = transitions(transitions(:,5) == 4 & transitions(:,6) == 3,[1 2 3 5 6]);
        b.txn5_3 = transitions(transitions(:,5) == 5 & transitions(:,6) == 3,[1 2 3 5 6]);
        b.txn6_3 = transitions(transitions(:,5) == 5 & transitions(:,6) == 3,[1 2 3 5 6]);
        b.txn10_11 = transitions(transitions(:,5) == 10 & transitions(:,6) == 11,[1 2 3 5 6]);
        b.txn11_10 = transitions(transitions(:,5) == 11 & transitions(:,6) == 10,[1 2 3 5 6]);
        b.txn11_16 = transitions(transitions(:,5) == 11 & transitions(:,6) == 16,[1 2 3 5 6]);
        b.txn10_16 = transitions(transitions(:,5) == 10 & transitions(:,6) == 16,[1 2 3 5 6]);
        b.txn16_15 = transitions(transitions(:,5) == 16 & transitions(:,6) == 15,[1 2 3 5 6]);        

        
%% ENTRIES AND EXITS

        entries = [];
        exits = [];
        centerEntries = [];
        centerExits = [];
        rewardEntries = [];
        rewardExits = [];

        entries = data(data(:,3) == 2,:);
        exits = data(data(:,3) == 6,:);
        
        entries = [zeros(size(entries,1),1) entries];
        entries(:,1) = f;
        
        exits = [zeros(size(exits,1),1) exits];
        exits(:,1) = f;        
        
        centerEntries = entries(entries(:,5) == 4,:);
        rewardEntries = entries(entries(:,5) ~= 4,:);
        centerExits = exits(exits(:,5) == 4,:);
        rewardExits = exits(exits(:,5) ~= 4,:);


%%  CENTER ENTRIES

        % match exit--is this necessary?
        for e = 1:size(centerEntries,1)
            centerExitDiff = centerExits(:,2) - centerEntries(e,2);
            centerExitDiff(centerExitDiff < 0) = inf;
            [centerExitVal,centerExitIdx] = min(centerExitDiff);
            if isinf(centerExitVal)
                centerEntries(e,7) = totalTime;
            else
                centerEntries(e,7) = centerExits(centerExitIdx,2); % matching center exit
            end
        end

        % CENTER DWELL TIME
        centerEntries(:,8) = centerEntries(:,7) - centerEntries(:,2); % dwell time
        
        % SAVE ENTRIES AND EXITS TO DATA
        b.centerEntries = centerEntries;
        
%% GO_CUE

        b.goCue = b.txn7_8;
        
        % maybe this is counterproductive? Added to create gocue where
        % there is none, but maybe it's bad?
        if size(b.goCue,1) < trialCt
            b.goCue = [b.goCue; [f totalTime trialCt 0 0]];
        end
        b.goParams = data(data(:,3) == 1, :);
        b.goParams = [zeros(size(b.goParams,1),1) b.goParams];
        b.goParams(:,1) = f;        
        if size(b.goParams,1) < trialCt
            b.goParams = [b.goParams; [f totalTime trialCt 0 0 0]];
        end        
        
%% CHOICE

% Code for choice, includes timeout
% 1 = info, 0 = rand, 2 = none (timeout), 3 = incorrect (2 and 3 are errors)
% in trials during grace period changes, 2 == chose during grace

        b.choices = data(data(:,3) == 11, [1 2 4]);
        b.chose = ismember(b.trialNums,b.choices(:,2));
        b.choseTrialCt = sum(b.chose);
        
        b.choice = nan(trialCt,4);
        b.choice(:,1) = f; 
        b.choice(:,3) = b.trialNums;
        b.choice(b.chose,[2 4]) = b.choices(:,[1 3]);
        b.choice(~b.chose,4) = 2;
        
        % set choice time for non-choosing trials to max of response
        % (leaves out grace period)
        b.choice(~b.chose,2) = b.goCue(~b.chose,2) + odorDelay;

        
%% REACTION TIME / CHOICE

        b.choiceTime = b.choice(:,2);

        b.correct = b.choice(:,4) < 2;
        b.corrTrialCt = sum(b.correct);
        b.corrTrials = b.trialNums(b.correct);
        b.file = b.fileAll(b.correct);
        
        b.choiceCorr = b.choice(b.correct,4);

        b.gotToChoose = ismember(b.goCue(:,3),b.choice(:,3));
        b.rxn = NaN(trialCt,1);
        b.rxn(b.gotToChoose) = b.choiceTime - b.goCue(b.gotToChoose,2);             
        
%% CENTER ENTRY FIRST AND FOR GO CUE
        
        for r = 1:trialCt
            b.centerEntryGo(r,1) = f;
            b.centerExitGo(r,1) = f;
            b.centerEntryCt(r,1) = f;
            
            if size(b.goCue,1) >= trialCt % if there is a complete center entry in that trial
                centerEntryGoDiff =  b.goCue(r,2) - b.centerEntries(:,2); % find entry just before go cue
                centerEntryGoDiff(centerEntryGoDiff < 0) = inf;
                [centerEntryVal,centerEntryGoIdx] = min(centerEntryGoDiff);
                if isinf(centerEntryVal)
                   b.centerEntryGo(r,2) = 0;
                   b.centerExitGo(r,2) = 0;
                else
                   b.centerEntryGo(r,[2 3]) = b.centerEntries(centerEntryGoIdx,[3 2]);
                   b.centerExitGo(r,[2 3]) = b.centerEntries(centerEntryGoIdx,[3 7]);
                end

            else
                b.centerEntryGo(r,[2 3]) = 0;
                b.centerExitGo(r,[2 3]) = 0;
                b.centerEntryCt(r,2) = 0;
            end
            
            if ~isempty(b.centerEntries(:,3) == r) & ~isempty(find(b.txn3_4(:,3) == r))
                b.firstCenterEntryTxn(r,1) = b.txn3_4(find(b.txn3_4(:,3) == r,1,'first'),2);
            else
                b.firstCenterEntryTxn(r,1) = 0;
            end
            
            centerEntryFirstDiff = b.firstCenterEntryTxn(r,1) - b.centerEntries(:,2);
            centerEntryFirstDiff(centerEntryFirstDiff < 0) = inf;
            [centerEntryFirstVal, centerEntryFirstIdx] = min(centerEntryFirstDiff);
            if ~isinf(centerEntryFirstVal)
                b.centerEntryFirst(r,:) = b.centerEntries(centerEntryFirstIdx,:);
                b.centerEntries(centerEntryFirstIdx,3) = r;
            else
                b.centerEntryFirst(r,:) = [f totalTime r 0 0 0 0 0];
            end
            
            b.centerEntryCt(r,2) = sum(b.centerEntries(:,3) == r);            
        end
        
% correct center entries include ones before and during the center entry
% wait but not others        

        b.centerDwell = b.centerExitGo(:,2) - b.centerEntryGo(:,2);
        b.centerDwell = [zeros(size(b.centerDwell,1),1) b.centerDwell];
        b.centerDwell(:,1) = f;
        
        b.centerEntryGoCorr = b.centerEntryGo(b.correct,:);
                
%% REWARD ENTRIES

% NEED TO FIND THE CHOICE ONE AND THE EPOCH OF REWARD?
% MAKE THE GRAPH SHOWING ALL ENTRIES FOR EACH TRIAL     

        for e = 1:size(rewardEntries,1)
            rewardExitDiff = rewardExits(:,2) - rewardEntries(e,2);
            rewardExitDiff(rewardExitDiff < 0) = inf;
            [rewardExitVal,rewardExitIdx] = min(rewardExitDiff);
            if isinf(rewardExitVal)
                rewardEntries(e,7) = totalTime;
            else
                rewardEntries(e,7) = rewardExits(rewardExitIdx,2); % matching reward exit
            end
        end

        % REWARD DWELL TIME
        rewardEntries(:,8) = rewardEntries(:,7) - rewardEntries(:,2); % dwell time
        
        % SAVE ENTRIES AND EXITS TO DATA
        b.rewardEntries = rewardEntries;
        
        b.rewardEntriesCorr = b.rewardEntries(b.rewardEntries(:,6) == 1,:);
        

%% ODORS

        b.centerOdorOn = data(data(:,3) == 3 & data(:,5) == 0,:);
        b.centerOdorOff = data(data(:,3) == 5 & data(:,5) == 0,:);

        b.centerOdorOn = [zeros(size(b.centerOdorOn,1),1) b.centerOdorOn];
        b.centerOdorOn(:,1) = f; 
        b.centerOdorOff = [zeros(size(b.centerOdorOff,1),1) b.centerOdorOff];
        b.centerOdorOff(:,1) = f;

        b.sideOdorOn = data(data(:,3) == 3 & data(:,5) == 1,:);
        b.sideOdorOff = data(data(:,3) == 5 & data(:,5) == 1,:);
        b.sideOdorOn = [zeros(size(b.sideOdorOn,1),1) b.sideOdorOn];
        b.sideOdorOn(:,1) = f;
        b.sideOdorOff = [zeros(size(b.sideOdorOff,1),1) b.sideOdorOff];
        b.sideOdorOff(:,1) = f;

%% TRIAL PARAMS
    
        b.trialParams = data(data(:,3) == 17, :);
        b.trialParams = [zeros(size(b.trialParams,1),1) b.trialParams];
        b.trialParams(:,1) = f;
               
%% REWARD

        b.bigRewards = data(data(:,3) == 15,:); % trial type, choice (1 = info, 0 = rand)
        b.smallRewards = data(data(:,3) == 16,:); % trial type, choice
        b.bigRewards = [zeros(size(b.bigRewards,1),1) b.bigRewards];
        b.bigRewards(:,1) = f;
        b.smallRewards = [zeros(size(b.smallRewards,1),1) b.smallRewards];
        b.smallRewards(:,1) = f;
        b.bigRewardCt(f,1) = size(b.bigRewards,1); % report
        b.smallRewardCt(f,1) = size(b.smallRewards,1); % report
        b.rewardCts(f,1) = b.bigRewardCt(f,1) + b.smallRewardCt(f,1); % report
        b.bigRewardTime(f,1) = sessionParams(19,f);
        b.smallRewardTime(f,1) = sessionParams(20,f);
        b.bigReward(f,1) = (b.bigRewardTime(f,1) * 40)/1000;
        b.smallReward(f,1) = (b.smallRewardTime(f,1) * 40)/1000;
        b.rewardAmount(f,1) = b.bigRewardCt(f,1) * (b.bigRewardTime(f,1) * 40)/1000 + b.smallRewardCt(f,1) * (b.smallRewardTime(f,1) * 40)/1000; % report
        
%% REWARD TYPES
        
        allRewards = sort([b.bigRewards(:,3); b.smallRewards(:,3)]);
        b.rewarded = ismember(b.trialNums, allRewards);
        b.big = ismember(b.trialNums,b.bigRewards(:,3));
        b.small = ismember(b.trialNums,b.smallRewards(:,3));
        
        b.reward = zeros(trialCt,1);
        b.reward(b.big) = b.bigReward(f,1);
        b.reward(b.small) = b.smallReward(f,1);
        b.reward = b.reward(b.correct);

%% WATER

        b.waterOn = data(data(:,3) == 7, [1 2]);
        b.waterOff = data(data(:,3) == 8, [1 2]);

        b.waterOn = [zeros(size(b.waterOn,1),1) b.waterOn];
        b.waterOn(:,1) = f;
        b.waterOff = [zeros(size(b.waterOff,1),1) b.waterOff];
        b.waterOff(:,1) = f;        
        
%% TRIAL LENGTH

% WHY ARE THESE NOT IDENTICAL?
% 1. ITI is randomized 1 s
% 2. centerEntryGo can start before trial starts

        b.trialLength = zeros(trialCt,1);
        b.trialLengthEntry = zeros(trialCt,1);
        b.trialLengthTotal = zeros(trialCt,1);
        for tt = 1:trialCt-1
            b.trialLength(tt) = b.trialStart(tt+1,1) - b.goCue(tt,2);
            b.trialLengthEntry(tt) = b.trialStart(tt+1,1) - b.centerEntryGo(tt,3);
            b.trialLengthTotal(tt) = b.trialStart(tt+1,1) - b.trialStart(tt,1);
        end
        b.trialLength(trialCt) = NaN;
        b.trialLengthEntry(trialCt) = NaN;
        b.trialLengthTotal(trialCt) = NaN;
        
 %% CHOICE TRIAL TYPES

        b.choiceType = b.trialStart(:,4);

        b.choiceTrials = b.choiceType == 1;
        b.infoForced = b.choiceType == 2;
        b.randForced = b.choiceType == 3;

%% TRIAL TYPE FOR CORRECT TRIALS

% choice info big, choice info small, choice rand big, choice rand small
% info big, info small
% rand big, rand small

        b.choiceTypeCorr = b.choiceType(b.correct);
        b.choiceCorr = b.choice(b.correct,:);
        % b.trialParams(:,5)--> 1 = big, 0 = small

        b.type = zeros(b.corrTrialCt,1);

        for t = 1:b.corrTrialCt
            % CHOICE TRIALS
            if b.choiceTypeCorr(t) == 1
                % INFO    
                if b.choiceCorr(t,4) == 1
                    % BIG
                    if b.trialParams(t,5) == 1
                        b.type(t,1) = 1; % choice info big
                    % SMALL
                    elseif b.trialParams(t,5) == 0
                        b.type(t,1) = 2; % choice info small
                    end

                % RANDOM
                elseif b.choiceCorr(t,4) == 0
                    % BIG
                    if b.trialParams(t,5) == 1
                        b.type(t,1) = 3; % choice rand big
                    % SMALL
                    elseif b.trialParams(t,5) == 0
                        b.type(t,1) = 4; % choice rand small
                    end           
                end

            % INFO TRIALS
            elseif b.choiceTypeCorr(t) == 2
                % BIG
                if b.trialParams(t,5) == 1
                    b.type(t,1) = 5; % info big
                % SMALL
                elseif b.trialParams(t,5) == 0
                    b.type(t,1) = 6; % info small
                end

            % RAND TRIALS
            elseif b.choiceTypeCorr(t) == 3 
                % BIG
                if b.trialParams(t,5) == 1
                    b.type(t,1) = 7; % rand big
                % SMALL
                elseif b.trialParams(t,5) == 0
                    b.type(t,1) = 8; % rand small
                end
            end  
        end

%% OUTCOME OF ALL TRIALS

        b.outcome = zeros(trialCt,1);
        for t = 1:size(b.trialStart,1)
            % CHOICE TRIALS
            if b.choiceType(t) == 1
                % NO CHOICE
                if b.choice(t,3) == 2
                    b.outcome(t,1) = 1; % choice no choice;
                % INFO    
                elseif b.choice(t,3) == 1
                    % BIG
                    if b.big(t) == 1
                        b.outcome(t,1) = 2; % choice info big
                    % SMALL
                    elseif b.small(t) == 1
                        b.outcome(t,1) = 3; % choice info small
                    % NOT PRESENT
                    else b.outcome(t,1) = 4; %choice info not present
                    end

                % RANDOM
                else %if b.choice(t,3) == 0
                    %BIG
                    if b.big(t) == 1
                        b.outcome(t,1) = 5; % choice rand big
                    % SMALL
                    elseif b.small(t) == 1
                        b.outcome(t,1) = 6; % choice rand small
                    % NOT PRESENT
                    else b.outcome(t,1) = 7; %choice rand not present
                    end
                end

            % INFO TRIALS
            elseif b.choiceType(t) == 2
                % NO CHOICE
                if b.choice(t,4) == 2
                    b.outcome(t,1) = 8; % info no choice;  
                % CORRECT
                elseif b.choice(t,4) == 1
                    % BIG
                    if b.big(t) == 1
                        b.outcome(t,1) = 9; % info big
                    % SMALL
                    elseif b.small(t) == 1
                        b.outcome(t,1) = 10; % info small
                    % NOT PRESENT
                    else
                        b.outcome(t,1) = 11; % info not present
                    end
                % INCORRECT
                else %b.choice(t,3) == 3
                    b.outcome(t,1) = 12; % info incorrect
                end

            % RAND TRIALS
            else % if b.choiceType(t) == 3
                % NO CHOICE
                if b.choice(t,4) == 2
                    b.outcome(t,1) = 13; % rand no choice;  
                % CORRECT
                elseif b.choice(t,4) == 0
                    % BIG
                    if b.big(t) == 1
                        b.outcome(t,1) = 14; % rand big
                    % SMALL
                    elseif b.small(t) == 1
                        b.outcome(t,1) = 15; % rand small
                    % NOT PRESENT
                    else
                        b.outcome(t,1) = 16; % rand not present
                    end
                % INCORRECT
                else % b.choice(t,3) == 3
                    b.outcome(t,1) = 17; % rand incorrect
                end
            end  
        end
        
%% LICKING
        
% CONSUMMATORY LICKS CAN BE FROM AN INCORRECT ENTRY OR AN ENTRY TECHNICALLY
% IN THE NEXT TRIAL!!

        b.licks = [];
        b.licks = data(data(:,3) == 4 & data(:,4) > 0,[1 2 4]);        
        b.licks = [zeros(size(b.licks,1),1) b.licks];
        b.licks(:,1) = f;
        b.licks(:,5:13) = 0; % preallocate
        
        for l = 1:size(b.licks,1)
            lickEntDiff = [];
            lickExitDiff = [];
            lickEntDiff = b.licks(l,2) - b.rewardEntries(:,2);
            lickEntDiff(lickEntDiff<0) = inf;
            [~,lickEntIdx] = min(lickEntDiff);            
            lickExitDiff = b.licks(l,2) - b.rewardEntries(:,2);
            lickExitDiff(lickExitDiff<0) = inf;
            [~,lickExitIdx] = min(lickExitDiff);
            if ~isempty(lickExitIdx) & ~isempty(lickEntDiff)
                if lickExitIdx < lickEntIdx
                    lickIdx = lickExitIdx;
                else
                    lickIdx = lickEntIdx;
                end
                b.licks(l,5) = lickIdx; % entry number
                b.licks(l,[6 7 8]) = b.rewardEntries(lickIdx,[2 6 5]); % entry time, correct, port % PORT HERE MAY NOT BE CORRECT FOR TRIAL!!
                b.licks(l,9) = b.licks(l,2) - b.rewardEntries(lickIdx,2); % time from entry
                % INDEX OF CORRECT TRIAL MATCHING THAT LICK (should this be
                % by entry??)
                lickTrialIdx = find(b.corrTrials(:,1) == b.licks(l,3));
                if ~isempty(lickTrialIdx)
                    b.licks(l,10) = lickTrialIdx; % index into correct trials
                    b.licks(l,11) = b.type(lickTrialIdx,1); % trial type
                    if b.choiceCorr(lickTrialIdx,4) == 1
                        b.licks(l,12) = info;  % choice port
                    else
                        b.licks(l,12) = rand;  % choice port
                    end
                    b.licks(l,13) = b.licks(l,2) - b.centerEntryGoCorr(lickTrialIdx,3); % time from center correct time
                end
            end                
        end
        
%%
        corrLicks = [];
        corrLickFlag = b.licks(:,8) == b.licks(:,12) & b.licks(:,13) > 0; % want port = choice and after go cue
        corrLicks = b.licks(corrLickFlag,:);
        
        % time before odor on
        odorWait = files(f).centerDelay + files(f).centerOdorTime + ...
            files(f).startDelay + 50 + files(f).odorDelay;
        % time before reward starts
        rewardWait = odorWait + files(f).odorTime + files(f).rewardDelay;
        
        anticipateLicks = [];
        anticipateLicks = corrLicks(:,13) < rewardWait;
        anticipateTrialNums = [];
        anticipateTrialNums = corrLicks(anticipateLicks,3);

        earlyLicks = [];
        earlyLicks = corrLicks(:,13) < odorWait;
        earlyTrialNums = [];
        earlyTrialNums = corrLicks(earlyLicks,3);
        
        betweenLicks = [];
        betweenLicks = corrLicks(:,13) >= odorWait & corrLicks(:,13) < rewardWait;
        betweenTrialNums = [];
        betweenTrialNums = corrLicks(betweenLicks,3);

        waterLicks = [];
        waterLicks = corrLicks(:,13) >= rewardWait;
        waterLicksTrialNums = [];
        waterLicksTrialNums = corrLicks(waterLicks,3);

        b.lickCt = [];
        b.anticipatoryLicks = [];
        b.earlyLicks = [];
        b.waterLicks = [];
        b.rewardPortTime = [];
        b.betweenLicks = [];
               
        for t = 1:b.corrTrialCt
           trialNum = b.corrTrials(t,1);
           b.allLickCt(t,1) = sum(b.licks(:,3) == trialNum);
           b.lickCt(t,1) = sum(corrLicks(:,3) == trialNum);
           b.anticipatoryLicks(t,1) = sum(anticipateTrialNums == trialNum);
           b.earlyLicks(t,1) = sum(earlyTrialNums == trialNum);
           b.betweenLicks(t,1) = sum(betweenTrialNums == trialNum);
           b.waterLicks(t,1) = sum(waterLicksTrialNums == trialNum);
        end        
        
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  PUTTING FILES TOGETHER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        if exist('a','var') == 0

            a = b;
%             a.files = files;
%             a.numFiles = numFiles;
            a.parameters = sessionParameters;
            a.trialCts = trialCt;
            a.mouse = repmat(mouse,b.corrTrialCt,1);
            a.mouseAll = repmat(mouse,trialCt,1);

        else
            a.fileAll = [a.fileAll; b.fileAll];
            a.file = [a.file; b.file];
            a.parameters = [a.parameters; sessionParameters];
            a.trialCts = [a.trialCts trialCt];
            a.mouse = [a.mouse; repmat(mouse,b.corrTrialCt,1)];
            a.mouseAll = [a.mouseAll; repmat(mouse,trialCt,1)];
            a.trialNums = [a.trialNums; b.trialNums];
            a.trialStart = [a.trialStart; b.trialStart];
            a.txn0_1 = [a.txn0_1; b.txn0_1];
            a.txn1_2 = [a.txn1_2; b.txn1_2];
            a.txn2_3 = [a.txn2_3; b.txn2_3];
            a.txn3_4 = [a.txn3_4; b.txn3_4];
            a.txn4_5 = [a.txn4_5; b.txn4_5];
            a.txn5_6 = [a.txn5_6; b.txn5_6];
            a.txn6_7 = [a.txn6_7; b.txn6_7];
            a.txn7_8 = [a.txn7_8; b.txn7_8];
            a.txn8_9 = [a.txn8_9; b.txn8_9];
            a.txn9_11 = [a.txn9_11; b.txn9_11];
            a.txn9_10 = [a.txn9_10; b.txn9_10];
            a.txn10_12 = [a.txn10_12; b.txn10_12];
            a.txn11_12 = [a.txn11_12; b.txn11_12];
            a.txn12_13 = [a.txn12_13; b.txn12_13];
            a.txn13_14 = [a.txn13_14; b.txn13_14];
            a.txn14_15 = [a.txn14_15; b.txn14_15];
            a.txn15_0 = [a.txn15_0; b.txn15_0];
            a.txn4_3 = [a.txn4_3; b.txn4_3];
            a.txn5_3 = [a.txn5_3; b.txn5_3];
            a.txn6_3 = [a.txn6_3; b.txn6_3];
            a.txn10_11 = [a.txn10_11; b.txn10_11];
            a.txn11_10 = [a.txn11_10; b.txn11_10];
            a.txn11_16 = [a.txn11_16; b.txn11_16];
            a.txn10_16 = [a.txn10_16; b.txn10_16];
            a.txn16_15 = [a.txn16_15; b.txn16_15];
            a.centerEntries = [a.centerEntries; b.centerEntries];
            a.centerEntryGo = [a.centerEntryGo; b.centerEntryGo];
            a.centerExitGo = [a.centerExitGo; b.centerExitGo];
            a.centerEntryCt = [a.centerEntryCt; b.centerEntryCt];
            a.firstCenterEntryTxn = [a.firstCenterEntryTxn; b.firstCenterEntryTxn];
            a.centerDwell = [a.centerDwell; b.centerDwell];            
            a.goCue = [a.goCue; b.goCue];
            a.goParams = [a.goParams; b.goParams];
            a.choice = [a.choice; b.choice];
            a.choiceTime = [a.choiceTime; b.choiceTime];
            a.chose = [a.chose; b.chose];
            a.choseTrialCt = [a.choseTrialCt; b.choseTrialCt];
            a.correct = [a.correct; b.correct];
            a.corrTrialCt = [a.corrTrialCt; b.corrTrialCt];
            a.corrTrials = [a.corrTrials; b.corrTrials];
            a.choiceCorr = [a.choiceCorr; b.choiceCorr];
            a.rxn = [a.rxn; b.rxn];
            a.rewardEntries = [a.rewardEntries; b.rewardEntries];
            a.rewardEntriesCorr = [a.rewardEntriesCorr; b.rewardEntriesCorr];
            a.centerOdorOn = [a.centerOdorOn; b.centerOdorOn];
            a.centerOdorOff = [a.centerOdorOff; b.centerOdorOff];
            a.sideOdorOn = [a.sideOdorOn; b.sideOdorOn];
            a.sideOdorOff = [a.sideOdorOff; b.sideOdorOff];
            a.trialParams = [a.trialParams; b.trialParams];
            a.waterOn = [a.waterOn; b.waterOn];
            a.waterOff = [a.waterOff; b.waterOff];
            a.licks = [a.licks; b.licks];
            a.lickCt = [a.lickCt; b.lickCt];
            a.anticipatoryLicks = [a.anticipatoryLicks; b.anticipatoryLicks];
            a.earlyLicks = [a.earlyLicks; b.earlyLicks];
            a.waterLicks = [a.waterLicks; b.waterLicks];
            a.rewardPortTime = [a.rewardPortTime; b.rewardPortTime];
            a.betweenLicks = [a.betweenLicks; b.betweenLicks];
            a.trialLength = [a.trialLength; b.trialLength];
            a.trialLengthEntry = [a.trialLengthEntry; b.trialLengthEntry];
            a.trialLengthTotal = [a.trialLengthTotal; b.trialLengthTotal];
            a.bigRewards = [a.bigRewards; b.bigRewards];
            a.smallRewards = [a.smallRewards; b.smallRewards];
            a.bigRewardCt = [a.bigRewardCt; b.bigRewardCt];
            a.smallRewardCt = [a.smallRewardCt; b.smallRewardCt];
            a.rewardCts = [a.rewardCts; b.rewardCts];
            a.bigRewardTime = [a.bigRewardTime; b.bigRewardTime];
            a.smallRewardTime = [a.smallRewardTime; b.smallRewardTime];
            a.bigReward = [a.bigReward; b.bigReward];
            a.smallReward = [a.smallReward; b.smallReward];
            a.rewardAmount = [a.rewardAmount; b.rewardAmount];
            a.rewarded = [a.rewarded; b.rewarded];
            a.reward = [a.reward; b.reward];
            a.big = [a.big; b.big];
            a.small = [a.small; b.small];
            a.choiceType = [a.choiceType; b.choiceType];
            a.choiceTrials = [a.choiceTrials; b.choiceTrials];
            a.infoForced = [a.infoForced; b.infoForced];
            a.randForced = [a.randForced; b.randForced];
            a.choiceTypeCorr = [a.choiceTypeCorr; b.choiceTypeCorr];
            a.choiceCorr = [a.choiceCorr; b.choiceCorr];
            a.outcome = [a.outcome; b.outcome];
            a.type = [a.type; b.type];
            
        end
    end
    if isfield(a,'files') == 0
        a.files = files;
        a.numFiles = numFiles;
    else
        a.files = [a.files; files];
        a.numFiles = a.numFiles + numFiles;
    end
    
end

uisave({'a'},'infoSeekFSMData.mat');

