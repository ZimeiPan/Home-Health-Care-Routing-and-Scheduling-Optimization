%% Counting the days on which each healthcare caregiver has served
function ServiceMatrix = calculateMatrix(instance,Schedule)

    ServiceMatrix = zeros(instance.nrWorker,instance.period);

    Schedule = removeEmptySchedule(instance,Schedule);

    for day = 1 : instance.period
        DaySchedule = Schedule{day};
        %% Separate scheduling programs based on different service modes
        shangmenaSchedule = DaySchedule{1};
        xianshangSchedule = DaySchedule{2};
        menzhenSchedule = DaySchedule{3};
        
       
        for i = 1 : numel(shangmenaSchedule)
            routePart1 = shangmenaSchedule{i}{1};
            workerID = routePart1(1); 
            ServiceMatrix(workerID,day) = 1;
        end

        
        for i = 1 : numel(xianshangSchedule)
            routePart1 = xianshangSchedule{i}{1};
            workerID = routePart1(1); 
            ServiceMatrix(workerID,day) = 1;
        end
        
        
        for i = 1 : numel(menzhenSchedule)
            routePart1 = menzhenSchedule{i}{1};
            workerID = routePart1(1); 
            ServiceMatrix(workerID,day) = 1;
        end
    end
end

