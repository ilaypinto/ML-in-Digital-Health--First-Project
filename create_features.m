function features = create_features(datastruct)
% this function takes a data structure from preproccess_data and extract
% all kind of different features we decided to use/test/compare.

% extract the sensors data
gyro = datastruct.gyro;
acc = datastruct.acc;
baro = datastruct.baro;

% compute energy in each axis of each sensor
gyro_eng = sum(abs(gyro(1:3,:)))';
acc_eng = sum(abs(acc(1:3,:)))';
baro_eng = sum(abs(baro(1,:)));

%





end