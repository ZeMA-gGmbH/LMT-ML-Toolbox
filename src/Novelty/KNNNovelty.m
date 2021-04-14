classdef KNNNovelty < NDSuperCalss
    %KNNNOVELTY Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        k = 5;
        trainData = [];
        nearestInd=[];
    end
    
    methods
        function this = KNNNovelty(K)
            if nargin > 0
                if exist('K', 'var') && ~isempty(K)
                    this.k = K;
                end
            end
            this.isNoveltyMeasure = true;
        end
        
        function train(this, data)
            this.trainData = data;
            this.th = this.computeThreshold(data);
        end
        
        function scores = apply(this, data)
            [~, scores] = knnsearch(this.trainData, data, 'K', this.k);
            scores = sum(scores, 2);
        end
        function scores = applyPerGroup(this,trainGroup, data,dataGroup)
             groups = unique(dataGroup);
             scores = zeros(length(data),1);
             this.nearestInd = zeros(length(data),this.k);
             for i =1:length(groups)
                 tGroupId = trainGroup==groups(i);
                 dGroupId = dataGroup==groups(i);
                 tData = this.trainData(tGroupId,:);
                 seekData = data(dGroupId,:);
                 [id, groupScores] = knnsearch(tData, seekData, 'K', this.k);
                 scores(dGroupId) = sum(groupScores, 2);
                 %this.nearestInd = id;
             end
            
        end
        
        function thresh = computeThreshold(this, ~)
            [~, scores] = knnsearch(this.trainData, this.trainData, 'K', this.k+1);
            thresh = 2 * mean(sum(scores, 2));
        end
    end
    
end

