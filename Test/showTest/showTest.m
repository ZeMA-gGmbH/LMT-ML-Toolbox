addPaths

load('naph.mat')
sensors = sensors{:,:};
%%
st = SimpleTrainingStack({@PCAExtractor,@Pearson, @LDAMahalClassifier},...
    {{}, {}, {}});
cv = cvpartition(profile,'KFold',10);
st.train(sensors(cv.training(1),:),profile(cv.training(1)));
st.apply(sensors(cv.test(1),:));
st.show();