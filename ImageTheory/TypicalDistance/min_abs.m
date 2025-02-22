function min_value_index = min_abs(varargin)   
    min_abs_value = realmax * 1e308;    
    for i = 1 : 3
        abs_value = abs(varargin{i});        
        if abs_value < min_abs_value
            min_abs_value = abs_value;
            min_value_index = i;
        end
    end
end

