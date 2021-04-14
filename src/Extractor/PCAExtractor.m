classdef PCAExtractor < TransformableFESuperClass & Reconstructor
    %PCAEXTRACTOR A feature extractor for best PCA coefficients
    %   This is used to extract the best PCA coefficients for the provided
    %   raw data. The coefficients for the principal components of the raw
    %   data are computed and sorted by their explained variance.
    %   The Components that explain the most variance resemble the best.
    %   Features are computed by multiplying the raw data with the sorted
    %   coefficient matrix.
    
    properties
        coeffs = [];     % the PCA coefficients sorted as a result of training
        expl = [];       % variance explained by each principal component
        
        count = 0;
        xiyiSum = [];
        xiSum = [];
        
        heuristic = '';
        numFeat = [];
        
        dsFactor = [];
    end
    
    properties (Constant)
        intendedLength = 500;   % highest number of principal components allowed
    end
    
    methods
        function this = PCAExtractor(varargin)
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
            infoCell = cell(this.numFeat,2);
            for i = 1:size(infoCell,1)
                for lv1 = 1:size(this.coeffs,1)
                    for lv2 = 1:this.dsFactor
                         infoCell{i,1} = [infoCell{i,1} this.coeffs(lv1,i)];
                    end
                end

                infoCell{i,2} = 1:size(this.coeffs,1)*this.dsFactor;
            end
        end
        
        function [this] = trainFromPreTransformed(this,preTransformedData)
            dwnDat = preTransformedData;
            % update summed up covariance matrices
            if isempty(this.xiyiSum)
                this.xiSum = sum(dwnDat,1);
                this.xiyiSum = dwnDat'*dwnDat;
                this.count = size(dwnDat,1);
            else 
                this.xiSum = this.xiSum + sum(dwnDat,1);
                this.xiyiSum = this.xiyiSum + dwnDat'*dwnDat;
                this.count = this.count + size(dwnDat,1);
            end
        end
		
        function dwnDat = pretransform(this, rawData)
            if size(rawData,2) > this.intendedLength
				% downsample raw data for covariance computation
				len = cast(size(rawData,2), 'like', rawData);
				this.dsFactor = round(len/this.intendedLength)+1;
                if isa(rawData, 'single')
                    dwnDat = single(resample(double(rawData'), 1, double(this.dsFactor))');
                else
                    dwnDat = resample(rawData', 1, this.dsFactor)';
                end
            else
                this.dsFactor = 1;
				dwnDat = rawData;
            end
        end
        
        function feat = applyToPretransformed(this, dwnDat)
            this.finishTraining();
            % center the data if it has more than one observation
            if size(dwnDat,1)> 1
                dwnDat = dwnDat - mean(dwnDat,1);
            end
            if isempty(this.numFeat) && isempty(this.heuristic)
                feat = dwnDat*this.coeffs;
                this.numFeat = size(feat,2);
            elseif isempty(this.heuristic)
                feat = dwnDat*this.coeffs(:,1:this.numFeat);
            elseif strcmp(this.heuristic,'elbow')
                feat = dwnDat*this.coeffs(:,1:FeatureExtractorInterface.elbowPos(this.expl));
                this.numFeat = size(feat,2);
            elseif strcmp(this.heuristic,'percent')
                cutoff = floor(size(this.coeffs,2)/10);
                feat = dwnDat*this.coeffs(:,1:cutoff);
                this.numFeat = size(feat,2);
            end
        end
		
        function this = combine(this, target)
            % combine training results of target with the results of the
            % calling object
            
            % clear previously computed coefficients
            this.trainingFinished = false;
            
            % combine the summed up covariance matrices if classes match
            if strcmp(class(this),class(target))
				if isempty(this.xiSum)
                    this.xiSum = target.xiSum;
                    this.xiyiSum = target.xiyiSum;
                    this.count = target.count;
				else
                    this.xiSum = this.xiSum + target.xiSum;
                    this.xiyiSum = this.xiyiSum + target.xiyiSum;
                    this.count = this.count + target.count;
				end
            else
                warning(['Classes ',class(this),' and ',class(target),...
                    ' do not match and cannot be combined']);
            end
        end
        
        
        function rec = reconstruct(this, feat)
            rec = zeros(size(feat,1), size(this.coeffs,2));
            for i = 1:size(feat, 2)
                rec = rec + feat(:,i) .* this.coeffs(:,i)';
            end
            % revert previous centering if there is more than one
            % observation
            if size(feat,1)> 1
                rec = rec + (this.xiSum/this.count);
            end
            %upsample, if neccesary
            rec = resample(rec', this.dsFactor, 1)';
        end
        
    end
    methods (Access = protected)
        function finishTraining(this)
            % compute pca of the summed up covariance matrices
            covariance = 1/this.count * (this.xiyiSum - (1/this.count)*this.xiSum'*this.xiSum);
            
            [coeff,~,explained] = pcacov(covariance);
            
            % save computed coefficients and explained curve
            this.coeffs = coeff;
            this.expl = explained;
            
            this.trainingFinished = true;
        end
    end
end

