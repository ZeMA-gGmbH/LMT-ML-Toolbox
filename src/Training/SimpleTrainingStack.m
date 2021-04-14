classdef SimpleTrainingStack < SupervisedTrainable & Appliable
    %SIMPLETRAININGSTACK Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        stack = {};
        obj = {};
        args = [];
    end
    
    methods
        function this = SimpleTrainingStack(s, args)
            if nargin > 1
                if exist('s', 'var') && ~isempty(s)
                    this.stack = s;
                end
                if exist('args', 'var') && ~isempty(args)
                    this.args = args;
                end
            end
        end
        
        function train(this, data, target)
            this.obj = cell(size(this.stack));
            for i = 1:length(this.stack)
                if ~isempty(this.args)
                    arguments = this.args{i};
                    this.obj{i} = feval(this.stack{i}, arguments{:});
                else
                    this.obj{i} = feval(this.stack{i});
                end
            end
            
            if nargin < 3
                %ToDo: confirm that all obj are unsupervised trainable or
                %do not need training. Otherwise throw error
            end
            
            for i = 1:length(this.stack)
                if isa(this.obj{i}, 'SupervisedTrainable')
                    this.obj{i}.train(data, target);
                elseif isa(this.obj{i}, 'UnSupervisedTrainable')
                    this.obj{i}.train(data);
                elseif ~isa(this.obj{i}, 'Appliable')
                    throw('invalid Object in SimpleTrainingStack')
                end

                data = this.obj{i}.apply(data);
            end
        end
        
        function results = apply(this, data)
            %ToDo: Confirm this is trained
            for i = 1:length(this.stack)
                data = this.obj{i}.apply(data);
            end
            results = data;
        end
        
        function infoCell = info(this)
            infoCell = [];
            firstFlag = false;
            for i = 1:size(this.obj,2)
                if(ismethod(this.obj{1,size(this.obj,2)+1-i},"info"))
                    if(firstFlag == true)
                        infoCellTemp1 = this.obj{size(this.obj,2)+1-i}.info();
                        if(size(infoCellTemp1,2)>2)
                            infoCellTemp2 = [infoCell cell(size(infoCell,1),size(infoCellTemp1,2)-2)];
                        else
                            infoCellTemp2 = infoCell;
                        end
                        %k = Feature
                        for k = 1:size(infoCellTemp2,1)
                            infoCellTemp2{k,1} = [];
                            infoCellTemp2{k,2} = [];
                            for j = 1:size(infoCell(k,2),1)
                                infoCellTemp2{k,2} = [infoCellTemp2{k,2} infoCellTemp1{infoCell{k,2}(j),2}];
                                infoCellTemp2{k,1} = [infoCellTemp2{k,1} infoCell{k,1}(j)*infoCellTemp1{infoCell{k,2}(j),1}];
                                if(size(infoCellTemp1,2)>2)
                                    for lv=1:size(infoCellTemp1,2)-2
                                        infoCellTemp2{k,lv+2} = [infoCellTemp2{k,lv+2} infoCellTemp1{infoCell{k,2}(j),lv+2}];
                                    end
                                    
                                end
                            end
                        end
                        infoCell = infoCellTemp2;
                        if(size(infoCellTemp1,2)>2)
                            %ToDo Add info About transformation that happend
                            break;
                        end

                    else
                        infoCell = this.obj{size(this.obj,2)+1-i}.info();    
                    end
                    firstFlag = true;
                else
                    infoCell = [];
                    firstFlag = false;
                end
            end
        end
        function show(this)
            for i = 1:size(this.obj,2)
                if ismethod(this.obj{1,i},"show")
                    this.obj{1,i}.show();
                end
            end
        end
    end
end

