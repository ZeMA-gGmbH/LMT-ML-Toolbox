function [ error ] = evalLDA( X, Y )
%EVALLDA Summary of this function goes here
%     %   Detailed explanation goes here
     %persistent part;
%     persistent lastY;
    %if isempty(part) %|| (length(Y) ==  length(lastY) && any(lastY ~= Y))
        part = cvpartition(Y,'kfold', 10);
    %end
%     lastY = Y;
    numClasses = length(unique(Y));
    try

        errors = ones(1,part.NumTestSets);

        %Todo: parallelize!!!!
        for i = 1:part.NumTestSets
            %get projection Matrix on numClasses-1 dimensions
            train.data = X( part.training(i), :);
            train.classes = Y ( part.training(i), :);
            train.usedclasses = unique(train.classes);
            test.data = X(part.test(i),:);
            test.classes = Y(part.test(i),:);

            train.coeff = Helpers.lda2(X( part.training(i), :), Y ( part.training(i), :), numClasses - 1);
            %project training data

            train.transformed_data = train.data*train.coeff(1:end-1,:)...
                + ones(size(train.data,1), 1)*train.coeff(end,:); 

            test.transformed_data = test.data*train.coeff(1:end-1,:)...
                + ones(size(test.data,1), 1)*train.coeff(end,:);

            classifier(i,1) = Helpers.Mahal_Classifier(train, test, 'Vali');
            %classify holdout data

            %compute classification error
        end

        error = Helpers.ClassifierRate(classifier, ...
         [train.usedclasses, train.usedclasses], 0);
        index = logical(ones(size(error.ConfusionMatrix)) - eye(size(error.ConfusionMatrix)));
        error = sum(sum(error.ConfusionMatrix(index)))/length(Y);
    catch ME
        %disp(ME);
        error = 1;
    end
end

