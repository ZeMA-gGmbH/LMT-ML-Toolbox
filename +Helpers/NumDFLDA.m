addpath('../../');
nFeat = 100;

%load('FFTStudy.mat');
cv = cvpartition(target, 'KFold', 10);

err = zeros(length(unique(target))-1, 1);
for i = 1:cv.NumTestSets
    trainInd = cv.training(i);
    class.train(d(trainInd, 1:nFeat), target(trainInd));
    trainTarget = target(trainInd);
    testTarget = target(cv.test(i));
    for n = 1:length(unique(target))-1
        train.classes = trainTarget;
        train.usedclasses = unique(trainTarget);
        train.transformed_data = d(trainInd, 1:nFeat)*class.projLDA(1:end-1,:)...
                + ones(sum(trainInd), 1)*class.projLDA(end,:);
        test.transformed_data = d(cv.test(i), 1:nFeat)*class.projLDA(1:end-1,:)...
                + ones(sum(cv.test(i)), 1)*class.projLDA(end,:);
        train.transformed_data = train.transformed_data(:,1:n);
        test.transformed_data = test.transformed_data(:,1:n);
        result = Helpers.Mahal_Classifier(train,test, '');
        pred = result.PredicGroups;
        err(n) = err(n) + sum(pred ~= testTarget);
    end
end
err = err./size(d,1)*100;


plot(err, 'LineWidth', 2)
xlabel('Number of discriminant functions', 'FontSize', 16)
ylabel('Classification error (%)', 'FontSize', 16)

savefig('ErrNumDF');
set(gcf, 'PaperPositionMode', 'auto');
print('ErrNumDF', '-dpng', '-r300');
