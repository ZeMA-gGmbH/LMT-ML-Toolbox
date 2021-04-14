classdef (Abstract) SupervisedTrainable < handle
    %SUPERVISEDTRAINABLE 
    
    methods
        this = train(this, data, target);
    end
end

