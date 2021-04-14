classdef CrossValidator < handle
    %CROSSVALIDATOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        stack = {};
        obj = {};
        %cv = {};
        args = [];
    end
    
    methods
        function this = CrossValidator(s, args)
            if nargin > 0
                if exist('s', 'var') && ~isempty(s)
                    this.stack = s;
                end
                if exist('args', 'var') && ~isempty(args)
                    this.args = args;
                end
            end
        end
        
        function results = crossValidate(this, data, target, cv)
            this.obj = cell(cv.NumTestSets, 1);
            for i = 1:cv.NumTestSets
                ind = cv.training(i);
                this.obj{i} = SimpleTrainingStack(this.stack, this.args);
            %ToDo: better solution for allowing data to be both cell array
            %and matrix
                if iscell(data)
                    trainData = cellfun(@(a)a(ind,:), data, 'UniformOutput', false);
                else
                    trainData = data(ind,:);
                end
                this.obj{i}.train(trainData, target(ind));
            end
            
            results = zeros(cv.NumObservations,1);
            for i = 1:cv.NumTestSets
                if iscell(data)
                    results(cv.test(i)) = this.obj{i}.apply(cellfun(@(a)a(cv.test(i),:), data, 'UniformOutput', false));
                else
                    results(cv.test(i)) = this.obj{i}.apply(data(cv.test(i),:));
                end
            end
        end
    end
end

