%% Two routes are exchanged - subsequence exchange
% For in-door-to-door and online only
function [flag,sortedCrossSolutionSet] = crossSearch(instance,Schedule,Day,ServiceModel)
    
    flag = true; 
    CrossSolutionSet = {}; 
    sortedCrossSolutionSet = {}; 
    
    % The value of the objective function before the domain search
    ScheduleObj = calculateObjective(instance,Schedule);
    
    % Matrix of the number of times the service is currently resolved
    ptwMatrix = PatienToWorker(instance,Schedule);

    
    % 1. Start by separating the daily schedule according to the service mode

    DaySchedule = Schedule{Day};
    DayShangmenSchedule = DaySchedule{1};  
    DayXianShangSchedule = DaySchedule{2}; 
    

    DaySchedule = DaySchedule{ServiceModel + 1};
    if  numel(DaySchedule) < 2
        flag = false;
        return;
    end
    TempSchedule = Schedule;
    % For this operator, up to two routes
    if ServiceModel == 0
        if numel(DayShangmenSchedule) >= 2
            for t1 = 1 : numel(DayShangmenSchedule)-1
                for t2 = t1 + 1 : numel(DayShangmenSchedule)
                    SolutionSet = cross(instance,DayShangmenSchedule{t1},DayShangmenSchedule{t2},Day,ptwMatrix);
                    for i = 1 : size(SolutionSet,2) 
                        TempDayShangmenSchedule = DayShangmenSchedule;  
                        TempDayShangmenSchedule{t1} = SolutionSet{i}{1}; 
                        TempDayShangmenSchedule{t2} = SolutionSet{i}{2};  
                        TempSchedule{Day}{1} = TempDayShangmenSchedule; 

                        CrossSolutionSet{end+1} = {[4,t1,t2],TempSchedule,ScheduleObj+SolutionSet{i}{3}};
                    end
                end
            end
        else 
            flag = false;
        end
    elseif ServiceModel == 1 
        if numel(DayXianShangSchedule) >= 2
            for t1 = 1 : numel(DayXianShangSchedule)-1
                for t2 = t1 + 1 : numel(DayXianShangSchedule)
                    SolutionSet = cross(instance,DayXianShangSchedule{t1},DayXianShangSchedule{t2},Day,ptwMatrix);
                    for i = 1 : size(SolutionSet,2)  
                        TempDayXianShangSchedule = DayXianShangSchedule;  
                        TempDayXianShangSchedule{t1} = SolutionSet{i}{1}; 
                        TempDayXianShangSchedule{t2} = SolutionSet{i}{2}; 
                        TempSchedule{Day}{2} = TempDayXianShangSchedule;                        
                        CrossSolutionSet{end+1} = {[4,t1,t2],TempSchedule,ScheduleObj+SolutionSet{i}{3}};
                    end
                end
            end
        else 
            flag = false;
        end
    end
    
    if isempty(CrossSolutionSet)
        flag = false;
    else
        thirdColValues = cellfun(@(x) x{3}, CrossSolutionSet);  
        [~, sortIndex] = sort(thirdColValues);
        sortedCrossSolutionSet = CrossSolutionSet(sortIndex);
    end
end


function SolutionSet = cross(instance,tour1,tour2,d,ptwMatrix)
    SolutionSet = {};
    
    
    tour1Part1 = tour1{1}; 
    tour1Part2 = tour1{2}; 


    tour2Part1 = tour2{1}; 
    tour2Part2 = tour2{2}; 
    
    for i = 2 : numel(tour1Part2)-2  
        for k = i + 1 : numel(tour1Part2)-1 
            for j = 2 : numel(tour2Part2)-2 %
                for l = j + 1 : numel(tour2Part2)-1 

                    tour1skillflag = matchDoctorToPatientV2(instance,tour1Part1,tour2Part2(j:l));
                    tour2skillflag = matchDoctorToPatientV2(instance,tour2Part1,tour1Part2(i:k));
                    
                    if tour1skillflag && tour2skillflag  
                    
                        new_tour1 = [tour1Part2(1:i-1),tour2Part2(j:l),tour1Part2(k+1:end)];
                        new_tour2 = [tour2Part2(1:j-1),tour1Part2(i:k),tour2Part2(l+1:end)];

                        [tour1MultiFlag,tour1DurationFlag]= RouteDurationCheckerV2(instance,tour1Part1,new_tour1,d); 
                        [tour2MultiFlag,tour2DurationFlag]= RouteDurationCheckerV2(instance,tour2Part1,new_tour2,d); 
                        
                        if tour1MultiFlag && tour2MultiFlag
                            if tour1DurationFlag && tour2DurationFlag
                              
                                newTour1 = {tour1Part1,new_tour1};
                                newTour2 = {tour2Part1,new_tour2};
                                
                            
                                BeforeTour1 = calculateSingelDay(instance,tour1,d);
                                AfterTour1 = calculateSingelDay(instance,newTour1,d);
                            
                                BeforeTour2 = calculateSingelDay(instance,tour2,d);
                                AfterTour2 = calculateSingelDay(instance,newTour2,d);
                                CostPart1 = (AfterTour1 - BeforeTour1) + (AfterTour2 - BeforeTour2);
                                
                            
                                Tour1WorkerID = tour1Part1(1);
                                Tour2WorkerID = tour2Part1(1);
                              
                                Cost1 = ServiceNum(ptwMatrix,Tour1WorkerID,tour1Part2(i:k),1); 
                                Cost2 = ServiceNum(ptwMatrix,Tour1WorkerID,tour2Part2(j:l),2); 
                              
                                Cost3 = ServiceNum(ptwMatrix,Tour2WorkerID,tour2Part2(j:l),1); 
                                Cost4 = ServiceNum(ptwMatrix,Tour2WorkerID,tour1Part2(i:k),2); 
                                CostPart2 = instance.serviceContinuityWeight * (Cost1+Cost2+Cost3+Cost4);
                                CostChange = CostPart1 + CostPart2;
                                
                         
                                SolutionSet{end+1} = {newTour1,newTour2,CostChange};
                            end
                        end
                    end
                end
            end
        end
    end
end