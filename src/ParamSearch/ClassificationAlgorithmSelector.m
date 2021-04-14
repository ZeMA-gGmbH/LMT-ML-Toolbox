classdef ClassificationAlgorithmSelector < SupervisedTrainable & Appliable
    %ALGORITHMSELECTOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        algStacksPlan = {};
        algStacks = {};
        algStackArgs = [];
        bestAlg = {};
        loss = [];
    end
    
    methods
        function this = ClassificationAlgorithmSelector(algStacksPlan, algStackArgs)
            if nargin > 0
                if exist('algStacksPlan', 'var') && ~isempty(algStacksPlan)
                    this.algStacksPlan = algStacksPlan;
                end
                if exist('algStackArgs', 'var') && ~isempty(algStackArgs)
                    this.algStackArgs = algStackArgs;
                end
            end
        end
        
        function train(this, data, target)
            %cross validate all algorithm plans
            algLoss = Inf(size(this.algStacksPlan));
            this.algStacks = cell(size(this.algStacksPlan));
            for i = 1:length(this.algStacksPlan)
                if ~isempty(this.algStackArgs)
                    cv = CrossValidator(this.algStacksPlan{i}, this.algStackArgs{i});
                else
                    cv = CrossValidator(this.algStacksPlan{i});
                end
                algLoss(i) = ClassificationError.loss(cv.crossValidate(data, target, cvpartition(target, 'KFold', 10)), target);
                this.algStacks{i} = cv;
            end
            
            %find out best algorithm plan
            [~, best] = min(algLoss);
            this.loss = algLoss;
            
            %train best algorithm plan on all data
            funPointer = this.algStacksPlan{best};
            if ~isempty(this.algStackArgs)
                this.bestAlg = feval(funPointer{1}, this.algStackArgs{best});
            else
                this.bestAlg = feval(funPointer{1});
            end
            this.bestAlg.train(data, target);
        end
        
        function result = apply(this,data)
            result = this.bestAlg.apply(data);
        end
    end
end

