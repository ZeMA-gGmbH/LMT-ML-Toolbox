classdef MultisensorExtractor < Appliable & UnSupervisedTrainable
    %MULTISENSOREXTRACTOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        extractionAlg = @BFCExtractor;
        extractors = {};
        extArg = {};
    end
    
    methods
        function this = MultisensorExtractor(extractionAlg, extArg)
            if nargin > 0
                if exist('extractionAlg', 'var') && ~isempty(extractionAlg)
                    this.extractionAlg = extractionAlg;
                end
                if exist('extArg', 'var') && ~isempty(extArg)
                    this.extArg = extArg;
                end
            end
        end
        
        function infoCell = info(this)
            infoCell = [];
            for i = 1:size(this.extractors,2)
                temp = this.extractors{i}.info();
                temp1 = cell(size(temp,1),1);
                for j = 1:size(temp,1)
                    temp1{j} = i;
                end
                infoCell = [infoCell; temp temp1];
            end
        end
        
        function train(this, data)
            %data is cell array of matrices
            %ToDo: check all matrices for the same number of rows
            
            %also allow single sensor extraction
            if ~iscell(data)
                data = {data};
            end
            
            this.extractors = cell(size(data));
            for i = 1:length(data)
                if iscell(this.extractionAlg)
                    this.extractors{i} = feval(this.extractionAlg{i}, this.extArg{i});
                elseif iscell(this.extArg)
                    this.extractors{i} = feval(this.extractionAlg, this.extArg{:});
                else
                    this.extractors{i} = feval(this.extractionAlg, this.extArg);
                end
                if isa(this.extractors{i}, 'UnSupervisedTrainable')
                    this.extractors{i}.train(data{i});
                end
            end
        end
        
        function feat = apply(this,data)
            %also allow single sensor extraction
            if ~iscell(data)
                data = {data};
            end
            
            feat = cell(size(data));
            for i = 1:length(data)
                feat{i} = this.extractors{i}.apply(data{i});
            end
            feat = horzcat(feat{:});
        end
    end
end

