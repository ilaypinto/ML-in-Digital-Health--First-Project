function windows = extract_sampels(datastruct)
% this function recieves a data structer and output a cell with
% arrays containing recording of a movement.
% the order of labels in the cell is  [12 22 3 4 5 6 11 21 0]
% need to add 0 label sections!!!

labels_time = [2,2,2,2,2,2,2,2,2];
sample_freq = [25, 3.82];
window_size = labels_time.*sample_freq(1) + 10;
window_size_baro = round(labels_time.*sample_freq(2)) + 1;
% extract the data from each sensor
gyro = datastruct.gyro;
acc = datastruct.acc;
baro = datastruct.baro;

% extract labels for each sensor
labels = gyro(4,:);
labels_baro = baro(2,:);

num_0 = length(find(labels == 0))/window_size(9);
num_12 = length(find(labels == 12))/window_size(1);
num_22 = length(find(labels == 22))/window_size(2);
num_3 = length(find(labels == 3))/window_size(3);
num_4 = length(find(labels == 4))/window_size(4);
num_5 = length(find(labels == 5))/window_size(5);
num_6 = length(find(labels == 6))/window_size(6);
num_11 = length(find(labels == 11))/window_size(7);
num_21 = length(find(labels == 21))/window_size(8);

labels_numbers = [12 22 3 4 5 6 11 21 0];
total_num = [num_12 num_22 num_3 num_4 num_5 num_6 num_11 num_21 num_0];

% extract the relevant recording indices for each movement and store the
% recording in that time in windows - index in window is the same as the movement label
% except label 0 which is the last index (7) in windows
windows = cell(1,9);
for i = 1:8
    if total_num(i) ~= 0
        move_gyro = gyro(1:3,labels == labels_numbers(i));
        move_acc = acc(1:3,labels == labels_numbers(i));
        move_baro = baro(1, labels_baro == labels_numbers(i));
        move.gyro = [];
        move.acc = [];
        move.baro = [];
        for j = 0:total_num(i) - 1
            move.gyro(:,:,j + 1) = move_gyro(:,j*window_size(i) + 1:window_size(i)*(j + 1));
            move.acc(:,:,j + 1) = move_acc(:,j*window_size(i) + 1:window_size(i)*(j + 1));
            move.baro(:,:,j + 1) = move_baro(:,j*window_size_baro(i) + 1:window_size_baro(i)*(j + 1));
        end
        windows{i} = move;
    end
end




