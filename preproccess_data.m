function proccessed_data = preproccess_data(foldername)
% this fnuction creates a structure containing the recording from all the
% available sensors. the structure contains 3 fields - gyro, acc and baro.
% each field is a matrix in which each row is data from different axis in
% the following order - x,y,z,labels.
% baro field will be zeros if no record is available. 

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
sample_freq = [25, 3.82];                   % define the sample frequency
time = 30*60;                               % define the time of the signal in sec
labels_time = 7;                            % define the time that each action takes in seconds
headers = data.Properties.VariableNames;    % get table headers

labels_gyro_acc = zeros(1,time*sample_freq(1));                    % start with unlabeled vector
labels_baro = zeros(1, time*sample_freq(2));

for i = 1:height(data(:,headers(1)))
    times = table2array(data(:, headers(1)));
    labels = table2array(data(:,headers(2)));
    label = labels(i);                              % get the label number
    start_time = times(i);                          % get the start time of the movment
    if start_time*sample_freq(1) + labels_time*sample_freq(1) >= length(labels_gyro_acc) || ...
            round(start_time*sample_freq(2)) + round(labels_time*sample_freq(2)) >= length(labels_baro)||...
            start_time*sample_freq(1) - 25 < 0 || start_time*sample_freq(2) - 4 < 0
        continue
    else
    % label the movment relativly to the time and duration it's been taken and take 10 samples bacwards as a saftey factor
    labels_gyro_acc(1,start_time*sample_freq(1) - 25:start_time*sample_freq(1) + labels_time*sample_freq(1)) = label;   
    labels_baro(1,round(start_time*sample_freq(2)) - 4: round(start_time*sample_freq(2)) + round(labels_time*sample_freq(2))) = label;
    end
end

% create the data vectors from Gyro Acc & baro
baro = zeros(1,time*sample_freq(2));       % baro will be zero vector if no measurments are available
for i = 3:length(list)                                          
    if list(i).name(end-7:end-4) == 'Gyro'
        gyro_data = readtable(strcat(path,'/',list(i).name)); 
        len = time*sample_freq(1) - length(gyro_data.x_axis_deg_s_);
        if len > 0 
            gyro_x = [gyro_data.x_axis_deg_s_(:)' zeros(1,len)];
            gyro_y = [gyro_data.y_axis_deg_s_(:)' zeros(1,len)];
            gyro_z = [gyro_data.z_axis_deg_s_(:)' zeros(1,len)];            
        else
            gyro_x = gyro_data.x_axis_deg_s_(1:time*sample_freq(1))';
            gyro_y = gyro_data.y_axis_deg_s_(1:time*sample_freq(1))';
            gyro_z = gyro_data.z_axis_deg_s_(1:time*sample_freq(1))';
        end
        
    elseif list(i).name(end-6:end-4) == 'Acc'
        Acc_data = readtable(strcat(path,'/',list(i).name));  
        len = time*sample_freq(1) - length(Acc_data.x_axis_g_); 
        if len > 0
        acc_x = [Acc_data.x_axis_g_(:)' zeros(1,len)];
        acc_y = [Acc_data.y_axis_g_(:)' zeros(1,len)];
        acc_z = [Acc_data.z_axis_g_(:)' zeros(1,len)];
        else
        acc_x = Acc_data.x_axis_g_(1:time*sample_freq(1))';
        acc_y = Acc_data.y_axis_g_(1:time*sample_freq(1))';
        acc_z = Acc_data.z_axis_g_(1:time*sample_freq(1))';
        end

    elseif list(i).name(end-7:end-4) == 'Baro'
        Baro_data = readtable(strcat(path,'/',list(i).name));
        len =  time*sample_freq(2) - length(Baro_data.pressure_Pa_); 
        if len > 0
        baro = [Baro_data.pressure_Pa_(:)' zeros(1,len)];
        else
        baro = Baro_data.pressure_Pa_(1:time*sample_freq(2))';
        end
    end
end

proccessed_data.gyro = [gyro_x; gyro_y; gyro_z; labels_gyro_acc(1:time*sample_freq(1))];
proccessed_data.acc = [acc_x; acc_y; acc_z; labels_gyro_acc(1:time*sample_freq(1))];
proccessed_data.baro = [baro; labels_baro(1:time*sample_freq(2))];

save(strcat(path,'/',group_num,'.',foldername,'.proccessed_data.mat'), 'proccessed_data');
end