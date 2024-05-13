clear all
clc

directory = 'C:/Users/MrLiangyiLYU/Desktop/SSR_ECGPPG_noise/Part_2/';
% Get the list of files in the directory
namelist = dir(fullfile(directory, '*.mat'));
len = length(namelist);
for i = 363:len
    file_name{i}=namelist(i).name;
    x= load(file_name{i});
    signal = x.signal;
    [feature_person,position_features]=Extract_feature(signal); % extract original features
    % [feature_person,position_features]=Extract_feature_withnoise(signal); % extract features with noise
     save_path1 = ['C:/Users/MrLiangyiLYU/Desktop/SSR_ECGPPG_noise/PART2_features/p2f' file_name{i}];
     save(save_path1,'feature_person');
     save_path2 = ['C:/Users/MrLiangyiLYU/Desktop/SSR_ECGPPG_noise/PART2_positions/p2p' file_name{i}];
     save(save_path2,'position_features');
end