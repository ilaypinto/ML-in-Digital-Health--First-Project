function folders = create_data_folders(O_filepath)
% order all data in folders such that each folder is a unique recording

folders = [];                                       % store the folders for later calls
listing = dir(O_filepath);                          % get files info
for i = 120:length(listing) - 2
    name = listing(i).name;                         % name of the file
    tags = split(name,'.'); 
    group = tags{1};                                % group number
    rec = tags{2};                                  % recording number
    k = (str2num(group) - 1)*12 + str2num(rec);     % folder number to match group and record numbers
    folders(end + 1) = k;
    % check if folder 'k' exist and if not create one
    new_folders = dir('data\meta-motion\Full recordings');
    flag = 1;
    for j = 1:length(new_folders)
        if strcmp(int2str(k), new_folders(j).name)
            flag = 0;
            break
        end
    end
    if flag
        mkdir(fullfile('data\meta-motion\Full recordings', int2str(k)));
    end

    % copy the file into folder 'k' if it doesnt already exist there
    sourceFile = fullfile(O_filepath, name);
    destFile   = fullfile('data\meta-motion\Full recordings', int2str(k), name);
    if ~isfile(destFile)
        copyfile(sourceFile, destFile);
    end
end
folders = unique(folders);
end




