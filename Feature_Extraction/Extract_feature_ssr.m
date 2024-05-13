clear all
close all
clc

namelist = dir('C:/Users/MrLiangyiLYU/Desktop/SSR_ECGPPG_noise/train_ecgppg_noise/*.mat');
len = length(namelist);

dim = 3;
lag=3;
for i = 1:len
    file_name{i}=namelist(i).name;
   x= load(file_name{i});
    feature_person1 = x.feature_person;
    pttp = feature_person1(:,1);
    cfslope = feature_person1(:,2);
    snv = feature_person1(:,3);
    sfr = feature_person1(:,4);
    hr = feature_person1(:,5);
    XR2 = phaseSpaceReconstruction(cfslope,lag,dim); % cfslope
    XR3 = phaseSpaceReconstruction(snv,lag,dim); % snv
    XR4 = phaseSpaceReconstruction(sfr,lag,dim); % sfr
    XR5 = phaseSpaceReconstruction(hr,lag,dim); % hr
    new_feature = cat(2,pttp(lag*(dim-1)+1:end),XR2,XR3,XR4,XR5,feature_person1(lag*(dim-1)+1:end,6:8));

    feature_person=new_feature;
    
    save_path1 = ['C:/Users/MrLiangyiLYU/Desktop/SSR_ECGPPG_noise/train_ecgppg_noise_ssr/' file_name{i}];
    save(save_path1,'feature_person');


end
% new = cat(2,XR2(1:min_len,:),XR3(1:min_len,:),XR4(1:min_len,:),XR5(1:min_len,:),feature_person(1:min_len,6:8));
