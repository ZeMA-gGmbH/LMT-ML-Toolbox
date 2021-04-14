addPaths
load('naph.mat')
sensors3 = {sensors{:,:} sensors{:,:} sensors{:,:}};
extractors = {@ALAExtractor @ALAExtractor};
extractorArgs = {{} {}};

%%
mult = MultiSensorMultiExtractor(extractors,extractorArgs);
mult.train(sensors3);
mult.apply(sensors3);
%%
extractors = {@ALAExtractor @BFCExtractor};
extractorArgs = {{} {}};
numF = {{10} {20} {30};{40} {50} {100}};
mult = MultiSensorMultiExtractor(extractors,extractorArgs,true,numF);
mult.train(sensors3);
mult.apply(sensors3);
%%
extractors = {@ALAExtractor @BFCExtractor @BDWExtractor @PCAExtractor};
extractorArgs = {{} {} {} {}};
numF = {{1:10} {5:16} {1:10}};
mult = MultiSensorMultiExtractor(extractors,extractorArgs,false,numF);
mult.train(sensors3);
testOut = mult.apply(sensors3);
%%
extractors = {@ALAExtractor @BFCExtractor @BDWExtractor @PCAExtractor};
extractorArgs = {{} {} {} {}};
st = SimpleTrainingStack({@MultiSensorMultiExtractor,@Pearson,@NumFeatRanking,@LDAMahalClassifier},{{extractors,extractorArgs,true},{200},{@RFESVM},{}});

st.train(sensors3,profile);
testOut = st.apply(sensors3);
infoOut = st.info();