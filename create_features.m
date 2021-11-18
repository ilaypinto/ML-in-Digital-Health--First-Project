function features = create_features(datastruct)
% this function takes a data structure from preproccess_data and extract
% all kind of different features we decided to use/test/compare.

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
freq_accgyro = [0, 5; 5, 10; 10, 15; 15, 20; 20, 25];
freq_baro = [0, 1; 1, 2; 2, 3; 3, 3.82];

% Features
for i=1:size(datastruct.gyro,3)
    sample_features = [];                       % reset this vec every iteration
    for j = 1:7
        vec = data{j}(1,:,i);                   % current vector
        derv_1 = abs(vec(2:end) - vec(1:end-1));% first derivative
        pos = vec > 0;
        
% time domain features
        Mean        = mean(vec);                % Mean value of window
        Std         = std(vec);                 % STD value of window
        Ent         = wentropy(vec,'shannon');  % Entropy of window
        Energy      = sum((abs(vec)).^2);       % Energy of window
        Var         = var(vec);                 % Variance of window
        Med         = median(vec);              % Median for window
        Min         = min(vec);                 % Minimal value for window
        Max         = max(vec);                 % Maximal value for window
        %Slew       = slewrate(vec);            % Slewrate of window
        Skew        = skewness(vec);            % Skewness of window
        Kurt        = kurtosis(vec);            % Kurtosis of window
        Iqr         = iqr(vec);                 % IQR of window
        max_slope = max(derv_1);                % max slope
        zero_crossing = abs(sum(pos(2:end)...
                            - pos(1:end-1)));   % zero crossing

% freq domain features
        Y = fft(vec); L = length(vec); P2 = abs(Y/L);       % compute the fft      
        P1 = P2(1:L/2+1); P1(2:end-1) = 2*P1(2:end-1);      % compute the fft
        [M, I] = max(P1);
        max_freq_val = M;
        
        band_p = [];
        if j == 7                                                                       % baro sensor            
            f = Fs(1,2)*(0:(L/2))/L;                      % freq
            for k = 1:length(freq_baro)
                Band_p(k)      = bandpower(vec, Fs(1,2), freq_baro(k,:));               % Bandpower of window
                if f(I) >= freq_baro(k,1) && f(I) <= freq_baro(k,2)
                    max_freq_idx = k;                                                   % dicritized max freq
                end
            end
        else                                                                            % other sensors
            f = Fs(1,1)*(0:(L/2))/L;                      % freq
            for k = 1:length(freq_accgyro)
                Band_p(k)      = bandpower(vec, Fs(1,1), freq_accgyro(k,:));            % Bandpower of window
                if f(I) >= freq_baro(k,1) && f(I) <= freq_baro(k,2)
                    max_freq_idx = k;                                                   % dicritized max freq
                end
            end
        end

        sample_features = [sample_features, Mean, Std, Ent, Energy, Var, Med, Min, Max, zero_crossing, Rms, Band_p, Skew, Kurt, Iqr, band_p];
    end
    features = cat(3, features, sample_features);
end
end