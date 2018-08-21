% TO DELETE A FILE

% fd = file number to delete

% a struct has new deleted data, b has original

% a.deletedFiles = [b.deletedFiles; b.files(fd).name];

ok=b.file~=311;
okAll=b.fileAll~=311;
idx = 1:b.numFiles;
okIdx=idx~=311;

% relevant to file nums:
% choseTrialCt
% corrTrialCt
% bigRewardCt
% smallRewardCt
% rewardCts
% bigRewardTime
% smallRewardTime
% bigReward
% smallReward
% rewardAmount
% parameters
% trialCts
% files
% numFiles

a.trialNums = b.trialNums(okAll);
a.trialStart = b.trialStart(okAll,:);
a.fileAll = b.fileAll(okAll);
a.images = b.images(b.images(:,1)~=311,:);

a.txn0_1 = b.txn0_1(b.txn0_1(:,1)~=311,:);
a.txn1_2 = b.txn1_2(b.txn1_2(:,1)~=311,:);
a.txn2_3 = b.txn2_3(b.txn2_3(:,1)~=311,:);
a.txn3_4 = b.txn3_4(b.txn3_4(:,1)~=311,:);
a.txn4_5 = b.txn4_5(b.txn4_5(:,1)~=311,:);
a.txn5_6 = b.txn5_6(b.txn5_6(:,1)~=311,:);
a.txn6_7 = b.txn6_7(b.txn6_7(:,1)~=311,:);
a.txn7_8 = b.txn7_8(b.txn7_8(:,1)~=311,:);
a.txn8_9 = b.txn8_9(b.txn8_9(:,1)~=311,:);
a.txn9_11 = b.txn9_11(b.txn9_11(:,1)~=311,:);
a.txn9_10 = b.txn9_10(b.txn9_10(:,1)~=311,:);
a.txn10_11 = b.txn10_11(b.txn10_11(:,1)~=311,:);
a.txn11_12 = b.txn11_12(b.txn11_12(:,1)~=311,:);
a.txn12_13 = b.txn12_13(b.txn12_13(:,1)~=311,:);
a.txn13_14 = b.txn13_14(b.txn13_14(:,1)~=311,:);
a.txn14_15 = b.txn14_15(b.txn14_15(:,1)~=311,:);
a.txn15_0 = b.txn15_0(b.txn15_0(:,1)~=311,:);
a.txn4_3 = b.txn4_3(b.txn4_3(:,1)~=311,:);
a.txn5_3 = b.txn5_3(b.txn5_3(:,1)~=311,:);
a.txn6_3 = b.txn6_3(b.txn6_3(:,1)~=311,:);
a.txn10_12 = b.txn10_12(b.txn10_12(:,1)~=311,:);
a.txn11_10 = b.txn11_10(b.txn11_10(:,1)~=311,:);
a.txn11_16 = b.txn11_16(b.txn11_16(:,1)~=311,:);
a.txn10_16 = b.txn10_16(b.txn10_16(:,1)~=311,:);
a.txn16_15 = b.txn16_15(b.txn16_15(:,1)~=311,:);

a.centerEntries = b.centerEntries(b.centerEntries(:,1)~=311,:);
a.goCue = b.goCue(okAll,:);
a.goParams = b.goParams(b.goParams(:,1)~=311,:);
a.chose=b.chose(okAll);
a.choseTrialCt = b.choseTrialCt;
a.choseTrialCt(311) = NaN;
a.choice = b.choice(okAll,:);
a.choiceTime = b.choiceTime(okAll);
a.correct = b.correct(okAll);
a.corrTrialCt = b.corrTrialCt;
a.corrTrialCt(311) = NaN;
a.corrTrials=b.corrTrials(ok);
a.file=b.file(ok);
a.choiceCorr=b.choiceCorr(ok);
a.rxn=b.rxn(okAll);
a.centerEntryGo=b.centerEntryGo(okAll,:);
a.centerExitGo=b.centerExitGo(okAll,:);
a.centerEntryCt=b.centerEntryCt(okAll,:);
a.firstCenterEntryTxn=b.firstCenterEntryTxn(okAll);
a.centerDwell=b.centerDwell(okAll,:);
a.rewardEntries=b.rewardEntries(b.rewardEntries(:,1)~=311,:);
a.rewardEntriesCorr=b.rewardEntriesCorr(b.rewardEntriesCorr(:,1)~=311,:);
a.centerOdorOn = b.centerOdorOn(b.centerOdorOn(:,1)~=311,:);
a.centerOdorOff = b.centerOdorOff(b.centerOdorOff(:,1)~=311,:);
a.sideOdorOn = b.sideOdorOn(b.sideOdorOn(:,1)~=311,:);
a.sideOdorOff = b.sideOdorOff(b.sideOdorOff(:,1)~=311,:);
a.trialParams=b.trialParams(b.trialParams(:,1)~=311,:);
a.bigRewards=b.bigRewards(b.bigRewards(:,1)~=311,:);
a.smallRewards=b.smallRewards(b.smallRewards(:,1)~=311,:);
a.bigRewardCt = b.bigRewardCt;
a.bigRewardCt(311) = NaN;
a.smallRewardCt = b.smallRewardCt;
a.smallRewardCt(311) = NaN;
a.rewardCts = b.rewardCts;
a.rewardCts(311) = NaN;
a.bigRewardTime = b.bigRewardTime;
a.bigRewardTime(311) = NaN;
a.smallRewardTime = b.smallRewardTime;
a.smallRewardTime(311) = NaN;
a.bigReward = b.bigReward;
a.bigReward(311) = NaN;
a.smallReward = b.smallReward;
a.smallReward(311) = NaN;
a.rewardAmount = b.rewardAmount;
a.rewardAmount(311) = NaN;
a.rewarded=b.rewarded(okAll);
a.big=b.big(okAll);
a.small=b.small(okAll);
a.reward=b.reward(ok);
a.waterOn=b.waterOn(b.waterOn(:,1)~=311,:);
a.waterOff=b.waterOff(b.waterOff(:,1)~=311,:);
a.trialLength=b.trialLength(okAll);
a.trialLengthEntry=b.trialLengthEntry(okAll);
a.trialLengthTotal=b.trialLengthTotal(okAll);
a.choiceType=b.choiceType(okAll);
a.choiceTrials=b.choiceTrials(okAll);
a.infoForced=b.infoForced(okAll);
a.randForced=b.randForced(okAll);
a.choiceTypeCorr=b.choiceTypeCorr(ok);
a.type=b.type(ok);
a.outcome=b.outcome(okAll);
a.licks=b.licks(b.licks(:,1)~=311,:);
a.corrLicks=b.corrLicks(b.corrLicks(:,1)~=311,:);
a.lickCt=b.lickCt(ok);
a.anticipatoryLicks=b.anticipatoryLicks(ok);
a.earlyLicks = b.earlyLicks(ok);
a.waterLicks = b.waterLicks(ok);
a.rewardPortTime = [];
a.betweenLicks = b.betweenLicks(ok);
a.allLickCt = b.allLickCt(ok);
a.parameters = b.parameters;

a.trialCts = b.trialCts;
a.trialCts(1,311) = NaN;
a.mouse=b.mouse(ok);
a.mouseAll=b.mouseAll(okAll);
a.files=b.files;
a.numFiles=b.numFiles;
a.firstCenterEntry=b.firstCenterEntry(okAll,:);

a.deletedFiles = 311;
a.fileIdx = unique(a.file);
a.numFilesPostDel = numel(a.fileIdx);

uisave({'a'},'infoSeekFSMData.mat');