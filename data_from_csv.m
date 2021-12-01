function data = data_from_csv(folders, flag_data_csv, label_time, save_bool)
% read all the csv files and store the data in a cell array - long run time
if flag_data_csv
    data = cell(1,folders(end));  % we will store the data in a cell array, each object in it is a structure. 
    warning('off','all');
    for i = folders
        char = int2str(i);
        data{1,i} = extract_data(char, label_time);
    end
    if save_bool
    save('mat files/all_data','data')
    warning('on','all')
    end
else
    data = load('mat files/all_data.mat');
    data = data.data;
end