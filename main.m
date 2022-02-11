function main(filepath)
% this function recieves a path pointing to where the data CSV files are
% stored, preprocess the data and predict using our selected model.
% the model selected uses Event Trigger segmentation!

% set some usefull flags - this was helpfull when we built our workflow,
% now its not necessary but our functions demands these variables as inputs
flag_data_csv = 1;          % 1 - extract data from csv files,      0 - load data from saved mat file
flag_segm_ET  = 1;          % 1 - use the ET segmentation function, 0 - load saved segments

% define some variables
label_time = 3;
segmentation = 'event trigger';
labels_tags = [12 22 3 4 5 6 11 21 0];
overlap = 90;               % doesnt realy being used here but some functions requires it as an input


folders = create_data_folders(filepath);
data = data_from_csv(folders, flag_data_csv, label_time, 0);
ET_train_set = create_data_set(folders, data, segmentation, overlap, 'test', label_time, flag_segm_ET, 0);
ET_train_feat = create_ET_best_feat_set(ET_train_set, labels_tags);

model = load('trained model');
model = model.trainedModel;

predictions = model.predictFcn(ET_train_feat(:,1:end - 1));
table = confusionmat(ET_train_feat(:,end), predictions, 'order', labels_tags);
figure(1);
confusionchart(table, labels_tags);
end




