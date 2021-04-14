classdef StatisticalMomentsAutoSec < TransformableFESuperClass
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        segStart = [];
        segStop =  [];
        dataLength = [];
    end
    
    methods
        function this = StatisticalMomentsAutoSec(varargin)

        end
        
        function infoCell = info(this)

        end
        
        function dwnDat = pretransform(this, rawData)
            dwnDat = rawData;
        end
        
        function [this] = trainFromPreTransformed(this,preTransformedData)
% %       Alte Methode
%             data = movmean(preTransformedData,size(preTransformedData,2)/30,1);
%             allEdges = false(1,size(data,2));
%             totalThresh = 0;
%             allThresh = zeros(size(data,1),1);
%             for i = 1:size(data,1)
%                 [~,thresh] = edge(data(i,:));
%                 totalThresh = totalThresh+thresh;
%                 allThresh(i) = thresh;
%                 % Te4st with filter  seam to be worse edge(movmean(data(i,:),ceil(size(data,2)/100)+1));
%             end
%             totalThresh = totalThresh/size(data,1)+4*std(allThresh);
%             for i = 1:size(data,1)
%                 allEdges = allEdges|edge(data(i,:),totalThresh);
%                 % Te4st with filter  seam to be worse edge(movmean(data(i,:),ceil(size(data,2)/100)+1));
%             end
%             
%             allEdgesCombi = any(allEdges,1);
% %             % Make edges larger and combine them


% %       Neue Methode
            meanCurve = mean(preTransformedData,1);
            data = meanCurve;
            allEdgesCombi = edge(meanCurve);
            
            allEdgesCombiMax = movmax(allEdgesCombi,ceil(size(data,2)/500)+1);
            segStartL = [];
            segStopL = [];
            idStart = 1;
            idStop = 1;
            if(allEdgesCombiMax(1) == 1)
                segStartL(idStart) = 1;
                idStart = idStart+1;
            end
            for i = 1:size(allEdgesCombiMax,2)-1
                if allEdgesCombiMax(i) == 0 && allEdgesCombiMax(i+1) == 1
                    segStartL(idStart) = i;
                    idStart = idStart+1;
                end
                if allEdgesCombiMax(i) == 1 && allEdgesCombiMax(i+1) == 0
                    segStopL(idStop) = i+1;
                    idStop = idStop+1;
                end
            end
            if idStart >idStop
                segStopL(idStop) = size(allEdgesCombiMax,2);
            end
            this.segStart = segStartL;
            this.segStop = segStopL;
        end
        
        
        
        function fitParam = applyToPretransformed(this, dwnDat)
            feat = [];
            data = dwnDat;
            featCell = cell(2*size(this.segStart,2)+1,1);
            featCount = 1;
            if size(this.segStart) == 0
                %Kein Abschnitt
                featCell{featCount} = this.featLess(data,1:size(dwnDat,2));
            else
               % ERster Abschnitt
               if this.segStart(1) ~= 1
                    %featCell{1}=this.featEx(data(:,1:this.segStart(1)-1));
                    featCell{1}=this.featLess(data(:,1:this.segStart(1)-1),1:this.segStart(1)-1);
                    featCount = featCount+1;
               end
               % Alle zwischen eins und letztem
               for i = 1:size(this.segStart,2)-1
                    %featCell{featCount}= this.featExEdge(data(:,this.segStart(i):this.segStop(i)));
                    featCell{featCount}= this.featLess(data(:,this.segStart(i):this.segStop(i)),this.segStart(i):this.segStop(i));
                    featCount = featCount+1;
                    %featCell{featCount}= this.featEx(data(:,this.segStop(i)+1:this.segStart(i+1)));
                    featCell{featCount}= this.featLess(data(:,this.segStop(i):this.segStart(i+1)),this.segStop(i):this.segStart(i+1));
                    featCount = featCount+1;
                    
               end
               %Letzter Abschnitt
               if this.segStop(end) ~= size(data,2)
                   %featCell{featCount}= this.featExEdge(data(:,this.segStart(end):this.segStop(end)));
                   featCell{featCount}= this.featLess(data(:,this.segStart(end):this.segStop(end)),this.segStart(end):this.segStop(end));
                   featCount = featCount+1;
                   %featCell{featCount}= this.featEx(data(:,this.segStop(end)+1:end));
                   featCell{featCount}= this.featLess(data(:,this.segStop(end):end),this.segStop(end):size(data,2));
               elseif this.segStop(end)+1 == size(data,2)
                   featCell{featCount}= this.featLess(data(:,this.segStart(end):this.segStop(end)),this.segStart(end):this.segStop(end));
               else
                   %featCell{featCount}= this.featExEdge(data(:,this.segStart(end):this.segStop(end)));
                   featCell{featCount}= this.featLess(data(:,this.segStart(end):this.segStop(end)),this.segStart(end):this.segStop(end));
               end
               
            end
            
            for i = 1:size(featCell,1)
                    feat = [feat, featCell{i}];
            end
            fitParam = feat;
        end
        
        
        
        function feat = featEx(this,data)
            if size(data,2) ~= 0
                
                feat = cell(1, 1);
                for i = 1:1
                    f = zeros(size(data,1), 7);

                    %get indices for this segment
                    start = (i-1) * ceil(size(data,2)/1) + 1;
                    stop = min(size(data,2), i * ceil(size(data,2)/1));
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
                    [f(:,6), f(:,5)] = max(data, [], 2);
                    %minimal value
                    f(:,7) = min(data, [], 2);
                    feat{i} = f;
                end

                feat = horzcat(feat{:});
            else
                feat = [];
            end
        end
        
        
        function feat = featExEdge(this,data)
            feat = cell(1, 1);
            for i = 1:1
                f = zeros(size(data,1), 9);
                
                %get indices for this segment
                start = (i-1) * ceil(size(data,2)/1) + 1;
                stop = min(size(data,2), i * ceil(size(data,2)/1));
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
                edgeLoc = edge(data);
                edgeSlope = zeros(size(data,1),1);
                edgeLocFirst = zeros(size(data,1),1);
                for j=1:size(data,1)
                    edgeId = find(edgeLoc(j,:),1);
                    [~,slope] = this.linFit(ind,data(j,:));
                    edgeSlope(j) = slope(2);
                    if ~isempty(edgeId)
                        edgeLocFirst(j) = edgeId(1);
                    end
                end
                f(:,5) = edgeLocFirst;
                f(:,6) = edgeSlope;
                [f(:,7), f(:,8)] = max(data, [], 2);
                f(:,9) = min(data, [], 2);
                feat{i} = f;
            end
            
            feat = horzcat(feat{:});
        end
        
        function feat = featLess(this,data,x)
            feat = cell(1, 1);
            for i = 1:1
                f = zeros(size(data,1), 9);
                
                %get indices for this segment
                start = (i-1) * ceil(size(data,2)/1) + 1;
                stop = min(size(data,2), i * ceil(size(data,2)/1));
                ind = start:stop;
                %compute mean
                f(:,1) = mean(data(:,:), 2);
                %compute standard deviation
                f(:,2) = std(data(:,:), [], 2);
                %Remark: The old toolbox structure had skewness and
                %kurtosis switched. This was fixed here but will lead to
                %different feature order.
                %compute skewness
                f(:,3) = skewness(data(:,:), [], 2);
                %compute kurtosis
                f(:,4) = kurtosis(data(:,:), [], 2);
                [f(:,5), f(:,6)] = max(data, [], 2);
                f(:,7) = min(data, [], 2);

                for k = 1:size(data,1)
                    [~,lFeats] = this.linFit(x,data(k,:));
                    f(k,8) = lFeats(:,1);
                    f(k,9) = lFeats(:,2);
                end
                usedFeat = [2 3 4 5 6 8 9];
                feat{i} = f(:,usedFeat);
            end
            
            feat = horzcat(feat{:});
        end
        
        function this = combine(this, other)
            
        end
        
        function reconstruction = reconstruct(this, feat)
            reconstruction = feat;
        end
        
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
    end
    
    methods (Access = protected)
		function finishTraining(this)
            this.trainingFinished = true;
		end
    end
end

