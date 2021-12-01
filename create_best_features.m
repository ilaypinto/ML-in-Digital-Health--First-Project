function features = create_best_features(varargin)
% this function takes a data structure from preproccess_data and extract
% the best features (for event trigger segmentation) we found for our model.
% for train/test features insert a data structure and a label number. for 
% new observations insert only data structure.
% if a label is given the label vector will be the last column in the
% features matrix

datastruct = varargin{1};
num_feat = 21;
if nargin > 1
    label = varargin{2};
    num_feat = 22;
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
    baro = datastruct.baro(1,:,i);
    
    % define some variables to use when computing features
    freq_accgyro = [0, 2.5 ; 2.5, 5; 5, 10; 10, 15; 15, 20; 20, 24]./2;
    
% [1 5 12 13 19 23 26 29 31 34 35 39 40 41 51 52 53 55 57 59 68] - indices
% of best features

    % compute features
    gyro_x_Mean = mean(gyro_x);
    [~, gyro_x_Max_idx] = max(gyro_x);
    [gyro_y_Max, gyro_y_Max_idx] = max(gyro_y);
    gyro_z_mean = mean(gyro_z);
    gyro_z_Max = max(gyro_z);
    gyro_z_iqr = iqr(gyro_z);
    acc_x_Ent = wentropy(acc_x,'shannon');
    acc_x_Min = min(acc_x);
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
    acc_z_Min = min(acc_z);
    [~, acc_z_Max_idx] = max(acc_z);
    acc_z_kurt = kurtosis(acc_z);
    
    derv_1 = abs(baro(2:end) - baro(1:end-1));   % first derivative
    baro_max_slope = max(derv_1);
    
    
    temp_features = [gyro_x_Mean, gyro_x_Max_idx, gyro_y_Max, gyro_y_Max_idx, gyro_z_mean, gyro_z_Max, gyro_z_iqr,...
        acc_x_Ent, acc_x_Min, acc_x_skew, acc_x_kurt, acc_x_band_p_2_5, acc_x_max_freq_idx, acc_y_std, acc_y_zero_crossing,...
        acc_y_max_freq_idx, acc_z_std, acc_z_Min, acc_z_Max_idx, acc_z_kurt, baro_max_slope];
    
    if exist('label')
        temp_features = [temp_features, label];
    end
    features(i,:) = temp_features;
end
end


