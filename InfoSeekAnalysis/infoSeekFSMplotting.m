%% TO CALC/FIX

% bar graphs of licking for most recent day


%%
% PLOTTING

a.mColors = [0 176 80; 255 0 0; 0 176 240; 112 48 160; 234 132 20; 255 255 0; 204 0 204];
a.mColors = a.mColors./255;

dx = 0.2;
dy = 0.02;

odorDelay = 2000;
rewardWait = 2000;

plots = [1 1; 1 2; 2 1; 2 2];

purple = [121 32 196] ./ 255;
orange = [251 139 6] ./ 255;

a.outcomeLabels = {'ChoiceNoChoice','ChoiceInfoBig','ChoiceInfoSmall','ChoiceInfoNP','ChoiceRandBig',...
    'ChoiceRandSmall','ChoiceRandNP','InfoNoChoice','InfoBig','InfoSmall',...
    'InfoNP','InfoIncorrect','RandNoChoice','RandBig','RandSmall','RandNP',...
    'RandIncorrect'};

a.choiceLabels = {'ChoiceInfoBig','ChoiceInfoSmall','ChoiceRandBig',...
    'ChoiceRandSmall','InfoBig','InfoSmall','RandBig','RandSmall'};

%% PLOT DAY SUMMARIES BY MOUSE

for m = 1:a.mouseCt
    figure();
    
    fig = gcf;
    fig.PaperUnits = 'inches';
    fig.PaperPosition = [1 1 7 9];
    set(fig,'renderer','painters')
    
%     ax = nsubplot(7,1,1,1);
%     title(a.mouseList(m));
%     ax.FontSize = 10;
%     ax.XTick = [0:5:a.mouseDayCt(m)];    
%     ax.YTick = [0 0.25 0.50 0.75 1];
%     ax.YLim = [0 1];
%     plot(0:a.mouseDayCt(m),[0 cell2mat(a.daySummary.percentInfo(m,:))],'Color',a.mColors(m,:),'LineWidth',2,'Marker','o','MarkerFaceColor',a.mColors(m,:),'MarkerSize',5);
%     plot([-10000000 1000000],[0.5 0.5],'k','xliminclude','off','color',[0.6 0.6 0.6],'LineWidth',2);
%     plot([a.reverseDay(m)-0.5 a.reverseDay(m)-0.5],[-10000000 1000000],'k','yliminclude','off','xliminclude','off','LineWidth',4);
%     ylabel('Info choice probability');
%     xlabel('Day');
%     hold off;
    
    ax = nsubplot(7,1,1,1);
    title(a.mouseList(m));
    ax.FontSize = 10;
    ax.XTick = [0:5:max(cell2mat(a.daySummary.day(m,:)))];
    plot(cell2mat(a.daySummary.rxnInfoForced(m,:)),'Color',orange,'LineWidth',2,'Marker','o','MarkerFaceColor',orange,'MarkerSize',5);
    plot(cell2mat(a.daySummary.rxnInfoChoice(m,:)),'Color',orange,'LineWidth',2,'Marker','o','MarkerEdgeColor',orange,'MarkerFaceColor','w','MarkerSize',5,'LineStyle',':');
    plot(cell2mat(a.daySummary.rxnRandForced(m,:)),'Color',purple,'LineWidth',2,'Marker','o','MarkerFaceColor',purple,'MarkerSize',5);
    plot(cell2mat(a.daySummary.rxnRandChoice(m,:)),'Color',purple,'LineWidth',2,'Marker','o','MarkerEdgeColor',purple,'MarkerFaceColor','w','MarkerSize',5,'LineStyle',':');
    plot([a.reverseDay(m)-0.5 a.reverseDay(m)-0.5],[-10000000 1000000],'k','yliminclude','off','xliminclude','off','LineWidth',4);
    ylabel('Reaction Time (ms)');
    xlabel('Day');    
    leg = legend(ax,'Info-Forced','Info-Choice','No Info - Forced','No Info - Choice','Location','best','Orientation','horizontal');
    leg.Box = 'off';
    leg.FontWeight = 'bold';
    hold off;
    
    ax = nsubplot(7,1,2,1);
    ax.FontSize = 10;
    ax.XTick = [0:5:max(cell2mat(a.daySummary.day(m,:)))];
    ax.YLim = [0 inf];
    plot(cell2mat(a.daySummary.infoBigLicksEarly(m,:)),'Color','g','LineWidth',2,'Marker','o','MarkerFaceColor','g','MarkerSize',5);
    plot(cell2mat(a.daySummary.infoSmallLicksEarly(m,:)),'Color','m','LineWidth',2,'Marker','o','MarkerFaceColor','m','MarkerSize',5);
    plot(cell2mat(a.daySummary.randCLicksEarly(m,:)),'Color','c','LineWidth',2,'Marker','o','MarkerFaceColor','c','MarkerSize',5);
    plot(cell2mat(a.daySummary.randDLicksEarly(m,:)),'Color','b','LineWidth',2,'Marker','o','MarkerFaceColor','b','MarkerSize',5);
    plot([a.reverseDay(m)-0.5 a.reverseDay(m)-0.5],[-10000000 1000000],'k','yliminclude','off','xliminclude','off','LineWidth',4);        
    ylabel('Early lick rate');
    xlabel('Day');
    leg = legend(ax,'Info-Rew','Info-No Rew','No Info - C','No Info - D','Location','best','Orientation','horizontal');
    leg.Box = 'off';
    leg.FontWeight = 'bold';
    hold off;

    ax = nsubplot(7,1,3,1);
    ax.FontSize = 10;
    ax.XTick = [0:5:max(cell2mat(a.daySummary.day(m,:)))];
    ax.YLim = [0 inf];
    plot(cell2mat(a.daySummary.infoBigLicks(m,:)),'Color','g','LineWidth',2,'Marker','o','MarkerFaceColor','g','MarkerSize',5);
    plot(cell2mat(a.daySummary.infoSmallLicks(m,:)),'Color','m','LineWidth',2,'Marker','o','MarkerFaceColor','m','MarkerSize',5);
    plot(cell2mat(a.daySummary.randCLicks(m,:)),'Color','c','LineWidth',2,'Marker','o','MarkerFaceColor','c','MarkerSize',5);
    plot(cell2mat(a.daySummary.randDLicks(m,:)),'Color','b','LineWidth',2,'Marker','o','MarkerFaceColor','b','MarkerSize',5);
    plot([a.reverseDay(m)-0.5 a.reverseDay(m)-0.5],[-10000000 1000000],'k','yliminclude','off','xliminclude','off','LineWidth',4);        
    ylabel('Anticipatory lick rate');
    xlabel('Day');
    leg = legend(ax,'Info-Rew','Info-No Rew','No Info - C','No Info - D','Location','best','Orientation','horizontal');
    leg.Box = 'off';
    leg.FontWeight = 'bold';
    hold off;
    
    ax = nsubplot(7,1,4,1);
    ax.FontSize = 10;
    ax.XTick = [0:5:max(cell2mat(a.daySummary.day(m,:)))];
    ax.YLim = [0 inf];
    plot(cell2mat(a.daySummary.infoBigLicksWater(m,:)),'Color','g','LineWidth',2,'Marker','o','MarkerFaceColor','g','MarkerSize',5);
    plot(cell2mat(a.daySummary.infoSmallLicksWater(m,:)),'Color','m','LineWidth',2,'Marker','o','MarkerFaceColor','m','MarkerSize',5);
    plot(cell2mat(a.daySummary.randBigLicksWater(m,:)),'Color','c','LineWidth',2,'Marker','o','MarkerFaceColor','c','MarkerSize',5);
    plot(cell2mat(a.daySummary.randSmallLicksWater(m,:)),'Color','b','LineWidth',2,'Marker','o','MarkerFaceColor','b','MarkerSize',5);
%     plot(cell2mat(a.daySummary.randCLicksWater(m,:)),'Color','c','LineWidth',2,'Marker','o','MarkerFaceColor','c','MarkerSize',5);
%     plot(cell2mat(a.daySummary.randDLicksWater(m,:)),'Color','b','LineWidth',2,'Marker','o','MarkerFaceColor','b','MarkerSize',5);
    plot([a.reverseDay(m)-0.5 a.reverseDay(m)-0.5],[-10000000 1000000],'k','yliminclude','off','xliminclude','off','LineWidth',4);        
    ylabel('Post-outcome lick rate');
    xlabel('Day');
    leg = legend(ax,'Info-Rew','Info-No Rew','No Info - Rew','No Info - No Rew','Location','best','Orientation','horizontal');
    leg.Box = 'off';
    leg.FontWeight = 'bold';
    hold off;
    
    ax = nsubplot(7,1,5,1);
    ax.FontSize = 10;
    ax.XTick = [0:5:max(cell2mat(a.daySummary.day(m,:)))];
    ax.YLim = [0 inf];
    plot(cell2mat(a.daySummary.ARewards(m,:)),'Color','g','LineWidth',2,'Marker','o','MarkerFaceColor','g','MarkerSize',5);
    plot(cell2mat(a.daySummary.BRewards(m,:)),'Color','m','LineWidth',2,'Marker','o','MarkerFaceColor','m','MarkerSize',5);
    plot(cell2mat(a.daySummary.CRewards(m,:)),'Color','c','LineWidth',2,'Marker','o','MarkerFaceColor','c','MarkerSize',5);
    plot(cell2mat(a.daySummary.DRewards(m,:)),'Color','b','LineWidth',2,'Marker','o','MarkerFaceColor','b','MarkerSize',5);
%     plot(cell2mat(a.daySummary.randBigRewards(m,:)),'Color','c','LineWidth',2,'Marker','o','MarkerFaceColor','c','MarkerSize',5);
%     plot(cell2mat(a.daySummary.randSmallRewards(m,:)),'Color','b','LineWidth',2,'Marker','o','MarkerFaceColor','b','MarkerSize',5);
    plot([a.reverseDay(m)-0.5 a.reverseDay(m)-0.5],[-10000000 1000000],'k','yliminclude','off','xliminclude','off','LineWidth',4);        
    ylabel('Mean Reward (uL)');
    xlabel('Day');
    leg = legend(ax,'Info-Rew','Info-No Rew','No Info - C','No Info - D','Location','best','Orientation','horizontal');
    leg.Box = 'off';
    leg.FontWeight = 'bold';
    hold off;
    
        ax = nsubplot(7,1,6,1);
    ax.FontSize = 10;
    ax.XTick = [0:5:max(cell2mat(a.daySummary.day(m,:)))];
%     ax.YLim = [0 15000];
    plot(cell2mat(a.daySummary.trialLengthInfoForced(m,:)),'Color',orange,'LineWidth',2,'Marker','o','MarkerFaceColor',orange,'MarkerSize',5);
    plot(cell2mat(a.daySummary.trialLengthInfoChoice(m,:)),'Color',orange,'LineWidth',2,'Marker','o','MarkerFaceColor',orange,'MarkerSize',5,'LineStyle',':');
    plot(cell2mat(a.daySummary.trialLengthRandForced(m,:)),'Color',purple,'LineWidth',2,'Marker','o','MarkerFaceColor',purple,'MarkerSize',5);
    plot(cell2mat(a.daySummary.trialLengthRandChoice(m,:)),'Color',purple,'LineWidth',2,'Marker','o','MarkerFaceColor',purple,'MarkerSize',5,'LineStyle',':');
    plot([a.reverseDay(m)-0.5 a.reverseDay(m)-0.5],[-10000000 1000000],'k','yliminclude','off','xliminclude','off','LineWidth',4);
    ylabel('Trial duration(ms)');
    xlabel('Day');
    leg = legend(ax,'Info Forced','Info Choice','No Info Forced','No Info Choice','Location','best','Orientation','horizontal');
    leg.Box = 'off';
    leg.FontWeight = 'bold';
    hold off;

    ax = nsubplot(7,1,7,1);
    ax.FontSize = 10;
    ax.XTick = [0:5:max(cell2mat(a.daySummary.day(m,:)))];   
    plot(cell2mat(a.daySummary.rewardRateInfoForced(m,:)),'Color',orange,'LineWidth',2,'Marker','o','MarkerFaceColor',orange,'MarkerSize',5);
    plot(cell2mat(a.daySummary.rewardRateInfoChoice(m,:)),'Color',orange,'LineWidth',2,'Marker','o','MarkerEdgeColor',orange,'MarkerFaceColor','w','MarkerSize',5,'LineStyle',':');
    plot(cell2mat(a.daySummary.rewardRateRandForced(m,:)),'Color',purple,'LineWidth',2,'Marker','o','MarkerFaceColor',purple,'MarkerSize',5);
    plot(cell2mat(a.daySummary.rewardRateRandChoice(m,:)),'Color',purple,'LineWidth',2,'Marker','o','MarkerEdgeColor',purple,'MarkerFaceColor','w','MarkerSize',5,'LineStyle',':');
    plot([a.reverseDay(m)-0.5 a.reverseDay(m)-0.5],[-10000000 1000000],'k','yliminclude','off','xliminclude','off','LineWidth',4);
    ylabel('Reward Rate');
    xlabel('Day');    
    leg = legend(ax,'Info Forced','Info Choice','No Info Forced','No Info Choice','Location','best','Orientation','horizontal');
    leg.Box = 'off';
    leg.FontWeight = 'bold';
    hold off;
end

%% PLOT OUTCOMES BY MOUSE

for m = 1:a.mouseCt
    figure();
    fig = gcf;
    fig.PaperUnits = 'inches';
    fig.PaperPosition = [1 1 7 9];
    set(fig,'renderer','painters')
    for d = 1:a.mouseDayCt(m)
        ax = nsubplot(a.mouseDayCt(m),1,d,1);
        title(a.mouseList(m));
        ax.FontSize = 10;
        [outcomeCounts,outcomeBins] = histcounts(a.daySummary.outcome{m,d},[0.5:1:17.5],'Normalization','probability');
        bar([1:17],outcomeCounts);
        plot([7.5 7.5],[-10000000 1000000],'k','yliminclude','off','color',[0.6 0.6 0.6],'LineWidth',2);
        plot([12.5 12.5],[-10000000 1000000],'k','yliminclude','off','color',[0.6 0.6 0.6],'LineWidth',2);
        ylabel('Trial Outcomes (% of trials)');
        ax.XTick = [1:17];
        set(gca,'XTickLabel',a.outcomeLabels,'XTickLabelRotation',15)
    end
end

%% PLOT MOST RECENT DAY'S LICKS
    
figure();
fig = gcf;
fig.PaperUnits = 'inches';
fig.PaperPosition = [1 1 7 9];
set(fig,'renderer','painters');
    
for m = 1:a.mouseCt
    d = a.mouseDayCt(m);
    ax = nsubplot(1,a.mouseCt,1,m);
    ax.FontSize = 10;
%     ax.XTick = [0:5:max(cell2mat(a.daySummary.day(m,:)))];
%     ax.YLim = [0 inf];
    bar([cell2mat(a.daySummary.infoBigLicks(m,d)) cell2mat(a.daySummary.infoSmallLicks(m,d)) cell2mat(a.daySummary.randCLicks(m,d)) cell2mat(a.daySummary.randDLicks(m,d))]);      
    ylabel('Anticipatory lick rate');
    xlabel(a.mouseList(m));
    hold off;
    
end