function features = create_ET_best_feat_set(data_set, labels_tags)
% this function create a feature set for a data set.
%
% inputs:
%       - DATA_SET - a data set created by create_data_set function.
%       - LABELS_TAGS - the labels corresponding to the indices of the
%                       dataset structure indices.
%
% outputs:
%       - FEATURES - a 2D matrix containing the feature set of each window
%                    as rows. the last column is the label of the window.

% initialize an empty array
features = [];


for i = 1:9
    temp_features = create_ET_best_features(data_set(i), labels_tags(i));
    features = cat(1, features, temp_features);
end                     
end