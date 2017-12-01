%% WHAT TO ANALYZE

% find complete imaging trials
% ID type
% track all activity rel to trial start
% assume concat video with allframes from all trials? 
% find trial starts w/in frames

% trial start (available)
% port entry (baseline)
% odor on
% delay
% water
% ITI
% licks?

% find all licks

% show lick raster across trials
% lick probs by type
% rewards by type
% complete % by type
% dwell time by type

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
    files(f).imagingFlag = sessionParams(6,f);
    files(f).trialTypes = sessionParams(7,f);
    files(f).imagingTime = sessionParams(8,f);
    files(f).port = sessionParams(9,f);
    files(f).CSplus1 = sessionParams(10,f);
    files(f).CSplus2 = sessionParams(11,f);
    files(f).CSminus1 = sessionParams(12,f);
    files(f).CSminus2 = sessionParams(13,f);
    files(f).baseline = sessionParams(14,f);
    files(f).odorTime = sessionParams(15,f);
    files(f).delayTime = sessionParams(16,f);
    files(f).rewardDrops = sessionParams(17,f);
    files(f).ITI = sessionParams(18,f);
    if isfield(files, 'folder')
        files = rmfield(files,'folder');
    end
    
    
%% TRIAL COUNTS

    trialCt = max(data(:,2));
    b.trialNums(:,1) = 1:trialCt;

    b.trialStart = data(data(:,3) == 10,:);


    if loadData == 0
        b.fileAll(1:trialCt,1) = f;
    else
        b.fileAll(1:trialCt,1) = f + a.numFiles;
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
    
    baseline = b.transitions(b.transitions(:,5)==3,:);
    
    for t=1:trialCt
       baselineIdx = find(baseline(:,3)==t,1,'last');
       b.baseline(t,:) = baseline(baselineIdx,:);
       baselineDiff = b.baseline(t,2) - b.entries(:,2);
       baselineDiff(baselineDiff < 0) = inf;
       [baselineEntryVal,baselineEntryIdx] = min(baselineDiff);
       b.baselineEntry(t,:) = b.entries(baselineEntryIdx,:);
       b.baselineExit(t,:) = b.exits(baselineEntryIdx,:);
    end
    
%% COMPLETE

    timeoutTrials = b.transitions(b.transitions(:,5) == 11,3);
    b.complete = zeros(trialCt,1);
    b.complete(timeoutTrials) = 1;

%% REWARDS

% trial only complete (printer(18) if finish getting reward drops-->don't
% have to be in port?!?!?

%% LICKS