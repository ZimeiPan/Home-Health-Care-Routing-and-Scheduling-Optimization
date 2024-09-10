%% Optimize scheduling for the day

function [flag,sortedSolutionSet] = InnerTabuSerch(instance,current_Schedule,currentDay,ServiceModel)
    
    flag = true; 
    TotalSet = [];
    %% Judge which domain operators to choose based on the service mode
    
    if ServiceModel == 0  
        %% operator
        % Single-point retargeting
        % two-point exchange
        % subsequence exchange
        % Healthcare caregiver exchange
        [relocateFlag,RelocateSolutionSet] = relocateRearch(instance,current_Schedule,currentDay,ServiceModel);
        [exchangeFlag,ExchangeSolutionSet] = exchangeSearch(instance,current_Schedule,currentDay,ServiceModel);
        [crossFlag,CrossSolutionSet] = crossSearch(instance,current_Schedule,currentDay,ServiceModel);

        [workerExchangeFlag,WorkerExchangeSolutionSet] = workerExchangeSearchV3(instance,current_Schedule,currentDay);
        % 1
        if relocateFlag == 1
            TotalSet= [TotalSet,RelocateSolutionSet];
        end
        
        % 2
        if exchangeFlag == 1
            TotalSet = [TotalSet,ExchangeSolutionSet];
        end

        % 3
        if crossFlag == 1
            TotalSet= [TotalSet,CrossSolutionSet];
        end
        
        % 4
        if workerExchangeFlag == 1
            TotalSet = [TotalSet,WorkerExchangeSolutionSet];
        end

    elseif ServiceModel == 1 

        [relocateFlag,RelocateSolutionSet] = relocateRearch(instance,current_Schedule,currentDay,ServiceModel);
        [exchangeFlag,ExchangeSolutionSet] = exchangeSearch(instance,current_Schedule,currentDay,ServiceModel);
        [crossFlag,CrossSolutionSet] = crossSearch(instance,current_Schedule,currentDay,ServiceModel);

        [workerExchangeFlag,WorkerExchangeSolutionSet] = workerExchangeSearchV3(instance,current_Schedule,currentDay);
        % 1
        if relocateFlag == 1
            TotalSet= [TotalSet,RelocateSolutionSet];
        end

        % 2
        if exchangeFlag == 1
            TotalSet = [TotalSet,ExchangeSolutionSet];
        end

        % 3
        if crossFlag == 1
            TotalSet= [TotalSet,CrossSolutionSet];
        end

        % 4
        if workerExchangeFlag == 1
            TotalSet = [TotalSet,WorkerExchangeSolutionSet];
        end


    else   
        [relocateFlag,RelocateSolutionSet] = relocateRearch(instance,current_Schedule,currentDay,ServiceModel);
        [exchangeFlag,ExchangeSolutionSet] = exchangeSearch(instance,current_Schedule,currentDay,ServiceModel);
        [workerExchangeFlag,WorkerExchangeSolutionSet] = workerExchangeSearchV3(instance,current_Schedule,currentDay);
        % 1
        if relocateFlag == 1
            TotalSet = [TotalSet,RelocateSolutionSet];
        end
        % 2
        if exchangeFlag == 1
            TotalSet = [TotalSet,ExchangeSolutionSet];
        end
        % 3
        if workerExchangeFlag == 1
            TotalSet = [TotalSet,WorkerExchangeSolutionSet];
        end
    end
    
    % For the generated solutions, sort them according to the value of the objective function
    if ~isempty(TotalSet)
        thirdColValues = cellfun(@(x) x{3}, TotalSet);  
        [~, sortIndex] = sort(thirdColValues);
        sortedSolutionSet = TotalSet(sortIndex);
    else
        flag = false;
        sortedSolutionSet = {};
    end
end

