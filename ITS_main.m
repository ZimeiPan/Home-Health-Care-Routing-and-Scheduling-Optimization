clc
clear 
close all
%% Hybrid Taboo Search Algorithmic Logic for Multi-Cycle Models
T_max = 90;   

instance = Reader();

%% Parameter
IniTabu1Tenure = 10;
IniTabu2Tenure = 5;
Tabu1Tenure = 10;    
Tabu2Tenure = 5;
OuterIterMax = 30;  
InnerIterMax = 30;  
ShakingIterMax = 50; 
Tabu1 = {};     

% Initial solution construction
schedule = robustFunction(@Construction,instance);

% Calculation of the objective function
scheduleObj = calculateObjective(instance,schedule);

%% Tabu algorithm main logic
best_Schedule = schedule;
best_Cost = scheduleObj;

current_Schedule = schedule;
current_Cost = scheduleObj;

SolutionSpace = {};
SolutionObj = []; 
no_worker = [];   

SolutionSpace{end+1} = best_Schedule;
SolutionObj(end+1) = best_Cost;

disp(['Outer layer iteration ' num2str(0) ': Best Cost = ' num2str(best_Cost)]);

%% primary cycle
tStart = tic;
for iteration = 1 : OuterIterMax
    
    %% 1. Iteration based on patient service time exchange operator
    SolutionSet = PatientServiceTimeShiftLS2(instance,current_Schedule);  
    
    PatientServiceTimeShiftLS_Schedule = SolutionSet{1}{2};
    PatientServiceTimeShiftLS_Cost = SolutionSet{1}{3};
    
    %[Amnesty guidelines]
    if PatientServiceTimeShiftLS_Cost < best_Cost   
       
        current_Schedule = PatientServiceTimeShiftLS_Schedule; 
        current_Cost = PatientServiceTimeShiftLS_Cost;

    
        best_Schedule = PatientServiceTimeShiftLS_Schedule;
        best_Cost = PatientServiceTimeShiftLS_Cost;
        
        %% Contraindications table updated
        insertone = SolutionSet{1}{1};  % [Patient,d1,d2]
       
        for i = 1 : size(Tabu1,2)
            if isequal(Tabu1{i},insertone)
                Tabu1(i) = [];  
                break; 
            end
        end
        Tabu1Tenure = Tabu1Tenure + 1; 
    else

        if numel(SolutionSet) >= 2
            index = 2;   
            tabuflag = 0; 
            for i = 2 : numel(SolutionSet) 
                if ~isinTabu(SolutionSet{i}{1},Tabu1)
                    index = i;
                    tabuflag = 1;
                    break;
                end
            end
            if tabuflag ~= 0 
              
                current_Schedule = SolutionSet{index}{2};
                current_Cost = SolutionSet{index}{3};
                insertone = SolutionSet{index}{1};
            else 
            
                current_Schedule = SolutionSet{1}{2};
                current_Cost = SolutionSet{1}{3};
                insertone = SolutionSet{1}{1};
                for i = 1 : size(Tabu1,2)
                    if isequal(Tabu1{i},insertone)
                        Tabu1(i) = [];  
                        break; 
                    end
                end
            end
        else
       
            current_Schedule = SolutionSet{1}{2};
            current_Cost = SolutionSet{1}{3};
            insertone = SolutionSet{1}{1};
            for i = 1 : size(Tabu1,2)
                if isequal(Tabu1{i},insertone)
                    Tabu1(i) = []; 
                    break; 
                end
            end
        end
        Tabu1Tenure = Tabu1Tenure - 1; 
    end
    %% Contraindications table updated
    if Tabu1Tenure < 0
        Tabu1Tenure = IniTabu1Tenure;
    end
    Tabu1{end+1} = insertone;
    newTabu = {};
    if numel(Tabu1) > Tabu1Tenure
        for i = 1 : Tabu1Tenure
            newTabu(i) = Tabu1(1+i);
        end
        Tabu1 = newTabu;
    end
    current_Schedule = removeEmptySchedule(instance,current_Schedule);
    
    %% Optimize scheduling for the two days when changes occur
    PatientID = insertone(1); 
    day1 = insertone(2);  
    day1ServiceModel = instance.patinetServiceModel(PatientID,day1);  
    day2 = insertone(3);  
    day2ServiceModel = instance.patinetServiceModel(PatientID,day2);  
    dayUpdate = [day1,day2];
    dayUpdateServiceModel = [day1ServiceModel,day2ServiceModel];
    
    %% Updates to the two-day solution
    for i = 1 : 2 
        currentDay = dayUpdate(i);
        currentDayServiceModel = dayUpdateServiceModel(i);
        % Each day's traversal is a new table of taboos.
        Tabu_2c = {};
        Tabu2Tenure = IniTabu2Tenure;
        %% Internal taboo table
        for iteration2 = 1 : InnerIterMax  
        
            [flag,Inner_SolutionSet] = InnerTabuSerch(instance,current_Schedule,currentDay,currentDayServiceModel);
            
            if ~isempty(Inner_SolutionSet)
             
                Inner_Schedule = Inner_SolutionSet{1}{2}; 
                Inner_Cost = Inner_SolutionSet{1}{3}; 

                if Inner_Cost < best_Cost  
                
                    current_Schedule{currentDay} = Inner_Schedule{currentDay};
                    current_Cost = Inner_Cost;
              
                    best_Schedule = Inner_Schedule;
                    best_Cost = Inner_Cost;
            
                    insertone = Inner_SolutionSet{1}{3};
                 
                    for j = 1 : numel(Tabu_2c)
                        if isequal(Tabu_2c{j},insertone)
                            Tabu_2c(j) = []; 
                            break; 
                        end
                    end
                    Tabu2Tenure = Tabu2Tenure + 1;
                else  
                    %% Find an unbanned solution from the candidate set.
                    inner_index = 2;    
                    inner_tabuflag = 0; 
                    for j = 2 : numel(Inner_SolutionSet) 
                        if ~isinTabu(Inner_SolutionSet{j}{3},Tabu_2c) 
                            inner_index = j;
                            inner_tabuflag = 1;
                            break; 
                        end
                    end
                    if inner_tabuflag ~= 0 
                     
                        current_Schedule{currentDay} = Inner_SolutionSet{inner_index}{2}{currentDay};
                        current_Cost = Inner_SolutionSet{inner_index}{3}; 
              
                        insertone = Inner_SolutionSet{inner_index}{3};
                    else
                        current_Schedule{currentDay} = Inner_Schedule{currentDay};
                        current_Cost = Inner_Cost;

                        insertone = Inner_Cost;
                        for j = 1 : numel(Tabu_2c)
                            if isequal(Tabu_2c{j},insertone)
                                Tabu_2c(j) = []; 
                                break; 
                            end
                        end
                    end
                    Tabu2Tenure = Tabu2Tenure - 1;
                end
                if Tabu2Tenure < 0
                    Tabu2Tenure = IniTabu2Tenure;
                end
                Tabu_2c{end+1} = insertone;
                newTabu = {};
                if numel(Tabu_2c) > Tabu2Tenure
                    for j = 1 : Tabu2Tenure
                        newTabu(j) = Tabu_2c(1+j);
                    end
                    Tabu_2c = newTabu;
                end
      
                current_Schedule = removeEmptySchedule(instance,current_Schedule);
            end
            disp(['number of days:' num2str(i) 'Inner iteration:' num2str(iteration2) 'optimum value：' num2str(best_Cost)]);
        end
    end    

    if current_Cost < best_Cost  
        best_Schedule = current_Schedule;
        best_Cost = current_Cost;
    end

    %% Perturbation - Tabu threshold with restart policy
    [current_Schedule,best_Schedule,best_Cost] = shakingV5(instance,current_Schedule,best_Schedule,best_Cost,ShakingIterMax);  
    
    %% Remove empty routes from currentSchedule
    current_Schedule = removeEmptySchedule(instance,current_Schedule);
    SolutionSpace{end+1} = best_Schedule;
    SolutionObj(end+1) = best_Cost;  
    disp(['Outer iteration ' num2str(iteration) ': Best Cost = ' num2str(best_Cost)]);

    timeEnd = toc(tStart);
    if timeEnd > T_max
        break;
    end
end

%% output
disp([': Best Cost = ' num2str(best_Cost)]);
timeEnd = toc(tStart);

%% Skill level deviation
save('Sensitivity analysis/skill level deviation sensitivity analysis_2.mat',"SolutionSpace","SolutionObj","timeEnd","best_Schedule","best_Cost");
