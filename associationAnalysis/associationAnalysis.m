%%

% show lick raster across trials
% lick probs by type
% rewards by type
% complete % by type
% dwell time by type

% track all activity rel to trial start
% assume concat video with allframes from all trials? 
% find trial starts w/in frames (nums in files, also in concat vid)
% make plots/analysis

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
   a.parameters{s,35} = find(ismember(days,a.parameters{s,3})); 
   a.files(s).day = a.parameters{s,35};
end

a.fileDays = cell2mat(a.parameters(:,35));
a.day = a.fileDays(a.file);

%% TRIAL COUNT

a.trialCt = size(a.file,1);
a.completeTrialCt = sum(a.complete);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% TRIAL TYPES

a.typeList = 1:5;
a.typeNames = {'CSplus1','CSplus2','CSminus1','CSminus2','US'};
a.pooledTypeNames = {'CSplus','CSminus','US'};

a.typeCounts = sum(a.type == a.typeList);

a.types = a.type == a.typeList;

a.CSplus1 = a.type == 1;
a.CSplus2 = a.type == 2;
a.CSminus1 = a.type == 3;
a.CSminus2 = a.type == 4;
a.US = a.type == 5;

%% MICE
a.mouseList = unique(a.mouse);
a.mouseCt = size(a.mouseList,1);

a.mice = [];
for m = 1:a.mouseCt
  a.mice(:,m) = strcmp(a.mouse,a.mouseList(m)) == 1;
end

%% DAY AND MOUSE

a.dayCell = a.parameters(:,3); % names
a.miceCell = a.parameters(:,2); % names
for m = 1:a.mouseCt
   mouseFileIdx = strcmp(a.miceCell,a.mouseList{m});
   a.mouseDays{m} = unique(a.dayCell(mouseFileIdx));
   a.mouseDayCt(m) = size(a.mouseDays{m},1);
end

for fm = 1:a.numFiles
   a.fileMouse(fm) = find(strcmp(a.parameters(fm,2),a.mouseList));
   a.fileDay(fm) = find(strcmp(a.parameters(fm,3),a.mouseDays{1,a.fileMouse(fm)}));   
end

a.mouseDay = zeros(sum(a.trialCt),1);
for tf = 1:sum(a.trialCt) % for each trial
   a.mouseDay(tf,1) = a.fileDay(a.file(tf));
end

%% CURRENT

dayDates = datetime(cell2mat(a.parameters(:,3)),'InputFormat','yyyy-MM-dd');
today = max(dayDates);
currentDay = a.parameters(:,3) == today;
a.currentMice = unique(a.parameters(currentDay,2));
[~,a.currentMiceNums] = ismember(a.currentMice,a.mouseList);

%% REWARDS BY TYPE

a.rewardedByType = sum(a.rewarded == 1& a.types == 1)./a.trialCt;

%% COMPLETE BY TYPE

a.completeByType = sum(a.complete == 1& a.types == 1)./a.trialCt;

%% DWELL TIME BY TYPE

% % this seems incorrect
% a.dwell = a.exit(:,2) - a.entry(:,2);
% dwell = repmat(a.dwell,1,5);
% a.meanDwellByType = nanmean(dwell(a.types));
% a.semDwellByType = sem(dwell(a.types));

% dwellByType = NaN(sum(a.trialCt),5);
% for type = 1:numel(a.typeList)
%     if sum(a.type==type)~=0
%         dwellByType(:,type) = a.dwell(a.type==type);
%     end
% end
% a.meanDwellByType = nanmean(dwellByType);
% a.semDwellByType = sem(dwellByType);

%% LICK COUNTS BY TYPE

% Need to assign correct licks to trial number, then calc time from trial
% entry (start) and assign anticipatory or consummatory
% 
% a.anticipatoryLicks = a.trialLicks(:,4);
% a.consummatoryLicks = a.trialLicks(:,5);
% 
% % aLicks = repmat(a.anticipatoryLicks,1,5);
% % cLicks = repmat(a.consummatoryLicks,1,5);
% 
% anticipatoryLicksByType = NaN(sum(a.trialCt),5);
% consummatoryLicksByType = NaN(sum(a.trialCt),5);
% for type = 1:numel(a.typeList)
%     if sum(a.type==type)~=0
%         anticipatoryLicksByType(:,type) = a.anticipatoryLicks(a.type==type);
%         consummatoryLicksByType(:,type) = a.consummatoryLicks(a.type==type);
%     end
% end
% a.meanAnticipatoryLicksByType = nanmean(anticipatoryLicksByType);
% a.semAnticipatoryLicksByType = sem(anticipatoryLicksByType);
% a.meanConsummatoryLicksByType = nanmean(consummatoryLicksByType);
% a.semConsummatoryLicksByType = sem(consummatoryLicksByType);

%% LICK PROBS BY TYPE

%% LICK RASTER

% for each mouse?

fileComplete = a.file(a.complete);
for f = 1:a.numFiles
    ok = a.file == f & a.complete==1;
    a.maxTrialLength(f,1) = max(a.trialComplete(fileComplete == 1,1) - a.baseline(ok,2)) + a.files(f).ITI +a.files(f).imagingTime;
end

cumCts = cumsum(a.trialCt);
starts = [0; cumCts(1:end-1)+1];
    
for m = 1:a.mouseCt     
    ok = a.mice(:,m)==1;
    
    figure();
    fig = gcf;
    fig.PaperUnits = 'inches';
    fig.PaperPosition = [1 1 8 10];
    set(fig,'renderer','painters');
    set(fig,'PaperOrientation','portrait');

    ax = nsubplot(1,1,1,1);
    hold on;
    ax.FontSize = 10;
    lowerTime = -max(a.files.ITI);
    upperTime = max(a.maxTrialLength(a.fileMouse == m));
    ax.XLim = [lowerTime upperTime];
    ax.YLim = [-10 sum(ok)];
    ax.YDir = 'reverse';

    title(['Licks by trial ' files(find(a.fileMouse==m,1)).mouseName]);

    mouseTrials = find(ok);
    for tt = 1:sum(ok)
        t = mouseTrials(tt);
        licksToPlot = [];
        licksToPlot = a.allLicksTrialStart{t,1};
        licksToPlot = licksToPlot(licksToPlot >= -a.files(a.file(t)).ITI & licksToPlot <= a.maxTrialLength(a.file(t),1));
        for p = 1:numel(licksToPlot)
            plot([licksToPlot(p),licksToPlot(p)],[tt-0.5,tt+0.5],'color','k');
        end
    end

    for f=1:a.numFiles
        plot([-10000000 1000000],[cumCts(f) cumCts(f)],'color','k','linewidth',0.5,'yliminclude','off','xliminclude','off');
    end

    ylabel('Trial');
    xlabel('Time from Trial Start (ms)');

    hold off;

    saveMouse = string(files(1).mouseName);
    figName = char('lickRaster' + saveMouse + '.pdf');
    saveFig = fullfile(pathname,figName);
    saveas(fig,fullfile(pathname,figName)); 
end