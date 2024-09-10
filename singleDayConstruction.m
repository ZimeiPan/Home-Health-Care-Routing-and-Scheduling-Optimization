%% Construction of daily initial solutions

function [day_Schedule,WorkerPatientSerNum,WorkerDuration] = singleDayConstruction(instance,WorkerPatientSerNum,WorkerDuration,d_shangmen,d_xianshang,d_menzhen,d)
    
    indices = find(WorkerDuration > 0);    
    serviceableWorker = [indices,instance.workerSkill(indices)];
    
    %% Structuring of door-to-door services
    shangmenSchedule = {};
    unServedShangmen = d_shangmen; 
    while(~isempty(unServedShangmen))
        
        randomIndex = randi(numel(unServedShangmen));
        randomPatientID = unServedShangmen(randomIndex);  

       
        [QualifiedWorkerID,QualifiedWorkerSkill] = findQualifiedWorker(instance,randomPatientID,serviceableWorker);
        
        route_part1 = [QualifiedWorkerID,0]; 
        route_part2 = [0,randomPatientID,0]; 
    
   
        unServedShangmen = removePatient(unServedShangmen,randomPatientID);
        serviceableWorker = removeWorker(serviceableWorker,QualifiedWorkerID);
        WorkerDuration(QualifiedWorkerID) = WorkerDuration(QualifiedWorkerID) - 1; 
        WorkerPatientSerNum(QualifiedWorkerID,randomPatientID) = WorkerPatientSerNum(QualifiedWorkerID,randomPatientID) + 1;
        

        QualifiedPatients = findQualifiedPatients(instance,unServedShangmen,QualifiedWorkerSkill);
        
        while(~isempty(QualifiedPatients))
            % Find the optimal patient ID based on the number of services criterion
            % Find the optimal location of its corresponding insertion based on cost
            [flag,bestCandidateList] = findOptimalPatientAndLocation(instance,d,QualifiedPatients,WorkerPatientSerNum,route_part1,route_part2);

            if ~flag 
                break;  
            else 
                bestInsertinPatientID = bestCandidateList(1);
                bestInsertLocation = bestCandidateList(2);
                
                unServedShangmen = removePatient(unServedShangmen,bestInsertinPatientID);
          
                QualifiedPatients = removePatient(QualifiedPatients,bestInsertinPatientID);
             
                WorkerPatientSerNum(QualifiedWorkerID,bestInsertinPatientID) = WorkerPatientSerNum(QualifiedWorkerID,bestInsertinPatientID) + 1;
              
                route_part2 = [route_part2(1:bestInsertLocation-1),bestInsertinPatientID,route_part2(bestInsertLocation:end)];
            end
        end
        shangmenSchedule{end + 1} = {route_part1,route_part2};
    end
    
    %% Constructing online services
    xianshangSchedule = {};
    unServedxianshang = d_xianshang; 
    while(~isempty(unServedxianshang)) 
        
        randomIndex = randi(numel(unServedxianshang));
        randomPatientID = unServedxianshang(randomIndex); 
        
  
        [QualifiedWorkerID,QualifiedWorkerSkill] = findQualifiedWorker(instance,randomPatientID,serviceableWorker);
       
        route_part1 = [QualifiedWorkerID,1]; 
        route_part2 = [0,randomPatientID,0]; 
        
        unServedxianshang = removePatient(unServedxianshang,randomPatientID);
        serviceableWorker = removeWorker(serviceableWorker,QualifiedWorkerID);
        WorkerDuration(QualifiedWorkerID) = WorkerDuration(QualifiedWorkerID) - 1;
        WorkerPatientSerNum(QualifiedWorkerID,randomPatientID) = WorkerPatientSerNum(QualifiedWorkerID,randomPatientID) + 1;
        
        QualifiedPatients = findQualifiedPatients(instance,unServedxianshang,QualifiedWorkerSkill);
        
        while(~isempty(QualifiedPatients))
            [flag,bestCandidateList] = findOptimalPatientAndLocation(instance,d,QualifiedPatients,WorkerPatientSerNum,route_part1,route_part2);

            if ~flag
                break;  
            else 
                bestInsertinPatientID = bestCandidateList(1);
                bestInsertLocation = bestCandidateList(2);
 
                unServedxianshang = removePatient(unServedxianshang,bestInsertinPatientID);
                QualifiedPatients = removePatient(QualifiedPatients,bestInsertinPatientID);
                WorkerPatientSerNum(QualifiedWorkerID,bestInsertinPatientID) = WorkerPatientSerNum(QualifiedWorkerID,bestInsertinPatientID) + 1;
                route_part2 = [route_part2(1:bestInsertLocation-1),bestInsertinPatientID,route_part2(bestInsertLocation:end)];
            end
        end
        xianshangSchedule{end + 1} = {route_part1,route_part2};
    end

    %% Structured outpatient services
    menzhenSchedule = {};
    unServedmenzhen = d_menzhen; 
    while(~isempty(unServedmenzhen)) 
 
        randomIndex = randi(numel(unServedmenzhen));
        randomPatientID = unServedmenzhen(randomIndex);


        [QualifiedWorkerID,QualifiedWorkerSkill] = findQualifiedWorker(instance,randomPatientID,serviceableWorker);

        route_part1 = [QualifiedWorkerID,2]; 
        route_part2 = randomPatientID; 

        unServedmenzhen = removePatient(unServedmenzhen,randomPatientID); 
        serviceableWorker = removeWorker(serviceableWorker,QualifiedWorkerID);
        WorkerDuration(QualifiedWorkerID) = WorkerDuration(QualifiedWorkerID) - 1; 
        WorkerPatientSerNum(QualifiedWorkerID,randomPatientID) = WorkerPatientSerNum(QualifiedWorkerID,randomPatientID) + 1;

        QualifiedPatients = findQualifiedPatients(instance,unServedmenzhen,QualifiedWorkerSkill);
        
        QualifiedWorkerServiceRate = instance.workerServicerate(QualifiedWorkerID);
        upperServicePatientNum = QualifiedWorkerServiceRate * instance.workerServiceDuration; 

        while((~isempty(QualifiedPatients)) && numel(route_part2) < upperServicePatientNum - 1)
            [flag,bestCandidateList] = findOptimalPatientAndLocation(instance,d,QualifiedPatients,WorkerPatientSerNum,route_part1,route_part2);
            
            if ~flag 
                break;  
            else 
                bestInsertinPatientID = bestCandidateList(1);
                unServedmenzhen = removePatient(unServedmenzhen,bestInsertinPatientID);
                QualifiedPatients = removePatient(QualifiedPatients,bestInsertinPatientID);
                WorkerPatientSerNum(QualifiedWorkerID,bestInsertinPatientID) = WorkerPatientSerNum(QualifiedWorkerID,bestInsertinPatientID) + 1;
                route_part2(end+1) = bestInsertinPatientID;
            end
        end
        menzhenSchedule{end+1} = {route_part1,route_part2};
    end
    day_Schedule = {shangmenSchedule,xianshangSchedule,menzhenSchedule};
end
%% Remove the patient from unserved patients
function NewUnServed = removePatient(OldUnServed,randomPatientID)
    indexToRemove = (OldUnServed == randomPatientID);
    NewUnServed = OldUnServed;
    NewUnServed(indexToRemove) = [];
end

%% Remove already utilized healthcare workers from serviceable healthcare caregivers
function newServiceableWorker = removeWorker(oldServiceableWorker,workerID)
    indexToRemove = (oldServiceableWorker(:,1) == workerID);
    newServiceableWorker = oldServiceableWorker;
    newServiceableWorker(indexToRemove,:) = [];
end

%% Identify eligible patients based on the skill level of the healthcare worker - no longer differentiates between service models.
function QualifiedPatients = findQualifiedPatients(instance,unServed,QualifiedWorkerSkill)
    min_skill = max(QualifiedWorkerSkill - instance.skillDiff, 1);
    p_skill = min_skill : QualifiedWorkerSkill;
    unServePatientSkill = instance.patientSkill(unServed,:)'; 
    QualifiedPatients = unServed(ismember(unServePatientSkill,p_skill));
end
