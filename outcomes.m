%% outcomes

all trials

info
    big received
    big NP
    small received
    small NP
    no choice
    incorrect
    
    a.choiceType - 1 = choice, 2 = info, 3 = rand
    a.choice 2 = no choice, 1 = info, 0 = rand
    a.big
    a.small
    else not present
        
    whether big or small is a.rewardAssigned

    b.bigRewards = actually getting big reward
        
check what a.reward is! and a.choice! a.choiceCorr = 0 or 1 for info or rand but no no choice vs incorrect!!
get reward entries!!


%% PreFSM

reward = 1 when big actually given, 0 for all others
a.portChoiceAll (allTrials 11) 1, 3, 0 info, rand incorrect!
a.trialTypeAll = allTrials(:,4);
a.rewardSize only for correct, (allCorrTrials 14) TRIAL PARAMS
a.info only for correct
a.complete--present!

%% Post FSM
choiceType
choice
a.rewardAssigned = [b.trialParams(:,5); c.rewardSize]; ONLY FOR CORRECT
bigRewards, smallRewards

%% OUTCOMES OF FSM TRIALS

a.finalOutcome = zeros(numel(a.FSMall),1);
a.choiceTypeFSM = a.choiceType(a.FSMall);
a.rewardAssignedFSM = a.rewardAssigned(a.FSMall);
a.bigFSM = a.big(a.FSMall);
a.smallFSM=a.small(a.FSMall);

%% OUTCOMES OF ALL TRIALS

a.choiceType = [b.choiceType; c.trialTypeAll];
a.choice = [b.choice; c.portChoiceAll]; %1,0,2 and then 1,3,0 (0 = incorrect)
a.choiceCorr =info, random, 
a.rewardAssigned (big or small, only for correct)
a.rewarded = [b.rewarded; c.complete];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% REAL

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% 
a.corrIdx = NaN(numel(a.fileAll),1);

for t = 1:numel(a.fileAll)
    if ~isempty(find(a.file == a.fileAll(t) & a.trial == a.trialAll(t)))
    a.corrIdx(t,1) = find(a.file == a.fileAll(t) & a.trial == a.trialAll(t));
    end
end

%%

% 

a.finalOutcome = NaN(numel(a.fileAll),1);

for t = 1:size(a.fileAll,1)
    % choice 1 = info, 0 = rand, 3 = wrong, 2 = no choice
    
    if a.FSMall(t) == 1
        if ~isempty(find(a.file == a.fileAll(t) & a.trial == a.trialAll(t)))
            corrIdx = find(a.file == a.fileAll(t) & a.trial == a.trialAll(t));
        end
        % CHOICE TRIALS
        if a.choiceType(t) == 1
            % NO CHOICE
            if a.choice(t) == 2
                a.finalOutcome(t,1) = 1; % choice no choice;
            % INFO    
            elseif a.choice(t) == 1
                % BIG
                if a.rewardAssigned(corrIdx) == 1
                    if a.rewarded(t) == 1
                        a.finalOutcome(t,1) = 2; % choice info big
                    else a.finalOutcome(t,1) = 3; % choice info big NP
                    end
                % SMALL
                elseif a.rewardAssigned(corrIdx) == 0
                    if a.rewarded(t) == 1
                        a.finalOutcome(t,1) = 4; % choice info small
                    else a.finalOutcome(t,1) = 5; % choice info small NP
                    end
                end
            % RANDOM
            elseif a.choice(t) == 0
                % BIG
                if a.rewardAssigned(corrIdx) == 1
                    if a.rewarded(t) == 1
                        a.finalOutcome(t,1) = 6; % choice rand big
                    else a.finalOutcome(t,1) = 7; % choice rand big NP
                    end
                % SMALL
                elseif a.rewardAssigned(corrIdx) == 0
                    if a.rewarded(t) == 1
                        a.finalOutcome(t,1) = 8; % choice rand small
                    else a.finalOutcome(t,1) = 9; % choice rand small NP
                    end
                end
            end

        % INFO TRIALS
        elseif a.choiceType(t) == 2
            % NO CHOICE
            if a.choice(t) == 2
                a.finalOutcome(t,1) = 10; % info no choice;  
            % CORRECT
            elseif a.choice(t) == 1
                % BIG
                if a.rewardAssigned(corrIdx) == 1
                    if a.rewarded(t) == 1
                        a.finalOutcome(t,1) = 11; % info big
                    else a.finalOutcome(t,1) = 12; % info big NP
                    end
                % SMALL
                elseif a.rewardAssigned(corrIdx) == 0
                    if a.rewarded(t) == 1
                        a.finalOutcome(t,1) = 13; % info small
                    else a.finalOutcome(t,1) = 14; % info small NP
                    end
                end
            % INCORRECT
            else %a.choice(t) == 3 
                a.finalOutcome(t,1) = 15; % info incorrect (went rand)
            end

        % RAND TRIALS
        elseif a.choiceType(t) == 3
            % NO CHOICE
            if a.choice(t) == 2
                a.finalOutcome(t,1) = 16; % rand no choice;  
            % CORRECT
            elseif a.choice(t) == 0
                % BIG
                if a.rewardAssigned(corrIdx) == 1
                    if a.rewarded(t) == 1
                        a.finalOutcome(t,1) = 17; % rand big
                    else a.finalOutcome(t,1) = 18; % rand big NP
                    end
                % SMALL
                elseif a.rewardAssigned(corrIdx) == 0
                    if a.rewarded(t) == 1
                        a.finalOutcome(t,1) = 19; % rand small
                    else a.finalOutcome(t,1) = 20; % rand small NP
                    end
                end
            % INCORRECT
            else %a.choice(t) == 3 
                a.finalOutcome(t,1) = 21; % rand incorrect (went info)
            end
        end  
    end
end

        %% 
            
%% FOR OLD FILES, GETS DIFF CORRECT VALUES b/c portChoices are not correct

for f=1:b.numFiles
    fileInfoSide(f,1) = b.files(f).infoSide;
end

b.correct = NaN(numel(b.correctAll),1);
b.choices = NaN(numel(b.correctAll),1);

for t = 1:numel(b.correctAll)
    infoSide(t,1) = fileInfoSide(b.fileAll(t));
    if infoSide(t,1) == 0
        info = 1;
        rand = 3;
    else
        info = 3;
        rand = 1;
    end
    % CHOICE
    if b.trialTypeAll(t) == 1
        % NO CHOICE
        if b.portChoiceAll(t) == 0
            b.choices(t) = 2;
            b.correct(t) = 0;
            % INFO
        else if b.portChoiceAll(t) == info
                b.choices(t) = 1;
                b.correct(t) = 1;
            else
                b.choices(t) = 0;
                b.correct(t) = 1;
            end
        end
        % FORCED INFO
    else if b.trialTypeAll(t) == 2
            % No choice
        if b.portChoiceAll(t) == 0
            b.choices(t) = 2;
            b.correct(t) = 0;
            % INFo
        else if b.portChoiceAll(t) == info
                b.choices(t) = 1;
                b.correct(t) = 1;
            else
                b.choices(t) = 0;
                b.correct(t) = 0;
            end
        end
        else
            if b.portChoiceAll(t) == 0
                b.choices(t) = 2;
                b.correct(t) = 0;
            else if b.portChoiceAll(t) == rand
                b.choices(t) = 0;
                b.correct(t) = 1;
            else
                b.choices(t) = 1;
                b.correct(t) = 0;    
                end
            end
        end
    end
end


%% 
corrTrialNums = b.trialAll(b.correctAll==1);
corrFileNums = b.fileAll(b.correctAll==1);

for f = 1:b.numFiles
    fileCorrTrials = b.trial(b.file == f);
    fileAllTrials = b.trialAll(b.filesAll == f);
    fileTrialsByCorr
