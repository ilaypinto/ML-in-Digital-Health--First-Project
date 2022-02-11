function windows = extract_segments(datastruct, labels_time, overlap, segment_type)
% this function recieves a data structer and splits it into small segments.
%
% inputs:
%       - DATASTRUCT - data structure containing sensors data and labels
%       - LABEL_TIME - labels duration
%       - OVERLAP - windows percentage of overlapping to use in moving
%                   window segmentation only.
%       - SEGMENT_TYPE - string, 'event triger' or 'moving window'.
%
% outputs:
%        - WINDOWS - an array with structures with fields - gyro, acc, baro.
%                    each field is a 3 dim matrix, firs dim is axis (in the 
%                    following order - x,y,z), second dim is the data, third
%                    dim is for windows separation. each structure holds 
%                    movements from a single label. the order is [12 22 3 4 5 6 11 21 0]
%                    where 12 is in index 1 and 0 in index 9.


extra_time = labels_time*0.5;       % extra time for the windows
sample_freq = [25, 3.82];           % sample frequencies of the sensors

% define the windows size and steps
window_size_gyro_acc = round((labels_time + extra_time).*sample_freq(1));
window_size_baro = round((labels_time + extra_time).*sample_freq(2));
step_gyro_acc = round(((100 - overlap)/100)*window_size_gyro_acc);
step_baro = round(((100 - overlap)/100)*window_size_baro);

% extract the data from each sensor
gyro = datastruct.gyro;
acc = datastruct.acc;
baro = datastruct.baro;

% extract labels for each sensor
labels_gyro_acc = gyro(4,:);
labels_baro = baro(2,:);

move.gyro       = [];
move.acc        = [];
move.baro       = [];
windows = repmat(move,1,9);
% labels tags is a vector containing the labels numbers corresonding to
% their index in windows array.
labels_tags = [12 22 3 4 5 6 11 21 0];

% moving window segmentation
if strcmp(segment_type, 'moving window')
    index_gyro_acc = 1;
    index_baro      = 1;
    while index_gyro_acc + window_size_gyro_acc < length(gyro) && index_baro + window_size_baro < length(baro)
        % extract the label of the window
        labels = labels_gyro_acc(1, index_gyro_acc: index_gyro_acc + window_size_gyro_acc);
        tag = unique(labels);
        if length(tag) == 1
            M = 0;
        else
            M = sum(labels == tag(end));
        end
        if M >= labels_time*sample_freq(1) - 1    % above 80% is enought - should be changed to optimize accuracy
            tag = tag(end);
        else
            tag = 0;
        end
        windows_idx = find(labels_tags == tag);          % where to store the data in windows
        % extract sensors data
        window_gyro = gyro(1:3, index_gyro_acc: index_gyro_acc + window_size_gyro_acc);
        window_acc = acc(1:3, index_gyro_acc: index_gyro_acc + window_size_gyro_acc);
        window_baro = baro(1, index_baro: index_baro + window_size_baro);
        % append into windows
        windows(windows_idx).gyro = cat(3, windows(windows_idx).gyro, window_gyro);
        windows(windows_idx).acc = cat(3, windows(windows_idx).acc, window_acc);
        windows(windows_idx).baro = cat(3, windows(windows_idx).baro, window_baro);
        % update start index with step size
        index_baro = index_baro + step_baro;
        index_gyro_acc = index_gyro_acc + step_gyro_acc;
    end
end

% event trigger segmentation
if strcmp(segment_type, 'event trigger')
    % find indices that trigger a window - peaks above 30 in any gyro axis
    threshold = 80;
    temp_indx = zeros(3, length(gyro(1,:)));
    for j = 1:3
        [~,locs] = findpeaks(abs(gyro(j,:)));          % find peaks
        temp_indx(j, locs) = 1;                        % create bool indices
    end
    upthresh = abs(gyro(1:3,:)) > threshold;      % find points above threshold 
    indices = sum(and(upthresh,temp_indx));       % take only peaks above the threshold
    indices = find(sum(indices,1));               % find indices where peak threshold is passed in at least one axis
    
    % redifine the window size - we need to use pretty big windows since
    % the labels are not accurate
    window_size_gyro_acc = window_size_gyro_acc*2;   % ###################
    window_size_baro = window_size_baro*2;           % ###################
    for i = 1:length(indices)
        % define start and stop indices
        start_gyro_acc = ceil(indices(i) - window_size_gyro_acc/2); 
        stop_gyro_acc  = ceil(indices(i) + window_size_gyro_acc/2); 
        start_baro = floor((indices(i)/25)*3.82) - ceil(window_size_baro/2);
        stop_baro  = floor((indices(i)/25)*3.82) + ceil(window_size_baro/2);
        if start_gyro_acc < 1 || start_baro < 1 || stop_gyro_acc > size(gyro,2) || stop_baro > size(baro,2)
            continue
        end
        % extract the label of the window
        labels = labels_gyro_acc(1, start_gyro_acc: stop_gyro_acc);
        tag = unique(labels);
        if length(tag) ~= 1
            for j = 2:length(tag)
                M = sum(labels == tag(j));
                if M >= labels_time*sample_freq(1) + 1
                    tag = tag(end);
                    break
                else
                    tag = 0;
                end
            end
        end
        windows_idx = find(labels_tags == tag);          % where to store the data in windows
        % extract sensors data
        window_gyro = gyro(1:3, start_gyro_acc: stop_gyro_acc);
        window_acc  = acc(1:3, start_gyro_acc: stop_gyro_acc);
        window_baro = baro(1, start_baro: stop_baro);
        % append into windows
        windows(windows_idx).gyro = cat(3, windows(windows_idx).gyro, window_gyro);
        windows(windows_idx).acc  = cat(3, windows(windows_idx).acc, window_acc);
        windows(windows_idx).baro = cat(3, windows(windows_idx).baro, window_baro);
    end
end
end



