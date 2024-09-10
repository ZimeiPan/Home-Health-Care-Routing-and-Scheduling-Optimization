% Determine the daily collection of door-to-door, online, and outpatient patients based on the service mode

function [shangmenSet,xianshangSet,menzhenSet] = divideModel(dayPatiensSet)
    
    shangmenSet = [];
    xianshangSet = [];
    menzhenSet = [];
    
    for i = 1 : numel(dayPatiensSet)
        if dayPatiensSet{i}(2) == 0 
            shangmenSet(end + 1) = dayPatiensSet{i}(1);
        elseif dayPatiensSet{i}(2) == 1 
            xianshangSet(end + 1) = dayPatiensSet{i}(1);
        else 
            menzhenSet(end+1) = dayPatiensSet{i}(1);
        end
    end

end

