%% this are some plots to check the segmentation and label process is done as we wish - surprise surprise its NOT... :( 
% the problem is not in our code (our files are being labeled and segmented very accurately) but in the label process 
% done by some other groups, so we are exluding the bad labeled recordings.

good_labels_folder = [];

indx = [49 50 51 52	53 54 55 57	58 59 60 73	74 75 76 77	78 79 80 81	82 ...
                 83	84 87 90 91	93 94 159 160 161 163 164 165 166 167 168 173 174 175 176 178 205 206 208 ...
                 213 214 215 216 227 241	242	243	244	245	246	247	248	249	250	251	252	253	254	256	257	258 ...
                 259	260	 262	265	266	267	269	270	271	272	273	274	276	277	279	280	281	282	283	284	289	293	294	295	296	297	298	299	300];         
for i = indx
    temp_data = data{i};
    baro_1 = temp_data.baro;
    gyro_1 = temp_data.gyro;
    acc_1 = temp_data.acc;
%     figure(1);
%     plot((1:length(baro_1(1,:))),baro_1(1,:)); hold on; plot(find(baro_1(2,:) ~= 0), baro_1(1, find(baro_1(2,:) ~= 0)) + 1.01*10^5,'b.' ); hold off;
    figure(2);
    plot((1:length(gyro_1(1,:))),gyro_1(1:3,:)); hold on; plot(find(gyro_1(4,:) ~= 0), gyro_1(1:3, find(gyro_1(4,:) ~= 0)),'b.' ); hold off;
% 
    figure(3);
    plot((1:length(acc_1(1,:))),acc_1(1:3,:)); hold on; plot(find(acc_1(4,:) ~= 0), acc_1(1:3, find(acc_1(4,:) ~= 0)),'b.' ); hold off;
    pause()
%     store = input('good: ');
%     if store == 1
%         good_labels_folder(end + 1) = i;
%     end
end
%%
% a = create_data_set([51  , data, segmentation(2,:), overlap, 'train', label_time, 1,1);

for i = 1:9
    for j = 1:size(ET_train_set(i).gyro,3)
        L = ET_train_set(i);
        figure(2);
        plot((1:length(L.gyro(1,:,j))),L.gyro(:,:,j));
        pause()

    end
end

