% Calculate the cost of a single route for the three service modes

function tourObj = calculateSingelDay(instance,tour,d)
    
    
    tourPart1 = tour{1}; 
    tourPart2 = tour{2}; 
    
    if tourPart1(2) == 0   % door-to-door
        if numel(tourPart2) == 2 
            tourObj = 0;
        else 
            
            optimalOutput = minRouteDuration(instance,tourPart1,tourPart2,d);
            
            
            shangmenRoteIndex = tourPart2 + 1; 
            routeDis = zeros(1,numel(tourPart2));
            for j = 1 : numel(shangmenRoteIndex)-1
                routeDis(j) = instance.patientsDis(shangmenRoteIndex(j),shangmenRoteIndex(j+1));
            end
            shangmenTravelCost = instance.distanceCostUnit * sum(routeDis);

           
            shangmenWaitingTimeCost = instance.shangmenWaitingTimeWeight * optimalOutput(3);
            
            tourObj = shangmenTravelCost + shangmenWaitingTimeCost;
        end
    elseif tourPart1(2) == 1 % online
        if numel(tourPart2) == 2 
            tourObj = 0;        
        else 
            optimalOutput = minRouteDuration(instance,tourPart1,tourPart2,d);

            xianshangWaitingTimeCost = instance.xianshangWaitingTimeWeight * optimalOutput(3);
            tourObj = xianshangWaitingTimeCost;
        end
    else % outpatient
        if isempty(tourPart2) 
            tourObj = 0;        
        else 
            workerID = tourPart1(1);
            
            serPatientNum = numel(tourPart2); 
            workerSerRate = instance.workerServicerate(workerID); 
         
            totalWaitTime = (workerSerRate * instance.workerServiceDuration * instance.workerServiceDuration) / (workerSerRate * instance.workerServiceDuration - serPatientNum) - ...
                serPatientNum/workerSerRate - instance.workerServiceDuration;
         
            tourObj = instance.menzhenWaitingWeight * totalWaitTime;
        end
    end
end

