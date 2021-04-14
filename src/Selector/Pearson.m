classdef Pearson < FSSuperClass
    %PEARSONSELECTOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function this = Pearson(numFeat)
           if nargin > 0
               this.nFeat = numFeat;
           end
        end
        
        function train(this, X, Y)
            %this.data = X;
            this.rank = abs(corr(X, Y));
            this.rank(isnan(this.rank)) = 0;
            [~, this.rank] = sort(this.rank, 'descend');
            this.nFeat = min(this.nFeat, size(X,2));
        end
        function infoCell = info(this)
            infoCell = cell(this.nFeat,2);
            for i = 1:this.nFeat
                infoCell{i,1} = [1];
                infoCell{i,2} = [this.rank(i)];
            end
        end
    end
    
end

