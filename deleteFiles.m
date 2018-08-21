b=a;


clear a;
newTotal = 136223;
newCorr = 123374;
newFiles = 909;
fileCutoff = 910;

ok = b.file <= newFiles;
okAll=b.fileAll <= newFiles;
idx = 1:b.numFiles;
okFiles=idx <= newFiles;
okFileIdx = find(okFiles);


a.trialNums = b.trialNums(1:newTotal);
a.trialStart = b.trialStart(okFiles,:);
a.fileAll = b.fileAll(1:newTotal);
a.images=b.images(b.images(:,1)<fileCutoff,:);

a.txn0_1 = b.txn0_1(b.txn0_1(:,1)<fileCutoff,:);
a.txn1_2 = b.txn1_2(b.txn1_2(:,1)<fileCutoff,:);
a.txn2_3 = b.txn2_3(b.txn2_3(:,1)<fileCutoff,:);
a.txn3_4 = b.txn3_4(b.txn3_4(:,1)<fileCutoff,:);
a.txn4_5 = b.txn4_5(b.txn4_5(:,1)<fileCutoff,:);
a.txn5_6 = b.txn5_6(b.txn5_6(:,1)<fileCutoff,:);
a.txn6_7 = b.txn6_7(b.txn6_7(:,1)<fileCutoff,:);
a.txn7_8 = b.txn7_8(b.txn7_8(:,1)<fileCutoff,:);
a.txn8_9 = b.txn8_9(b.txn8_9(:,1)<fileCutoff,:);
a.txn9_11 = b.txn9_11(b.txn9_11(:,1)<fileCutoff,:);
a.txn9_10 = b.txn9_10(b.txn9_10(:,1)<fileCutoff,:);
a.txn10_12 = b.txn10_12(b.txn10_12(:,1)<fileCutoff,:);
a.txn11_12 = b.txn11_12(b.txn11_12(:,1)<fileCutoff,:);
a.txn12_13 = b.txn12_13(b.txn12_13(:,1)<fileCutoff,:);
a.txn13_14 = b.txn13_14(b.txn13_14(:,1)<fileCutoff,:);
a.txn14_15 = b.txn14_15(b.txn14_15(:,1)<fileCutoff,:);
a.txn15_0 = b.txn15_0(b.txn15_0(:,1)<fileCutoff,:);
a.txn4_3 = b.txn4_3(b.txn4_3(:,1)<fileCutoff,:);
a.txn5_3 = b.txn5_3(b.txn5_3(:,1)<fileCutoff,:);
a.txn6_3 = b.txn6_3(b.txn6_3(:,1)<fileCutoff,:);
a.txn10_11 = b.txn10_11(b.txn10_11(:,1)<fileCutoff,:);
a.txn11_10 = b.txn11_10(b.txn11_10(:,1)<fileCutoff,:);
a.txn11_16 = b.txn11_16(b.txn11_16(:,1)<fileCutoff,:);
a.txn10_16 = b.txn10_16(b.txn10_16(:,1)<fileCutoff,:);
a.txn16_15 = b.txn16_15(b.txn16_15(:,1)<fileCutoff,:);

a.centerEntries = b.centerEntries(b.centerEntries(:,1)<fileCutoff,:);
a.goCue = b.goCue(okAll,:);
a.goParams = b.goParams(b.goParams(:,1)<fileCutoff,:);
a.chose=b.chose(okAll);
a.choseTrialCt = b.choseTrialCt(okFiles);
a.choice = b.choice(okAll,:);
a.choiceTime = b.choiceTime(okAll);
a.correct = b.correct(okAll);
a.corrTrialCt = b.corrTrialCt(okFiles);
a.corrTrials=b.corrTrials(ok);
a.file=b.file(ok);
a.choiceCorr=b.choiceCorr(ok);
a.rxn=b.rxn(okAll);
a.centerOdorOn = b.centerOdorOn(b.centerOdorOn(:,1)<fileCutoff,:);
a.centerOdorOff = b.centerOdorOff(b.centerOdorOff(:,1)<fileCutoff,:);
a.sideOdorOn = b.sideOdorOn(b.sideOdorOn(:,1)<fileCutoff,:);
a.sideOdorOff = b.sideOdorOff(b.sideOdorOff(:,1)<fileCutoff,:);
a.centerEntryGo=b.centerEntryGo(okAll,:);
a.centerExitGo=b.centerExitGo(okAll,:);
a.centerEntryCt=b.centerEntryCt(okAll,:);
a.centerOdorOnGo=b.centerOdorOnGo(okAll,:);
a.firstCenterEntryTxn=b.firstCenterEntryTxn(okAll);
a.firstCenterEntry=b.firstCenterEntry(b.firstCenterEntry(:,1)<fileCutoff,:);
a.centerDwell=b.centerDwell(okAll,:);
a.rewardEntries=b.rewardEntries(b.rewardEntries(:,1)<fileCutoff,:);
a.rewardEntriesCorr=b.rewardEntriesCorr(b.rewardEntriesCorr(:,1)<fileCutoff,:);
a.trialParams=b.trialParams(b.trialParams(:,1)<fileCutoff,:);

a.bigRewards=b.bigRewards(b.bigRewards(:,1)<fileCutoff,:);
a.smallRewards=b.smallRewards(b.smallRewards(:,1)<fileCutoff,:);

a.infoBigRewards = b.infoBigRewards(b.infoBigRewards(:,1)<fileCutoff,:);
a.infoSmallRewards = b.infoSmallRewards(b.infoSmallRewards(:,1)<fileCutoff,:);
a.randBigRewards = b.randBigRewards(b.randBigRewards(:,1)<fileCutoff,:);
a.randSmallRewards = b.randSmallRewards(b.randSmallRewards(:,1)<fileCutoff,:);
a.infoBigRewardCt = b.infoBigRewardCt(okFiles);
a.infoSmallRewardCt = b.infoSmallRewardCt(okFiles);
a.randBigRewardCt = b.randBigRewardCt(okFiles);
a.randSmallRewardCt = b.randSmallRewardCt(okFiles);
a.rewardCts = b.rewardCts(okFiles);
a.infoBigRewardTime = b.infoBigRewardTime(okFiles);
a.infoSmallRewardTime = b.infoSmallRewardTime(okFiles);
a.randBigRewardTime = b.randBigRewardTime(okFiles);
a.randSmallRewardTime = b.randSmallRewardTime(okFiles);
a.infoBigReward = b.infoBigReward(okFiles);
a.infoSmallReward = b.infoSmallReward(okFiles);
a.randBigReward = b.randBigReward(okFiles);
a.randSmallReward = b.randSmallReward(okFiles);
a.rewardAmount = b.rewardAmount(okFiles);
a.rewarded=b.rewarded(okAll);
a.infoBig = b.infoBig(okAll);
a.infoSmall = b.infoSmall(okAll);
a.randBig = b.randBig(okAll);
a.randSmall = b.randSmall(okAll);
a.reward=b.reward(okAll);
a.rewardCorr = b.rewardCorr(ok);
a.waterOn=b.waterOn(b.waterOn(:,1)<fileCutoff,:);
a.waterOff=b.waterOff(b.waterOff(:,1)<fileCutoff,:);
a.trialLength=b.trialLength(okAll);
a.trialLengthCenterEntry=b.trialLengthCenterEntry(okAll);
a.trialLengthTotal=b.trialLengthTotal(okAll);
a.choiceType=b.choiceType(okAll);
a.choiceTrials=b.choiceTrials(okAll);
a.infoForced=b.infoForced(okAll);
a.randForced=b.randForced(okAll);
a.choiceTypeCorr=b.choiceTypeCorr(ok);
a.type=b.type(ok);
a.outcome=b.outcome(okAll);
a.finalOutcome=b.finalOutcome(okAll);
a.licks=b.licks(b.licks(:,1)<fileCutoff,:);
a.corrLicks=b.corrLicks(b.corrLicks(:,1)<fileCutoff,:);
a.lickCt=b.lickCt(ok);
a.anticipatoryLicks=b.anticipatoryLicks(ok);
a.earlyLicks = b.earlyLicks(ok);
a.waterLicks = b.waterLicks(ok);
a.rewardPortTime = [];
a.betweenLicks = b.betweenLicks(ok);
a.allLickCt = b.allLickCt(ok);

a.trialCts = b.trialCts(okFiles);
a.mouse=b.mouse(ok);
a.mouseAll=b.mouseAll(okAll);
a.files=b.files(okFiles);
a.numFiles=sum(okFiles);

for p = 1:sum(okFiles)
   pp = okFileIdx(p);
   for r = 1:size(b.parameters,2)
      a.parameters{p,r} = b.parameters{pp,r}; 
   end
end


uisave({'a'},'infoSeekFSMData.mat');