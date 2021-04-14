classdef PLSR < SupervisedTrainable & Appliable
    %PLSR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        numComp = 5;
        beta = [];
    end
    
    methods
        function this = PLSR(numComp)
            if nargin > 0
                while iscell(numComp)
                    numComp = numComp{1,1};
                end
                this.numComp = numComp;
            end
        end
        
        function train(this, data, target)
            if(size(data,2)<this.numComp)
                %warning("less number of Components");
                this.numComp = size(data,2);
            end
            [~,~,~,~,this.beta] = plsregress(data,target,this.numComp);
        end
        
        function pred = apply(this, data)
            pred = [ones(size(data,1),1) data]*this.beta;
        end
    end
end

