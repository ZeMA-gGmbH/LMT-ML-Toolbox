function [err] = numFeatClassifier(data, classes, rank, cv, classifier)
%NUMFEATCLASSIFIER Summary of this function goes here
%   Detailed explanation goes here
    err = zeros(1, size(data,2));
    for c = 1:cv.NumTestSets
        disp(['Cross-Validating Classifier: ',num2str(c/cv.NumTestSets*100), ' % progress']);
        trainData = single(data(cv.training(c), :));
        testData = single(data(cv.test(c),:));
        
        trainTarget = classes(cv.training(c));
        testTarget = classes(cv.test(c));
        
        parfor n = 1:size(trainData,2)
            classifier.train(trainData(:,rank(1:n)), trainTarget);
            err(n) = err(n) + sum(testTarget ~= classifier.apply(testData(:,rank(1:n))));
        end
    end
    err = err./size(data,1);
end

