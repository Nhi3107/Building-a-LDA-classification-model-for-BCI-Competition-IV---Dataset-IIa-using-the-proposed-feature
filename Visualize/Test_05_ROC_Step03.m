clearvars -except path listname method class_pair len intervals V all_AUC
%% Plot ROC curve
FigureName= sprintf('ROC_for_all_subject');
set(gcf,'WindowState','maximized');
sub_color={'#77AC30','b','m','c'};
for k=1:length(class_pair)
    subplot(1,length(class_pair),k);
    hold on
    temp_classpair=strrep(char(class_pair(k)),'_',' & ');
    for i=1:length(method)
        % Tính giá trị trung bình của trục y -> true positive rate
        V_mean=mean(V.(char(class_pair(k))).(char(method(i)))');
        inter=intervals.(char(class_pair(k))).(char(method(i)));
        AUC=mean(all_AUC.(char(class_pair(k))).(char(method(i))));
        
        % Các thông số để vẽ
        temp_method=strrep(char(method(i)),'_',' - ');
        plot(inter,V_mean,'LineWidth',1.5,'Color',char(sub_color(i)));
        xlabel('False positive rate','Fontsize',18,'FontWeight','bold') ;
        ylabel('True positive rate','Fontsize',18,'FontWeight','bold');
%         ylim([0.4 1.00]);
        set(gca,'FontSize',14);
        legendInfo{i}=sprintf('%s with AUC = %f',temp_method,AUC);
        legend(legendInfo,'Location','southoutside','FontSize',14);
        axis square
       
    end
    title(sprintf('All subjects - all: Pair %s',temp_classpair));
    hold off
end