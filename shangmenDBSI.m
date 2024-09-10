% Backward starting interval algorithm for door-to-door service
function [F,WIF]= shangmenDBSI(instance,patientRoute,PatientsTimeWindow)
    % The last initialization
    F1 = cell(1,instance.timewindowNum);
    W1_F = cell(1,instance.timewindowNum);   
    for i = 1 : numel(F1)  
        F1{i} = [PatientsTimeWindow{end}(2*i-1:2*i)];
        W1_F{i} = 0;
    end
    
  
    F = cell(numel(patientRoute),1);
    WIF = cell(numel(patientRoute),1);
    F{end} = F1;
    WIF{end} = W1_F;
    for j = 1 : numel(patientRoute) - 1
        F{j} = {};
        WIF{j} = {};
    end

    for i = numel(patientRoute)-1 : -1 : 1  
        current_F = {};
        current_W = {};
     
        seita = 1;
        for q = 1 : size(F{i+1},2)
            for t = seita : instance.timewindowNum 
                if F{i+1,1}{1,q}(2) - instance.shangmenServicetime(patientRoute(i)) - instance.patientShangmenTraveltime(patientRoute(i)+1,patientRoute(i+1)+1) >= PatientsTimeWindow{i}(1,2*t-1) % 判断左时间窗
                    p = size(current_F,2) + 1; 
                    if F{i+1,1}{1,q}(1) - instance.shangmenServicetime(patientRoute(i)) - instance.patientShangmenTraveltime(patientRoute(i)+1,patientRoute(i+1)+1) <= PatientsTimeWindow{i}(1,2*t) % 判断右时间窗
                        E_ip = max(F{i+1,1}{1,q}(1)-instance.shangmenServicetime(patientRoute(i))-instance.patientShangmenTraveltime(patientRoute(i)+1,patientRoute(i+1)+1),PatientsTimeWindow{i}(1,2*t-1));
                        L_ip = min(F{i+1,1}{1,q}(2)-instance.shangmenServicetime(patientRoute(i))-instance.patientShangmenTraveltime(patientRoute(i)+1,patientRoute(i+1)+1),PatientsTimeWindow{i}(1,2*t));
                        w_ip = WIF{i+1,1}{1,q};
                    else
                        E_ip = PatientsTimeWindow{i}(1,2*t); 
                        L_ip = PatientsTimeWindow{i}(1,2*t); 
                        w_ip = WIF{i+1,1}{1,q} + F{i+1,1}{1,q}(1)-instance.shangmenServicetime(patientRoute(i))-instance.patientShangmenTraveltime(patientRoute(i)+1,patientRoute(i+1)+1)-PatientsTimeWindow{i}(1,2*t);
                    end

                  
                    if size(current_F,2) >= 1
                        if L_ip >= current_F{end}(2) && (current_W{end} - w_ip) >= (E_ip - current_F{end}(1))
                           
                            current_F{end} = [E_ip,L_ip];
                            current_W{end} = w_ip;
                        else
                            
                            if current_F{end}(2) >= L_ip && (E_ip - current_F{end}(1)) >= ((current_W{end} - w_ip))
                                
                            else
                           
                                current_F{end+1} = [E_ip,L_ip];
                                current_W{end+1} = w_ip;
                            end
                        end
                    else
                        
                        current_F{end+1} = [E_ip,L_ip];
                        current_W{end+1} = w_ip;
                    end
                    
                    if F{i+1,1}{1,q}(2) - instance.shangmenServicetime(patientRoute(i)) - instance.patientShangmenTraveltime(patientRoute(i)+1,patientRoute(i+1)+1) <= PatientsTimeWindow{i}(1,2*t)
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
