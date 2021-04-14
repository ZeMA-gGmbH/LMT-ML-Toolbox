classdef ANNRegressor < SupervisedTrainable & Appliable
    %ANNREGRESSOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        numHidden = 10;
        model = [];
        trainingTime = 3;
    end
    
    methods
        function this = ANNRegressor(numHidden, trainingTime)
            if exist('numHidden', 'var') && ~isempty(numHidden)
                this.numHidden = numHidden;
            end
            if exist('trainingTime', 'var') && ~isempty(trainingTime)
                this.trainingTime = trainingTime;
            end
        end
        
        function train(this, data, target)
            this.model = fitnet(this.numHidden);
            this.model.trainParam.max_fail = 1e10;
            this.model.trainParam.min_grad = 0;
            this.model.trainParam.epochs = 1e10;
            this.model.trainParam.time = this.trainingTime;
            this.model.trainParam.showWindow = false;
            this.model = train(this.model, data', target');
        end
        
        function pred = apply(this, data)
            pred = this.model(data')';
        end
    end
end

