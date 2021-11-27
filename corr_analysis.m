function [feat_feat_corr, weights_all, best_feat_label, features_removed_names,...
    feature_removed_indices, new_feat_matrix, new_feat_names, highest_corr_under_thresh]...
    = corr_analysis(feat_label_mat, feat_names)
% this function computes correlations between features and relieff between fetures and labels.

k = 10;     % num of neighbors for relieff

% Slice the data to features and labels
label_vec = feat_label_mat(:, end);         % Separate the Labels from matrix
feat_mat = feat_label_mat(:, 1:end - 1);    % Separate Features from labels

% define empty cells arrays
best_feat_label = {};
nan_feat_idx  = sum(isnan(feat_mat),1);
nan_exmpl_idx = sum(isnan(feat_mat),2);


% Compute correlations
[idx_relieff_all, weights_all] = relieff(feat_mat(nan_exmpl_idx == 0,:), label_vec(nan_exmpl_idx == 0,:), k);   % Features-Labels correlation fo all feat
[idx_relieff_no_nan, weights_all_no_nan] = relieff(feat_mat(:,nan_feat_idx == 0), label_vec, k);                % Features-Labels correlation for feat without nans

feat_feat_corr_nan = corr(feat_mat, 'type', 'Spearman', 'rows', 'all');                 % Features-Features correlation
feat_feat_corr_all = corr(feat_mat, 'type', 'Spearman', 'rows', 'pairwise');            % Features-Features correlation
feat_feat_corr = feat_feat_corr_nan;
feat_feat_corr(isnan(feat_feat_corr)) = feat_feat_corr_all(isnan(feat_feat_corr));      % combine corr from feat with nan values

% extract the feature with highest feature label correlation
best_feat_label{1} = [weights_all(idx_relieff_all(1)), weights_all(idx_relieff_all(2))];    % value of relieff
best_feat_label{2} = [idx_relieff_all(1), idx_relieff_all(2)];                           % index of feature in matrix
best_feat_label{3} = feat_names([idx_relieff_all(1), idx_relieff_all(2)]);                  % feature name

% find and remove features with over 0.7 feature-feature correlation
indices = find(and(abs(feat_feat_corr) >= 0.7, abs(feat_feat_corr) ~= 1) );
indices_cols = ceil(indices./size(feat_feat_corr, 1));
indices_rows = mod(indices, size(feat_feat_corr, 1));
indices_rows(indices_rows == 0) = size(feat_feat_corr, 1);
feature_removed_indices = zeros(1,length(indices));

for i = 1:length(indices)
    feat_1 = indices_cols(i);
    feat_2 = indices_rows(i);
    if isnan(feat_feat_corr_nan(indices_rows(i),indices_cols(i)))
        if strcmp(feat_names{feat_1}(1:4), 'baro') && strcmp(feat_names{feat_2}(1:4), 'baro')
            if weights_all(feat_1) > weights_all(feat_2)
                worst_feat = feat_2;
            else
                worst_feat = feat_1;
            end
        elseif strcmp(feat_names{feat_1}(1:4), 'baro')
            worst_feat = feat_1;
        else
            worst_feat = feat_2;
        end
    elseif weights_all_no_nan(feat_1) > weights_all_no_nan(feat_2)
        worst_feat = feat_2;
    elseif weights_all_no_nan(feat_1) < weights_all_no_nan(feat_2)
        worst_feat = feat_1;
    end
    feature_removed_indices(i) = worst_feat;
end
feature_removed_indices = [feature_removed_indices find(isnan(weights_all))];
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
