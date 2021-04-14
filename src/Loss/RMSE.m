classdef RMSE < handle
    %CLASSIFICATIONERROR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods (Static)
        function l = loss(pred, target)
            %root of mean squared error
            try
                l = sqrt(mean((pred - target).^2));
            catch ME
                disp(ME);
                disp(ME.stack)
                l = Inf;
            end
        end
    end
end

