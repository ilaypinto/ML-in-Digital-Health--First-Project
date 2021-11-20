function [features, features_names] = create_features(varargin)
% this function takes a data structure from preproccess_data and extract
% all kind of different features we decided to use/test/compare.
% for train features insert a data structure and a label number for test
% features insert only data structure.

datastruct = varargin{1};
if nargin == 2
    label = varargin{2};
end

% extract the signals from the structer
gyro_x = datastruct.gyro(1,:,:);
gyro_y = datastruct.gyro(2,:,:);
gyro_z = datastruct.gyro(3,:,:);
acc_x = datastruct.acc(1,:,:);
acc_y = datastruct.acc(2,:,:);
acc_z = datastruct.acc(3,:,:);
baro = datastruct.baro;

% store the signals in a cell for easy access from for loop
data=cell(1,7);
data{1} = gyro_x; data{2} = gyro_y; data{3} = gyro_z; data{4} = acc_x;
data{5} = acc_y; data{6} = acc_z; data{7} = baro;

% define features array as an empty array
features=[];

% define some variables to use when computing features
Fs = [25, 3.82];
freq_accgyro = [0, 2.5 ; 2.5, 5; 5, 10; 10, 15; 15, 20; 20, 24]./2;
freq_baro = [0, 1; 1, 2; 2, 3; 3, 3.8]./2;

% Features
for i=1:size(datastruct.gyro,3)
    sample_features = [];                       % reset this vec every iteration
    for j = 1:7
        vec = data{j}(1,:,i);                   % current vector
        if j ~= 7 && ~isempty(find(vec,1))
            derv_1 = abs(vec(2:end) - vec(1:end-1));% first derivative
            pos = vec > 0;
            
    % time domain features
            Mean                    = mean(vec);                % Mean value of window
            Std                     = std(vec);                 % STD value of window
            Ent                     = wentropy(vec,'shannon');  % Entropy of window
            Energy                  = sum((abs(vec)).^2);       % Energy of window
            Var                     = var(vec);                 % Variance of window
            Med                     = median(vec);              % Median for window
            [Min, Min_idx]          = min(vec);                 % Minimal value for window
            [Max, Max_idx]          = max(vec);                 % Maximal value for window
            Skew                    = skewness(vec);            % Skewness of window
            Kurt                    = kurtosis(vec);            % Kurtosis of window
            Iqr                     = iqr(vec);                 % IQR of window
            max_slope               = max(derv_1);              % max slope
            zero_crossing           = abs(sum(pos(2:end)...
                                            - pos(1:end-1)));   % zero crossing
    
    % freq domain features
            Y = fft(vec); L = length(vec); P2 = abs(Y/L);       % compute the fft      
            P1 = P2(1:L/2+1); P1(2:end-1) = 2*P1(2:end-1);      % compute the fft
            [M, I] = max(P1);
            max_freq_val = M;
% Fs = [25, 3.82];
% freq_accgyro = [0, 2.5 ; 2.5, 5; 5, 10; 10, 15; 15, 20; 20, 24];
% freq_baro = [0, 1; 1, 2; 2, 3; 3, 3.8];
            band_p = [];
            if j == 7                                                                       % baro sensor            
                f = Fs(1,2)*(0:(L/2))/L;                      % freq
                for k = 1:length(freq_baro)
                    band_p(k)      = bandpower(vec, Fs(1,2), freq_baro(k,:));               % Bandpower of window
                    if f(I) >= freq_baro(k,1) && f(I) <= freq_baro(k,2)
                        max_freq_idx = k;                                                   % dicritized max freq
                    end
                end
            else                                                                            % other sensors
                f = Fs(1,1)*(0:(L/2))/L;                      % freq
                for k = 1:length(freq_accgyro)
                    band_p(k)      = bandpower(vec, Fs(1,1), freq_accgyro(k,:));            % Bandpower of window
                    if f(I) >= freq_accgyro(k,1) && f(I) <= freq_accgyro(k,2)
                        max_freq_idx = k;                                                   % dicritized max freq
                    end
                end
            end
            % concat the features from different axis of different sensors
            sample_features = [sample_features, Mean, Std, Ent, Energy, Var, Med, Min, Min_idx, Max, Max_idx, Skew, Kurt, Iqr, max_slope, zero_crossing, band_p, max_freq_idx];
        else
            sample_features = [sample_features, NaN(1,20)];         % need to change it if we change the number of features!!!
        end
    end

    % insert label if needed
    if exist('label')
    sample_features = [sample_features, label];
    end
    
    features = cat(1, features, sample_features); % concat features of different windows to create a 2D matrix
end

% create a cell containing the features names
names_gyro_acc = char('Mean', 'Std', 'Ent', 'Energy', 'Var', 'Med', 'Min', 'Min_idx', 'Max', 'Max_idx', 'Skew', 'Kurt', 'Iqr', 'max_slope', 'zero_crossing',...
    'band_p_0_2','band_p_2_5','band_p_5_10','band_p_10_15','band_p_15_20','band_p_20_24', 'max_freq_idx');
names_baro = char('Mean', 'Std', 'Ent', 'Energy', 'Var', 'Med', 'Min', 'Min_idx', 'Max', 'Max_idx', 'Skew', 'Kurt', 'Iqr', 'max_slope', 'zero_crossing',...
    'band_p_0_1','band_p_1_2','band_p_2_3','band_p_3_3_8', 'max_freq_idx');
starter = char('gyro_x ', 'gyro_y ', 'gyro_z ', 'acc_x ', 'acc_y ', 'acc_z ', 'baro ');
for j = 1:7
    if j ~= 7
        for i = 1:length(names_gyro_acc)
            features_names{length(names_gyro_acc)*(j - 1) + i} = strcat(starter(j,:), names_gyro_acc(i,:));
        end
    else
        for i = 1:length(names_baro)
            features_names{length(names_gyro_acc)*(j - 1) + i} = strcat(starter(j,:), names_baro(i,:));
        end
    end
end


end