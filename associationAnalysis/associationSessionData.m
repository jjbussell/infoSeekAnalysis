%% WHAT TO ANALYZE

% find complete imaging trials
% ID type

% trial start (available)
% port entry (baseline)
% odor on
% delay
% water
% ITI
% licks?

% find all licks

%%
clear all;
close all;

%% load previous data

% loadData = 1;
loadData = 0;

if loadData == 1
    [datafilename,datapathname]=uigetfile('*.mat', 'Choose processed data file to load');
    fname=fullfile(datapathname,datafilename);
    
%     fname = 'infoSeekFSMData.mat';
    load(fname); % opens structure "a" with previous data, if available    
    for fn = 1:a.numFiles
        names{fn} = a.files(fn).name; 
    end
end

%% LOAD NEW DATA

% select folder with new data file(s) to load
pathname=uigetdir;
files=dir([pathname,'/*.csv']);
numFiles = size(files,1);

f = 1;

%% FOR EACH FILE
for f = 1:numFiles
    filename = files(f).name;
    
    if loadData == 1
        if sum(strcmp(filename,names)) > 0
            disp(fprintf(['Skipping duplicate file ' filename]));
            files(f) = [];
            f = f+1;
            filename = files(f).name;
            numFiles = numFiles - 1;
        end
        ff = a.numFiles + f;
    else
        ff = f;
    end
    
    fname = fullfile(pathname,filename); % report
    dayPlace = strfind(filename,'_');

    mouse = cellstr(filename(1:dayPlace-1));
    day = filename(dayPlace(1)+1:dayPlace(2)-1);

    data = [];
    
    data = csvread(fname,21,0);
    sessionParams(:,f) = csvread(fname,1,1,[1,1,20,1]);        
    
    b = struct;
    
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
    files(f).imagingFlag = sessionParams(3,f);
    files(f).trialTypes = sessionParams(4,f);
    files(f).imagingTime = sessionParams(5,f);
    files(f).port = sessionParams(6,f);
    files(f).CSplus1 = sessionParams(7,f);
    files(f).CSplus2 = sessionParams(8,f);
    files(f).CSminus1 = sessionParams(9,f);
    files(f).CSminus2 = sessionParams(10,f);
    files(f).baseline = sessionParams(11,f);
    files(f).odorTime = sessionParams(12,f);
    files(f).delayTime = sessionParams(13,f);
    files(f).rewardDrops = sessionParams(14,f);
    files(f).ITI = sessionParams(15,f);
    if isfield(files, 'folder')
        files = rmfield(files,'folder');
    end
    
    
%% TRIAL COUNTS

    trialCt = max(data(:,2));
    b.trialNums(:,1) = 1:trialCt;

    b.trialStart = data(data(:,3) == 10,:);


    if loadData == 0
        b.file(1:trialCt,1) = f;
    else
        b.file(1:trialCt,1) = f + a.numFiles;
    end
    
%% TRIAL TYPE

    b.type = b.trialStart(:,4);
    
%% IMAGING

    % Pull imaging frame timestamps
    b.images = [];
    b.images = data(data(:,3) == 20, [1 2]);
    b.images = [zeros(size(b.images,1),1) b.images];
    b.images(:,1) = ff;    
    
%% STATE TRANSITIONS

    b.transitions = [];
    b.transitions = data(data(:,3) == 21,:);
    b.transitions = [zeros(size(b.transitions,1),1) b.transitions];
    b.transitions(:,1) = ff;
    
%% ENTRIES AND EXITS

    b.entries = [];
    b.exits = [];
    
    b.entries = data(data(:,3) == 2,:);
    b.exits = data(data(:,3) == 6,:);
    b.entries = [zeros(size(b.entries,1),1) b.entries];
    b.entries(:,1) = ff;
    b.exits = [zeros(size(b.exits,1),1) b.exits];
    b.exits(:,1) = ff;
    
    % printer(2,port,1) means correct/during wait for entry-->get only
    % these so ignore timeout ones
    
    % DEAL WITH NO EXIT @ END!
        
%% FIND IMAGING ENTRY/TRIAL START

% IF EXIT EARLY after odor starts, GO TO TIMEOUT but imaging continues! printer(11,...)
% if exit during baseline, go to wait for entry
% does *real* entry have to be the last before complete?!?!

%% BASELINE ENTRIES
    
    % can be more than one per trial! or none for last trial
    baseline = [];
    baseline = b.transitions(b.transitions(:,5)==3,:);
    
    for t=1:trialCt
       baselineIdx = find(baseline(:,3)==t,1,'last');
       if ~isempty(baselineIdx)
           b.baseline(t,:) = baseline(baselineIdx,:);
       else
           b.baseline(t,:) = [0,0,0,0,0,0];
       end
       baselineDiff = b.baseline(t,2) - b.entries(:,2);
       baselineDiff(baselineDiff < 0) = inf;
       [entryVal,entryIdx] = min(baselineDiff);
       if ~isempty(entryIdx)
           b.entry(t,:) = b.entries(entryIdx,:);
       else
           b.entry(t,:) = [0,0,0,0,0,0];
       end
       if entryIdx <= size(b.exits,1)
           b.exit(t,:) = b.exits(entryIdx,:);
       else
           b.exit(t,:) = [0,0,0,0,0,0];
       end
    end
    
%% COMPLETE

    timeoutTrials = b.transitions(b.transitions(:,5) == 11,3);
    b.trialComplete = data(data(:,3)==18,:);
    b.complete = ismember(b.trialNums,b.trialComplete(:,2));

%% REWARDS

% trial only complete (printer(18) if finish getting reward drops-->don't
% have to be in port?!?!?

    b.outcome = data(data(:,3) == 15 | data(:,3) == 16,:);
    b.reward = b.outcome(b.outcome(:,3) == 15,:);
    b.rewarded = ismember(b.trialNums,b.reward(:,2));

%% LICKS

    b.licks = [];
    b.licks = data(data(:,3) == 4,[1 2]);
    b.licks = [zeros(size(b.licks,1),1) b.licks];
    b.licks(:,1) = ff;
    
    b.licks(:,4:11) = NaN;
    
    for L = 1:size(b.licks,1)
        lickEntDiff = [];
        lickExitDiff = [];
        lickIdx = [];
        lickEntIdx = [];
        lickExitIdx = [];
        lickEntDiff = b.licks(L,2) - b.entries(:,2);
        lickEntDiff(lickEntDiff<0) = inf;
        [~,lickIdx] = min(lickEntDiff);
%         lickExitDiff = b.licks(L,2) - b.exits(:,2);
%         lickExitDiff(lickExitDiff<0) = inf;
%         [~,lickExitIdx] = min(lickExitDiff);
% %         if ~isempty(lickExitIdx) & ~isempty(lickEntDiff)
%         if lickExitIdx < lickEntIdx
%             lickIdx = lickExitIdx;
%         else
%             lickIdx = lickEntIdx;
%         end
        b.licks(L,4) = lickIdx; % entry index
        b.licks(L,5) = b.entries(lickIdx,2); % entry time (all entries, use for correct to find trial #)
        b.licks(L,6) = b.licks(L,2) - b.entries(lickIdx,2); % time from entry
        if ismember(b.licks(L,5),b.entry(:,2))
            b.licks(L,7) = 1; % correct = during baseline entry
            lickTrialIdx = find(b.entry(:,2) == b.licks(L,5),1,'first');
            b.licks(L,8) = lickTrialIdx; % trial number
            b.licks(L,9) = b.baseline(lickTrialIdx,2);
            b.licks(L,10) = b.licks(L,2) - b.baseline(lickTrialIdx,2); % time from baseline
            if b.licks(L,10) <= 0
                b.licks(L,11) = 1; % pre-baseline
            elseif b.licks(L,10) <= files(f).baseline
                b.licks(L,11) = 2; % during baseline, pre-odor
            elseif b.licks(L,10) <= files(f).baseline + files(f).odorTime + files(f).delayTime
               b.licks(L,11) = 3; % pre-reward(anticipatory)
            else b.licks(L,11) = 4; % consummatory
            end
        end
%         end                
    end
    
%% LICKS PER TRIAL

b.trialLicks = zeros(trialCt,5);

for t = 1:trialCt
    b.trialLicks(t,1) = sum(b.licks(:,8) == t);
    b.trialLicks(t,2) = sum(b.licks(:,8) == t & b.licks(:,11) == 1);
    b.trialLicks(t,3) = sum(b.licks(:,8) == t & b.licks(:,11) == 2);
    b.trialLicks(t,4) = sum(b.licks(:,8) == t & b.licks(:,11) == 3);
    b.trialLicks(t,5) = sum(b.licks(:,8) == t & b.licks(:,11) == 4);
    b.allLicksTrialStart{t,1} = b.licks(:,2) - b.entry(t,2);
    b.lickTimes{t,1} = b.licks(b.licks(:,8) == t,10);
end
    
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  PUTTING FILES TOGETHER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% still within for each file!

    if exist('a','var') == 0

        a = b;
        a.parameters = sessionParameters;
        a.trialCts = trialCt;
        a.mouse = repmat(mouse,trialCt,1);

    else
        a.file = [a.file; b.file];
        a.parameters = [a.parameters; sessionParameters];

        a.trialCts = [a.trialCts trialCt];
        a.images = [a.images; b.images];
        a.transitions = [a.transitions; b.transitions];        
        a.mouse = [a.mouse; repmat(mouse,trialCt,1)];
        a.trialNums = [a.trialNums; b.trialNums];
        a.type = [a.type; b.type];
        a.trialStart = [a.trialStart; b.trialStart];
        a.entries = [a.entries; b.entries];
        a.exits = [a.exits; b.exits];
        a.baseline = [a.baseline; b.baseline];
        a.entry = [a.entry; b.entry];
        a.exit = [a.exit; b.exit];
        a.trialComplete = [a.trialComplete; b.trialComplete];
        a.complete = [a.complete; b.complete];
        a.outcome = [a.outcome; b.outcome];
        a.reward = [a.reward; b.reward];
        a.rewarded = [a.rewarded; b.rewarded];
        a.licks = [a.licks; b.licks];
        a.trialLicks = [a.trialLicks; b.trialLicks];
        a.allLicksTrialStart = [a.allLicksTrialStart; b.allLicksTrialStart];
        a.lickTimes = [a.lickTimes; b.lickTimes];
    end
end % for each file

if isfield(a,'files') == 0
    a.files = files;
    a.numFiles = numFiles;
else       
    a.files = [a.files; files];
    a.numFiles = a.numFiles + numFiles;
end

% save('associationFSMData.mat','a');
uisave({'a'},'associationFSMData.mat');