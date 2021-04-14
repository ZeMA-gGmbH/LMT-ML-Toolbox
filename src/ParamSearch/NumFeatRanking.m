classdef NumFeatRanking < SupervisedTrainable & Appliable
    %NUMFEATRANKING Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Constant)
        maxFeat = 200;
    end
    
    properties
        rankingAlg = @Pearson;
        ranking = [];
        loss = [];
        lossAlg = @ClassificationError.loss;
        predictionStack = {@LDAMahalClassifier};
        predArg = {{}};
        nFeat = 0;
    end
    
    methods
        
        function infoCell = info(this)
            infoCell = cell(this.nFeat,2);
            for i = 1:this.nFeat
                infoCell{i,1} = [1];
                infoCell{i,2} = [this.ranking(i)];
            end
        end
        
        function this = NumFeatRanking(rankingAlg, predictionStack, predArg, lossAlg)
            if nargin > 0
                if exist('rankingAlg', 'var') && ~isempty(rankingAlg)
                    this.rankingAlg = rankingAlg;
                end
                if exist('predictionStack', 'var') && ~isempty(predictionStack)
                    this.predictionStack = predictionStack;
                end
                if exist('predArg', 'var') && ~isempty(predArg)
                    this.predArg = predArg;
                end
                if exist('lossAlg', 'var') && ~isempty(lossAlg)
                    this.lossAlg = lossAlg;
                end
            end
        end
        
        function train(this, data, target)
            %get ranking
            rAlg = feval(this.rankingAlg);
            rAlg.train(data,target);
            this.ranking = rAlg.getRanking();
            
            %compute loss for each feature number
            cv = cvpartition(target, 'KFold', 10);
            l = Inf(min(this.maxFeat, size(data,2)), 1);
            
            predStack = this.predictionStack;
            pArg = this.predArg;
            r = this.ranking;
            parfor i = 1:min(this.maxFeat, size(data,2))
                evaluator = CrossValidator(predStack, pArg);
                cvPred = evaluator.crossValidate(data(:, r(1:i)), target, cv);
                l(i) = feval(this.lossAlg, cvPred, target);
            end
            this.loss = l;
            
            %get optimal number of features
            [~, this.nFeat] = min(this.loss);
        end
        
        function pred = apply(this, data)
            pred = data(:, this.ranking(1:this.nFeat));
        end
    end
end

