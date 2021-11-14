function plot_data_time(data_cell, indx)
% this function gets a cell array and indices vector and plot the data in
% those indices in interesting times to help us visualize the recordings to
% extract features and determine other variables

for i = 1:length(indx)
    % extract the data of each sensor
    data_struc = data_cell{indx(i)};
    gyro = data_struc.gyro;
    acc = data_struc.acc;
    baro = data_struc.baro;

    % find interesting points of each movement
    baro_not_empty = ~isempty(find(baro(1,:),1));  % check if baro is available

    % first movement - zoom in
    gyro_idx_1 = find(gyro(4,:) == 1);
    acc_idx_1 = find(acc(4,:) == 1);
    if baro_not_empty
        baro_idx_1 = find(baro(2,:) == 1);
    else
        baro_idx_1 = [];
    end

    % second movement - zoom out
    gyro_idx_2 = find(gyro(4,:) == 2);
    acc_idx_2 = find(acc(4,:) == 2);
    if baro_not_empty
        baro_idx_2 = find(baro(2,:) == 2);
    else
        baro_idx_2 = [];
    end

    % third movement - scroll up
    gyro_idx_3 = find(gyro(4,:) == 3);
    acc_idx_3 = find(acc(4,:) == 3);
    if baro_not_empty
        baro_idx_3 = find(baro(2,:) == 3);
    else
        baro_idx_3 = [];
    end

    % fourth movement - scroll down
    gyro_idx_4 = find(gyro(4,:) == 4);
    acc_idx_4 = find(acc(4,:) == 4);
    if baro_not_empty
        baro_idx_4 = find(baro(2,:) == 4);
    else
        baro_idx_4 = [];
    end

    % fifth movement - on/off
    gyro_idx_5 = find(gyro(4,:) == 5);
    acc_idx_5 = find(acc(4,:) == 5);
    if baro_not_empty
        baro_idx_5 = find(baro(2,:) == 5);
    else
        baro_idx_5 = [];
    end

    % sixth movement - noise
    gyro_idx_6 = find(gyro(4,:) == 6);
    acc_idx_6 = find(acc(4,:) == 6);
    if baro_not_empty
        baro_idx_6 = find(baro(2,:) == 6);
    else
        baro_idx_6 = [];
    end

    % plot everything...

    % define some variables
    baro_hz = 3.82;
    acc_gyro_hz = 25;

    % gyro plot
    figure('Name', 'Gyro');

    % move 1
    subplot(3,6,1);
    plot(gyro_idx_1./acc_gyro_hz,gyro(1,gyro_idx_1));
    title('1 - x axis'); xlabel('time [sec]'); ylabel('acceleration [deg/s]');

    subplot(3,6,2);
    plot(gyro_idx_1./acc_gyro_hz,gyro(2,gyro_idx_1));
    title('1 - y axis'); xlabel('time [sec]'); ylabel('acceleration [deg/s]'); 

    subplot(3,6,3);
    plot(gyro_idx_1./acc_gyro_hz,gyro(3,gyro_idx_1));
    title('1 - z axis'); xlabel('time [sec]'); ylabel('acceleration [deg/s]');
 
    % move 2
    subplot(3,6,4);
    plot(gyro_idx_2./acc_gyro_hz,gyro(1,gyro_idx_2));
    title('2 - x axis'); xlabel('time [sec]'); ylabel('acceleration [deg/s]');

    subplot(3,6,5);
    plot(gyro_idx_2./acc_gyro_hz,gyro(2,gyro_idx_2));
    title('2 - y axis'); xlabel('time [sec]'); ylabel('acceleration [deg/s]');

    subplot(3,6,6);
    plot(gyro_idx_2./acc_gyro_hz,gyro(3,gyro_idx_2));
    title('2 - z axis'); xlabel('time [sec]'); ylabel('acceleration [deg/s]');

    % move 3
    subplot(3,6,7);
    plot(gyro_idx_3./acc_gyro_hz,gyro(1,gyro_idx_3));
    title('3 - x axis'); xlabel('time [sec]'); ylabel('acceleration [deg/s]');

    subplot(3,6,8);
    plot(gyro_idx_3./acc_gyro_hz,gyro(2,gyro_idx_3));
    title('3 - y axis'); xlabel('time [sec]'); ylabel('acceleration [deg/s]');

    subplot(3,6,9);
    plot(gyro_idx_3./acc_gyro_hz,gyro(3,gyro_idx_3));
    title('3 - z axis'); xlabel('time [sec]'); ylabel('acceleration [deg/s]');

    % move 4
    subplot(3,6,10);
    plot(gyro_idx_4./acc_gyro_hz,gyro(1,gyro_idx_4));
    title('4 - x axis'); xlabel('time [sec]'); ylabel('acceleration [deg/s]');

    subplot(3,6,11);
    plot(gyro_idx_4./acc_gyro_hz,gyro(2,gyro_idx_4));
    title('4 - y axis'); xlabel('time [sec]'); ylabel('acceleration [deg/s]');

    subplot(3,6,12);
    plot(gyro_idx_4./acc_gyro_hz,gyro(3,gyro_idx_4));
    title('4 - z axis'); xlabel('time [sec]'); ylabel('acceleration [deg/s]');

    % move 5
    subplot(3,6,13);
    plot(gyro_idx_5./acc_gyro_hz,gyro(1,gyro_idx_5));
    title('5 - x axis'); xlabel('time [sec]'); ylabel('acceleration [deg/s]');

    subplot(3,6,14);
    plot(gyro_idx_5./acc_gyro_hz,gyro(2,gyro_idx_5));
    title('5 - y axis'); xlabel('time [sec]'); ylabel('acceleration [deg/s]');

    subplot(3,6,15);
    plot(gyro_idx_5./acc_gyro_hz,gyro(3,gyro_idx_5));
    title('5 - z axis'); xlabel('time [sec]'); ylabel('acceleration [deg/s]');

    % move 6
    subplot(3,6,16);
    plot(gyro_idx_6./acc_gyro_hz,gyro(1,gyro_idx_6));
    title('6 - x axis'); xlabel('time [sec]'); ylabel('acceleration [deg/s]');

    subplot(3,6,17);
    plot(gyro_idx_6./acc_gyro_hz,gyro(2,gyro_idx_6));
    title('6 - y axis'); xlabel('time [sec]'); ylabel('acceleration [deg/s]');

    subplot(3,6,18);
    plot(gyro_idx_6./acc_gyro_hz,gyro(3,gyro_idx_6));
    title('6 - z axis'); xlabel('time [sec]'); ylabel('acceleration [deg/s]');


    % Acc plot
    figure('Name','Acc')

    % move 1
    subplot(3,6,1);
    plot(acc_idx_1./acc_gyro_hz,gyro(1,acc_idx_1));
    title('1 - x axis'); xlabel('time [sec]'); ylabel('acceleration [g]');

    subplot(3,6,2);
    plot(acc_idx_1./acc_gyro_hz,gyro(2,acc_idx_1));
    title('1 - y axis'); xlabel('time [sec]'); ylabel('acceleration [g]'); 

    subplot(3,6,3);
    plot(acc_idx_1./acc_gyro_hz,gyro(3,acc_idx_1));
    title('1 - z axis'); xlabel('time [sec]'); ylabel('acceleration [g]');
 
    % move 2
    subplot(3,6,4);
    plot(acc_idx_2./acc_gyro_hz,acc(1,acc_idx_2));
    title('2 - x axis'); xlabel('time [sec]'); ylabel('acceleration [g]');

    subplot(3,6,5);
    plot(acc_idx_2./acc_gyro_hz,acc(2,acc_idx_2));
    title('2 - y axis'); xlabel('time [sec]'); ylabel('acceleration [g]');

    subplot(3,6,6);
    plot(acc_idx_2./acc_gyro_hz,acc(3,acc_idx_2));
    title('2 - z axis'); xlabel('time [sec]'); ylabel('acceleration [g]');

    % move 3
    subplot(3,6,7);
    plot(acc_idx_3./acc_gyro_hz,acc(1,acc_idx_3));
    title('3 - x axis'); xlabel('time [sec]'); ylabel('acceleration [g]');

    subplot(3,6,8);
    plot(acc_idx_3./acc_gyro_hz,acc(2,acc_idx_3));
    title('3 - y axis'); xlabel('time [sec]'); ylabel('acceleration [g]');

    subplot(3,6,9);
    plot(acc_idx_3./acc_gyro_hz,acc(3,acc_idx_3));
    title('3 - z axis'); xlabel('time [sec]'); ylabel('acceleration [g]');

    % move 4
    subplot(3,6,10);
    plot(acc_idx_4./acc_gyro_hz,acc(1,acc_idx_4));
    title('4 - x axis'); xlabel('time [sec]'); ylabel('acceleration [g]');

    subplot(3,6,11);
    plot(acc_idx_4./acc_gyro_hz,acc(2,acc_idx_4));
    title('4 - y axis'); xlabel('time [sec]'); ylabel('acceleration [g]');

    subplot(3,6,12);
    plot(acc_idx_4./acc_gyro_hz,acc(3,acc_idx_4));
    title('4 - z axis'); xlabel('time [sec]'); ylabel('acceleration [g]');

    % move 5
    subplot(3,6,13);
    plot(acc_idx_5./acc_gyro_hz,acc(1,acc_idx_5));
    title('5 - x axis'); xlabel('time [sec]'); ylabel('acceleration [g]');

    subplot(3,6,14);
    plot(acc_idx_5./acc_gyro_hz,acc(2,acc_idx_5));
    title('5 - y axis'); xlabel('time [sec]'); ylabel('acceleration [g]');

    subplot(3,6,15);
    plot(acc_idx_5./acc_gyro_hz,acc(3,acc_idx_5));
    title('5 - z axis'); xlabel('time [sec]'); ylabel('acceleration [g]');

    % move 6
    subplot(3,6,16);
    plot(acc_idx_6./acc_gyro_hz,acc(1,acc_idx_6));
    title('6 - x axis'); xlabel('time [sec]'); ylabel('acceleration [g]');

    subplot(3,6,17);
    plot(acc_idx_6./acc_gyro_hz,acc(2,acc_idx_6));
    title('6 - y axis'); xlabel('time [sec]'); ylabel('acceleration [g]');

    subplot(3,6,18);
    plot(acc_idx_6./acc_gyro_hz,acc(3,acc_idx_6));
    title('6 - z axis'); xlabel('time [sec]'); ylabel('acceleration [g]');
    
 

end
end



