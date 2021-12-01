function features = create_best_feat_set(varargin)
% this function create a feature set (only the best selected features) for
% a data set - only for ET segmentation!!

% initialize an empty array
features = [];

data_set = varargin{1};
if nargin > 1
    labels_tags = varargin{2};
    % features & labels for ET segments
    for i = 1:9
        temp_features = create_best_features(data_set(i), labels_tags(i));
        features = cat(1, features, temp_features);
    end
else
    % only features for ET segments
    for i = 1:9
        temp_features = create_best_features(data_set(i));
        features = cat(1, features, temp_features);
    end
end
end