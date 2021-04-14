classdef AECNovelty < NDSuperCalss
    %KNNNOVELTY Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        autoenc = [];
        maxEpochs = 500;
        hiddenSize = [];
    end
    
    methods
        function this = AECNovelty(hiddenSize, maxEpochs)
            if nargin > 0
                if exist('hiddenSize', 'var') && ~isempty(hiddenSize)
                    %if not set here it will be set during training by
                    %heuristic
                    this.hiddenSize = hiddenSize;
                end
                if exist('maxEpochs', 'var') && ~isempty(maxEpochs)
                    this.maxEpochs = maxEpochs;
                end
            end
        end
        
        %ToDo: Implement functions
        function train(this, data)
            if isempty(this.hiddenSize)
                this.hiddenSize = ceil((size(data,1))^(0.05));
            end
            this.autoenc = trainAutoencoder(data', this.hiddenSize, 'MaxEpochs', this.maxEpochs, 'UseGPU', true);
            nntraintool('close');
            this.th = this.computeThreshold(data);
        end
        
        function scores = apply(this, data)
            test_autoencode = predict(this.autoenc, data');
            scores = sqrt(sum((test_autoencode-data').^2, 1))';
        end
        
        function thresh = computeThreshold(this, data)
            %heuristic
            scores = this.apply(data);
            thresh = 2 * mean(scores);
        end
    end
    
end

