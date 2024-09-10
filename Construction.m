%% Initial solution construction for multicycle models

function iniSchedule = Construction(instance)
    
    iniSchedule = cell(instance.period,1); 

    % 1. Determine the collection of patients to be served each day
    dayPatiensSet = chosenServiceDays(instance);
    
    % 2. Break down the daily patient set to determine the set of patients to be served in the door-to-door, online, and outpatient setting
    
    WorkerPatientSerNum = zeros(instance.nrWorker,instance.nrPatient);
    WorkerDuration = instance.workerDaysDurationMatrix; 
    % Construct the initial solution
    
    for d = 1 : instance.period
        [d_shangmen,d_xianshang,d_menzhen] = divideModel(dayPatiensSet{d});
   
        [day_Schedule,WorkerPatientSerNum,WorkerDuration] = singleDayConstruction(instance,WorkerPatientSerNum,WorkerDuration,d_shangmen,d_xianshang,d_menzhen,d);
        iniSchedule{d} = day_Schedule;
    end
end

