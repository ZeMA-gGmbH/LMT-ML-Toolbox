classdef SVMClassifier < CLSuperClass
    %SVMCLASSIFIER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        C = 1000;
        mdl = {};
        mu = [];
        sigma = [];
    end
    
    methods
        function this = SVMClassifier(C)
            if nargin > 0
                this.C = C;
            else
                this.C = 1000;
            end
        end
        
        function train(this, feat, target)
            [data, this.mu, this.sigma] = zscore(feat);
            template = templateSVM('BoxConstraint', this.C, 'CacheSize', 'maximal',...
                'KernelFunction', 'rbf', 'KernelScale', 'auto');
            this.mdl = fitcecoc(data, target, 'Coding', 'onevsone', 'Learners', template);
        end
        
        function pred = apply(this, feat)
            data = (feat - this.mu)./this.sigma;
            pred = this.mdl.predict(data);
        end
    end
end







