function [ cycMat ] = continousToCyc( contData, windowLen, overlap )
%CONTIOUSTOCYC Converts continous data to cyclic data by windowing.
%
%Inputs:
%contData:  Array of continous data
%windowLen: Length of rectengular window and expected cycleLength
%overlap:   Overlap of windows in percent of window length
%
%Outputs:
%cycMat:    NumCyc x windowLength matrix representing cycles

l = length(contData);
overlap = round(windowLen * overlap / 100);
cycNum = floor((l-windowLen)/overlap);
cycMat = zeros(cycNum, windowLen);
for i = 1:cycNum
    start = (i-1) * overlap + 1;
    stop = start + windowLen - 1;
    cycMat(i,:) = contData(start:stop);
end

end

