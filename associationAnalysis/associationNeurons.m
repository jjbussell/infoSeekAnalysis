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
a.behaviorFrames = size(a.frames,1);

[a.neuronCt,a.neuronFrames] = size(neuron.C);

%% IMAGING BOUTS

% ONLY GOOD FOR THIS SPECIFIC DATA

a.imagingBoutCt = size(a.imagingStart,1);

if size(a.imagingStop,1) < a.imagingBoutCt
   a.imagingStop(a.imagingBoutCt,:) =  [1, a.images(end,[2 3])];
end

a.images(:,4) = 0;

for b = 1:a.imagingBoutCt
   frames = a.images(:,2) >= a.imagingStart(b,2) & a.images(:,2) <= a.imagingStop(b,2);
   a.images(frames,4) = b;   
end

a.imageCts = accumarray(a.images(:,4),1);