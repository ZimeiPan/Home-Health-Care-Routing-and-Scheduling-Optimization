% Filter the set of patients with variable number of days of service based on acceptable days > service frequency

function PatientsCondition = filterPatientsByCondition(instance,schedule)
    
    QulifiedPatients = [];
    for i = 1 : instance.nrPatient
        if instance.patinetServiceDaySum(i) > instance.patinetServiceFre(i)
            QulifiedPatients(end+1) = i;  
        end
    end
    
    % Iterate through the Schdule to get the days on which this patient is receiving services, and the service pattern, on which days they are likely to receive services
    PatientsCondition = cell(numel(QulifiedPatients),3);  
    for i = 1 : numel(QulifiedPatients)
         PatientsCondition{i,1} = QulifiedPatients(i);   
    end
    
    PatientsDay = instance.patinetServiceDay(QulifiedPatients,:);   
    for d = 1 : instance.period
        [PatientsCondition,PatientsDay] = addPatientsCondition(schedule{d},PatientsCondition,PatientsDay,d); 
    end

    % Add days not served and service pattern to PatientsCondition based on PatientsCondition and PatientsDay
    for i = 1 : size(PatientsCondition,1)
        for j = 1 : size(PatientsDay,2) 
            if PatientsDay(i,j) ~= -1  
               
                patientID = PatientsCondition{i,1};
                serviceModel = instance.patinetServiceModel(patientID,j);
                PatientsCondition{i,3}{end+1} = [j,serviceModel];
            end
        end
    end
end

% Extract eligible patients who received the service and those who did not receive the service mode
function  [PatientsCondition,PatientsDay] = addPatientsCondition(dayschedule,PatientsCondition,PatientsDay,d)
   
    dayshangmen = dayschedule{1};
    dayxianshang = dayschedule{2};
    daymenzhen = dayschedule{3};

    for i = 1 : numel(dayshangmen) 
        routePart2 = dayshangmen{i}{2};
        for j = 2 : numel(routePart2) - 1 
            if ismember(routePart2(j),cell2mat(PatientsCondition(:,1))) 
                index = (cell2mat(PatientsCondition(:,1)) == routePart2(j)); 
                PatientsCondition{index,2}{end+1} = [d,0];  
                PatientsDay(index,d) = -1; 
            end
        end
    end


    for i = 1 : numel(dayxianshang) 
        routePart2 = dayxianshang{i}{2};
        for j = 2 : numel(routePart2) - 1 
            if ismember(routePart2(j),cell2mat(PatientsCondition(:,1)))
                index = (cell2mat(PatientsCondition(:,1)) == routePart2(j));
                PatientsCondition{index,2}{end+1} = [d,1];  
                PatientsDay(index,d) = -1; 
            end
        end
    end


    for i = 1 : numel(daymenzhen)  
        routePart2 = daymenzhen{i}{2};
        for j = 1 : numel(routePart2) 
            if ismember(routePart2(j),cell2mat(PatientsCondition(:,1))) 
                index = (cell2mat(PatientsCondition(:,1)) == routePart2(j));
                PatientsCondition{index,2}{end+1} = [d,2];  
                PatientsDay(index,d) = -1; 
            end
        end
    end
end
