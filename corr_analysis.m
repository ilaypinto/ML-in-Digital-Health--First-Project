function [feat_feat_corr_num_under_0_7, feat_feat_corr, feat_label_corr, best_feat_feat,...
    best_feat_label, features_removed_names, feature_removed_indices, new_feat_matrix, new_feat_names, highest_corr_under_thresh]...
    = corr_analysis(feat_label_mat, feat_names)
% need to add description

% define empty cells arrays
best_feat_label = {};
best_feat_feat = {};

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

% find and remove features with over 0.7 feature-feature correlation
indices = find(and(abs(feat_feat_corr) >= 0.7, abs(feat_feat_corr) ~= 1) );
indices_cols = ceil(indices./size(feat_feat_corr, 1));
indices_rows = mod(indices, size(feat_feat_corr, 1));
indices_rows(indices_rows == 0) = size(feat_feat_corr, 1);
features_removed_names = cell(1, length(indices));
feature_removed_indices = zeros(1,length(indices));

for i = 1:length(indices)
    feat_1 = indices_cols(i);
    feat_2 = indices_rows(i);
    if feat_label_corr(feat_1) > feat_label_corr(feat_2)
        worst_feat = feat_2;
    else
        worst_feat = feat_1;
    end
    feature_removed_indices(i) = worst_feat;
end
feature_removed_indices = unique(feature_removed_indices);
features_removed_names = feat_names(feature_removed_indices);

vec = ones(1,size(feat_label_mat, 2));
vec(1,feature_removed_indices) = 0;
new_feat_matrix = feat_label_mat(:, vec == 1);
new_feat_names = feat_names(vec(1:end - 1) == 1);

% find max feature-feature correlation under 0.7 and their names
M = max(feat_feat_corr(abs(feat_feat_corr) < 0.7));
I = find(abs(feat_feat_corr) == M, 1);
I_cols = ceil(I/size(feat_feat_corr, 1));
I_rows = mod(I, size(feat_feat_corr, 1));
highest_corr_under_thresh = cell(1,4);
highest_corr_under_thresh{1} = M;
highest_corr_under_thresh{2} = I;            % use this value to check for correct names afterwards
highest_corr_under_thresh{3} = feat_names{I_cols};
highest_corr_under_thresh{4} = feat_names{I_rows};
                                
end
