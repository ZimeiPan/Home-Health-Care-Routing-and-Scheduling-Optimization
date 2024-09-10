%% Local Optimization Process - Based on Taboo Thresholds
% Perturbation with threshold restart policy
function [schedule,best_Schedule,best_Cost] = shakingV5(instance,current_schedule,best_Schedule,best_Cost,shakingIterMax)


    TabuThresholdMin = 0.10; 
    TabuThresholdMax = 0.14;
    
    %% Constructed fields
    Neighubour = [1,2,3,4,5,6,7,8,9,10];
    
    schedule = current_schedule;
    schedule_Obj = calculateObjective(instance,schedule);
    
    tourObj = 2000000; % The initial setting is larger
    
    day = 1; 
    for iter = 1 : shakingIterMax
    
        %% Threshold ratio selection
        r = TabuThresholdMin + (TabuThresholdMax-TabuThresholdMin)*rand;

        l = randperm(numel(Neighubour),1); % Choose an operator at random
        if l == 1 % Patient service time transformation operator
            SolutionSet = PatientServiceTimeShiftLS2(instance,schedule);
            if ~isempty(SolutionSet) 
                tour =  SolutionSet{1}{2};
                tourObj = SolutionSet{1}{3};
            end
        elseif l == 2 % Single-point relocation - door-to-door [Relocation]
            [relocateFlag,SolutionSet] = relocateRearch(instance,schedule,day,0);
            if  relocateFlag
                tour =  SolutionSet{1}{2};
                tourObj = SolutionSet{1}{3};
            end
        elseif l == 3 % Single-point relocation - online [Relocation].
            [relocateFlag,SolutionSet] = relocateRearch(instance,schedule,day,1);
            if relocateFlag
                tour =  SolutionSet{1}{2};
                tourObj = SolutionSet{1}{3};
            end
        elseif l == 4 % Single Point Relocation - Outpatient [Relocation]
            [relocateFlag,SolutionSet] = relocateRearch(instance,schedule,day,2);
            if  relocateFlag
                tour =  SolutionSet{1}{2};
                tourObj = SolutionSet{1}{3};
            end
        elseif l == 5 % Two-point exchange - door-to-door [Exchange calculator]
            [exchangeFlag,SolutionSet] = exchangeSearch(instance,schedule,day,0);
            if  exchangeFlag
                tour =  SolutionSet{1}{2};
                tourObj = SolutionSet{1}{3};
            end
        elseif l == 6 % Two-Point Exchange-Online [Exchange Calculator]
            [exchangeFlag,SolutionSet] = exchangeSearch(instance,schedule,day,1);
            if  exchangeFlag
                tour =  SolutionSet{1}{2};
                tourObj = SolutionSet{1}{3};
            end
        elseif l == 7 % Two Point Exchange - Outpatient [Exchange Calculator]
            [exchangeFlag,SolutionSet] = exchangeSearch(instance,schedule,day,2);
            if exchangeFlag
                tour =  SolutionSet{1}{2};
                tourObj = SolutionSet{1}{3};
            end
        elseif l == 8 % Subsequence exchange - door-to-door [CROSS operator].
            [crossFlag,SolutionSet] = crossSearch(instance,schedule,day,0);
            if  crossFlag
                tour =  SolutionSet{1}{2};
                tourObj = SolutionSet{1}{3};
            end
        elseif l == 9 % Subsequence exchange - online [CROSS operator]
            [crossFlag,SolutionSet] = crossSearch(instance,schedule,day,1);
            if  crossFlag
                tour =  SolutionSet{1}{2};
                tourObj = SolutionSet{1}{3};
            end
        elseif l == 10 % Medics exchange operators-change throughout the solution space
            [workerExchangeFlag,SolutionSet] = workerExchangeSearchV4(instance,schedule);

            if  workerExchangeFlag
                tour =  SolutionSet{1}{2};
                tourObj = SolutionSet{1}{3};
            end
        end
    
        %% acceptance strategy
        if (tourObj / schedule_Obj) < 1 + r
            tour = removeEmptySchedule(instance,tour); 
            
            schedule_Obj = tourObj;
            schedule = tour;
            
            %% better than the optimal solution
            if tourObj < best_Cost
                best_Schedule = tour;
                best_Cost = tourObj;
            end
        end
        
        disp(['perturbation iteration ' num2str(iter) ': Best Cost = ' num2str(best_Cost)]);
    
        day = day + 1;
        if day > instance.period 
            day = 1;
        end
    end
end
