function [result_mahacl] = Mahal_Classifier(train, test, Modus)
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% written by Matthias Bock 2013 (MT IV Seminar)
% modified by Christian Bur, July 2014
%
% Classifier based on Mahalanobis distance
%
% Input:  struct train, data from LDA ("training data")
%            train.transformed_data, train.classes, train.usedclasses
%
%         struct test, to be classified ("evaluation data")
%            test.transformed_data
%
% Output: struct result_mahacl
%            result_mahacl.PredicGroups: group of every datapoint in test
%              assigned by the classifier (min Mahalanobis distance)
%            result_mahacl.KnownGroups: correct group relation
%            result_mahacl.corClassified: logical vector (1 correctly
%               classified, 0 wrong) for each data point in tbclass
%            result_mahacl.min_dist: minimal Mahalanobis distance

% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Compute all Mahalanobis distances between the datapoints in tbclass and the
% particular groups

result_mahacl.maha = zeros(size(test.transformed_data,1), length(train.usedclasses));

for i=1:length(train.usedclasses)
    
    %indizes = strcmp(train.usedclasses(i), train.classes)==1;
    indizes = train.classes == train.usedclasses(i);
    %if(size(train.transformed_data(indizes,:),1) > size(train.transformed_data(indizes,:),2))
    w = warning ('off','all');
        maha_dist = mahal(test.transformed_data, train.transformed_data(indizes,:));
        result_mahacl.maha(:,i) =  maha_dist;
    %else
    %    msgbox('Classification error. Training data set is too small');
    %    return;
    %end
end

% Find the group with minimal mahal distance for every datapoint in tbclass
[result_mahacl.min_dist, min_ind] = min(result_mahacl.maha,[],2);

% Assign group with minimal distance (predicted group)
result_mahacl.PredicGroups = train.usedclasses(min_ind); 

% correct group relation
if strcmp(Modus, 'TerriPlot') == 1   % LDA territorial plot
    
elseif strcmp(Modus, 'Vali') == 1 % Validation
    result_mahacl.KnownGroups = test.classes;
    % corClassified: 1 for correctly classified, 0 for wrong classified            
    result_mahacl.corClassified = strcmp(result_mahacl.KnownGroups, ...
    result_mahacl.PredicGroups);

elseif strcmp(Modus, 'Eval') == 1 % evaluation (apply)
    % knownGroups: groups should be classified as
    result_mahacl.KnownGroups = test.Zuordnungclasses;
    % realGroup: real group label
    result_mahacl.realGroups = test.classes;
    % corClassified: 1 for correctly classified, 0 for wrong classified            
    result_mahacl.corClassified = strcmp(result_mahacl.KnownGroups, ...
    result_mahacl.PredicGroups);
end

end
