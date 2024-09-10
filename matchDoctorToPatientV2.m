% Skill matching function - optimized version - only calculates the portion to be moved
% routePart2：The part to be inserted

function flag = matchDoctorToPatientV2(instance,routePart1,routePart2)
    flag = true;
   
    workerID = routePart1(1);
    workerSkill = instance.workerSkill(workerID);

    minSkill = min(1,workerSkill-instance.skillDiff);
    skillRange = minSkill : workerSkill; 
    
    for i = 1 : numel(routePart2)
        if routePart2(i) ~= 0 
            if ~ismember(instance.patientSkill(routePart2(i)),skillRange) 
                flag = false;
                break;
            end
        end
    end
end

