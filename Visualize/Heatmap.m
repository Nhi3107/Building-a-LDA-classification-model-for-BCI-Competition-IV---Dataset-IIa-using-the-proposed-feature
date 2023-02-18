clearvars -except CASE DFBCSP_Fisher DFBCSP_FmRmR DFBCSP_mRmR FBCSP filename idname method path
clc
%% Check folder
% check = dir(fullfile(path, 'HeatMap'));
% if isempty(check)
%     mkdir([path,'HeatMap']);
% else
% end
% selpath=[path,'HeatMap','\'];
% clear check
% 
% check = dir(fullfile(selpath,idname));
% if isempty(check)
%     mkdir([selpath,idname]);
% else
% end
clear check
%% Run 'InputData' first - input one subject
extract.FBCSP=FBCSP;
extract.DFBCSP_Fisher=DFBCSP_Fisher;
extract.DFBCSP_mRmR=DFBCSP_mRmR;
extract.DFBCSP_FmRmR=DFBCSP_FmRmR;

test_CASE=char(CASE(1));
if idname(1)=='['
    CASE=CASE(end); 
end

temp_classpair={'LH_RH','RH_F','F_LH'};
len_classpair=length(temp_classpair);

figure('Name',sprintf('Subject %s',idname));
set(gcf,'WindowState','maximized')
% tiledlayout(len_classpair,length(fieldnames(extract)),'Padding','compact','TileSpacing','none');
count=0;

for a=1:length(CASE) % lấy 'all' bên author và 'one_vs_one' bên bci
    for j=1:length(fieldnames(extract)) % lặp theo method
        for i=1:len_classpair % lặp theo classpair
            count=count+1; % biến để vẽ hình => max count =12;
            % chỉnh lại tên các biến cần thiết
            temp_02_classpair=strrep(char(temp_classpair(i)),'_',' vs. ');
            if idname(1)=='['
                temp_CASE=char(CASE(a));
            else
                temp_CASE=strrep(char(CASE(a)),'_',' ');
            end
            temp_method=strrep(char(method(j)),'_','-');
            
            classlabels=split(temp_classpair(i),'_');
            classlabels=char(classlabels);
            
            xvalues = {classlabels(1,:),classlabels(2,:)}; % tách tên từng cặp classpair
            yvalues = {classlabels(1,:),classlabels(2,:)}; % tách tên từng cặp classpair
                       
            clear temp_cm cm
            
            temp_cm=extract.(char(method(j))).(char(CASE(a)))...
                .(char(temp_classpair(:,i))).cfm_LDA; % lấy các hệ số trong confusion matrix
            
            subplot(4,3,count)
            
            cm=heatmap(xvalues,yvalues,temp_cm); % vẽ heatmap: theo từng pair và method
            
            % format lại hình ảnh
            if j==1 && i==1
                cm.Title = sprintf('%s - %s',temp_method...
                    ,temp_02_classpair);
                cm.XLabel = 'Actual';
                cm.YLabel = 'Predicted';
                %cm.ColorbarVisible = 'off';
            elseif i==1
                cm.Title = sprintf('%s - %s',temp_method...
                    ,temp_02_classpair);
                cm.ColorbarVisible = 'off';
            else
                cm.Title = sprintf('%s',temp_02_classpair);
                cm.ColorbarVisible = 'off';
            end
        end
    end
end

% saveas(gcf,[selpath,'\',idname,'\',idname,'_',char(temp_classpair(j)),...
% %                 '.bmp']);
