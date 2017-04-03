%% TO CALC/FIX

%%
% PLOTTING

a.mColors = [0 176 80; 255 0 0; 0 176 240; 112 48 160; 234 132 20; 255 255 0; 204 0 204];
a.mColors = a.mColors./255;

dx = 0.2;
dy = 0.02;

plots = [1 1; 1 2; 2 1; 2 2];

purple = [121 32 196] ./ 255;
orange = [251 139 6] ./ 255;

a.outcomeLabels = {'ChoiceNoChoice','ChoiceInfoBig','ChoiceInfoSmall','ChoiceInfoNP','ChoiceRandBig',...
    'ChoiceRandSmall','ChoiceRandNP','InfoNoChoice','InfoBig','InfoSmall',...
    'InfoNP','InfoIncorrect','RandNoChoice','RandBig','RandSmall','RandNP',...
    'RandIncorrect'};

a.choiceLabels = {'ChoiceInfoBig','ChoiceInfoSmall','ChoiceRandBig',...
    'ChoiceRandSmall','InfoBig','InfoSmall','RandBig','RandSmall'};

 bins = [a.win/2:a.win:a.maxBin*a.win-a.win/2];

%% PLOT DAY SUMMARIES BY MOUSE

for m = 1:a.mouseCt
    figure();
    
    fig = gcf;
    fig.PaperUnits = 'inches';
    fig.PaperPosition = [1 1 7 10];
    set(fig,'renderer','painters')
    
    ax = nsubplot(4,2,1,1);
    title(a.mouseList(m));
    ax.FontSize = 10;
    ax.XTick = [0:5:a.mouseDayCt(m)];    
    ax.YTick = [0 0.25 0.50 0.75 1];
    ax.YLim = [0 1];
%     set(ax,'units','inches');
%     ax.Position = [1 1 5 1];
    if sum(isnan(cell2mat(a.daySummary.percentInfo(m,:)))) ~= a.mouseDayCt(m)
    plot(0:a.mouseDayCt(m),[0 cell2mat(a.daySummary.percentInfo(m,:))],'Color',a.mColors(m,:),'LineWidth',2,'Marker','o','MarkerFaceColor',a.mColors(m,:),'MarkerSize',5);
    plot([-10000000 1000000],[0.5 0.5],'k','xliminclude','off','color',[0.6 0.6 0.6],'LineWidth',2);
    plot([a.reverseDay(m)-0.5 a.reverseDay(m)-0.5],[-10000000 1000000],'k','yliminclude','off','xliminclude','off','LineWidth',4);
    end
    ylabel({'Info choice', 'probability'}); %ylabel({'line1', 'line2','line3'},)
%     xlabel('Day');
    hold off;
    
    ax = nsubplot(4,2,2,1);
    ax.FontSize = 10;
    ax.XTick = [0:5:max(cell2mat(a.daySummary.day(m,:)))];
    plot(cell2mat(a.daySummary.rxnInfoForced(m,:)),'Color',orange,'LineWidth',2,'Marker','o','MarkerFaceColor',orange,'MarkerSize',5);
    plot(cell2mat(a.daySummary.rxnInfoChoice(m,:)),'Color',orange,'LineWidth',2,'Marker','o','MarkerEdgeColor',orange,'MarkerFaceColor','w','MarkerSize',5,'LineStyle',':');
    plot(cell2mat(a.daySummary.rxnRandForced(m,:)),'Color',purple,'LineWidth',2,'Marker','o','MarkerFaceColor',purple,'MarkerSize',5);
    plot(cell2mat(a.daySummary.rxnRandChoice(m,:)),'Color',purple,'LineWidth',2,'Marker','o','MarkerEdgeColor',purple,'MarkerFaceColor','w','MarkerSize',5,'LineStyle',':');
    plot([a.reverseDay(m)-0.5 a.reverseDay(m)-0.5],[-10000000 1000000],'k','yliminclude','off','xliminclude','off','LineWidth',4);
    ylabel({'Reaction', 'Time (ms)'});
%     xlabel('Day');    
    leg = legend(ax,'Info-Forced','Info-Choice','No Info - Forced','No Info - Choice','Location','best','Orientation','horizontal');
    leg.Box = 'off';
    leg.FontWeight = 'bold';
    hold off;
    
    ax = nsubplot(4,2,3,1);
    ax.FontSize = 10;
    ax.XTick = [0:5:max(cell2mat(a.daySummary.day(m,:)))];
    ax.YLim = [0 inf];
    plot(cell2mat(a.daySummary.infoBigLicksEarly(m,:)),'Color','g','LineWidth',2,'Marker','o','MarkerFaceColor','g','MarkerSize',5);
    plot(cell2mat(a.daySummary.infoSmallLicksEarly(m,:)),'Color','m','LineWidth',2,'Marker','o','MarkerFaceColor','m','MarkerSize',5);
    plot(cell2mat(a.daySummary.randCLicksEarly(m,:)),'Color','c','LineWidth',2,'Marker','o','MarkerFaceColor','c','MarkerSize',5);
    plot(cell2mat(a.daySummary.randDLicksEarly(m,:)),'Color','b','LineWidth',2,'Marker','o','MarkerFaceColor','b','MarkerSize',5);
%     plot(cell2mat(a.daySummary.randBigLicksEarly(m,:)),'Color','c','LineWidth',2,'Marker','o','MarkerFaceColor','c','MarkerSize',5);
%     plot(cell2mat(a.daySummary.randSmallLicksEarly(m,:)),'Color','b','LineWidth',2,'Marker','o','MarkerFaceColor','b','MarkerSize',5);
    plot([a.reverseDay(m)-0.5 a.reverseDay(m)-0.5],[-10000000 1000000],'k','yliminclude','off','xliminclude','off','LineWidth',4);        
    ylabel({'Early', 'lick rate'});
%     xlabel('Day');
    leg = legend(ax,'Info-Rew','Info-No Rew','No Info - C','No Info - D','Location','best','Orientation','horizontal');
    leg.Box = 'off';
    leg.FontWeight = 'bold';
    hold off;

    ax = nsubplot(4,2,4,1);
    ax.FontSize = 10;
    ax.XTick = [0:5:max(cell2mat(a.daySummary.day(m,:)))];
    ax.YLim = [0 inf];
    plot(cell2mat(a.daySummary.infoBigLicks(m,:)),'Color','g','LineWidth',2,'Marker','o','MarkerFaceColor','g','MarkerSize',5);
    plot(cell2mat(a.daySummary.infoSmallLicks(m,:)),'Color','m','LineWidth',2,'Marker','o','MarkerFaceColor','m','MarkerSize',5);
    plot(cell2mat(a.daySummary.randCLicks(m,:)),'Color','c','LineWidth',2,'Marker','o','MarkerFaceColor','c','MarkerSize',5);
    plot(cell2mat(a.daySummary.randDLicks(m,:)),'Color','b','LineWidth',2,'Marker','o','MarkerFaceColor','b','MarkerSize',5);
    plot([a.reverseDay(m)-0.5 a.reverseDay(m)-0.5],[-10000000 1000000],'k','yliminclude','off','xliminclude','off','LineWidth',4);        
    ylabel({'Anticipatory', 'lick rate'});
%     xlabel('Day');
    leg = legend(ax,'Info-Rew','Info-No Rew','No Info - C','No Info - D','Location','best','Orientation','horizontal');
    leg.Box = 'off';
    leg.FontWeight = 'bold';
    hold off;
    
    ax = nsubplot(4,2,1,2);
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
    ylabel({'Post-outcome', 'lick rate'});
%     xlabel('Day');
    leg = legend(ax,'Info-Rew','Info-No Rew','No Info - Rew','No Info - No Rew','Location','best','Orientation','horizontal');
    leg.Box = 'off';
    leg.FontWeight = 'bold';
    hold off;
    
    ax = nsubplot(4,2,2,2);
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
    ylabel({'Mean Reward', '(uL)'});
%     xlabel('Day');
    leg = legend(ax,'Info-Rew','Info-No Rew','No Info - C','No Info - D','Location','best','Orientation','horizontal');
    leg.Box = 'off';
    leg.FontWeight = 'bold';
    hold off;
    
    ax = nsubplot(4,2,3,2);
    ax.FontSize = 10;
    ax.XTick = [0:5:max(cell2mat(a.daySummary.day(m,:)))];
    ax.YLim = [6000 10000];
    plot(cell2mat(a.daySummary.trialLengthInfoForced(m,:)),'Color',orange,'LineWidth',2,'Marker','o','MarkerFaceColor',orange,'MarkerSize',5);
    plot(cell2mat(a.daySummary.trialLengthInfoChoice(m,:)),'Color',orange,'LineWidth',2,'Marker','o','MarkerFaceColor',orange,'MarkerSize',5,'LineStyle',':');
    plot(cell2mat(a.daySummary.trialLengthRandForced(m,:)),'Color',purple,'LineWidth',2,'Marker','o','MarkerFaceColor',purple,'MarkerSize',5);
    plot(cell2mat(a.daySummary.trialLengthRandChoice(m,:)),'Color',purple,'LineWidth',2,'Marker','o','MarkerFaceColor',purple,'MarkerSize',5,'LineStyle',':');
    plot([a.reverseDay(m)-0.5 a.reverseDay(m)-0.5],[-10000000 1000000],'k','yliminclude','off','xliminclude','off','LineWidth',4);
    ylabel({'Trial', 'duration (ms)'});
%     xlabel('Day');
    leg = legend(ax,'Info Forced','Info Choice','No Info Forced','No Info Choice','Location','best','Orientation','horizontal');
    leg.Box = 'off';
    leg.FontWeight = 'bold';
    hold off;

    ax = nsubplot(4,2,4,2);
    ax.FontSize = 10;
    ax.XTick = [0:5:max(cell2mat(a.daySummary.day(m,:)))];
    ax.YLim = [0 0.5];
    plot(cell2mat(a.daySummary.rewardRateInfoForced(m,:)),'Color',orange,'LineWidth',2,'Marker','o','MarkerFaceColor',orange,'MarkerSize',5);
    plot(cell2mat(a.daySummary.rewardRateInfoChoice(m,:)),'Color',orange,'LineWidth',2,'Marker','o','MarkerEdgeColor',orange,'MarkerFaceColor','w','MarkerSize',5,'LineStyle',':');
    plot(cell2mat(a.daySummary.rewardRateRandForced(m,:)),'Color',purple,'LineWidth',2,'Marker','o','MarkerFaceColor',purple,'MarkerSize',5);
    plot(cell2mat(a.daySummary.rewardRateRandChoice(m,:)),'Color',purple,'LineWidth',2,'Marker','o','MarkerEdgeColor',purple,'MarkerFaceColor','w','MarkerSize',5,'LineStyle',':');
    plot([a.reverseDay(m)-0.5 a.reverseDay(m)-0.5],[-10000000 1000000],'k','yliminclude','off','xliminclude','off','LineWidth',4);
    ylabel({'Reward', 'Rate'});
    xlabel('Day');    
    leg = legend(ax,'Info Forced','Info Choice','No Info Forced','No Info Choice','Location','best','Orientation','horizontal');
    leg.Box = 'off';
    leg.FontWeight = 'bold';
    hold off;
end

%% PLOT OUTCOMES BY MOUSE

% for m = 1:a.mouseCt
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
% end

% for m=1:a.mouseCt 
%     [outcomeCounts(m,:),outcomeBins(m,:)] = histcounts(a.daySummary.outcome{m,d},[0.5:1:17.5],'Normalization','probability');
% end


%% PLOT MOST RECENT DAY'S LICKS
%     
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

%% LICK HISTOGRAMS / BINS BY DAY AND MOUSE
% 
% PLOT BY MOUSE AND DAY

% 
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

%%
for m = 1:a.mouseCt
    plotData = cell2mat(a.lickProbDays(:,:,m));
    
    figure();
    hold on;
    
    if a.mouseDayCt(m) > 3
        CT = cbrewer('seq', 'Blues', a.mouseDayCt(m));
    else
        CT = ([0.419607843137255,0.682352941176471,0.839215686274510; 0.0313725490196078,0.188235294117647,0.419607843137255]);
    end
    
    for lp = 1:4            
        ax = nsubplot(4,1,lp,1);
        colormap(CT);
        if lp == 1
            title([char(a.mouseList{m}) ': Licks per Trial']);
        end
        ax.FontSize = 12;
        xlim([0,a.maxBin*a.win]);
        ylim([0,0.75]);
        for d = 1:a.mouseDayCt(m) 
            plot(bins,plotData((a.mouseDayCt(m)*(lp-1))+d,:),'color',CT(d,:))
        end
        plot(a.odorWait*[1 1],[0 100],'k','yliminclude','off');
        plot((a.odorWait+200)*[1 1],[0 100],'k','yliminclude','off');
        plot((a.rewardWait+100)*[1 1],[0 100],'k','yliminclude','off');
        plot(a.rewardWait*[1 1],[0 100],'k','yliminclude','off');
        if lp == 4
            xlabel('Time from go cue');
%             colorbar('southoutside')
        end
        ylabel(a.typeNames(lp));
        hold off;
    end
end