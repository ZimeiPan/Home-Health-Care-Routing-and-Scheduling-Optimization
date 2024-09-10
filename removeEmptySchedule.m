%% Remove empty routes from a route
function New_Sub_tour_VNS = removeEmptySchedule(instance,Sub_tour_VNS)
    New_Sub_tour_VNS = cell(3,1);
 
    for d = 1 : instance.period
        DaySchedule = Sub_tour_VNS{d}; 

        DayShangmen = DaySchedule{1};
        DayXianshang = DaySchedule{2};
        DayMenzhen = DaySchedule{3};
        

        New_DayShangmen = {};
        for i = 1 : numel(DayShangmen)
            if numel(DayShangmen{i}{2}) ~= 2 
                New_DayShangmen{end+1} = DayShangmen{i};
            end
        end
        

        New_DayXianshang = {};
        for i = 1 : numel(DayXianshang)
            if numel(DayXianshang{i}{2}) ~= 2 
                New_DayXianshang{end+1} = DayXianshang{i};
            end
        end
        

        New_DayMenzhen = {};
        for i = 1 : numel(DayMenzhen)
            if ~isempty(DayMenzhen{i}{2})
                New_DayMenzhen{end+1} = DayMenzhen{i};
            end
        end
        New_DaySchedule = {New_DayShangmen,New_DayXianshang,New_DayMenzhen};
        New_Sub_tour_VNS{d} = New_DaySchedule;
    end
end

