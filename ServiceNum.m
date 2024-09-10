% Counting changes in patient and provider IDs for a partial pathway - change in number served by different providers

function Cost = ServiceNum(ptwMatrix,workerID,routePart,flag)
    Cost = 0;
    
    if flag == 1 
        for i = 1 : numel(routePart) 
            if routePart(i) ~= 0
                ptwMatrix(routePart(i),workerID) = ptwMatrix(routePart(i),workerID) - 1;
                if ptwMatrix(routePart(i),workerID) == 0
                    Cost = Cost - 1;
                end
            end
        end
    elseif flag == 2 
        for i = 1 : numel(routePart) 
            if routePart(i) ~= 0
                ptwMatrix(routePart(i),workerID) = ptwMatrix(routePart(i),workerID) + 1;
                if ptwMatrix(routePart(i),workerID) == 1
                    Cost = Cost + 1;
                end
            end
        end
    end
end

