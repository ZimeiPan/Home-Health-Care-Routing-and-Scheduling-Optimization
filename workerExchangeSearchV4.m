% Two paramedics perform an exchange of arithmetic
%% Possibility of the same healthcare worker serving twice in one day
% Replace within the entire solution space
function [flag,sortedWorkerExchangeSolutionSet] = workerExchangeSearchV4(instance,Schedule)
    flag = true; 
    WorkerExchangeSolutionSet = {}; 
    sortedWorkerExchangeSolutionSet = {};
    
 
    ScheduleObj = calculateObjective(instance,Schedule);
    
   
    ptwMatrix = PatienToWorker(instance,Schedule);

    ServiceMatrix = calculateMatrix(instance,Schedule);
    
    for d1 = 1 : instance.period - 1
        for d2 = d1 + 1 :instance.period
            %% D1-day scheduling scheme
   
            Day1Schedule = Schedule{d1};
            Day1ShangmenSchedule = Day1Schedule{1};
            Day1XianShangSchedule = Day1Schedule{2};
            Day1MenzhenSchedule = Day1Schedule{3};   
       
            Day1Tour = [Day1ShangmenSchedule,Day1XianShangSchedule,Day1MenzhenSchedule];
            
            %% D2-day scheduling scheme

            Day2Schedule = Schedule{d2};
            Day2ShangmenSchedule = Day2Schedule{1}; 
            Day2XianShangSchedule = Day2Schedule{2}; 
            Day2MenzhenSchedule = Day2Schedule{3};  
   
            Day2Tour = [Day2ShangmenSchedule,Day2XianShangSchedule,Day2MenzhenSchedule];

            TempSchedule = Schedule; 
            for t1 = 1 : numel(Day1Tour)
                for t2 = 1 : numel(Day2Tour)
                    Worker1 = ServiceMatrix(Day1Tour{t1}{1}(1),d1) +  ServiceMatrix(Day1Tour{t1}{1}(1),d2);
                    Worker2 = ServiceMatrix(Day2Tour{t2}{1}(1),d1) +  ServiceMatrix(Day2Tour{t2}{1}(1),d2);
                    
                    if Day1Tour{t1}{1}(1) ~= Day2Tour{t2}{1}(1) && Worker1 == 1 && Worker2 == 1
                              
                
                        %% First determine if the skill level constraints are satisfied - newly generated paths
                        
                        tour1skillflag = matchDoctorToPatientV2(instance,Day2Tour{t2}{1},Day1Tour{t1}{2});
                        tour2skillflag = matchDoctorToPatientV2(instance,Day1Tour{t1}{1},Day2Tour{t2}{2});
         
                        if tour1skillflag && tour2skillflag
                   
                            SolutionSet = workerExchange(instance,Day1Tour{t1},Day2Tour{t2},d1,d2,ptwMatrix);

                            for i = 1 : size(SolutionSet,2)
                                TempDay1Schdule = Day1Tour;
                                TempDay2Schdule = Day2Tour;
                                TempDay1Schdule{t1} = SolutionSet{i}{1};  
                                TempDay2Schdule{t2} = SolutionSet{i}{2};  
                                TempDay1Schdule = scheduleDivide(TempDay1Schdule); 
                                TempDay2Schdule = scheduleDivide(TempDay2Schdule); 
                                TempSchedule{d1} = TempDay1Schdule;
                                TempSchedule{d2} = TempDay2Schdule;
                         
                                WorkerExchangeSolutionSet{end+1} = {[6,SolutionSet{i}{1}{1}(1),SolutionSet{i}{2}{1}(1)],TempSchedule,ScheduleObj+SolutionSet{i}{3}};
                            end
                        end
                    end
                end
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

function SolutionSet = workerExchange(instance,tour1,tour2,d1,d2,ptwMatrix)
    flag = true; 
    SolutionSet = {};
    

    tour1Part1 = tour1{1}; 
    tour1Part2 = tour1{2}; 


    tour2Part1 = tour2{1}; 
    tour2Part2 = tour2{2}; 
    
    %% New routes
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
    
    if flag 
        BeforeTour1 = calculateSingelDay(instance,tour1,d1);
        AfterTour1 = calculateSingelDay(instance,newTour1,d1);

       
        BeforeTour2 = calculateSingelDay(instance,tour2,d2);
        AfterTour2 = calculateSingelDay(instance,newTour2,d2);
        CostPart1 = (AfterTour1 - BeforeTour1) + (AfterTour2 - BeforeTour2);

        
        Tour1WorkerID = tour1Part1(1);
        Tour2WorkerID = tour2Part1(1);
        
   
        [Cost1,ptwMatrix] = ServiceNum2(ptwMatrix,Tour1WorkerID,tour1Part2,1); 
        [Cost2,ptwMatrix] = ServiceNum2(ptwMatrix,Tour1WorkerID,tour2Part2,2); 
  
        [Cost3,ptwMatrix] = ServiceNum2(ptwMatrix,Tour2WorkerID,tour2Part2,1); 
        [Cost4,~] = ServiceNum2(ptwMatrix,Tour2WorkerID,tour1Part2,2); 
        CostPart2 = instance.serviceContinuityWeight * (Cost1+Cost2+Cost3+Cost4);
        
        CostChange = CostPart1 + CostPart2;
        
        SolutionSet{end+1} = {newTour1,newTour2,CostChange};
    end
end
