classdef StatisticalMoments < Appliable
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        nSeg = 10;
        dataLength = [];
    end
    
    methods
        function this = StatisticalMoments(numSegments)
            if nargin > 0
                if exist('numSegments', 'var') && ~isempty(numSegments)
                    this.nSeg = numSegments;
                end
            end
        end
        
        function infoCell = info(this)
            infoCell = cell(this.nSeg*4,3);
             for i = 1:this.nSeg
                %get indices for this segment
                start = (i-1) * ceil(this.dataLength/this.nSeg) + 1;
                stop = min(this.dataLength, i * ceil(this.dataLength/this.nSeg));
                infoCell{4*(i-1)+1,1} = ones(stop-start+1,1);
                infoCell{4*(i-1)+2,1} = ones(stop-start+1,1);
                infoCell{4*(i-1)+3,1} = ones(stop-start+1,1);
                infoCell{4*(i-1)+4,1} = ones(stop-start+1,1);
                infoCell{4*(i-1)+1,2} = start:stop;
                infoCell{4*(i-1)+2,2} = start:stop;
                infoCell{4*(i-1)+3,2} = start:stop;
                infoCell{4*(i-1)+4,2} = start:stop;
                infoCell{4*(i-1)+1,3} = "Mean";
                infoCell{4*(i-1)+2,3} = "Variance";
                infoCell{4*(i-1)+3,3} = "skewness";
                infoCell{4*(i-1)+4,3} = "kurtosis";
             end
        end
        
        function feat = apply(this, data)
            feat = cell(this.nSeg, 1);
            this.dataLength = size(data,2);
            for i = 1:this.nSeg
                f = zeros(size(data,1), 4);
                
                %get indices for this segment
                start = (i-1) * ceil(size(data,2)/this.nSeg) + 1;
                stop = min(size(data,2), i * ceil(size(data,2)/this.nSeg));
                ind = start:stop;
                
                %compute mean
                f(:,1) = mean(data(:,ind), 2);
                %compute standard deviation
                f(:,2) = std(data(:,ind), [], 2);
                %Remark: The old toolbox structure had skewness and
                %kurtosis switched. This was fixed here but will lead to
                %different feature order.
                %compute skewness
                f(:,3) = skewness(data(:,ind), [], 2);
                %compute kurtosis
                f(:,4) = kurtosis(data(:,ind), [], 2);
                
                feat{i} = f;
            end
            
            feat = horzcat(feat{:});
        end
    end
end

