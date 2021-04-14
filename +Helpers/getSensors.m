function [ sensors, numPoints ] = getSensors( data, evalData )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    
    f = Factory.getFactory();
    if iscell(data) & ~ischar(data{1})
        sensors = cell(size(data));
        numPoints = zeros(size(data));
        for i = 1:length(data)
            if nargin > 1
                sensors{i} = f.getSensor(f.getRamData(data{i}), num2str(i), f.getRamData(evalData{i}));
            else
                sensors{i} = f.getSensor(f.getRamData(data{i}), num2str(i));
            end
            numPoints(i) = size(data{i}, 2);
        end
    elseif iscell(data)
        %ToDo: numPoints = signal Length anpassen
        sensors = cell(size(data));
        for i = 1:length(data)
            if nargin > 1
                sensors{i} = f.getSensor(MatfileData(data{i}), num2str(i), MatfileData(evalData{i}));
            else
                sensors{i} = f.getSensor(MatfileData(data{i}), num2str(i));
            end
        end
        numPoints = repmat(sensors{1}.getNumberOfCycles(), 1, length(sensors));
    else
        dataInt = f.getRamData(data);
        if nargin > 1
            sensors = {f.getSensor(dataInt, '', f.getRamData(evalData))};
        else
            sensors = {f.getSensor(dataInt, '')};
        end
        numPoints = size(data, 2);
    end
end

