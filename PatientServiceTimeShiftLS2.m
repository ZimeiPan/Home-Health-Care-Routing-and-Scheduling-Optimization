%% Patient acceptance service transformation operator
%% In this exchange, all the domain solutions are saved
function sortedSolutionSet = PatientServiceTimeShiftLS2(instance,schedule)
    
    SolutionSet = {}; 
 
    PatientsCondition = filterPatientsByCondition(instance,schedule);
    ptwMatrix = PatienToWorker(instance,schedule);
    ScheduleObj = calculateObjective(instance,schedule);
    
    for i = 1 : size(PatientsCondition,1)  
        for j = 1 : size(PatientsCondition{i,2},2)  
            for k = 1 : size(PatientsCondition{i,3},2)  
                ID = PatientsCondition{i,1};
                yijiesou = PatientsCondition{i,2}{j};
                weijiesou = PatientsCondition{i,3}{k};
                [flag,tempScehdule] = PatientServiceTimeShift(instance,schedule,ID,yijiesou,weijiesou,ptwMatrix,ScheduleObj);
                
                %% Save the optimal value of the time transformation of the service received by each patient
                if flag  
                    SolutionSet{end+1} = {[ID,yijiesou(1),weijiesou(1)],tempScehdule{1},tempScehdule{2}};
                end
            end
        end
    end

    % Sort the SolutionSet according to the target value
    thirdColValues = cellfun(@(x) x{3}, SolutionSet);  
    [~, sortIndex] = sort(thirdColValues);
    sortedSolutionSet = SolutionSet(sortIndex);
end
