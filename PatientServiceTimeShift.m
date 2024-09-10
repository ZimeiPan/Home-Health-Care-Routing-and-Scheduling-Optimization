%% Patient service time conversion operator
% Function: After the patient receives the service time change, the optimal solution of the exchange is saved after the optimal insertion is performed

function [flag,NewSchedule] = PatientServiceTimeShift(instance,schedule,PatientID,yijiesou,weijiesou,ptwMatrix,ScheduleObj)
    %% Default Return Value
    flag = true; 
    NewSchedule = {}; 
    
    SolutionSet = {};

    tempSchedule = schedule; 
    
    % Performs patient service time change operations
    %% 1. Remove
    delDay = yijiesou(1); 
    delDayServiceMode = yijiesou(2);
    delDaySchedule = schedule{delDay};
    
    delDayScheduleModel = delDaySchedule{delDayServiceMode+1};
    NewDelDayScheduleModel = {};
    
    %% Judged on the basis of the service mode
    
    if delDayServiceMode == 0 || delDayServiceMode == 1
 
        index = 1;  
        for i = 1 : numel(delDayScheduleModel) 
            routePart2 = delDayScheduleModel{i}{2}; 
            
            if ismember(PatientID,routePart2)  
                idx = (routePart2 == PatientID); 
                routePart2(idx) = [];
                index = i;  
                delDayScheduleModel{index}{2} = routePart2;
                break; 
            end
        end
        
        % Determine whether the multiple time window constraint is satisfied after deleting this patient
        [multiFlag,~] = RouteDurationCheckerV2(instance,delDayScheduleModel{index}{1},delDayScheduleModel{index}{2},delDay);
        if multiFlag  

            BeforeTour1 = calculateSingelDay(instance,schedule{delDay}{delDayServiceMode+1}{index},delDay);   
            AfterTour1 = calculateSingelDay(instance,delDayScheduleModel{index},delDay); 

            Tour1WorkerID = delDayScheduleModel{index}{1}(1); 
  
            [Cost1,ptwMatrix] = ServiceNum2(ptwMatrix,Tour1WorkerID,PatientID,1); 
            CostPart2 = instance.serviceContinuityWeight * Cost1;
            DelCostChange = (AfterTour1 - BeforeTour1) + CostPart2;
        else
      
            flag = false; 
            return;        
        end

        for i= 1 : numel(delDayScheduleModel)  
            if numel(delDayScheduleModel{i}{2}) > 2 
                NewDelDayScheduleModel{end+1} = delDayScheduleModel{i};
            end
        end 
    else  
        for i = 1 : numel(delDayScheduleModel)  
            routePart2 = delDayScheduleModel{i}{2}; 
            
            if ismember(PatientID,routePart2)  
                idx = (routePart2 == PatientID);
                routePart2(idx) = [];
                index = i; 
                delDayScheduleModel{i}{2} = routePart2;
                break; 
            end
        end
        
        % Part 1
        % Deletion of route cost changes
        BeforeTour1 = calculateSingelDay(instance,schedule{delDay}{delDayServiceMode+1}{index},delDay);   
        AfterTour1 = calculateSingelDay(instance,delDayScheduleModel{index},delDay); 
        
        % Part 2 - Number of patients served by different health caregivers

        Tour1WorkerID = delDayScheduleModel{index}{1}(1); 
        [Cost1,ptwMatrix] = ServiceNum2(ptwMatrix,Tour1WorkerID,PatientID,1);
        CostPart2 = instance.serviceContinuityWeight * Cost1;
        DelCostChange = (AfterTour1 - BeforeTour1) + CostPart2;
        

        for i = 1 : numel(delDayScheduleModel)
            if ~isempty(delDayScheduleModel{i}{2})
                NewDelDayScheduleModel{end+1} = delDayScheduleModel{i}; 
            end
        end
    end
   
    delDaySchedule{delDayServiceMode+1} = NewDelDayScheduleModel; 
    tempSchedule{delDay} = delDaySchedule;  
    
    %% 2. increase
    insertDay = weijiesou(1); 
    insertDayServiceMode = weijiesou(2); 
    insertDaySchedule = schedule{insertDay}; 
    insertDayScheduleModel = insertDaySchedule{insertDayServiceMode+1}; 
    
  
    PatientSkill = instance.patientSkill(PatientID);
    max_skill = min(3,PatientSkill + instance.skillDiff);
    workSkillRange = PatientSkill : max_skill;
    
    if insertDayServiceMode == 0 || insertDayServiceMode == 1
        for i = 1 : numel(insertDayScheduleModel) 
       
            routePart1 = insertDayScheduleModel{i}{1}; 
            routePart2 = insertDayScheduleModel{i}{2};
            workerID = routePart1(1);  
            
            insertptwMatrix = ptwMatrix; 
           
            Cost1 = ServiceNum(insertptwMatrix,workerID,PatientID,2); 
            CostPart2 = instance.serviceContinuityWeight * Cost1;
            
            TempinsertDaySchedule = insertDaySchedule;  

            if ismember(instance.workerSkill(workerID),workSkillRange) 
                for j = 2 : numel(routePart2) 
                    
                 
                    newroutePart2 = [routePart2(1:j-1),PatientID,routePart2(j:end)]; 
                  
                    [multiflag,durationflag] = RouteDurationCheckerV2(instance,routePart1,newroutePart2,insertDay);

                    if multiflag && durationflag 
                       
                        BeforeTour2 = calculateSingelDay(instance,insertDayScheduleModel{i},insertDay); 
                        AfterTour2 = calculateSingelDay(instance,{routePart1,newroutePart2},insertDay);
                       
                        AddCostChange = (AfterTour2 - BeforeTour2) +  CostPart2;                        
                
                        TempinsertDaySchedule{insertDayServiceMode+1}{i}{2} = newroutePart2;
                        % Total Path Update-Because the solution on the day of deletion, does not change, it does not need to be assigned every time
                        tempSchedule{insertDay} = TempinsertDaySchedule;

                        SolutionSet{end+1} = {tempSchedule,ScheduleObj + AddCostChange + DelCostChange};
                    end
                end
            end
        end
    else 
        for i = 1 : numel(insertDayScheduleModel) 
            
            routePart1 = insertDayScheduleModel{i}{1}; 
            routePart2 = insertDayScheduleModel{i}{2};
            workerID = routePart1(1);  
            insertptwMatrix = ptwMatrix; 
            
            TempinsertDaySchedule = insertDaySchedule;  
            
            if ismember(instance.workerSkill(workerID),workSkillRange) 
                newroutePart2 = [routePart2,PatientID]; 
                if checkQueueStability(instance,routePart1,newroutePart2) 
                 
                    BeforeTour2 = calculateSingelDay(instance,insertDayScheduleModel{i},insertDay); 
                    AfterTour2 = calculateSingelDay(instance,{routePart1,newroutePart2},insertDay); 

                
                    Cost1 = ServiceNum(insertptwMatrix,workerID,PatientID,2); 
                    CostPart2 = instance.serviceContinuityWeight * Cost1;

        
                    AddCostChange = (AfterTour2 - BeforeTour2) +  CostPart2;
       
                    TempinsertDaySchedule{insertDayServiceMode+1}{i}{2} = newroutePart2; 
                    tempSchedule{insertDay} = TempinsertDaySchedule;

                    SolutionSet{end+1} = {tempSchedule,ScheduleObj + AddCostChange + DelCostChange};
                end
            end
        end
    end
    
    if isempty(SolutionSet)  
        flag = false;
        return;
    end
    
    BestSchedule = SolutionSet{1}{1};
    BestScheduleobj = SolutionSet{1}{2};
    for i = 2 : size(SolutionSet,1)
        if BestScheduleobj > SolutionSet{i}{2} 
            BestSchedule = SolutionSet{i}{1};
            BestScheduleobj = SolutionSet{i}{2};
        end
    end
    NewSchedule = {BestSchedule,BestScheduleobj};
end



