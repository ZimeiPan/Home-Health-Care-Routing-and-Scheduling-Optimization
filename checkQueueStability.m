% Check whether the outpatient is systematically homeostatically constrained

function flag = checkQueueStability(instance,routePart1,routePart2)
    
    flag = true;


    workerID = routePart1(1);

    if isempty(routePart2)
        flag = true;
        return;
    end

    workerServiceRate = instance.workerServicerate(workerID);  

    if (numel(routePart2) / (workerServiceRate * instance.workerServiceDuration)) >= 1 
        flag = false;
    end
    
end

