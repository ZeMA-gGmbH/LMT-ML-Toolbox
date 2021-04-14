classdef SVMNovelty < NDSuperCalss
    %KNNNOVELTY Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        SVMModel = [];
    end
    
    methods
        function this = SVMNovelty()
            this.isNoveltyMeasure = false;
        end
        
        function train(this, data)
            Y = ones(size(data,1),1);
            this.SVMModel = fitcsvm(data,Y,'KernelFunction','rbf','KernelScale','auto');
            this.th = this.computeThreshold(data);
        end
        
        function scores = apply(this, data)
            [~,scores] = predict(this.SVMModel, data);
        end
        
        function thresh = computeThreshold(~, ~)
            thresh = 0;
        end
    end
    
end

