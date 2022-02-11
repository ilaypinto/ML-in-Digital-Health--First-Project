function features = create_feat_set(data_set, mat_file_name, flag_feat, labels_tags)
% this function create a feature set for all the data in data set
%
% inputs:
%       - DATA_SET - a data set created by create_data_set function.
%       - MAT_FILE_NAME - string, the name of the mat file that FEATURES
%                         will be saved to 
%       - FLAG_FEAT - bool, decides if features will be computed or loaded
%                     from mat file.
%       - LABELS_TAGS - the labels corresponding to the indices of the
%                       dataset structure indices.
%
% outputs:
%       - FEATURES - a 2D matrix containing the feature set of each window
%                    as rows. the last column is the label of the window.

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