% Randomly select two pathways and two patients to exchange

function [flag,sortedExchangeSolutionSet] = exchangeSearch(instance,Schedule,Day,ServiceModel)
    
    flag = true; 
    ExchangeSolutionSet = {}; 
    sortedExchangeSolutionSet = {};
    
    
  
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
  
    if ServiceModel == 0 % 上门 
        if numel(DayShangmenSchedule) >= 2
             
            for t1 = 1 : numel(DayShangmenSchedule)-1
                for t2 = t1 + 1 : numel(DayShangmenSchedule)
                    SolutionSet = exchange(instance,DayShangmenSchedule{t1},DayShangmenSchedule{t2},Day,ptwMatrix);
                    for i = 1 : size(SolutionSet,2)  
                        TempDayShangmenSchedule = DayShangmenSchedule;  
                        TempDayShangmenSchedule{t1} = SolutionSet{i}{1}; 
                        TempDayShangmenSchedule{t2} = SolutionSet{i}{2}; 
                        TempSchedule{Day}{1} = TempDayShangmenSchedule; 
                        ExchangeSolutionSet{end+1} = {[2,t1,t2],TempSchedule,ScheduleObj+SolutionSet{i}{3}};
                    end
                end
            end
        end
    elseif ServiceModel == 1 
        if numel(DayXianShangSchedule) >= 2
          
            for t1 = 1 : numel(DayXianShangSchedule)-1
                for t2 = t1 + 1 : numel(DayXianShangSchedule)
                    SolutionSet = exchange(instance,DayXianShangSchedule{t1},DayXianShangSchedule{t2},Day,ptwMatrix);
                    for i = 1 : size(SolutionSet,2)  
                        TempDayXianShangSchedule = DayXianShangSchedule; 
                        TempDayXianShangSchedule{t1} = SolutionSet{i}{1};
                        TempDayXianShangSchedule{t2} = SolutionSet{i}{2};  
                        TempSchedule{Day}{2} = TempDayXianShangSchedule;
                        ExchangeSolutionSet{end+1} = {[2,t1,t2],TempSchedule,ScheduleObj+SolutionSet{i}{3}};
                    end
                end
            end
        end
    else 
        if numel(DayMenzhenSchedule) >= 2
            
            for t1 = 1 : numel(DayMenzhenSchedule)-1
                for t2 = t1 + 1 : numel(DayMenzhenSchedule)
                    SolutionSet = exchange(instance,DayMenzhenSchedule{t1},DayMenzhenSchedule{t2},Day,ptwMatrix);
                    for i = 1 : size(SolutionSet,2) 
                        TempDayMenzhenSchedule = DayMenzhenSchedule;  
                        TempDayMenzhenSchedule{t1} = SolutionSet{i}{1};  
                        TempDayMenzhenSchedule{t2} = SolutionSet{i}{2};  
                        TempSchedule{Day}{3} = TempDayMenzhenSchedule; 
                        ExchangeSolutionSet{end+1} = {[2,t1,t2],TempSchedule,ScheduleObj+SolutionSet{i}{3}};
                    end
                end
            end
        end
    end
    %% No feasible neighborhood solutions were found.
    if isempty(ExchangeSolutionSet)
        flag = false; 
    else
       
        thirdColValues = cellfun(@(x) x{3}, ExchangeSolutionSet);  
        [~, sortIndex] = sort(thirdColValues);
        sortedExchangeSolutionSet = ExchangeSolutionSet(sortIndex);
    end
end

function SolutionSet = exchange(instance,tour1,tour2,d,ptwMatrix)
    SolutionSet = {};
    
    tour1Part1 = tour1{1}; 
    tour1Part2 = tour1{2}; 
 

    tour2Part1 = tour2{1};
    tour2Part2 = tour2{2}; 
    
    if tour1Part1(2) == 0 || tour1Part1(2) == 1 
        for i = 2 : numel(tour1Part2)-1 
            for j = 2 : numel(tour2Part2)-1 
      
                % 1. Determine whether the two newly generated routes satisfy the doctor-patient skill matching constraints
                tour1skillflag = matchDoctorToPatientV2(instance,tour1Part1,tour2Part2(j));
                tour2skillflag = matchDoctorToPatientV2(instance,tour2Part1,tour1Part2(i));
                
                if tour1skillflag && tour2skillflag  
                    % Determine whether the new route satisfies the multiple time window constraints as well as the work duration constraints
                    %% Two newly generated routes
                    new_tour1 = [tour1Part2(1:i-1),tour2Part2(j),tour1Part2(i+1:end)];
                    new_tour2 = [tour2Part2(1:j-1),tour1Part2(i),tour2Part2(j+1:end)];

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
                            
                            %% Component 2 - Number of patients served by different healthcare professionals
                            Tour1WorkerID = tour1Part1(1);
                            Tour2WorkerID = tour2Part1(1);

                            Cost1 = ServiceNum(ptwMatrix,Tour1WorkerID,tour1Part2(i),1); 
                            Cost2 = ServiceNum(ptwMatrix,Tour1WorkerID,tour2Part2(j),2); 
                            
                            Cost3 = ServiceNum(ptwMatrix,Tour2WorkerID,tour2Part2(j),1); 
                            Cost4 = ServiceNum(ptwMatrix,Tour2WorkerID,tour1Part2(i),2); 
                            CostPart2 = instance.serviceContinuityWeight * (Cost1+Cost2+Cost3+Cost4);

                            CostChange = CostPart1 + CostPart2;

                            
                            SolutionSet{end+1} = {newTour1,newTour2,CostChange};
                        end
                    end
                end
            end
        end
    else  
        for i = 1 : numel(tour1Part2)
            for j = 1 : numel(tour2Part2)  
               
                % 1. Determine whether the two newly generated routes satisfy the doctor-patient skill matching constraints
                tour1skillflag = matchDoctorToPatientV2(instance,tour1Part1,tour2Part2(j));
                tour2skillflag = matchDoctorToPatientV2(instance,tour2Part1,tour1Part2(i));
                
                if tour1skillflag && tour2skillflag 
                 
                    new_tour1 = [tour1Part2(1:i-1),tour1Part2(i+1:end),tour2Part2(j)];
                    new_tour2 = [tour2Part2(1:j-1),tour2Part2(j+1:end),tour1Part2(i)];
                 
                    newTour1 = {tour1Part1,new_tour1};
                    newTour2 = {tour2Part1,new_tour2};

               
                    Tour1WorkerID = tour1Part1(1);
                    Tour2WorkerID = tour2Part1(1);
         
                    Cost1 = ServiceNum(ptwMatrix,Tour1WorkerID,tour1Part2(i),1); 
                    Cost2 = ServiceNum(ptwMatrix,Tour1WorkerID,tour2Part2(j),2); 

            
                    Cost3 = ServiceNum(ptwMatrix,Tour2WorkerID,tour2Part2(j),1); 
                    Cost4 = ServiceNum(ptwMatrix,Tour2WorkerID,tour1Part2(i),2);
                    CostChange = instance.serviceContinuityWeight * (Cost1+Cost2+Cost3+Cost4);
                    
                    % Save the neighborhood solution
                    SolutionSet{end+1} = {newTour1,newTour2,CostChange};
                end
            end
        end
    end
end