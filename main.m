clc; clear all; close all;
% this is the main script to manage our workflow
%  ##### If its the first time you run this script make sure all flags are set to 1 ##### (except flag_use_good_folders)

% things to do to improve speed:
% - allocate a space in memory to prevent changing size every iteration
%   in: extract data, extract segments, create features.

% set some usefull flags
flag_folders  = 0;          % 1 - extract folders numbers,          0 - load folders numbers
flag_data_csv = 0;          % 1 - extract data from csv files,      0 - load data from saved mat file
flag_segm_MW  = 0;          % 1 - use the MW segmentation function, 0 - load saved segments
flag_segm_ET  = 0;          % 1 - use the ET segmentation function, 0 - load saved segments
flag_feat_MW  = 0;          % 1 - compute features for MW segments, 0 - load features
flag_feat_ET  = 0;          % 1 - compute features for ET segments, 0 - load features
flag_use_good_folders = 0;  % 1 - use good labeled folders,         0 - use all folders         

% define some variables for later use
label_time = 3;
overlap = 90;
segmentation = ['moving window'; 'event trigger'];
labels_tags = [12 22 3 4 5 6 11 21 0];
good_labels_folder = [];  % cherry pick folders with good labeled recordings

%% order data in folders and load data from csv files
% create a folder for each recording containing the sensors data and labels
% csv files - folders is a vector with the folders numbers
if flag_folders
    folders = create_data_folders('C:\Users\tomer\Desktop\חישה רציפה\matlab code\first project\project\data\meta-motion\Full recordings\הקלטות mmr');
    save('mat files/folders', 'folders');
else
    folders = load('mat files/folders.mat');
    folders = folders.folders;
end

if flag_use_good_folders
    folders = good_labels_folder;
end

%% read data from csv files into cell array
data = data_from_csv(folders, flag_data_csv, label_time);

%% create train and test set for MW and ET segmentation
folders_train = folders(1:round(0.75*length(folders)));         % try cherry pick with good labeled recordings
folders_test = folders(round(0.75*length(folders)) + 1: end);   % try cherry pick with good labeled recordings

MW_train_set = create_data_set(folders_train, data, segmentation(1,:), overlap, 'train', label_time, flag_segm_MW);
MW_test_set = create_data_set(folders_test, data, segmentation(1,:), overlap, 'test', label_time, flag_segm_MW);

ET_train_set = create_data_set(folders_train, data, segmentation(2,:), overlap, 'train', label_time, flag_segm_ET);
ET_test_set = create_data_set(folders_test, data, segmentation(2,:), overlap, 'test', label_time, flag_segm_ET);

%% extract features from segmentations - MW & ET 
% ############# need to add a random algo for reproducibility#############
MW_train_feat = create_feat_set(MW_train_set, 'MW_train_feat', flag_feat_MW, labels_tags);
MW_test_feat = create_feat_set(MW_test_set, 'MW_test_feat', flag_feat_MW , labels_tags);

ET_train_feat = create_feat_set(ET_train_set, 'ET_train_feat', flag_feat_ET, labels_tags);
ET_new_test_feat = create_feat_set(ET_test_set, 'ET_test_feat', flag_feat_ET, labels_tags);

%% feature selection process
% ###### need to verify results of names and indices removed ######
features_names = get_feat_names();          % create a cell array with the features names
[ET_ff_corr_low, ET_ff_corr, ET_fl_corr, ET_best_ff, ET_best_fl, ET_features_removed,...
    ET_feature_removed_indices, ET_new_train_feat, ET_new_features_names, ET_highest_corr_under_thresh] = corr_analysis(ET_train_feat, features_names);

[MW_ff_corr_low, MW_ff_corr, MW_fl_corr, MW_best_ff, MW_best_fl, MW_features_removed,...
    MW_feature_removed_indices, MW_new_train_feat, MW_new_features_names, MW_highest_corr_under_thresh] = corr_analysis(MW_train_feat, features_names);

ET_vec = ones(1,size(ET_train_feat, 2));
ET_vec(1,ET_feature_removed_indices) = 0;

MW_vec = ones(1,size(MW_train_feat, 2));
MW_vec(1,ET_feature_removed_indices) = 0;

ET_new_test_feat = ET_new_test_feat(:, ET_vec == 1);
MW_new_test_feat = MW_new_test_feat(:, MW_vec == 1);
% compute CFS on selected features
% event trigger
[~, I_1_ET] = maxk(ET_fl_corr,14);
[~, I_2_ET] = mink(ET_ff_corr(I_1_ET,:), 1, 2);
I_2_ET = reshape(I_2_ET,1,numel(I_2_ET));
I_ET = unique([I_1_ET' I_2_ET]);
cfs_ET = calculate_CFS(ET_fl_corr,ET_ff_corr,I_ET);
names_ET = features_names(I_ET);

% moving window
[~, I_1_MW] = maxk(MW_fl_corr,14);
[~, I_2_MW] = mink(MW_ff_corr(I_1_MW,:), 10, 2);
I_2_MW = reshape(I_2_MW,1,numel(I_2_MW));
I_MW = unique([I_1_MW' I_2_MW]);
cfs_MW = calculate_CFS(MW_fl_corr,MW_ff_corr,I_MW);
names_MW = features_names(I_MW);

disp('feat for MW')
for i = 1:length(names_MW)
    disp(names_MW{i})
end
disp([newline 'feat for ET'])
for i = 1:length(names_ET)
    disp(names_ET{i})
end

% compute relief - ###### need to find a solution for NaN #######
% k = 10;
% [relief_idx_MW, relief_weights_MW] = relieff(features_MW(:,1:end-1),features_MW(:,1:end-1),k);
% [relief_idx_ET, relief_weights_ET] = relieff(features_ET(:,1:end-1),features_ET(:,1:end-1),k);

%%
template = templateTree('MaxNumSplits', 20);
classificationEnsemble = fitcensemble(ET_train_feat(:, 1:end - 1), ET_train_feat(:, end), 'Method', 'AdaBoostM2', 'NumLearningCycles', 30, 'Learners', template, 'ClassNames', [0; 3; 4; 5; 6; 11; 12; 21; 22]);

%SFS- using loss function as criteria
fun = @(Xtrain,Ytrain,Xtest,Ytest)loss(fitcensemble(Xtrain, Ytrain, 'Method', 'AdaBoostM2', 'Learners', template), Xtest, Ytest);
[Indx_MW, history_MW] = sequentialfs(fun, MW_new_train_feat(:,1:5), MW_new_train_feat(:,end));
[Indx_ET, history_ET] = sequentialfs(fun, ET_new_train_feat(:,1:5), ET_new_train_feat(:,end));













%% this are some plots to check the segmentation and label process is done as we wish - surprise surprise its NOT... :( 
% the problem is not in our code (our files are being labeled and segmented very accurately) but in the label process 
% done by some other groups.

indx = 277;
data = extract_data(int2str(indx), label_time);
baro_1 = data.baro;
gyro_1 = data.gyro;
acc_1 = data.acc;
figure(1);
plot((1:length(baro_1(1,:))),baro_1(1,:)); hold on; plot(find(baro_1(2,:) ~= 0), baro_1(1, find(baro_1(2,:) ~= 0)) + 1.01*10^5,'b.' ); hold off;
figure(2);
plot((1:length(gyro_1(1,:))),gyro_1(1:3,:)); hold on; plot(find(gyro_1(4,:) ~= 0), gyro_1(1:3, find(gyro_1(4,:) ~= 0)),'b.' ); hold off;
figure(3);
plot((1:length(acc_1(1,:))),acc_1(1:3,:)); hold on; plot(find(acc_1(4,:) ~= 0), acc_1(1:3, find(acc_1(4,:) ~= 0)),'b.' ); hold off;

% %%
% for i = 1:9
%     for j = 1:size(segments_ET(i).gyro,3)
%         L = segments_ET(i);
%         figure(2);
%         plot((1:length(L.gyro(1,:,j))),L.gyro(:,:,j));
%         pause()
%     end
% end

