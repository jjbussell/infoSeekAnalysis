%% TO CALC/FIX

% fix numToPlot for animals with few choices
% make pre-choice animals automatic

% other things to plot only for current mice?

% fix lick prob days for histogram

% LICKS NEEDS TO ACCOUNT FOR TIME/ERROR TRIALS!!

% scatter of initial vs reversal pref for IIS in diff bins (# trials,
% days)--> NEED TO FIX BINNING/numToPlot?
% early lick index/other lick index
% correlation side/info bias-->REGRESSION
% correlation rxn time/early licks (normalize to time?)

% sliding window (adjustable) of mean choice + CI from start through reversal
% sliding window (adjustable) of mean choice + CI divided by reversal
% CHOICES BY DAY
% mean choice by day + CI from start through reversal
% mean choice by day + CI divided by reversal

%% SET ANALYSIS PARAMS
a.odorWait = 50 + 2000;
a.rewardWait = a.odorWait + 200 + 2000;
a.maxTimeToLick = 10000;

a.win = 50;
a.maxBin = ceil(a.maxTimeToLick/a.win);
bins = [a.win/2:a.win:a.maxBin*a.win-a.win/2];
a.timeBins = (0:a.win:a.maxBin*a.win);

% trials to plot
numToPlot = 50;

dayDates = datetime(cell2mat(a.parameters(:,3)),'InputFormat','yyyy-MM-dd');
today = max(dayDates);
currentDay = a.parameters(:,3) == today;
a.currentMice = unique(a.parameters(currentDay,2));
[~,a.currentMiceNums] = ismember(a.currentMice,a.mouseList);

%% PLOTTING COLORS


a.mColors = linspecer(a.mouseCt);

a.mChoiceColors = linspecer(a.choiceMouseCt);

if ~isempty(a.choiceMice)
    % sort plotting colors
    a.sortedColors = a.mChoiceColors(a.sortedChoice(:,3),:);
end

map = linspecer(2);

dx = 0.2;
dy = 0.02;

plots = [1 1; 1 2; 2 1; 2 2];

purple = [121 32 196] ./ 255;
orange = [251 139 6] ./ 255;
cornflower = [100 149 237] ./ 255;

CC = [0.2,0.2,0.2; %choice no choice
    0.984313725490196,0.545098039215686,0.0235294117647059; %choice info big
    1, 0.8, 0.0; %choice info small
    1,0.8,0.8; %choice info NP
    0.474509803921569,0.125490196078431,0.768627450980392; %choice rand big
    0.9490, 0.8, 1.0; %choicerandsmall
    0.8,0.8,0.8; %choicerandNP
    0.6,0.6,0.6; %info no choice
    0,1,0; %info big
    1,0,1; %infosmall
    1,0.8,0.8; %info not present
    0.0,0.0,0.0; %infoincorrect
    0.2,0.2,0.2;% rand no choice
    0,0,1; %rand big
    0,1,1; %rand small
    0.8,0.8,0.8; %rand NP
    0.0,0.0,0.0]; %rand incorrect

a.outcomeLabels = {'ChoiceNoChoice','ChoiceInfoBig','ChoiceInfoSmall','ChoiceInfoNP','ChoiceRandBig',...
    'ChoiceRandSmall','ChoiceRandNP','InfoNoChoice','InfoBig','InfoSmall',...
    'InfoNP','InfoIncorrect','RandNoChoice','RandBig','RandSmall','RandNP',...
    'RandIncorrect'};

a.choiceLabels = {'ChoiceInfoBig','ChoiceInfoSmall','ChoiceRandBig',...
    'ChoiceRandSmall','InfoBig','InfoSmall','RandBig','RandSmall'};


%% PLOT DAY SUMMARIES BY MOUSE

 pathname=uigetdir('','Choose save directory');

for m = a.currentMiceNums(1):a.currentMiceNums(end)
    figure();
    
    fig = gcf;
    fig.PaperUnits = 'inches';
    fig.PaperPosition = [0.5 0.5 10 7];
    set(fig,'renderer','painters');
    set(fig,'PaperOrientation','landscape');
    
    ax = nsubplot(4,2,1,1);
    title(a.mouseList(m));
    ax.FontSize = 8;
    ax.XTick = [0:5:a.mouseDayCt(m)];    
    ax.YTick = [0 0.25 0.50 0.75 1];
    ax.YLim = [0 1];
%     set(ax,'units','inches');
%     ax.Position = [1 1 5 1];
    if sum(isnan(cell2mat(a.daySummary.percentInfo(m,:)))) ~= a.mouseDayCt(m)
    plot(0:a.mouseDayCt(m),[0 cell2mat(a.daySummary.percentInfo(m,:))],'Color',a.mColors(m,:),'LineWidth',2,'Marker','o','MarkerFaceColor',a.mColors(m,:),'MarkerSize',3);
    plot([-10000000 1000000],[0.5 0.5],'k','xliminclude','off','color',[0.6 0.6 0.6],'LineWidth',2);
    plot([a.reverseDay(m)-0.5 a.reverseDay(m)-0.5],[-10000000 1000000],'k','yliminclude','off','xliminclude','off','LineWidth',4);
    end
    ylabel({'Info choice', 'probability'}); %ylabel({'line1', 'line2','line3'},)
%     xlabel('Day');
    hold off;
    
    ax = nsubplot(4,2,2,1);
    ax.FontSize = 8;
    ax.XTick = [0:5:max(cell2mat(a.daySummary.day(m,:)))];
    plot(cell2mat(a.daySummary.rxnInfoForced(m,:)),'Color',purple,'LineWidth',2,'Marker','o','MarkerFaceColor',purple,'MarkerSize',3);
    plot(cell2mat(a.daySummary.rxnInfoChoice(m,:)),'Color',purple,'LineWidth',2,'Marker','o','MarkerEdgeColor',purple,'MarkerFaceColor','w','MarkerSize',3,'LineStyle',':');
    plot(cell2mat(a.daySummary.rxnRandForced(m,:)),'Color',orange,'LineWidth',2,'Marker','o','MarkerFaceColor',orange,'MarkerSize',3);
    plot(cell2mat(a.daySummary.rxnRandChoice(m,:)),'Color',orange,'LineWidth',2,'Marker','o','MarkerEdgeColor',orange,'MarkerFaceColor','w','MarkerSize',3,'LineStyle',':');
    plot([a.reverseDay(m)-0.5 a.reverseDay(m)-0.5],[-10000000 1000000],'k','yliminclude','off','xliminclude','off','LineWidth',4);
    ylabel({'Reaction', 'Time (ms)'});
%     xlabel('Day');    
    leg = legend(ax,'Info-Forced','Info-Choice','No Info - Forced','No Info - Choice','Location','southoutside','Orientation','horizontal');
    leg.Box = 'off';
    leg.FontWeight = 'bold';
    hold off;
    
    ax = nsubplot(4,2,3,1);
    ax.FontSize = 8;
    ax.XTick = [0:5:max(cell2mat(a.daySummary.day(m,:)))];
    ax.YLim = [0 inf];
    plot(cell2mat(a.daySummary.infoBigLicksEarly(m,:)),'Color','g','LineWidth',2,'Marker','o','MarkerFaceColor','g','MarkerSize',3);
    plot(cell2mat(a.daySummary.infoSmallLicksEarly(m,:)),'Color','m','LineWidth',2,'Marker','o','MarkerFaceColor','m','MarkerSize',3);
    plot(cell2mat(a.daySummary.randCLicksEarly(m,:)),'Color',cornflower,'LineWidth',2,'Marker','o','MarkerFaceColor',cornflower,'MarkerSize',3);
    plot(cell2mat(a.daySummary.randDLicksEarly(m,:)),'Color',cornflower,'LineWidth',2,'Marker','o','MarkerEdgeColor',cornflower,'MarkerSize',3,'LineStyle',':');
%     plot(cell2mat(a.daySummary.randBigLicksEarly(m,:)),'Color','c','LineWidth',2,'Marker','o','MarkerFaceColor','c','MarkerSize',3);
%     plot(cell2mat(a.daySummary.randSmallLicksEarly(m,:)),'Color','b','LineWidth',2,'Marker','o','MarkerFaceColor','b','MarkerSize',3);
    plot([a.reverseDay(m)-0.5 a.reverseDay(m)-0.5],[-10000000 1000000],'k','yliminclude','off','xliminclude','off','LineWidth',4);        
    ylabel({'Early', 'lick rate'});
%     xlabel('Day');
    leg = legend(ax,'Info-Rew','Info-No Rew','No Info - C','No Info - D','Location','southoutside','Orientation','horizontal');
    leg.Box = 'off';
    leg.FontWeight = 'bold';
    hold off;

    ax = nsubplot(4,2,4,1);
    ax.FontSize = 8;
    ax.XTick = [0:5:max(cell2mat(a.daySummary.day(m,:)))];
    ax.YLim = [0 inf];
    plot(cell2mat(a.daySummary.infoBigLicks(m,:)),'Color','g','LineWidth',2,'Marker','o','MarkerFaceColor','g','MarkerSize',3);
    plot(cell2mat(a.daySummary.infoSmallLicks(m,:)),'Color','m','LineWidth',2,'Marker','o','MarkerFaceColor','m','MarkerSize',3);
    plot(cell2mat(a.daySummary.randCLicks(m,:)),'Color',cornflower,'LineWidth',2,'Marker','o','MarkerFaceColor',cornflower,'MarkerSize',3);
    plot(cell2mat(a.daySummary.randDLicks(m,:)),'Color',cornflower,'LineWidth',2,'Marker','o','MarkerEdgeColor',cornflower,'MarkerSize',3,'LineStyle',':');
    plot([a.reverseDay(m)-0.5 a.reverseDay(m)-0.5],[-10000000 1000000],'k','yliminclude','off','xliminclude','off','LineWidth',4);        
    ylabel({'Anticipatory', 'lick rate'});
    xlabel('Day');
    leg = legend(ax,'Info-Rew','Info-No Rew','No Info - C','No Info - D','Location','southoutside','Orientation','horizontal');
    leg.Box = 'off';
    leg.FontWeight = 'bold';
    hold off;
    
    ax = nsubplot(4,2,1,2);
%     title(a.mouseList(m));
    title(a.dayCell{find(a.fileMouse == m & a.fileDay == a.mouseDayCt(m),1,'first')});
    ax.FontSize = 8;
    ax.XTick = [0:5:max(cell2mat(a.daySummary.day(m,:)))];
    ax.YLim = [0 inf];
    plot(cell2mat(a.daySummary.infoBigLicksWater(m,:)),'Color','g','LineWidth',2,'Marker','o','MarkerFaceColor','g','MarkerSize',3);
    plot(cell2mat(a.daySummary.infoSmallLicksWater(m,:)),'Color','m','LineWidth',2,'Marker','o','MarkerFaceColor','m','MarkerSize',3);
    plot(cell2mat(a.daySummary.randBigLicksWater(m,:)),'Color','b','LineWidth',2,'Marker','o','MarkerFaceColor','b','MarkerSize',3);
    plot(cell2mat(a.daySummary.randSmallLicksWater(m,:)),'Color','c','LineWidth',2,'Marker','o','MarkerFaceColor','c','MarkerSize',3);
%     plot(cell2mat(a.daySummary.randCLicksWater(m,:)),'Color','c','LineWidth',2,'Marker','o','MarkerFaceColor','c','MarkerSize',3);
%     plot(cell2mat(a.daySummary.randDLicksWater(m,:)),'Color','b','LineWidth',2,'Marker','o','MarkerFaceColor','b','MarkerSize',3);
    plot([a.reverseDay(m)-0.5 a.reverseDay(m)-0.5],[-10000000 1000000],'k','yliminclude','off','xliminclude','off','LineWidth',4);        
    ylabel({'Post-outcome', 'lick rate'});
%     xlabel('Day');
    leg = legend(ax,'Info-Rew','Info-No Rew','No Info - Rew','No Info - No Rew','Location','southoutside','Orientation','horizontal');
    leg.Box = 'off';
    leg.FontWeight = 'bold';
    hold off;
    
    ax = nsubplot(4,2,2,2);
    ax.FontSize = 8;
    ax.XTick = [0:5:max(cell2mat(a.daySummary.day(m,:)))];
    ax.YLim = [0 inf];
    plot(cell2mat(a.daySummary.ARewards(m,:)),'Color','g','LineWidth',2,'Marker','o','MarkerFaceColor','g','MarkerSize',3);
    plot(cell2mat(a.daySummary.BRewards(m,:)),'Color','m','LineWidth',2,'Marker','o','MarkerFaceColor','m','MarkerSize',3);
    plot(cell2mat(a.daySummary.CRewards(m,:)),'Color',cornflower,'LineWidth',2,'Marker','o','MarkerFaceColor',cornflower,'MarkerSize',3);
    plot(cell2mat(a.daySummary.DRewards(m,:)),'Color',cornflower,'LineWidth',2,'Marker','o','MarkerEdgeColor',cornflower,'MarkerSize',3,'LineStyle',':');
%     plot(cell2mat(a.daySummary.randBigRewards(m,:)),'Color','c','LineWidth',2,'Marker','o','MarkerFaceColor','c','MarkerSize',3);
%     plot(cell2mat(a.daySummary.randSmallRewards(m,:)),'Color','b','LineWidth',2,'Marker','o','MarkerFaceColor','b','MarkerSize',3);
    plot([a.reverseDay(m)-0.5 a.reverseDay(m)-0.5],[-10000000 1000000],'k','yliminclude','off','xliminclude','off','LineWidth',4);        
    ylabel({'Mean Reward', '(uL)'});
%     xlabel('Day');
    leg = legend(ax,'Info-Rew','Info-No Rew','No Info - C','No Info - D','Location','southoutside','Orientation','horizontal');
    leg.Box = 'off';
    leg.FontWeight = 'bold';
    hold off;
    
    ax = nsubplot(4,2,3,2);
    ax.FontSize = 8;
    ax.XTick = [0:5:max(cell2mat(a.daySummary.day(m,:)))];
    ax.YLim = [6000 20000];
    plot(cell2mat(a.daySummary.trialLengthInfoForced(m,:)),'Color',purple,'LineWidth',2,'Marker','o','MarkerFaceColor',purple,'MarkerSize',3);
    plot(cell2mat(a.daySummary.trialLengthInfoChoice(m,:)),'Color',purple,'LineWidth',2,'Marker','o','MarkerFaceColor',purple,'MarkerSize',3,'LineStyle',':');
    plot(cell2mat(a.daySummary.trialLengthRandForced(m,:)),'Color',orange,'LineWidth',2,'Marker','o','MarkerFaceColor',orange,'MarkerSize',3);
    plot(cell2mat(a.daySummary.trialLengthRandChoice(m,:)),'Color',orange,'LineWidth',2,'Marker','o','MarkerFaceColor',orange,'MarkerSize',3,'LineStyle',':');
    plot([a.reverseDay(m)-0.5 a.reverseDay(m)-0.5],[-10000000 1000000],'k','yliminclude','off','xliminclude','off','LineWidth',4);
    ylabel({'Trial', 'duration (ms)'});
%     xlabel('Day');
    leg = legend(ax,'Info Forced','Info Choice','No Info Forced','No Info Choice','Location','southoutside','Orientation','horizontal');
    leg.Box = 'off';
    leg.FontWeight = 'bold';
    hold off;

    ax = nsubplot(4,2,4,2);
    ax.FontSize = 8;
    ax.XTick = [0:5:max(cell2mat(a.daySummary.day(m,:)))];
    ax.YLim = [0 0.5];
    plot(cell2mat(a.daySummary.rewardRateInfoForced(m,:)),'Color',purple,'LineWidth',2,'Marker','o','MarkerFaceColor',purple,'MarkerSize',3);
    plot(cell2mat(a.daySummary.rewardRateInfoChoice(m,:)),'Color',purple,'LineWidth',2,'Marker','o','MarkerEdgeColor',purple,'MarkerFaceColor','w','MarkerSize',3,'LineStyle',':');
    plot(cell2mat(a.daySummary.rewardRateRandForced(m,:)),'Color',orange,'LineWidth',2,'Marker','o','MarkerFaceColor',orange,'MarkerSize',3);
    plot(cell2mat(a.daySummary.rewardRateRandChoice(m,:)),'Color',orange,'LineWidth',2,'Marker','o','MarkerEdgeColor',orange,'MarkerFaceColor','w','MarkerSize',3,'LineStyle',':');
    plot([a.reverseDay(m)-0.5 a.reverseDay(m)-0.5],[-10000000 1000000],'k','yliminclude','off','xliminclude','off','LineWidth',4);
        plot(cell2mat(a.daySummary.infoBigLicksWater(m,:)),'Color','g','LineWidth',2,'Marker','o','MarkerFaceColor','g','MarkerSize',3,'Visible','off');
    plot(cell2mat(a.daySummary.infoSmallLicksWater(m,:)),'Color','m','LineWidth',2,'Marker','o','MarkerFaceColor','m','MarkerSize',3,'Visible','off');
    plot(cell2mat(a.daySummary.randBigLicksWater(m,:)),'Color','b','LineWidth',2,'Marker','o','MarkerFaceColor','b','MarkerSize',3,'Visible','off');
    plot(cell2mat(a.daySummary.randSmallLicksWater(m,:)),'Color','c','LineWidth',2,'Marker','o','MarkerFaceColor','c','MarkerSize',3,'Visible','off');
    plot(cell2mat(a.daySummary.CRewards(m,:)),'Color',cornflower,'LineWidth',2,'Marker','o','MarkerFaceColor',cornflower,'MarkerSize',3,'Visible','off');
    plot(cell2mat(a.daySummary.DRewards(m,:)),'Color',cornflower,'LineWidth',2,'Marker','o','MarkerEdgeColor',cornflower,'MarkerSize',3,'LineStyle',':','Visible','off');
    ylabel({'Reward', 'Rate'});
    xlabel('Day');    
    leg = legend(ax,'Info Forced','Info Choice','No Info Forced','No Info Choice','Location','southoutside','Orientation','horizontal');
    leg.Box = 'off';
    leg.FontWeight = 'bold';

%     leg = legend(ax,'Info Forced','Info Choice','No Info Forced','No Info Choice''Info-Rew','Info-No Rew','No Info - Rew','No Info - No Rew','No Info - C','No Info - D','Units','normalized','Position',[0.2 0.6 0.1 0.2],'Orientation','horizontal');
%     leg.Box = 'off';
%     leg.FontWeight = 'bold';

    hold off;

   
    saveas(fig,fullfile(pathname,a.mouseList{m}),'pdf');
    close(fig);
    
end


%% PLOT DAY SUMMARIES BY MOUSE BEFORE CHOICE

% for m = a.currentMiceNums(1):a.currentMiceNums(end)
%     figure();
%     
%     fig = gcf;
%     fig.PaperUnits = 'inches';
%     fig.PaperPosition = [0.5 0.5 10 7];
%     set(fig,'renderer','painters');
%     set(fig,'PaperOrientation','landscape');
%     
%     ax = nsubplot(4,2,1,1);
%     title(a.mouseList(m));
%     ax.FontSize = 8;
%     ax.XTick = [0:5:a.mouseDayCt(m)];
%     ax.XLim = [1 a.mouseDayCt(m)]; 
% %     set(ax,'units','inches');
% %     adoc x.Position = [1 1 5 1];
% %     yyaxis left;
% %     bar(1:a.mouseDayCt(m),cell2mat(a.daySummary.totalTrials(m,:)),0.5,'FaceColor',[1 1 1],'EdgeColor',[0.3 0.3 0.3]);
% %     ylabel('Trials completed');
% %     ax.YColor = 'k';
% %     yyaxis right;
% %     scatter(1:a.mouseDayCt(m),cell2mat(a.daySummary.infoBigProb(m,:)),'filled','markerfacecolor','k');
%     plot(1:a.mouseDayCt(m),cell2mat(a.daySummary.infoBigProb(m,:)),'Color','k','LineWidth',2,'Marker','o','MarkerFaceColor','k','MarkerSize',3);
%     for d = 1:a.mouseDayCt(m)
%     text(d+0.1,a.daySummary.infoBigProb{m,d}+10,[num2str(a.daySummary.totalTrials{m,d}),' trials'],'Fontsize',5);
%     end
%     ylabel('Big reward probability');
%     ax.YLim = [0 100];
%     ax.YTick = [0 25 50 75 100];
% %     ax.YColor = 'k';
%     hold off;
%     
%     ax = nsubplot(4,2,2,1);
%     ax.FontSize = 8;
%     ax.XTick = [0:5:max(cell2mat(a.daySummary.day(m,:)))];
%     plot(cell2mat(a.daySummary.rxnInfoForced(m,:)),'Color',purple,'LineWidth',2,'Marker','o','MarkerFaceColor',purple,'MarkerSize',3);
%     plot(cell2mat(a.daySummary.rxnInfoChoice(m,:)),'Color',purple,'LineWidth',2,'Marker','o','MarkerEdgeColor',purple,'MarkerFaceColor','w','MarkerSize',3,'LineStyle',':');
%     plot(cell2mat(a.daySummary.rxnRandForced(m,:)),'Color',orange,'LineWidth',2,'Marker','o','MarkerFaceColor',orange,'MarkerSize',3);
%     plot(cell2mat(a.daySummary.rxnRandChoice(m,:)),'Color',orange,'LineWidth',2,'Marker','o','MarkerEdgeColor',orange,'MarkerFaceColor','w','MarkerSize',3,'LineStyle',':');
%     plot([a.reverseDay(m)-0.5 a.reverseDay(m)-0.5],[-10000000 1000000],'k','yliminclude','off','xliminclude','off','LineWidth',4);
%     ylabel({'Reaction', 'Time (ms)'});
% %     xlabel('Day');    
%     leg = legend(ax,'Info-Forced','Info-Choice','No Info - Forced','No Info - Choice','Location','southoutside','Orientation','horizontal');
%     leg.Box = 'off';
%     leg.FontWeight = 'bold';
%     hold off;
%     
%     ax = nsubplot(4,2,3,1);
%     ax.FontSize = 8;
%     ax.XTick = [0:5:max(cell2mat(a.daySummary.day(m,:)))];
%     ax.YLim = [0 inf];
%     plot(cell2mat(a.daySummary.infoBigLicksEarly(m,:)),'Color','g','LineWidth',2,'Marker','o','MarkerFaceColor','g','MarkerSize',3);
%     plot(cell2mat(a.daySummary.infoSmallLicksEarly(m,:)),'Color','m','LineWidth',2,'Marker','o','MarkerFaceColor','m','MarkerSize',3);
%     plot(cell2mat(a.daySummary.randCLicksEarly(m,:)),'Color',cornflower,'LineWidth',2,'Marker','o','MarkerFaceColor',cornflower,'MarkerSize',3);
%     plot(cell2mat(a.daySummary.randDLicksEarly(m,:)),'Color',cornflower,'LineWidth',2,'Marker','o','MarkerEdgeColor',cornflower,'MarkerSize',3,'LineStyle',':');
% %     plot(cell2mat(a.daySummary.randBigLicksEarly(m,:)),'Color','c','LineWidth',2,'Marker','o','MarkerFaceColor','c','MarkerSize',3);
% %     plot(cell2mat(a.daySummary.randSmallLicksEarly(m,:)),'Color','b','LineWidth',2,'Marker','o','MarkerFaceColor','b','MarkerSize',3);
%     plot([a.reverseDay(m)-0.5 a.reverseDay(m)-0.5],[-10000000 1000000],'k','yliminclude','off','xliminclude','off','LineWidth',4);        
%     ylabel({'Early', 'lick rate'});
% %     xlabel('Day');
%     leg = legend(ax,'Info-Rew','Info-No Rew','No Info - C','No Info - D','Location','southoutside','Orientation','horizontal');
%     leg.Box = 'off';
%     leg.FontWeight = 'bold';
%     hold off;
% 
%     ax = nsubplot(4,2,4,1);
%     ax.FontSize = 8;
%     ax.XTick = [0:5:max(cell2mat(a.daySummary.day(m,:)))];
%     ax.YLim = [0 inf];
%     plot(cell2mat(a.daySummary.infoBigLicks(m,:)),'Color','g','LineWidth',2,'Marker','o','MarkerFaceColor','g','MarkerSize',3);
%     plot(cell2mat(a.daySummary.infoSmallLicks(m,:)),'Color','m','LineWidth',2,'Marker','o','MarkerFaceColor','m','MarkerSize',3);
%     plot(cell2mat(a.daySummary.randCLicks(m,:)),'Color',cornflower,'LineWidth',2,'Marker','o','MarkerFaceColor',cornflower,'MarkerSize',3);
%     plot(cell2mat(a.daySummary.randDLicks(m,:)),'Color',cornflower,'LineWidth',2,'Marker','o','MarkerEdgeColor',cornflower,'MarkerSize',3,'LineStyle',':');
%     plot([a.reverseDay(m)-0.5 a.reverseDay(m)-0.5],[-10000000 1000000],'k','yliminclude','off','xliminclude','off','LineWidth',4);        
%     ylabel({'Anticipatory', 'lick rate'});
%     xlabel('Day');
%     leg = legend(ax,'Info-Rew','Info-No Rew','No Info - C','No Info - D','Location','southoutside','Orientation','horizontal');
%     leg.Box = 'off';
%     leg.FontWeight = 'bold';
%     hold off;
%     
%     ax = nsubplot(4,2,1,2);
% %     title(a.mouseList(m));
%     title(a.dayCell{find(a.fileMouse == m & a.fileDay == a.mouseDayCt(m),1,'first')});
%     ax.FontSize = 8;
%     ax.XTick = [0:5:max(cell2mat(a.daySummary.day(m,:)))];
%     ax.YLim = [0 inf];
%     plot(cell2mat(a.daySummary.infoBigLicksWater(m,:)),'Color','g','LineWidth',2,'Marker','o','MarkerFaceColor','g','MarkerSize',3);
%     plot(cell2mat(a.daySummary.infoSmallLicksWater(m,:)),'Color','m','LineWidth',2,'Marker','o','MarkerFaceColor','m','MarkerSize',3);
%     plot(cell2mat(a.daySummary.randBigLicksWater(m,:)),'Color','b','LineWidth',2,'Marker','o','MarkerFaceColor','b','MarkerSize',3);
%     plot(cell2mat(a.daySummary.randSmallLicksWater(m,:)),'Color','c','LineWidth',2,'Marker','o','MarkerFaceColor','c','MarkerSize',3);
% %     plot(cell2mat(a.daySummary.randCLicksWater(m,:)),'Color','c','LineWidth',2,'Marker','o','MarkerFaceColor','c','MarkerSize',3);
% %     plot(cell2mat(a.daySummary.randDLicksWater(m,:)),'Color','b','LineWidth',2,'Marker','o','MarkerFaceColor','b','MarkerSize',3);
%     plot([a.reverseDay(m)-0.5 a.reverseDay(m)-0.5],[-10000000 1000000],'k','yliminclude','off','xliminclude','off','LineWidth',4);        
%     ylabel({'Post-outcome', 'lick rate'});
% %     xlabel('Day');
%     leg = legend(ax,'Info-Rew','Info-No Rew','No Info - Rew','No Info - No Rew','Location','southoutside','Orientation','horizontal');
%     leg.Box = 'off';
%     leg.FontWeight = 'bold';
%     hold off;
%     
%     ax = nsubplot(4,2,2,2);
%     ax.FontSize = 8;
%     ax.XTick = [0:5:max(cell2mat(a.daySummary.day(m,:)))];
%     ax.YLim = [0 inf];
%     plot(cell2mat(a.daySummary.ARewards(m,:)),'Color','g','LineWidth',2,'Marker','o','MarkerFaceColor','g','MarkerSize',3);
%     plot(cell2mat(a.daySummary.BRewards(m,:)),'Color','m','LineWidth',2,'Marker','o','MarkerFaceColor','m','MarkerSize',3);
%     plot(cell2mat(a.daySummary.CRewards(m,:)),'Color',cornflower,'LineWidth',2,'Marker','o','MarkerFaceColor',cornflower,'MarkerSize',3);
%     plot(cell2mat(a.daySummary.DRewards(m,:)),'Color',cornflower,'LineWidth',2,'Marker','o','MarkerEdgeColor',cornflower,'MarkerSize',3,'LineStyle',':');
% %     plot(cell2mat(a.daySummary.randBigRewards(m,:)),'Color','c','LineWidth',2,'Marker','o','MarkerFaceColor','c','MarkerSize',3);
% %     plot(cell2mat(a.daySummary.randSmallRewards(m,:)),'Color','b','LineWidth',2,'Marker','o','MarkerFaceColor','b','MarkerSize',3);
%     plot([a.reverseDay(m)-0.5 a.reverseDay(m)-0.5],[-10000000 1000000],'k','yliminclude','off','xliminclude','off','LineWidth',4);        
%     ylabel({'Mean Reward', '(uL)'});
% %     xlabel('Day');
%     leg = legend(ax,'Info-Rew','Info-No Rew','No Info - C','No Info - D','Location','southoutside','Orientation','horizontal');
%     leg.Box = 'off';
%     leg.FontWeight = 'bold';
%     hold off;
%     
%     ax = nsubplot(4,2,3,2);
%     ax.FontSize = 8;
%     ax.XTick = [0:5:max(cell2mat(a.daySummary.day(m,:)))];
%     ax.YLim = [6000 20000];
%     plot(cell2mat(a.daySummary.trialLengthInfoForced(m,:)),'Color',purple,'LineWidth',2,'Marker','o','MarkerFaceColor',purple,'MarkerSize',3);
%     plot(cell2mat(a.daySummary.trialLengthInfoChoice(m,:)),'Color',purple,'LineWidth',2,'Marker','o','MarkerFaceColor',purple,'MarkerSize',3,'LineStyle',':');
%     plot(cell2mat(a.daySummary.trialLengthRandForced(m,:)),'Color',orange,'LineWidth',2,'Marker','o','MarkerFaceColor',orange,'MarkerSize',3);
%     plot(cell2mat(a.daySummary.trialLengthRandChoice(m,:)),'Color',orange,'LineWidth',2,'Marker','o','MarkerFaceColor',orange,'MarkerSize',3,'LineStyle',':');
%     plot([a.reverseDay(m)-0.5 a.reverseDay(m)-0.5],[-10000000 1000000],'k','yliminclude','off','xliminclude','off','LineWidth',4);
%     ylabel({'Trial', 'duration (ms)'});
% %     xlabel('Day');
%     leg = legend(ax,'Info Forced','Info Choice','No Info Forced','No Info Choice','Location','southoutside','Orientation','horizontal');
%     leg.Box = 'off';
%     leg.FontWeight = 'bold';
%     hold off;
% 
%     ax = nsubplot(4,2,4,2);
%     ax.FontSize = 8;
%     ax.XTick = [0:5:max(cell2mat(a.daySummary.day(m,:)))];
%     ax.YLim = [0 0.5];
%     plot(cell2mat(a.daySummary.rewardRateInfoForced(m,:)),'Color',purple,'LineWidth',2,'Marker','o','MarkerFaceColor',purple,'MarkerSize',3);
%     plot(cell2mat(a.daySummary.rewardRateInfoChoice(m,:)),'Color',purple,'LineWidth',2,'Marker','o','MarkerEdgeColor',purple,'MarkerFaceColor','w','MarkerSize',3,'LineStyle',':');
%     plot(cell2mat(a.daySummary.rewardRateRandForced(m,:)),'Color',orange,'LineWidth',2,'Marker','o','MarkerFaceColor',orange,'MarkerSize',3);
%     plot(cell2mat(a.daySummary.rewardRateRandChoice(m,:)),'Color',orange,'LineWidth',2,'Marker','o','MarkerEdgeColor',orange,'MarkerFaceColor','w','MarkerSize',3,'LineStyle',':');
%     plot([a.reverseDay(m)-0.5 a.reverseDay(m)-0.5],[-10000000 1000000],'k','yliminclude','off','xliminclude','off','LineWidth',4);
%         plot(cell2mat(a.daySummary.infoBigLicksWater(m,:)),'Color','g','LineWidth',2,'Marker','o','MarkerFaceColor','g','MarkerSize',3,'Visible','off');
%     plot(cell2mat(a.daySummary.infoSmallLicksWater(m,:)),'Color','m','LineWidth',2,'Marker','o','MarkerFaceColor','m','MarkerSize',3,'Visible','off');
%     plot(cell2mat(a.daySummary.randBigLicksWater(m,:)),'Color','b','LineWidth',2,'Marker','o','MarkerFaceColor','b','MarkerSize',3,'Visible','off');
%     plot(cell2mat(a.daySummary.randSmallLicksWater(m,:)),'Color','c','LineWidth',2,'Marker','o','MarkerFaceColor','c','MarkerSize',3,'Visible','off');
%     plot(cell2mat(a.daySummary.CRewards(m,:)),'Color',cornflower,'LineWidth',2,'Marker','o','MarkerFaceColor',cornflower,'MarkerSize',3,'Visible','off');
%     plot(cell2mat(a.daySummary.DRewards(m,:)),'Color',cornflower,'LineWidth',2,'Marker','o','MarkerEdgeColor',cornflower,'MarkerSize',3,'LineStyle',':','Visible','off');
%     ylabel({'Reward', 'Rate'});
%     xlabel('Day');    
%     leg = legend(ax,'Info Forced','Info Choice','No Info Forced','No Info Choice','Location','southoutside','Orientation','horizontal');
%     leg.Box = 'off';
%     leg.FontWeight = 'bold';
% 
% %     leg = legend(ax,'Info Forced','Info Choice','No Info Forced','No Info Choice''Info-Rew','Info-No Rew','No Info - Rew','No Info - No Rew','No Info - C','No Info - D','Units','normalized','Position',[0.2 0.6 0.1 0.2],'Orientation','horizontal');
% %     leg.Box = 'off';
% %     leg.FontWeight = 'bold';
% 
%     hold off;
% 
%    
%     saveas(fig,fullfile(pathname,['preChoice' a.mouseList{m}]),'pdf');
%     close(fig);
%     
% end


%% ALL MOUSE SUMMARIES CHOICE + LICKING

% for m = 1:a.mouseCt
%     figure();
%     
%     fig = gcf;
%     fig.PaperUnits = 'inches';
%     fig.PaperPosition = [0.5 0.5 7 10];
%     set(fig,'renderer','painters');
%     set(fig,'PaperOrientation','portrait');
%     
%     ax = nsubplot(4,1,1,1);
%     title(a.mouseList(m));
%     ax.FontSize = 8;
%     ax.XTick = [0:5:a.mouseDayCt(m)];    
%     ax.YTick = [0 0.25 0.50 0.75 1];
%     ax.YLim = [0 1];
% %     set(ax,'units','inches');
% %     ax.Position = [1 1 5 1];
%     if sum(isnan(cell2mat(a.daySummary.percentInfo(m,:)))) ~= a.mouseDayCt(m)
%     plot(0:a.mouseDayCt(m),[0 cell2mat(a.daySummary.percentInfo(m,:))],'Color',a.mColors(m,:),'LineWidth',2,'Marker','o','MarkerFaceColor',a.mColors(m,:),'MarkerSize',3);
%     plot([-10000000 1000000],[0.5 0.5],'k','xliminclude','off','color',[0.6 0.6 0.6],'LineWidth',2);
%     plot([a.reverseDay(m)-0.5 a.reverseDay(m)-0.5],[-10000000 1000000],'k','yliminclude','off','xliminclude','off','LineWidth',4);
%     end
%     ylabel({'Info choice', 'probability'}); %ylabel({'line1', 'line2','line3'},)
% %     xlabel('Day');
%     hold off;
%     
%     ax = nsubplot(4,1,2,1);
%     ax.FontSize = 8;
%     ax.XTick = [0:5:max(cell2mat(a.daySummary.day(m,:)))];
%     ax.YLim = [0 inf];
%     plot(cell2mat(a.daySummary.infoBigLicksEarly(m,:)),'Color','g','LineWidth',2,'Marker','o','MarkerFaceColor','g','MarkerSize',3);
%     plot(cell2mat(a.daySummary.infoSmallLicksEarly(m,:)),'Color','m','LineWidth',2,'Marker','o','MarkerFaceColor','m','MarkerSize',3);
%     plot(cell2mat(a.daySummary.randCLicksEarly(m,:)),'Color',cornflower,'LineWidth',2,'Marker','o','MarkerFaceColor',cornflower,'MarkerSize',3);
%     plot(cell2mat(a.daySummary.randDLicksEarly(m,:)),'Color',cornflower,'LineWidth',2,'Marker','o','MarkerEdgeColor',cornflower,'MarkerSize',3,'LineStyle',':');
% %     plot(cell2mat(a.daySummary.randBigLicksEarly(m,:)),'Color','c','LineWidth',2,'Marker','o','MarkerFaceColor','c','MarkerSize',3);
% %     plot(cell2mat(a.daySummary.randSmallLicksEarly(m,:)),'Color','b','LineWidth',2,'Marker','o','MarkerFaceColor','b','MarkerSize',3);
%     plot([a.reverseDay(m)-0.5 a.reverseDay(m)-0.5],[-10000000 1000000],'k','yliminclude','off','xliminclude','off','LineWidth',4);        
%     ylabel({'Early', 'lick rate'});
% %     xlabel('Day');
%     leg = legend(ax,'Info-Rew','Info-No Rew','No Info - C','No Info - D','Location','southoutside','Orientation','horizontal');
%     leg.Box = 'off';
%     leg.FontWeight = 'bold';
%     hold off;
% 
%     ax = nsubplot(4,1,3,1);
%     ax.FontSize = 8;
%     ax.XTick = [0:5:max(cell2mat(a.daySummary.day(m,:)))];
%     ax.YLim = [0 inf];
%     plot(cell2mat(a.daySummary.infoBigLicks(m,:)),'Color','g','LineWidth',2,'Marker','o','MarkerFaceColor','g','MarkerSize',3);
%     plot(cell2mat(a.daySummary.infoSmallLicks(m,:)),'Color','m','LineWidth',2,'Marker','o','MarkerFaceColor','m','MarkerSize',3);
%     plot(cell2mat(a.daySummary.randCLicks(m,:)),'Color',cornflower,'LineWidth',2,'Marker','o','MarkerFaceColor',cornflower,'MarkerSize',3);
%     plot(cell2mat(a.daySummary.randDLicks(m,:)),'Color',cornflower,'LineWidth',2,'Marker','o','MarkerEdgeColor',cornflower,'MarkerSize',3,'LineStyle',':');
%     plot([a.reverseDay(m)-0.5 a.reverseDay(m)-0.5],[-10000000 1000000],'k','yliminclude','off','xliminclude','off','LineWidth',4);        
%     ylabel({'Anticipatory', 'lick rate'});
%     xlabel('Day');
%     leg = legend(ax,'Info-Rew','Info-No Rew','No Info - C','No Info - D','Location','southoutside','Orientation','horizontal');
%     leg.Box = 'off';
%     leg.FontWeight = 'bold';
%     hold off;
%     
%     ax = nsubplot(4,1,4,1);
% %     title(a.mouseList(m));
%     title(a.dayCell{find(a.fileMouse == m & a.fileDay == a.mouseDayCt(m),1,'first')});
%     ax.FontSize = 8;
%     ax.XTick = [0:5:max(cell2mat(a.daySummary.day(m,:)))];
%     ax.YLim = [0 inf];
%     plot(cell2mat(a.daySummary.infoBigLicksWater(m,:)),'Color','g','LineWidth',2,'Marker','o','MarkerFaceColor','g','MarkerSize',3);
%     plot(cell2mat(a.daySummary.infoSmallLicksWater(m,:)),'Color','m','LineWidth',2,'Marker','o','MarkerFaceColor','m','MarkerSize',3);
%     plot(cell2mat(a.daySummary.randBigLicksWater(m,:)),'Color','b','LineWidth',2,'Marker','o','MarkerFaceColor','b','MarkerSize',3);
%     plot(cell2mat(a.daySummary.randSmallLicksWater(m,:)),'Color','c','LineWidth',2,'Marker','o','MarkerFaceColor','c','MarkerSize',3);
% %     plot(cell2mat(a.daySummary.randCLicksWater(m,:)),'Color','c','LineWidth',2,'Marker','o','MarkerFaceColor','c','MarkerSize',3);
% %     plot(cell2mat(a.daySummary.randDLicksWater(m,:)),'Color','b','LineWidth',2,'Marker','o','MarkerFaceColor','b','MarkerSize',3);
%     plot([a.reverseDay(m)-0.5 a.reverseDay(m)-0.5],[-10000000 1000000],'k','yliminclude','off','xliminclude','off','LineWidth',4);        
%     ylabel({'Post-outcome', 'lick rate'});
% %     xlabel('Day');
%     leg = legend(ax,'Info-Rew','Info-No Rew','No Info - Rew','No Info - No Rew','Location','southoutside','Orientation','horizontal');
%     leg.Box = 'off';
%     leg.FontWeight = 'bold';
%     hold off;
%    
%     saveas(fig,fullfile(pathname,['licks' a.mouseList{m}]),'pdf');
% %     close(fig);
%     
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% PLOT OUTCOMES BY MOUSE - ONLY WORKS FOR FSM, CURRENTLY SKIP

% FSM mice
a.FSMmice = zeros(a.mouseCt,1);
for m = 1:a.mouseCt
    if sum(a.FSM(a.mice(:,m) == 1)) > 0
        a.FSMmice(m,1) = 1;
    end
end
a.FSMmouseIdx = find(a.FSMmice);


    %% STACKED BARS

% for m = 21:a.mouseCt
%     if a.mouseDayCt(m) > 3
%         for d = 1:a.mouseDayCt(m)
%             [outcomeCounts(d,:),outcomeBins(d,:)] = histcounts(a.daySummary.outcome{m,d},[0.5:1:17.5],'Normalization','probability');
%         end
% 
%         figure();
%         fig = gcf;
%         fig.PaperUnits = 'inches';
%         fig.PaperPosition = [1 1 8 10];
%         set(fig,'renderer','painters')
%         set(fig,'PaperOrientation','portrait');
% 
%         ax = nsubplot(1,1,1,1);
%         title(a.mouseList(m));
%         ax.FontSize = 10;
%         ylabel('Trial Outcomes (% of trials)');
%         xlabel('Day');
%         ax.YLim = [0 1];
%         ax.YTick = [0:0.25:1];
%         colormap(fig,CC);
%         bar(outcomeCounts,'stacked');
%         set(gca, 'ydir', 'reverse');
%         leg = legend(ax,a.outcomeLabels,'Location','eastoutside');
%         leg.Box = 'off';
%         leg.FontWeight = 'bold';
%     else
%         figure();
%         fig = gcf;
%         fig.PaperUnits = 'inches';
%         fig.PaperPosition = [1 1 8 10];
%     %     set(fig,'PaperOrientation','landscape');
%         set(fig,'renderer','painters')
%         for d = 1:a.mouseDayCt(m)
%             ax = nsubplot(a.mouseDayCt(m),1,d,1);
%             if d==1
%             title(a.mouseList(m));       
%             end
%             ax.FontSize = 10;
%             [outcomeCounts,outcomeBins] = histcounts(a.daySummary.outcome{m,d},[0.5:1:17.5],'Normalization','probability');
%             bar([1:17],outcomeCounts);
%             plot([7.5 7.5],[-10000000 1000000],'k','yliminclude','off','color',[0.6 0.6 0.6],'LineWidth',2);
%             plot([12.5 12.5],[-10000000 1000000],'k','yliminclude','off','color',[0.6 0.6 0.6],'LineWidth',2);    
%             if d == ceil(a.mouseDayCt(m)/2)
%             ylabel('Trial Outcomes (% of trials)');
%             end
%             if d == a.mouseDayCt(m)
%                 ax.XTick = [1:17];
%             set(gca,'XTickLabel',a.outcomeLabels,'XTickLabelRotation',35)
%             end
%         end
%     end
%     saveas(fig,fullfile(pathname,['outcomesStacked' a.mouseList{m}]),'pdf');
%     close(fig);
% end

    %% bar plot for each day
for m = a.currentMiceNums(1):a.currentMiceNums(end)
    
% for m = 1:mouseCt    
    figure();
    fig = gcf;
    fig.PaperUnits = 'inches';
    fig.PaperPosition = [1 1 8 10];
%     set(fig,'PaperOrientation','landscape');
    set(fig,'renderer','painters')
    for d = 1:a.mouseDayCt(m)
        ax = nsubplot(a.mouseDayCt(m),1,d,1);
        if d==1
        title(a.mouseList(m));       
        end
        ax.FontSize = 10;
        [outcomeCounts,outcomeBins] = histcounts(a.daySummary.outcome{m,d},[0.5:1:17.5],'Normalization','probability');
        bar([1:17],outcomeCounts);
        plot([7.5 7.5],[-10000000 1000000],'k','yliminclude','off','color',[0.6 0.6 0.6],'LineWidth',2);
        plot([12.5 12.5],[-10000000 1000000],'k','yliminclude','off','color',[0.6 0.6 0.6],'LineWidth',2);    
        if d == ceil(a.mouseDayCt(m)/2)
        ylabel('Trial Outcomes (% of trials)');
        end
        if d == a.mouseDayCt(m)
            ax.XTick = [1:17];
        set(gca,'XTickLabel',a.outcomeLabels,'XTickLabelRotation',35)
        end       
    end
        saveas(fig,fullfile(pathname,['outcomes' a.mouseList{m}]),'pdf');
        close(fig);

end

%%  bar plot for most recent day

% for m = a.FSMmouseIdx(1):a.FSMmouseIdx(end)
%     
for m = a.currentMiceNums(1):a.currentMiceNums(end)   
    figure();
    fig = gcf;
    fig.PaperUnits = 'inches';
    fig.PaperPosition = [1 1 10 7];
    set(fig,'PaperOrientation','landscape');
    set(fig,'renderer','painters')
    for d = a.mouseDayCt(m)
        ax = nsubplot(1,1,1,1);
        title([a.mouseList(m) a.dayCell{find(a.fileMouse == m & a.fileDay == a.mouseDayCt(m),1,'first')}]);       
        ax.FontSize = 10;
        [outcomeCounts,outcomeBins] = histcounts(a.daySummary.outcome{m,d},[0.5:1:17.5],'Normalization','probability');
        bar([1:17],outcomeCounts);
        plot([7.5 7.5],[-10000000 1000000],'k','yliminclude','off','color',[0.6 0.6 0.6],'LineWidth',2);
        plot([12.5 12.5],[-10000000 1000000],'k','yliminclude','off','color',[0.6 0.6 0.6],'LineWidth',2);    
        if d == ceil(a.mouseDayCt(m)/2)
        ylabel('Trial Outcomes (% of trials)');
        end
        if d == a.mouseDayCt(m)
            ax.XTick = [1:17];
        set(gca,'XTickLabel',a.outcomeLabels,'XTickLabelRotation',35)
        end
    end
    
    saveas(fig,fullfile(pathname,['outcomesMostRecentDay' a.mouseList{m}]),'pdf');
    close(fig);
end


    %% OVERALL
% for m=1:a.mouseCt 
%     [outcomeCounts(m,:),outcomeBins(m,:)] = histcounts(a.daySummary.outcome{m,d},[0.5:1:17.5],'Normalization','probability');
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% PLOT MOST RECENT DAY'S LICKS - SKIP
%%     
% for m = 1:a.mouseCt
%     plotData = cell2mat(a.lickProbDays(:,:,m));
%     d = a.mouseDayCt(m);
%     
%     figure();
%     fig = gcf;
%     fig.PaperUnits = 'inches';
%     fig.PaperPosition = [1 1 7 9];
%     set(fig,'renderer','painters');
%     
%     for lp = 1:4
%         ax = nsubplot(4,1,lp,1);
%         hold on;
%         if lp ==1
%         title([char(a.mouseList{m}) ' Day ' char(string(d))]);
%         end
%         ax.FontSize = 12;
%         bar(bins,plotData((a.mouseDayCt(m)*(lp-1))+d,:),'edgecolor','none','facecolor',[0.4 0.4 0.4],'BarWidth',1);
%         xlim([0,a.maxBin*a.win]);
%         ylim([0,1]);
%         plot(a.odorWait*[1 1],[0 100],'k','yliminclude','off');
%         plot((a.odorWait+200)*[1 1],[0 100],'k','yliminclude','off');
%         plot((a.rewardWait+100)*[1 1],[0 100],'k','yliminclude','off');
%         plot(a.rewardWait*[1 1],[0 100],'k','yliminclude','off');
%         if lp == 4
%         xlabel('Time from go cue');
%         end
%         ylabel(strcat('Licks per-',a.typeNames(lp),' Trial'));
%         hold off;
%     end    
% 
%     
% %     ax = nsubplot(1,a.mouseCt,1,m);
% %     ax.FontSize = 10;
% % %     ax.XTick = [0:5:max(cell2mat(a.daySummary.day(m,:)))];
% % %     ax.YLim = [0 inf];
% %     bar([cell2mat(a.daySummary.infoBigLicks(m,d)) cell2mat(a.daySummary.infoSmallLicks(m,d)) cell2mat(a.daySummary.randCLicks(m,d)) cell2mat(a.daySummary.randDLicks(m,d))]);      
% %     ylabel('Anticipatory lick rate');
% %     xlabel(a.mouseList(m));
% %     hold off;
%     
% end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% LICK HISTOGRAMS / BINS BY DAY AND MOUSE - SKIPS 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% for m = 1:a.mouseCt
%     plotData = cell2mat(a.lickProbDays(:,:,m));
%     
%     figure();
%     hold on;
%     
%     if a.mouseDayCt(m) >= 3
% %         CT = cbrewer('seq', 'Blues', a.mouseDayCt(m));
%         CT = linspecer(a.mouseDayCt(m),'blue');
%     else
%         CT = ([0.419607843137255,0.682352941176471,0.839215686274510; 0.0313725490196078,0.188235294117647,0.419607843137255]);
%     end
%     
%     for lp = 1:4            
%         ax = nsubplot(4,1,lp,1);
%         colormap(CT);
%         if lp == 1
%             title([char(a.mouseList{m}) ': Licks per Trial']);
%         end
%         ax.FontSize = 12;
%         xlim([0,a.maxBin*a.win]);
%         ylim([0,0.75]);
%         for d = 1:a.mouseDayCt(m) 
%             plot(bins,plotData((a.mouseDayCt(m)*(lp-1))+d,:),'color',CT(d,:))
%         end
%         plot(a.odorWait*[1 1],[0 100],'k','yliminclude','off');
%         plot((a.odorWait+200)*[1 1],[0 100],'k','yliminclude','off');
%         plot((a.rewardWait+100)*[1 1],[0 100],'k','yliminclude','off');
%         plot(a.rewardWait*[1 1],[0 100],'k','yliminclude','off');
%         if lp == 4
%             xlabel('Time from go cue');
% %             colorbar('southoutside')
%         end
%         ylabel(a.typeNames(lp));
%         hold off;
%     end
% end

    %%  PLOT BY MOUSE AND DAY

    %% 
% for m = 1:a.mouseCt
%     plotData = cell2mat(a.lickProbDays(:,:,m));
%     for d = 1:a.mouseDayCt(m)        
%         figure();
%         for lp = 1:4
%             ax = nsubplot(4,1,lp,1);
%             hold on;
%             if lp ==1
%             title([char(a.mouseList{m}) ' Day ' char(string(d))]);
%             end
%             ax.FontSize = 12;
%             bar(bins,plotData((a.mouseDayCt(m)*(lp-1))+d,:),'edgecolor','none','facecolor',[0.4 0.4 0.4],'BarWidth',1);
%             plot(bins,plotData((a.mouseDayCt(m)*(lp-1))+d,:))
%             xlim([0,a.maxBin*a.win]);
%             ylim([0,1]);
%             plot(a.odorWait*[1 1],[0 100],'k','yliminclude','off');
%             plot((a.odorWait+200)*[1 1],[0 100],'k','yliminclude','off');
%             plot((a.rewardWait+100)*[1 1],[0 100],'k','yliminclude','off');
%             plot(a.rewardWait*[1 1],[0 100],'k','yliminclude','off');
%             if lp == 4
%             xlabel('Time from go cue');
%             end
%             ylabel(strcat('Licks per-',a.typeNames(lp),' Trial'));
%             hold off;
%         end
%     end
% end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ALL MICE SUMMARIES

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% PLOT ALL-TIME SORTED PREFERENCE BARS WITH CONFIDENCE INTERVAL (overall.pdf)

if a.choiceMouseCt > 1
    fig = figure();
    
    fig = gcf;
    fig.PaperUnits = 'inches';
    fig.PaperPosition = [0.5 0.5 10 7];
    set(fig,'renderer','painters');
    set(fig,'PaperOrientation','landscape');
    
    ax = nsubplot(1,1,1,1);
    ax.FontSize = 8;
    ax.XTick = [1:a.choiceMouseCt+1];
    ax.YTick = [0 0.25 0.50 0.75 1];
    ax.XTickLabel = [a.sortedMouseList; 'Mean'];
    ax.YLim = [0 1];
    for m = 1:a.choiceMouseCt
%         bar(m,a.sortedChoice(m,1),'facecolor',a.mColors(m,:),'edgecolor','none');
          bar(m,a.sortedChoice(m,1),'facecolor',[0.3 0.3 0.3],'edgecolor','none');
          errorbar(m,a.sortedChoice(m,1),a.sortedChoice(m,1) - a.sortedCI(m,1),a.sortedCI(m,2) - a.sortedChoice(m,1),'LineStyle','none','LineWidth',2,'Color','k');
    end
    bar(a.choiceMouseCt+1,a.overallPref,'facecolor','k','edgecolor','none');
    errorbar(a.choiceMouseCt+1,a.overallPref,a.overallPref - a.overallCI(1),a.overallCI(2) - a.overallPref,'LineStyle','none','LineWidth',2,'Color','k');
    plot([-10000000 1000000],[0.5 0.5],'k','yliminclude','off','xliminclude','off');
    text(a.choiceMouseCt+2,a.overallPref,['p = ' num2str(a.overallP)])
    ylabel('Info side preference');
    xlabel('Mouse');
    hold off;
    
    saveas(fig,fullfile(pathname,'Overall'),'pdf');
    close(fig);
end

%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% PLOT CUMULATIVE CHOICE - SKIPS

alt = zeros(numToPlot,1);
alt(2:2:numToPlot) = 1;
alt = cumsum(alt);

perf = cumsum(ones(numToPlot,1));

% figure();
% ax = nsubplot(1,1,1,1);
% ax.FontSize = 12;
% for m = 1:a.choiceMouseCt
%     cumPlotData = a.cumChoiceByMouse{m};
%     plot(cumPlotData(1:numToPlot),'color',a.mColors(m,:),'LineWidth',2);
% end
% plot(perf,'color','k','LineWidth',4);
% plot(alt,'color','k','LineWidth',4);
% hold off;

%% CHOICE RANGE DATA (PRE-REVERSE)

if a.choiceMouseCt > 0
    
    % CALC RANGE DATA
    choiceToPlot = [];
    mouseChoiceData = [];
    rxnData = [];
    lickEarlyData = [];
    lickAnticData = [];
    rxnToPlot = [];
    lickEarlyToPlot = [];
    lickAnticToPlot = [];
    rewardData = [];
    rewardToPlot = [];
    for m = 1:a.choiceMouseCt
       mouseChoiceData = a.choicebyMouse{m};
       numToPlotByMouse(m,1) = min(numToPlot,numel(mouseChoiceData));
       rxnData = a.choiceRxnByMouse{m};
       lickEarlyData = a.choiceEarlyLicksByMouse{m};
       lickAnticData = a.choiceAnticLicksByMouse{m};
       rewardData = a.choiceRewardByMouse{m};
       choiceToPlot(m,:) = mouseChoiceData(1:numToPlot);
       rxnToPlot(m,:) = rxnData(1:numToPlot);
       lickEarlyToPlot(m,:) = lickEarlyData(1:numToPlot);
       lickAnticToPlot(m,:) = lickAnticData(1:numToPlot);
       rewardToPlot(m,:) = rewardData(1:numToPlot);
    end

    [sortedChoiceToPlot,sortIdx] = sortrows(choiceToPlot);
    miceSortToPlot = (a.mouseList(sortIdx));

    %% CHOICE Pre-reverse RANGE DATA BY MOUSE (earlyJBXXX.pdf)

    % MAKE DYNAMIC re: trial nums, pre/post reverse

    for m = a.choiceMice(1):a.choiceMice(end)
        fig = figure();

        fig = gcf;
        fig.PaperUnits = 'inches';
        fig.PaperPosition = [0.5 0.5 7 10];
        set(fig,'renderer','painters');
        set(fig,'PaperOrientation','portrait');

        ax = nsubplot(5,1,1,1);
        ax.FontSize = 12;
        title(a.choiceMiceList(m));
        ax.XLim = [1 numToPlotByMouse(m)];
        ax.YLim = [0.5 1.5];
        ax.XTickLabel = [];
        ax.YTick = [];
        ylabel('Choice');
        imagesc('XData',(1:numToPlotByMouse(m)),'YData',(1),'CData',choiceToPlot(m,:))
        colormap(ax,map);
        % colorbar('YTick',[0.25 0.75],'TickLabels',{'No Info','Info'},'FontSize',12,'TickLength',0,'Location','northoutside');

        ax = nsubplot(5,1,2,1);
        ax.FontSize = 12;
        ax.XLim = [1 numToPlotByMouse(m)];
        ax.YLim = [0.5 1.5];
        ax.XTickLabel = [];
        ax.YTick = [];
        ylabel('Reward');
        imagesc('XData',(1:numToPlotByMouse(m)),'YData',(1),'CData',rewardToPlot(m,:))
        colormap(ax,[0 0 0; 1 1 1]);    

        ax = nsubplot(5,1,3,1);
        ax.FontSize = 12;
        ax.XLim = [1 numToPlotByMouse(m)];
        ax.XTickLabel = [];
        ylabel('Reaction Time');
        scatter(find(choiceToPlot(m,:)==1),rxnToPlot(m,choiceToPlot(m,:)==1),'filled','markerfacecolor',map(2,:));
        scatter(find(choiceToPlot(m,:)==0),rxnToPlot(m,choiceToPlot(m,:)==0),'filled','markerfacecolor',map(1,:));

        ax = nsubplot(5,1,4,1);
        ax.FontSize = 12;
        ax.XLim = [1 numToPlotByMouse(m)];
        ax.XTickLabel = [];
        ylabel('Early Licks');
        scatter(find(choiceToPlot(m,:)==1),lickEarlyToPlot(m,choiceToPlot(m,:)==1),'filled','markerfacecolor',map(2,:));
        scatter(find(choiceToPlot(m,:)==0),lickEarlyToPlot(m,choiceToPlot(m,:)==0),'filled','markerfacecolor',map(1,:));

        ax = nsubplot(5,1,5,1);
        ax.FontSize = 12;
        ax.XLim = [1 numToPlotByMouse(m)];
        ylabel('Anticipatory Licks');
        scatter(find(choiceToPlot(m,:)==1),lickAnticToPlot(m,choiceToPlot(m,:)==1),'filled','markerfacecolor',map(2,:));
        scatter(find(choiceToPlot(m,:)==0),lickAnticToPlot(m,choiceToPlot(m,:)==0),'filled','markerfacecolor',map(1,:));
        xlabel('Choice Trial');
        lgd = legend('Info','No Info');
        lgd.FontSize = 16; lgd.Location = 'southoutside';
        lgd.Orientation = 'horizontal'; lgd.Box = 'off';
        % set(icons(:),'MarkerSize',20); %// Or whatever
        % icons(1).Children.MarkerSize = 20;

        saveas(fig,fullfile(pathname,['early' a.mouseList{m}]),'pdf');
        close(fig);
    end

    %% CHOICE pre-reverse RANGE HEATMAP (heatmap.pdf)

%     fig = figure();
%     ax = nsubplot(1,1,1,1);
%     ax.FontSize = 12;
%     title('Choices by Trial');
%     xlabel('Choice Trial');
%     ylabel('Mouse');
%     ax.YTick = [1:a.choiceMouseCt];
%     ax.XLim = [1 numToPlot];
%     ax.YLim = [0.5 a.choiceMouseCt+0.5];
%     ax.YTickLabel = miceSortToPlot;
%     ax.YGrid = 'on';
%     set(ax,'Box','off');
%     set(ax,'TickDir','out');
%     set(ax,'ticklen',[.01 .01]);
%     set(ax,'Color','none');
%     set(ax,'layer','top');
%     % set parent figure to have white bg color
%     set(get(ax,'parent'),'color','w');
%     hold(ax,'on');
%     imagesc('XData',(1:numToPlot),'YData',(1:a.choiceMouseCt),'CData',sortedChoiceToPlot)
%     colormap(linspecer(2));
%     colorbar('YTick',[0.25 0.75],'TickLabels',{'No Info','Info'},'FontSize',12,'TickLength',0);
%     saveas(fig,fullfile(pathname,'heatmap'),'pdf');
%     close (fig);
%     hold off;

%% PREFERENCES AND REGRESSION BASED ON TRIALS TO COUNT IN ANALYSIS (not range above)

    %% CHOICE PREF PRE- VS POST-REVERSAL FOR TRIALS TO COUNT (prevspost.pdf)

    fig = figure();
    fig.PaperUnits = 'inches';
    fig.PaperPosition = [0.5 0.5 10 7];
    set(fig,'renderer','painters');
    set(fig,'PaperOrientation','landscape');

    ax = nsubplot(1,1,1,1);
    ax.FontSize = 8;
    ax.XLim = [0 1];
    ax.YLim = [0 1];
    for m = 1:a.choiceMouseCt
        plot([a.pref(m,1) a.pref(m,1)],[a.prefRevCI(m,1) a.prefRevCI(m,2)],'color',[0.2 0.2 0.2],'linewidth',0.25);
        plot([a.prefCI(m,1) a.prefCI(m,2)],[a.pref(m,2) a.pref(m,2)],'color',[0.2 0.2 0.2],'linewidth',0.25);
        dy = a.prefRevCI(m,2) - a.pref(m,2) + 0.02;
        text(a.pref(m,1),a.pref(m,2) + dy,a.choiceMiceList{m},'HorizontalAlignment','center');
    end
    scatter(a.pref(:,1),a.pref(:,2),'filled')
    plot([-10000000 1000000],[0.5 0.5],'color',[0.2 0.2 0.2],'linewidth',0.25,'yliminclude','off','xliminclude','off');
    plot([0.5 0.5],[-10000000 1000000],'color',[0.2 0.2 0.2],'linewidth',0.25,'yliminclude','off','xliminclude','off');
    text(a.choiceMouseCt+2,a.overallPref,['p = ' num2str(a.overallP)])
    patch([0.5 1 1 0.5],[0 0 0.5 0.5],[0.3 0.3 0.3],'FaceAlpha',0.1,'EdgeColor','none');
    ylabel({'% choice of initially informative side', 'POST-reversal'}); %{'Info choice', 'probability'}
    xlabel({'% choice of initially informative side', 'PRE-reversal'});
    title('Raw choice percentages, pre vs post-reversal');
    hold off;

    saveas(fig,fullfile(pathname,'PrevsPost'),'pdf');
    close(fig);

    %% LOGISTIC REGRESSION ON TRIALS TO COUNT (regression.pdf) 

    fig = figure();
    fig.PaperUnits = 'inches';
    fig.PaperPosition = [0.5 0.5 10 7];
    set(fig,'renderer','painters');
    set(fig,'PaperOrientation','landscape');

    ax = nsubplot(1,1,1,1);
    ax.FontSize = 8;
    ax.XLim = [-10 10];
    ax.YLim = [-10 10];
    for m = 1:a.choiceMouseCt
%         plot([a.pref(m,1) a.pref(m,1)],[a.prefRevCI(m,1) a.prefRevCI(m,2)],'color',[0.2 0.2 0.2],'linewidth',0.25);
%         plot([a.prefCI(m,1) a.prefCI(m,2)],[a.pref(m,2) a.pref(m,2)],'color',[0.2 0.2 0.2],'linewidth',0.25);
%         dy = a.beta(m,2) - a.betaCI(m,2) + 0.02;
        text(a.beta(m,1),a.beta(m,2) + 0.2,a.choiceMiceList{m},'HorizontalAlignment','center');
    end
    scatter(a.beta(:,1),a.beta(:,2),'filled')
    plot([-10000000 1000000],[0.5 0.5],'color',[0.2 0.2 0.2],'linewidth',0.25,'yliminclude','off','xliminclude','off');
    plot([0.5 0.5],[-10000000 1000000],'color',[0.2 0.2 0.2],'linewidth',0.25,'yliminclude','off','xliminclude','off');
    ylabel({'Info preference', '(log odds biasing to currently informative side'}); %{'Info choice', 'probability'}
    xlabel({'Side bias', '(log odds biasing to initially informative side)'});
    title('Logistic Regression Analysis');
    hold off;

    saveas(fig,fullfile(pathname,'Regression'),'pdf');
    close(fig);

end

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% NEED TO ADD SLIDING WINDOW AVERAGING FOR MEAN CHOICE WITH CI

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PLOT CHOICES BY DAY
% 
% figure();
% ax = nsubplot(1,1,1,1);
% ax.FontSize = 12;
% ax.XTick = [1:max(choiceDayCt)];
% ax.YTick = [0 0.25 0.50 0.75 1];
% ax.YLim = [0 1];
% for m = 1:a.mouseCt
%     plot(cell2mat(a.meanDayChoicesOrg(m,:)),'Color',a.mColors(m,:),'LineWidth',3,'Marker','o','MarkerFaceColor',a.mColors(m,:),'MarkerSize',8);
% end
% plot([-10000000 1000000],[0.5 0.5],'k','xliminclude','off','color',[0.6 0.6 0.6],'LineWidth',2);
% leg = legend(a.mouseList,'Location','southoutside','Orientation','horizontal');
% leg.Box = 'off';
% leg.FontWeight = 'bold';
% ylabel('Info choice probability');
% xlabel('Day');
% hold off;

%% PLOT CHOICES BY DAY ALIGNED TO REVERSE

% figure();
% ax = nsubplot(1,1,1,1);
% ax.FontSize = 12;
% ax.XTick = [0:5:a.totalChoiceDays];
% ax.YTick = [0 0.25 0.50 0.75 1];
% ax.YLim = [0 1];
% for m = 1:a.mouseCt
%     plot(a.revChoiceDays{m,:},cell2mat(a.meanDayChoicesOrg(m,:)),'Color',a.mColors(m,:),'LineWidth',3,'Marker','o','MarkerFaceColor',a.mColors(m,:),'MarkerSize',8);
% end
% plot([-10000000 1000000],[0.5 0.5],'k','xliminclude','off','color',[0.6 0.6 0.6],'LineWidth',2);
% plot([revAlign-0.5 revAlign-0.5],[-10000000 1000000],'k','yliminclude','off','xliminclude','off','LineWidth',4);
% leg = legend(a.mouseList,'Location','southoutside','Orientation','horizontal');
% leg.Box = 'off';
% leg.FontWeight = 'bold';
% ylabel('Info choice probability');
% xlabel('Day');
% hold off;

%% PLOT MEAN CHOICE BY DAY WITH REVERSALS

% maxDays = a.dayswRev;
% plotDays = 1:maxDays;
% semPlus = a.meanChoicebyRevDay + a.semChoicebyRevDay;
% semMinus = a.meanChoicebyRevDay - a.semChoicebyRevDay;
% 
% figure();
% ax = nsubplot(1,1,1,1);
% ax.FontSize = 12;
% ax.XTick = [0:5:maxDays];
% ax.YTick = [0 0.25 0.50 0.75 1];
% ax.YLim = [0 1];
% p = patch([plotDays fliplr(plotDays)], [semMinus,fliplr(semPlus)],[0.8 0.8 0.8]);
% p.EdgeColor = 'none';
% plot(a.meanChoicebyRevDay,'LineWidth',4,'Marker','none','color',[0.3 0.3 0.3]);
% plot([-10000000 1000000],[0.5 0.5],'k','xliminclude','off','color','k','LineWidth',2)
% plot([revAlign-0.5 revAlign-0.5],[-10000000 1000000],'k','yliminclude','off','xliminclude','off','LineWidth',4);
% ylabel('Population Mean Info choice probability');
% xlabel('Day');
% hold off;

%% PLOT MEAN CHOICE BY DAY

% a.meanDayChoicesOrg(cellfun(@isempty,a.meanDayChoicesOrg(:,:))) = {NaN};
% 
% a.meanChoicebyDay = mean(cell2mat(a.meanDayChoicesOrg),1,'omitnan');
% a.semChoicebyDay = sem(cell2mat(a.meanDayChoicesOrg));
% 
% maxDays = size(a.meanDayChoicesOrg,2);
% plotDays = 1:maxDays;
% semPlus = a.meanChoicebyDay + a.semChoicebyDay;
% semMinus = a.meanChoicebyDay - a.semChoicebyDay;
% 
% figure();
% ax = nsubplot(1,1,1,1);
% ax.FontSize = 12;
% ax.XTick = [0:5:maxDays];
% ax.YTick = [0 0.25 0.50 0.75 1];
% ax.YLim = [0 1];
% p = patch([plotDays fliplr(plotDays)], [semMinus,fliplr(semPlus)],[0.8 0.8 0.8]);
% p.EdgeColor = 'none';
% plot(a.meanChoicebyDay,'LineWidth',4,'Marker','none','color',[0.3 0.3 0.3]);
% plot([-10000000 1000000],[0.5 0.5],'k','xliminclude','off','color','k','LineWidth',2)
% % plot([revAlign-0.5 revAlign-0.5],[-10000000 1000000],'k','yliminclude','off','xliminclude','off','LineWidth',4);
% ylabel('Population Mean Info choice probability');
% xlabel('Day');
% hold off;
