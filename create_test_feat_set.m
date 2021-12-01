function features = create_test_feat_set(data_set, mat_file_name, flag_feat, labels_tags)
% this function create a feature set for data set

% initialize an empty array
features = [];

% features for MW segments
if flag_feat
    for i = 1:9
        temp_features = create_features(data_set(i), labels_tags(i));
        features = cat(1, features, temp_features);
    end
    save(strcat('mat files/', mat_file_name), 'features');
else
    features = load(strcat('mat files/',mat_file_name,'.mat'));
    features = features.features;
end
end