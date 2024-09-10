
% Find a healthcare caregiver ID who can serve a particular patient

function [QualifiedWorkerID,QualifiedWorkerSkill] = findQualifiedWorker(instance,randomPatientID,serviceableWorker)
    p_skill = instance.patientSkill(randomPatientID);
    

    max_skill = min(p_skill + instance.skillDiff, 3);

    
    w_skill = p_skill : max_skill; 
    

    w_no = find(ismember(serviceableWorker(:, 2), w_skill))';  

    candidateworkerID = serviceableWorker(w_no,1);

    QualifiedWorkerID = candidateworkerID(randi(numel(w_no)));  
    QualifiedWorkerSkill = serviceableWorker(ismember(serviceableWorker(:,1),QualifiedWorkerID),2);

end

