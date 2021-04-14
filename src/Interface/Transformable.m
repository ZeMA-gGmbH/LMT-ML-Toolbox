classdef (Abstract) Transformable < handle
    %TRANSFORMABLE interface
    
    methods (Abstract)
        
        preTransformed = pretransform(this, rawData);
        features = applyToPretransformed(this, transformed);
        this = trainFromPreTransformed(this, transfomed);

    end
end

