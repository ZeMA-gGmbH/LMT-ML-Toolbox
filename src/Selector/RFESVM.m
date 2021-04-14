classdef RFESVM < FSSuperClass
    %RFESVMEXTRACTOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function this = RFESVM(numFeat)
            if nargin > 0
                if exist('numFeat', 'var') && ~isempty(numFeat)
                    this.nFeat = numFeat;
                end
            end
        end
        
        function train(this, X, Y)
            X = zscore(X);
            subsInd = true(1, size(X,2));
            nSelected = size(X,2);
            
            numToSel = 1;
            rank = inf(1,size(X,2));

            %delete features that have nan values
            while any(any(isnan(X(:,subsInd)))) && (nSelected > numToSel)
                ind = find(subsInd);
                ex = find(any(isnan(X(:,subsInd)), 1));
                ex = ex(1);
                subsInd(ind(ex)) = false;
                nSelected = nSelected - 1;
                if nargout == 2
                    rank(ind(ex)) = nSelected;
                end
            end
            
            while nSelected > numToSel
                %train linear SVM
                t = templateSVM('KernelFunction', 'linear','IterationLimit',20);
                mdl = fitcecoc(X(:,subsInd), Y, 'Coding', 'onevsone', 'Learners', t, 'Options', statset('UseParallel', true));
                %get weight vector
                weights = zeros(length(mdl.BinaryLearners{1}.Beta), 1);
                for i = 1:length(mdl.BinaryLearners)
                    weights = weights + abs(mdl.BinaryLearners{i}.Beta);
                end
                %eliminate worst feature
                ind = find(subsInd);
                [~, ex] = min(weights);
                subsInd(ind(ex)) = false;
                nSelected = nSelected - 1;
                rank(ind(ex)) = nSelected;
            end
            [~, this.rank] = sort(-rank, 'descend');
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

