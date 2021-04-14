classdef AmplitudeSpectrum < Appliable
    %STANDARDIZEDPCA Summary of this class goes here
    %   Detailed explanation goes here
    
    properties

    end
    
    methods
        
        function feat = apply(this, data)
            
             if iscell(data)
                [dataL, idx] = max([size(data,1) size(data,2)]);
                
                feat = cell(1,dataL);
                if idx == 2
                    for i = 1:dataL
                        coeff = fft(data{1,i}, [], 2);
                        preTransformed = coeff(:, 1:floor(size(data{1,i},2)/2));
                        coeff = preTransformed(:,:);
                        feat{1,i} = [abs(coeff), angle(coeff)];
                    end
                else
                    for i = 1:dataL
                        coeff = fft(data{i,1}, [], 2);
                        preTransformed = coeff(:, 1:floor(size(data{i,1},2)/2));
                        coeff = preTransformed(:,:);
                        feat{1,i} = [abs(coeff), angle(coeff)];
                    end 
                end
            else    
                coeff = fft(data, [], 2);
                preTransformed = coeff(:, 1:floor(size(data,2)/2));
                coeff = preTransformed(:,:);
                feat = [abs(coeff), angle(coeff)];
            end

        end
        
        function scatter(this, feat, classes)
            cN = unique(classes);
            scores = this.apply(feat);
            figure; hold on;
            for i = 1:length(cN)
                ind = classes == cN(i);
                scatter3(scores(ind,1), scores(ind,2), scores(ind,3));
            end
        end
        
        function loadings(this, names, threeD)
            figure;
            if nargin < 3
                threeD = false;
            end
            if threeD
                scatter3(this.coeff(:,1), this.coeff(:,2), this.coeff(:,3), 'LineWidth', 2);
                line([zeros(size(this.coeff,1),1), this.coeff(:,1)]', [zeros(size(this.coeff,1),1), this.coeff(:,2)]', [zeros(size(this.coeff,1),1), this.coeff(:,3)]', 'LineWidth', 2)
                if nargin > 1
                    for i = 1:size(this.coeff,1)
                        txt = names{i};
                        text(double(this.coeff(i,1)),double(this.coeff(i,2)),double(this.coeff(i,3)),txt)
                    end
                end
            else
                scatter(this.coeff(:,1), this.coeff(:,2), 'LineWidth', 2);
                line([zeros(size(this.coeff,1),1), this.coeff(:,1)]', [zeros(size(this.coeff,1),1), this.coeff(:,2)]', 'LineWidth', 2)
                if nargin > 1
                    for i = 1:size(this.coeff,1)
                        txt = names{i};
                        text(double(this.coeff(i,1)),double(this.coeff(i,2)),txt);
                    end
                end
            end
        end
    end
    
end

