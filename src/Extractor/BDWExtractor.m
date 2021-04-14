classdef BDWExtractor < TransformableFESuperClass & Reconstructor
    %BDWEXTRACTOR A feature extractor for best daubechies wavelet coefficients (BDW)
    %   This is used to extract the best daubechies wavelet coefficients
    %   for the provided raw data.
    
    properties
        ind = [];%the indices ordering the wavelet coefficients that result from training
        m = [];  %the sum of wavelet coefficients for the ongoing training 
        n = [];  %counter
        heuristic = '';
        numFeat = [];
        
        len = [];
        originLen = [];
    end
    
    methods
        function this = BDWExtractor(varargin)
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
            infoCell = cell(this.numFeat,3);
            counter = 1;
            for i = 1:size(this.ind,2)

                if(this.ind(i) == 1)
                    infoCell{counter,3} = ["BDW Coeffizient"];
                    infoCell{counter,2} = [i];
                    infoCell{counter,1} = [1];
                    counter = counter+1;
                end
            end
        end
        
        function [this] = trainFromPreTransformed(this, preTransformedData)
            this.ind = [];
            data = preTransformedData;
            
            % sum up all wavelet coefficients and store the result for
            % continued training
            if isempty(this.m)
                this.m = sum(abs(data));
                this.n = size(data,1);
            else
                this.m = this.m + sum(abs(data));
                this.n = this.n + size(data,1);
            end
        end
        
        function data = pretransform(this, data)
            this.originLen = size(data, 2);
            % compute wavelet transformation
            wlevel = BDWExtractor.wMaxLv(size(data,2));
            [af, df] = wfilters('db2');

            d = cell(1,wlevel);
            for i = wlevel:-1:1
                l = size(data,2)+6;
                fInd = false(1,l);
                fInd(5:2:l) = true;
                data = [data(:,[1,1,1]), data, data(:,[end, end, end])];
                d{i} = filter(df, 1, data, [], 2);
                d{i} = d{i}(:,fInd);

                data = filter(af, 1, data, [], 2);
                data = data(:,fInd);
            end
            % concatenate coefficients of different levels
            this.len = [size(data,2), cellfun(@(a)size(a,2), d)];
            data = [data, d{:}];
        end
        
        function feat = applyToPretransformed(this, data)
            finishTraining(this);
            feat = data(:,this.ind);
        end
        
        
        function this = combine(this, target)
            % combine training results of target with the results of the
            % calling object
            
            % clear previously computed coefficient order
            this.ind = [];
            this.trainingFinished = false;
            
            % combine the summed up coefficients if classes match
            if strcmp(class(this),class(target))
                if isempty(this.m)
                    this.m = target.m;
                    this.n = target.n;
                else
                    this.m = this.m + target.m;
                    this.n = this.n + target.n;
                end
            else
                warning(['Classes ',class(this),' and ',class(target),...
                    ' do not match and cannot be combined']);
            end
        end
        
        function rec = reconstruct(this, feat)
            [~,~, LoR, HiR] = wfilters('db2');
            
            coeff = zeros(size(feat,1), sum(this.len));
            coeff(:,this.ind) = feat;
            
            %ToDo: remove this block of code and figure out filter delays
            %below!
            rec = zeros(size(feat,1), this.originLen);
            for i = 1:size(feat,1)
                rec(i,:) = waverec(coeff(i,:), [this.len this.originLen], 'db2');
            end
            
%             clen = [0 cumsum(this.len)];
%             d = cell(length(this.len), 1);
%             for i = 1:length(this.len)
%                 d{i} = coeff(:, clen(i)+1:clen(i+1));
%             end
            
%             rec = d{1};
%             for i = 2:length(this.len)
%                 rec = filter(LoR, 1, upsample(rec', 2)', [], 2);
%                 detail = filter(HiR, 1, upsample(d{i}', 2)', [], 2);
%                 detail(size(feat,1), size(rec,2)) = 0;
%                 rec = rec + detail; %shorten rec correctly
%             end
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
            this.numFeat = nFeat;
            i(idx(1:nFeat)) = true;
            this.ind = i;
            this.trainingFinished = true;
        end
    end
    
    methods (Static)
        function wl = wMaxLv(len)
            if len <= 5
                wl = 0;
            else
                wl = 1;
                cur = 6;
                sum = 11;
                while sum < len
                    cur = cur * 2;
                    sum = sum + cur;
                    wl = wl + 1;
                end
            end
        end
    end
end
