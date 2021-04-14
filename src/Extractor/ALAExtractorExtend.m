classdef ALAExtractorExtend < TransformableFESuperClass & Reconstructor
    %ALAEXTRACTOR A feature extractor for ALA features
    %   This is used to extract features via the ALA method. Therefore
    %   cycles are divided into several intervals. Slope and mean for each
    %   interval are then combined to form the extracted features.
    
    properties
        errVec = [];
		l = [];
		start = [];
		stop = [];
        dsFactor = [];
        
        numFeat = [];
    end
    
    properties (Constant)
        intendedLength = 500;   % highest number of principal components allowed
    end
    
    methods
        function this = ALAExtractorExtend(varargin)
           if ~isempty(varargin)
               p = inputParser;
               defNumFeat = [];
               addOptional(p,'numFeat',defNumFeat,@isnumeric);
               parse(p,varargin{:});
               this.numFeat = p.Results.numFeat;
           end
        end
        

        
        function infoCell = info(this)
            infoCell = cell(this.numFeat,3);
            
            for i = 1:this.numFeat/2

                if(this.start(i) == 1)
                    infoCell{2*i-1,2} = [this.start(i):this.dsFactor*this.stop(i)];
                    infoCell{2*i,2} = [this.start(i):this.dsFactor*this.stop(i)];
                else
                    infoCell{2*i-1,2} = [this.dsFactor*this.start(i):this.dsFactor*this.stop(i)];
                    infoCell{2*i,2} = [this.dsFactor*this.start(i):this.dsFactor*this.stop(i)];
                end
                infoCell{2*i-1,1} = ones(1,size(infoCell{2*i-1,2},2));
                infoCell{2*i,1} = ones(1,size(infoCell{2*i-1,2},2));
                infoCell{2*i-1,3} = ["Mean"];
                infoCell{2*i,3} = ["Slope"];
            end
        end
        
		function [this] = trainFromPreTransformed(this,preTransformedData)
            % clear previously computed coefficients
            this.start = [];
            this.stop = [];
            
            dwnDat = preTransformedData;
			%compute error matrix
			for i = 1:size(dwnDat,1)
				if i == 1
					errVec = this.errMatTransformFast_mex(dwnDat(i,:));
				else
					errVec = errVec + this.errMatTransformFast_mex(dwnDat(i,:));
				end
			end
            
			this.l = size(dwnDat,2);
			
            % update summed up error vector
            if isempty(this.errVec)
                this.errVec = errVec;
            else 
                this.errVec = this.errVec + errVec;
            end
        end
		
        function dwnDat = pretransform(this, rawData)
			if size(rawData,2) > this.intendedLength
				% downsample raw data for covariance computation
				len = cast(size(rawData,2), 'like', rawData);
				dsFactor = round(len/this.intendedLength);
                if isa(rawData, 'single')
                    dwnDat = single(resample(double(rawData'), 1, double(dsFactor))');
                else
                    dwnDat = resample(rawData', 1, dsFactor)';
                end
                this.dsFactor = dsFactor;
			else
				dwnDat = rawData;
                this.dsFactor = 1;
            end
        end
        
        function fitParamRet = applyToPretransformed(this, dwnDat)
            this.finishTraining();
            usedParam = [2 3 4 5 6 7 8 9];
            lengthParam = size(usedParam,2);
			%Compute linear fit parameter
			fitParam = zeros(size(dwnDat,1), 9, 'like', dwnDat);
            fitParamRet = zeros(size(dwnDat,1), size(this.start,2)*lengthParam, 'like', dwnDat);
			x = 1:cast(length(dwnDat), 'like', dwnDat);
			for i = 1:cast(length(this.start), 'like', dwnDat)
				ind = this.start(i):this.stop(i);
				for n = 1:size(dwnDat,1)
					[~, d] =  this.linFit(x(ind),dwnDat(n, ind));
					fitParam(n,[8,9]) = d;
                end
                fitParam(:,1) = mean(dwnDat(:,ind), 2);
                %compute standard deviation
                fitParam(:,2) = std(dwnDat(:,ind), [], 2);
                %Remark: The old toolbox structure had skewness and
                %kurtosis switched. This was fixed here but will lead to
                %different feature order.
                %compute skewness
                fitParam(:,3) = skewness(dwnDat(:,ind), [], 2);
                %compute kurtosis
                fitParam(:,4) = kurtosis(dwnDat(:,ind), [], 2);
                [fitParam(:,5), fitParam(:,6)] = max(dwnDat(:,ind), [], 2);
                fitParam(:,7) = min(dwnDat(:,ind), [], 2);
                fitParamRet(:,lengthParam*(i-1)+1:lengthParam*i) = fitParam(:,usedParam); 
            end
  
        end
		
		function this = combine(this, other)
			this.start = [];
			this.stop = [];
            this.trainingFinished = false;
			
			if isempty(this.errVec)
				this.errVec = other.errVec;
				this.l = other.l;
			else
				this.errVec = this.errVec + other.errVec;
			end
        end
        
        function reconstruction = reconstruct(this, feat)
            %reconstruct downsampled data from linear fits
            rec = zeros(size(feat,1), this.stop(end));
            for i = 1:length(this.start)
                ind = this.start(i):this.stop(i);
                len = this.stop(i)-this.start(i)+1;
                meanInd = ((i-1)*2)+1;
                slopeInd = meanInd +1;
                nSamples = size(feat,1);
                
                rec(:, ind) = repmat(feat(:, meanInd), 1, len);
                slopeAdd = repmat(ind, nSamples, 1) .* feat(:,slopeInd);
                rec(:, ind) = rec(:, ind) + slopeAdd - mean(slopeAdd, 2);
            end
            
            %upsample, if neccesary
            reconstruction = resample(rec', this.dsFactor, 1)';
        end
    end
	
	methods (Access = protected)
		function finishTraining(this)
			
			errMat = Inf(this.l, 'like', this.errVec);
			%from-to matrix
			errMat(tril(true(this.l),-1)) = this.errVec;
            errMat = errMat';
			
			if isa(errMat, 'gpuArray')
                errMat = gather(errMat);
            end
			if isempty(this.numFeat)
                [~, splits, e] = this.findSplits(errMat);
            elseif this.numFeat >=4
                numSplits = floor(this.numFeat/2)-1;
                [~, splits, e] = this.findSplits(errMat,numSplits);
            else
                disp('specifiy higher numFeat so splitting is relevant')
            end
            this.start = cast([1,splits], 'like', this.errVec);
            this.stop = cast([splits, this.l], 'like', this.errVec);
            
            if any(isinf(this.start)) || any(isinf(this.stop))
                error('Failed to find linear segments');
            end
            this.numFeat = size(this.start,2)*2;
            this.trainingFinished = true;
		end
	end
	
	methods(Static)
		%ToDo: Umschreiben für Matrizen
		function errMat = errMatTransformFast_mex( data )
			%ERRMATTRANSFORMFAST Summary of this function goes here
			%   Detailed explanation goes here
			len = length(data);
			errMat = zeros(1, (len*(len-1)/2));
			indRunning = 1;
			%iterate over start-points
			for i = 1:len
				sumX = i;
				sumXX = i^2;
				sumY = data(i);
				sumYY = data(i)^2;
				sumXY = i * data(i);
				%iterate over stop-points
				for j = i+1:len
					sumX = sumX + j;
					sumXX = sumXX + j^2;
					sumY = sumY + data(j);
					sumYY = sumYY + data(j)^2;
					sumXY = sumXY + j*data(j);
					num = j-i+1;
					f = -1/num;
					
					p1 = sumXX - sumX^2/num;
					p2 = 2*sumX*sumY/num - 2*sumXY;
					p3 = sumYY - sumY^2/num;
					b = (sumXY - sumX*sumY/num)/(sumXX - sumX^2/num);
					errMat(indRunning) = p1*b^2+p2*b+p3;
					
					indRunning = indRunning + 1;
				end
			end
        end
        
    end
    
    methods(Access = private)
        function [R2, data] = linFit(~, x, y)
            xm = sum(x,2)/size(x,2);
            ym = sum(y,2)/size(y,2);
            xDiff = (x-repmat(xm,1,size(x,2)));
            b = sum((xDiff).*(y-repmat(ym,1,size(y,2))), 2)./sum((xDiff).^2,2);
            a = ym - b.*xm;
            R2 = 0;
            for i = 1:size(y,1)
                R2 = R2 + sum((y(i,:) - (a(i) + b(i) * x(i,:))).^2);
            end
            data = [ym,b];
        end
		
        function [ err, splits, dat ] = findSplits( this, errMat, numSplits )
        %FINDSPLITS Summary of this function goes here
        %   Detailed explanation goes here
            maxSplits = 70;
            n = length(errMat);
            spl = Inf(maxSplits,n);
            errors = Inf(maxSplits,n); %#ok<PROPLC>
            for q = 1:maxSplits
                for i = 1:n-q
                    if q == 1
                        sumRes = errMat(i,:) + errMat(:,n)';
                    else
                        sumRes = errors(q-1,:) + errMat(i,:); %#ok<PROPLC>
                    end
                    [errors(q,i),spl(q,i)] = min(sumRes); %#ok<PROPLC>
                end
            end

            dat = errors(:,1)'; %#ok<PROPLC>
            sqErr = this.getFitErrorMatrix(dat, {'this.linFit'});
            maxSplits = 3;
            n = length(sqErr);
            splTemp = Inf(maxSplits,n);
            errorsTemp = Inf(maxSplits,n);
            for q = 1:maxSplits
                for i = 1:n-q
                    if q == 1
                        sumRes = sqErr(i,:) + sqErr(:,n)';
                    else
                        sumRes = errorsTemp(q-1,:) + sqErr(i,:);
                    end
                    [errorsTemp(q,i),splTemp(q,i)] = min(sumRes);
                end
            end
            splits = zeros(1,maxSplits);
            splits(1) = splTemp(maxSplits,1);
            for i = maxSplits-1:-1:1
                splits(maxSplits - i + 1) = splTemp(i, splits(maxSplits - i));
            end

            if nargin < 3
                numSplits = splits(end);
            end
            splits = zeros(1,numSplits);
            err = errors(numSplits,1); %#ok<PROPLC>
            splits(1) = spl(numSplits,1);
            for i = numSplits-1:-1:1
                splits(numSplits - i + 1) = spl(i, splits(numSplits - i));
            end
        end
		
		function [sqErr, functions] = getFitErrorMatrix(this, dat, varargin)
            dat = sum(dat,1);
            x = 1:size(dat,2);

            fitFunctions = varargin{1};

            N = size(dat,2);
            sqErr = Inf(N);
            functions = cell(N);

            combos = this.nchoose2(1:N);
            sqErrTemp = Inf(1,size(combos,1));
            funTemp = zeros(1,size(combos,1));
            for i = 1:size(combos,1)
                sqTT = Inf(1,length(fitFunctions));
                for j = 1:length(fitFunctions)
                    for k = 1:size(dat,1)
                        xu = x(combos(i,1):combos(i,2));
                        yu = dat(k,combos(i,1):combos(i,2));
                        err = this.linFit(xu, yu);
                        if sqTT(j) == Inf
                            sqTT(j) = err;
                        else
                            sqTT(j) = sqTT(j) + err;
                        end
                    end
                end
                [sqErrTemp(i), funTemp(i)] = min(sqTT);
            end
            for i = 1:size(combos,1)
                functions(combos(i,1),combos(i,2)) = fitFunctions(funTemp(i));
                sqErr(combos(i,1),combos(i,2)) = sqErrTemp(i);
            end
        end
		
        function [ combos ] = nchoose2( ~, nums,varargin )
        %FNCHOOSEK Summary of this function goes here
        %   Detailed explanation goes here
            N = length(nums);
            combos = zeros(nchoosek(N,2),2);
            for i = 1:N-1
                start = nchoosek(N, 2) - nchoosek(N - i + 1, 2) + 1; %#ok<PROPLC>
                if N-i == 1
                    fin = length(combos);
                else
                    fin = nchoosek(N, 2) - nchoosek(N-i, 2);
                end
                combos(start:fin, 1) = nums(i); %#ok<PROPLC>
                combos(start:fin, 2) = nums(i+1:end); %#ok<PROPLC>
            end
        end
	end
    
end
