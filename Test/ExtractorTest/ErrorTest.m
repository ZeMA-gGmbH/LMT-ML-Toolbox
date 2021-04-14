%%
disp("DataRead")
load("naph.mat")
sensors = sensors{:,:};
%%
alaTest = ALAExtractor();
alaTest.train(sensors);
alaTest.showError(sensors,profile);

%%
alaTest = BDWExtractor();
alaTest.train(sensors);
alaTest.showError(sensors,profile);

%%
alaTest = PCAExtractor();
alaTest.train(sensors);
alaTest.showError(sensors,profile);

%%
alaTest = BFCExtractor();
alaTest.train(sensors);
alaTest.showError(sensors,profile);