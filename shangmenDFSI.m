% Forward starting interval algorithm for door-to-door service
function [F,WIF]= shangmenDFSI(instance,patientRoute,PatientsTimeWindow)
   
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
        for q = 1 : size(F{i-1},2)
            for t = seita : instance.timewindowNum 
                if F{i-1,1}{1,q}(1) + instance.shangmenServicetime(patientRoute(i-1)) + instance.patientShangmenTraveltime(patientRoute(i-1)+1,patientRoute(i)+1) <= PatientsTimeWindow{i}(1,2*t)
                    p = size(current_F,2) + 1;  
                    if F{i-1,1}{1,q}(2) + instance.shangmenServicetime(patientRoute(i-1)) + instance.patientShangmenTraveltime(patientRoute(i-1)+1,patientRoute(i)+1) >= PatientsTimeWindow{i}(1,2*t-1)
                        E_ip = max(F{i-1,1}{1,q}(1)+instance.shangmenServicetime(patientRoute(i-1))+instance.patientShangmenTraveltime(patientRoute(i-1)+1,patientRoute(i)+1),PatientsTimeWindow{i}(1,2*t-1));
                        L_ip = min(F{i-1,1}{1,q}(2)+instance.shangmenServicetime(patientRoute(i-1))+instance.patientShangmenTraveltime(patientRoute(i-1)+1,patientRoute(i)+1),PatientsTimeWindow{i}(1,2*t));
                        w_ip = WIF{i-1,1}{1,q};
                    else
                        E_ip = PatientsTimeWindow{i}(1,2*t-1);
                        L_ip = PatientsTimeWindow{i}(1,2*t-1);
                        w_ip = WIF{i-1,1}{1,q} + PatientsTimeWindow{i}(1,2*t-1) - F{i-1,1}{1,q}(2) - instance.shangmenServicetime(patientRoute(i-1)) - instance.patientShangmenTraveltime(patientRoute(i-1)+1,patientRoute(i)+1);

                    end
                    %% Checking for dominance
                    if size(current_F,2) >= 1
                        if E_ip <= current_F{end}(1) && (current_W{end} - w_ip) >= (current_F{end}(2) - L_ip)
                       
                            current_F{end} = [E_ip,L_ip];
                            current_W{end} = w_ip;
                        else
                            if current_F{end}(1) <= E_ip && (current_F{end}(2) - L_ip) >= (current_W{end} - w_ip)


                            else
                          
                                current_F{end+1} = [E_ip,L_ip];
                                current_W{end+1} = w_ip;
                            end
                        end
                    else
                  
                        current_F{end+1} = [E_ip,L_ip];
                        current_W{end+1} = w_ip;
                    end
                    if F{i-1,1}{1,q}(2) + instance.shangmenServicetime(patientRoute(i-1))+instance.patientShangmenTraveltime(patientRoute(i-1)+1,patientRoute(i)+1) <= PatientsTimeWindow{i}(1,2*t)
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
