% Decomposition into three service modes - line model

function NewSchedule = scheduleDivide(schedule)
    NewSchedule = cell(1,3);
    

    shangmenSchedule = {};
    xianshangSchedule = {};
    menzhenSchedule = {};
    
    for i = 1 : numel(schedule)
        if schedule{i}{1}(2) == 0
            shangmenSchedule{end + 1} = schedule{i};
        elseif schedule{i}{1}(2) == 1
            xianshangSchedule{end + 1} = schedule{i}; 
        else    
            menzhenSchedule{end + 1} = schedule{i};  
        end
    end

    NewSchedule{1} = shangmenSchedule;
    NewSchedule{2} = xianshangSchedule;
    NewSchedule{3} = menzhenSchedule;
end

