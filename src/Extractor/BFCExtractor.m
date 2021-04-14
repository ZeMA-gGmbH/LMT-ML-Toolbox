classdef BFCExtractor < TransformableFESuperClass & Reconstructor
    %BFCEXTRACTOR 

    properties
        m = [];
        n = [];
        ind = [];
        
        heuristic = '';
        numFeat = [];
    end
    
    methods
        function this = BFCExtractor(varargin)
           if ~isempty(varargin)
               p = inputParser;
               defHeuristic = '';
               expHeuristic = {'elbow','percent'};
               defNumFeat = [];
               addOptional(p,'heuristic',defHeuristic,...
                   @(x) any(validatestring(x,expHeuristic)));
               addOptional(p,'numFeat',defNumFeat,@isnumeric);
               parse(p,varargin{:});
               this.heuristic = p.Results.heuristic;
               this.numFeat = p.Results.numFeat;
           end
        end
        
        
         function infoCell = info(this)
            infoCell = cell(this.numFeat*2,3);
            counter = 1;
            for i = 1:size(this.ind,2)

                if(this.ind(i) == 1)
                    infoCell{counter,3} = ["ABS FFT Component"];
                    infoCell{counter,2} = [i-1];
                    infoCell{counter,1} = [1];
                    infoCell{counter+this.numFeat,3} = ["Phase FFT Component"];
                    infoCell{counter+this.numFeat,2} = [i-1];
                    infoCell{counter+this.numFeat,1} = [1];
                    counter = counter+1;
                end
            end
        end
        
        function this = trainFromPreTransformed(this, preTransformedData)
			this.ind = [];
            
            amp = preTransformedData;
           
            if isempty(this.m)
                this.m = sum(amp,1);
                this.n = size(amp,1);
            else
                this.m = this.m + sum(amp,1);
                this.n = this.n + size(amp, 1);
            end
            %clear preTransformedData;
        end
		
		function preTransformed = pretransform(this, rawData)
			coeff = fft(rawData, [], 2);
            preTransformed = coeff(:, 1:floor(size(rawData,2)/2));
		end
		
		function features = applyToPretransformed(this, preTransformed)
            finishTraining(this);
            coeff = preTransformed(:,this.ind);
            features = [abs(coeff), angle(coeff)];
		end
        
        function obj1 = combine(this, obj1, obj2)
			this.trainingFinished = false;
            obj1.ind = [];
            if ~isempty(obj1.m)
                obj1.m = obj1.m + obj2.m;
                obj1.n = obj1.n + obj2.n;
            else
                obj1.m = obj2.m;
                obj1.n = obj2.n;
            end
        end
        
        function rec = reconstruct(this, feat)
            absolute = feat(:, 1:size(feat,2)/2);
            ang = feat(:, size(feat,2)/2+1:end);
            
            fcoeff = complex(zeros(size(feat,1), length(this.ind)));
            fcoeff(:,this.ind) = complex(absolute.*cos(ang), absolute.*sin(ang));
            fcoeff = [fcoeff, flip(fcoeff,2)];
            
            rec = ifft(fcoeff, [], 2, 'symmetric');
        end
    end
    
    methods (Access = protected)
        function finishTraining(this)
            mean = this.m ./ this.n;
            [mean, idx] = sort(mean, 'descend');
            i = false(size(mean));
            if isempty(this.numFeat) && isempty(this.heuristic)
                nFeat = floor(size(mean, 2)/10);
            elseif isempty(this.heuristic)
                nFeat = this.numFeat;
            elseif strcmp(this.heuristic,'elbow')
                nFeat = FeatureExtractorInterface.elbowPos(mean);
            end
            if(this.trainingFinished == false)
                this.numFeat = nFeat;
            end
            i(idx(1:nFeat)) = true;
            this.ind = i;
			this.trainingFinished = true;
        end
    end
end

