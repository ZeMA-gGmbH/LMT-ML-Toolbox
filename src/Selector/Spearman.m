classdef Spearman < FSSuperClass
    %PEARSONSELECTOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function this = Spearman(numFeat)
           if nargin > 0
               this.nFeat = numFeat;
           end
        end
        
        function train(this, X, Y)
            %this.data = X;
            this.rank = abs(corr(X, Y, 'Type', 'Spearman'));
            this.rank(isnan(this.rank)) = 0;
            [~, this.rank] = sort(this.rank, 'descend');
            this.nFeat = min(this.nFeat, size(X,2));
        end
    end
    
end

