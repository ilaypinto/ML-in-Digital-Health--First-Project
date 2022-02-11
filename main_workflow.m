clc; clear all; close all;
% this is the main script to manage our workflow
%  ##### If its the first time you run this script make sure all flags are set to 1 ##### 

% things to do to improve speed:
% - allocate a space in memory to prevent changing size every iteration
%   in: extract data, extract segments, create features. (dont have time
%   for that...)

% set some usefull flags
flag_folders  = 1;          % 1 - extract folders numbers,          0 - load folders numbers
flag_data_csv = 1;          % 1 - extract data from csv files,      0 - load data from saved mat file
flag_segm_MW  = 1;          % 1 - use the MW segmentation function, 0 - load saved segments
flag_segm_ET  = 1;          % 1 - use the ET segmentation function, 0 - load saved segments
flag_feat_MW  = 1;          % 1 - compute features for MW segments, 0 - load features
flag_feat_ET  = 1;          % 1 - compute features for ET segments, 0 - load features
flag_use_good_folders = 1;  % 1 - use good labeled folders,         0 - use all folders  
flag_SFS_MW = 1;            % 1 - compute the SFS for MW,           0 - load saved indices
flag_SFS_ET = 1;            % 1 - compute the SFS for ET,           0 - load saved indices
flag_segm_ET_All = 1;       % 1 - use the ET segmentation function, 0 - load saved segments
flag_segm_MW_All = 1;       % 1 - use the ET segmentation function, 0 - load saved segments
flag_save = 1;              % 1 - save the variables as mat files,  0 - dont save the variables

% define some variables for later use
label_time = 3;
overlap = 90;
segmentation = ['moving window'; 'event trigger'];
labels_tags = [12 22 3 4 5 6 11 21 0];
good_labels_folder = [16 20	23	24	31	36	37	38	39	41	42	44	45	46 47	49	50	51	52	53	54	55	57	58	59	60	73	74 ...
                 	 75	76	77	78	79	80	81	82	83	84	87	90	91	93 94	159	160	161	163	164	165	166	167	168	173	174	175	176 ...
                 	 178    182 183	184	185	186	187	188	189	190	191	192	205	 206	208	213	214	215	216	227	241	242	243	244	245	246	...
                     247	248	249	250	251	252	253	254	256	257	258	259	260	 262	265	266	267	269	270	271	272	273	274	276	277	279	...
                     280	281	282	283	284	289	293	294	295	296	297	298	299	300];  % cherry pick folders with good labeled recordings

%% order data in folders and load data from csv files
% create a folder for each recording containing the sensors data and labels
% csv files - folders is a vector with the folders numbers
if flag_folders
    folders = create_data_folders('data\meta-motion\Full recordings\mmr');
    save('mat files/folders', 'folders');
else
    folders = load('mat files/folders.mat');
    folders = folders.folders;
end

if flag_use_good_folders
    folders = good_labels_folder;
end

%% read data from csv files into cell array
data = data_from_csv(folders, flag_data_csv, label_time, flag_save);

%% create train and test set for MW and ET segmentation
folders_train = [49 50 178];         
folders_test = [182 183];   % recordings from groups not included in the train set

MW_train_set = create_data_set(folders_train, data, segmentation(1,:), overlap, 'train', label_time, flag_segm_MW, flag_save);
MW_test_set = create_data_set(folders_test, data, segmentation(1,:), overlap, 'test', label_time, flag_segm_MW, flag_save);

ET_train_set = create_data_set(folders_train, data, segmentation(2,:), overlap, 'train', label_time, flag_segm_ET, flag_save);
ET_test_set = create_data_set(folders_test, data, segmentation(2,:), overlap, 'test', label_time, flag_segm_ET, flag_save);

%% extract features from segmentations - MW & ET 
MW_train_feat = create_feat_set(MW_train_set, 'MW_train_feat', flag_feat_MW, labels_tags);
MW_test_feat = create_feat_set(MW_test_set, 'MW_test_feat', flag_feat_MW , labels_tags);

ET_train_feat = create_feat_set(ET_train_set, 'ET_train_feat', flag_feat_ET, labels_tags);
ET_test_feat = create_feat_set(ET_test_set, 'ET_test_feat', flag_feat_ET, labels_tags);
    

%% feature selection process
features_names = get_feat_names();          % create a cell array with the features names
[ET_ff_corr, ET_fl_corr, ET_best_fl, ET_features_removed, ET_feature_removed_indices,...
    ET_new_train_feat, ET_new_features_names, ET_highest_corr_under_thresh] = corr_analysis(ET_train_feat, features_names);

[MW_ff_corr, MW_fl_corr, MW_best_fl, MW_features_removed, MW_feature_removed_indices,...
    MW_new_train_feat, MW_new_features_names, MW_highest_corr_under_thresh] = corr_analysis(MW_train_feat, features_names);

figure(2); heatmap(abs(corr(ET_new_train_feat(:,1:end-1), 'type', 'Spearman', 'rows', 'pairwise')));title('Spearman correlation - Heatmap (event trigger)') % correlation heatmap
%% create new test features
ET_vec = ones(1, size(ET_train_feat, 2));
ET_vec(1, ET_feature_removed_indices) = 0;

MW_vec = ones(1, size(MW_train_feat, 2));
MW_vec(1, MW_feature_removed_indices) = 0;

ET_new_test_feat = ET_test_feat(:, ET_vec == 1);
MW_new_test_feat = MW_test_feat(:, MW_vec == 1);

%% final feature selection - define the SFS parameters
options = statset('Display', 'iter', 'UseParallel', true);  % UseParallel to speed up the computations and Display so we can see the progress
template = templateTree('MaxNumSplits', 30, 'MinLeafSize', 10);                % define the trees to use in the ensemble model

%SFS- using loss function as criteria
fun = @(Xtrain,Ytrain,Xtest,Ytest)loss(fitcensemble(Xtrain, Ytrain, 'Method', 'RUSBoost', 'Learners', template), Xtest, Ytest);

%% compute MW SFS 
if flag_SFS_MW
    [Indx_MW, history_MW] = sequentialfs(fun, MW_new_train_feat(:,1:end-1), MW_new_train_feat(:,end), 'options', options);
    save('mat files/sfs_MW','Indx_MW', 'history_MW')
else
    Indx_MW = load('mat files/sfs_MW.mat');
    Indx_MW = Indx_MW.Indx_MW;
end

MW_final_feat_names = MW_new_features_names(Indx_MW);   % get the names of the final features
Indx_MW(end + 1) = 1;                                   % set label indices as 1

% plot the best features corr and gplot
corr_1 = corr(MW_new_train_feat(:,Indx_MW), 'type', 'Spearman', 'rows', 'all');
corr_2 = corr(MW_new_train_feat(:,Indx_MW), 'type', 'Spearman', 'rows', 'pairwise');
corr_1(isnan(corr_1)) = corr_2(isnan(corr_1));
figure(1); heatmap(abs(corr_1));                                                             % correlation heatmap
title('Spearman correlation - Heatmap (moving window)');
figure(2); gplotmatrix(MW_new_train_feat(:,[12,32,42,43,56]), [], MW_new_train_feat(:,end));     % gplot

%% compute ET SFS
if flag_SFS_ET
    [Indx_ET, history_ET] = sequentialfs(fun, ET_new_train_feat(:,1:end-1), ET_new_train_feat(:,end), 'options', options);
    save('mat files/sfs_ET','Indx_ET', 'history_ET')
else
    Indx_ET = load('mat files/sfs_ET.mat');
    Indx_ET = Indx_ET.Indx_ET;
end

ET_final_feat_names = ET_new_features_names(Indx_ET);   % get the names of the final features
Indx_ET(end + 1) = 1;                                   % set label indices as 1

% plot the best features corr and gplot
corr_3 = corr(ET_new_train_feat(:, Indx_ET), 'type', 'Spearman', 'rows', 'all');
corr_4 = corr(ET_new_train_feat(:, Indx_ET), 'type', 'Spearman', 'rows', 'pairwise');
corr_3(isnan(corr_3)) = corr_4(isnan(corr_3));
figure(3); heatmap(corr_3);                                                             % correlation heatmap
title('Spearman correlation - Heatmap (event trigger)');
figure(4); gplotmatrix(ET_new_train_feat(:,[1,12,39,41,53]), [], ET_new_train_feat(:,end));     % gplot

%% get the final feature matrices to try models on with classification learner app (matlab app)
final_ET_feat_train = ET_new_train_feat(:, Indx_ET);
final_ET_feat_test = ET_new_test_feat(:, Indx_ET);

final_MW_feat_train = MW_new_train_feat(:, Indx_MW);
final_MW_feat_test = MW_new_test_feat(:, Indx_MW);

%% models to release to the world - hyperparameters chosen with the help of classification learner app.
% the model we saved was made by the classification learner app, this code
% is just to illustrate what we did there.

% ET model
ET_data_set_All = create_data_set(folders, data, segmentation(2,:), overlap, 'train_all', label_time, flag_segm_ET_All,1);
final_ET_feat_All = create_ET_best_feat_set(ET_data_set_All, 'ET_All_feat', flag_feat_ET, labels_tags);

trees_ET = templateTree('MaxNumSplits', 40);
num_trees_ET = 40;
Boosted_Tree_ET = fitcensemble(final_ET_feat_All(:,end - 1), final_ET_feat_All(:,end), 'Method', 'RUSBoost', ...
'NumLearningCycles', num_trees_ET,'Learners', trees_ET);


% MW model
final_MW_feat_All = cat(1, final_MW_feat_train, final_MW_feat_test);

trees_MW = templateTree('MaxNumSplits',40);
num_trees_MW = 60;
Boosted_Tree_MW = fitcensemble(final_MW_feat_All(:,end - 1), final_MW_feat_All(:,end), 'Method', 'RUSBoost', ...
'NumLearningCycles', num_trees_MW, 'Learners', trees_MW);
    