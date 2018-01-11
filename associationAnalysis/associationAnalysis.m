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

%% FIND REVERSALS!!!!!!!!!!!!!!!!!!!!!!!

%%

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


%% REVERSALS

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%% REWARDS BY TYPE

a.rewardedByType = sum(a.rewarded == 1& a.types == 1)./a.typeCounts;

%% COMPLETE BY TYPE

a.completeByType = sum(a.complete == 1& a.types == 1)./a.typeCounts;

%% DWELL TIME

% this seems incorrect
a.dwell = NaN(size(a.exit,1),1);
a.dwell(a.exit(:,2)>0) = a.exit(a.exit(:,2)>0,2) - a.entry(a.exit(:,2)>0,2);
% dwell = repmat(a.dwell,1,5);
% a.meanDwellByType = nanmean(dwell(a.types));
% a.semDwellByType = sem(dwell(a.types));

dwellByType = NaN(sum(a.trialCt),5);
for type = 1:numel(a.typeList)
    if sum(a.type==type)~=0
        dwellByType(a.type==type,type) = a.dwell(a.type==type);
    end
end
a.meanDwellByType = nanmean(dwellByType);
a.semDwellByType = sem(dwellByType);

%% LICK COUNTS BY TYPE

% Need to assign correct licks to trial number, then calc time from trial
% entry (start) and assign anticipatory or consummatory

a.generalAnticipatoryLicks = a.trialLicks(:,3);
a.anticipatoryLicks = a.trialLicks(:,4);
a.consummatoryLicks = a.trialLicks(:,5);

% aLicks = repmat(a.anticipatoryLicks,1,5);
% cLicks = repmat(a.consummatoryLicks,1,5);

generalAnticipatoryLicksByType = NaN(sum(a.trialCt),5);
anticipatoryLicksByType = NaN(sum(a.trialCt),5);
consummatoryLicksByType = NaN(sum(a.trialCt),5);
licksByType = NaN(sum(a.trialCt),5);
for type = 1:numel(a.typeList)
    if sum(a.type==type)~=0
        generalAnticipatoryLicksByType(a.type==type,type) = a.generalAnticipatoryLicks(a.type==type);
        anticipatoryLicksByType(a.type==type,type) = a.anticipatoryLicks(a.type==type);
        consummatoryLicksByType(a.type==type,type) = a.consummatoryLicks(a.type==type);
        licksByType(a.type==type,type) = a.trialLicks(a.type==type,1);
    end
end
a.meanLicksByType = nanmean(licksByType);
a.meanGeneralAnticipatoryLicksByType = nanmean(generalAnticipatoryLicksByType);
a.semGeneralAnticipatoryLicksByType = sem(generalAnticipatoryLicksByType);
a.meanAnticipatoryLicksByType = nanmean(anticipatoryLicksByType);
a.semAnticipatoryLicksByType = sem(anticipatoryLicksByType);
a.meanConsummatoryLicksByType = nanmean(consummatoryLicksByType);
a.semConsummatoryLicksByType = sem(consummatoryLicksByType);


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% DAY SUMMARY
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for m = 1:a.mouseCt
    for d = 1:a.mouseDayCt(m)
        ok = a.mouseDay == d & a.mice(:,m) == 1;
        a.daySummary.mouse{m,d} = m;
        a.daySummary.mouseName{m,d} = a.mouseList{m};
        a.daySummary.day{m,d} = d;
        for type = 1:numel(a.typeList)
            a.daySummary.trialCt{m,d,type} = sum(a.type == type & ok == 1);
            a.daySummary.rewarded{m,d,type} = sum(a.rewarded == 1& a.type == type & ok == 1)./sum(a.type == type & ok == 1);
            a.daySummary.complete{m,d,type} = sum(a.rewarded == 1& a.type == type & ok == 1)./sum(a.type == type & ok == 1);
            a.daySummary.generalAnticipatoryLicks{m,d,type} = nanmean(a.generalAnticipatoryLicks(ok == 1 & a.type == type));
            a.daySummary.anticipatoryLicks{m,d,type} = nanmean(a.anticipatoryLicks(ok == 1 & a.type == type));
            a.daySummary.consummatoryLicks{m,d,type} = nanmean(a.consummatoryLicks(ok == 1 & a.type == type));
            a.daySummary.generalAnticipatoryLicksSEM{m,d,type} = sem(a.generalAnticipatoryLicks(ok == 1 & a.type == type));
            a.daySummary.anticipatoryLicksSEM{m,d,type} = sem(a.anticipatoryLicks(ok == 1 & a.type == type));
            a.daySummary.consummatoryLicksSEM{m,d,type} = sem(a.consummatoryLicks(ok == 1 & a.type == type));
            a.daySummary.dwell{m,d,type} = nanmean(a.dwell(ok == 1 & a.type == type));
            a.daySummary.dwellSEM{m,d,type} = sem(a.dwell(ok == 1 & a.type == type));
        end
    end
end


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SUMMARY PLOTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fileComplete = a.file(a.complete);
for f = 1:a.numFiles
    ok = a.file == f & a.complete==1;
    if sum(ok)>0
    a.maxTrialLength(f,1) = max(a.trialComplete(fileComplete == f,1) - a.baseline(ok,2)) + a.files(f).ITI +a.files(f).imagingTime;
    else
        a.maxTrialLength(f,1) = a.files(f).baseline + a.files(f).odorTime + a.files(f).delayTime + a.files(f).ITI +a.files(f).imagingTime;
    end
end

cumCts = cumsum(a.trialCt);
starts = [0; cumCts(1:end-1)+1];

lowerTime = -max(cell2mat(a.parameters(:,18))); % ITI
upperTime = max(a.maxTrialLength);

a.win = 50;
a.maxBin = ceil(upperTime/a.win);
a.minBin = ceil(lowerTime/a.win);
% a.timeBins = (0:a.win:a.maxBin*a.win);
a.bins = (a.minBin*a.win:a.win:a.maxBin*a.win);
a.binLabels = [a.minBin*a.win+a.win/2:a.win:a.maxBin*a.win-a.win/2];

%% COLORS

% CC = linspecer(5);

CC = [77/255,172/255,38/255; 184/255,225/255,134/255;...
    241/255,182/255,218/255; 208/255,28/255,139/255; 0,0,0];

%% MOUSE SUMMARY BY DAYS

for mm = 1:numel(a.currentMiceNums)
    m=a.currentMiceNums(mm);
% for m = 1:a.mouseCt
    figure();
    
    fig = gcf;
    fig.PaperUnits = 'inches';
    fig.PaperPosition = [0.5 0.5 10 7];
    set(fig,'renderer','painters');
    set(fig,'PaperOrientation','landscape');
    
    % SEM
    
    ax = nsubplot(3,2,1,1);
    title(a.mouseList(m));
    ax.FontSize = 8;
    ax.XTick = [0:5:a.mouseDayCt(m)];    
    plotData = [];
    for d = 1:a.mouseDayCt(m)
        for type = 1:numel(a.typeList)
        plotColor = CC(type,:);  
        plotData(d,type) = a.daySummary.trialCt{m,d,type};
        end      
    end
    bar(plotData,'stacked');
    h = gcf; h.Colormap = CC;
    ylabel('Number of trials');
    hold off;
    
    ax = nsubplot(3,2,2,1);
    ax.FontSize = 8;
    ax.XTick = [0:5:a.mouseDayCt(m)];    
    ax.YTick = [0 0.25 0.50 0.75 1];
    ax.YLim = [-0.1 1.1];
    plotData = [];
    for type = 1:numel(a.typeList)
        plotColor = CC(type,:);
        for d = 1:a.mouseDayCt(m)       
            plotData(type,d) = a.daySummary.complete{m,d,type};
        end
        plot(1:a.mouseDayCt(m),plotData(type,:),'Color',plotColor,'LineWidth',2,'Marker','o','MarkerSize',3,'MarkerFaceColor',plotColor,'MarkerEdgeColor',plotColor);
    end
    ylabel('% trials complete');
    ax.YLim = [0 1];
    ax.YTick = [0 .25 .50 .75 1];
    hold off;
    
    ax = nsubplot(3,2,3,1);
    ax.FontSize = 8;
    ax.XTick = [0:5:a.mouseDayCt(m)];    
    plotData = [];
    for type = 1:numel(a.typeList)
        plotColor = CC(type,:);
        for d = 1:a.mouseDayCt(m)       
            plotData(type,d) = a.daySummary.dwell{m,d,type};
            plotSEM(type,d) = a.daySummary.dwellSEM{m,d,type};
        end
        plot(1:a.mouseDayCt(m),plotData(type,:),'Color',plotColor,'LineWidth',2,'Marker','o','MarkerSize',3,'MarkerFaceColor',plotColor,'MarkerEdgeColor',plotColor);
    end
    ylabel('Dwell Time (ms)');
    xlabel('Day');
    leg = legend(ax,'CS+ 1','CS+ 2','CS- 1','CS- 2','US','Location','southoutside','Orientation','horizontal');
    leg.Box = 'off';
    leg.FontWeight = 'bold';
    hold off;
    
    ax = nsubplot(3,2,1,2);
    ax.FontSize = 8;
    title(a.dayCell{find(a.fileMouse == m & a.fileDay == a.mouseDayCt(m),1,'first')});
    ax.XTick = [0:5:a.mouseDayCt(m)];    
    plotData = [];
    for type = 1:numel(a.typeList)
        plotColor = CC(type,:);
        for d = 1:a.mouseDayCt(m)       
            plotData(type,d) = a.daySummary.generalAnticipatoryLicks{m,d,type};
            plotSEM(type,d) = a.daySummary.generalAnticipatoryLicksSEM{m,d,type};
        end
        plot(1:a.mouseDayCt(m),plotData(type,:),'Color',plotColor,'LineWidth',2,'Marker','o','MarkerSize',3,'MarkerFaceColor',plotColor,'MarkerEdgeColor',plotColor);
    end
    ylabel('Licks prior to odor');
    hold off;
    
    ax = nsubplot(3,2,2,2);
    ax.FontSize = 8;
    ax.XTick = [0:5:a.mouseDayCt(m)];    
    plotData = [];
    for type = 1:numel(a.typeList)
        plotColor = CC(type,:);
        for d = 1:a.mouseDayCt(m)       
            plotData(type,d) = a.daySummary.anticipatoryLicks{m,d,type};
            plotSEM(type,d) = a.daySummary.anticipatoryLicksSEM{m,d,type};
        end
        plot(1:a.mouseDayCt(m),plotData(type,:),'Color',plotColor,'LineWidth',2,'Marker','o','MarkerSize',3,'MarkerFaceColor',plotColor,'MarkerEdgeColor',plotColor);
    end
    ylabel('Licks between odor and outcome');
    hold off;    
    
    ax = nsubplot(3,2,3,2);
    ax.FontSize = 8;
    ax.XTick = [0:5:a.mouseDayCt(m)];    
    plotData = [];
    for type = 1:numel(a.typeList)
        plotColor = CC(type,:);
        for d = 1:a.mouseDayCt(m)       
            plotData(type,d) = a.daySummary.consummatoryLicks{m,d,type};
            plotSEM(type,d) = a.daySummary.consummatoryLicksSEM{m,d,type};
        end
        plot(1:a.mouseDayCt(m),plotData(type,:),'Color',plotColor,'LineWidth',2,'Marker','o','MarkerSize',3,'MarkerFaceColor',plotColor,'MarkerEdgeColor',plotColor);
    end
    ylabel('Consummatory Licks');
    xlabel('Day');    
    leg = legend(ax,'CS+ 1','CS+ 2','CS- 1','CS- 2','US','Location','southoutside','Orientation','horizontal');
    leg.Box = 'off';
    leg.FontWeight = 'bold';
    hold off;    
end


%% LICK RASTER

% make one page for each mouse for each day
% plot for each type

% NEED TO SHOW BASELINE START, ODOR, WATER, TRIAL TYPE
    
% for m = 1:a.mouseCt     
%     ok = a.mice(:,m)==1;
%     
%     figure();
%     fig = gcf;
%     fig.PaperUnits = 'inches';
%     fig.PaperPosition = [1 1 8 10];
%     set(fig,'renderer','painters');
%     set(fig,'PaperOrientation','portrait');
% 
%     ax = nsubplot(1,1,1,1);
%     hold on;
%     ax.FontSize = 10;
%     ax.XLim = [lowerTime upperTime];
%     ax.YLim = [-10 sum(ok)];
%     ax.YDir = 'reverse';
% 
%     title(['Licks by trial ' files(find(a.fileMouse==m,1)).mouseName]);
% 
%     mouseTrials = find(ok);
%     for tt = 1:sum(ok)
%         t = mouseTrials(tt);
%         licksToPlot = [];
%         licksToPlot = a.allLicksTrialStart{t,1};
%         licksToPlot = licksToPlot(licksToPlot >= -a.files(a.file(t)).ITI & licksToPlot <= a.maxTrialLength(a.file(t),1));
%         for p = 1:numel(licksToPlot)
%             plot([licksToPlot(p),licksToPlot(p)],[tt-0.5,tt+0.5],'color','k');
%         end
%     end
% 
%     for f=1:a.numFiles
%         plot([-10000000 1000000],[cumCts(f) cumCts(f)],'color','k','linewidth',0.5,'yliminclude','off','xliminclude','off');
%     end
% 
%     ylabel('Trial');
%     xlabel('Time from Trial Start (ms)');
% 
%     hold off;
% 
%     saveMouse = string(files(1).mouseName);
%     figName = char('lickRaster' + saveMouse + '.pdf');
%     saveFig = fullfile(pathname,figName);
%     saveas(fig,fullfile(pathname,figName)); 
% end

%% LICK PROBS

% NEED FOR EACH MOUSE, subplot for EACH DAY, BY TYPE plot prob of licking

a.lickProbsOverall = histcounts(a.licks(:,10),a.bins,'Normalization','probability');

% a.licks (1 == file, 8 == trial)

for m = 1:a.mouseCt
    for d = 1:a.mouseDayCt(m)
%         files = find(a.fileDay == d & a.fileMouse == m);
        for type = 1:numel(a.typeList)
            ok = a.mouseDay == d & a.mice(:,m) == 1 & a.type == type;
            if sum(ok)>0
                for k = 1:sum(ok)
                    okTrials = find(ok);
                    if k == 1
                        lickTimes = a.lickTimes{okTrials(k)};
                    else
                        lickTimes = [lickTimes; a.lickTimes{okTrials(k)}];
                    end
                end
                a.lickTimesByType{m,d,type} = lickTimes;
            else
                a.lickTimesByType{m,d,type} = [];
            end
            a.lickProbs{m,d,type} = histcounts(a.lickTimesByType{m,d,type},a.bins,'Normalization','probability');
        end
    end
end

%% PLOT LICK PROBS

for mm = 1:numel(a.currentMiceNums)
    m=a.currentMiceNums(mm);
% for m = 1:a.mouseCt
    figure();
    
    fig = gcf;
    fig.PaperUnits = 'inches';
    fig.PaperPosition = [0.5 0.5 10 7];
    set(fig,'renderer','painters');
    set(fig,'PaperOrientation','landscape');
    
    for d = 1:a.mouseDayCt(m)
        ax = nsubplot(a.mouseDayCt(m),1,d,1);
        for type = 1:numel(a.typeList)
            plotColor = CC(type,:);
            plot(a.lickProbs{m,d,type},'Color',plotColor);
        end
    end
    
end

%%
uisave({'a'},'associationFSMDataAnalyzed.mat');