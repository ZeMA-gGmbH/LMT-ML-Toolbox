  

classdef TimeFrequencyExtractor < Appliable
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        nSegTime = 10;
        nSegFreq = 10;
        dataLength;
        freqLength;
        charFreqFlag=0;
        charTimeFlag=0;
        segTime=[];
        segFreq=[];
        segFreqReal=[];
        sampleRate=1;
    end
    
    methods
        function this = TimeFrequencyExtractor(numSegmentsTime, numSegmentsFreq, Fs)
            if nargin > 0
                if exist('numSegmentsTime', 'var') && ~isempty(numSegmentsTime)
                    %if only one argument is given, use the same number of
                    %segments for both domains
                        this.nSegTime = numSegmentsTime+1;
                        this.nSegFreq = numSegmentsTime+1;                   
                end
                if exist('numSegmentsFreq', 'var') && ~isempty(numSegmentsFreq)

                        this.nSegTime = numSegmentsTime+1;
                        if isempty(numSegmentsTime)
                            this.nSegTime =11;
                        end                        
                        this.nSegFreq = numSegmentsFreq+1;
                end
                if exist('Fs', 'var') && ~isempty(Fs)
                    this.sampleRate=Fs;
                end
            end
        end
        
        function feat = apply(this, data)
           
            featTime = cell(this.nSegTime, 1);
            featFreq = cell(this.nSegTime, 1);
            featFreqTemp = cell(this.nSegFreq, 1);
                        
            this.dataLength = size(data,2);
            
                
            for i = 1:this.nSegTime
                %get indices for this segment (Time domain)
                this.segTime(i,1) = (i-1) * floor(size(data,2)/(this.nSegTime-1)) + 1;
                this.segTime(i,2) = min(size(data,2), i * ceil(size(data,2)/(this.nSegTime-1)));
                this.segTime(this.nSegTime,1)=1;
                this.segTime(this.nSegTime,2)=this.dataLength;
                
                ind = this.segTime(i,1):this.segTime(i,2);
                featTime{i} = this.applyFeatureFuns(data(:,ind));
                
                L=size(data(:,ind),2);
                freqData = abs((fft(data(:,ind)-mean(data(:,ind)), [], 2))/L);
                freqData=freqData(:,1:L/2+1);
                freqData(:,2:end-1)=2*freqData(:,2:end-1);
                fx = this.sampleRate*(0:(L/2))/L;
                
                this.freqLength(i) = size(freqData,2);

                for j = 1:this.nSegFreq
                    %get indices for this segment (Frequency domain)
                        this.segFreq{i}(j,1) = (j-1) * floor(size(freqData,2)/(this.nSegFreq-1)) + 1;
                        this.segFreq{i}(j,2) = min(size(freqData,2), j * ceil(size(freqData,2)/(this.nSegFreq-1)));

                        this.segFreq{i}(this.nSegFreq,1)=1;
                        this.segFreq{i}(this.nSegFreq,2)=this.freqLength(i);
                        
                        this.segFreqReal(j,1)=fx(this.segFreq{i}(j,1));
                        this.segFreqReal(j,2)=fx(this.segFreq{i}(j,2));
                                       
                        ind = this.segFreq{i}(j,1):this.segFreq{i}(j,2);
                        featFreqTemp{j} = this.applyFeatureFuns(freqData(:,ind));
                end
                featFreq{i}=horzcat(featFreqTemp{:});
            end
            
            feat = horzcat(featTime{:}, featFreq{:});
        end

	function infoCell = info(this)
            infoCell = cell(this.nSegTime*9+this.nSegTime*this.nSegFreq*9,3);
            
            for numTimeSeg = 1:this.nSegTime
                %get indices for this segment
                startTime = this.segTime(numTimeSeg,1);
                stopTime = this.segTime(numTimeSeg,2);
                namesFunc={'Vib RMS T', 'Vib Var T', 'Vib slope T', 'Vib Idx Max T', 'Vib Max T', 'Vib Min T', 'Vib skewness T', 'Vib kurtosis T', 'Vib Peak RMS ratio T'}; 
                for numFunc=1:9
                    
                    infoCellTimeTemp{numTimeSeg}{numFunc,1} = ones(stopTime-startTime+1,1);
                    infoCellTimeTemp{numTimeSeg}{numFunc,2} = startTime:stopTime;
                    infoCellTimeTemp{numTimeSeg}{numFunc,3} = namesFunc{numFunc};
                
                end
                
                for numFreqSeg = 1:this.nSegFreq
                    %get indices for this segment
                    startFreq = this.segFreqReal(numFreqSeg,1);
                    stopFreq = this.segFreqReal(numFreqSeg,2);
                                   
                    namesFunc={'Vib RMS F', 'Vib Var F', 'Vib slope F', 'Vib Idx Max F', 'Vib Max F', 'Vib Min F', 'Vib skewness F', 'Vib kurtosis F', 'Vib Peak RMS ratio F'}; 

                    for numFunc=1:9
                    
                        infoCellFreqTemp{numFreqSeg}{numFunc,1} = startTime:stopTime;
                        infoCellFreqTemp{numFreqSeg}{numFunc,2} = startFreq:stopFreq;
                        infoCellFreqTemp{numFreqSeg}{numFunc,3} = namesFunc{numFunc};
                    end

                end
                6*infoCellFreq{numTimeSeg}=vertcat(infoCellFreqTemp{:});
                
            end
            infoCellTime=vertcat(infoCellTimeTemp{:});
            infoCellFreq=vertcat(infoCellFreq{:});
            infoCell=vertcat(infoCellTime,infoCellFreq);
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



