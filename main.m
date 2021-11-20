clc; clear all; close all;
% this is the main script to manage the workflow
% If its the first time you run this script make sure flag_store is set to 1!

% define some usefull flags
flag_store = 0;         % decide if u want to pull data from csv files or load the saved data

% define some variables
label_time = 3;
overlap = 90;
segmentation = ['moving window'; 'event trigger'];

%% preproccessing the data
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

%% sort the recording by movement labels
struc.gyro = [];
struc.acc  = [];
struc.baro = [];
data_sampels = repmat(struc,1,9);

for i = 181:193
    [sampels, labels_tags] = extract_sampels(data{1,i}, label_time, overlap, segmentation(1,:));
    for j = 1:9
        if isempty(sampels(j).gyro)
            continue
        end
        my_struc = data_sampels(j);
        my_struc.gyro = cat(3, my_struc.gyro, sampels(j).gyro);
        my_struc.acc = cat(3, my_struc.acc, sampels(j).acc);
        my_struc.baro = cat(3, my_struc.baro, sampels(j).baro);
        data_sampels(j) = my_struc;
    end
end
save('windows_for_feat.mat', 'data_sampels')
%%
% indx = 181;
% gyro_1 = data{1,indx}.gyro;
% figure(1);
% plot((1:length(gyro_1(1,:))),gyro_1(1:3,:)); hold on; plot(find(gyro_1(4,:) ~= 0), gyro_1(4,gyro_1(4,:) ~= 0),'b*' ); hold off;
% 
% 
% 
% 
% %%
% for i = 1:9
%     for j = 1:size(data_sampels(i).gyro,3)
%         L = data_sampels(i);
%         figure(2);
%         plot((1:length(L.gyro(1,:,j))),L.gyro(:,:,j));
%         pause()
%     end
% end
%%
% data_sampels = load('windows_for_feat');
% data_sampels = data_sampels.data_sampels;
features = [];
for i = 1:8
    [temp_features,features_names] = create_features(data_sampels(i), labels_tags(i));
    features = cat(1, features, temp_features);
end
N = size(data_sampels(9).gyro, 3);
idx = unique(randi([0 N], 1, size(features, 1)*(2/8)));
data_sampels(9).gyro = data_sampels(9).gyro(:,:,idx);
data_sampels(9).acc = data_sampels(9).acc(:,:,idx);
data_sampels(9).baro = data_sampels(9).baro(:,:,idx);
temp_features = create_features(data_sampels(9), labels_tags(9));
features = cat(1, features, temp_features);
save('features_MW', 'features')
%%
[feat_feat_corr_under_0_7, feat_feat_corr, feat_label_corr, best_feat_feat, best_feat_label] = corr_analysis(features, features_names);
