function features_names = get_feat_names()
% create a cell containing the features names
names_gyro_acc = char('Mean', 'Std', 'Ent', 'Energy', 'Var', 'Med', 'Min', 'Min_idx', 'Max', 'Max_idx', 'Skew', 'Kurt', 'Iqr', 'max_slope', 'zero_crossing',...
    'band_p_0_2','band_p_2_5','band_p_5_10','band_p_10_15','band_p_15_20','band_p_20_24', 'max_freq_idx', 'min_max_idx_diff');
names_baro = char('Mean', 'Std', 'Ent', 'Energy', 'Var', 'Med', 'Min', 'Min_idx', 'Max', 'Max_idx', 'Skew', 'Kurt', 'Iqr', 'max_slope', 'zero_crossing',...
    'band_p_0_1','band_p_1_2','band_p_2_3','band_p_3_3_8', 'max_freq_idx', 'min_max_idx_diff');
starter = char('gyro_x_', 'gyro_y_', 'gyro_z_', 'acc_x_', 'acc_y_', 'acc_z_', 'baro_');
names_multi = char('total energy', 'acc_std', 'acc_std_end', 'acc_std_start', 'gyro_energy_start', 'gyro_energy_end');
for j = 1:7
    if j ~= 7
        for i = 1:size(names_gyro_acc, 1)
            features_names{size(names_gyro_acc, 1)*(j - 1) + i} = strcat(starter(j,:), names_gyro_acc(i,:));
        end
    else
        for i = 1:size(names_baro, 1)
            features_names{size(names_gyro_acc, 1)*(j - 1) + i} = strcat(starter(j,:), names_baro(i,:));
        end
    end
end
for j = 1:size(names_multi, 1)
    features_names{end + 1} = names_multi(j,:);
end
end