% According to the solution, the service relationship between the caregiver and the patient

function ptwMatrix = PatienToWorker(instance,schedule)
  
    ptwMatrix = zeros(instance.nrPatient,instance.nrWorker);

    for d = 1 : instance.period
        
        ptwMatrix = uppdateMatrix(schedule{d},ptwMatrix); 
    end
end

function ptwMatrix = uppdateMatrix(Dayschedule,ptwMatrix)
    %% Separate scheduling programs based on different service models
    shangmenaSchedule = Dayschedule{1};
    xianshangSchedule = Dayschedule{2};
    menzhenSchedule = Dayschedule{3};

    for i = 1 : numel(shangmenaSchedule)
        workerID = shangmenaSchedule{i}{1}(1); 
        route = shangmenaSchedule{i}{2};       
        
        for j = 2 : numel(route)-1
            ptwMatrix(route(j),workerID) = ptwMatrix(route(j),workerID) + 1;
        end
    end

    for i = 1 : numel(xianshangSchedule)
        workerID = xianshangSchedule{i}{1}(1); 
        route = xianshangSchedule{i}{2};       
        
        for j = 2 : numel(route)-1
            ptwMatrix(route(j),workerID) = ptwMatrix(route(j),workerID) + 1;
        end
    end
    
    for i = 1 : numel(menzhenSchedule)
        workerID = menzhenSchedule{i}{1}(1); 
        route = menzhenSchedule{i}{2};       

        for j = 1 : numel(route)
            ptwMatrix(route(j),workerID) = ptwMatrix(route(j),workerID) + 1;
        end
    end
end