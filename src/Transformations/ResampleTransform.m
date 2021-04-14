classdef ResampleTransform < Appliable
    %STANDARDIZEDPCA Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        intendedLength = 100;
    end
    
    methods
        
        function dwnDat = apply(this, data)
            
             if iscell(data)
                [dataL, idx] = max([size(data,1) size(data,2)]);
                
                dwnDat = cell(1,dataL);
                if idx == 2
                    for i = 1:dataL
                        if size(data{1,i},2) > this.intendedLength
                            % downsample raw data for covariance computation
                            len = cast(size(data{1,i},2), 'like', data{1,i});
                            dsFactor = round(len/this.intendedLength);
                            if isa(data, 'single')
                                dwnDat{1,i} = single(resample(double(data{1,i}'), 1, double(dsFactor))');
                            else
                                dwnDat{1,i} = resample(data{1,i}', 1, dsFactor)';
                            end
                        else
                            dwnDat{1,i} = data{1,i};
                        end
                    end
                else
                    for i = 1:dataL
                        if size(data{i,1},2) > this.intendedLength
                            % downsample raw data for covariance computation
                            len = cast(size(data{i,1},2), 'like', data{i,1});
                            dsFactor = round(len/this.intendedLength);
                            if isa(data, 'single')
                                dwnDat{1,i} = single(resample(double(data{i,1}'), 1, double(dsFactor))');
                            else
                                dwnDat{1,i} = resample(data{i,1}', 1, dsFactor)';
                            end
                        else
                            dwnDat{1,i} = data{i,1};
                        end
                    end 
                end
             else    
                if size(data,2) > this.intendedLength
                    % downsample raw data for covariance computation
                    len = cast(size(data,2), 'like', data);
                    dsFactor = round(len/this.intendedLength);
                    if isa(data, 'single')
                        dwnDat = single(resample(double(data'), 1, double(dsFactor))');
                    else
                        dwnDat = resample(data', 1, dsFactor)';
                    end
                else
                    dwnDat = data;
                end
             end     
        end
    end
    
end

