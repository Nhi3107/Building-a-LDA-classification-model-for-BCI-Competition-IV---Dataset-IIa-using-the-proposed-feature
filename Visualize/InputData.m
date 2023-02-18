clearvars
clc; clear;
[filename,path]=uigetfile('*.mat');% Lấy thông tin đường dẫn
load([path,filename]); % load data
temp=split(filename(1:end-4),'_');
idname=char(temp(end));
CASE=fieldnames(DFBCSP_Fisher);
method={'FBCSP','DFBCSP_Fisher','DFBCSP_mRmR','DFBCSP_FmRmR'};
clc; clear name temp