classdef ClassificationError < handle
    %CLASSIFICATIONERROR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods (Static)
        function l = loss(pred, target)
            %Classification error in %
            %ToDo: also allow non-numerical classes (cell arrays of strings)
            try
                l = sum(pred~=target)/size(target,1) * 100;
            catch ME
                disp(ME);
                disp(ME.stack)
                l = 100;
            end
        end
    end
end

