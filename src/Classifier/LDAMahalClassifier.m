classdef LDAMahalClassifier < CLSuperClass
    %LDACLASSIFIER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        data_plot = {}
        target_plot = {}
        projLDA = [];
        gm = [];
        icovar = [];
        target = [];
        leftOutFeat = [];
        meanTrain = [];
    end
    
    methods
        function this = Classifier(varargin)
            if narargin == 0
                this.data = [];
                this.target = [];
                this.projLDA = [];
            elseif narargin == 2
                this.data = varargin{1};
                this.target = varargin{2};
                this.projLDA = [];
            elseif narargin == 3
                this.data = varargin{1};
                this.target = varargin{2};
                this.projLDA = varargin{3};
            else
                error('Wrong number of arguments');
            end
        end
        
        function train(this, X, Y)
            tempData = cell(1,1);
            tempTarget = cell(1,1);
            tempData{1,1} = X;
            tempTarget{1,1} = Y;
            this.data_plot = tempData;
            this.target_plot = tempTarget;
            
            this.target = Y;
            
            %remove constant Features to prevent nans and Infs in
            %covariance matrices
            s = std(X, [], 1);
            this.leftOutFeat = s~=0;
            X = X(:, this.leftOutFeat);
            
            groups = unique(Y);
            dim = length(groups) - 1;
            
            %X = zscore(X);
            xm = mean(X);
            this.meanTrain = xm;
            X = X - xm(ones(size(X,1),1),:); 
            
            withinSSCP = zeros(size(X,2));
            covarianz = cell(size(groups));
            gm = cell(size(groups));
            for g = 1:length(groups)
                if iscell(groups) 
                    ind = strcmp(Y, groups(g));
                else
                    ind = Y == groups(g);
                end
                gm{g} = mean(X(ind,:));
                withinSSCP = withinSSCP + (X(ind,:)-gm{g})' * (X(ind,:)-gm{g});
                covarianz{g} = cov(X(ind,:));
            end
            this.gm = gm;
            betweenSSCP = X' * X - withinSSCP;
            
            try
            warning('off')
            [proj, ~] = eig(withinSSCP\betweenSSCP);
            warning('on')
            proj = proj(:, 1:min(size(X,2),dim));
            scale = sqrt(diag(proj' * withinSSCP * proj) ./ (size(X,1)-length(groups)));
            proj = bsxfun(@rdivide, proj, scale');
            this.icovar = cellfun(@(a){inv(proj' * (a * proj))}, covarianz);
            this.projLDA = proj;
            catch ME
                disp(getReport(ME));
            end
        end
        
        function pred = apply(this, X)
            tempData = cell(size(this.data_plot,1)+1,1);
            tempTarget = cell(size(this.target_plot,1)+1,1);
            for i = 1:size(this.data_plot,1)
                tempData{i,1} = this.data_plot{i,1};
                tempTarget{i,1} = this.target_plot{i,1};
            end
            tempData{end,1} = X;
            this.data_plot = tempData;
            
            X = X(:, this.leftOutFeat);
            %CenterData with mean from Prev?!
            xm = this.meanTrain;
            X = X - xm(ones(size(X,1),1),:); 
            if isempty(this.projLDA)
                pred = ones(size(X,1),1) * mode(this.target);
            else
                try
                    groups = unique(this.target);
                    testDataProj = X * this.projLDA;
                    mahalDist = Inf(size(testDataProj,1), length(groups));
                    for g = 1:length(groups)
                        m = this.gm{g}*this.projLDA;
                        mahalDist(:,g) = sum(((testDataProj-m)*this.icovar{g}) .* (testDataProj-m), 2);
                    end
                    [~, predInd] = min(mahalDist, [], 2);
                    if ischar(groups)
                        pred = groups{predInd};
                    else
                        pred = groups(predInd);
                    end
                catch ME
                    disp(ME)
                    %try to predict into majority class
                    try
                        groups = unique(this.target);
                        counts = zeros(size(groups));
                        for g = 1:length(groups)
                            if iscell(groups)
                                counts(g) = sum(strcmp(this.target, groups{g}));
                            else
                                counts(g) = sum(this.target == groups(g));
                            end
                        end
                        [~, pred] = max(counts);
                        pred = repmat(pred, size(X,1), 1);
                    catch
                        pred(:) = nan;
                    end
                end
            end
            tempTarget{end,1} = pred;
            this.target_plot = tempTarget;
        end
        
        function showLDA(this, varargin)
            plot3 = false;
            if nargin > 1
                plot3 = varargin{1};
            end
            figure;
            if isempty(this.projLDA)
                title('LDA not trained or training error', 'FontSize', 16);
                return;
            end
            trans = this.data*this.projLDA(1:end-1,:)...
                        + ones(size(this.data,1), 1)*this.projLDA(end,:);
            groups = unique(this.target, 'stable');
            hold on
            for i = 1:length(groups)
                if iscell(groups)
                    ind = strcmp(groups{i}, this.target);
                else
                    ind = groups(i) == this.target;
                end
                if plot3 && size(trans,2) > 2
                    scatter3(trans(ind,1), trans(ind,2), trans(ind,3), 'filled', 'LineWidth', 2);
                elseif size(trans,2) > 1
                    scatter(trans(ind,1), trans(ind,2), 'filled', 'LineWidth', 2);
                else
                    histogram(trans(ind));
                end
            end
            if iscell(groups)
                legend(groups, 'Location', 'best');
            else
                legend(arrayfun(@num2str, groups, 'UniformOutput', false), 'Location', 'best');
            end
            set(gcf, 'PaperPositionMode', 'auto');
            xlabel('first discriminant function', 'FontSize', 16);
            ylabel('second discriminant function', 'FontSize', 16);
            if plot3
                zlabel('third discriminant function', 'FontSize', 16);
            end
        end
        
        function show(this)
            figure()
            numD = size(this.data_plot,1);
            first = true;

            for i = 1:size(this.data_plot,1)

                proj = (this.data_plot{i,1}-this.meanTrain(ones(size(this.data_plot{i,1},1),1),:))*this.projLDA;
                if first == true
                    scat = scatter(proj(:,1),proj(:,2),75,this.target_plot{i,1},'*');
                    first = false;
                    
                elseif i == 2 %Use for simple trainig stack because the
                %plot becomes more clear
                    
                else
                    scat = scatter(proj(:,1),proj(:,2),30,this.target_plot{i,1},'d','filled','MarkerEdgeColor',[i/numD 0 0],'LineWidth',0.5);
                end
                hold on
            end
            legend();
            colorbar();
            xlabel("DF1");
            ylabel("DF2");
            title("LDA (* traindata / diamonds testdata)")
        end
    end
    
end

