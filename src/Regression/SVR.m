classdef SVR < SupervisedTrainable & Appliable
    %SVR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        kernel = 'rbf';
        C = 1;
        model = [];
    end
    
    methods
        function this = SVR(C, kernel)
            if exist('C', 'var') && ~isempty(C)
                this.C = C;
            end
            if exist('kernel', 'var') && ~isempty(kernel)
                this.kernel = kernel;
            end
        end
        
        function train(this, data, target)
            this.model = fitrsvm(data, target, 'KernelFunction', this.kernel, 'BoxConstraint', this.C, 'Standardize', true);
        end
        
        function pred = apply(this, data)
            pred = predict(this.model, data);
        end
    end
end

