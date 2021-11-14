function proccessed_data = preproccess_data(foldername)
% this fnuction creates a structure containing the recording from all the
% available sensors. the structure contains 3 fields - gyro, acc and baro.
% each field is a matrix in which each row is data from different axis in
% the following order - x,y,z,labels.
% baro field will be zeros if no record is available. 

warning('off','all');
path = strcat('data/meta-motion/Full recordings/' ,foldername);
list = dir(path);

% extract the group number
group_num = split(list(4).name,'.');
group_num = char(group_num(1));

% create the labels vector
for i = 3:length(list)                                          % search for the right file
    if list(i).name(end-8:end-4) == 'Label'
        data = readtable(strcat(path,'/',list(i).name));        % create a table from the csv file 
        break
    end
end
sample_freq = [25, 3.82];                           % define the sample frequency
time = 30*60;                               % define the time of the signal in sec
labels_time = [0,0,2,2,2,2,2,2,2,0,2,2,0,0,0,0,0,0,0,0,2,2];                % define the time that each action takes in seconds

labels_gyro_acc = zeros(1,time*sample_freq(1));                    % start with unlabeled vector
labels_baro = zeros(1, time*sample_freq(2));

for i = 1:length(data.SecondsFromRecordingStart)
    label = data.Label(i);                              % get the label number
    start_time = data.SecondsFromRecordingStart(i);     % get the start time of the movment
    % label the movment relativly to the time and duration it's been taken and take 10 samples bacwards as a saftey factor
    labels_gyro_acc(1,start_time*sample_freq(1) - 10:start_time*sample_freq(1) + labels_time(label)*sample_freq(1)) = label;   
    labels_baro(1,round(start_time*sample_freq(2)) - 1: round(start_time*sample_freq(2)) + round(labels_time(label)*sample_freq(2))) = label;
end

% create the data vectors from Gyro Acc & baro
baro = zeros(1,time*sample_freq(2));       % baro will be zero vector if no measurments are available
for i = 3:length(list)                                          
    if list(i).name(end-7:end-4) == 'Gyro'
        gyro_data = readtable(strcat(path,'/',list(i).name));         
        gyro_x = gyro_data.x_axis_deg_s_(1:time*sample_freq(1))';
        gyro_y = gyro_data.y_axis_deg_s_(1:time*sample_freq(1))';
        gyro_z = gyro_data.z_axis_deg_s_(1:time*sample_freq(1))';
        
    elseif list(i).name(end-6:end-4) == 'Acc'
        Acc_data = readtable(strcat(path,'/',list(i).name));        
        acc_x = Acc_data.x_axis_g_(1:time*sample_freq(1))';
        acc_y = Acc_data.y_axis_g_(1:time*sample_freq(1))';
        acc_z = Acc_data.z_axis_g_(1:time*sample_freq(1))';

    elseif list(i).name(end-7:end-4) == 'Baro'
        Baro_data = readtable(strcat(path,'/',list(i).name));     
        baro = Baro_data.x_axis_g_(1:time*sample_freq(2))';   % need to change table header      
    end
end

proccessed_data.gyro = [gyro_x; gyro_y; gyro_z; labels_gyro_acc];
proccessed_data.acc = [acc_x; acc_y; acc_z; labels_gyro_acc];
proccessed_data.baro = [baro; labels_baro];

save(strcat(path,'/',group_num,'.',foldername,'.proccessed_data.mat'), 'proccessed_data');
warning('on','all')
end