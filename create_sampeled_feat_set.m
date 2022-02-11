function features = create_sampeled_feat_set(data_set, mat_file_name, flag_feat, labels_tags)
% this function create a feature set for a data set, for label 0 windows it
% takes a small part of windows to compute features on since we got to
% much of them.
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
    for i = 1:8
        temp_features = create_features(data_set(i), labels_tags(i));
        features = cat(1, features, temp_features);
    end
    % there are too many windows with label 0 so we will only choose some of
    % them randomly to train our model with
    N = size(data_set(9).gyro, 3);                                      % num of label 0 windows
    if N > size(features, 1)
        idx = unique(randi([1 N], 1, size(features, 1)));        % random indices
        data_set(9).gyro = data_set(9).gyro(:,:,idx);
        data_set(9).acc = data_set(9).acc(:,:,idx);
        data_set(9).baro = data_set(9).baro(:,:,idx);
        temp_features = create_features(data_set(9), labels_tags(9));       % take only the windows in the random indices
        features = cat(1, features, temp_features);                         % extract features
    else
        temp_features = create_features(data_set(9), labels_tags(9));
        features = cat(1, features, temp_features);
    end
    save(strcat('mat files/', mat_file_name), 'features');
else
    features = load(strcat('mat files/',mat_file_name,'.mat'));
    features = features.features;
end
end