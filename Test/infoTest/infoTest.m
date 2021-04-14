%%
load('hyd.mat');
target = profile;
addPaths
%%
testStack = SimpleTrainingStack({@Standardisation,@MultisensorExtractor, @Pearson,  @LDAMahalClassifier}, ...
    {{},{@ALAExtractor}, {500}, {}, {}});

testStack.train(sensors(1,6:7),target(:,1));
test = testStack.info();
if(test{1,4}(1) == 1 && test{1,2,1}(1,1) == 1056)
    disp("OK")
else
    disp("ERROR")
end

%%
testStack = SimpleTrainingStack({@MultisensorExtractor, @Pearson,  @LDAMahalClassifier}, ...
    {{@BFCExtractor}, {500}, {}, {}});

testStack.train(sensors(1,6:7),target(:,1));
test = testStack.info();
if(test{1,4}(1) == 2 && test{1,2}(1,1) == 18)
    disp("OK")
else
    disp("ERROR")
end

%%
testStack = SimpleTrainingStack({@MultisensorExtractor, @Pearson,  @LDAMahalClassifier}, ...
    {{@PCAExtractor}, {500}, {}, {}});
testStack.train(sensors(1,5:7),target(:,1));
test = testStack.info();

if(test{1,3}(1) == 2 && test{1,1}(1,1) >= 0.031952115824 && test{1,1}(1,1) <= 0.031952115826)
    disp("OK")
else
    disp("ERROR")
end
%%
testStack = SimpleTrainingStack({@MultisensorExtractor, @Pearson,  @LDAMahalClassifier}, ...
    {{@BDWExtractor}, {500}, {}, {}});

testStack.train(sensors(1,5:7),target(:,1));
test = testStack.info();
if(test{500,2}(1) == 329 && test{500,4}(1,1) == 2 && test{1,2}(1) == 637 && test{1,4} == 3)
    disp("OK")
else
    disp("ERROR")
end

%%
testStack = SimpleTrainingStack({@MultisensorExtractor, @Pearson,  @LDAMahalClassifier}, ...
    {{@StatisticalMoments}, {500}, {}, {}});

testStack.train(sensors(1,6:7),target(:,1));

test = testStack.info();
if(test{1,4}(1) == 1 && test{1,2}(1,1) == 1201 && test{80,4} == 2 && test{79,2}(1,1) == 3601)
    disp("OK")
else
    disp("ERROR")
end
%%
testStack = SimpleTrainingStack({@MultisensorExtractor, @RFESVM,  @LDAMahalClassifier}, ...
    {{@BFCExtractor}, {500}, {}, {}});

testStack.train(sensors(1,6:7),target(:,1));
test = testStack.info();
if(test{1,2}(1) == 2 && test{1,4}(1,1) == 2 && test{500,2}(1) == 19 && test{500,4}(1,1) == 2)
    disp("OK")
else
    disp("ERROR")
end
%%
testStack = SimpleTrainingStack({@MultisensorExtractor, @RELIEFF,  @LDAMahalClassifier}, ...
    {{@BFCExtractor}, {500}, {}, {}});

testStack.train(sensors(1,6:7),target(:,1));
test = testStack.info();
if(test{1,2}(1) == 147 && test{1,4}(1,1) == 1 && test{500,2}(1) == 168 && test{500,4}(1,1) == 2)
    disp("OK")
else
    disp("ERROR")
end

%%
testStack = SimpleTrainingStack({@MultisensorExtractor, @Pearson,@NumFeatRanking,  @LDAMahalClassifier}, ...
    {{@BFCExtractor}, {150},{@RELIEFF}, {}, {}});

testStack.train(sensors(1,6:7),target(:,1));
test = testStack.info();
if(test{1,2}(1) == 1 && test{1,4}(1,1) == 1 && test{30,2}(1) == 184 && test{30,4}(1,1) == 2)
    disp("OK")
else
    disp("ERROR")
end

