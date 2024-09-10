% Determine whether an array is in an array of cells
function flag = isinTabu(insertone,Tabu)
   
     isEqualFunc = @(x) isequal(x, insertone);
  
     matches = cellfun(isEqualFunc, Tabu);

     if any(matches)
         flag = true;
     else
         flag = false;
     end
end

