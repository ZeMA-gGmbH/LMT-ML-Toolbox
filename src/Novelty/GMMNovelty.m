classdef GMMNovelty < NDSuperCalss
    %KNNNOVELTY Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        gmm = [];
        K = [];
    end
    
    methods
        function this = GMMNovelty(K)
            if nargin > 0
                if exist('K', 'var') && ~isempty(K)
                    %If not set here it will be set by brute force search
                    %during training. Set it here to prevent training time
                    this.K = K;
                end
            end
        end

        function train(this, data)
            if isempty(this.K)
                %heuristic, if K has not been set in consturctor
                eva = evalclusters(data,'kmeans','gap','KList',(1:50));
                this.K = eva.OptimalK;
            end
            this.gmm = fitgmdist(data, this.K, 'Options',statset('MaxIter',200),'CovType','diagonal', 'SharedCov',true, 'Regularize',0.01);
            this.th = this.computeThreshold(data);
        end
        
        function scores = apply(this, data)
            scores = pdf(this.gmm, data);
        end
        
        function thresh = computeThreshold(this, data)
            scores = this.apply(data);
            thresh = mean(scores) - 3*std(scores);
        end
    end
    
end

