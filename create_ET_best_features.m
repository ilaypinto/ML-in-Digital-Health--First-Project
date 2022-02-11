function features = create_ET_best_features(varargin)
% this function takes a data structure from preproccess_data and extract
% the best features (for event trigger segmentation) we found for our model.
% for train/test features insert a data structure and a label number. for 
% new observations insert only data structure.
% if a label is given the label vector will be the last column in the
% features matrix

datastruct = varargin{1};
num_feat = 40;
if nargin > 1
    label = varargin{2};
    num_feat = num_feat + 1;
end
if isempty(datastruct.gyro)
    features = [];
    return
end

num = size(datastruct.gyro, 3);
features = zeros(num, num_feat);

for i = 1:num
    % extract the signals from the structer
    gyro_x = datastruct.gyro(1,:,i);
    gyro_y = datastruct.gyro(2,:,i);
    gyro_z = datastruct.gyro(3,:,i);
    acc_x = datastruct.acc(1,:,i);
    acc_y = datastruct.acc(2,:,i);
    acc_z = datastruct.acc(3,:,i);

    % define some variables to use when computing features
    freq_accgyro = [0, 2.5 ; 2.5, 5; 5, 10; 10, 15; 15, 20; 20, 24]./2;

    % compute features - these are the best features we got from the sfs
    gyro_x_Mean = mean(gyro_x);
    [~, gyro_x_Max_idx] = max(gyro_x);
    [gyro_y_Max, gyro_y_Max_idx] = max(gyro_y);
    [~, gyro_y_Min_idx] = min(gyro_y);
    gyro_z_mean = mean(gyro_z);
    gyro_z_Max = max(gyro_z);
    gyro_z_iqr = iqr(gyro_z);
    acc_x_Ent = wentropy(acc_x,'shannon');
    [acc_x_Min, acc_x_Min_I] = min(acc_x);
    acc_x_skew = skewness(acc_x);
    acc_x_kurt = kurtosis(acc_x);
    acc_x_band_p_2_5 = bandpower(acc_x, 25, [1.25, 2.5]);

    
    Y = fft(acc_x); L = length(acc_x); P2 = abs(Y/L);   % compute the fft      
    P1 = P2(1:L/2+1); P1(2:end-1) = 2*P1(2:end-1);      % compute the fft
    [~, I] = max(P1);
    f = 25*(0:(L/2))/L;                                 % freq
    for k = 1:length(freq_accgyro)
        if f(I) >= freq_accgyro(k,1) && f(I) <= freq_accgyro(k,2)
            acc_x_max_freq_idx = k;                                                   % dicritized max freq
        end
    end
    
    acc_y_std = std(acc_y);
    
    pos = acc_y > 0;
    acc_y_zero_crossing = abs(sum(pos(2:end) - pos(1:end-1)));   % zero crossing

    pos = gyro_z > 0;
    gyro_z_zero_crossing           = abs(sum(pos(2:end)...
                                            - pos(1:end-1)));   % zero crossing

    pos = acc_z > 0;
    acc_z_zero_crossing           = abs(sum(pos(2:end)...
                                            - pos(1:end-1)));   % zero crossing
    
    
    Y = fft(acc_y); L = length(acc_y); P2 = abs(Y/L);   % compute the fft      
    P1 = P2(1:L/2+1); P1(2:end-1) = 2*P1(2:end-1);      % compute the fft
    [~, I] = max(P1);
    f = 25*(0:(L/2))/L;                                 % freq
    for k = 1:length(freq_accgyro)
        if f(I) >= freq_accgyro(k,1) && f(I) <= freq_accgyro(k,2)
            acc_y_max_freq_idx = k;                                                   % dicritized max freq
        end
    end
    
    acc_z_std = std(acc_z);
    [acc_z_Min,acc_z_Min_I] = min(acc_z);
    [~, acc_z_Max_idx] = max(acc_z);
    acc_z_kurt = kurtosis(acc_z);


    % new features after presentation day we think are good to add - not
    % tested with sfs but adding them did improved the model, we could use
    % another sfs to filter some of the new or old features but we didnt
    % have the time to run the sfs function...

    % difine some filter parameters
    h = [1/2 1/2];
    binomialCoeff = conv(h,h);
    for n = 1:4
        binomialCoeff = conv(binomialCoeff,h);
    end

    % clip the gyro data and find peaks and the first peak sign - doesnt do
    % what we want accuratly but gives a decent result

    gyro_x_clip = abs(gyro_x);
    gyro_x_clip(gyro_x_clip < 80) = 80;
    gyro_x_clip = filter(binomialCoeff, 1, gyro_x_clip);
    [~, idx] = findpeaks(gyro_x_clip);
    if isempty(idx)
        gyro_x_num_peaks = 0;
        gyro_x_sign_first_peak = 0;
    else
        gyro_x_num_peaks = sum(idx > 81);
        gyro_x_sign_first_peak = sign(gyro_x(idx(1)));
    end

    gyro_y_clip = abs(gyro_y);
    gyro_y_clip(gyro_y_clip < 80) = 80;
    gyro_y_clip = filter(binomialCoeff, 1, gyro_y_clip);
    [~, idx] = findpeaks(gyro_y_clip);
    if isempty(idx)
        gyro_y_num_peaks = 0;
        gyro_y_sign_first_peak = 0;
    else
        gyro_y_num_peaks = sum(idx > 81);
        gyro_y_sign_first_peak = sign(gyro_y(idx(1)));
    end

    gyro_z_clip = abs(gyro_x);
    gyro_z_clip(gyro_z_clip < 80) = 80;
    gyro_z_clip = filter(binomialCoeff, 1, gyro_z_clip);
    [~, idx] = findpeaks(gyro_z_clip);
    if isempty(idx)
        gyro_z_num_peaks = 0;
        gyro_z_sign_first_peak = 0;
    else
        gyro_z_num_peaks = sum(idx > 81);
        gyro_z_sign_first_peak = sign(gyro_z(idx(1)));
    end

    % clip the acc data and find peaks and the first peak sign
    acc_x_clip = abs(acc_x);
    acc_x_clip(acc_x_clip < 0.5) = 0.5;
    acc_x_clip = filter(binomialCoeff, 1, acc_x_clip);
    [~, idx] = findpeaks(acc_x_clip);
    if isempty(idx)
        acc_x_num_peaks = 0;
        acc_x_sign_first_peak = 0;
    else
        acc_x_num_peaks = sum(idx > 0.51);
        acc_x_sign_first_peak = sign(acc_x(idx(1)));
    end

    acc_y_clip = abs(acc_y);
    acc_y_clip(acc_y_clip < 0.5) = 0.5;
    acc_y_clip = filter(binomialCoeff, 1, acc_y_clip);
    [~, idx] = findpeaks(acc_y_clip);
    if isempty(idx)
        acc_y_num_peaks = 0;
        acc_y_sign_first_peak = 0;
    else
        acc_y_num_peaks = sum(idx > 0.51);
        acc_y_sign_first_peak = sign(acc_y(idx(1)));
    end

    acc_z_clip = abs(acc_z);
    acc_z_clip(acc_z_clip < 0.5) = 0.5;
    acc_z_clip = filter(binomialCoeff, 1, acc_z_clip);
    [~, idx] = findpeaks(acc_z_clip);
    if isempty(idx)
        acc_z_num_peaks = 0;
        acc_z_sign_first_peak = 0;
    else
        acc_z_num_peaks = sum(idx > 0.51);
        acc_z_sign_first_peak = sign(acc_z(idx(1)));
    end


    acc_std = std(acc_x) + std(acc_y) + std(acc_z);
    std_end = std(gyro_x(end-12:end)) + std(gyro_y(end-12:end)) + std(gyro_z(end-12:end));
    std_start = std(gyro_x(1:12)) + std(gyro_y(1:12)) + std(gyro_z(1:12));
    
    
    if exist('label', 'var')
        temp_features = [gyro_x_Mean, gyro_x_Max_idx, gyro_y_Max, gyro_y_Max_idx, gyro_z_mean, gyro_z_Max, gyro_z_iqr,...
        acc_x_Ent, acc_x_Min, acc_x_skew, acc_x_kurt, acc_x_band_p_2_5, acc_x_max_freq_idx, acc_y_std, acc_y_zero_crossing,...
        acc_y_max_freq_idx, acc_z_std, acc_z_Min, acc_z_Max_idx, acc_z_kurt, acc_std, std_end, std_start,gyro_y_Min_idx,...
        gyro_z_zero_crossing, acc_x_Min_I, acc_z_Min_I, acc_z_zero_crossing, gyro_x_num_peaks, gyro_x_sign_first_peak, gyro_y_num_peaks, gyro_y_sign_first_peak,...
        gyro_z_num_peaks, gyro_z_sign_first_peak, acc_x_num_peaks, acc_x_sign_first_peak, acc_y_num_peaks, acc_y_sign_first_peak, acc_z_num_peaks, acc_z_sign_first_peak  label];
    else
        temp_features = [gyro_x_Mean, gyro_x_Max_idx, gyro_y_Max, gyro_y_Max_idx, gyro_z_mean, gyro_z_Max, gyro_z_iqr,...
        acc_x_Ent, acc_x_Min, acc_x_skew, acc_x_kurt, acc_x_band_p_2_5, acc_x_max_freq_idx, acc_y_std, acc_y_zero_crossing,...
        acc_y_max_freq_idx, acc_z_std, acc_z_Min, acc_z_Max_idx, acc_z_kurt, acc_std, std_end, std_start,gyro_y_Min_idx,...
        gyro_z_zero_crossing, acc_x_Min_I, acc_z_Min_I, acc_z_zero_crossing, gyro_x_num_peaks, gyro_x_sign_first_peak, gyro_y_num_peaks, gyro_y_sign_first_peak,...
        gyro_z_num_peaks, gyro_z_sign_first_peak, acc_x_num_peaks, acc_x_sign_first_peak, acc_y_num_peaks, acc_y_sign_first_peak, acc_z_num_peaks, acc_z_sign_first_peak];
    end
    features(i,:) = temp_features;
end
end


