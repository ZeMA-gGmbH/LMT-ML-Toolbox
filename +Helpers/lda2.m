function coeff = lda2(data, classes, num_coeffcol)
%
% =========================================================================
%                   Linear Discriminant Analysis 
%                        based on 'manova1'
% =========================================================================
%
% [ coeff, r ] = lda(data, classes, num_coeffcol, flag_stepwise)
%
%  data:        List of feature vectors (one vector per row)
%  classes:     Class/Category of the feature vectors (one integer 
%               per feature vector)
%  num_coeffcol:Anzahl der zu verwendenden Diskriminanzfunktionen, i.d.R. 2
%
%
%  coeff:       normed LDA coefficients
%  r:           struct with all other (and intermediate) results
%
%
% Authors:      Thomas Fricke & Christian Bur
% Lehrstuhl für Messtechnik, Juni 2013
%


% tic
if (size(classes,2) ~= 1)
    error('classes must be one-dimensional!')
end


[ r.num_measurements, r.num_features ] = size(data);
r.num_groups = size(unique(sort(classes)),1);
r.num_measurements_in_group = zeros(r.num_groups);

% if classes is a cell array, it does not contain integer indexes,
% but free form strings. create a matching table.
if (iscell(classes))
    allclasses = unique(sort(classes));
    oldclasses = classes;
    clear classes;
    for i=1:r.num_measurements
        for j=1:length(allclasses)
            if (strcmp(allclasses{j}, oldclasses{i}))
                classes(i) = j;
            end
        end
        %r.num_measurements_in_group(classes(i)) = ...
        %r.num_measurements_in_group(classes(i)) + 1;
    end
end

%% Multivariate Analysis of Variance (based on manova1)
% Calculation of Discriminant Coefficients

% Added by Thomas Fricke 25.04.2013


[~,~,stats] = manova1(data,classes); % Using manova1

% Calculate b0
X_j = sum(data) / (stats.dfT + 1); %r.num_measurements;
b0 = -1.0 * (X_j * stats.eigenvec);

% write the results in the right structures
%r.B = stats.B;
%r.W = stats.W;
%r.T = stats.T;
%r.eigenvalues = stats.eigenval;

% maximum number of discriminant functions possible
% r.max_funcs = min( [ r.num_groups - 1 , r.num_features ] ); 
r.max_funcs = size(stats.lambda,1);
%r.num_features = size(stats.W,1);
%r.num_measurements = stats.dfT + 1;
%r.num_groups = size(stats.gnames,1);
%r.num_DFs = min(num_coeffcol,r.max_funcs);

% Discriminant Coefficients (normalized)
% used to calculated the projection/scatterplot
r.coeff= [stats.eigenvec(:,1:r.max_funcs);b0(1:r.max_funcs)];
coeff=r.coeff(:,1:min(num_coeffcol,r.max_funcs));

% unscaled Discriminant Coefficients
%r.coeff_unscaled = sqrt(1/((r.num_measurements-r.num_groups))).*r.coeff;

% standardized Discriminant Coefficients 
% used to compare the coefficients and necessary for the Loadings Plot
%r.coeff_stand(1:size(r.coeff,1)-1,:)=diag(sqrt( 1./...
%    ((r.num_measurements-r.num_groups))*diag(r.W) ))*r.coeff(1:size(r.coeff,1)-1,:);


%% Some Statistics for each Discriminant Function

% Cumulated variance/energy for all theoretically possible DFs
% used for e.g. Scree-Plot
%r.cumulative_energy = cumsum(r.eigenvalues(1:r.max_funcs));
% normalized to 0..1 respectively 0..100%
%r.cumulative_energy = r.cumulative_energy ./ r.cumulative_energy(r.max_funcs);


% Amount of information represented by DF with regard to all possible DFs
% Name in Backhaus: Eigenwertanteil,EA
% used for labling the axis of Scatterplot
%r.amount_info = 100*r.eigenvalues(1:r.max_funcs)./sum(r.eigenvalues(1:r.max_funcs)); 
%r.amount_info = round(r.amount_info.*100)/100; 
        
% Canonical Correlation Coefficient
%r.canonical_correlation_coefficient = sqrt(r.eigenvalues(1:r.max_funcs)...
%    ./ (1 + r.eigenvalues(1:r.max_funcs)));

% Wilks' Lambda
%r.wilks_lambda = 1.0 ./ (1 + r.eigenvalues(1:r.max_funcs));

% Significance level, similar to Chi-Square
%r.chi_square = - (r.num_measurements - ...
%    (r.num_features+r.num_groups)/2-1)*log(r.wilks_lambda);

% (Residual) Wilks' Lambda
% Testing the significance of all DFs after the first k with k = 0,1,..,(#DFs -1)
%r.wilks_lambda_residual = stats.lambda;


    
%% Some Statistics for the entire Discrimination

    % Multivariate Wilks' Lambda, bezogen auf alle benutzte DFs 
    % (also 2 oder 3). Normalerweise definiert von i=1:max_func
    %r.wilks_lambda_multivar = cumprod(r.wilks_lambda(1:r.num_DFs));
    %r.wilks_lambda_multivar = r.wilks_lambda_multivar(end);
    
    % Multivariate Signifikanzprüfung, ähnlich zu Chi-Square
    %r.chi_square_multivar = - (r.num_measurements - ...
    %    (r.num_features+r.num_groups)/2-1)*log(r.wilks_lambda_multivar);
    % Cluster Separatbility
    % see ppt from Steve Semancik, COST EuNetAir Training School 2014 in SB
    %r.J = trace(r.B) / (trace(r.B)+trace(r.W)) * 100; % in Procent
    
%% Some Statistics for each Feature Variable

% Average Discriminant Coefficient (mittlerer Diskriminanzkoeffizient) 
% siehe Bakchaus 11. Auflage Seite 188
%r.b_quer =  abs(r.coeff_stand) * r.amount_info/100;

% Univariate F 
%r.F = ( diag(r.T - r.W) .* (r.num_measurements - r.num_groups) ) ./ ...
%    ( diag(r.W) * (r.num_groups - 1) );

% Univariate (Wilks') Lambda 
%r.Lambda = diag(r.W ./ r.T);  

% String for coefficients b_i
%r.coeff_name= {};

%for i=1:r.num_features   
%   % Name b(i) für Coeff.
%   a = i;
%   r.coeff_name = [r.coeff_name; ['b' num2str(a)]];    
%end
%r.coeff_name = [r.coeff_name; 'b0'];



%% Other Results
% 
%     % Individual Group Covariance Matrix
%     % CB: habe Zweifel an der Richtigkeit der Berechnung!!!!
%     r.C_ind = zeros(r.num_groups, r.num_features, r.num_features);
%     for k=1:r.num_measurements
%         for i=1:r.num_features
%             for l=1:r.num_features
%                 r.C_ind(classes(k),i,l) = r.C_ind(classes(k),i,l) + ...
%                     ( data(k,i)*data(k,l) - ...
%                       Xdash_jg(i,classes(k))*Xdash_jg(l, classes(k)) * ...
%                       r.num_measurements_in_group(classes(k)) );
%             end
%         end
%     end
%     for j=1:r.num_groups
%         for i=1:r.num_features
%             for l=1:r.num_features
%                 r.C_ind(classes(k),i,l) = r.C_ind(classes(k),i,l) / ...
%                     (r.num_measurements_in_group(j));
%             end
%         end
%     end
% 
%     % Within-groups Correlation Matrix R
%     r.R = zeros(r.num_features, r.num_features);
%     for i=1:r.num_features
%         for l=1:r.num_features
%             if (r.W(i,i) * r.W(l,l) == 0)
%                 r.R(i,l) = NaN;
%             else
%                 r.R(i,l) = r.W(i,l) / sqrt(r.W(i,i) * r.W(l,l));
%             end
%         end
%     end

        
    % Total Covariance Matrix T_tot    
%    r.T_tot = ( r.T / (r.num_measurements - 1) ); 
    
    
%     % Test: Christian Bur,04.07.2014 
%     WilksL = det(r.W) / det(r.T)
%     gamma = trace(( r.coeff(1:end-1,:)' * r.B * r.coeff(1:end-1,:)) / ( r.coeff(1:end-1,:)' * r.W * r.coeff(1:end-1,:) ))
%     r.J


% toc









  





