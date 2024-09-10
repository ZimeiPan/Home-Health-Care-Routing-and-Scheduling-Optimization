%% Calculate the value of the objective function for daily scheduling
function [PatientToWorker,singleDayObj] = calculateSingelDayObj(instance,Dayschedule,PatientToWorker,d)
    
    %% Separate scheduling programs based on different service modes
    shangmenaSchedule = Dayschedule{1};
    xianshangSchedule = Dayschedule{2};
    menzhenSchedule = Dayschedule{3};
    
    %% Calculate the value of the objective function for different service modes
    %% Door-to-door service
    shangmenObjList = zeros(1,numel(shangmenaSchedule));
    for i = 1 : numel(shangmenaSchedule)  
        routePart1 = shangmenaSchedule{i}{1}; 
        routePart2 = shangmenaSchedule{i}{2};
        
        if numel(routePart2) == 2
            shangmenObjList(i) = 0;
            continue;
        else
           
            for j = 2 : numel(routePart2)-1
                PatientToWorker(routePart2(j),routePart1(1)) = 1;
            end

            optimalOutput = minRouteDuration(instance,routePart1,routePart2,d);


            shangmenRoteIndex = routePart2 + 1; 
            routeDis = zeros(1,numel(routePart2));
            for j = 1 : numel(shangmenRoteIndex)-1
                routeDis(j) = instance.patientsDis(shangmenRoteIndex(j),shangmenRoteIndex(j+1));
            end
            shangmenTravelCost = instance.distanceCostUnit * sum(routeDis);

            shangmenWaitingTimeCost = instance.shangmenWaitingTimeWeight * optimalOutput(3);
            shangmenObjList(i) = shangmenTravelCost + shangmenWaitingTimeCost;
        end
    end
    shangmenPartCost = sum(shangmenObjList);
    
    %% Online service
    xianshangObjList = zeros(1,numel(xianshangSchedule));
    for i = 1 : numel(xianshangSchedule) 
        routePart1 = xianshangSchedule{i}{1}; 
        routePart2 = xianshangSchedule{i}{2}; 

        if numel(routePart2) == 2
            xianshangObjList(i) = 0;
            continue;
        else
           
            for j = 2 : numel(routePart2)-1
                PatientToWorker(routePart2(j),routePart1(1)) = 1;
            end
            
            optimalOutput = minRouteDuration(instance,routePart1,routePart2,d);

            xianshangWaitingTimeCost = instance.xianshangWaitingTimeWeight * optimalOutput(3);
            xianshangObjList(i) = xianshangWaitingTimeCost;
        end
    end
    xianshangPartCost = sum(xianshangObjList);
    
    %% Outpatient service
    menzhenObjList = zeros(1,numel(menzhenSchedule));
    for i = 1 : numel(menzhenSchedule)
        routePart1 = menzhenSchedule{i}{1};
        routePart2 = menzhenSchedule{i}{2};
        workerID = routePart1(1); 

        if isempty(routePart2) 
            menzhenObjList(i) = 0;
            continue;
        else 
            for j = 1 : numel(routePart2)
                PatientToWorker(routePart2(j),routePart1(1)) = 1;
            end

            serPatientNum = numel(routePart2); 
            workerSerRate = instance.workerServicerate(workerID); 
      
            totalWaitTime = (workerSerRate * instance.workerServiceDuration * instance.workerServiceDuration) / (workerSerRate * instance.workerServiceDuration - serPatientNum) - ...
                serPatientNum/workerSerRate - instance.workerServiceDuration;
            menzhenObjList(i) = totalWaitTime;
        end
    end

    menzhenPartCost = instance.menzhenWaitingWeight * sum(menzhenObjList);
    
    singleDayObj = shangmenPartCost + xianshangPartCost +  menzhenPartCost;
end

