clearvars -except CASE listname method path FullData class_pair
%% Run 'Input_FullData' first - this code just use for author dataset

%% Take data
posclass='1';%take calss 1 to draw
len=length(listname);
for k=1:len
    clear extract
    % variable tạm để chứa dữ liệu => phân theo method
    extract.FBCSP=FullData.(char(listname(k))).FBCSP;
    extract.DFBCSP_Fisher=FullData.(char(listname(k))).DFBCSP_Fisher;
    extract.DFBCSP_mRmR=FullData.(char(listname(k))).DFBCSP_mRmR;
    extract.DFBCSP_FmRmR=FullData.(char(listname(k))).DFBCSP_FmRmR;

    temp_classpair=class_pair;
    len_classpair=length(temp_classpair);

    for j=1:len_classpair

        for e=1:length(method)
            
%             tách labels và score thành 2 variable theo cấp phân lớp:
%             tên subject - classpair - method
            Full_labels.(char(listname(k))).(char(temp_classpair(:,j)))...
                .(char(method(e)))=extract.(char(method(e)))...
                .(char(CASE.(char(listname(k)))(end))).(char(temp_classpair(:,j))).ROC(:,3);
            Full_score.(char(listname(k))).(char(temp_classpair(:,j)))...
                .(char(method(e)))=extract.(char(method(e)))...
                .(char(CASE.(char(listname(k)))(end))).(char(temp_classpair(:,j))).ROC(:,1);
        end
           
    end
end