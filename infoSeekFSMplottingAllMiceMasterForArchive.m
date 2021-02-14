%% 

% 300 trials arbitrary. in new version, average ~110 trials per session
% currently: pre vs post analyses are last 300 trials around first reversal
% (right?!?) YES a.rxnSpeedIdx from a.preRevRxnSpeed (not sorted), whereas
% a.pref (PrevsPostIIS is sorted! but also only 300 trials --> add rxn speed and licks there?)
% "overall.pdf" pref/meanchoice is *all* prereverse trials 
% a.overallChoice includes all choice trials on each side!
% logistic regression betas include all choice trials on sides (rel IIS)
% reversalChoices, reversalRxn simply pulls days-->include last reversal?
% all days present, rxn, reward rate includes all trials
% all current reward rates pull days from daysummary.rewardRateRand etc
% for reversal multipref, include all reversals/average timecourse?

% to calc/plot: reward rate vs pref both initial and across all
% reward rate and reaction time across all reversals (reversalRxn)
% --> need to sort and pull last 300 trials (forced??) for each reversal
% period
% or all trials within reversal? 

% want pref by rxn and pref by reward rate

%% TO CALC/FIX

% TRIAL LENGTHS / LICKING TIME IN PORT-->how long does ITI need to be?

% "checking"/out of trial flow side entries

% outcome plots 
% fix lick prob days for histogram

% LICKS NEEDS TO ACCOUNT FOR TIME/ERROR TRIALS!!

% scatter of initial vs reversal pref for IIS in diff bins (# trials,
% days)--> NEED TO FIX BINNING/numToPlot? GET DAYS!!!
% correlation rxn time
% AGAIN - need to throw out bad rxn time trials and days

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
numToPlot = 200;

%% PLOTTING COLORS

a.mColors = linspecer(a.mouseCt);

a.mReverseColors = linspecer(numel(a.reverseMice));

a.mChoiceColors = linspecer(numel(a.choiceMice));

if ~isempty(a.choiceMice)
    % sort plotting colors
    a.sortedColors = a.mChoiceColors(a.sortIdx,:);
end

map = linspecer(2);

dx = 0.2;
dy = 0.02;

purple = [121 32 196] ./ 255;
orange = [251 139 6] ./ 255;
cornflower = [100 149 237] ./ 255;
grey = [.8 .8 .8];

CCfinal = [0.2,0.2,0.2; %choice no choice
    0.474509803921569,0.125490196078431,0.768627450980392; %choice info big
    171/255,130/255,1; % choice info big NP
    0.9490, 0.8, 1.0; %choiceinfosmall
    238/255,224/255,229/255; %choiceinfoNPsmall    
    0.984313725490196,0.545098039215686,0.0235294117647059; %choice rand big
    245/255,222/255,179/255; % choice rand big NP
    1, 0.8, 0.0; %choice rand small
    244/255, 164/255, 96/255; %choice rand small NP
    0.6,0.6,0.6; %info no choice
    0,1,0; %info big
    152/255,251/255,152/255;% info big NP
    1,0,1; %infosmall
    1,192/255,203/255; %info small not present
    0.0,0.0,0.0; %infoincorrect
    0.2,0.2,0.2;% rand no choice
    0,0,1; %rand big
    135/255,206/255,1; % rand big NP
    0,1,1; %rand small
    187/255,1,1; %rand small NP
    0.0,0.0,0.0]; %rand incorrect

a.outcomeLabels = {'ChoiceNoChoice','ChoiceInfoBig','ChoiceInfoSmall','ChoiceInfoNP','ChoiceRandBig',...
    'ChoiceRandSmall','ChoiceRandNP','InfoNoChoice','InfoBig','InfoSmall',...
    'InfoNP','InfoIncorrect','RandNoChoice','RandBig','RandSmall','RandNP',...
    'RandIncorrect'};

a.choiceLabels = {'ChoiceInfoBig','ChoiceInfoSmall','ChoiceRandBig',...
    'ChoiceRandSmall','InfoBig','InfoSmall','RandBig','RandSmall'};

a.finalOutcomeLabels = {'ChoiceNoChoice','ChoiceInfoBig','ChoiceInfoBigNP',...
    'ChoiceInfoSmall','ChoiceInfoSmallNP','ChoiceRandBig','ChoiceRandBigNP',...
    'ChoiceRandSmall','ChoiceRandSmallNP','InfoNoChoice','InfoBig',...
    'InfoBigNP','InfoSmall','InfoSmallNP','InfoIncorrect','RandNoChoice',...
    'RandBig','RandBigNP','RandSmall','RandSmallNP',...
    'RandIncorrect'};

% a.inPortLabels = {'ChoiceInfoBig','ChoiceInfoSmall','ChoiceRandBig',...
%     'ChoiceRandSmall','InfoBig','InfoSmall','RandBig','RandSmall'};

%%

if exist('D:\Dropbox\Data\Infoseek\Graphs')
  pathname = 'D:\Dropbox\Data\Infoseek\Graphs';
else
  pathname=uigetdir('','Choose save directory');
end

%% PLOT DAY SUMMARIES BY MOUSE FOR CURRENT MICE

% for mm = 1:numel(a.currentMiceNums)
%     m=a.currentMiceNums(mm);
for m = 1:a.mouseCt
    figure();
    
    fig = gcf;
    fig.PaperUnits = 'inches';
    fig.PaperPosition = [0 0 11 8.5];
    set(fig,'renderer','painters');
    set(fig,'PaperOrientation','landscape');
    
    ax = nsubplot(4,2,1,1);
    title(a.mouseList(m));
    ax.FontSize = 8;
%     set(ax,'units','inches');
%     ax.Position = [1 1 5 1];

    % if there's choice
%     if sum(isnan(cell2mat(a.daySummary.percentInfo(m,:)))) ~= a.mouseDayCt(m)
    if sum(a.mouseTrialTypes{m}>4) > 0
        ax.XTick = [0:5:a.mouseDayCt(m)];    
        ax.YTick = [0 0.25 0.50 0.75 1];
        ax.YLim = [-0.1 1.1];
        plot(0,0,'Marker','none');
        plot(1:a.mouseDayCt(m),[cell2mat(a.daySummary.percentInfo(m,:))],'Color',[.5 .5 .5],'LineWidth',2,'Marker','o','MarkerSize',3);
        if ismember(m,a.optoMice)
            om = find(a.optoMice == m);
            plot(a.laserDays{om,1},[cell2mat(a.daySummary.percentInfo(m,a.laserDays{om,1}))],'Color',[0 1 1],'LineStyle','none','Marker','o','MarkerFaceColor',[0 1 1],'MarkerSize',3);
        end        
        plot([-10000000 1000000],[0.5 0.5],'k','xliminclude','off','color',[0.8 0.8 0.8],'LineWidth',1);
        for r = 1:numel(cell2mat(a.reverseDay(m,:)))
            plot([a.reverseDay{m,r}-0.5 a.reverseDay{m,r}-0.5],[-10000000 1000000],'k','yliminclude','off','xliminclude','off','LineWidth',2);
        end

        for d = 1:a.mouseDayCt(m)
            text(d,1.05,num2str(a.daySummary.infoBigProb{m,d}),'Fontsize',5,'Color','r');
            text(d,-.05,num2str(a.daySummary.randBigProb{m,d}),'Fontsize',5,'Color','r');
            if d == a.mouseDayCt(m)
               text(d+.2,1.05,'Info p(water)','Fontsize',7,'Color','r');
               text(d+.2,-.05,'NoInfo p(water)','Fontsize',7,'Color','r');
            end
        end   
        ylabel({'Info choice', 'probability'}); %ylabel({'line1', 'line2','line3'},)
    %     xlabel('Day');
        hold off;
    else
        ax.XTick = [0:5:a.mouseDayCt(m)];
%         ax.XLim = [1 a.mouseDayCt(m)]; 
        plot(1:a.mouseDayCt(m),cell2mat(a.daySummary.infoBigProb(m,:)),'Color','k','LineWidth',1,'Marker','o','MarkerFaceColor','k','MarkerSize',2);
        for d = 1:a.mouseDayCt(m)
        text(d+0.1,a.daySummary.infoBigProb{m,d}+10,[num2str(a.daySummary.totalTrials{m,d}),' trials'],'Fontsize',5);
        end
        ylabel('Big reward probability');
        ax.YLim = [0 100];
        ax.YTick = [0 25 50 75 100];
    %     ax.YColor = 'k';
        hold off;
    end
    
    
    ax = nsubplot(4,2,2,1);
    ax.FontSize = 8;
    ax.XTick = [0:5:max(cell2mat(a.daySummary.day(m,:)))];
    ax.YLim = [0 2000];
    plot(cell2mat(a.daySummary.rxnInfoForced(m,:)),'Color',purple,'LineWidth',1);
    plot(cell2mat(a.daySummary.rxnInfoChoice(m,:)),'Color',purple,'LineWidth',1,'LineStyle',':');
    plot(cell2mat(a.daySummary.rxnRandForced(m,:)),'Color',orange,'LineWidth',1);
    plot(cell2mat(a.daySummary.rxnRandChoice(m,:)),'Color',orange,'LineWidth',1,'LineStyle',':');
    for r = 1:numel(cell2mat(a.reverseDay(m,:)))
        plot([a.reverseDay{m,r}-0.5 a.reverseDay{m,r}-0.5],[-10000000 1000000],'k','yliminclude','off','xliminclude','off','LineWidth',1);
    end
    ylabel({'Reaction', 'Time (ms)'});
%     xlabel('Day');    
    leg = legend(ax,['Info' newline '-Forced'],['Info' newline '-Choice'],['No Info' newline '-Forced'],['No Info' newline '-Choice'],'Location','southoutside','Orientation','horizontal');
    leg.Box = 'off';
    leg.FontWeight = 'bold';
    hold off;
    
    ax = nsubplot(4,2,3,1);
    ax.FontSize = 8;
    ax.XTick = [0:5:max(cell2mat(a.daySummary.day(m,:)))];
    ax.YLim = [0 inf];
    plot(cell2mat(a.daySummary.infoBigLicksEarly(m,:)),'Color','g','LineWidth',1);
    plot(cell2mat(a.daySummary.infoSmallLicksEarly(m,:)),'Color','m','LineWidth',1);
    plot(cell2mat(a.daySummary.randCLicksEarly(m,:)),'Color',cornflower,'LineWidth',1);
    plot(cell2mat(a.daySummary.randDLicksEarly(m,:)),'Color',cornflower,'LineWidth',1,'LineStyle',':');
%     plot(cell2mat(a.daySummary.randBigLicksEarly(m,:)),'Color','c','LineWidth',1);
%     plot(cell2mat(a.daySummary.randSmallLicksEarly(m,:)),'Color','b','LineWidth',1);
    for r = 1:numel(cell2mat(a.reverseDay(m,:)))
        plot([a.reverseDay{m,r}-0.5 a.reverseDay{m,r}-0.5],[-10000000 1000000],'k','yliminclude','off','xliminclude','off','LineWidth',1);
    end
    ylabel({'Early', 'lick rate'});
%     xlabel('Day');
    if ismember(m,find(a.noneMice))
        leg = legend(ax,'Info-Rew','Info-No Rew','No Info - C','No Info - D','Location','southoutside','Orientation','horizontal');
    else
        leg = legend(ax,'Info-Big','Info-Small','No Info - C','No Info - D','Location','southoutside','Orientation','horizontal');
    end
    leg.Box = 'off';
    leg.FontWeight = 'bold';
    hold off;

    ax = nsubplot(4,2,4,1);
    ax.FontSize = 8;
    ax.XTick = [0:5:max(cell2mat(a.daySummary.day(m,:)))];
    ax.YLim = [0 inf];
    plot(cell2mat(a.daySummary.infoBigLicks(m,:)),'Color','g','LineWidth',1);
    plot(cell2mat(a.daySummary.infoSmallLicks(m,:)),'Color','m','LineWidth',1);
    plot(cell2mat(a.daySummary.randCLicks(m,:)),'Color',cornflower,'LineWidth',1);
    plot(cell2mat(a.daySummary.randDLicks(m,:)),'Color',cornflower,'LineWidth',1,'LineStyle',':');
    for r = 1:numel(cell2mat(a.reverseDay(m,:)))
        plot([a.reverseDay{m,r}-0.5 a.reverseDay{m,r}-0.5],[-10000000 1000000],'k','yliminclude','off','xliminclude','off','LineWidth',1);
    end     
    ylabel({'Anticipatory', 'lick rate'});
    xlabel('Day');
    if ismember(m,find(a.noneMice))    
    leg = legend(ax,'Info-Rew','Info-No Rew','No Info - C','No Info - D','Location','southoutside','Orientation','horizontal');
    else
    leg = legend(ax,'Info-Big','Info-Small','No Info - C','No Info - D','Location','southoutside','Orientation','horizontal');
    end
    leg.Box = 'off';
    leg.FontWeight = 'bold';
    hold off;
    
    ax = nsubplot(4,2,1,2);
%     title(a.mouseList(m));
    title(a.dayCell{find(a.fileMouse == m & a.fileDay == a.mouseDayCt(m),1,'first')});
    ax.FontSize = 8;
    ax.XTick = [0:5:max(cell2mat(a.daySummary.day(m,:)))];
    ax.YLim = [0 inf];
    plot(cell2mat(a.daySummary.infoBigLicksWater(m,:)),'Color','g','LineWidth',1);
    plot(cell2mat(a.daySummary.infoSmallLicksWater(m,:)),'Color','m','LineWidth',1);
    plot(cell2mat(a.daySummary.randBigLicksWater(m,:)),'Color','b','LineWidth',1);
    plot(cell2mat(a.daySummary.randSmallLicksWater(m,:)),'Color','c','LineWidth',1);
%     plot(cell2mat(a.daySummary.randCLicksWater(m,:)),'Color','c','LineWidth'1);
%     plot(cell2mat(a.daySummary.randDLicksWater(m,:)),'Color','b','LineWidth',1);
    for r = 1:numel(cell2mat(a.reverseDay(m,:)))
        plot([a.reverseDay{m,r}-0.5 a.reverseDay{m,r}-0.5],[-10000000 1000000],'k','yliminclude','off','xliminclude','off','LineWidth',1);
    end   
    ylabel({'Post-outcome', 'lick rate'});
%     xlabel('Day');
    if ismember(m,find(a.noneMice))
    leg = legend(ax,'Info-Rew','Info-No Rew','No Info - Rew','No Info - No Rew','Location','southoutside','Orientation','horizontal');
    else
    leg = legend(ax,'Info-Big','Info-Small','No Info - Big','No Info - Small','Location','southoutside','Orientation','horizontal');        
    end
    leg.Box = 'off';
    leg.FontWeight = 'bold';
    hold off;
    
    ax = nsubplot(4,2,2,2);
    ax.FontSize = 8;
    ax.XTick = [0:5:max(cell2mat(a.daySummary.day(m,:)))];
    ax.YLim = [0 inf];
    plot(cell2mat(a.daySummary.ARewards(m,:)),'Color','g','LineWidth',1);
    plot(cell2mat(a.daySummary.BRewards(m,:)),'Color','m','LineWidth',1);
    plot(cell2mat(a.daySummary.CRewards(m,:)),'Color',cornflower,'LineWidth',1);
    plot(cell2mat(a.daySummary.DRewards(m,:)),'Color',cornflower,'LineWidth',1,'LineStyle',':');
    plot(cell2mat(a.daySummary.randBigRewards(m,:)),'Color','c','LineWidth',1);
    plot(cell2mat(a.daySummary.randSmallRewards(m,:)),'Color','b','LineWidth',1);
    for r = 1:numel(cell2mat(a.reverseDay(m,:)))
        plot([a.reverseDay{m,r}-0.5 a.reverseDay{m,r}-0.5],[-10000000 1000000],'k','yliminclude','off','xliminclude','off','LineWidth',1);
    end     
    ylabel({'Mean Reward', '(uL)'});
%     xlabel('Day');
    if ismember(m,find(a.noneMice))
    leg = legend(ax,['Info' newline '-Rew'],['Info' newline '-No Rew'],['No Info' newline '-C'],['No Info' newline '-D'],['No Info' newline '-Rew'],['No Info' newline '-No Rew'],'Location','southoutside','Orientation','horizontal');
    else
    leg = legend(ax,['Info' newline '-Big'],['Info' newline '-Small'],['No Info' newline '-C'],['No Info' newline '-D'],['No Info' newline '-Big'],['No Info' newline '-Small'],'Location','southoutside','Orientation','horizontal');        
    end
    leg.Box = 'off';
    leg.FontWeight = 'bold';
    hold off;
    
%     ax = nsubplot(4,2,3,2);
%     ax.FontSize = 8;
%     ax.XTick = [0:5:max(cell2mat(a.daySummary.day(m,:)))];
% %     ax.YLim = [6000 20000];
%     plot(cell2mat(a.daySummary.trialLengthEntryInfoForced(m,:)),'Color',purple,'LineWidth',2,'Marker','o','MarkerFaceColor',purple,'MarkerSize',3);
%     plot(cell2mat(a.daySummary.trialLengthEntryInfoChoice(m,:)),'Color',purple,'LineWidth',2,'Marker','o','MarkerFaceColor',purple,'MarkerSize',3,'LineStyle',':');
%     plot(cell2mat(a.daySummary.trialLengthEntryRandForced(m,:)),'Color',orange,'LineWidth',2,'Marker','o','MarkerFaceColor',orange,'MarkerSize',3);
%     plot(cell2mat(a.daySummary.trialLengthEntryRandChoice(m,:)),'Color',orange,'LineWidth',2,'Marker','o','MarkerFaceColor',orange,'MarkerSize',3,'LineStyle',':');
%     plot([a.reverseDay(m)-0.5 a.reverseDay(m)-0.5],[-10000000 1000000],'k','yliminclude','off','xliminclude','off','LineWidth',4);
%     ylabel({'Trial', 'duration (ms)'});
% %     xlabel('Day');
%     leg = legend(ax,'Info Forced','Info Choice','No Info Forced','No Info Choice','Location','southoutside','Orientation','horizontal');
%     leg.Box = 'off';
%     leg.FontWeight = 'bold';
%     hold off;

    ax = nsubplot(4,2,3,2);
    ax.FontSize = 8;
    ax.XTick = [0:5:max(cell2mat(a.daySummary.day(m,:)))];
%     ax.YLim = [6000 20000];
    plot(cell2mat(a.infoIncorr(m,:)),'Color',purple,'LineWidth',1);
    plot(cell2mat(a.randIncorr(m,:)),'Color',orange,'LineWidth',1);
    plot(cell2mat(a.choiceIncorr(m,:)),'Color',[0.5 0.5 0.5],'LineWidth',1);
    if ismember(m,a.optoMice)
        om = find(a.optoMice == m);
        plot(a.laserDays{om,1},ones(1,length(a.laserDays{om,1})),'Color',[0 1 1],'LineStyle','none','Marker','o','MarkerFaceColor',[0 1 1],'MarkerSize',5);
    end 
    for r = 1:numel(cell2mat(a.reverseDay(m,:)))
        plot([a.reverseDay{m,r}-0.5 a.reverseDay{m,r}-0.5],[-10000000 1000000],'k','yliminclude','off','xliminclude','off','LineWidth',1);
    end
    for d = 1:a.mouseDayCt(m)
        text(d+0.1,1.1,num2str(a.daySummary.totalTrials{m,d}),'Fontsize',5);
    end 
    ylabel('Error rate');
%     xlabel('Day');
    leg = legend(ax,'Info','No Info','Choice','Location','southoutside','Orientation','horizontal');
    leg.Box = 'off';
    leg.FontWeight = 'bold';
    hold off;

    ax = nsubplot(4,2,4,2);
    ax.FontSize = 8;
    ax.XTick = [0:5:max(cell2mat(a.daySummary.day(m,:)))];
    ax.YLim = [0 25];
    plot(cell2mat(a.daySummary.rewardRateInfoForced(m,:)),'Color',purple,'LineWidth',1);
    plot(cell2mat(a.daySummary.rewardRateRandForced(m,:)),'Color',orange,'LineWidth',1);
    plot(cell2mat(a.daySummary.rewardRateChoice(m,:)),'Color',[0.5 0.5 0.5],'LineWidth',1);
%     plot(cell2mat(a.daySummary.rewardRateInfoForced(m,:)),'Color',purple,'LineWidth',2,'Marker','o','MarkerFaceColor',purple,'MarkerSize',3);
%     plot(cell2mat(a.daySummary.rewardRateInfoChoice(m,:)),'Color',purple,'LineWidth',2,'Marker','o','MarkerEdgeColor',purple,'MarkerFaceColor','w','MarkerSize',3,'LineStyle',':');
%     plot(cell2mat(a.daySummary.rewardRateRandForced(m,:)),'Color',orange,'LineWidth',2,'Marker','o','MarkerFaceColor',orange,'MarkerSize',3);
%     plot(cell2mat(a.daySummary.rewardRateRandChoice(m,:)),'Color',orange,'LineWidth',2,'Marker','o','MarkerEdgeColor',orange,'MarkerFaceColor','w','MarkerSize',3,'LineStyle',':');
    for r = 1:numel(cell2mat(a.reverseDay(m,:)))
        plot([a.reverseDay{m,r}-0.5 a.reverseDay{m,r}-0.5],[-10000000 1000000],'k','yliminclude','off','xliminclude','off','LineWidth',1);
    end
%     plot(cell2mat(a.daySummary.infoBigLicksWater(m,:)),'Color','g','LineWidth',2,'Marker','o','MarkerFaceColor','g','MarkerSize',3,'Visible','off');
%     plot(cell2mat(a.daySummary.infoSmallLicksWater(m,:)),'Color','m','LineWidth',2,'Marker','o','MarkerFaceColor','m','MarkerSize',3,'Visible','off');
%     plot(cell2mat(a.daySummary.randBigLicksWater(m,:)),'Color','b','LineWidth',2,'Marker','o','MarkerFaceColor','b','MarkerSize',3,'Visible','off');
%     plot(cell2mat(a.daySummary.randSmallLicksWater(m,:)),'Color','c','LineWidth',2,'Marker','o','MarkerFaceColor','c','MarkerSize',3,'Visible','off');
%     plot(cell2mat(a.daySummary.CRewards(m,:)),'Color',cornflower,'LineWidth',2,'Marker','o','MarkerFaceColor',cornflower,'MarkerSize',3,'Visible','off');
%     plot(cell2mat(a.daySummary.DRewards(m,:)),'Color',cornflower,'LineWidth',2,'Marker','o','MarkerEdgeColor',cornflower,'MarkerSize',3,'LineStyle',':','Visible','off');
    ylabel({'Reward', 'Rate'});
    xlabel('Day');    
    leg = legend(ax,'Info','No Info','Choice','Location','southoutside','Orientation','horizontal');
    leg.Box = 'off';
    leg.FontWeight = 'bold';

%     leg = legend(ax,'Info Forced','Info Choice','No Info Forced','No Info Choice''Info-Rew','Info-No Rew','No Info - Rew','No Info - No Rew','No Info - C','No Info - D','Units','normalized','Position',[0.2 0.6 0.1 0.2],'Orientation','horizontal');
%     leg.Box = 'off';
%     leg.FontWeight = 'bold';

    hold off;

   
    saveas(fig,fullfile(pathname,a.mouseList{m}),'pdf');
%     saveas(fig,fullfile(pathname,a.mouseList{m}),'epsc');
%     close(fig);
    
end


%% PLOT DAY SUMMARIES BY MOUSE BEFORE CHOICE ONLY FOR PRE-CHOICE MICE - SKIPS

% if ~isempty(a.preChoiceMice)
% for m = a.preChoiceMice(1):a.preChoiceMice(end)
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
% %     close(fig);
%     
% end
% end


%% SUMMARIES CHOICE + LICKING FOR CURRENT MICE - SKIPS

% for m = 1:a.mouseCt
% for mm = 1:numel(a.currentMiceNums)
%     m=a.currentMiceNums(mm);
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
%     close(fig);
%     
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% CHOICE TRAINING PLOTS - SKIPS
% 
% % CHOICE TRIANING MICE
% a.choiceTrainingMice = zeros(a.mouseCt,1);
% for m = 1:a.mouseCt
%     mouseFiles = strcmp(a.mouseList(m),a.parameters(:,2));
%     if sum([sum(cell2mat(a.parameters(mouseFiles,7)) == 7) sum(cell2mat(a.parameters(mouseFiles,7)) == 8)]) > 0
%         a.choiceTrainingMice(m) = 1;
%     end    
% end
% a.choiceTrainingMiceIdx = find(a.choiceTrainingMice);
% 
% a.choiceTrainingFiles = cell2mat(a.parameters(:,7)) == 7 | cell2mat(a.parameters(:,7)) == 8;
% 
% % a.choiceTraining = zeros(numel(a.FSMall),1);
% % for t = 1:numel(a.choiceTraining)
% %     if a.parameters(a.fileAll,7) == 7 | a.parameters(a.fileAll,7) == 8
% %         a.choiceTraining(t,1) = 1;
% %     end
% % end
% 
% for mm = 1:numel(a.choiceTrainingMiceIdx)
%     m = a.choiceTrainingMiceIdx(mm);
%     
%     % & ismember(a.fileAll,find(a.choiceTrainingFiles))    
%     ok = a.miceAll(:,m) ;
%     
%     okTrials = numel(find(ok));
%     blockSwitches = find(diff(a.file(ok)));
%     okTypes = a.choiceType(ok);
%     okChoice = a.choice(ok);
%     okRxn = a.rxn(ok);
% 
%     figure();
% 
%     fig = gcf;
%     fig.PaperUnits = 'inches';
%     fig.PaperPosition = [0.5 0.5 10 7];
%     set(fig,'renderer','painters');
%     set(fig,'PaperOrientation','landscape');
%     hold on;
% 
% % use rxnAll, need by choice/side/info/rand and forced/choice
% % 1 = info, 0 = rand, 2 = none (timeout), 3 = incorrect (2 and 3 are errors)
% 
%     plot(okRxn);
%     plot(find(okTypes==1),okRxn(okTypes == 1),'LineStyle','none','Marker','o','MarkerFaceColor',purple);
%     plot(find(okTypes~=1),okRxn(okTypes ~= 1),'LineStyle','none','Marker','o');
%     for d = 1: numel(unique(a.file(ok)))-1
%         plot([blockSwitches(d)+0.5 blockSwitches(d)+0.5],[-10000000 1000000],'k','yliminclude','off','xliminclude','off','LineWidth',1); 
%     end
%     
% end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% PLOT OUTCOMES BY MOUSE FOR CURRENT MICE - ONLY WORKS FOR FSM

    %% STACKED BARS

for m = 1:a.mouseCt   
    
% for mm = 1:numel(a.currentMiceNums)
%     m=a.currentMiceNums(mm);
    outcomeCounts = [];
    outcomeBins = [];
    
    if a.mouseDayCt(m) > 3
        for d = 1:a.mouseDayCt(m)
            [outcomeCounts(d,:),outcomeBins(d,:)] = histcounts(a.daySummary.finalOutcome{m,d},[0.5:1:21.5],'Normalization','probability');
        end
        figure();
        fig = gcf;
        fig.PaperUnits = 'inches';
        fig.PaperPosition = [1 1 10 8];
        set(fig,'renderer','painters')
        set(fig,'PaperOrientation','landscape');
        
        ax = nsubplot(1,1,1,1);
        title(a.mouseList(m));
        ax.FontSize = 10;
        ylabel('Trial Outcomes (% of trials)');
        xlabel('Day');
        ax.YLim = [0 1];
        ax.YTick = [0:0.25:1];
        ax.XLim = [0 a.mouseDayCt(m)+1];
        ax.XTick = [1:10:a.mouseDayCt(m)];
        ax.XTickLabel = [1:10:a.mouseDayCt(m)];
        colormap(fig,CCfinal);
        bar(outcomeCounts,'stacked');
        set(gca, 'ydir', 'reverse');
        lgd = legend(ax,a.finalOutcomeLabels,'Location','eastoutside');
        lgd.Box = 'off';
        lgd.FontWeight = 'bold';

    else
        figure();
        fig = gcf;
        fig.PaperUnits = 'inches';
        fig.PaperPosition = [1 1 10 7];
    %     set(fig,'PaperOrientation','landscape');
        set(fig,'renderer','painters')
        for d = 1:a.mouseDayCt(m)
            ax = nsubplot(a.mouseDayCt(m),1,d,1);
            if d==1
            title(a.mouseList(m));       
            end
            ax.FontSize = 10;
            [outcomeCounts,outcomeBins] = histcounts(a.daySummary.finalOutcome{m,d},[0.5:1:21.5],'Normalization','probability');
            bar([1:21],outcomeCounts);
            plot([9.5 9.5],[-10000000 1000000],'k','yliminclude','off','color',[0.6 0.6 0.6],'LineWidth',2);
            plot([15.5 15.5],[-10000000 1000000],'k','yliminclude','off','color',[0.6 0.6 0.6],'LineWidth',2);    
            if d == ceil(a.mouseDayCt(m)/2)
                ylabel('Trial Outcomes (% of trials)');
            end
            if d == a.mouseDayCt(m)
                ax.XTick = [1:21];
            set(gca,'XTickLabel',a.finalOutcomeLabels,'XTickLabelRotation',35)
            end
        end
    end
    saveas(fig,fullfile(pathname,['outcomesStacked' a.mouseList{m}]),'pdf');
%     close(fig);
end

    %% bar plot for each day
% for for mm = 1:numel(a.currentMiceNums)
%     m=a.currentMiceNums(mm);
%     
% % for m = 1:mouseCt    
%     figure();
%     fig = gcf;
%     fig.PaperUnits = 'inches';
%     fig.PaperPosition = [1 1 8 10];
% %     set(fig,'PaperOrientation','landscape');
%     set(fig,'renderer','painters')
%     for d = 1:a.mouseDayCt(m)
%         ax = nsubplot(a.mouseDayCt(m),1,d,1);
%         if d==1
%         title(a.mouseList(m));       
%         end
%         ax.FontSize = 10;
%         [outcomeCounts,outcomeBins] = histcounts(a.daySummary.finalOutcome{m,d},[0.5:1:21.5],'Normalization','probability');
%         bar([1:2`],outcomeCounts);
%         plot([9.5 9.5],[-10000000 1000000],'k','yliminclude','off','color',[0.6 0.6 0.6],'LineWidth',2);
%         plot([15.5 15.5],[-10000000 1000000],'k','yliminclude','off','color',[0.6 0.6 0.6],'LineWidth',2);    
%         if d == ceil(a.mouseDayCt(m)/2)
%         ylabel('Trial Outcomes (% of trials)');
%         end
%         if d == a.mouseDayCt(m)
%             ax.XTick = [1:17];
%         set(gca,'XTickLabel',a.outcomeLabels,'XTickLabelRotation',35)
%         end       
%     end
%         saveas(fig,fullfile(pathname,['outcomes' a.mouseList{m}]),'pdf');
%         close(fig);
% 
% end

%%  bar plot for most recent day

% for m = a.FSMmouseIdx(1):a.FSMmouseIdx(end)
%     
% for mm = 1:numel(a.currentMiceNums)
%     m=a.currentMiceNums(mm); 
%     figure();
%     fig = gcf;
%     fig.PaperUnits = 'inches';
%     fig.PaperPosition = [1 1 10 7];
%     set(fig,'PaperOrientation','landscape');
%     set(fig,'renderer','painters')
%     for d = a.mouseDayCt(m)
%         ax = nsubplot(1,1,1,1);
%         title([a.mouseList(m) a.dayCell{find(a.fileMouse == m & a.fileDay == a.mouseDayCt(m),1,'first')}]);       
%         ax.FontSize = 10;
%         [outcomeCounts,outcomeBins] = histcounts(a.daySummary.outcome{m,d},[0.5:1:17.5],'Normalization','probability');
%         bar([1:17],outcomeCounts);
%         plot([7.5 7.5],[-10000000 1000000],'k','yliminclude','off','color',[0.6 0.6 0.6],'LineWidth',2);
%         plot([12.5 12.5],[-10000000 1000000],'k','yliminclude','off','color',[0.6 0.6 0.6],'LineWidth',2);    
%         if d == ceil(a.mouseDayCt(m)/2)
%         ylabel('Trial Outcomes (% of trials)');
%         end
%         if d == a.mouseDayCt(m)
%             ax.XTick = [1:17];
%         set(gca,'XTickLabel',a.outcomeLabels,'XTickLabelRotation',35)
%         end
%     end
%     
%     saveas(fig,fullfile(pathname,['outcomesMostRecentDay' a.mouseList{m}]),'pdf');
% %     close(fig);
% end

%% FINAL OUTCOME (error plots) ACROSS DAYS

% infoCorrCodes = [11 13 14];
% infoIncorrCodes = [10 12 15];
% randCorrCodes = [17 19];
% randIncorrCodes = [16 18 20 21];
% 
% for mm = 1:sum(a.FSMmice)
%     m=a.FSMmouseIdx(mm);
%     for d = 1:a.mouseDayCt(m)
%         outcomes = a.daySummary.finalOutcome{m,d};
%         infoCorr{m,d} = sum(ismember(outcomes,infoCorrCodes))/(sum(ismember(outcomes,infoCorrCodes))+sum(ismember(outcomes,infoIncorrCodes)));
%         infoIncorr{m,d} = sum(ismember(outcomes,infoIncorrCodes))/(sum(ismember(outcomes,infoCorrCodes))+sum(ismember(outcomes,infoIncorrCodes)));
%         randCorr{m,d} = sum(ismember(outcomes,randCorrCodes))/(sum(ismember(outcomes,randCorrCodes))+sum(ismember(outcomes,randIncorrCodes)));
%         randIncorr{m,d} = sum(ismember(outcomes,randIncorrCodes))/(sum(ismember(outcomes,randCorrCodes))+sum(ismember(outcomes,randIncorrCodes)));
%     end
% end

% for mm = 1:sum(a.FSMmice)
%     m=a.FSMmouseIdx(mm);
% 
%     figure();
%     fig = gcf;
%     fig.PaperUnits = 'inches';
%     fig.PaperPosition = [1 1 8 10];
%     set(fig,'renderer','painters')
%     set(fig,'PaperOrientation','portrait');
% 
%     ax = nsubplot(3,1,1,1);
%     title(a.mouseList(m));
%     ax.FontSize = 10;
%     ylabel('% info trials)');
%     xlabel('Day');
%     plot([1:6],cell2mat(infoCorr(m,7:12)),'Color',purple,'LineWidth',2);
%     plot([1:6],cell2mat(infoIncorr(m,7:12)),'Color',purple,'LineStyle','--','LineWidth',2);
%     
%     ax = nsubplot(3,1,2,1);
%     ax.FontSize = 10;
%     ylabel('% no info trials)');
%     xlabel('Day');
%     plot([1:6],cell2mat(randCorr(m,7:12)),'Color',orange,'LineWidth',2);
%     plot([1:6],cell2mat(randIncorr(m,7:12)),'Color',orange,'LineStyle','--','LineWidth',2);
%     
%     ax = nsubplot(3,1,3,1);
%     ax.FontSize = 10;
%     ylabel('Reward Probability');
%     xlabel('Day');
% %     plot([1:a.mouseDayCt(m)],cell2mat(a.daySummary.infoBigProb(m,:)),'Color','k','LineWidth',2);    
%     scatter([1:6],cell2mat(a.daySummary.infoBigProb(m,7:12)),50,'filled','MarkerFaceColor','k');
% 
%     saveas(fig,fullfile(pathname,['errors' a.mouseList{m}]),'pdf');
% %     close(fig);
% end

% for mm = 1:4
%     kb = [23 24 25 26];
%     m=kb(mm);
%     randIncorrData(mm,:) = cell2mat(randIncorr(m,7:12));
%     infoIncorrData(mm,:) = cell2mat(infoIncorr(m,7:12));
% end
% 
% kbMice = a.reverseMice(~ismember(a.reverseMice,kb));
% compMice = [17 18 19 20];
% 
% for mm = 1:numel(compMice)
%     m = compMice(mm);
%     randIncorrAllData(mm,:) = cell2mat(randIncorr(m,a.reverseDay(m)-1));
%     infoIncorrAllData(mm,:) = cell2mat(infoIncorr(m,a.reverseDay(m)-1));
% end
% 
% meanRandIncorr = mean(randIncorrData);
% stdRandIncorr = sem(randIncorrData);
% semRandPlus = meanRandIncorr + stdRandIncorr;
% semRandMinus = meanRandIncorr - stdRandIncorr;
% meanInfoIncorr = mean(infoIncorrData);
% stdInfoIncorr = sem(infoIncorrData);
% semInfoPlus = meanInfoIncorr + stdInfoIncorr;
% semInfoMinus = meanInfoIncorr - stdInfoIncorr;
% 
% meanAllRandIncorr = mean(randIncorrAllData(:,1));
% stdAllRandIncorr = sem(randIncorrAllData(:,1));
% semRandAllPlus = meanAllRandIncorr + stdAllRandIncorr;
% semRandAllMinus = meanAllRandIncorr - stdAllRandIncorr;
% meanAllInfoIncorr = mean(infoIncorrAllData(:,1));
% stdAllInfoIncorr = sem(infoIncorrAllData(:,1));
% semInfoAllPlus = meanAllInfoIncorr + stdAllInfoIncorr;
% semInfoAllMinus = meanAllInfoIncorr - stdAllInfoIncorr;
% 
% 
% 
%     figure();
%     fig = gcf;
%     fig.PaperUnits = 'inches';
%     fig.PaperPosition = [1 1 8 10];
%     set(fig,'renderer','painters')
%     set(fig,'PaperOrientation','portrait');
%     
%     ax = nsubplot(3,1,1,1);
%     ax.FontSize = 10;
%     ylabel('Reward Probability (%)');
%     xlabel('Day');
% %     plot([1:a.mouseDayCt(m)],cell2mat(a.daySummary.infoBigProb(m,:)),'Color','k','LineWidth',2);    
%     bar([1:7],[50 cell2mat(a.daySummary.infoBigProb(23,7:12))],'k');
% 
%     ax = nsubplot(3,1,2,1);
%     title('No Info Errors');
%     ax.FontSize = 10;
%     ylabel('% error on no info trials)');
%     xlabel('Day');
%     ax.XLim = [0 8];
%     ax.YLim = [0 .5];
% for mm = 1:4
%     kb = [23 24 25 26];
%     m=kb(mm);
% %     plot([0:7],[NaN cell2mat(randIncorr(m,7:12)) NaN],'Color',orange,'LineStyle','--','LineWidth',2);  
%     p = patch([[2:7] fliplr([2:7])], [semRandMinus,fliplr(semRandPlus)],[0.8 0.8 0.8]);
%     p.EdgeColor = 'none';
%     plot([1:8],nanmean([NaN(4,1) randIncorrData NaN(4,1)],1),'Color',orange,'LineWidth',4);
%     scatter(1,meanAllRandIncorr,'filled','MarkerEdgeColor','none','MarkerFaceColor',orange);
%     plot([1 1],[semRandAllPlus semRandAllMinus]);
% end
% 
%     ax = nsubplot(3,1,3,1);
%     title('Info Errors');
%     ax.FontSize = 10;
%     ylabel('% error on info trials)');
%     xlabel('Day');
%     ax.YLim = [0 .5];
%     ax.XLim = [0 7];
% for mm = 1:4
%     kb = [23 24 25 26];
%     m=kb(mm);
% %     plot([0:7],[NaN cell2mat(infoIncorr(m,7:12)) NaN],'Color',purple,'LineStyle','--','LineWidth',2);
%     p = patch([[2:7] fliplr([2:7])], [semInfoMinus,fliplr(semInfoPlus)],[0.8 0.8 0.8]);
%     p.EdgeColor = 'none';
%     plot([1:8],nanmean([NaN(4,1) infoIncorrData NaN(4,1)],1),'Color',purple,'LineWidth',4);
%     scatter(1,meanAllInfoIncorr,'filled','MarkerEdgeColor','none','MarkerFaceColor',purple);
%     plot([1 1],[semInfoAllPlus semInfoAllMinus]);
% end
%     hold off;
% 
%     saveas(fig,fullfile(pathname,['errors']),'pdf');
% %     close(fig);
% 
% for mm = 1:numel(kb)
%    m = kb(mm);
%    infoMeanLength(mm,1) = nanmean(a.trialLengthCenterEntry(a.mice(:,m)==1 & a.infoForcedCorr==1));
%    randMeanLength(mm,1) = nanmean(a.trialLengthCenterEntry(a.mice(:,m)==1 & a.randForcedCorr==1));
%    [~,lengthSig(mm,1)] = ttest2(a.trialLengthCenterEntry(a.mice(:,m)==1 & a.infoForcedCorr==1),a.trialLengthCenterEntry(a.mice(:,m)==1 & a.randForcedCorr==1));
%     
% end
% 
% 
% figure();
% fig = gcf;
% fig.PaperUnits = 'inches';
% fig.PaperPosition = [1 1 8 10];
% set(fig,'renderer','painters')
% set(fig,'PaperOrientation','portrait');
% 
% ax = nsubplot(1,1,1,1);
% ax.FontSize = 10;
% ax.YLim = [15000 25000];
% ylabel('Trial Length');
% xlabel('Mouse');
% b = bar([1:4],[infoMeanLength randMeanLength])
% b(1).FaceColor = purple;
% b(2).FaceColor = orange;
% b(1).EdgeColor = 'none';
% b(2).EdgeColor = 'none';
% saveas(fig,fullfile(pathname,['errorLengths']),'pdf');

%% ERROR MICE PREFERENCES

% fig = figure();    
% fig = gcf;
% fig.PaperUnits = 'inches';
% fig.PaperPosition = [0.5 0.5 10 7];
% set(fig,'renderer','painters');
% set(fig,'PaperOrientation','landscape');
% 
% ax = nsubplot(1,1,1,1);
% ax.FontSize = 8;
% %     ax.XTick = [1:a.choiceMouseCt+1];
% % ax.YTick = [0 0.25 0.50 0.75 1];
% %     ax.XTickLabel = [a.sortedMouseList; 'Mean'];
% ax.YLim = [0 1];
% for mm = 1:4
%     kb = [17 18 19 20];
%     m=kb(mm);
%     bar(m,a.meanChoice(m,1),'facecolor',[0.3 0.3 0.3],'edgecolor','none');
%     errorbar(m,a.meanChoice(m,1),a.meanChoice(m,1) - a.choiceCI(m,1),a.choiceCI(m,2) - a.meanChoice(m,1),'LineStyle','none','LineWidth',2,'Color','k');
% end
% plot([-10000000 1000000],[0.5 0.5],'k','yliminclude','off','xliminclude','off');
% ylabel('Info side preference');
% xlabel('Mouse');
% hold off;
% 
%     saveas(fig,fullfile(pathname,'ErrorMicePrefs'),'pdf');
%     close(fig);


%% NOT PRESENT IN PORT OVERALL

% for mm = 1:numel(a.currentMiceNums)
%     m=a.currentMiceNums(mm);
for m = 1:a.mouseCt
    figure();
    fig = gcf;
    fig.PaperUnits = 'inches';
    fig.PaperPosition = [0.5 0.5 10 7];
    set(fig,'renderer','painters');
    set(fig,'PaperOrientation','landscape');
    
    ax = nsubplot(1,1,1,1);
    title(a.mouseList(m));
    ax.FontSize = 8;
    ylabel('% trials not present in reward port at outcome');
    
    ax.YTick = [0 0.25 0.50 0.75 1];
    ax.YLim = [-0.1 1.1];
    
    bar(a.incomplete(m,:),'FaceColor','k','EdgeColor','none');
    set(gca,'XTickLabel',a.choiceLabels,'XTick',[1:8]);
    
    saveas(fig,fullfile(pathname,['notPresent' a.mouseList{m}]),'pdf');

end

%%
    figure();
    fig = gcf;
    fig.PaperUnits = 'inches';
    fig.PaperPosition = [0.5 0.5 10 7];
    set(fig,'renderer','painters');
    set(fig,'PaperOrientation','landscape');
    
    ax = nsubplot(1,1,1,1);
    title('Not Present in Port at Outcome');
    ax.FontSize = 8;
    ylabel('% trials not present in reward port at outcome');
    
    ax.YTick = [0 0.25 0.50 0.75 1];
    ax.YLim = [-0.1 1.1];
    
    bar(mean(a.incomplete),'FaceColor','none','EdgeColor','k');
    hold on;
    plot(a.incomplete','Linestyle','none','Marker','o');
    set(gca,'XTickLabel',a.choiceLabels,'XTick',[1:8]);
    
    saveas(fig,fullfile(pathname,'notPresentMean'),'pdf');


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

%% PLOT PRE-REVERSE SORTED PREFERENCE BARS WITH CONFIDENCE INTERVAL (overall.pdf)

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
    saveas(fig,fullfile(pathname,'Overall'),'png');
%     close(fig);
end

%% PLOT VALUE RESPONSE CURVES

% by mouse (1 fig for each mouse, plot1: value vs pref + baseline...
% plot2: pref and vals each day)

a.currentValMice = a.currentMiceNums(ismember(a.currentMiceNums,a.valueMice));

% for mC = 1:numel(a.currentValMice)
%     m = a.currentValMice(mC);
%     mm = find(a.valueMice == m);

a.tempValueMice = a.valueMice;
    
for mm = 1:numel(a.tempValueMice)
    m =a.tempValueMice(mm);
    
    fig = figure();
    fig = gcf;
    fig.PaperUnits = 'inches';
    fig.PaperPosition = [0.5 0.5 10 7];
    set(fig,'renderer','painters');
    set(fig,'PaperOrientation','landscape');
     
    ax = nsubplot(2,1,1,1);
    title(a.mouseList(m));
    ax.FontSize = 8;
    ax.XLim = [0 2];
%     ax.XTickMode = 'manual';
%     ax.XTick = [0 0.5 1 1.5 2];
%     set(ax,'XTick',[0 0.5 1 1.5 2]);
%     ax.YTick = [0 0.25 0.50 0.75 1];
    ax.YLim = [0 1];
    s=a.relValues';
%     xticklabels([strtrim(cellstr(num2str(s'))') 'Overall']);
    ylabel({'Info choice', 'probability'});
    xlabel('Info side relative water amount');
    mouseVals = ~isnan(a.valChoiceMeanbyMouse(mm,:));
    plot([-10000000 1000000],[0.5 0.5],'Color',grey,'yliminclude','off','xliminclude','off');
    plot(a.relValues(mouseVals),a.valChoiceMeanbyMouse(mm,mouseVals),'Color','r','LineWidth',3,'Marker','o','MarkerFaceColor','r','MarkerSize',3);
    plot(a.relValues(mouseVals),a.valChoiceMeanbyMouse(mm,mouseVals)+a.valChoiceSEMbyMouse(mm,mouseVals),'Color','r','LineWidth',1,'Marker','none','MarkerFaceColor','r','MarkerSize',3);
    plot(a.relValues(mouseVals),a.valChoiceMeanbyMouse(mm,mouseVals)-a.valChoiceSEMbyMouse(mm,mouseVals),'Color','r','LineWidth',1,'Marker','none','MarkerFaceColor','r','MarkerSize',3);
    %     bar(2,a.meanChoice(m,1),0.2,'FaceColor','r','EdgeColor','none');
%     bar([a.relValues(mouseVals); 2],[a.valChoiceMeanbyMouse(mm,mouseVals) a.meanChoice(m,1)],0.2,'FaceColor','k');
%     xticklabels(['0' strtrim(cellstr(num2str(s'))')]);

    ax = nsubplot(2,1,2,1);    
    ax.FontSize = 8;
%     ax.YLim = [0 1];
    xlabel('Day');
    yyaxis left
    ax = gca;
    ax.YColor = 'k';
    ylabel({'Info', 'relative value'});
    ax.YTick = [0 0.5 1 1.5 2];
    ax.YLim = [0 2];
    plot([-10000000 1000000],[1 1],'Color',grey,'yliminclude','off','xliminclude','off','LineWidth',0.5);
%     bar([1 cell2mat(a.daySummary.infoBigAmt(m,a.mouseValueDays{mm,1}))/4],'FaceColor','k','EdgeColor','none');
    if ismember(m,a.valueMiceInfo)
        bar([1 cell2mat(a.daySummary.infoBigAmt(m,a.mouseValueDays{mm,1}))./4],'FaceColor','k','EdgeColor','none');
    else
        bar([1 4./cell2mat(a.daySummary.randBigAmt(m,a.mouseValueDays{mm,1}))],'FaceColor','k','EdgeColor','none');
    end
    
    
    yyaxis right
    ax = gca;
    ax.YColor = 'r';
    ylabel({'Info choice', 'probability'});
    ax.YTick = [0 0.25 0.50 0.75 1];
    ax.YLim = [0 1];
    plot([-10000000 1000000],[0.5 0.5],'Color','r','yliminclude','off','xliminclude','off','LineWidth',0.5);
    plot(1:numel(a.mouseValueDays{mm,1})+1,[a.meanChoice(m,1) cell2mat(a.daySummary.percentInfo(m,a.mouseValueDays{mm,1}))],'Color','r','LineWidth',3,'LineStyle','-','Marker','o','MarkerFaceColor',[.5 .5 .5],'MarkerSize',3);    

    saveas(fig,fullfile(pathname,['values' a.mouseList{m}]),'pdf');
end

%% overall value plot
% 1 fig, plot val vs pref (mean + error + baseline)

if ~isempty(a.valueMice)

    fig = figure();
    fig = gcf;
    fig.PaperUnits = 'inches';
    fig.PaperPosition = [0.5 0.5 10 7];
    set(fig,'renderer','painters');
    set(fig,'PaperOrientation','landscape');
    ax = nsubplot(1,1,1,1);
    hold on;
    % ax.FontSize = 8;
    % ax.XLim = [0 2.5];
    % ax.XTick = [0 a.relValues'];
    % xticklabels(['0' strtrim(cellstr(num2str(s'))') 'Original (1)']);
    ax.YTick = [0 0.25 0.50 0.75 1];
    ax.YLim = [0 1];
    ylabel({'Info choice probability', 'across mice'});
    xlabel('Info side relative water amount');
    % p = patch([[a.relValues'] fliplr([a.relValues'])], [[a.choiceByAmtMean-a.choiceByAmtSEM]',[fliplr([a.choiceByAmtMean+a.choiceByAmtSEM]')]],[0.8 0.8 0.8]);
    % p.EdgeColor = 'none';
    % plot(a.relValues,a.choiceByAmtMean,'Color','k','LineWidth',2,'Marker','o','MarkerFaceColor','k','MarkerSize',3);
    % bar(a.relValues,a.choiceByAmtMean,'FaceColor','k');
    plot(a.relValues(~isnan(a.choiceByAmtProbMean(:,1))),a.choiceByAmtProbMean(~isnan(a.choiceByAmtProbMean(:,1)),1),'Color','m','LineWidth',1,'Marker','o','MarkerFaceColor','k','MarkerEdgeColor','k','MarkerSize',3);
    plot(a.relValues(~isnan(a.choiceByAmtProbMean(:,2))),a.choiceByAmtProbMean(~isnan(a.choiceByAmtProbMean(:,2)),2),'Color','g','LineWidth',1,'Marker','o','MarkerFaceColor','k','MarkerEdgeColor','k','MarkerSize',3);
    % plot(a.relValues(~isnan(a.choiceByAmtProbMean(:,3))),a.choiceByAmtProbMean(~isnan(a.choiceByAmtProbMean(:,3)),3),'Color','b','LineWidth',1,'Marker','o','MarkerFaceColor','k','MarkerEdgeColor','k','MarkerSize',3);
    plot(a.relValues,a.choiceByAmtMean(:,1),'Color','k','LineWidth',3,'Marker','o','MarkerFaceColor','k','MarkerEdgeColor','k','MarkerSize',3);
    plot(a.relValues,a.choiceByAmtMean(:,1)+a.choiceByAmtSEM(:,1),'Color','k','LineWidth',1,'Marker','none');
    plot(a.relValues,a.choiceByAmtMean(:,1)-a.choiceByAmtSEM(:,1),'Color','k','LineWidth',1,'Marker','none');
    % bar(2,a.overallPref,0.2,'FaceColor','r','EdgeColor','none');
    % errorbar(2,a.overallPref,a.overallPref - a.overallCI(1),a.overallCI(2) - a.overallPref,'CapSize',20,'LineStyle','none','LineWidth',2,'Color','k');

    % errorbar(a.relValues,a.choiceByAmtMean,a.choiceByAmtSEM,'Color','k','LineStyle','none','CapSize',10,'LineWidth',2);
    plot([-10000000 1000000],[0.5 0.5],'Color',grey,'yliminclude','off','xliminclude','off');
    hold off;

    saveas(fig,fullfile(pathname,'OverallValue'),'pdf');
end

%% overall value plot
% 1 fig, plot val vs pref (mean + error + baseline)

if ~isempty(a.valueMice)

    fig = figure();
    fig = gcf;
    fig.PaperUnits = 'inches';
    fig.PaperPosition = [0.5 0.5 10 7];
    set(fig,'renderer','painters');
    set(fig,'PaperOrientation','landscape');
    ax = nsubplot(1,1,1,1);
    hold on;
    % ax.FontSize = 8;
    % ax.XLim = [0 2.5];
    % ax.XTick = [0 a.relValues'];
    % xticklabels(['0' strtrim(cellstr(num2str(s'))') 'Original (1)']);
    ax.YTick = [0 0.25 0.50 0.75 1];
    ax.YLim = [0 1];
    ylabel({'Info choice probability', 'across mice'});
    xlabel('Info side relative water amount');
    % p = patch([[a.relValues'] fliplr([a.relValues'])], [[a.choiceByAmtMean-a.choiceByAmtSEM]',[fliplr([a.choiceByAmtMean+a.choiceByAmtSEM]')]],[0.8 0.8 0.8]);
    % p.EdgeColor = 'none';
    % plot(a.relValues,a.choiceByAmtMean,'Color','k','LineWidth',2,'Marker','o','MarkerFaceColor','k','MarkerSize',3);
    % bar(a.relValues,a.choiceByAmtMean,'FaceColor','k');
    % plot(a.relValues(~isnan(a.choiceByAmtProbMean(:,1))),a.choiceByAmtProbMean(~isnan(a.choiceByAmtProbMean(:,1)),1),'Color','m','LineWidth',1,'Marker','o','MarkerFaceColor','k','MarkerEdgeColor','k','MarkerSize',3);
    % plot(a.relValues(~isnan(a.choiceByAmtProbMean(:,2))),a.choiceByAmtProbMean(~isnan(a.choiceByAmtProbMean(:,2)),2),'Color','g','LineWidth',1,'Marker','o','MarkerFaceColor','k','MarkerEdgeColor','k','MarkerSize',3);
    % plot(a.relValues(~isnan(a.choiceByAmtProbMean(:,3))),a.choiceByAmtProbMean(~isnan(a.choiceByAmtProbMean(:,3)),3),'Color','b','LineWidth',1,'Marker','o','MarkerFaceColor','k','MarkerEdgeColor','k','MarkerSize',3);
    plot(a.relValues,a.prefByAmt(:,1),'Color','k','LineWidth',3,'Marker','o','MarkerFaceColor','k','MarkerEdgeColor','k','MarkerSize',3);
    plot(a.relValues,a.prefByAmtCI(:,1),'Color','k','LineWidth',1,'Marker','none');
    plot(a.relValues,a.prefByAmtCI(:,2),'Color','k','LineWidth',1,'Marker','none');
    % bar(2,a.overallPref,0.2,'FaceColor','r','EdgeColor','none');
    % errorbar(2,a.overallPref,a.overallPref - a.overallCI(1),a.overallCI(2) - a.overallPref,'CapSize',20,'LineStyle','none','LineWidth',2,'Color','k');

    % errorbar(a.relValues,a.choiceByAmtMean,a.choiceByAmtSEM,'Color','k','LineStyle','none','CapSize',10,'LineWidth',2);
    plot([-10000000 1000000],[0.5 0.5],'Color',grey,'yliminclude','off','xliminclude','off');
    hold off;

    saveas(fig,fullfile(pathname,'OverallValue'),'pdf');
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

%% CHOICE RANGE DATA (PRE-REVERSE) - NEED TO FIX FOR FEW CHOICES!

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
    for m = a.choiceMice(1):a.choiceMice(end)
       mouseChoiceData = a.choicebyMouse{m};
       numToPlotByMouse(m,1) = min(numToPlot,numel(mouseChoiceData));
       rxnData = a.choiceRxnByMouse{m};
       lickEarlyData = a.choiceEarlyLicksByMouse{m};
       lickAnticData = a.choiceAnticLicksByMouse{m};
       rewardData = a.choiceRewardByMouse{m};
       choiceToPlot{m,1} = mouseChoiceData(1:numToPlotByMouse(m));
       rxnToPlot{m,1} = rxnData(1:numToPlotByMouse(m));
       lickEarlyToPlot{m,1} = lickEarlyData(1:numToPlotByMouse(m));
       lickAnticToPlot{m,1} = lickAnticData(1:numToPlotByMouse(m));
       rewardToPlot{m,1} = rewardData(1:numToPlotByMouse(m));
    end

%     [sortedChoiceToPlot,sortIdx] = sortrows(choiceToPlot);
%     miceSortToPlot = (a.mouseList(sortIdx));
end
    %% CHOICE Pre-reverse RANGE DATA BY MOUSE (earlyJBXXX.pdf)

    % MAKE DYNAMIC re: trial nums, pre/post reverse

% if sum(a.currentChoiceMice>0)
%     for mm = 1:numel(a.currentChoiceMice)
%         m = a.currentChoiceMice(mm);
%         
% % if sum(a.choiceMice>0)
% %     for mm = 1:numel(a.choiceMice)
% %         m = a.choiceMice(mm);        
%         fig = figure();
% 
%         fig = gcf;
%         fig.PaperUnits = 'inches';
%         fig.PaperPosition = [0.5 0.5 7 10];
%         set(fig,'renderer','painters');
%         set(fig,'PaperOrientation','portrait');
% 
%         ax = nsubplot(5,1,1,1);
%         ax.FontSize = 12;
%         title(a.currentChoiceMiceList(mm));
%         ax.XLim = [1 numToPlotByMouse(m)];
%         ax.YLim = [0.5 1.5];
%         ax.XTickLabel = [];
%         ax.YTick = [];
%         ylabel('Choice');
%         imagesc('XData',(1:numToPlotByMouse(m)),'YData',(1),'CData',choiceToPlot{m,1}')
%         colormap(ax,map);
%         % colorbar('YTick',[0.25 0.75],'TickLabels',{'No Info','Info'},'FontSize',12,'TickLength',0,'Location','northoutside');
% 
%         ax = nsubplot(5,1,2,1);
%         ax.FontSize = 12;
%         ax.XLim = [1 numToPlotByMouse(m)];
%         ax.YLim = [0.5 1.5];
%         ax.XTickLabel = [];
%         ax.YTick = [];
%         ylabel('Reward');
%         imagesc('XData',(1:numToPlotByMouse(m)),'YData',(1),'CData',rewardToPlot{m,1}')
%         colormap(ax,[1 1 1; 0 0 0]);    
% 
%         ax = nsubplot(5,1,3,1);
%         ax.FontSize = 12;
%         ax.XLim = [1 numToPlotByMouse(m)];
%         ax.XTickLabel = [];
%         ylabel('Reaction Time');
%         rxnToPlotm = [];
%         rxnToPlotm = cell2mat(rxnToPlot(m,1));
%         scatter(find(choiceToPlot{m,1}==1),rxnToPlotm(choiceToPlot{m,1}==1),'filled','markerfacecolor',map(2,:));
%         scatter(find(choiceToPlot{m,1}==0),rxnToPlotm(choiceToPlot{m,1}==0),'filled','markerfacecolor',map(1,:));
% 
%         ax = nsubplot(5,1,4,1);
%         ax.FontSize = 12;
%         ax.XLim = [1 numToPlotByMouse(m)];
%         ax.XTickLabel = [];
%         ylabel('Early Licks');
%         lickEarlyToPlotm = [];
%         lickEarlyToPlotm = cell2mat(lickEarlyToPlot(m,1));
%         scatter(find(choiceToPlot{m,1}==1),lickEarlyToPlotm(choiceToPlot{m,1}==1),'filled','markerfacecolor',map(2,:));
%         scatter(find(choiceToPlot{m,1}==0),lickEarlyToPlotm(choiceToPlot{m,1}==0),'filled','markerfacecolor',map(1,:));
% 
%         ax = nsubplot(5,1,5,1);
%         ax.FontSize = 12;
%         ax.XLim = [1 numToPlotByMouse(m)];
%         ylabel('Anticipatory Licks');
%         lickAnticToPlotm = [];
%         lickAnticToPlotm = cell2mat(lickAnticToPlot(m,1));
%         scatter(find(choiceToPlot{m,1}==1),lickAnticToPlotm(choiceToPlot{m,1}==1),'filled','markerfacecolor',map(2,:));
%         scatter(find(choiceToPlot{m,1}==0),lickAnticToPlotm(choiceToPlot{m,1}==0),'filled','markerfacecolor',map(1,:));
%         xlabel('Choice Trial');
%         lgd = legend('Info','No Info');
%         lgd.FontSize = 16; lgd.Location = 'southoutside';
%         lgd.Orientation = 'horizontal'; lgd.Box = 'off';
%         % set(icons(:),'MarkerSize',20); %// Or whatever
%         % icons(1).Children.MarkerSize = 20;
% 
%         saveas(fig,fullfile(pathname,['early' a.mouseList{m}]),'pdf');
%         close(fig);
%     end
% end

    %% CHOICE pre-reverse RANGE HEATMAP (heatmap.pdf) - SKIPS

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

    %% CHOICE PREF REL IIS PRE- VS POST-REVERSAL FOR TRIALS TO COUNT (prevspost.pdf)

    if ~isempty(a.reverseMice)
        fig = figure();
        fig.PaperUnits = 'inches';
        fig.PaperPosition = [0.5 0.5 10 7];
        set(fig,'renderer','painters');
        set(fig,'PaperOrientation','landscape');

        ax = nsubplot(1,1,1,1);
        ax.FontSize = 8;
        ax.XLim = [0 1];
        ax.YLim = [0 1];
        for l = 1:numel(a.reverseMice)
            m = a.reverseMice(l);
            plot([a.pref(m,1) a.pref(m,1)],[a.prefRevCI(m,1) a.prefRevCI(m,2)],'color',[0.2 0.2 0.2],'linewidth',0.25);
            plot([a.prefCI(m,1) a.prefCI(m,2)],[a.pref(m,2) a.pref(m,2)],'color',[0.2 0.2 0.2],'linewidth',0.25);
            dy = a.prefRevCI(m,2) - a.pref(m,2) + 0.02;
            text(a.pref(m,1),a.pref(m,2) + dy,a.reverseMiceList{l},'HorizontalAlignment','center');
        end
        scatter(a.pref(:,1),a.pref(:,2),'filled')
        plot([-10000000 1000000],[0.5 0.5],'color',[0.2 0.2 0.2],'linewidth',0.25,'yliminclude','off','xliminclude','off');
        plot([0.5 0.5],[-10000000 1000000],'color',[0.2 0.2 0.2],'linewidth',0.25,'yliminclude','off','xliminclude','off');
        text(numel(a.reverseMice)+2,a.overallPref,['p = ' num2str(a.overallP)])
    %     patch([0.5 1 1 0.5],[0 0 0.5 0.5],[0.3 0.3 0.3],'FaceAlpha',0.1,'EdgeColor','none');
        ylabel({'% choice of initially informative side', 'POST-reversal'}); %{'Info choice', 'probability'}
        xlabel({'% choice of initially informative side', 'PRE-reversal'});
        title('Raw choice percentages, pre vs post-reversal');
        hold off;

        saveas(fig,fullfile(pathname,'PrevsPostIIS'),'pdf');
    %     close(fig);
end
    
%% PERCENT INFO CHOICE BY SIDE

if ~isempty(a.reverseMice)
    fig = figure();
    fig.PaperUnits = 'inches';
    fig.PaperPosition = [0.5 0.5 10 7];
    set(fig,'renderer','painters');
    set(fig,'PaperOrientation','landscape');

    ax = nsubplot(1,1,1,1);
    ax.FontSize = 8;
    ax.XLim = [0 1];
    ax.YLim = [0 1];
    for l = 1:numel(a.reverseMice)
        m = a.reverseMice(l);
        text(a.overallChoice(m,1),a.overallChoice(m,2) + 0.02,a.reverseMiceList{l},'HorizontalAlignment','center');
    end
    scatter(a.overallChoice(:,1),a.overallChoice(:,2),'filled')
    plot([-10000000 1000000],[0.5 0.5],'color',[0.2 0.2 0.2],'linewidth',0.25,'yliminclude','off','xliminclude','off');
    plot([0.5 0.5],[-10000000 1000000],'color',[0.2 0.2 0.2],'linewidth',0.25,'yliminclude','off','xliminclude','off');
    plot([0 1],[0 1],'color',[0.2 0.2 0.2],'linewidth',0.25,'yliminclude','off','xliminclude','off');
    plot([0 1],[1 0],'color',[0.2 0.2 0.2],'linewidth',0.25,'yliminclude','off','xliminclude','off');
    ylabel({'P(choose info | Info side = 1)'}); %{'Info choice', 'probability'}
    xlabel({'P(choose info | Info side = 0)'});
    title('Raw choice percentages, by physical info side');
    hold off;

    saveas(fig,fullfile(pathname,'Prefbyside'),'pdf');
%     close(fig);
end

    if ~isempty(a.reverseMice)
    fig = figure();
    fig.PaperUnits = 'inches';
    fig.PaperPosition = [0.5 0.5 10 7];
    set(fig,'renderer','painters');
    set(fig,'PaperOrientation','landscape');

    ax = nsubplot(1,1,1,1);
    ax.FontSize = 8;
    ax.XLim = [0 1];
    ax.YLim = [0 1];
    for l = 1:numel(a.reverseMice)
        m = a.reverseMice(l);
        text(a.overallChoice(m,3),a.overallChoice(m,4) + 0.02,a.reverseMiceList{l},'HorizontalAlignment','center');
    end
    scatter(a.overallChoice(:,3),a.overallChoice(:,4),'filled')
    plot([-10000000 1000000],[0.5 0.5],'color',[0.2 0.2 0.2],'linewidth',0.25,'yliminclude','off','xliminclude','off');
    plot([0.5 0.5],[-10000000 1000000],'color',[0.2 0.2 0.2],'linewidth',0.25,'yliminclude','off','xliminclude','off');
    plot([0 1],[0 1],'color',[0.2 0.2 0.2],'linewidth',0.25,'yliminclude','off','xliminclude','off');
    plot([0 1],[1 0],'color',[0.2 0.2 0.2],'linewidth',0.25,'yliminclude','off','xliminclude','off');
    ylabel({'P(choose info | Info side = initially non-informative)'}); %{'Info choice', 'probability'}
    xlabel({'P(choose info | Info side = initially informative)'});
    title('Raw choice percentages, by info side');
    hold off;

    saveas(fig,fullfile(pathname,'Prefbyinitside'),'pdf');
%     close(fig);
    end


%% PREFERENCE VS LEAVING

if ~isempty(a.reverseMice)
fig = figure();
fig.PaperUnits = 'inches';
fig.PaperPosition = [0.5 0.5 10 7];
set(fig,'renderer','painters');
set(fig,'PaperOrientation','landscape');

ax = nsubplot(1,1,1,1);
ax.FontSize = 8;
% ax.XLim = [0 1];
ax.YLim = [0 1];
for mm = 1:numel(a.reverseMice)
    m = a.reverseMice(mm);
    text(a.incomplete(m,6),a.overallChoice(m,5) + 0.01,a.reverseMiceList{mm},'HorizontalAlignment','center');
end
scatter(a.incomplete(a.reverseMice,6),a.overallChoice(a.reverseMice,5),'filled')
plot([-10000000 1000000],[0.5 0.5],'color',[0.2 0.2 0.2],'linewidth',0.25,'yliminclude','off','xliminclude','off');
plot([0.5 0.5],[-10000000 1000000],'color',[0.2 0.2 0.2],'linewidth',0.25,'yliminclude','off','xliminclude','off');
% plot([0 1],[0 1],'color',[0.2 0.2 0.2],'linewidth',0.25,'yliminclude','off','xliminclude','off');
% plot([0 1],[1 0],'color',[0.2 0.2 0.2],'linewidth',0.25,'yliminclude','off','xliminclude','off');
ylabel({'P(choose info)'}); %{'Info choice', 'probability'}
xlabel({'P(NOT present in port on info small)'});
title('Overall mean choice of information vs. probability of leaving on low-value info trials');
hold off;

saveas(fig,fullfile(pathname,'Prefbyleaving'),'pdf');
%     close(fig);
end


%% PREFERENCE VS LEAVING DIFFERENCE
if ~isempty(a.reverseMice)
fig = figure();
fig.PaperUnits = 'inches';
fig.PaperPosition = [0.5 0.5 10 7];
set(fig,'renderer','painters');
set(fig,'PaperOrientation','landscape');

ax = nsubplot(1,1,1,1);
ax.FontSize = 8;
% ax.XLim = [0 1];
ax.YLim = [0 1];
for mm = 1:numel(a.reverseMice)
    m = a.reverseMice(mm);
    text(a.incompleteDifference(m)*100,a.overallChoice(m,5) + 0.01,a.reverseMiceList{mm},'HorizontalAlignment','center');
end
scatter(a.incompleteDifference(a.reverseMice)*100,a.overallChoice(a.reverseMice,5),'filled')
plot([-10000000 1000000],[0.5 0.5],'color',[0.2 0.2 0.2],'linewidth',0.25,'yliminclude','off','xliminclude','off');
% plot([0.5 0.5],[-10000000 1000000],'color',[0.2 0.2 0.2],'linewidth',0.25,'yliminclude','off','xliminclude','off');
% plot([0 1],[0 1],'color',[0.2 0.2 0.2],'linewidth',0.25,'yliminclude','off','xliminclude','off');
% plot([0 1],[1 0],'color',[0.2 0.2 0.2],'linewidth',0.25,'yliminclude','off','xliminclude','off');
ylabel({'P(choose info)'}); %{'Info choice', 'probability'}
xlabel({'Difference in % trials not in port at outcome, info - no info'});
title('Overall mean choice of information vs. probability of leaving');
hold off;

saveas(fig,fullfile(pathname,'Prefbyleavingdifference'),'pdf');
%     close(fig);
end

%% leaving vs reward rate
fig = figure();
fig.PaperUnits = 'inches';
fig.PaperPosition = [0.5 0.5 10 7];
set(fig,'renderer','painters');
set(fig,'PaperOrientation','landscape');

ax = nsubplot(1,1,1,1);
ax.FontSize = 8;
% ax.XLim = [0 1];
% ax.YLim = [0 1];
for mm = 1:numel(a.reverseMice)
    m = a.reverseMice(mm);
    text(a.incompleteDifference(m)*100,a.rewardDiff(m,1)+ 0.01,a.reverseMiceList{mm},'HorizontalAlignment','center');
end
scatter(a.incompleteDifference(a.reverseMice)*100,a.rewardDiff(:,1),'filled')
plot([-10000000 1000000],[0 0],'color',[0.2 0.2 0.2],'linewidth',0.25,'yliminclude','off','xliminclude','off');
plot([0 0],[-10000000 1000000],'color',[0.2 0.2 0.2],'linewidth',0.25,'yliminclude','off','xliminclude','off');
% plot([0 1],[0 1],'color',[0.2 0.2 0.2],'linewidth',0.25,'yliminclude','off','xliminclude','off');
% plot([0 1],[1 0],'color',[0.2 0.2 0.2],'linewidth',0.25,'yliminclude','off','xliminclude','off');
ylabel({'Info reward rate - no info reward rate (uL per minute)'}); %{'Info choice', 'probability'}
xlabel({'Difference in % trials not in port at outcome, info - no info'});
title('Trials not in port vs. reward rate difference');
hold off;

saveas(fig,fullfile(pathname,'Rewardbynotpresent'),'pdf');
%     close(fig);


%% initial pref vs initial leaving
if ~isempty(a.reverseMice)
fig = figure();
fig.PaperUnits = 'inches';
fig.PaperPosition = [0.5 0.5 10 7];
set(fig,'renderer','painters');
set(fig,'PaperOrientation','landscape');

ax = nsubplot(1,1,1,1);
ax.FontSize = 8;
% ax.XLim = [0 1];
ax.YLim = [0 1];
for mm = 1:numel(a.choiceMice)
    m = a.choiceMice(mm);
    text(a.initialIncomplete(m,1),a.pref(m,1) + 0.01,a.choiceMiceList{mm},'HorizontalAlignment','center');
end
scatter(a.initialIncomplete(a.choiceMice,1),a.pref(a.choiceMice,1),'filled')
plot([-10000000 1000000],[0.5 0.5],'color',[0.2 0.2 0.2],'linewidth',0.25,'yliminclude','off','xliminclude','off');
plot([0.5 0.5],[-10000000 1000000],'color',[0.2 0.2 0.2],'linewidth',0.25,'yliminclude','off','xliminclude','off');
% plot([0 1],[0 1],'color',[0.2 0.2 0.2],'linewidth',0.25,'yliminclude','off','xliminclude','off');
% plot([0 1],[1 0],'color',[0.2 0.2 0.2],'linewidth',0.25,'yliminclude','off','xliminclude','off');
ylabel({'P(choose info)'}); %{'Info choice', 'probability'}
xlabel({'P(NOT present in port on info small)'});
title('Initial choice of information vs. probability of leaving on low-value info trials');
hold off;

saveas(fig,fullfile(pathname,'InitPrefbyleaving'),'pdf');
%     close(fig);
end


%% PREFERENCE VS REACTION DIFFERENCE
if ~isempty(a.reverseMice)
fig = figure();
fig.PaperUnits = 'inches';
fig.PaperPosition = [0.5 0.5 10 7];
set(fig,'renderer','painters');
set(fig,'PaperOrientation','landscape');

ax = nsubplot(1,1,1,1);
ax.FontSize = 8;
% ax.XLim = [0 1];
ax.YLim = [0 1];
for mm = 1:numel(a.reverseMice)
    m = a.reverseMice(mm);
    text(a.rxnDiff(m),a.overallChoice(m,5) + 0.01,a.reverseMiceList{mm},'HorizontalAlignment','center');
end
scatter(a.rxnDiff(a.reverseMice),a.overallChoice(a.reverseMice,5),'filled')
plot([-10000000 1000000],[0.5 0.5],'color',[0.2 0.2 0.2],'linewidth',0.25,'yliminclude','off','xliminclude','off');
plot([0.5 0.5],[-10000000 1000000],'color',[0.2 0.2 0.2],'linewidth',0.25,'yliminclude','off','xliminclude','off');
% plot([0 1],[0 1],'color',[0.2 0.2 0.2],'linewidth',0.25,'yliminclude','off','xliminclude','off');
% plot([0 1],[1 0],'color',[0.2 0.2 0.2],'linewidth',0.25,'yliminclude','off','xliminclude','off');
ylabel({'P(choose info)'}); %{'Info choice', 'probability'}
xlabel({'Difference in forced trial reaction time, info - no info'});
title('Overall mean choice of information vs. forced trial reaction time');
hold off;

saveas(fig,fullfile(pathname,'PrefbyRTdifference'),'pdf');
%     close(fig);
end

%% initial pref vs days of training
if ~isempty(a.reverseMice)
fig = figure();
fig.PaperUnits = 'inches';
fig.PaperPosition = [0.5 0.5 10 7];
set(fig,'renderer','painters');
set(fig,'PaperOrientation','landscape');

reverseDays = cell2mat(a.reverseDay(:,1));
reverseDays = reverseDays(reverseDays>0);
imagingReverseDays = cell2mat(a.reverseDay(:,1));
imagingReverseDays = imagingReverseDays(a.imagingMice==1);

ax = nsubplot(1,1,1,1);
ax.FontSize = 8;
% ax.XLim = [0 1];
ax.YLim = [0 1];
for mm = 1:numel(a.reverseMice)
    m = a.reverseMice(mm);
    text(a.reverseDay{m,1},a.pref(m,1) + 0.01,a.reverseMiceList{mm},'HorizontalAlignment','center');
end
scatter(reverseDays,a.pref(a.reverseMice,1),'filled');
scatter(imagingReverseDays,a.pref(find(a.imagingMice),1),'filled','MarkerFaceColor','r');
plot([-10000000 1000000],[0.5 0.5],'color',[0.2 0.2 0.2],'linewidth',0.25,'yliminclude','off','xliminclude','off');
plot([0.5 0.5],[-10000000 1000000],'color',[0.2 0.2 0.2],'linewidth',0.25,'yliminclude','off','xliminclude','off');
plot([0 1],[0 1],'color',[0.2 0.2 0.2],'linewidth',0.25,'yliminclude','off','xliminclude','off');
plot([0 1],[1 0],'color',[0.2 0.2 0.2],'linewidth',0.25,'yliminclude','off','xliminclude','off');
ylabel({'P(choose info)'}); %{'Info choice', 'probability'}
xlabel({'Days of training'});
title('Initial choice of information vs. length of training');
hold off;

saveas(fig,fullfile(pathname,'InitPrefbytraining'),'pdf');
%     close(fig);
end

%% initial pref vs initial rxn
if ~isempty(a.reverseMice)
fig = figure();
fig.PaperUnits = 'inches';
fig.PaperPosition = [0.5 0.5 10 7];
set(fig,'renderer','painters');
set(fig,'PaperOrientation','landscape');

ax = nsubplot(1,1,1,1);
ax.FontSize = 8;
% ax.XLim = [0 1];
ax.YLim = [0 1];
for mm = 1:numel(a.reverseMice)
    m = a.reverseMice(mm);
    text(a.reversalRxn(mm,1),a.pref(m,1) + 0.01,a.reverseMiceList{mm},'HorizontalAlignment','center');
end
scatter(a.reversalRxn(:,1),a.pref(a.reverseMice,1),'filled');
% scatter(imagingReverseDays,a.pref(find(a.imagingMice),1),'filled','MarkerFaceColor','r');
plot([-10000000 1000000],[0.5 0.5],'color',[0.2 0.2 0.2],'linewidth',0.25,'yliminclude','off','xliminclude','off');
plot([0.5 0.5],[-10000000 1000000],'color',[0.2 0.2 0.2],'linewidth',0.25,'yliminclude','off','xliminclude','off');
% plot([0 1],[0 1],'color',[0.2 0.2 0.2],'linewidth',0.25,'yliminclude','off','xliminclude','off');
% plot([0 1],[1 0],'color',[0.2 0.2 0.2],'linewidth',0.25,'yliminclude','off','xliminclude','off');
ylabel({'P(choose info)'}); %{'Info choice', 'probability'}
xlabel({'Reaction speed index: 1 = faster info reaction speed'});
title('Initial choice of information vs. faster info reaction');
hold off;

saveas(fig,fullfile(pathname,'InitPrefbyrxn'),'pdf');
%     close(fig);
end

%% initial pref vs initial licking
if ~isempty(a.reverseMice)
fig = figure();
fig.PaperUnits = 'inches';
fig.PaperPosition = [0.5 0.5 10 7];
set(fig,'renderer','painters');
set(fig,'PaperOrientation','landscape');

ax = nsubplot(1,1,1,1);
ax.FontSize = 8;
% ax.XLim = [0 1];
ax.YLim = [0 1];
for mm = 1:numel(a.reverseMice)
    m = a.reverseMice(mm);
    text(a.reversalLickDiff(mm,1),a.pref(m,1) + 0.01,a.reverseMiceList{mm},'HorizontalAlignment','center');
end
scatter(a.reversalLickDiff(:,1),a.pref(a.reverseMice,1),'filled');
% scatter(imagingReverseDays,a.pref(find(a.imagingMice),1),'filled','MarkerFaceColor','r');
plot([-10000000 1000000],[0.5 0.5],'color',[0.2 0.2 0.2],'linewidth',0.25,'yliminclude','off','xliminclude','off');
plot([0.5 0.5],[-10000000 1000000],'color',[0.2 0.2 0.2],'linewidth',0.25,'yliminclude','off','xliminclude','off');
% plot([0 1],[0 1],'color',[0.2 0.2 0.2],'linewidth',0.25,'yliminclude','off','xliminclude','off');
% plot([0 1],[1 0],'color',[0.2 0.2 0.2],'linewidth',0.25,'yliminclude','off','xliminclude','off');
ylabel({'P(choose info)'}); %{'Info choice', 'probability'}
xlabel({'Info - No Info anticipatory licks'});
title('Initial choice of information vs. anticipatory licking');
hold off;

saveas(fig,fullfile(pathname,'InitPrefbylicking'),'pdf');
%     close(fig);
end

%% MEAN PREFERENCE (INDEX)

if ~isempty(a.reverseMice)
    fig = figure();
    fig.PaperUnits = 'inches';
    fig.PaperPosition = [0.5 0.5 10 7];
    set(fig,'renderer','painters');
    set(fig,'PaperOrientation','landscape');

    ax = nsubplot(1,1,1,1);
    ax.FontSize = 6;
%     ax.YLim = [-0.2 0.2];
    ax.YLim = [-0.4 0.4];
    
    micetoplot = unique([a.reverseMice;find(a.imagingMice)]);
    imagemice = find(a.imagingMice);
    choicetoplot = a.overallChoice;
    choicetoplot(isnan(choicetoplot))=0.5;
    [sharedvals,idx] = intersect(micetoplot,imagemice);
    bar(choicetoplot(micetoplot,5)-0.5,'FaceColor',grey);
    imagingchoice = choicetoplot(sharedvals,5)-0.5;
    bar(idx,imagingchoice,'FaceColor','r');
    bar(numel(micetoplot)+1,nanmean(a.overallChoice(micetoplot,5))-0.5,'FaceColor','k');
    xticks(1:numel(micetoplot)+1);
    xticklabels([a.mouseList(micetoplot); 'Mean']);
    xlim([0.5 numel(micetoplot)+1.5]);
    ylabel('Mean choice of info side across reversals');
    yticks([-.2 -.1 0 .1 .2]);
    yticklabels({'30%','40%','50%','60%','70%'});
    text(numel(micetoplot)+1,nanmean(a.overallChoice(micetoplot,5))-0.45,['Mean = ' num2str(round(nanmean(a.overallChoice(micetoplot,5)),4))],'HorizontalAlignment','center');
    text(numel(micetoplot)+1,nanmean(a.overallChoice(micetoplot,5))-0.46,['p = ' num2str(round(a.overallChoiceP,4))],'HorizontalAlignment','center');
    

    saveas(fig,fullfile(pathname,'OverallIndex'),'pdf');
end


%% MEAN PREFERENCE (INDEX) NO IMAGING, only big/small mice

if ~isempty(a.reverseMice)
    fig = figure();
    fig.PaperUnits = 'inches';
    fig.PaperPosition = [0.5 0.5 10 7];
    set(fig,'renderer','painters');
    set(fig,'PaperOrientation','landscape');

    ax = nsubplot(1,1,1,1);
    ax.FontSize = 6;
%     ax.YLim = [-0.2 0.2];
    ax.YLim = [-0.4 0.4];
    
%     micetoplot = a.reverseMice;
    imagemice = find(a.imagingMice);
    micetoplot = a.reverseMice(~ismember(a.reverseMice,imagemice));
    noneMice = find(a.noneMice);
    noneMice = 0;
    micetoplot = micetoplot(~ismember(micetoplot,noneMice));
    choicetoplot = a.overallChoice;
    choicetoplot(isnan(choicetoplot))=0.5;
    bar(choicetoplot(micetoplot,5)-0.5,'FaceColor',grey);
    bar(numel(micetoplot)+1,nanmean(a.overallChoice(micetoplot,5))-0.5,'FaceColor','k');
    xticks(1:numel(micetoplot)+1);
    xticklabels([a.mouseList(micetoplot); 'Mean']);
    xlim([0.5 numel(micetoplot)+1.5]);
    ylabel('Mean choice of info side across reversals for all non-imaging mice');
    yticks([-.2 -.1 0 .1 .2]);
    yticklabels({'30%','40%','50%','60%','70%'});
    text(numel(micetoplot)+1,nanmean(a.overallChoice(micetoplot,5))-0.45,['Mean = ' num2str(round(nanmean(a.overallChoice(micetoplot,5)),4))],'HorizontalAlignment','center');
    overallChoicePercent = a.overallChoice(micetoplot,5)*100;
    overallChoiceP = signrank(overallChoicePercent-50);    
    text(numel(micetoplot)+1,nanmean(a.overallChoice(micetoplot,5))-0.46,['p = ' num2str(round(overallChoiceP,4))],'HorizontalAlignment','center');
    

    saveas(fig,fullfile(pathname,'OverallIndexNoImage'),'pdf');
    
    fig = figure();
    fig.PaperUnits = 'inches';
    fig.PaperPosition = [0.5 0.5 10 7];
    set(fig,'renderer','painters');
    set(fig,'PaperOrientation','landscape');

    ax = nsubplot(1,1,1,1);
    ax.FontSize = 8;
%     ax.YLim = [-0.2 0.2];
    ax.YLim = [0 1];
    
%     micetoplot = a.reverseMice;
    imagemice = find(a.imagingMice);
    micetoplot = a.reverseMice(~ismember(a.reverseMice,imagemice));
    noneMice = find(a.noneMice);
    noneMice = 0;
    micetoplot = micetoplot(~ismember(micetoplot,noneMice));
    choicetoplot = a.overallChoice(micetoplot,5);
%     choicetoplot(isnan(choicetoplot(:,5)),5)=0;
    [sortChoice,idx] = sort(choicetoplot);
    bar(sortChoice,'FaceColor',grey);
    bar(numel(micetoplot)+1,nanmean(a.overallChoice(micetoplot,5)),'FaceColor','k');
    xticks(1:numel(micetoplot)+1);
    mouselist = a.mouseList(micetoplot);
    xticklabels([mouselist(idx); 'Mean']);
    xlim([0.5 numel(micetoplot)+1.5]);
    ylabel('Mean choice of info side across reversals for all non-imaging mice');
%     yticks([-.2 -.1 0 .1 .2]);
%     yticklabels({'30%','40%','50%','60%','70%'});
    text(numel(micetoplot)+1,nanmean(a.overallChoice(micetoplot,5))+0.05,['Mean = ' num2str(round(nanmean(a.overallChoice(micetoplot,5)),4))],'HorizontalAlignment','center');
    overallChoicePercent = a.overallChoice(micetoplot,5)*100;
    overallChoiceP = signrank(overallChoicePercent-50);    
    text(numel(micetoplot)+1,nanmean(a.overallChoice(micetoplot,5))+0.04,['p = ' num2str(round(overallChoiceP,4))],'HorizontalAlignment','center');
    

    saveas(fig,fullfile(pathname,'OverallIndexNoImageSort'),'pdf');    
end


%% MOVING AVERAGE

if ~isempty(a.reverseMice)
    for mm = 1:numel(a.reverseMice)
        m = a.reverseMice(mm);
        
%         if ismember(m,a.currentMiceNums)
        
            ok = a.mice(:,m) == 1 & a.choiceTypeCorr == 1 & a.fileTrialTypes == 5;
            okidx = find(ok);
            [~,sortidx] = sort(a.mouseDay(ok==1));
            oksorted = okidx(sortidx);
            % that mouse's choice trials
            choicesIIS = a.choiceIISByMouse{m}; % includes choice training??
            choicesIIS = choicesIIS(sortidx);
            choices = a.choiceAllbyMouse{m};
            choices = choices(sortidx);
            reverses = a.reverseByMouse{m};
            reverses = reverses(sortidx);
            reversePts = find(diff(reverses));        

%             fig = figure();
%             fig.PaperUnits = 'inches';
%             fig.PaperPosition = [0.5 0.5 10 7];
%             set(fig,'renderer','painters');
%             set(fig,'PaperOrientation','landscape');
% 
%             ax = nsubplot(1,1,1,1);
%             ax.FontSize = 8;
%             ax.YLim = [0 1];
%             title(a.mouseList(m));        
% 
%             toPlot = movmean(choicesIIS,20);
%             hold on;
%             plot([-10000 10000],[0.5 0.5],'xliminclude','off','Color',grey,'linewidth',2);
%             for i = 1:numel(reversePts)
%                plot([reversePts(i) reversePts(i)],[0 1],'Color','k','linewidth',2); 
%             end
%             plot(toPlot,'Color','r','linewidth',2);
%             ylabel('Preference for original INFO side, 20-trial avg');
%             xlabel('Trial');
% 
%             saveas(fig,fullfile(pathname,['movingavgIIS' a.mouseList{m}]),'pdf');

            fig = figure();
            fig.PaperUnits = 'inches';
            fig.PaperPosition = [0.5 0.5 10 7];
            set(fig,'renderer','painters');
            set(fig,'PaperOrientation','landscape');

            ax = nsubplot(1,1,1,1);
            ax.FontSize = 8;
            ax.YLim = [0 1];
            title(a.mouseList(m));        

            toPlot = movmean(choices,20);
            hold on;
            plot([-10000 10000],[0.5 0.5],'xliminclude','off','Color',grey,'linewidth',2);
            for i = 1:numel(reversePts)
               plot([reversePts(i) reversePts(i)],[0 1],'Color','k','linewidth',2); 
            end
            plot(toPlot,'Color','b','linewidth',2);
            ylabel('Preference for current INFO side, 20-trial avg');
            xlabel('Trial');

            saveas(fig,fullfile(pathname,['movingavg' a.mouseList{m}]),'pdf');
%         end
        
    end
end

%% ALL CHOICES BY DAY

% choiceColorMap = [ orange; purple; grey; 0.9490, 0.8, 1.0; 1, 0.8, 0.0];
% typeColorMap = [1 1 0; purple; orange];
cmap = [orange; purple; grey; 1, 0.8, 0.0; 0.9490, 0.8, 1.0;1 1 0; purple; orange];
clabel = {'NoInfo','Info','NoChoice','NoInfoWRONG','InfoWRONG','Choice','Info','NoInfo'};

for m = 1:a.mouseCt
    if ismember(m,a.choiceMice)
        days = a.mouseChoiceDays{m};
        dayCount = numel(days);    
        fig = figure();
        fig.PaperUnits = 'inches';
        fig.PaperPosition = [0.5 0.5 7 10];
        set(fig,'renderer','painters');
        set(fig,'PaperOrientation','portrait');    
             
        for dd = 1:dayCount
            d = days(dd);
            choices = [a.daySummary.wentInfo{m,d}' 0:7];
            ok = a.miceAll(:,m)==1 & a.mouseDayAll == d;
            choiceTypes = a.choiceType(ok)';
            choiceTypes=[choiceTypes+4 0:7];
%             choices = [a.choice(ok,4)' 0:7];
           
            ax1 = nsubplot(dayCount*2,1,dd*2-1,1);
            ax1.FontSize = 8;
            ax1.YLim = [0 1];
            imagesc(ax1,choiceTypes);colormap(ax1,cmap);
            ylabel({[a.mouseDays{m}{d} ' ' num2str(d)], 'Type'});
            axis tight;
            ax1.XLim = [1 numel(choiceTypes)-8];
            set(gca,'ytick',[]);
            set(gca,'yticklabel',[]); 
            
            ax2 = nsubplot(dayCount*2,1,dd*2,1);
            ax2.FontSize = 8;
            ax2.YLim = [0 1];
            
            imagesc(ax2,choices);colormap(ax2,cmap);
            ylabel('Choice');
            axis tight;
            ax2.XLim = [1 numel(choices)-8];
            
            set(gca,'ytick',[]);
            set(gca,'yticklabel',[]);           
        end
        ha = axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0  1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
        h_for_legend=[];
        hold on;
        for i = 1:7
            h_for_legend(end+1) = plot(ha,0,0, 'color',cmap(i,:),'linewidth',2);
        end
        hold off;
            
        leg = legend(h_for_legend,clabel,'Location','south','Orientation','horizontal');
        legend('boxoff');
        text(0.51,0.98,[a.mouseList{m} ' Choice of Side'],'FontSize',14,'FontWeight','bold','HorizontalAlignment','center');        
    end
    saveas(fig,fullfile(pathname,[a.mouseList{m},'_FullChoices']),'pdf');
end

%% TRIAL TYPES BY DAY
% 
% choiceColorMap = [1 1 0; purple; orange];
% 
% for m = 1:a.mouseCt
%     if ismember(m,a.currentChoiceMice)
%         days = a.mouseChoiceDays{m};
%         dayCount = numel(days);  
%         fig = figure();
%         fig.PaperUnits = 'inches';
%         fig.PaperPosition = [0.5 0.5 10 7];
%         set(fig,'renderer','painters');
%         set(fig,'PaperOrientation','landscape');    
%              
%         for dd = 1: dayCount
%             d = days(dd);    
%             
%             ok = a.miceAll(:,m)==1 & a.mouseDayAll == d;
%             
%             ax = nsubplot(dayCount,1,dd,1);
%             ax.FontSize = 8;
%             ax.YLim = [0 1];
%                         
%             choices = [a.choiceType(ok)' 1:3];
%             
%             imagesc(choices);colormap(choiceColorMap);
%             ylabel([a.mouseDays{m}{d} ' ' num2str(d)]);
%             axis tight;
%             set(gca,'ytick',[]);
%             set(gca,'yticklabel',[]);            
%         end
%         ha = axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0  1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
%         text(0.51,0.98,[a.mouseList{m} ' Trial Type'],'FontSize',14,'FontWeight','bold','HorizontalAlignment','center');        
%     end
% end


%% LOGISTIC REGRESSION ON TRIALS TO COUNT (regression.pdf) 

if ~isempty(a.reverseMice)
    fig = figure();
    fig.PaperUnits = 'inches';
    fig.PaperPosition = [0.5 0.5 10 7];
    set(fig,'renderer','painters');
    set(fig,'PaperOrientation','landscape');

    ax = nsubplot(1,1,1,1);
    ax.FontSize = 8;
    ax.XLim = [-3 3];
    ax.YLim = [-3 3];
    for mm = 1:numel(a.reverseMice)
        m = a.reverseMice(mm);
        plot([a.beta(m,1) a.beta(m,1)],[a.beta(m,2) - a.betaSE(m,2) a.beta(m,2) + a.betaSE(m,2)],'color',[0.2 0.2 0.2],'linewidth',0.25);
        plot([a.beta(m,1)-a.betaSE(m,1) a.beta(m,1)+a.betaSE(m,1)],[a.beta(m,2) a.beta(m,2)],'color',[0.2 0.2 0.2],'linewidth',0.25);
%         dy = a.beta(m,2) - a.betaCI(m,2) + 0.02;
        text(a.beta(m,1),a.beta(m,2) + 0.1,a.reverseMiceList{mm},'HorizontalAlignment','center');
    end
    scatter(a.beta(:,1),a.beta(:,2),'filled','FaceColor','k')
    plot([-10000000 1000000],[0 0],'color',[0.2 0.2 0.2],'linewidth',0.25,'yliminclude','off','xliminclude','off');
    plot([0 0],[-10000000 1000000],'color',[0.2 0.2 0.2],'linewidth',0.25,'yliminclude','off','xliminclude','off');
    ylabel({'Info preference', '(log odds biasing to currently informative side'}); %{'Info choice', 'probability'}
    xlabel({'Side bias', '(log odds biasing to initially informative side)'});
    title('Logistic Regression Analysis');
    hold off;

    saveas(fig,fullfile(pathname,'Regression'),'pdf');
%     close(fig);
end

    %% EARLY LICKS REGRESSION
if ~isempty(a.reverseMice)
    bothSig = a.preRevEarlyLicks(:,3)<0.05 & a.postRevEarlyLicks(:,3)<0.05;

    for m = 1:a.mouseCt
        if bothSig(m) == 1
            if a.preRevEarlyLicks(m,1)>a.preRevEarlyLicks(m,2)
                if a.postRevEarlyLicks(m,1)>a.preRevEarlyLicks(m,2)
                    sig(m) = 2;
                else
                    sig(m) = 3;
                end
            else if a.preRevEarlyLicks(m,1)<a.preRevEarlyLicks(m,2)
                    if a.postRevEarlyLicks(m,1)<a.postRevEarlyLicks(m,2)
                        sig(m) = 1;
                    else
                        sig(m) = 3;
                    end
                end
            end
        else sig(m) = 4;
        end
    end
    
    reverseSig = sig(a.reverseMice);
    a.earlyLickIdxRev = a.earlyLickIdx(a.reverseMice,:);

    
    fig = figure();
    fig.PaperUnits = 'inches';
    fig.PaperPosition = [0.5 0.5 10 7];
    set(fig,'renderer','painters');
    set(fig,'PaperOrientation','landscape');

    ax = nsubplot(1,1,1,1);
    ax.FontSize = 8;
    ax.XLim = [-1 1];
    ax.YLim = [-1 1];
    for l = 1:numel(a.reverseMice)
        m = a.reverseMice(l);
        dy = 0.02;
        text(a.earlyLickIdx(m,1),a.earlyLickIdx(m,2) + dy,a.reverseMiceList{l},'HorizontalAlignment','center');
    end
    plot([-10000000 1000000],[0 0],'color',[0.2 0.2 0.2],'linewidth',0.25,'yliminclude','off','xliminclude','off');
    plot([0 0],[-10000000 1000000],'color',[0.2 0.2 0.2],'linewidth',0.25,'yliminclude','off','xliminclude','off');
    scatter(a.earlyLickIdxRev(reverseSig==1,1),a.earlyLickIdxRev(reverseSig==1,2),'filled','MarkerEdgeColor','none','MarkerFaceColor',orange);
    scatter(a.earlyLickIdxRev(reverseSig==2,1),a.earlyLickIdxRev(reverseSig==2,2),'filled','MarkerEdgeColor','none','MarkerFaceColor',purple);
    scatter(a.earlyLickIdxRev(reverseSig==3,1),a.earlyLickIdxRev(reverseSig==3,2),'filled','MarkerEdgeColor','none','MarkerFaceColor','k');
    scatter(a.earlyLickIdxRev(reverseSig==4,1),a.earlyLickIdxRev(reverseSig==4,2),'filled','MarkerEdgeColor','none','MarkerFaceColor',[.8 .8 .8]);
    ylabel('POST-reversal (info side vs other side)');
    xlabel('PRE-reversal (info side vs other side)');
    title({'Pre-odor2 lick indices, pre vs post-reversal', '(-1 = lick more for no info side)'});
    hold off;

    saveas(fig,fullfile(pathname,'PrevsPostEarlyLicks'),'pdf');
% %     close(fig);


    %%  EARLY LICK BAR GRAPHS 
    
    % sort order
%     preSig = a.preRevEarlyLicks(:,3)<0.05;
%     preDiff = a.preRevEarlyLicks(:,2)-a.preRevEarlyLicks(:,1);
%     postSig = a.postRevEarlyLicks(:,3)<0.05;
%     postDiff = a.postRevEarlyLicks(:,2)-a.postRevEarlyLicks(:,1);
%     
%     sorts = [preSig preDiff postSig postDiff];
%     sorts2 = [preDiff postDiff];
%     
%     [sortsSorted,earlyLickSortIdx] = sortrows(sorts2);
%     
%     
%     fig = figure();
%     fig.PaperUnits = 'inches';
%     fig.PaperPosition = [0.5 0.5 10 7];
%     set(fig,'renderer','painters');
%     set(fig,'PaperOrientation','landscape');
%     
%     for m = 1:a.mouseCt
%         earlyLickSortVal = earlyLickSortIdx(m);
%         ax = subplot(a.mouseCt/4,a.mouseCt/8,earlyLickSortVal);
%         if ~isnan(a.postRevEarlyLicks(m,1))
%             bar(1:4,[a.preRevEarlyLicks(m,2),a.preRevEarlyLicks(m,1),a.postRevEarlyLicks(m,2),a.postRevEarlyLicks(m,1)]);
%         else
%             bar(1:4,[a.preRevEarlyLicks(m,2),a.preRevEarlyLicks(m,1),0,0]);
%         end
%     end

%     [a.sortedEarlyLickIdx,a.earlyLickSortIdx] = sortrows(a.earlyLickIdx(a.reverseMice),1);
%     a.completeSig = a.preRevEarlyLicks(a.reverseMice,3);
%     a.sortedLickMouseList = a.reverseMiceList(a.earlyLickSortIdx);
%     a.sortedSig = a.completeSig(a.earlyLickSortIdx);
%     a.completeRevSig = a.postRevEarlyLicks(a.reverseMice,3);
%     a.sortedRevSig = a.completeRevSig(a.earlyLickSortIdx);
%     a.completeRevLickIdx = a.earlyLickIdx(a.reverseMice,2);
%     a.sortedRevEarlyLickIdx = a.completeRevLickIdx(a.earlyLickSortIdx);
%     
%     fig = figure();
%     fig.PaperUnits = 'inches';
%     fig.PaperPosition = [0.5 0.5 10 7];
%     set(fig,'renderer','painters');
%     set(fig,'PaperOrientation','landscape');
% 
%     ax = nsubplot(2,1,1,1);
%     ax.FontSize = 8;
%     ax.YLim = [-1 1];
%     ax.XTick = [1:numel(a.reverseMice)];
%     ax.XTickLabel = [a.sortedLickMouseList];
%     bar(find(a.sortedSig<0.05),a.sortedEarlyLickIdx(a.sortedSig<0.05,1),'k');
%     bar(find(a.sortedSig>=0.05),a.sortedEarlyLickIdx(a.sortedSig>=0.05,1),'EdgeColor',[.8 .8 .8],'FaceColor',[.8 .8 .8]);
%     ylabel('Pre-odor2 lick index');
%     xlabel('Mouse');
%     title({'Pre-odor2 lick indices, PRE-reveral', '(1 = lick more for initial noInfo side)'});
% 
%     ax = nsubplot(2,1,2,1);
%     ax.FontSize = 8;
%     ax.YLim = [-1 1];
%     ax.XTick = [1:numel(a.reverseMice)];
%     ax.XTickLabel = [a.sortedLickMouseList];
%     bar(find(a.sortedRevSig<0.05),a.sortedRevEarlyLickIdx(a.sortedRevSig<0.05,1),'k');
%     bar(find(a.sortedRevSig>=0.05),a.sortedRevEarlyLickIdx(a.sortedRevSig>=0.05,1),'EdgeColor',[.8 .8 .8],'FaceColor',[.8 .8 .8]);
%     ylabel('Pre-odor2 lick index');
%     xlabel('Mouse');
%     hold off;   
%     
%     saveas(fig,fullfile(pathname,'EarlyLickIndex'),'pdf');
% %     close(fig);


    %% REACTION SPEED REGRESSION

    bothSig = a.preRevRxnSpeed(:,3)<0.05 & a.postRevRxnSpeed(:,3)<0.05;

    for m = 1:a.mouseCt
        if bothSig(m) == 1
            if a.preRevRxnSpeed(m,1)>a.preRevRxnSpeed(m,2)
                if a.postRevRxnSpeed(m,1)>a.postRevRxnSpeed(m,2)
                    sig(m) = 1;
                else
                    sig(m) = 3;
                end
            else if a.preRevRxnSpeed(m,1)<a.preRevRxnSpeed(m,2)
                    if a.postRevRxnSpeed(m,1)<a.postRevRxnSpeed(m,2)
                        sig(m) = 2;
                    else
                        sig(m) = 3;
                    end
                end
            end
        else sig(m) = 4;
        end
    end
    
    reverseSig = sig(a.reverseMice);
    a.rxnSpeedIdxRev=a.rxnSpeedIdx(a.reverseMice,:);

    
    fig = figure();
    fig.PaperUnits = 'inches';
    fig.PaperPosition = [0.5 0.5 10 7];
    set(fig,'renderer','painters');
    set(fig,'PaperOrientation','landscape');

    ax = nsubplot(1,1,1,1);
    ax.FontSize = 8;
    ax.XLim = [-.3 .3];
    ax.YLim = [-.3 .3];
    for l = 1:numel(a.reverseMice)
        m = a.reverseMice(l);
        dy = 0.01;
        text(a.rxnSpeedIdx(m,1),a.rxnSpeedIdx(m,2) + dy,a.reverseMiceList{l},'HorizontalAlignment','center');
    end
    plot([-10000000 1000000],[0 0],'color',[0.2 0.2 0.2],'linewidth',0.25,'yliminclude','off','xliminclude','off');
    plot([0 0],[-10000000 1000000],'color',[0.2 0.2 0.2],'linewidth',0.25,'yliminclude','off','xliminclude','off');
    scatter(a.rxnSpeedIdxRev(reverseSig==1,1),a.rxnSpeedIdxRev(reverseSig==1,2),'filled','MarkerEdgeColor','none','MarkerFaceColor',purple);
    scatter(a.rxnSpeedIdxRev(reverseSig==2,1),a.rxnSpeedIdxRev(reverseSig==2,2),'filled','MarkerEdgeColor','none','MarkerFaceColor',orange);
    scatter(a.rxnSpeedIdxRev(reverseSig==3,1),a.rxnSpeedIdxRev(reverseSig==3,2),'filled','MarkerEdgeColor','none','MarkerFaceColor','k');
    scatter(a.rxnSpeedIdxRev(reverseSig==4,1),a.rxnSpeedIdxRev(reverseSig==4,2),'filled','MarkerEdgeColor','none','MarkerFaceColor',[.8 .8 .8]);
    ylabel('POST-reversal (info side vs other side)');
    xlabel('PRE-reversal (info side vs other side)');
    title({'Reaction speed indices, pre vs post-reversal', '(1 = faster reaction for info side)'});
    hold off;

    saveas(fig,fullfile(pathname,'PrevsPostRxn'),'pdf');
%     close(fig);

%% PLOT MEAN CHOICES AROUND REVERSALS

    fig = figure();
    
    fig = gcf;
    fig.PaperUnits = 'inches';
    fig.PaperPosition = [0.5 0.5 10 7];
    set(fig,'renderer','painters');
    set(fig,'PaperOrientation','landscape');
    
    ax = nsubplot(1,1,1,1);
    ax.FontSize = 8;
    ax.YTick = [0 0.25 0.50 0.75 1];
    ax.YLim = [0 1];
    ax.XLim = [0.5 9.5];
    ax.XTick = [1:8];
    
    plot([1:4], a.meanReversalMultiPrefs(1:4),'Color','k','LineWidth',3,'Marker','o','MarkerFaceColor','k','MarkerSize',5);
    plot([1:4], a.meanReversalMultiPrefs(1:4)+a.SEMReversalMultiPrefs(1:4),'Color','k','LineWidth',1,'Marker','none');
    plot([1:4], a.meanReversalMultiPrefs(1:4)-a.SEMReversalMultiPrefs(1:4),'Color','k','LineWidth',1,'Marker','none');
    plot([5:8], a.meanReversalMultiPrefs(5:8),'Color','k','LineWidth',3,'Marker','o','MarkerFaceColor','k','MarkerSize',5)
    plot([5:8], a.meanReversalMultiPrefs(5:8)+a.SEMReversalMultiPrefs(1:4),'Color','k','LineWidth',1,'Marker','none');
    plot([5:8], a.meanReversalMultiPrefs(5:8)-a.SEMReversalMultiPrefs(1:4),'Color','k','LineWidth',1,'Marker','none');
    plot([1.5 1.5],[-10000000 1000000],'color','r','linewidth',1,'linestyle','--','yliminclude','off','xliminclude','off');
    plot([5.5 5.5],[-10000000 1000000],'color','r','linewidth',1,'linestyle','--','yliminclude','off','xliminclude','off');
    
    reverseLabels = {'Pre-reverse','1','2','3','Pre-reverse','1','2','3'};
    set(gca,'XTickLabel',reverseLabels);
    ylabel({'% choice of', 'initial info side'});
    hold off;
    
    saveas(fig,fullfile(pathname,'ReversalMultiChoices'),'pdf');
    
%% PLOT MEAN CHOICES AROUND REVERSALS (single days)

% if a.choiceMouseCt > 1
    fig = figure();
    
    fig = gcf;
    fig.PaperUnits = 'inches';
    fig.PaperPosition = [0.5 0.5 10 7];
    set(fig,'renderer','painters');
    set(fig,'PaperOrientation','landscape');
    
    ax = nsubplot(1,1,1,1);
    ax.FontSize = 8;
    ax.YTick = [0 0.25 0.50 0.75 1];
    ax.YLim = [0 1];
    ax.XLim = [0.5 3.5];
    ax.XTick = [1 2 3];
    
    for n=1:3
       plot(n,nanmean(a.reversalPrefs(:,n)),'Color','k','LineWidth',2,'Marker','o','MarkerFaceColor','k','MarkerSize',10); 
       errorbar(n,nanmean(a.reversalPrefs(:,n)),sem(a.reversalPrefs(:,n)),'Color','k','LineWidth',2,'CapSize',100);
    end
    for m = 1:numel(a.reverseMice)
%         if ~isnan(a.reversalPrefs(m,3))
            plot(a.reversalPrefs(m,:),'Color',grey,'LineStyle',':','LineWidth',2,'Marker','o','MarkerFaceColor',grey);
%         end
    end
    reverseLabels = {'Pre-reversal','Reversal','Post-reversal'};
    set(gca,'XTickLabel',reverseLabels);
    ylabel({'% choice of', 'initial info side'});
    
    saveas(fig,fullfile(pathname,'ReversalChoices'),'pdf');
    
% end

%% PLOT MEAN CHOICES AROUND REVERSALS (single days) for mice with real pref
% 
% % if a.choiceMouseCt > 1
%     fig = figure();
%     
%     fig = gcf;
%     fig.PaperUnits = 'inches';
%     fig.PaperPosition = [0.5 0.5 10 7];
%     set(fig,'renderer','painters');
%     set(fig,'PaperOrientation','landscape');
%     
%     ax = nsubplot(1,1,1,1);
%     ax.FontSize = 8;
%     ax.YTick = [0 0.25 0.50 0.75 1];
%     ax.YLim = [0 1];
%     ax.XLim = [0.5 3.5];
%     ax.XTick = [1 2 3];
%     
%     for n=1:3
%        plot(n,nanmean(a.reversalPrefs(a.reversalPrefFlag,n)),'Color','k','LineWidth',2,'Marker','o','MarkerFaceColor','k','MarkerSize',10); 
%        errorbar(n,nanmean(a.reversalPrefs(a.reversalPrefFlag,n)),sem(a.reversalPrefs(a.reversalPrefFlag,n)),'Color','k','LineWidth',2,'CapSize',100);
%     end
%     for mm = 1:sum(a.reversalPrefFlag)
%         m = a.reversalPrefMice(mm);
% %         if ~isnan(a.reversalPrefs(m,3))
%             plot(a.reversalPrefs(m,:),'Color',grey,'LineStyle',':','LineWidth',2,'Marker','o','MarkerFaceColor',grey);
% %         end
%     end
%     reverseLabels = {'Pre-reversal','Reversal','Post-reversal'};
%     set(gca,'XTickLabel',reverseLabels);
%     ylabel({'% choice of', 'initial info side'});
%     
%     saveas(fig,fullfile(pathname,'ReversalChoicesReal'),'pdf');
%     
% % end

%% PLOT RXN SPEED IDX AROUND REVERSALS

% if a.choiceMouseCt > 1
    fig = figure();
    
    fig = gcf;
    fig.PaperUnits = 'inches';
    fig.PaperPosition = [0.5 0.5 10 7];
    set(fig,'renderer','painters');
    set(fig,'PaperOrientation','landscape');
    
    ax = nsubplot(1,1,1,1);
    ax.FontSize = 8;
%     ax.YTick = [0 0.25 0.50 0.75 1];
%     ax.YLim = [0 1];
    ax.XLim = [0.5 3.5];
    ax.XTick = [1 2 3];
    
    for n=1:3
       plot(n,nanmean(a.reversalRxn(:,n)),'Color','k','LineWidth',2,'Marker','o','MarkerFaceColor','k','MarkerSize',10); 
       errorbar(n,nanmean(a.reversalRxn(:,n)),sem(a.reversalRxn(:,n)),'Color','k','LineWidth',2,'CapSize',100);
    end
    for m = 1:numel(a.reverseMice)
        if ~isnan(a.reversalPrefs(m,3))
            plot(a.reversalRxn(m,:),'Color',grey,'LineStyle',':','LineWidth',2,'Marker','o','MarkerFaceColor',grey);
        end
    end
    reverseLabels = {'Pre-reversal','Reversal','Post-reversal'};
    set(gca,'XTickLabel',reverseLabels);
    ylabel('Reaction Speed Index');
    
    saveas(fig,fullfile(pathname,'ReversalRxn'),'pdf');
% end


%% REACTION SPEED PLOT

    fig = figure();
    
    fig = gcf;
    fig.PaperUnits = 'inches';
    fig.PaperPosition = [0.5 0.5 10 7];
    set(fig,'renderer','painters');
    set(fig,'PaperOrientation','landscape');
    
    ax = nsubplot(1,1,1,1);
    ax.FontSize = 8;
%     ax.YTick = [0 500 1000 1500];
%     ax.YLim = [300 1300];
    ax.XLim = [0.5 4.5];
%     ax.XTick = [1 2 3];
    
%     bar(1,nanmean(a.reversalRxn(:,1)));
    for m = 1:numel(a.reverseMice)
        plot([1 2 3 4],[a.reversalRxnInfo(m,1) a.reversalRxnRand(m,1) a.reversalRxnInfoChoice(m,1) a.reversalRxnRandChoice(m,1)],'Color',grey,'LineStyle',':','LineWidth',2,'Marker','o','MarkerFaceColor',grey);
    end
    plot(1,nanmean(a.reversalRxnInfo(:,1)),'Color','k','LineWidth',2,'Marker','o','MarkerFaceColor','k','MarkerSize',10);
    errorbar(1,nanmean(a.reversalRxnInfo(:,1)),sem(a.reversalRxnInfo(:,1)),'Color','k','LineWidth',2,'CapSize',100);
    plot(2,nanmean(a.reversalRxnRand(:,1)),'Color','k','LineWidth',2,'Marker','o','MarkerFaceColor','k','MarkerSize',10);
    errorbar(2,nanmean(a.reversalRxnRand(:,1)),sem(a.reversalRxnRand(:,1)),'Color','k','LineWidth',2,'CapSize',100);
    plot(3,nanmean(a.reversalRxnInfoChoice(:,1)),'Color','k','LineWidth',2,'Marker','o','MarkerFaceColor','k','MarkerSize',10);
    errorbar(3,nanmean(a.reversalRxnInfoChoice(:,1)),sem(a.reversalRxnInfoChoice(:,1)),'Color','k','LineWidth',2,'CapSize',100);
    plot(4,nanmean(a.reversalRxnRandChoice(:,1)),'Color','k','LineWidth',2,'Marker','o','MarkerFaceColor','k','MarkerSize',10);
    errorbar(4,nanmean(a.reversalRxnRandChoice(:,1)),sem(a.reversalRxnRandChoice(:,1)),'Color','k','LineWidth',2,'CapSize',100);    
    xticks([1 2 3 4]);
    xticklabels({'Info Forced','No Info Forced','Info Choice','No Info Choice'});
    ylabel('Reaction time on last session before reversal');
    saveas(fig,fullfile(pathname,'ReactionTime'),'pdf');
    
    
    %% REACTION TIME PLOT ALL DAYS

    fig = figure();
    
    fig = gcf;
    fig.PaperUnits = 'inches';
    fig.PaperPosition = [0.5 0.5 10 7];
    set(fig,'renderer','painters');
    set(fig,'PaperOrientation','landscape');
    
    ax = nsubplot(1,1,1,1);
    ax.FontSize = 8;
%     ax.YTick = [0 500 1000 1500];
    ax.YLim = [300 1300];
    ax.XLim = [0.5 3.5];
%     ax.XTick = [1 2 3];
    
%     bar(1,nanmean(a.reversalRxn(:,1)));
    for m = 1:a.mouseCt
        plot([1 3],[a.rxnMean(m,1) a.rxnMean(m,2)],'Color',grey,'LineStyle',':','LineWidth',2,'Marker','o','MarkerFaceColor',grey);
    end
    plot(1,nanmean(a.rxnMean(:,1)),'Color','k','LineWidth',2,'Marker','o','MarkerFaceColor','k','MarkerSize',10);
    errorbar(1,nanmean(a.rxnMean(:,1)),sem(a.rxnMean(:,1)),'Color','k','LineWidth',2,'CapSize',100);
    plot(3,nanmean(a.rxnMean(:,2)),'Color','k','LineWidth',2,'Marker','o','MarkerFaceColor','k','MarkerSize',10);
    errorbar(3,nanmean(a.rxnMean(:,2)),sem(a.rxnMean(:,2)),'Color','k','LineWidth',2,'CapSize',100);
    xticks([1 3]);
    xticklabels({'Info','No Info'});
    ylabel('Reaction time across all preference days');
    saveas(fig,fullfile(pathname,'ReactionTimeAllDays'),'pdf');
   

%% PLOT EARLY LICK IDX AROUND REVERSALS

% if numel(a.reverseMice) > 1
    fig = figure();
    
    fig = gcf;
    fig.PaperUnits = 'inches';
    fig.PaperPosition = [0.5 0.5 10 7];
    set(fig,'renderer','painters');
    set(fig,'PaperOrientation','landscape');
    
    ax = nsubplot(1,1,1,1);
    ax.FontSize = 8;
%     ax.YTick = [0 0.25 0.50 0.75 1];
%     ax.YLim = [0 1];
    ax.XLim = [0.5 3.5];
    ax.XTick = [1 2 3];
    
    for n=1:3
       plot(n,nanmean(a.reversalLicks(:,n)),'Color','k','LineWidth',2,'Marker','o','MarkerFaceColor','k','MarkerSize',10); 
       errorbar(n,nanmean(a.reversalLicks(:,n)),sem(a.reversalPrefs(:,n)),'Color','k','LineWidth',2,'CapSize',100);
    end
    for m = 1:numel(a.reverseMice)
        if ~isnan(a.reversalPrefs(m,3))
            plot(a.reversalLicks(m,:),'Color',grey,'LineStyle',':','LineWidth',2,'Marker','o','MarkerFaceColor',grey);
        end
    end
    reverseLabels = {'Pre-reversal','Reversal','Post-reversal'};
    set(gca,'XTickLabel',reverseLabels);
    ylabel('Early Lick Index');
    
    saveas(fig,fullfile(pathname,'ReversalLicks'),'pdf');
% end

%% PLOT LICKS AROUND REVERSALS

% if numel(a.reverseMice) > 1
    fig = figure();
    
    fig = gcf;
    fig.PaperUnits = 'inches';
    fig.PaperPosition = [0.5 0.5 10 7];
    set(fig,'renderer','painters');
    set(fig,'PaperOrientation','landscape');
    
    
    ax = nsubplot(1,2,1,1);
    ax.FontSize = 8;
%     ax.YTick = [0 0.25 0.50 0.75 1];
%     ax.YLim = [0 40];
    ax.XLim = [0.5 3.5];
    ax.XTick = [1 2 3];
    
   plot(nanmean(a.reversalInfoBigEarlyLicks(:,:)),'Color','g','LineWidth',3,'Marker','o','MarkerFaceColor','g','MarkerSize',5); 
%    plot(nanmean(a.reversalInfoBigEarlyLicks([1:3,5:15],:)+sem(a.reversalInfoBigEarlyLicks([1:3,5:15],:))),'Color','g','LineWidth',1);
%    plot(nanmean(a.reversalInfoBigEarlyLicks([1:3,5:15],:)-sem(a.reversalInfoBigEarlyLicks([1:3,5:15],:))),'Color','g','LineWidth',1);
   plot(nanmean(a.reversalInfoSmallEarlyLicks(:,:)),'Color','m','LineWidth',3,'Marker','o','MarkerFaceColor','m','MarkerSize',5); 
%    plot(nanmean(a.reversalInfoSmallEarlyLicks([1:3,5:15],:)+sem(a.reversalInfoSmallEarlyLicks([1:3,5:15],:))),'Color','m','LineWidth',1);
%    plot(nanmean(a.reversalInfoSmallEarlyLicks([1:3,5:15],:)-sem(a.reversalInfoSmallEarlyLicks([1:3,5:15],:))),'Color','m','LineWidth',1);
   plot(nanmean(a.reversalRandCEarlyLicks(:,:)),'Color',cornflower,'LineWidth',3,'Marker','o','MarkerFaceColor',cornflower,'MarkerSize',5); 
%    plot(nanmean(a.reversalRandCEarlyLicks([1:3,5:15],:)+sem(a.reversalRandCEarlyLicks([1:3,5:15],:))),'Color',cornflower,'LineWidth',1);
%    plot(nanmean(a.reversalRandCEarlyLicks([1:3,5:15],:)-sem(a.reversalRandCEarlyLicks([1:3,5:15],:))),'Color',cornflower,'LineWidth',1);
   plot(nanmean(a.reversalRandDEarlyLicks(:,:)),'Color',cornflower,'LineWidth',3,'LineStyle','--','Marker','o','MarkerFaceColor',cornflower,'MarkerSize',5); 
%    plot(nanmean(a.reversalRandDEarlyLicks([1:3,5:15],:)+sem(a.reversalRandDEarlyLicks([1:3,5:15],:))),'Color',cornflower,'LineWidth',1,'LineStyle','--');   
%    plot(nanmean(a.reversalRandDEarlyLicks([1:3,5:15],:)-sem(a.reversalRandDEarlyLicks([1:3,5:15],:))),'Color',cornflower,'LineWidth',1,'LineStyle','--');   

    reverseLabels = {'Pre-reversal','Reversal','Post-reversal'};
    set(gca,'XTickLabel',reverseLabels);
    ylabel('Mean Pre-Odor Licks');
    hold off;
    
    ax = nsubplot(1,2,1,2);
    ax.FontSize = 8;
%     ax.YTick = [0 0.25 0.50 0.75 1];
%     ax.YLim = [0 40];
    ax.XLim = [0.5 3.5];
    ax.XTick = [1 2 3];

   plot(nanmean(a.reversalInfoBigLicks(:,:)),'Color','g','LineWidth',3,'Marker','o','MarkerFaceColor','g','MarkerSize',5); 
%    plot(nanmean(a.reversalInfoBigLicks([1:3,5:15],:)+sem(a.reversalInfoBigLicks([1:3,5:15],:))),'Color','g','LineWidth',1);
%    plot(nanmean(a.reversalInfoBigLicks([1:3,5:15],:)-sem(a.reversalInfoBigLicks([1:3,5:15],:))),'Color','g','LineWidth',1);
   plot(nanmean(a.reversalInfoSmallLicks(:,:)),'Color','m','LineWidth',3,'Marker','o','MarkerFaceColor','m','MarkerSize',5); 
%    plot(nanmean(a.reversalInfoSmallLicks([1:3,5:15],:)+sem(a.reversalInfoSmallLicks([1:3,5:15],:))),'Color','m','LineWidth',1);
%    plot(nanmean(a.reversalInfoSmallLicks([1:3,5:15],:)-sem(a.reversalInfoSmallLicks([1:3,5:15],:))),'Color','m','LineWidth',1);
   plot(nanmean(a.reversalRandCLicks(:,:)),'Color',cornflower,'LineWidth',3,'Marker','o','MarkerFaceColor',cornflower,'MarkerSize',5); 
%    plot(nanmean(a.reversalRandCLicks([1:3,5:15],:)+sem(a.reversalRandCLicks([1:3,5:15],:))),'Color',cornflower,'LineWidth',1);
%    plot(nanmean(a.reversalRandCLicks([1:3,5:15],:)-sem(a.reversalRandCLicks([1:3,5:15],:))),'Color',cornflower,'LineWidth',1);
   plot(nanmean(a.reversalRandDLicks(:,:)),'Color',cornflower,'LineWidth',3,'LineStyle','--','Marker','o','MarkerFaceColor',cornflower,'MarkerSize',5); 
%    plot(nanmean(a.reversalRandDLicks([1:3,5:15],:)+sem(a.reversalRandDLicks([1:3,5:15],:))),'Color',cornflower,'LineWidth',1,'LineStyle','--');   
%    plot(nanmean(a.reversalRandDLicks([1:3,5:15],:)-sem(a.reversalRandDLicks([1:3,5:15],:))),'Color',cornflower,'LineWidth',1,'LineStyle','--');   
   
    reverseLabels = {'Pre-reversal','Reversal','Post-reversal'};
    set(gca,'XTickLabel',reverseLabels);
    ylabel('Mean Anticipatory Licks');
    hold off;    
    
    saveas(fig,fullfile(pathname,'ReversalMeanLicks'),'pdf');
% end

%% PLOT REWARD RATE DIFF AROUND REVERSALS

% if numel(a.reverseMice) > 1
    fig = figure();
    
    fig = gcf;
    fig.PaperUnits = 'inches';
    fig.PaperPosition = [0.5 0.5 10 7];
    set(fig,'renderer','painters');
    set(fig,'PaperOrientation','landscape');
    
    ax = nsubplot(1,1,1,1);
    ax.FontSize = 8;
%     ax.YTick = [0 0.25 0.50 0.75 1];
%     ax.YLim = [0 1];
    ax.XLim = [0.5 3.5];
    ax.XTick = [1 2 3];
    
    for n=1:size(a.reversalRewardRateIdx,2)
       plot(n,nanmean(a.reversalRewardRateIdx(:,n)),'Color','k','LineWidth',2,'Marker','o','MarkerFaceColor','k','MarkerSize',10); 
       errorbar(n,nanmean(a.reversalRewardRateIdx(:,n)),sem(a.reversalRewardRateIdx(:,n)),'Color','k','LineWidth',2,'CapSize',100);
    end
    if size(a.reversalRewardRateIdx,2)==3
    for m = 1:numel(a.reverseMice)
        if ~isnan(a.reversalRewardRateIdx(m,3))
            plot(a.reversalRewardRateIdx(m,:),'Color',grey,'LineStyle',':','LineWidth',2,'Marker','o','MarkerFaceColor',grey);
        end
    end
    end
    reverseLabels = {'Pre-reversal','Reversal','Post-reversal'};
    set(gca,'XTickLabel',reverseLabels);
    ylabel('Reward Rate of Initial Info Side - Reward Rate of Initial No Info Side');
    
    saveas(fig,fullfile(pathname,'ReversalRewardRate'),'pdf');
    
% end

%% REWARD RATE PRE-REVERSE PLOT

    fig = figure();

    fig = gcf;
    fig.PaperUnits = 'inches';
    fig.PaperPosition = [0.5 0.5 10 7];
    set(fig,'renderer','painters');
    set(fig,'PaperOrientation','landscape');

    ax = nsubplot(1,1,1,1);
    ax.FontSize = 8;
    %     ax.YTick = [0 0.25 0.50 0.75 1];
    %     ax.YLim = [0 20];
    ax.XLim = [0 4];
    ax.XTick = [1 3];
    xticklabels({'Info','No Info'});
    ylabel('Reward rate on last day before reverse');

    %     plot(1,nanmean(a.reversalRewardRateIdx(:,1)),'Color','k','LineWidth',2,'Marker','o','MarkerFaceColor','k','MarkerSize',10);
    %     errorbar(1,nanmean(a.reversalRewardRateIdx(:,1)),sem(a.reversalRewardRateIdx(:,1)),'Color','k','LineWidth',2,'CapSize',100);

    plot(1,nanmean(a.reversalRewardRateInfo(:,1)),'Color','k','LineWidth',2,'Marker','o','MarkerFaceColor','k','MarkerSize',10);
    errorbar(1,nanmean(a.reversalRewardRateInfo(:,1)),sem(a.reversalRewardRateInfo(:,1)),'Color','k','LineWidth',2,'CapSize',100);
    plot(3,nanmean(a.reversalRewardRateRand(:,1)),'Color','k','LineWidth',2,'Marker','o','MarkerFaceColor','k','MarkerSize',10);
    errorbar(3,nanmean(a.reversalRewardRateRand(:,1)),sem(a.reversalRewardRateRand(:,1)),'Color','k','LineWidth',2,'CapSize',100);


    for m = 1:numel(a.reverseMice)
    %         plot(a.reversalRewardRateIdx(m,1),'Color',grey,'LineStyle',':','LineWidth',2,'Marker','o','MarkerFaceColor',grey);
    %         plot(a.reversalPrefs(m,1),a.reversalRewardRateIdx(m,1),'Color',grey,'LineStyle',':','LineWidth',2,'Marker','o','MarkerFaceColor',grey);
        plot([1 3],[a.reversalRewardRateInfo(m,1),a.reversalRewardRateRand(m,1)],'Color',grey,'LineStyle',':','LineWidth',2,'Marker','o','MarkerFaceColor',grey);
    %         plot(2,a.reversalRewardRateRand(m,1),'Color',grey,'LineStyle',':','LineWidth',2,'Marker','o','MarkerFaceColor',grey);
    end



    % plot(a.reversalRewardRateIdx(:,1),a.reversalMultiPrefs(:,1),'Color','k','LineStyle','none','Marker','o','MarkerFaceColor','k','MarkerSize',10);

    saveas(fig,fullfile(pathname,'RewardRate'),'pdf');
    
    
%% REWARD RATE ALL DAYS

    fig = figure();
    
    fig = gcf;
    fig.PaperUnits = 'inches';
    fig.PaperPosition = [0.5 0.5 10 7];
    set(fig,'renderer','painters');
    set(fig,'PaperOrientation','landscape');
    
    ax = nsubplot(1,1,1,1);
    ax.FontSize = 8;
%     ax.YTick = [0 500 1000 1500];
%     ax.YLim = [300 1300];
    ax.XLim = [0.5 3.5];
%     ax.XTick = [1 2 3];
    
%     bar(1,nanmean(a.reversalRxn(:,1)));
    for m = 1:a.mouseCt
        plot([1 3],[a.rewardRate(m,1) a.rewardRate(m,2)],'Color',grey,'LineStyle',':','LineWidth',2,'Marker','o','MarkerFaceColor',grey);
    end
    plot(1,nanmean(a.rewardRate(:,1)),'Color','k','LineWidth',2,'Marker','o','MarkerFaceColor','k','MarkerSize',10);
    errorbar(1,nanmean(a.rewardRate(:,1)),sem(a.rewardRate(:,1)),'Color','k','LineWidth',2,'CapSize',100);
    plot(3,nanmean(a.rewardRate(:,2)),'Color','k','LineWidth',2,'Marker','o','MarkerFaceColor','k','MarkerSize',10);
    errorbar(3,nanmean(a.rewardRate(:,2)),sem(a.rewardRate(:,2)),'Color','k','LineWidth',2,'CapSize',100);
    xticks([1 3]);
    xticklabels({'Info','No Info'});
    ylabel('Reward Rate across all preference days');
    saveas(fig,fullfile(pathname,'RewardRateAllDays'),'pdf');    


%% pref vs reward rate
fig = figure();
fig.PaperUnits = 'inches';
fig.PaperPosition = [0.5 0.5 10 7];
set(fig,'renderer','painters');
set(fig,'PaperOrientation','landscape');

ax = nsubplot(1,1,1,1);
ax.FontSize = 8;
% ax.XLim = [0 1];
ax.YLim = [0 1];
for mm = 1:numel(a.reverseMice)
    m = a.reverseMice(mm);
    text(a.rewardDiff(m,1),a.overallChoice(m,5) + 0.01,a.reverseMiceList{mm},'HorizontalAlignment','center');
end
scatter(a.rewardDiff(:,1),a.overallChoice(:,5),'filled')
plot([-10000000 1000000],[0.5 0.5],'color',[0.2 0.2 0.2],'linewidth',0.25,'yliminclude','off','xliminclude','off');
plot([0 0],[-10000000 1000000],'color',[0.2 0.2 0.2],'linewidth',0.25,'yliminclude','off','xliminclude','off');
% plot([0 1],[0 1],'color',[0.2 0.2 0.2],'linewidth',0.25,'yliminclude','off','xliminclude','off');
% plot([0 1],[1 0],'color',[0.2 0.2 0.2],'linewidth',0.25,'yliminclude','off','xliminclude','off');
ylabel({'P(choose info)'}); %{'Info choice', 'probability'}
xlabel({'Info reward rate - no info reward rate (uL per minute)'});
title('Choice of information vs. reward rate difference');
hold off;

saveas(fig,fullfile(pathname,'Prefbyreward'),'pdf');
%     close(fig);
    
    
    %% initial pref vs initial reward rate
fig = figure();
fig.PaperUnits = 'inches';
fig.PaperPosition = [0.5 0.5 10 7];
set(fig,'renderer','painters');
set(fig,'PaperOrientation','landscape');

ax = nsubplot(1,1,1,1);
ax.FontSize = 8;
% ax.XLim = [0 1];
ax.YLim = [0 1];
for mm = 1:numel(a.reverseMice)
    m = a.reverseMice(mm);
    text(a.reversalRewardRateIdx(mm,1),a.pref(m,1) + 0.01,a.reverseMiceList{mm},'HorizontalAlignment','center');
end
scatter(a.reversalRewardRateIdx(:,1),a.pref(a.reverseMice,1),'filled')
plot([-10000000 1000000],[0.5 0.5],'color',[0.2 0.2 0.2],'linewidth',0.25,'yliminclude','off','xliminclude','off');
plot([0 0],[-10000000 1000000],'color',[0.2 0.2 0.2],'linewidth',0.25,'yliminclude','off','xliminclude','off');
% plot([0 1],[0 1],'color',[0.2 0.2 0.2],'linewidth',0.25,'yliminclude','off','xliminclude','off');
% plot([0 1],[1 0],'color',[0.2 0.2 0.2],'linewidth',0.25,'yliminclude','off','xliminclude','off');
ylabel({'P(choose info)'}); %{'Info choice', 'probability'}
xlabel({'Info reward rate - no info reward rate (uL per minute)'});
title('Initial choice of information vs. reward rate difference');
hold off;

saveas(fig,fullfile(pathname,'InitPrefbyreward'),'pdf');
%     close(fig);    
    
    
%%
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


%% CHOICE TRAINING VS INFO PREF / REVERSAL ABILITY?!?

% sum(a.mice(:,3)==1 & a.fileTrialTypes==7)

for m = 1:a.mouseCt
   a.choiceTraining(m,1) =  sum(a.mice(:,m)==1 & (a.fileTrialTypes==7 | a.fileTrialTypes==8));
end

% a.incomplete
%a.reversalprefs

%% INFO RELATIVE VALUE DUE TO LEAVING

a.present = 1-a.incomplete;

for m = 1:a.mouseCt
   a.infoLeaveVal(m,1) =  (a.present(m,5)*8*0.25+a.present(m,6)*1*0.75)/(a.present(m,7)*8*0.25+a.present(m,8)*1*0.75);
   a.waterMissed(m,1) = a.incomplete(m,6)*1*0.75/(a.present(m,5)*8*0.25+a.present(m,6)*1*0.75);
end