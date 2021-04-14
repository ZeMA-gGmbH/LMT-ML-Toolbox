function [ controller ] = showApproxRamData( data, target )
%EXTRACTFEAT Summary of this function goes here
%   Detailed explanation goes here

f = Factory.getFactory();
sens = f.getSensor(f.getRamData(data), '');
cycLen = size(data, 2);
cv = cvpartition(size(target, 1), 'kfold', 10);
[obj, ~] = f.getMultisensorFullTree('',cv,target, cycLen, 20, {sens});
controller = f.getMapReduceController(cv, target);
controller.addPipeline(obj)
controller.trainFeatureExtraction(true, true, false);
controller.fourTimesPlot({sens.copy()});
end

