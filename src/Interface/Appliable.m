classdef (Abstract) Appliable < handle
    %Appliable interface
    
    methods (Abstract)
        feat = apply(this, data);
    end
end
