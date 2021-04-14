%Unit Tests for 4 Extractor Methodes
%Needed Files : All Interfaces, All Extractor Classes, Reference Results
%and Raw Data
%Named according to the tests listed below.
%Tests executed with "results = runtests('extractorTest.m')"

function tests = extractorTest
    tests = functiontests(localfunctions);
end

%Testfunction for comparing ALA Extractor with Reference Results 
function testALA(testCase)
    rawData = readtable('./Data/rawData.csv');
    rawData = rawData{:,:};
    refData = readtable('./Data/alaFeat.csv');
    refData = refData{:,:};
    testextractorALA = ALAExtractor();
    testextractorALA.train(rawData);
    alaData = testextractorALA.apply(rawData);
    refData = refData .* 10^10;
    refData = floor(refData);
    alaData = alaData .* 10^10;
    alaData = floor(alaData);
    assert(isequal(refData,alaData),'ALA comparison failed');
end

%Testfunction for comparing BDW Extractor with Reference Results 
function testBDW(testCase)
    rawData = readtable('./Data/rawData.csv');
    rawData = rawData{:,:};
    refData = readtable('./Data/bdwFeat.csv');
    refData = refData{:,:};
    testextractorBDW = BDWExtractor();
    testextractorBDW.train(rawData);
    bdwData = testextractorBDW.apply(rawData);
    refData = refData .* 10^10;
    refData = floor(refData);
    bdwData = bdwData .* 10^10;
    bdwData = floor(bdwData);
    assert(isequal(refData,bdwData),'BDW comparison failed');
end

%Testfunction for comparing BFC Extractor with Reference Results 
function testBFC(testCase)
    rawData = readtable('./Data/rawData.csv');
    rawData = rawData{:,:};
    refData = readtable('./Data/bfcFeat.csv');
    refData = refData{:,:};
    testextractorBFC = BFCExtractor();
    testextractorBFC.train(rawData);
    bfcData = testextractorBFC.apply(rawData);
    refData = refData .* 10^8;
    refData = floor(refData);
    bfcData = bfcData .* 10^8;
    bfcData = floor(bfcData);
    assert(isequal(refData,bfcData),'BFC comparison failed');
end

%Testfunction for comparing PCA Extractor with Reference Results 
function testPCA(testCase)
    rawData = readtable('./Data/rawData.csv');
    rawData = rawData{:,:};
    refData = readtable('./Data/pcaFeat.csv');
    refData = refData{:,:};
    testextractorPCA = PCAExtractor();
    testextractorPCA.train(rawData);
    pcaData = testextractorPCA.apply(rawData);
    comp = abs(refData - pcaData);
    comp = comp ./ abs(refData);
    comp = floor(comp.*5);
    refzeros = zeros(size(comp));
    assert(isequal(refzeros,comp),'PCA comparison failed');
end