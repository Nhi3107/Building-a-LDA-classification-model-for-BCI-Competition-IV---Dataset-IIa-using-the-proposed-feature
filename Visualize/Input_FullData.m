% Dùng code này để load file .mat vào matlab:
% - chỉ cần chỉ tới đường dẫn chứa folder của tất cả dataset muốn chạy ROC
clc;clear;
%% Lấy thông tin đường dẫn
path=uigetdir;
check=dir([path,'\','*.mat']);
%% Chạy vòng lặp từng subject
for i = 1:length(check)
    temp_name=check(i).name(14:end-4);
    if temp_name(1)=='['
        listname(i,1)={temp_name(5:end)}
        clear temp subtemp
    else
        listname(i,1)={temp_name};
    end
    clear temp_name
    load([path,'\',check(i).name]);
    CASE.(char(listname(i)))=fieldnames(FBCSP); % từng ngày đo trong author
    temp.FBCSP=FBCSP;
    temp.DFBCSP_Fisher=DFBCSP_Fisher;
    temp.DFBCSP_mRmR=DFBCSP_mRmR;
    temp.DFBCSP_FmRmR=DFBCSP_FmRmR;
    eval(['FullData.',char(listname(i,1)),'=temp']); % lưu lại data với tên biến Fulldata
    clear temp FBCSP DFBCSP_Fisher DFBCSP_mRmR DFBCSP_FmRmR
end
clear check i
class_pair={'LH_RH','RH_F','F_LH'};
method={'FBCSP','DFBCSP_Fisher','DFBCSP_mRmR','DFBCSP_FmRmR'};