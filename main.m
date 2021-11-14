clc; clear all; close all;
% this is the main script to manage the workflow

%% this function is needed only once to organize all the files in folders.
folders = create_data_folders('C:\Users\tomer\Desktop\חישה רציפה\matlab code\first project\project\data\meta-motion\Full recordings\הקלטות mmr');
%%
% preprocess all relevant data      

data = cell(1,folders(end));  % we will store the data in a cell array, each object in it is a structure.    
for i = folders
    char = int2str(i);
    data{1,i} = preproccess_data(char);
end
%%
struc.gyro = [];
struc.acc = [];
struc.baro = [];
data_sampels = cell(1,9);
for i = 1:9
    data_sampels{i} = struc;
end

for i = 1:num_recordings
    sampels = extract_sampels(data{1,i});
    for j = 1:length(data_sampels)
        if isempty(sampels{j})
            continue
        end
        my_struc = data_sampels{j};
        my_struc.gyro = cat(3, my_struc.gyro, sampels{j}.gyro);
        my_struc.acc = cat(3, my_struc.acc, sampels{j}.acc);
        my_struc.baro = cat(3, my_struc.baro, sampels{j}.baro);
        data_sampels{j} = my_struc;
    end
end

%%
% plot some random signals in our interest time
indx = randi(num_recordings,1,3);
plot_data_time(data,indx);

