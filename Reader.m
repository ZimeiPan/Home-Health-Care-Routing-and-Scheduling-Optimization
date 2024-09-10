%% Data reading data_1
function instance = Reader()
    
    instance = struct();
    
    %% Patient Information
    patinets_info = xlsread("D:\Codings\Matlab_coding\data\R30_3\patients_info.xlsx");
    
    patinets_ServiceFrequency = xlsread("D:\Codings\Matlab_coding\\data\R30_3\serviceFrequency.xlsx");
    % Patient serviceable days: to be greater than or equal to the patient's service frequency
    patinets_ServiceDays = xlsread("D:\Codings\Matlab_coding\\data\R30_3\patientServiceDays.xlsx");
    % Corresponding service model selected by the patient for the number of days available for service
    patinets_ServiceOption = xlsread("D:\Codings\Matlab_coding\data\R30_3\serviceOption.xlsx");

    patinets_ShangmenTimeWindows = xlsread("D:\Codings\Matlab_coding\data\R30_3\shangmenTimeWindows.xlsx");

    patinets_XianshangTimeWindows = xlsread("D:\Codings\Matlab_coding\\data\R30_3\xianshangTimeWindows.xlsx");
    
    worker_info = xlsread("D:\Codings\Matlab_coding\data\R30_3\works_info.xlsx");
    
    %% Care centers and other parameters
    huli_x = 0;
    huli_y = 0;
    instance.openDuration = 540; 
    instance.period = size(patinets_ServiceDays,2); 
    
    %% skill level difference
    instance.skillDiff = 2; 
    instance.workerDaysDuration = instance.period-1; 
    instance.nrWorker = size(worker_info,1); 
    instance.workerDaysDurationMatrix = ones(instance.nrWorker,1) * instance.workerDaysDuration; 
    %% Objective calculation of relevant weights
    instance.distanceCostUnit = 1;
    instance.shangmenWaitingTimeWeight = 10; 
    instance.xianshangWaitingTimeWeight = 10; 
    instance.menzhenWaitingWeight = 10; 
    instance.serviceContinuityWeight = 10; 
    
    %% Patient information extraction
    instance.nrPatient = size(patinets_info,1); 
    instance.patientID = 1 : size(patinets_info,1); 
    instance.coordinates = patinets_info(:,1:2);
    instance.patientSkill = patinets_info(:,3); 
    instance.shangmenServicetime = patinets_info(:,4); 
    instance.xianshangServicetime = patinets_info(:,4); 
    

    instance.timewindowNum = 2; 
    instance.shangmenTimeWindows = patinets_ShangmenTimeWindows; 
    instance.xianshangTimeWindows = patinets_XianshangTimeWindows; 
    
    % Service frequency, number of days, and corresponding service mode
    instance.patinetServiceFre = patinets_ServiceFrequency; 
    instance.patinetServiceDay = patinets_ServiceDays;
    instance.patinetServiceModel = patinets_ServiceOption;
    
    % Sum of the number of days a patient can receive services during the cycle
    patinetServiceDaySum = zeros(instance.nrPatient,1);
    for i = 1 : instance.nrPatient
        for j = 1 : instance.period
            if patinets_ServiceDays(i,j) ~= -1
                patinetServiceDaySum(i) = patinetServiceDaySum(i) + 1;
            end
        end
    end
    instance.patinetServiceDaySum = patinetServiceDaySum;
    
    %% Travel distance between in-home and online services

    totalCoordinates = [huli_x,huli_y;instance.coordinates]; 
    patientsDis = zeros(instance.nrPatient+1,instance.nrPatient+1); 
    for i = 1 : size(totalCoordinates,1)
        for j = 1 : size(totalCoordinates,1)
            if i ~= j
                if i < j
                    patientsDis(i,j) = sqrt(power(totalCoordinates(i,1)-totalCoordinates(j,1),2)+power(totalCoordinates(i,2)-totalCoordinates(j,2),2));
                else
                    patientsDis(i,j) = patientsDis(j,i);
                end
            end
        end
    end
    patientsDis = ceil(patientsDis * 100) / 100; 
    patientsShangmenTraveltime = patientsDis; 

    instance.patientsDis = patientsDis;    
    instance.patientShangmenTraveltime = patientsShangmenTraveltime;
    
    serviceReadyTime = 20; 
    patientsXianshangTraveltime = zeros(instance.nrPatient+1,instance.nrPatient+1); 

    for i = 1 : size(patientsXianshangTraveltime,1)
        for j = 1 : size(patientsXianshangTraveltime,1)
            if i ~= j
                if i < j
                    patientsXianshangTraveltime(i,j) = serviceReadyTime;
                else
                     patientsXianshangTraveltime(i,j) =  patientsXianshangTraveltime(j,i);
                end
            end
        end
    end
    instance.patientsXianshangTraveltime = patientsXianshangTraveltime; 
    

    %% caregiver information extraction
    instance.workerID = 1 : size(worker_info,1);
    
    instance.workerSkill = worker_info(:,2); 
    instance.workerServicerate = worker_info(:,3); 
    instance.workerServiceDuration = 480; 

end

