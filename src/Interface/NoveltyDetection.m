classdef NoveltyDetection < UnSupervisedTrainable & Appliable
    %NOVELTY 
    
    methods
%         xy = rocCurve(this, data, novel);
%         scores = getScore(this, data);
%         grid = teritorialPlot(this, xCoordinates, yCoordinates, scatteredData, novel);
%         scores = progressionPlot(this, data);
%         scoresLables = histogramPlot(this, data, novel);
        
        threshold = getThreshold(this);
        
        setThreshold(this, threshold);
        
        th = computeThreshold(this, data);
    end
end

