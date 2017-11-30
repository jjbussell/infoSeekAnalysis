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