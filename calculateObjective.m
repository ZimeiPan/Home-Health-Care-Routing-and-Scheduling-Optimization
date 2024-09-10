% Calculate the objective function value of a multi-period scheduling scheme
function totalObj = calculateObjective(instance,schedule)
    
    
    PatientToWorker = zeros(instance.nrPatient,instance.nrWorker);
    
    %% Cost 1: Costs associated with the three service modes
    CostPart1 = zeros(1,instance.period); 
    for d = 1 : instance.period
       
        [PatientToWorker,singleDayObj] = calculateSingelDayObj(instance,schedule{d},PatientToWorker,d);
        
        CostPart1(d) = singleDayObj;
    end
    
    %% Cost 2 - The cost of the number of different caregivers serving a patient
    
    ServiceObj = zeros(1,instance.nrPatient); 
    for i = 1 : instance.nrPatient
        ServiceObj(i) = sum(PatientToWorker(i,:));  
    end
    CostPart2 = sum(ServiceObj) * instance.serviceContinuityWeight; 

    totalObj = sum(CostPart1) + CostPart2;
end

