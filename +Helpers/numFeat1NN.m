function [ err ] = numFeat1NN( data, classes, rank, cv )
%NUMFEATLDAMAHAL Summary of this function goes here
%   Detailed explanation goes here

% err = zeros(1,size(data,2));
% data = zscore(data);
% parfor n = 1:size(data,2)
%     featInd = false(1, size(data,2));
%     featInd(rank(1:n)) = true;
%     
%     mdl = fitcecoc(data(:, featInd), classes, 'CVPartition', cv, 'Learners', 'knn');
%     err(n) = kfoldLoss(mdl);
% end
% end

err = zeros(1,size(data,2));
data = zscore(data);

for c = 1:cv.NumTestSets
    %standardize data?
    trainData = single(data(cv.training(c), :));
    testData = single(data(cv.test(c),:));
    
    trainTarget = repmat(classes(cv.training(c)), 1, size(testData, 1));
    t = classes(cv.training(c));
    testTarget = classes(cv.test(c));
    
    d = zeros(size(trainData,1), size(testData,1), 'single');
    ind = repmat(single(1:size(trainData,1))', 1, size(testData,1));
    [m,nP]=size(d);
    indCol = repmat(1:nP,m,1);
    idx = sub2ind([m nP],ind,indCol);
    for n = 1:size(trainData, 2)
        try
%             newd = (trainData(:,rank(n)) - testData(:,rank(n))').^2;
%             d = d + newd(idx);
%             [d, ind] = sort(d);
%             idx = sub2ind([m nP],ind,indCol);
%             trainTarget = trainTarget(idx);

            newd = (trainData(:,rank(n)) - testData(:,rank(n))').^2;
            d = d + newd;
            [~, idx] = min(d);
            
            %make prediction
%             err(n) = err(n) + sum(testTarget ~= mode(trainTarget(1:5, :))');
            err(n) = err(n) + sum(testTarget ~= trainTarget(idx'));
            
            
%             id = knnsearch(trainData(:, rank(1:n)), testData(:, rank(1:n)));
%             err(n) = err(n) + sum(trainTarget(id) ~= testTarget;
            
            

            %way too slow
%              template = templateKNN('NumNeighbors', 5, 'Standardize', false);
%              mdl = fitcecoc(trainData(:, rank(1:n)), t, 'learners', template);
%              err(n) = err(n) + sum(mdl.predict(testData(:, rank(1:n))) ~= testTarget);
        catch
            err(n) = err(n) + length(testTarget);
        end
    end
end

err = err./size(data, 1);