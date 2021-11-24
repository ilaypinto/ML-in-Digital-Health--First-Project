function data_set = create_data_set(folders, data, segmentation, mat_file_name, label_time, flag_segm_MW, flag_segm_ET)
% this function creates a data set from folders specified.
% the data is segmented as specified.

% segmentation and sorting the recording by movement labels - Moving Window & Event Trigger
% initialize matrixes with empty structures
struc.gyro = [];
struc.acc  = [];
struc.baro = [];
segments_MW = repmat(struc,1,9);
segments_ET = repmat(struc,1,9);

% Moving Window segmentation - very long run time
if flag_segm_MW
    for i = folders
        temp_segments_MW = extract_segments(data{1,i}, label_time, overlap, segmentation(1,:));
        for j = 1:9
            if isempty(temp_segments_MW(j).gyro)
                continue
            end
            my_struc = segments_MW(j);
            my_struc.gyro = cat(3, my_struc.gyro, temp_segments_MW(j).gyro);
            my_struc.acc = cat(3, my_struc.acc, temp_segments_MW(j).acc);
            my_struc.baro = cat(3, my_struc.baro, temp_segments_MW(j).baro);
            segments_MW(j) = my_struc;
        end
    end
    data_set = segments_MW;
    % save everything
    N = size(segments_MW(9).gyro, 3);   % the memory size of the data is big so we split it into several files
    extra_MW_segmentation_1.gyro = segments_MW(9).gyro(:,:,1:round(N/3));
    extra_MW_segmentation_1.acc = segments_MW(9).acc(:,:,1:round(N/3));
    extra_MW_segmentation_1.baro = segments_MW(9).baro(:,:,1:round(N/3));
    save(strcat('mat files/', mat_file_name, '_extra_MV_segmentation_1'), 'extra_MW_segmentation_1');
    extra_MW_segmentation_2.gyro = segments_MW(9).gyro(:,:,round(N/3) + 1:round(N*2/3));
    extra_MW_segmentation_2.acc = segments_MW(9).acc(:,:,round(N/3) + 1:round(N*2/3));
    extra_MW_segmentation_2.baro = segments_MW(9).baro(:,:,round(N/3) + 1:round(N*2/3));
    save(strcat('mat files/', mat_file_name, '_extra_MV_segmentation_2'), 'extra_MW_segmentation_2');
    extra_MW_segmentation_3.gyro = segments_MW(9).gyro(:,:,round(N*2/3) + 1:end);
    extra_MW_segmentation_3.acc = segments_MW(9).acc(:,:,round(N*2/3) + 1:end);
    extra_MW_segmentation_3.baro = segments_MW(9).baro(:,:,round(N*2/3) + 1:end);
    save(strcat('mat files/', mat_file_name, '_extra_MV_segmentation_3'), 'extra_MW_segmentation_3');
    segments_MW_to_save = segments_MW(1:8);
    save(strcat('mat files/', mat_file_name, '_MV_segmentation'), 'segments_MW_to_save');
else
    % load the files if specified
    segments_MW = load(strcat('mat files/', mat_file_name, '_MV_segmentation.mat'));
    extra_MW_segmentation_1 = load(strcat('mat files/', mat_file_name, '_extra_MV_segmentation_1.mat'));
    extra_MW_segmentation_2 = load(strcat('mat files/', mat_file_name, '_extra_MV_segmentation_2.mat'));
    extra_MW_segmentation_3 = load(strcat('mat files/', mat_file_name, '_extra_MV_segmentation_3.mat'));
    segments_MW = segments_MW.segments_MW_to_save;
    extra_MW_segmentation_1 = extra_MW_segmentation_1.extra_MW_segmentation_1;
    extra_MW_segmentation_2 = extra_MW_segmentation_2.extra_MW_segmentation_2;
    extra_MW_segmentation_3 = extra_MW_segmentation_3.extra_MW_segmentation_3;
    segments_MW(9).gyro  = cat(3, extra_MW_segmentation_1.gyro, extra_MW_segmentation_2.gyro,extra_MW_segmentation_3.gyro);
    segments_MW(9).acc  = cat(3, extra_MW_segmentation_1.acc, extra_MW_segmentation_2.acc, extra_MW_segmentation_3.acc);
    segments_MW(9).baro  = cat(3, extra_MW_segmentation_1.baro, extra_MW_segmentation_2.baro, extra_MW_segmentation_3.baro);
    data_set = segments_MW;
end

% Event Trigger segmentation - long run time
if flag_segm_ET
    for i = folders
        temp_segments_ET = extract_segments(data{1,i}, label_time, overlap, segmentation(2,:));
        for j = 1:9
            if isempty(temp_segments_ET(j).gyro)
                continue
            end
            my_struc = segments_ET(j);
            my_struc.gyro = cat(3, my_struc.gyro, temp_segments_ET(j).gyro);
            my_struc.acc = cat(3, my_struc.acc, temp_segments_ET(j).acc);
            my_struc.baro = cat(3, my_struc.baro, temp_segments_ET(j).baro);
            segments_ET(j) = my_struc;
        end
    end
    data_set = segments_ET;
    save(strcat(mat_file_name, '_ET_segmentation'), 'segments_ET'); % save the data
else
    segments_ET = load(strcat(mat_file_name, '_ET_segmentation.mat'));  % load the data if specified
    data_set = segments_ET.segments_ET;
end