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

%% FINDING BOUTS -- NEED TO GENERALIZE!!

for f = 1:a.numFiles
    imagingStarts = []; imagingStops = []; images = [];
    
    imagingStarts = a.imagingStart(a.imagingStart(:,1) == f,:);
    imagingStops = a.imagingStop(a.imagingStop(:,1) == f,:);
    images = a.images(a.images(:,1) == f,:);
    images(:,4) = 0;
    
    a.imagingBoutCt(f,1) = size(a.imagingStart(a.imagingStart(:,1) == f,:),1);

    if size(imagingStops,1) < a.imagingBoutCt(f,1)
       imagingStops(a.imagingBoutCt,:) = [f images(end,2) a.imagingBoutCt(f,1)];
    end
    
    for b = 1:a.imagingBoutCt(f,1)
       frames = images(:,2) >= imagingStarts(b,2) & images(:,2) <= imagingStops(b,2);
       images(frames,4) = b;
    end

    a.imagingBouts{f,1} = accumarray(images(:,4),1);
%     imagingStarts = []; imagingStops = []; images = [];
end

% OPEN FRAME NUMBERS FOR VIDEO FROM XML FILE
% [datafilename,datapathname]=uigetfile('*.csv', 'Choose frame counts file to load');
% fname=fullfile(datapathname,datafilename);
% 
% imagingBoutsScope = csvread(fname,1,1);

%% OKAY FRAMES FOR THIS DAY--remove frames in vids (neuron) not in behavior
% what about dropped frames?!?

% behavior frame bouts 8:76-->trials?

% find trials and bouts in concat file
% concat file goes to imaging bout 76

% NEED TO LIMIT BEHAVIOR FRAMES TO BOUTS MATCHING CONCAT

imagingTrialsFirstTrial = images(min(find(images(:,4)==8)),3);
imagingTrialsLastTrial = images(min(find(images(:,4)==76)),3);

a.imagingTrials(:,1) = imagingTrialsFirstTrial:imagingTrialsLastTrial;
a.imagingTrialCt = numel(a.imagingTrials);
a.imagesTrimbyTrials = images(ismember(images(:,3),a.imagingTrials),:);

% from neuron, frames 1363:end

a.neurons = neuron.C;

% remove outliers

% this may be wrong since behavior frame counts include early ones?
a.neurons = a.neurons(:,1364:end); % spec to this file!
a.neuronsTrim = [a.neurons(:,1:1868) a.neurons(:,1870:9515) a.neurons(:,9517:end)]; 

% a.imagesTrim = images(images(:,4) >= 8 & images(:,4) <= 76,:);

% so now have same frames neural data and behavior

% find index of first frame at trial start and pull frames for that trial
% need to make sure don't go into next bout

%% FIND PSTH WINDOWS
% set the analysis interval for PSTH's
interval = 2000;
framesAround = interval/1000*neuron.Fs;

% find event timestamps for all relevant trials

% --> this is a.baseline(:,2)


% preallocate defined size matrix for frames from each trial

maxImagingBout = max(accumarray(images(:,4),1));
a.trialImages = NaN(a.imagingTrialCt,maxImagingBout);
a.C_trials = NaN(a.neuronCt,maxImagingBout,a.imagingTrialCt);

% find bout for each baseline (trial) and pull indices into vid frames
for tt = 1:a.imagingTrialCt
   t = a.imagingTrials(tt);
   trialImages = [];
   imagingStartDiff = [];
   imagingStartDiff = imagingStarts(:,2) - a.baseline(t,2);
   imagingStartDiff(imagingStartDiff<0) = inf;
   [imagingStartVal,imagingStartIdx] = min(imagingStartDiff);
   a.imagingTrialBout(tt,1) = imagingStartIdx;
   trialImages = find(a.imagesTrimbyTrials(:,4) == imagingStartIdx);
   a.trialImages(tt,1:numel(trialImages)) = trialImages';
   a.C_trials(:,1:numel(trialImages),tt) = a.neuronsTrim(:,trialImages');
end

% behaviorImagingFrames = ismember(images(:,4),a.imagingTrialBout);
% a.imagesTrim = images(behaviorImagingFrames,:);

%% ANALYSIS - not plotted below

% when in trial (by frames) do events occur?
% average each neuron across trials, by type

% average across all trials

a.C_mean = nanmean(a.C_trials,3);

% by type
a.imagingTrialType = a.type(a.imagingTrials);

a.C_CSplus1 = nanmean(a.C_trials(:,:,a.imagingTrialType == 1),3);
a.C_CSplus2 = nanmean(a.C_trials(:,:,a.imagingTrialType == 2),3);
a.C_CSminus1 = nanmean(a.C_trials(:,:,a.imagingTrialType == 3),3);
a.C_CSminus2 = nanmean(a.C_trials(:,:,a.imagingTrialType == 4),3);
a.C_US = nanmean(a.C_trials(:,:,a.imagingTrialType == 5),3);

% a.C_CSplus
% a.C_CSminus


%% PLOTTING:

pathname=uigetdir('','Choose save directory');

CC = [77/255,172/255,38/255; 184/255,225/255,134/255;...
241/255,182/255,218/255; 208/255,28/255,139/255; 0,0,0];
grey = [.8 .8 .8];

%% CONDITIONS TO PLOT:

% time (in sec relative to trial start) at each moment in the trial

t = (1:maxImagingBout)*(1/neuron.Fs);

% analysis window for cell sorting (odor time)
resp_win = [a.files(f).baseline/1000 (a.files(f).baseline+a.files(f).odorTime)/1000];
resp_okt = resp_win(1) <= t & t <= resp_win(2);

cnames = {'C_CSplus1','C_CSplus2','C_CSminus1','C_CSminus2','C_US'};
ccolors = CC;
clabels = {'CS plus 1','CS plus 2', 'CS minus 1', 'CS minus 2', 'US'};
eventTypes = {'Trial'};
cAll = cnames;

%% POPULATION ACTIVITY

figure();
fig = gcf;
fig.PaperUnits = 'inches';
fig.PaperPosition = [0.5 0.5 10 7];
set(fig,'renderer','painters');
set(fig,'PaperOrientation','landscape');

cname = cnames;
ccolor = ccolors;
clabel = clabels;

clims = [0 2];

% condition neural activity
% makes cell array with C(activity) for each condition
cy = cellfun(@(z) a.(z),cname,'uniform',0);

uactivity_max = nan*ones(size(cy{1},1));
uactivity_mean = nan*ones(size(cy{1},1));
uactivity_std = nan*ones(size(cy{1},1));
for u = 1:size(cy{1},1) % for each cell

    % all data from this unit, concatenating all conditions
    % just to normalize?!?    
    uy = [];
    for ci = 1:numel(cname)
        uy = [uy cy{ci}(u,:)];
    end;
    uactivity_max(u) = max(uy);
    uactivity_mean(u) = mean(uy);
    uactivity_std(u) = std(uy);

    % normalize activity of each cell

%     % peak-normalization
%     for ci = 1:numel(cname)
%         cy{ci}(u,:) = cy{ci}(u,:) ./ uactivity_max(u);
%     end;

%     % zscore-normalization
%     for ci = 1:numel(cname)
%         cy{ci}(u,:) = (cy{ci}(u,:) - uactivity_mean(u)) ./ uactivity_std(u);
%     end;
end;

h_for_legend = [];
for ci = 1:numel(cname) % for each condition

    cn = clabel{ci}; % name
    curcolor = ccolor(ci,:); % color

    y = cy{ci};

    ymean = mean(y,1);
    ysem = std(y,[],1) ./ sqrt(size(y,1));


    % unit responses in the analysis time window    
    if ci == 1
        yresp = mean(y(:,resp_okt),2);
        [~,cell_sort_ids] = sort(yresp);
    end;

%         figure(1);
    nsubplot(numel(cname)+1,1,ci); 
    hold on;
%     if ci == 1
%         imagesc(t,a.neuronCt,y(cell_sort_ids,:));
        imagesc(t,[],y(cell_sort_ids,:));
        colorbar;
%     else
%         imagesc(t,a.neuronCt,y);
%         imagesc(t,[],y);
%         imagesc(t,[],y,clims);
%         image(y);
%         colorbar;
%     end
    plot([5 5],[-1 +1].*10^10,'k','yliminclude','off');
    plot([7 7],[-1 +1].*10^10,'k','yliminclude','off');
    plot([10 10],[-1 +1].*10^10,'b','yliminclude','off');
%         colormap(gray); cmap = flipud(colormap); colormap(cmap);
    axis tight;
    ylabel('Cell');
    if ci == 1
        title([a.imageMouseName,' ',day,' ',cn]);
    else
        title(cn);
    end
    hold off;

%         figure(1);
    nsubplot(numel(cname)+1,1,numel(cname)+1); 
    hold on; 
    plot(t,ymean-ysem,'color',curcolor);
    plot(t,ymean+ysem,'color',curcolor);
    h_for_legend(end+1)=plot(t,ymean,'color',curcolor,'linewidth',3); % only this plot is used for legend!!
    xlim(t([1 end])); 
    if ci == 1
%        suptitle([a.imageMouseName ' ' day]);
        plot([5 5],[-1 +1].*10^10,'k','yliminclude','off');
        plot([7 7],[-1 +1].*10^10,'k','yliminclude','off');
        plot([10 10],[-1 +1].*10^10,'b','yliminclude','off');
    end
    if ci == numel(cname)
        plot([0 0],[-1 +1].*10^10,'k','yliminclude','off');
        legend(h_for_legend,clabel{:}); % 'Location','southoutside','Orientation','horizontal'
    end;
    xlabel('Seconds relative to trial start');
    ylabel('Calcium activity');
%     suptitle({a.imageMouseName, day});
    hold off;
  
%     suptitle({'Responses across units in ', clabels{ci}, 'Trials'});
    

end;
saveas(fig,fullfile(pathname,[a.imageMouseName,'_',day,'_Population']),'pdf');

%% MAKE FIGURES FOR EACH TRIAL TYPE FOR ALL CELLS, with little plot for each cell

nRows = 9;
nCols = 13;
cname = cnames;
ccolor = ccolors;
clabel = clabels;

cy = cellfun(@(z) a.(z),cname,'uniform',0);

for ci = 1:numel(cname) % for each type

    figure();
    set(gcf,'color','w');
    fig = gcf;
    fig.PaperUnits = 'inches';
    fig.PaperPosition = [0.5 0.5 10 7];
    set(fig,'renderer','painters');
    set(fig,'PaperOrientation','landscape');

    h_for_legend = [];

    cn = clabel{ci}; % name
    curcolor = ccolor(ci,:); % color

    y = cy{ci};

    for m = 1:nRows
        for n = 1:nCols
            u = (m-1)*nCols+n; % for each cell
%             figure(cd);
            ax = subplot(nRows,nCols,(m-1)*nCols+n);

            ax.FontSize = 8;
            set(ax,'Box','off');
            set(ax,'TickDir','out');
            set(ax,'ticklen',[.01 .01]);
            set(ax,'Color','none');
            set(ax,'layer','top');
%             if ci == 1
                hold(ax, 'on');
                plot(ax,[5 5],[-1 +1].*10^10,'color',grey,'yliminclude','off');
                plot(ax,[10 10],[-1 +1].*10^10,'color','b','yliminclude','off');
%             end
%             if u==1
%                 h_for_legend(end+1)=plot(ax,t,y(u,:),'Color',curcolor,'LineWidth',1);
%             else
                plot(ax,t,y(u,:),'Color',curcolor,'LineWidth',1);
%             end
        %     ax.Visible = 'off';
            ylabel(num2str(u));
            ax.XColor = 'none';
        %     ax.YColor = 'none';
            yticks([]);
        %     title('Trial Start Responses');
            if ci == numel(cname)
                hold(ax,'off');
            end
%             if u==a.neuronCt
%                leg = legend(h_for_legend,clabel{:},'Orientation','horizontal');
%                leg.Box = 'off';
%                leg.FontWeight = 'bold';
%                leg.FontSize = 10;
%                leg.Position = [0.4491 0.8982 0.0996 0.0158];
%                leg.Units = 'normalized';
%             end
        end
    end
    suptitle([a.imageMouseName,' ',day,' Unit Responses - ', clabels{ci}, ' Trials']);
    hold off;
    saveas(fig,fullfile(pathname,[a.imageMouseName,'_',day,'_Cells_',clabels{ci}]),'pdf');
end

%% for each cell
% mean PSTH for each event (4) by trial type, avg across trials
c=1;
for c = 1:a.neuronCt
    figure();
    
    fig = gcf;
    fig.PaperUnits = 'inches';
    fig.PaperPosition = [0.5 0.5 7 10];
    set(fig,'renderer','painters');
    set(fig,'PaperOrientation','portrait');
    
    
    for ci = 1:numel(cname) % for each type
        
        ax = nsubplot(5,1,ci,1);
        ax.FontSize = 8;
        ylabel('Mean Ca activity across trials');
        xlabel('Time relative to trial start');
        title(clabels{ci});
        y = a.C_trials(c,:,a.imagingTrialType == ci);
        ymean = nanmean(y,3);
        ysem = std(y,[],3)./sqrt(size(y,3));
        curcolor = ccolor(ci,:); % color
        hold on;
        plot([5 5],[-1 +1].*10^10,'k','yliminclude','off');
        plot([10 10],[-1 +1].*10^10,'b','yliminclude','off');
        plot(t,ymean-ysem,'color',curcolor);
        plot(t,ymean+ysem,'color',curcolor);        
        plot(t,ymean,'color',curcolor,'linewidth',3);
        hold off;
    end
        suptitle([a.imageMouseName,' ',day,' Unit', num2str(c)]);


        saveas(fig,fullfile(pathname,[a.imageMouseName,'_',day,'_Cell_',num2str(c)]),'pdf');

    
    
end