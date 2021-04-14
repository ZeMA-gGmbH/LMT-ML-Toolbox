classdef CustomCVPartition < handle
    
    properties
        ind = [];
        NumObservations = [];
        NumTestSets = [];
        groups = [];
    end
    
    methods
        function this = CustomCVPartition(groupVector)
            if nargin > 0
                this.ind = groupVector;
                this.NumObservations = length(groupVector);
                this.NumTestSets = length(unique(groupVector));
                this.groups = unique(groupVector);
            end
        end
        
        function i = training(this, fold)
            i = this.ind ~= this.groups(fold);
        end
        
        function i = test(this, fold)
            i = this.ind == this.groups(fold);
        end
    end
end