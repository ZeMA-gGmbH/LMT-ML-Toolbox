classdef Standardisation < UnSupervisedTrainable & Appliable
    
    properties
        mu = [];
        sigma = [];
    end
    
    methods
        function this = Standardisation()
        end
        
        function train(this, data)
            if iscell(data)
                [dataL idx] = max([size(data,1) size(data,2)]);
                
                this.mu = cell(1,dataL);
                this.sigma = cell(1,dataL);
                if idx == 2
                    for i = 1:dataL
                        [~, this.mu{i}, this.sigma{i}] = zscore(data{1,i});
                    end
                else
                    for i = 1:dataL
                        [~, this.mu{i}, this.sigma{i}] = zscore(data{i,1});
                    end 
                end
            else    
                [~, this.mu, this.sigma] = zscore(data);
            end
            
        end
        
        function z = apply(this,data)
            
             if iscell(data)
                [dataL idx] = max([size(data,1) size(data,2)]);
                
                z = cell(1,dataL);
                if idx == 2
                    for i = 1:dataL
                        z{1,i} = (data{1,i}-this.mu{1,i})./this.sigma{1,i};
                    end
                else
                    for i = 1:dataL
                        z{1,i} = (data{i,1}-this.mu{1,i})./this.sigma{1,i};
                    end 
                end
            else    
                z = (data-this.mu)./this.sigma;
            end

        end
    end
end

