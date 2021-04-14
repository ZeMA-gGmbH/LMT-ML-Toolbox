classdef SpearmanLoss < handle
    %PEARSONSELECTOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods (Static)
        function l = loss(X, Y)
            try
                l = 1-abs(corr(X, Y, 'Type', 'Spearman'));
            catch ME
                disp(ME);
                l = Inf;
            end
        end
    end
    
end

