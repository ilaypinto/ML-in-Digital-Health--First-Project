clc; clear all; close all;
% this is the main script to manage our workflow
%  ##### If its the first time you run this script make sure all flags are set to 1 #####

% set some usefull flags
flag_folders  = 0;          % 1 - extract folders numbers,          0 - load folders numbers
flag_data_csv = 0;          % 1 - extract data from csv files,      0 - load data from saved mat file
flag_segm_MW  = 1;          % 1 - use the MW segmentation function, 0 - load saved segments
flag_segm_ET  = 0;          % 1 - use the ET segmentation function, 0 - load saved segments
flag_feat_MW  = 1;          % 1 - compute features for MW segments, 0 - load features
flag_feat_ET  = 1;          % 1 - compute features for ET segments, 0 - load features

% define some variables for later use
label_time = 3;
overlap = 90;
segmentation = ['moving window'; 'event trigger'];

%% order data in folders and load data from csv files
% create a folder for each recording containing the sensors data and labels
% csv files - folders is a vector with the folders numbers
if flag_folders
    folders = create_data_folders('C:\Users\tomer\Desktop\חישה רציפה\matlab code\first project\project\data\meta-motion\Full recordings\הקלטות mmr');
    save('folders', 'folders');
else
    folders = load('folders.mat');
    folders = folders.folders;
end

% read all the csv files and store the data in a cell array - long run time
if flag_data_csv
    data = cell(1,folders(end));  % we will store the data in a cell array, each object in it is a structure. 
    warning('off','all');
    for i = folders
        char = int2str(i);
        data{1,i} = extract_data(char, label_time);
    end
    save('data','data')
    warning('on','all')
else
    data = load('data.mat');
    data = data.data;
end

%% segmentation and sorting the recording by movement labels - Moving Window & Event Trigger
% initialize matrixes with empty structures
struc.gyro = [];
struc.acc  = [];
struc.baro = [];
segments_MW = repmat(struc,1,9);
segments_ET = repmat(struc,1,9);

% Moving Window segmentation - very long run time
if flag_segm_MW
    for i = folders
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
    % ##### need to check for bugs ######
    extra_MW_segmentation_1.gyro = segments_MW(9).gyro(:,:,1:300000);
    extra_MW_segmentation_1.acc = segments_MW(9).acc(:,:,1:300000);
    extra_MW_segmentation_1.baro = segments_MW(9).baro(:,:,1:300000);
    save('extra_MV_segmentation_1', 'extra_MW_segmentation_1');
    extra_MW_segmentation_2.gyro = segments_MW(9).gyro(:,:,300001:600000);
    extra_MW_segmentation_2.acc = segments_MW(9).acc(:,:,300001:600000);
    extra_MW_segmentation_2.baro = segments_MW(9).baro(:,:,300001:600000);
    save('extra_MV_segmentation_2', 'extra_MW_segmentation_2');
    extra_MW_segmentation_3.gyro = segments_MW(9).gyro(:,:,600001:end);
    extra_MW_segmentation_3.acc = segments_MW(9).acc(:,:,600001:end);
    extra_MW_segmentation_3.baro = segments_MW(9).baro(:,:,600001:end);
    save('extra_MV_segmentation_3', 'extra_MW_segmentation_3');
    segments_MW_to_save = segments_MW(1:8);
    save('MV_segmentation', 'segments_MW_to_save');
else
    % ##### need to change loading method for all the extra files ######
    segments_MW = load('MV_segmentation.mat');
    segments_MW = segments_MW.segments_MW;
    labels_tags = [12 22 3 4 5 6 11 21 0];
end

% Event Trigger segmentation - long run time
if flag_segm_ET
    for i = folders
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
    segments_ET = segments_ET.segments_ET;
    labels_tags = [12 22 3 4 5 6 11 21 0];
end

%% this are some plots to check the segmentation and label process is done as we wish - surprise surprise its NOT... :( 
% the problem is not in our code (our files are being labeled and segmented very accurately) but in the label process 
% done by some other groups.

% indx = 270;
% baro_1 = data{1,indx}.baro;
% gyro_1 = data{1,indx}.gyro;
% acc_1 = data{1,indx}.acc;
% figure(1);
% plot((1:length(baro_1(1,:))),baro_1(1,:)); hold on; plot(find(baro_1(2,:) ~= 0), baro_1(1, find(baro_1(2,:) ~= 0)) + 1.01*10^5,'b.' ); hold off;
% figure(2);
% plot((1:length(gyro_1(1,:))),gyro_1(1:3,:)); hold on; plot(find(gyro_1(4,:) ~= 0), gyro_1(1:3, find(gyro_1(4,:) ~= 0)),'b.' ); hold off;
% figure(3);
% plot((1:length(acc_1(1,:))),acc_1(1:3,:)); hold on; plot(find(acc_1(4,:) ~= 0), acc_1(1:3, find(acc_1(4,:) ~= 0)),'b.' ); hold off;

% %%
% for i = 1:9
%     for j = 1:size(segments_ET(i).gyro,3)
%         L = segments_ET(i);
%         figure(2);
%         plot((1:length(L.gyro(1,:,j))),L.gyro(:,:,j));
%         pause()
%     end
% end

%% extract features from segmentations - MW & ET
% initialize an empty array
features_MW = [];
features_ET = [];

% features for MW segments
if flag_feat_MW
    for i = 1:8
        temp_features = create_features(segments_MW(i), labels_tags(i), i);
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
        temp_features = create_features(segments_ET(i), labels_tags(i));
        features_ET = cat(1, features_ET, temp_features);
    end
    save('features_ET', 'features_ET');
else
    features_ET = load('features_ET.mat');
    features_ET = features_ET.features_ET;
end

%%
features_names = get_feat_names();          % create a cell array with th features names
[ff_corr_low_ET, ff_corr_ET, fl_corr_ET, best_ff_ET, best_fl_ET] = corr_analysis(features_ET, features_names);
[ff_corr_low_MW, ff_corr_MW, fl_corr_MW, best_ff_MW, best_fl_MW] = corr_analysis(features_MW, features_names);

% compute CSF on selected features
% event trigger
[~, I_1_ET] = maxk(fl_corr_ET,14);
[~, I_2_ET] = mink(ff_corr_ET(I_1_ET,:), 1, 2);
I_2_ET = reshape(I_2_ET,1,numel(I_2_ET));
I_ET = unique([I_1_ET' I_2_ET]);
cfs_ET = calculate_CFS(fl_corr_ET,ff_corr_ET,I_ET);
names_ET = features_names(I_ET);

% moving window
[~, I_1_MW] = maxk(fl_corr_MW,14);
[~, I_2_MW] = mink(ff_corr_MW(I_1_MW,:), 10, 2);
I_2_MW = reshape(I_2_MW,1,numel(I_2_MW));
I_MW = unique([I_1_MW' I_2_MW]);
cfs_MW = calculate_CFS(fl_corr_MW,ff_corr_MW,I_MW);
names_MW = features_names(I_MW);

disp('feat for MW')
for i = 1:length(names_MW)
    disp(names_MW{i})
end
disp([newline 'feat for ET'])
for i = 1:length(names_ET)
    disp(names_ET{i})
end

