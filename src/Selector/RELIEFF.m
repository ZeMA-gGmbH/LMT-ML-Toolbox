classdef RELIEFF < FSSuperClass
    %RELIEFFSELECTOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function this = RELIEFF(numFeat)
            if nargin > 0
                if exist('numFeat', 'var') && ~isempty(numFeat)
                    this.nFeat = numFeat;
                end
            end
        end
        
        function train(this, X, Y)
            X = zscore(X);
            
            %Check, if there are at least four samples per group
            %(each one has three nearest neightbours)
            groups = unique(Y);
            numPerGroup = zeros(length(groups),1);
            for i = 1:length(groups)
                try
                    numPerGroup(i) = sum(Y == groups(i));
                catch
                    numPerGroup(i) = sum(strcmp(Y,groups{i}));
                end
            end
            n = min(numPerGroup);
            nNN = 3;
            if n <= 1
                error('empty group in reliefFUni');
            elseif n <= 3
                nNN = n - 1;
            end

            rank = zeros(1, size(X,2));

            for g = 1:length(groups)
                %Nearest Miss
                idxMiss = knnsearch( X(Y ~= groups(g),:), X(Y == groups(g),:), 'K', nNN, 'D', 'cityblock', 'NSMethod', 'kdtree');
                
                %Nearest Hits
                idxHit = knnsearch( X(Y == groups(g),:), X(Y == groups(g),:), 'K', nNN+1, 'D', 'cityblock', 'NSMethod', 'kdtree');
                idxHit = idxHit(:, 2:end);
                

                for i = 1:nNN
                    rank = rank + sum(abs(X(Y == groups(g),:) - X(idxMiss(:,i),:)), 1) - sum(abs(X(Y == groups(g),:) - X(idxHit(:,i),:)), 1);
                end
            end
            
            %rank = -rank;
            [~, this.rank] = sort(rank, 'descend');
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

