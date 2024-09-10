function Schedule = robustFunction(func,instance)
% func: the handle of the function to try to execute
% varargin: the parameter to pass to func 
% initialize a flag variable that indicates whether the function was successfully executed or not
    success = false;
    
    attempts = 0;

    % Loop until the function executes successfully or reaches the maximum number of attempts
    while ~success && attempts < 50 
        try
            % Trying to execute a function
            Schedule = func(instance);
           
            success = true;
        catch ME
        
            fprintf('Attempt %d failed: %s\n', attempts, ME.message);
     
            attempts = attempts + 1;
    
            pause(1); 
        end
    end

  
    if ~success
        error('Function failed after %d attempts.', attempts);
    end
end

