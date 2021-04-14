classdef SteffenExtractor < Appliable
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        nSegTime = 10;
        nSegFreq = 10;
        dataLength;
        freqLength;
    end
    
    methods
        function this = SteffenExtractor(numSegmentsTime, numSegmentsFreq)
            if nargin > 0
                if exist('numSegmentsTime', 'var') && ~isempty(numSegmentsTime)
                    %if only one argument is given, use the same number of
                    %segments for both domains
                    this.nSegTime = numSegmentsTime;
                    this.nSegFreq = numSegmentsTime;
                end
                if exist('numSegmentsFreq', 'var') && ~isempty(numSegmentsFreq)
                    this.nSegFreq = numSegmentsFreq;
                end
            end
        end
        
        function feat = apply(this, data)
            freqData = abs(fft(data, [], 2));
            freqData = freqData(:, 1:ceil(size(freqData,2)/2));
            
            featTime = cell(this.nSegTime, 1);
            featFreq = cell(this.nSegFreq, 1);

            this.dataLength = size(data,2);
            this.freqLength = size(freqData,2);
   
            for i = 1:this.nSegTime
                %get indices for this segment (Time domain)
                start = (i-1) * floor(size(data,2)/this.nSegTime) + 1;
                stop = min(size(data,2), i * ceil(size(data,2)/this.nSegTime));
                ind = start:stop;
                featTime{i} = this.applyFeatureFuns(data(:,ind));
            end
            for i = 1:this.nSegFreq
                %get indices for this segment (Frequency domain)
                start = (i-1) * floor(size(freqData,2)/this.nSegFreq) + 1;
                stop = min(size(freqData,2), i * ceil(size(freqData,2)/this.nSegFreq));
                ind = start:stop;
                featFreq{i} = this.applyFeatureFuns(freqData(:,ind));
            end
            
            feat = horzcat(featTime{:}, featFreq{:});
        end

	function infoCell = info(this)
            infoCell = cell(this.nSegTime*9+this.nSegFreq*9,3);
             for i = 1:this.nSegTime
                %get indices for this segment
                start = (i-1) * floor(this.dataLength/this.nSegTime) + 1;
                stop = min(this.dataLength, i * ceil(this.dataLength/this.nSegTime));

                infoCell{9*(i-1)+1,1} = ones(stop-start+1,1);
                infoCell{9*(i-1)+2,1} = ones(stop-start+1,1);
                infoCell{9*(i-1)+3,1} = ones(stop-start+1,1);
                infoCell{9*(i-1)+4,1} = ones(stop-start+1,1);
                infoCell{9*(i-1)+5,1} = ones(stop-start+1,1);
                infoCell{9*(i-1)+6,1} = ones(stop-start+1,1);
                infoCell{9*(i-1)+7,1} = ones(stop-start+1,1);
                infoCell{9*(i-1)+8,1} = ones(stop-start+1,1);
                infoCell{9*(i-1)+9,1} = ones(stop-start+1,1);

                infoCell{9*(i-1)+1,2} = start:stop;
                infoCell{9*(i-1)+2,2} = start:stop;
                infoCell{9*(i-1)+3,2} = start:stop;
                infoCell{9*(i-1)+4,2} = start:stop;
                infoCell{9*(i-1)+5,2} = start:stop;
                infoCell{9*(i-1)+6,2} = start:stop;
                infoCell{9*(i-1)+7,2} = start:stop;
                infoCell{9*(i-1)+8,2} = start:stop;
                infoCell{9*(i-1)+9,2} = start:stop;

                infoCell{9*(i-1)+1,3} = "Mean ST T";
                infoCell{9*(i-1)+2,3} = "Variance ST T";
                infoCell{9*(i-1)+3,3} = "cov ST T";
                infoCell{9*(i-1)+4,3} = "Max1 ST T";
                infoCell{9*(i-1)+5,3} = "Max2 ST T";
                infoCell{9*(i-1)+6,3} = "Min T";
                infoCell{9*(i-1)+7,3} = "skewness1 ST T";
                infoCell{9*(i-1)+8,3} = "skewness2 ST T";
                infoCell{9*(i-1)+9,3} = "Peak RMS ratio ST T";
             end

             for i = 1:this.nSegFreq
                %get indices for this segment
                start = (i-1) * floor(this.freqLength/this.nSegFreq) + 1;
                stop = min(this.freqLength, i * ceil(this.freqLength/this.nSegFreq));

                infoCell{9*(i-1)+1+9*this.nSegTime,1} = ones(stop-start+1,1);
                infoCell{9*(i-1)+2+9*this.nSegTime,1} = ones(stop-start+1,1);
                infoCell{9*(i-1)+3+9*this.nSegTime,1} = ones(stop-start+1,1);
                infoCell{9*(i-1)+4+9*this.nSegTime,1} = ones(stop-start+1,1);
                infoCell{9*(i-1)+5+9*this.nSegTime,1} = ones(stop-start+1,1);
                infoCell{9*(i-1)+6+9*this.nSegTime,1} = ones(stop-start+1,1);
                infoCell{9*(i-1)+7+9*this.nSegTime,1} = ones(stop-start+1,1);
                infoCell{9*(i-1)+8+9*this.nSegTime,1} = ones(stop-start+1,1);
                infoCell{9*(i-1)+9+9*this.nSegTime,1} = ones(stop-start+1,1);

                infoCell{9*(i-1)+1+9*this.nSegTime,2} = start:stop;
                infoCell{9*(i-1)+2+9*this.nSegTime,2} = start:stop;
                infoCell{9*(i-1)+3+9*this.nSegTime,2} = start:stop;
                infoCell{9*(i-1)+4+9*this.nSegTime,2} = start:stop;
                infoCell{9*(i-1)+5+9*this.nSegTime,2} = start:stop;
                infoCell{9*(i-1)+6+9*this.nSegTime,2} = start:stop;
                infoCell{9*(i-1)+7+9*this.nSegTime,2} = start:stop;
                infoCell{9*(i-1)+8+9*this.nSegTime,2} = start:stop;
                infoCell{9*(i-1)+9+9*this.nSegTime,2} = start:stop;

                infoCell{9*(i-1)+1+9*this.nSegTime,3} = "Mean ST F";
                infoCell{9*(i-1)+2+9*this.nSegTime,3} = "Variance ST F";
                infoCell{9*(i-1)+3+9*this.nSegTime,3} = "cov ST F";
                infoCell{9*(i-1)+4+9*this.nSegTime,3} = "Max1 ST F";
                infoCell{9*(i-1)+5+9*this.nSegTime,3} = "Max2 ST F";
                infoCell{9*(i-1)+6+9*this.nSegTime,3} = "Min F";
                infoCell{9*(i-1)+7+9*this.nSegTime,3} = "skewness1 ST F";
                infoCell{9*(i-1)+8+9*this.nSegTime,3} = "skewness2 ST F";
                infoCell{9*(i-1)+9+9*this.nSegTime,3} = "Peak RMS ratio ST F";
             end
        end
 
    end
    
    methods(Static)
        function f = applyFeatureFuns(data)
            f = zeros(size(data,1), 9);
            ind = 1:size(data,2);

            %RMS
            f(:,1) = rms(data, 2);
            %compute variance
            f(:,2) = var(data, [], 2);
            %linear slope
            xm = ind'-mean(ind);
            ym = data(:,ind)-mean(data,2);
            f(:,3) = (ym*xm)./sum(xm.^2);
            %position of peak and hights of peak
            [f(:,5), f(:,4)] = max(data, [], 2);
            %minimal value
            f(:,6) = min(data, [], 2);
            %compute skewness and kurtosis
            [f(:,7), f(:,8)] = SteffenExtractor.fastSkewKurt(data);
            %peak to RMS ration
            f(:,9) = f(:,5)./f(:,1);
        end
    
        function [s, k] = fastSkewKurt(x)
            dim = 2;
            x0 = x - nanmean(x,dim);
            s2 = nanmean(x0.^2,dim);
            m2 = x0.^2;
            m3 = nanmean(m2.*x0,dim);
            m4 = nanmean(m2.*m2,dim);
            s = m3 ./ s2.^(1.5);
            k = m4 ./ s2.^2;
        end

    end
end