%% Dataset and Helpers lda2 are needed 
load('hyd.mat');
target = profile;
%%
selTarget = 2;
selSensor = 4:7;

multEx = MultisensorExtractor(@ALAExtractor);
multEx.train(sensors(1,selSensor));
outMult = multEx.apply(sensors(1,selSensor));

selPearson = RFESVM(10);
selPearson.train(outMult,target(:,selTarget));
outSel = selPearson.apply(outMult);

data = outSel;

ldaClass = LDAMahalClassifier();
ldaClass.train(outSel,target(:,selTarget));
ldaClass.apply(outSel);
%%
proj = ldaClass.projLDA;
nor = vecnorm(proj(:,:));
proj = proj./nor;

figure()
dataProj = data*proj;
scatter(-dataProj(:,1),dataProj(:,2),[],target(:,selTarget))
title("New LDA");
figure()
coeff = lda2(data,int64(target(:,selTarget)),6);
nor = vecnorm(coeff(1:end-1,:));
coeff = coeff./nor;
dataProj = data*coeff(1:end-1,:);
scatter(dataProj(:,1),dataProj(:,2),[],target(:,selTarget));
title("Old LDA");
%%
load('naph.mat');
target = profile;
%%
selTarget = 1;
selSensor = 1;

multEx = MultisensorExtractor(@ALAExtractor);
multEx.train(sensors(1,selSensor));
outMult = multEx.apply(sensors(1,selSensor));

selPearson = RFESVM(20);
selPearson.train(outMult,target(:,selTarget));
outSel = selPearson.apply(outMult);

data = outSel;

ldaClass = LDAMahalClassifier();
ldaClass.train(outSel,target(:,selTarget));
pred = ldaClass.apply(outSel);
acc = ClassificationError.loss(pred,target);
%%
proj = ldaClass.projLDA;
% nor = vecnorm(proj(:,:));
% proj = proj./nor;

figure()
dataProj = data*proj;
scatter(dataProj(:,1),dataProj(:,2),[],target(:,selTarget))
title("New LDA");
figure()
coeff = Helpers.lda2(data,int64(target(:,selTarget)),6);
%nor = vecnorm(coeff(1:end-1,:));
%coeff = coeff./nor;
dataProj = data*coeff(1:end-1,:);
scatter(dataProj(:,1),dataProj(:,2),[],target(:,selTarget));
title("Old LDA");
%%
ldaClass = LDAMahalClassifier();
cv = cvpartition(target,'KFold',10);
ldaClass.train(outSel(cv.training(1),:),target(cv.training(1),selTarget));
pred = ldaClass.apply(outSel(cv.test(1),:));