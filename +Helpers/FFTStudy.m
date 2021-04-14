addpath('../../');
nFeat = 100;

%load('FFTStudy.mat');
trainInd = arrayfun(@(a)ismember(a, 1:20:100), target);
testInd = arrayfun(@(a)ismember(a, 10:20:100), target);

class.train(d(trainInd, 1:nFeat), target(trainInd));
class.showLDA(true);

testProj = d(testInd, 1:nFeat)*class.projLDA(1:end-1,:)...
                        + ones(size(d(testInd, 1:nFeat),1), 1)*class.projLDA(end,:);

testTarget = target(testInd);
testGroups = unique(testTarget);
for i = 1:length(testGroups)
    ind = testTarget == testGroups(i);
    scatter3(testProj(ind,1), testProj(ind,2), testProj(ind,3));
end

trainGroups = unique(target(trainInd));
legend(arrayfun(@num2str, [trainGroups; testGroups], 'UniformOutput', false));