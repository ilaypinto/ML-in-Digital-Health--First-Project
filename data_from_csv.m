function data = data_from_csv(folders, flag_data_csv, label_time, save_bool)
% this function creates a cell with all the data from the csv files in
% FOLDERS.
%
% inputs:
%        - FOLDERS - vector of integers to extract data from folders with
%                    that number.
%        - FLAG_DATA_CSV - bool variable to determine if data needs to be
%                          loaded from saved mat file or it should be 
%                          extracted from the csv files.
%        - LABEL_TIME - specify the length of movements
%        - SAVE_BOOL - bool variable, specifies if DATA should be saved
%
% outputs:
%         - DATA - a cel array, each object in the cell is a structure
%                  containing the data from the csv files in the folder
%                  corresponding to the object index. the structures has 3
%                  fields: 'gyro', 'acc', 'baro'.
%                  each field is a 2D mat containing the data from the
%                  sensor from every axis, data is in the first dimention
%                  and axis are in the second (first row is X axis then Y,Z).
%                  the last row is a label vector built according to the
%                  'Label' csv file.


                
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