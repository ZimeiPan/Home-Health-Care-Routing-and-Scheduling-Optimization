% Two paramedics perform an exchange of arithmetic
% Exchanges can be made within any service mode on the same day
function [flag,sortedWorkerExchangeSolutionSet] = workerExchangeSearchV3(instance,Schedule,Day)
    flag = true; 
    WorkerExchangeSolutionSet = {}; 
    sortedWorkerExchangeSolutionSet = {};
    
 
    ScheduleObj = calculateObjective(instance,Schedule);
    
 
    ptwMatrix = PatienToWorker(instance,Schedule);

    DaySchedule = Schedule{Day};
    DayShangmenSchedule = DaySchedule{1};  
    DayXianShangSchedule = DaySchedule{2}; 
    DayMenzhenSchedule = DaySchedule{3};   
    
    % Exchanged throughout the service model
    DayTour = [DayShangmenSchedule,DayXianShangSchedule,DayMenzhenSchedule];
  
    if  numel(DayTour) < 2
        flag = false;
        return;
    end

    TempSchedule = Schedule; 
    for t1 = 1 : numel(DayTour)-1
        for t2 = t1 + 1 : numel(DayTour)
            SolutionSet = workerExchange(instance,DayTour{t1},DayTour{t2},Day,ptwMatrix);
            for i = 1 : size(SolutionSet,2)  
                TempDaySchedule = DayTour;
                TempDaySchedule{t1} = SolutionSet{i}{1};  
                TempDaySchedule{t2} = SolutionSet{i}{2};  
                TempDaySchedule = scheduleDivide(TempDaySchedule); 
                TempSchedule{Day} = TempDaySchedule; 
                %% Data Addition
                WorkerExchangeSolutionSet{end+1} = {[6,SolutionSet{i}{1}{1}(1),SolutionSet{i}{2}{1}(1)],TempSchedule,ScheduleObj+SolutionSet{i}{3}};
            end
        end
    end
    
    if isempty(WorkerExchangeSolutionSet)
        flag = false;
    else

        thirdColValues = cellfun(@(x) x{3}, WorkerExchangeSolutionSet);  
        [~, sortIndex] = sort(thirdColValues);
        sortedWorkerExchangeSolutionSet = WorkerExchangeSolutionSet(sortIndex);
    end
end

function SolutionSet = workerExchange(instance,tour1,tour2,d,ptwMatrix)
    flag = true;  
    SolutionSet = {};
    

    tour1Part1 = tour1{1}; 
    tour1Part2 = tour1{2}; 


    tour2Part1 = tour2{1}; 
    tour2Part2 = tour2{2}; 

    % 1. Determine whether the two newly generated paths satisfy the doctor-patient skill matching constraints
    tour1skillflag = matchDoctorToPatientV2(instance,tour2Part1,tour1Part2);
    tour2skillflag = matchDoctorToPatientV2(instance,tour1Part1,tour2Part2);
    
    if tour1skillflag && tour2skillflag  
    
       newTour1Part1 = [tour2Part1(1),tour1Part1(2)]; 
       newTour1 = {newTour1Part1,tour1Part2}; 
       
       newTour2Part1 = [tour1Part1(1),tour2Part1(2)]; 
       newTour2 = {newTour2Part1,tour2Part2};

       if newTour1Part1(2) == 2
           if ~ checkQueueStability(instance,newTour1Part1,tour1Part2)
               flag = false;
           end
       end
       if newTour2Part1(2) == 2
           if ~ checkQueueStability(instance,newTour2Part1,tour2Part2)
               flag = false;
           end
       end 
    else
        flag = false;
    end

    if flag 
        BeforeTour1 = calculateSingelDay(instance,tour1,d);
        AfterTour1 = calculateSingelDay(instance,newTour1,d);
        BeforeTour2 = calculateSingelDay(instance,tour2,d);
        AfterTour2 = calculateSingelDay(instance,newTour2,d);
        CostPart1 = (AfterTour1 - BeforeTour1) + (AfterTour2 - BeforeTour2);

    
        Tour1WorkerID = tour1Part1(1);
        Tour2WorkerID = tour2Part1(1);

        Cost1 = ServiceNum(ptwMatrix,Tour1WorkerID,tour1Part2,1); 
        Cost2 = ServiceNum(ptwMatrix,Tour1WorkerID,tour2Part2,2);

        Cost3 = ServiceNum(ptwMatrix,Tour2WorkerID,tour2Part2,1); 
        Cost4 = ServiceNum(ptwMatrix,Tour2WorkerID,tour1Part2,2); 
        CostPart2 = instance.serviceContinuityWeight * (Cost1+Cost2+Cost3+Cost4);
        
        CostChange = CostPart1 + CostPart2;
  
        SolutionSet{end+1} = {newTour1,newTour2,CostChange};
    end
end
