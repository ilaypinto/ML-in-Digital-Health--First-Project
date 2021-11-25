function [feat_feat_corr_num_under_0_7, feat_feat_corr, feat_label_corr, best_feat_feat,...
    best_feat_label,features_to_remove,new_mat] = corr_analysis(feat_label_mat, feat_names)
% need to add description

% define empty cells arrays
best_feat_label = {};
best_feat_feat = {};
features_to_remove={};

% Slice the data to features and labels
label_vec = feat_label_mat(:, end);                                        % Separate the Labels from matrix
feat_mat = feat_label_mat(:, 1:end - 1);                                   % Separate Features from labels

% Compute correlation
feat_label_corr = corr(feat_mat, label_vec, 'type', 'Spearman');           % Features-Labels correlation
feat_feat_corr = corr(feat_mat, feat_mat, 'type', 'Spearman');             % Features-Features correlation
feat_feat_corr_num_under_0_7 = sum(sum(abs(feat_feat_corr) < 0.7))/2;          % Counts number of correlation under 0.7

% extract the feature with highest feature label correlation
best_feat_label{1} = max(abs(feat_label_corr));                             % value of corr
best_feat_label{2} = find(abs(feat_label_corr) == max(abs(feat_label_corr)));    % index of feature in matrix
best_feat_label{3} = feat_names(best_feat_label{2});                        % feature name


% extract the features with lowest festure feature correlation
[M,I] = min(abs(feat_feat_corr), [], 'all');
index2 = ceil(I/size(feat_feat_corr, 1));
if mod(I, size(feat_feat_corr, 1)) == 0
    index1 = size(feat_feat_corr, 1);
else
    index1 = mod(I, size(feat_feat_corr, 1));
end
best_feat_feat{1} = M;                                                      % value of corr
best_feat_feat{2} = [index1, index2];                                       % index of features
best_feat_feat{3}{1} = feat_names{index1};                                  % names of features
best_feat_feat{3}{2} = feat_names{index2};

%Graphs
% figure(1); gplotmatrix(feat_mat, [], label_vec');                               % gplot
% figure(2); heatmap(abs(feat_feat_corr));title('Spearman correlation - Heatmap') % correlation heatmap

%Names of features with over 0.7 feature-feature correlation

indices=find(and(abs(feat_feat_corr) >= 0.7, abs(feat_feat_corr)~=1) );
indices_rows=ceil(indices./size(feat_feat_corr, 1));
for i=1:length(indices)
    if mod(indices(i), size(feat_feat_corr, 1)) == 0
        indices_cols(i) = size(feat_feat_corr, 1);
    else
        indices_cols(i) = mod(indices(i), size(feat_feat_corr, 1));
    end
    if indices_cols(i)>indices_rows(i)
        features_to_remove{end+1}{1}=feat_names{indices_rows(i)};
        features_to_remove{end+1}{2}=indices_rows(i);
        features_to_remove{end+1}{3}=feat_names{indices_cols(i)};
        features_to_remove{end+1}{4}=indices_cols(i);
        if abs(feat_label_corr(indices_rows(i))) > abs(feat_label_corr(indices_cols(i)))
            features_to_remove{i}{5}=indices_cols(i);
            removal(i)=indices_cols(i);
        else
            features_to_remove{end+1}{5}=indices_rows(i);
            removal(end+1)=indices_rows(i);
        end
     else
        ;
     end
end

new_mat=feat_label_mat;
new_mat(:,removal)=[];


end
