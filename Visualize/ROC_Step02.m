clearvars -except CASE listname method path len_classpair class_pair len Full_labels Full_score posclass
%% Chạy ROC để lấy 2 giá trị X và Y của từng: 16 subject - 4 method - 2 classpair
posclass='1'; % positive class for ROC
for k=1:len_classpair
    for i=1:length(method)
        for j=1:len
            temp_score=Full_score.(char(listname(j))).(char(class_pair(k)))...
                .(char(method(i)));
            temp_labels=Full_labels.(char(listname(j))).(char(class_pair(k)))...
                .(char(method(i)));
            % Chạy ROC cho từng đối tượng
            [X,Y,~,AUC]=perfcurve(temp_labels,temp_score,posclass);
            temp_len_X(j)=length(X);
            all_X.(char(class_pair(k))).(char(method(i))).(char(listname(j)))=X; 
            all_Y.(char(class_pair(k))).(char(method(i))).(char(listname(j)))=Y;
            all_AUC.(char(class_pair(k))).(char(method(i)))(j)=AUC;
            clear temp_score temp_labels X Y AUC
        end
        max_X.(char(class_pair(k)))(i)=max(temp_len_X);
        temp_max_X=max(temp_len_X);
        intervals.(char(class_pair(k))).(char(method(i)))= linspace(0, 1, temp_max_X);
        inter=intervals.(char(class_pair(k))).(char(method(i)));
        for j=1:len
            X=all_X.(char(class_pair(k))).(char(method(i))).(char(listname(j)));
            Y=all_Y.(char(class_pair(k))).(char(method(i))).(char(listname(j)));
            if length(X)<temp_max_X;
                % Lấy các điểm khác biệt nhau trong giá trị X
                X=adjust_unique_points(X);
                % Hồi quy các giá trị X của 16 subject theo chiều dài dài nhất
                V.(char(class_pair(k))).(char(method(i)))(:,j)=interp1(X, Y, inter);
            else
                V.(char(class_pair(k))).(char(method(i)))(:,j)=Y;
            end
            clear temp_len_X X Y
        end
    end
end
