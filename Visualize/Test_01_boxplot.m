% load carsmall;
% boxplot(MPG,Origin)
% title('Miles per Gallon by Vehicle Origin')
% xlabel('Country of Origin')
% ylabel('Miles per Gallon (MPG)')
%% Run 'Classificaton_ROC' first
clc;clearvars -except final_result
% [filename,path]=uigetfile('*.mat');
% load([path,filename]);
temp=fieldnames(final_result);
LH_RH=0;
RH_F=0;
F_LH=0;
for i=length(temp):length(temp)
    temp_LH_RH=table2array(final_result.(char(temp(i))).LH_RH.Table(2,:)); 
    temp_RH_F=table2array(final_result.(char(temp(i))).RH_F.Table(2,:));
    temp_F_LH=table2array(final_result.(char(temp(i))).F_LH.Table(2,:));
    for j=1:length(temp_LH_RH)
        temp_01=cell2mat(temp_LH_RH(j));
        acc_01(j)=100*trace(temp_01)/sum(temp_01(:));
        temp_02=cell2mat(temp_RH_F(j));
        acc_02(j)=100*trace(temp_02)/sum(temp_02(:));
        temp_03=cell2mat(temp_F_LH(j));
        acc_03(j)=100*trace(temp_03)/sum(temp_03(:));
    end
    LH_RH(end+1:end+10)=acc_01;
    RH_F(end+1:end+10)=acc_02;
    F_LH(end+1:end+10)=acc_03;
end
LH_RH=LH_RH(2:end)';
RH_F=RH_F(2:end)';
F_LH=F_LH(2:end)';
data(1:length(LH_RH))=LH_RH;
data(end+1:end+length(RH_F))=RH_F;
data(end+1:end+length(F_LH))=F_LH;
data=data';
varName='';
for i=1:length(LH_RH)
    varName(end+1,1:5)='LH_RH';
end
for i=1:length(RH_F)
    varName(end+1,1:4)='RH_F';
end
for i=1:length(F_LH)
    varName(end+1,1:4)='F_LH';
end
figure
boxplot(data,varName,'Whisker',1.5);%,'Notch','on'
ylabel('accuracy(%)');