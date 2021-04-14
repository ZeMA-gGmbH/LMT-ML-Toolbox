
classdef TransformableFESuperClass < UnSupervisedTrainable & Transformable & Combinable
    %TRANSFORMABLE Feature Extractor
    properties
        trainingFinished = false;
    end
    
    methods
        function features = apply(this, rawData)
            if ~this.trainingFinished
                this.finishTraining();
            end
            
            preTransformed = this.pretransform(rawData);
            features = this.applyToPretransformed(preTransformed);
        end
        
        function this = showError(this, data,target)
            outEx = this.apply(data);
            outReconst = this.reconstruct(outEx);
            residualV = data-outReconst;
            sqrtErrorCycle = sum(residualV.^2,1);
            sqrtErrorMeasurment = sum(residualV.^2,2);
            figure()
            tiledlayout(2,2);
            nexttile
            plot(sqrtErrorCycle);
            title('Sum of square error over points in cycle')
            xlabel('Point in Cycle')
            ylabel('sum of squared error over all cycles')
            nexttile
            x = 1:size(sqrtErrorMeasurment,1)';
            y = sqrtErrorMeasurment';
            z = zeros(size(sqrtErrorMeasurment))';
            col = target';
            surface([x;x],[y;y],[z;z],[col;col],...
                'facecol','no',...
                'edgecol','interp',...
                'linew',2);
            title('Sum of square error over measurement')
            xlabel('Cycle in measurement')
            ylabel('Sum of squared error over measurement')
            
            nexttile
            histPara = histfit(reshape(residualV,1,[]));
            ydata = get(histPara,'YData');
            xdata = get(histPara,'XData');
            hskew = skewness(ydata{1,1});
            hkurt = kurtosis(ydata{1,1});
            hmean = mean(reshape(residualV,1,[]));
            text(max(xdata{1,1})*3/4,max(ydata{1,1})/2,{['Skewness: ' num2str(hskew)] [' Kurtosis: ' num2str(hkurt)] [' Mean: ' num2str(hmean)]})
            title('Distibution of residuals')
            xlabel('Value of residual')
            ylabel('Count')
            nexttile
            [~, maxErrorCycle] = max(sqrtErrorMeasurment);
            plot(data(maxErrorCycle,:));
            hold on
            plot(outReconst(maxErrorCycle,:));
            title(['Worst Approximation in Dataset (cycle ' , num2str(maxErrorCycle) , ')']);
            xlabel('Point in cycle')
            ylabel('Measurement value')
            legend('Original cycle','Approximation')
        end
        
        function this = train(this, rawData)
            this.trainingFinished = false;
            preTransformedData = this.pretransform(rawData);
            this = this.trainFromPreTransformed(preTransformedData);
        end
        
    end
    methods (Access = protected)
        finishTraining(this);
    end    
end

