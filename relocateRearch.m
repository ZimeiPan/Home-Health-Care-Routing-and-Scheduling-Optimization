%% Single-point retargeting of patients across three service modes
function [flag,sortedRelocateSolutionSet] = relocateRearch(instance,Schedule,Day,ServiceModel)
    
    RelocateSolutionSet = {}; 
    sortedRelocateSolutionSet = {};
    
    
    ScheduleObj = calculateObjective(instance,Schedule);
    

    ptwMatrix = PatienToWorker(instance,Schedule);
    
    % 1. Start by separating the daily scheduling based on the service mode 
    DaySchedule = Schedule{Day};
    DayShangmenSchedule = DaySchedule{1};  
    DayXianShangSchedule = DaySchedule{2};
    DayMenzhenSchedule = DaySchedule{3};   

    %% Judge whether there are two routes, no two, direct rejection
    DaySchedule = DaySchedule{ServiceModel + 1};
    if  numel(DaySchedule) < 2
        flag = false;
        return;
    end
    
    TempSchedule = Schedule; 
    exitFlag = false;

    if ServiceModel == 0 
        if numel(DayShangmenSchedule) >= 2
            for t1 = 1 : numel(DayShangmenSchedule)-1
                for t2 = t1 + 1 : numel(DayShangmenSchedule)
                    SolutionSet = relocate(instance,DayShangmenSchedule{t1},DayShangmenSchedule{t2},Day,ptwMatrix);
                  
                    if ~isempty(SolutionSet)
                        for i = 1 : size(SolutionSet,2) 
                            TempDayShangmenSchedule = DayShangmenSchedule;  
                            TempDayShangmenSchedule{t2} = SolutionSet{i}{2}; 
                            if numel(SolutionSet{i}{1}{2}) == 2 
                                TempDayShangmenSchedule(t1) = [];
                            else 
                                TempDayShangmenSchedule{t1} = SolutionSet{i}{1}; 
                            end
                            TempSchedule{Day}{1} = TempDayShangmenSchedule; 
                            RelocateSolutionSet{end+1} = {[1,t1,t2],TempSchedule,ScheduleObj+SolutionSet{i}{3}};
                        end
                    end
                end
            end
        end
    elseif ServiceModel == 1 
        if numel(DayXianShangSchedule) >= 2
            for t1 = 1 : numel(DayXianShangSchedule)-1
                for t2 = t1+1 : numel(DayXianShangSchedule)
                    SolutionSet = relocate(instance,DayXianShangSchedule{t1},DayXianShangSchedule{t2},Day,ptwMatrix);
              
                    if ~isempty(SolutionSet)
                        for i = 1 : size(SolutionSet,2) 
                            TempDayXianShangSchedule = DayXianShangSchedule;  
                            TempDayXianShangSchedule{t2} = SolutionSet{i}{2};  
                            if numel(SolutionSet{i}{1}{2}) == 2 
                                TempDayXianShangSchedule(t1) = [];
                            else 
                                TempDayXianShangSchedule{t1} = SolutionSet{i}{1}; 
                            end
                            TempSchedule{Day}{2} = TempDayXianShangSchedule; 
                            RelocateSolutionSet{end+1} = {[1,t1,t2],TempSchedule,ScheduleObj+SolutionSet{i}{3}};
                        end
                    end
                end
            end
        end
    else 
        if numel(DayMenzhenSchedule) >= 2
            for t1 = 1 : numel(DayMenzhenSchedule)-1
                for t2 = t1+1 : numel(DayMenzhenSchedule)
                    SolutionSet = relocate(instance,DayMenzhenSchedule{t1},DayMenzhenSchedule{t2},Day,ptwMatrix);
                  
                    if ~isempty(SolutionSet)
                        for i = 1 : size(SolutionSet,2)  
                            TempDayMenzhenSchedule = DayMenzhenSchedule;  
                            TempDayMenzhenSchedule{t2} = SolutionSet{i}{2};  
                            if isempty(SolutionSet{i}{1}{2}) 
                                TempDayMenzhenSchedule(t1) = []; 
                            else 
                                TempDayMenzhenSchedule{t1} = SolutionSet{i}{1}; 
                            end
                            TempSchedule{Day}{3} = TempDayMenzhenSchedule; 
                            RelocateSolutionSet{end+1} = {[1,t1,t2],TempSchedule,ScheduleObj+SolutionSet{i}{3}};
                        end
                    end
                end
            end
        end
    end
    %% No feasible domain solution found - default output original solution
    if isempty(RelocateSolutionSet)
        flag = false;
    else 
        flag = true;
        thirdColValues = cellfun(@(x) x{3}, RelocateSolutionSet);  
        [~, sortIndex] = sort(thirdColValues);
        sortedRelocateSolutionSet = RelocateSolutionSet(sortIndex);
    end
end

% Perform a relocation operation
% Find an objective function with the smallest value in the field (not necessarily improved)

function SolutionSet = relocate(instance,tour1,tour2,d,ptwMatrix)
    
    SolutionSet = {};
    

    tour1Part1 = tour1{1};
    tour1Part2 = tour1{2}; 

    tour2Part1 = tour2{1}; 
    tour2Part2 = tour2{2}; 
    
    if tour1Part1(2) == 0 || tour1Part1(2) == 1 
        for i = 2 : numel(tour1Part2)-1 
            for j = 1 : numel(tour2Part2)-1 
                % 1. Determine whether the two newly generated paths satisfy the doctor-patient skill matching constraints
                tour2skillflag = matchDoctorToPatientV2(instance,tour2Part1,tour1Part2(i));
                
                % Path 1 satisfies skill matching, multiple time windows, and work cap constraints by default
                if tour2skillflag  
                    new_tour1 = [tour1Part2(1:i-1),tour1Part2(i+1:end)];
                    new_tour2 = [tour2Part2(1:j),tour1Part2(i),tour2Part2(j+1:end)];
                    
                    % Determine whether route 2 satisfies the multiple time window constraints and the upper work limit constraints
                    [tour1MultiFlag,tour1DurationFlag]= RouteDurationCheckerV2(instance,tour1Part1,new_tour1,d); 
                    [tour2MultiFlag,tour2DurationFlag]= RouteDurationCheckerV2(instance,tour2Part1,new_tour2,d); 
                    if tour1MultiFlag && tour2MultiFlag
                        if tour1DurationFlag && tour2DurationFlag
                    
                            newTour1 = {tour1Part1,new_tour1};
                            newTour2 = {tour2Part1,new_tour2};
                            
                            %% Calculation of target change
                            %% Component 1: Number of patients served by different health caregivers
                  
                            BeforeTour1 = calculateSingelDay(instance,tour1,d);
                            AfterTour1 = calculateSingelDay(instance,newTour1,d);
                
                            BeforeTour2 = calculateSingelDay(instance,tour2,d);
                            AfterTour2 = calculateSingelDay(instance,newTour2,d);
                            CostPart1 = (AfterTour1 - BeforeTour1) + (AfterTour2 - BeforeTour2);

                            Tour1WorkerID = tour1Part1(1);
                            Tour2WorkerID = tour2Part1(1);
                            
                            Cost1 = ServiceNum(ptwMatrix,Tour1WorkerID,tour1Part2(i),1); 
                            Cost2 = ServiceNum(ptwMatrix,Tour2WorkerID,tour1Part2(i),2); 
                            CostPart2 = instance.serviceContinuityWeight * (Cost1+Cost2);

                            CostChange = CostPart1 + CostPart2;
                  
                            SolutionSet{end+1} = {newTour1,newTour2,CostChange};
                        end
                    end
                end
            end
        end
    else  
        for i = 1 : numel(tour1Part2) 
        
            tour2skillflag = matchDoctorToPatientV2(instance,tour2Part1,tour1Part2(i));
                 
            if tour2skillflag 
             
                new_tour1 = [tour1Part2(1:i-1),tour1Part2(i+1:end)]; 
                new_tour2 = [tour2Part2,tour1Part2(i)]; 

         
                if checkQueueStability(instance,tour2Part1,new_tour2) 
               
                     newTour1 = {tour1Part1,new_tour1};
                     newTour2 = {tour2Part1,new_tour2};

                 
                     BeforeTour1 = calculateSingelDay(instance,tour1,d);
                     AfterTour1 = calculateSingelDay(instance,newTour1,d);
              
                     BeforeTour2 = calculateSingelDay(instance,tour2,d);
                     AfterTour2 = calculateSingelDay(instance,newTour2,d);
            
                     CostPart1 = (AfterTour1 - BeforeTour1) + (AfterTour2 - BeforeTour2);

      
                     Tour1WorkerID = tour1Part1(1);
                     Tour2WorkerID = tour2Part1(1);
                     Cost1 = ServiceNum(ptwMatrix,Tour1WorkerID,tour1Part2(i),1); 
                     Cost2 = ServiceNum(ptwMatrix,Tour2WorkerID,tour1Part2(i),2); 
                     CostPart2 = instance.serviceContinuityWeight * (Cost1+Cost2);

                     CostChange = CostPart1 + CostPart2;                        
    
                     SolutionSet{end+1} = {newTour1,newTour2,CostChange};
                end
            end
        end
    end
end

