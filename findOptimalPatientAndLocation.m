%% For door-to-door and online service patients
function [flag,bestCandidateList] = findOptimalPatientAndLocation(instance,d,QualifiedPatients,WorkerPatientSerNum,route_part1,route_part2)
    flag = true;  
    
    %% Finding the optimal patient
    workerID = route_part1(1);
   
    maxValue = max(WorkerPatientSerNum(workerID,QualifiedPatients));

    maxIndices = find(WorkerPatientSerNum(workerID,QualifiedPatients) == maxValue);

    if length(maxIndices) > 1

        selectedIndex = maxIndices(randi(length(maxIndices)));
    else
        selectedIndex = maxIndices;
    end
    optimalPatientID = QualifiedPatients(selectedIndex);
    

    bestCandidateList = []; 
    candidateList = {};   
    
    %% Finding the optimal insertion position for different services
    if route_part1(2) == 0 || route_part1(2) == 1 
    
        beforeRouteCost = calculateSingelDay(instance,{route_part1,route_part2},d);
        for j = 2 : numel(route_part2) 
  
            newRoute = [route_part2(1:j-1),optimalPatientID,route_part2(j:end)];
            
          
            [multiFlag,durationFlag] = RouteDurationCheckerV2(instance,route_part1,newRoute,d);

            if multiFlag && durationFlag

                afterRouteCost = calculateSingelDay(instance,{route_part1,newRoute},d);
  
                costChange = afterRouteCost - beforeRouteCost;
                medList = [optimalPatientID,j,costChange];
                candidateList{end+1} = medList;
            else
                continue;
            end  
        end
    else 

        medList = [optimalPatientID,0,0];
        candidateList{end+1} = medList;
    end

    % 2.Sort the feasible insertion locations to find the one with the least insertion cost
    if numel(candidateList) == 0
       
        flag = false;
        return;
    else 

        bestCandidateList = candidateList{1};

        for i = 2 : numel(candidateList)
            if bestCandidateList(3) >=  candidateList{i}(3) 
                bestCandidateList = candidateList{i};
            end
        end
    end
end

