function [ClassifyRate]  = ClassifierRate(res_classifier, usedclasses, eval)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% written by:   Christian Bur, 25.07.2014
% modified by:  non
%
% ClassifierRate.m calculates the correct classification rate of classifier
% (e.g. Mahalanobis, kNN) for each group/class 
%
% Input: result of a classifier
%   res_classifier.corClassified    logical vector 
%                                   (1 correct, 0 wrong classified)
%   res.classifier.groups           class relationship
%   usedclasses(:,1)                classes used in the training set
%   usedclasses(:,2)                classes to be classified as 
%   eval                            flag: 0: validation; 1: evaluation 
%
% Output:   classification rate for each group + overall
%  ClassiRate.  
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



% Merge logical vectors from every fold
corClassified = vertcat(res_classifier(:).corClassified);
PredicGroups = vertcat(res_classifier(:).PredicGroups);
KnownGroups = vertcat(res_classifier(:).KnownGroups);

% Overall (all groups and all folds) correct classification rate
CorrClassRateOverall = mean(corClassified)*100;

% Initialize
overgroup = zeros(size(usedclasses,1),1);

if eval == 0
    % Correct classification rate for each group  
    for i=1:size(usedclasses,1)
        indGroup = strcmp(usedclasses(i,1), KnownGroups)==1;
        overgroup(i) = mean(corClassified(indGroup))*100;    
    end
    % Confusion Matrix for the classification
    [ClassifyRate.ConfusionMatrix, ClassifyRate.ConfusionNames] = ...
         confusionmat(KnownGroups,PredicGroups, 'order',usedclasses(:,1));
    
elseif eval == 1
    % nur für eval 
    realGroups = vertcat(res_classifier(:).realGroups);
    % for loop for evaluation
    for i=1:size(usedclasses,1) %usedclasses are realGroups 
        % idices of class i
        indGroup = strcmp(usedclasses(i,1), realGroups)==1;         
        % only entries of the vector correspondingt to group i        
        overgroup(i) = mean(corClassified(indGroup))*100;   
        if any(indGroup) == 0 % only 0
            overgroup(i) =0; % nothing was correctly classified
        end
    end
    
    % Confusion Matrix for the classification
    [ClassifyRate.ConfusionMatrix, ClassifyRate.ConfusionNames] = ...
         confusionmat(realGroups,PredicGroups, 'order',...
         unique([vertcat(usedclasses(:)); realGroups; PredicGroups]));
    
end

% Classification rate (overall + for each group)
%ClassifyRate.usedclasses = ['Overall';usedclasses(:,1)];
%ClassifyRate.AsClassifiedClasses = ['---';usedclasses(:,2)];
%ClassifyRate.CorrClassRate = [CorrClassRateOverall;overgroup]; 





