clc; clear all; close all;
% this is the main script to manage our workflow
%  ##### If its the first time you run this script make sure all flags are set to 1 #####

% set some usefull flags
flag_store   = 0;       % decide if u want to pull data from csv files or load the saved data
flag_segm_MW = 1;       % 1 - use the MW segmentation function, 0 - load saved segments
flag_segm_ET = 1;       % 1 - use the ET segmentation function, 0 - load saved segments
flag_feat_MW = 1;       % 1 - compute features for MW segments, 0 - load features
flag_feat_ET = 1;       % 1 - compute features for ET segments, 0 - load features

% define some variables used in multiple functions
label_time = 3;
overlap = 90;
segmentation = ['moving window'; 'event trigger'];

%% order data in folders and load data from csv files
% create a folder for each recording containing the sensors data and labels
% csv files - folders is a vector with the folders names
folders = create_data_folders('C:\Users\tomer\Desktop\חישה רציפה\matlab code\first project\project\data\meta-motion\Full recordings\הקלטות mmr');

% read all the csv files and store the data in a cell array - long run time
if flag_store
    data = cell(1,folders(end));  % we will store the data in a cell array, each object in it is a structure. 
    warning('off','all');
    for i = folders
        char = int2str(i);
        data{1,i} = store_data(char, label_time);
    end
    save('data','data')
    warning('on','all')
else
    data = load('data.mat');
    data = data.data;
end

%% segmentation and sorting the recording by movement labels - Moving Window & Event Trigger
struc.gyro = [];
struc.acc  = [];
struc.baro = [];
segments_MW = repmat(struc,1,9);
segments_ET = repmat(struc,1,9);

% Moving Window segmentation
if flag_segm_MW
    for i = 181:193
        [temp_segments_MW, labels_tags] = extract_segments(data{1,i}, label_time, overlap, segmentation(1,:));
        for j = 1:9
            if isempty(temp_segments_MW(j).gyro)
                continue
            end
            my_struc = segments_MW(j);
            my_struc.gyro = cat(3, my_struc.gyro, temp_segments_MW(j).gyro);
            my_struc.acc = cat(3, my_struc.acc, temp_segments_MW(j).acc);
            my_struc.baro = cat(3, my_struc.baro, temp_segments_MW(j).baro);
            segments_MW(j) = my_struc;
        end
    end
    save('MV_segmentation', 'segments_MW')
else
    segments_MW = load('MV_segmentation.mat');
    segments_MW = segments_MW.data_sampels;
end

% Event Trigger segmentation - ###### need to add it in extract_segments ######
if flag_segm_ET
    for i = 181:193
        [temp_segments_ET, labels_tags] = extract_segments(data{1,i}, label_time, overlap, segmentation(2,:));
        for j = 1:9
            if isempty(temp_segments_ET(j).gyro)
                continue
            end
            my_struc = segments_ET(j);
            my_struc.gyro = cat(3, my_struc.gyro, temp_segments_ET(j).gyro);
            my_struc.acc = cat(3, my_struc.acc, temp_segments_ET(j).acc);
            my_struc.baro = cat(3, my_struc.baro, temp_segments_ET(j).baro);
            segments_ET(j) = my_struc;
        end
    end
    save('ET_segmentation', 'segments_ET');
else
    segments_ET = load('ET_segmentation.mat');
    segments_ET = segments_ET.data_sampels;
end

% %%this are some plots to check the segmentation and label process is done as we wish - 
% % need to change some variables names (haven't changed it since it was
% under % mark)
% indx = 181;
% gyro_1 = data{1,indx}.gyro;
% figure(1);
% plot((1:length(gyro_1(1,:))),gyro_1(1:3,:)); hold on; plot(find(gyro_1(4,:) ~= 0), gyro_1(4,gyro_1(4,:) ~= 0),'b*' ); hold off;
% 

% for i = 1:9
%     for j = 1:size(data_sampels(i).gyro,3)
%         L = data_sampels(i);
%         figure(2);
%         plot((1:length(L.gyro(1,:,j))),L.gyro(:,:,j));
%         pause()
%     end
% end
%% extract features from segmentations - MW & ET
features_MW = [];
features_ET = [];

% features for MW segments
if flag_feat_MW
    for i = 1:8
        [temp_features,features_names] = create_features(segments_MW(i), labels_tags(i));
        features_MW = cat(1, features_MW, temp_features);
    end
    % there are too many windows with label 0 so we will only choose some of
    % them randomly to train our model with
    N = size(segments_MW(9).gyro, 3);                          % num of label 0 windows
    idx = unique(randi([0 N], 1, size(features_MW, 1)*(2/8)));     % random indices
    segments_MW(9).gyro = segments_MW(9).gyro(:,:,idx);
    segments_MW(9).acc = segments_MW(9).acc(:,:,idx);
    segments_MW(9).baro = segments_MW(9).baro(:,:,idx);
    temp_features = create_features(segments_MW(9), labels_tags(9));   % take only the windows in the random indices
    features_MW = cat(1, features_MW, temp_features);                         % extract features
    save('features_MW', 'features_MW');
else
    features_MW = load('features_MW.mat');
    features_MW = features_MW.features_MW;
end

% features for ET segments
if flag_feat_ET
    for i = 1:9
        [temp_features,features_names] = create_features(segments_ET(i), labels_tags(i));
        features_ET = cat(1, features_ET, temp_features);
    end
    save('features_ET', 'features_ET');
else
    features_ET = load('features_ET.mat');
    features_ET = features_ET.features_ET;
end

%%
[feat_feat_corr_under_0_7, feat_feat_corr, feat_label_corr, best_feat_feat, best_feat_label] = corr_analysis(features_MW, features_names);
