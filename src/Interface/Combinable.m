classdef Combinable < handle
    %COMBINABLEINTERFACE 
    
    methods (Abstract)
        this = combine(this,traget);
    end
    
end

