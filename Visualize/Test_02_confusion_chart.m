clearvars -except CASE DFBCSP_Fisher DFBCSP_FmRmR DFBCSP_mRmR FBCSP filename idname method path
%% Check folder
% check = dir(fullfile(path, 'ConfusionChart'));
% if isempty(check)
%     mkdir([path,'ConfusionChart']);
% else
% end
% selpath=[path,'ConfusionChart','\'];
% clear check
% 
% check = dir(fullfile(selpath,idname));
% if isempty(check)
%     mkdir([selpath,idname]);
% else
% end
% clear check
%% Run 'InputData' first
extract.FBCSP=FBCSP;
extract.DFBCSP_Fisher=DFBCSP_Fisher;
extract.DFBCSP_mRmR=DFBCSP_mRmR;
extract.DFBCSP_FmRmR=DFBCSP_FmRmR;

test_CASE=char(CASE(1));
if idname(1)=='['
    CASE=CASE(end); 
end

for e=1:length(fieldnames(extract))
    for i=1:length(CASE)
        temp_classpair={'LH_RH','RH_F','F_LH'};
        len_classpair=length(temp_classpair);
        for j=1:len_classpair
            temp_02_classpair=strrep(char(temp_classpair(j)),'_',' & ');
            if idname(1)=='['
                temp_CASE=char(CASE(i));
            else
                temp_CASE=strrep(char(CASE(i)),'_',' ');
            end
            temp_method=strrep(char(method(e)),'_',' #');
            
            classlabels=split(temp_classpair(j),'_');
            classlabels=char(classlabels);
            
            figure('Name',sprintf('Subject %s: %s, Feature extraction %s'...
                ,idname,temp_CASE,temp_method));
            set(gcf,'WindowState','maximized')
            
            cm=confusionchart(extract.(char(method(e))).(char(CASE(i))).(char(temp_classpair(:,j))).cfm_LDA,...
                classlabels)
            cm.Title = sprintf('Subject %s - %s - method: %s: Pair %s',...
            idname,temp_CASE,temp_method,temp_02_classpair);
            cm.RowSummary = 'row-normalized';
            cm.ColumnSummary = 'column-normalized';
            
%             saveas(gcf,[selpath,'\',idname,'\',char(method(e)),'-',char(CASE(i)),'-',...
%                 char(temp_classpair(j)),'.png']);
                
        end
    end
end