% Function: Determine the set of patients to be served each day (including service modes)

function dayPatiensSet = chosenServiceDays(instance)
    serviceFre = instance.patinetServiceFre;
    patientAvailableDays = instance.patinetServiceDay;
    patientAvailableServiceModel = instance.patinetServiceModel;
    patientAvailableDaysNum = instance.patinetServiceDaySum;
    
    % 1. Select the number of days for patients with service availability > service frequency,
    % and determine the set of patients to be served each day.
    serviceDays = cell(instance.nrPatient,1);
    for i = 1 : instance.nrPatient 
        patientsServiceDays = [];
        for j = 1 : instance.period
            if patientAvailableDays(i,j) ~= -1
                
                patientsServiceDays(end+1) = j;
            end
        end
        serviceDays{i} = patientsServiceDays;
    end
    
    % Determine the days on which patients receive services
    SelectedPatients = cell(instance.nrPatient,1);
    for i = 1 : instance.nrPatient
        if patientAvailableDaysNum(i) > serviceFre(i)
            indices = randperm(patientAvailableDaysNum(i),serviceFre(i));
            SelectedPatients{i} = serviceDays{i}(indices);
        else 
            SelectedPatients{i} = serviceDays{i};
        end
    end
    
    % Construct a collection of patients receiving services each day. Format: [Patient ID, Service Model]
    dayPatiensSet = cell(instance.period,1); 
    for d = 1 : instance.period  
        
        singleDay = {};
        
        for i = 1 : instance.nrPatient
            if ismember(d,SelectedPatients{i})  
                serviceModle = patientAvailableServiceModel(i,d); 
                singleDay{end+1} = [i,serviceModle];
            end
        end
        dayPatiensSet{d} = singleDay;
    end
    
end

