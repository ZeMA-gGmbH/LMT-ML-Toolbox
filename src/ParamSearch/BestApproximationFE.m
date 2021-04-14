classdef BestApproximationFE  < UnSupervisedTrainable & Appliable
    %BESTAPPROXIMATIONFE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        approxE = [];
        extractor = {};
    end
    
    methods
        function train(this, data)
            ext = {BFCExtractor(), BDWExtractor(), PCAExtractor(), ALAExtractor()};
            
            this.approxE = Inf(size(ext));
            for i = 1:length(ext)
                preTrans = ext{i}.pretransform(data);
                ext{i}.trainFromPreTransformed(preTrans);
                rec = ext{i}.reconstruct(ext{i}.applyToPretransformed(preTrans));
                if size(rec,2) ~=  size(data,2) 
                    rec = rec(:,1:size(data,2));
                end    
                this.approxE(i) = sum(sum((rec-data).^2));
            end
            
            [~, bestE] = min(this.approxE);
            this.extractor = ext{bestE};
        end
        
        function feat = apply(this, data)
            feat = this.extractor.apply(data);
        end
    end
end

