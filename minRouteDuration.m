
% Minimize the duration function of the route
% Using forward time interval and backward time interval algorithms
function optimalOutput = minRouteDuration(instance,routePart1,routePart2,d)

    serviceModel = routePart1(2);

    PatientsTimeWindow = cell(1,numel(routePart2)-2);
    if serviceModel == 0 

        for i = 2 : numel(routePart2)-1
            TimeWindow = instance.shangmenTimeWindows(routePart2(i),(d-1)*instance.timewindowNum*2+1:d*instance.timewindowNum*2);
            PatientsTimeWindow{i-1} = TimeWindow;
        end
        patientRoute = routePart2(2:end-1); 
     
        [shangmenDFSI_F,shangmenDFSI_WIF] = shangmenDFSI(instance,patientRoute,PatientsTimeWindow);
        
        [shangmenDBSI_F,shangmenDBSI_WIF]= shangmenDBSI(instance,patientRoute,PatientsTimeWindow);
        
        %% The solution of the dominance is retained
        kexingroute = cell(numel(shangmenDFSI_F{end}),1);
        minRoute = cell(numel(shangmenDFSI_F{end}),1); 

        %% Find the beginning and end of each path
        for i = 1 : numel(shangmenDFSI_F{end})
            s_1 =  shangmenDBSI_F{1,1}{1,i}(1);
            a_0 = s_1 - instance.patientShangmenTraveltime(1,patientRoute(1)+1);
            s_end = shangmenDFSI_F{end,1}{1,i}(1);
            b_0 = s_end + instance.patientShangmenTraveltime(1,patientRoute(end)+1);
            w = shangmenDFSI_WIF{end,1}{i};
            kexingroute{i} = [s_1,s_end,w];
            minRoute{i} = [a_0,b_0,w];
        end
        %% Determine the solution that meets the requirements
        kexingOutput = {};
        for i = 1 : numel(shangmenDFSI_F{end})
            if minRoute{i}(1) >=0 && minRoute{i}(2) <= instance.openDuration && minRoute{i}(2)- minRoute{i}(1)<= instance.workerServiceDuration
                kexingOutput{end+1} = minRoute{i};
            end
        end
        
    else 

        for i = 2 : numel(routePart2)-1
         
            TimeWindow = instance.xianshangTimeWindows(routePart2(i),(d-1)*instance.timewindowNum*2+1:d*instance.timewindowNum*2);
            PatientsTimeWindow{i-1} = TimeWindow;
        end
        patientRoute = routePart2(2:end-1); 
        [xianshangDFSI_F,xianshangDFSI_WIF] = xianshangDFSI(instance,patientRoute,PatientsTimeWindow);
        [xianshangDBSI_F,xianshangDBSI_WIF] = xianshangDBSI(instance,patientRoute,PatientsTimeWindow);
        
        %% Reservation of dominant solutions
        kexingroute = cell(numel(xianshangDFSI_F{end}),1);
        minRoute = cell(numel(xianshangDFSI_F{end}),1);
        
        %% Find the beginning and end of each path
        for i = 1 : numel(xianshangDFSI_F{end})
            %% The possibility that a_0 is less than 0 is a poorly designed time window
            s_1 =  xianshangDBSI_F{1,1}{1,i}(1);
            a_0 = s_1 - instance.patientsXianshangTraveltime(1,patientRoute(1)+1);
            s_end = xianshangDFSI_F{end,1}{1,i}(1);
            b_0 = s_end;
            w = xianshangDFSI_WIF{end,1}{i};
            kexingroute{i} = [s_1,s_end,w];
            minRoute{i} = [a_0,b_0,w];
        end
        %% Determine the solution that meets the requirements
        kexingOutput = {};
        for i = 1 : numel(xianshangDFSI_F{end})
            if minRoute{i}(1) >=0 && minRoute{i}(2) <= instance.openDuration && minRoute{i}(2)- minRoute{i}(1)<= instance.workerServiceDuration
                kexingOutput{end+1} = minRoute{i};
            end
        end        
    end

    %% Finding an optimal solution - as short a departure time as possible and as small a waiting time as possible
    optimalOutput = kexingOutput{1};
    for i = 1 : numel(kexingOutput)
        if optimalOutput(3) > kexingOutput{i}(3)
            
            optimalOutput = kexingOutput{i};
        end
    end
end

