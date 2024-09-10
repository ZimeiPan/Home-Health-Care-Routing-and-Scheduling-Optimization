% Forward Start Interval Algorithm for Online Services
function [F,WIF]= xianshangDFSI(instance,patientRoute,PatientsTimeWindow)
    
    F1 = cell(1,instance.timewindowNum);
    W1_F = cell(1,instance.timewindowNum);
    
    for i = 1 : numel(F1)  
        F1{i} = [PatientsTimeWindow{1}(2*i-1:2*i)];
        W1_F{i} = 0;
    end

    F = cell(numel(patientRoute),1);
    WIF = cell(numel(patientRoute),1);
    F{1} = F1;
    WIF{1} = W1_F;
    for j = 2 : numel(patientRoute)
        F{j} = {};
        WIF{j} = {};
    end
    
    %% primary cycle
    for i = 2 : numel(patientRoute)
        current_F = {};
        current_W = {};
    
        seita = 1;
        % Iterate over the number of last dominated while forward start intervals
        for q = 1 : size(F{i-1},2)
            for t = seita : instance.timewindowNum 
                % Vehicle provides service at some forward time interval from the last 1 customer and before or within a certain time window to the current customer
                if F{i-1,1}{1,q}(1) + instance.xianshangServicetime(patientRoute(i-1)) + instance.patientsXianshangTraveltime(patientRoute(i-1)+1,patientRoute(i)+1) <= PatientsTimeWindow{i}(1,2*t)
                    if F{i-1,1}{1,q}(2) + instance.xianshangServicetime(patientRoute(i-1)) + instance.patientsXianshangTraveltime(patientRoute(i-1)+1,patientRoute(i)+1) >= PatientsTimeWindow{i}(1,2*t-1) % 判断左时间窗
                        E_ip = max(F{i-1,1}{1,q}(1)+instance.xianshangServicetime(patientRoute(i-1))+instance.patientsXianshangTraveltime(patientRoute(i-1)+1,patientRoute(i)+1),PatientsTimeWindow{i}(1,2*t-1));
                        L_ip = min(F{i-1,1}{1,q}(2)+instance.xianshangServicetime(patientRoute(i-1))+instance.patientsXianshangTraveltime(patientRoute(i-1)+1,patientRoute(i)+1),PatientsTimeWindow{i}(1,2*t));
                        w_ip = WIF{i-1,1}{1,q};
                    else
                        E_ip = PatientsTimeWindow{i}(1,2*t-1);
                        L_ip = PatientsTimeWindow{i}(1,2*t-1);
                        w_ip = WIF{i-1,1}{1,q} + PatientsTimeWindow{i}(1,2*t-1) - F{i-1,1}{1,q}(2) - instance.xianshangServicetime(patientRoute(i-1)) - instance.patientsXianshangTraveltime(patientRoute(i-1)+1,patientRoute(i)+1);

                    end
                    %% Checking for dominance
                    if size(current_F,2) >= 1
                        if E_ip <= current_F{end}(1) && (current_W{end} - w_ip) >= (current_F{end}(2) - L_ip)
                            
                            current_F{end} = [E_ip,L_ip];
                            current_W{end} = w_ip;
                        else
                            if current_F{end}(1) <= E_ip &&(current_F{end}(2) - L_ip) >= (current_W{end} - w_ip)
                                
                            else
                             
                                current_F{end+1} = [E_ip,L_ip];
                                current_W{end+1} = w_ip;
                            end
                        end
                    else
                        
                        current_F{end+1} = [E_ip,L_ip];
                        current_W{end+1} = w_ip;
                    end
                    if F{i-1,1}{1,q}(2) + instance.xianshangServicetime(patientRoute(i-1))+instance.patientsXianshangTraveltime(patientRoute(i-1)+1,patientRoute(i)+1) <= PatientsTimeWindow{i}(1,2*t)
                        seita = t;
                        break
                    end
                end
           end
        end
        F{i} = current_F;
        WIF{i} = current_W;
    end
end

