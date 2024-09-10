% Two health caregivers exchange operators
function [flag,sortedWorkerExchangeSolutionSet] = workerExchangeSearch(instance,Schedule,Day,ServiceModel)
    flag = true;
    WorkerExchangeSolutionSet = {}; 
    sortedWorkerExchangeSolutionSet = {};
    

    ScheduleObj = calculateObjective(instance,Schedule);
    
 
    ptwMatrix = PatienToWorker(instance,Schedule);

    
    % 1. Start by separating the daily schedule according to the service mode

    DaySchedule = Schedule{Day};
    DayShangmenSchedule = DaySchedule{1};  
    DayXianShangSchedule = DaySchedule{2};
    DayMenzhenSchedule = DaySchedule{3}; 
   
    DaySchedule = DaySchedule{ServiceModel + 1};
    if  numel(DaySchedule) < 2
        flag = false;
        return;
    end
    
    TempSchedule = Schedule; 
   
    if ServiceModel == 0 
        if numel(DayShangmenSchedule) >= 2
            
            for t1 = 1 : numel(DayShangmenSchedule)-1
                for t2 = t1 + 1 : numel(DayShangmenSchedule)
                    SolutionSet = workerExchange(instance,DayShangmenSchedule{t1},DayShangmenSchedule{t2},Day,ptwMatrix);
                    for i = 1 : size(SolutionSet,2) 
                        TempDayShangmenSchedule = DayShangmenSchedule;
                        TempDayShangmenSchedule{t1} = SolutionSet{i}{1};  
                        TempDayShangmenSchedule{t2} = SolutionSet{i}{2};  
                        TempSchedule{Day}{1} = TempDayShangmenSchedule; 
                        
                        WorkerExchangeSolutionSet{end+1} = {[6,SolutionSet{i}{1}{1}(1),SolutionSet{i}{2}{1}(1)],TempSchedule,ScheduleObj+SolutionSet{i}{3}};
                    end
                end
            end
        end
    elseif ServiceModel == 1 
        if numel(DayXianShangSchedule) >= 2
            for t1 = 1 : numel(DayXianShangSchedule)-1
                for t2 = t1 + 1 : numel(DayXianShangSchedule)
                    SolutionSet = workerExchange(instance,DayXianShangSchedule{t1},DayXianShangSchedule{t2},Day,ptwMatrix);
                    for i = 1 : size(SolutionSet,2)  
                        TempDayXianShangSchedule = DayXianShangSchedule; 
                        TempDayXianShangSchedule{t1} = SolutionSet{i}{1};  
                        TempDayXianShangSchedule{t2} = SolutionSet{i}{2}; 
                        TempSchedule{Day}{2} = TempDayXianShangSchedule; 
                       
                        WorkerExchangeSolutionSet{end+1} = {[6,SolutionSet{i}{1}{1}(1),SolutionSet{i}{2}{1}(1)],TempSchedule,ScheduleObj+SolutionSet{i}{3}};
                    end
                end
            end
        end
    else 
        if numel(DayMenzhenSchedule) >= 2
            for t1 = 1 : numel(DayMenzhenSchedule)-1
                for t2 = t1 + 1 : numel(DayMenzhenSchedule)
                    SolutionSet = workerExchange(instance,DayMenzhenSchedule{t1},DayMenzhenSchedule{t2},Day,ptwMatrix);
                    for i = 1 : size(SolutionSet,2)  
                        TempDayMenzhenSchedule = DayMenzhenSchedule;  
                        TempDayMenzhenSchedule{t1} = SolutionSet{i}{1};  
                        TempDayMenzhenSchedule{t2} = SolutionSet{i}{2}; 
                        TempSchedule{Day}{3} = TempDayMenzhenSchedule; 
                        
                        WorkerExchangeSolutionSet{end+1} = {[3,SolutionSet{i}{1}{1}(1),SolutionSet{i}{2}{1}(1)],TempSchedule,ScheduleObj+SolutionSet{i}{3}};
                    end
                end
            end
        end
    end
    if isempty(WorkerExchangeSolutionSet)
        flag = false;
    else
        % Sort the SolutionSet according to the target value
        thirdColValues = cellfun(@(x) x{3}, WorkerExchangeSolutionSet);  
        [~, sortIndex] = sort(thirdColValues);
        sortedWorkerExchangeSolutionSet = WorkerExchangeSolutionSet(sortIndex);
    end
end

function SolutionSet = workerExchange(instance,tour1,tour2,d,ptwMatrix)
    SolutionSet = {};
    
    tour1Part1 = tour1{1}; 
    tour1Part2 = tour1{2};


    tour2Part1 = tour2{1}; 
    tour2Part2 = tour2{2}; 


    % 1. Determine whether the two newly generated routes satisfy the doctor-patient skill matching constraints
    tour1skillflag = matchDoctorToPatientV2(instance,tour2Part1,tour1Part2);
    tour2skillflag = matchDoctorToPatientV2(instance,tour1Part1,tour2Part2);
    
    if tour1skillflag && tour2skillflag
        if tour1Part1(2) == 0 || tour1Part1(2) == 1 
            

            newTour1 = {tour2Part1,tour1Part2};
            newTour2 = {tour1Part1,tour2Part2};
            
 
            Tour1WorkerID = tour1Part1(1);
            Tour2WorkerID = tour2Part1(1);

     
            Cost1 = ServiceNum(ptwMatrix,Tour1WorkerID,tour1Part2(2:end-1),1); 
            Cost2 = ServiceNum(ptwMatrix,Tour1WorkerID,tour2Part2(2:end-1),2); 

            Cost3 = ServiceNum(ptwMatrix,Tour2WorkerID,tour2Part2(2:end-1),1); 
            Cost4 = ServiceNum(ptwMatrix,Tour2WorkerID,tour1Part2(2:end-1),2); 
            CostChange = instance.serviceContinuityWeight * (Cost1+Cost2+Cost3+Cost4);
            
     
            SolutionSet{end+1} = {newTour1,newTour2,CostChange};
            
        else 
            % Satisfy the steady-state constraints of the system
            if checkQueueStability(instance,tour2Part1,tour1Part2) && checkQueueStability(instance,tour1Part1,tour2Part2)
                newTour1 = {tour2Part1,tour1Part2};
                newTour2 = {tour1Part1,tour2Part2};

                BeforeTour1 = calculateSingelDay(instance,tour1,d);
                AfterTour1 = calculateSingelDay(instance,newTour1,d);
                BeforeTour2 = calculateSingelDay(instance,tour2,d);
                AfterTour2 = calculateSingelDay(instance,newTour2,d);
                CostPart1 = (AfterTour1 - BeforeTour1) + (AfterTour2 - BeforeTour2);

                Tour1WorkerID = tour1Part1(1);
                Tour2WorkerID = tour2Part1(1);
         
                Cost1 = ServiceNum(ptwMatrix,Tour1WorkerID,tour1Part2(2:end-1),1); 
                Cost2 = ServiceNum(ptwMatrix,Tour1WorkerID,tour2Part2(2:end-1),2); 
                Cost3 = ServiceNum(ptwMatrix,Tour2WorkerID,tour2Part2(2:end-1),1); 
                Cost4 = ServiceNum(ptwMatrix,Tour2WorkerID,tour1Part2(2:end-1),2); 
                CostPart2 = instance.serviceContinuityWeight * (Cost1+Cost2+Cost3+Cost4);
                
                CostChange = CostPart1 + CostPart2;
                % Save the domain solution
                SolutionSet{end+1} = {newTour1,newTour2,CostChange};
            end
        end     
    end
end
