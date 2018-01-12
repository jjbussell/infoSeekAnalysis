%% events to analyze

% baseline
% odor on
% reward
% whole trial?!?!

%%

% need:
% frames from neuron.C_raw for each trial (real baseline)
% frame timestamps to match to behavior

% for each trial start (baseline entry), find closest frame, find that
% bout in behavior frames (a.frames(:,4), index into neuron.C

% no, make neuron.C == behavior frames


%%
clear all;
close all;

% open neuron file
uiopen('.mat');

% open analyzed association behavior file
uiopen('.mat');

%%

% find correct files to analyze

name = neuron.file;
mouseLoc = strfind(name,'JB');
if numel(mouseLoc)>1
    mouseLoc = mouseLoc(2);
end

a.imageMouseName = name(mouseLoc:mouseLoc+4);
a.imageMouse = find(~cellfun(@isempty,strfind(a.mouseList,a.imageMouseName)));

day = name(mouseLoc+6:mouseLoc+13);
a.imageDate = [day(1:4) '-' day(5:6) '-' day(7:8)];

files = zeros(a.numFiles,1);

for f = 1:a.numFiles
   fname = a.files(f).name;
   if strcmp(fname(7:16),a.imageDate) & strcmp(fname(1:5),a.imageMouseName)
       files(f,1) = 1;
   end    
end


% find all the frame timestamps in behavior
a.imagingFiles = find(files);

imagingFrames = ismember(a.images(:,1),a.imagingFiles);
a.frames = a.images(imagingFrames,:);
a.behaviorFrames = size(a.frames,1); % all for this file

[a.neuronCt,a.neuronFrames] = size(neuron.C);
