classdef NDSuperCalss < NoveltyDetection
    %NOVELTYDETECTION Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        th = [];
        isNoveltyMeasure = false;
    end
    
    methods
        function th = getThreshold(this)
            th = this.th;
        end
        
        function setThreshold(this, t)
            this.th = t;
        end
        
        function plotTerritorial(this, data, normal)
            classify = @(a)apply(this,a);
            territorialPlot(data, double(normal), @(a)double(getSecondOutput(classify, a)), 1000);
        end
        
        function plotProgression(this, data)
            figure;
            scores = this.apply(data);
            plot(scores, 'LineWidth', 2);
            line(get(gca, 'XLim'), [this.th, this.th], 'Color', 'black');
            legend({'Scores', 'Threshold'}, 'Location', 'best');
            ylabel('score', 'FontSize', 16)
        end
        
        function plotHistogram(this, data, trueLables)
            [scores] = this.apply(data);
            class  = scores<this.th;
            [~, edges] = histcounts(scores, 50);
            if nargin > 2 && ~isempty(trueLables)
                lables = trueLables;
            else
                lables = class;
            end
            uniqueLables = unique(lables);
            figure;
            hold on;
            for i = 1:numel(uniqueLables)
                histogram(scores(lables == uniqueLables(i)), edges);
            end
            line([this.th, this.th], get(gca, 'YLim'), 'Color', 'black');
            legend({'novel','normal', 'threshold'});
            ylabel('count', 'FontSize', 16);
            xlabel('score (au)', 'FontSize', 16);
        end
        
        function plotHistogramCV (this, data, cv, compare10Fold)
            if nargin > 3 && compare10Fold
                cv2 = cvpartition(size(data,1), 'KFold', 10);
                scores = zeros(size(data,1),1);
                for i = 1:cv2.numTestSets
                    nd = feval(class(this));
                    nd.train(data(cv.training(i),:));
                    scores(cv2.test(i)) = nd.apply(data(cv.test(i),:));
                end
            else
                [scores] = this.apply(data);
            end
            scoresCV = zeros(size(scores));
            for i = 1:cv.NumTestSets
                nd = feval(class(this));
                nd.train(data(cv.training(i),:));
                scoresCV(cv.test(i)) = nd.apply(data(cv.test(i),:));
            end
            
            [~, edges] = histcounts([scores; scoresCV], 50);
            figure;
            hold on;
            histogram(scores, edges);
            histogram(scoresCV, edges);
            proposedTh = median(scoresCV);
            
            line([this.th, this.th], get(gca, 'YLim'), 'Color', 'black');
            line([proposedTh, proposedTh], get(gca, 'YLim'), 'Color', 'yellow');
            legend({'data','cross-validated data', 'threshold', 'CVThreshold'});
            ylabel('count', 'FontSize', 16);
            xlabel('score (au)', 'FontSize', 16);
        end
        
        function T = plotROC(this, data, normal)
            scores = this.apply(data);
            [X,Y,T,AUC,OPTROCPT] = perfcurve(normal , scores, ~this.isNoveltyMeasure);
            T = T(X == OPTROCPT(1) & Y == OPTROCPT(2));
            figure;
            hold on;
            plot(X,Y, 'LineWidth', 2);
            scatter(OPTROCPT(1), OPTROCPT(2), 'o', 'MarkerEdgeColor', 'red', 'LineWidth', 2);
            legend({['ROC-Curve (AUC: ', num2str(AUC),')'],...
                ['optimal operating point (t = ', num2str(T),')']},...
                'Location', 'best');
            xlabel('False positive rate', 'FontSize', 16);
            ylabel('True positive rate', 'FontSize', 16);
        end
        
    end
end

