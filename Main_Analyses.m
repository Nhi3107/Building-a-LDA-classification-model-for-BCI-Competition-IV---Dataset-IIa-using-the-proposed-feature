clear; clc;
%% Load data
[FileName,Path]=uigetfile('*.mat');
RawData=load([Path,FileName]);
temp=split(FileName,'.');
DataName=char(temp(1));
fprintf('----------------Step 1: Loading raw data----------------\n');
fprintf('Load %s data \n',DataName);
%% Proccesing data
    % Time for 1 trial
t0=0; %a fixation cross appeared on the black screen, a short acoustic warning tone was presented
t1=2; t2=3.25; % a cue in the form of an arrow pointing
t3=3; t4=6; %motor imagery task until the fixation cross disappeared from the screen
t5=7; %A short break followed where the screen was black again
 
    % Process data
clear temp;
RawData=RawData.data(1,4:end); %take N run with N=length of rawData
        % Remove artifacts
for i=1:length(RawData) %length(RawData)= the number of RUN
    k=1;
    for j=1:length(RawData{1,i}.trial)
        if ~RawData{1,i}.artifacts(j) && RawData{1,i}.y(j)~=4
            if j ~= length(RawData{1,i}.trial)
                temp.rawdata{1,k}=RawData{1,i}.X(RawData{1,i}.trial(j):RawData{1,i}.trial(j+1)-1,:);
                temp.class(k)=RawData{1,i}.y(j);
                k=k+1;
            else
                temp.rawdata{1,k}=RawData{1,i}.X(RawData{1,i}.trial(j):end,:);
                temp.class(k)=RawData{1,i}.y(j);
            end
        end
    end
    if i==1
        data.rawdata=temp.rawdata;
        data.class=temp.class;
    else
        for j=1:length(temp.rawdata)
            data.rawdata{1,end+1}=temp.rawdata{1,j};
        end
        data.class(1,end+1:end+length(temp.class))=temp.class;
    end
    clear temp
end

data.label={'EEG-Fz';'EEG'...
        ;'EEG';'EEG';'EEG';'EEG';'EEG';'EEG-C3'...
        ;'EEG';'EEG-Cz';'EEG';'EEG-C4';'EEG';'EEG';'EEG'...
        ;'EEG';'EEG';'EEG';'EEG';'EEG-Pz';'EEG';'EEG'...
        ;'EOG-left';'EOG-central';'EOG-right'};
fs=RawData{1,1}.fs;
FOLD=10;
for i=1:3 %4 class
    count_each(i) = length(find(data.class==i));
end
clear temp;
fprintf('----------------Step 2: Processing raw data----------------\n');
fprintf('Done \n');


%% Classification
fprintf('----------------Step 3: Classfication----------------\n');
for i=1:length(data.rawdata)
    data_3class{i,1} = eeg_filter(data.rawdata{1,i}(t3*fs:t4*fs,1:end-3), fs, [8 14]);   % data (N_channels x Sample)
    data_3class{i,1}=data_3class{i,1}';
    label_3class(i,1) =  data.class(i)';
end
fprintf('Filter Done\n');
    %% one vs one 
fprintf('xxxxxxxxxxxxx ONE VS ONE xxxxxxxxxxxxx\n');
class_pair=[1 2; 2 3 ; 1 3]; %LH(1)-RH(2)-F(3)
classpair_name = {'LH-RH','RH-F','F-LH'};
fprintf('Binary Classification (%d fold-cross validation)\n',FOLD);%FOLD=10
for i=1:size(class_pair,1)%size(class_pair,1)=6

    clear classify_data label CV epoch_train epoch_test label_train label_test x_train x_test

    temp = find(label_3class==class_pair(i,1) | label_3class==class_pair(i,2));%Find: Find indices and values of nonzero elements, |: OR => take LH or RH (i=1) / RH or F (i=2)/ LH or F (i=3) 
    classify_data= data_3class(temp);
    label = label_3class(temp) ;
    label(find(label==class_pair(i,1)))=1;
    label(find(label==class_pair(i,2)))=2;
    classpair_varname=strrep(char(classpair_name(i)),'-','_');
    

    CV= cvpartition(label,'Kfold',FOLD); %Data partitions for cross validation
    cfm_LDA=[0 0; 0 0];
    rank_feature=[];
    acc=[];
    ROC_result=[];
    fprintf('[%s] LDA ',classpair_name{i}); 
    for fold=1:CV.NumTestSets
        tic

       epoch_train = classify_data(CV.training(fold)==1,:)';  
       epoch_test = classify_data(CV.test(fold)==1,:)'; 
       y_train = label(CV.training(fold)==1);
       y_test = label(CV.test(fold)==1);

        %% CSP
       trainParams.m = 3; % 2m <= channels
       [WCSP, x_train, x_test] = CSP_training(epoch_train, y_train, epoch_test, trainParams);
       band_selected(fold)={'None'};
       SaveFileName='CSP';

       %% FBCSP 
%        params.bands=[4 8; 6 10; 8 12; 10 14; 12 16; 14 18; 16 20; 18 22];
%             %20 24; 22 26; 24 28; 26 30; 28 32; 30 34; 32 36; 34 38; 36 40];
%        params.fs=fs;
%        params.m = 3;
%        [x_train, x_test]=FBCSP_training(epoch_train, y_train, epoch_test, params);
%        band_selected(fold)={'None'};
%        SaveFileName='FBCSP';

       %% DFBCSP Fisher
%        params.bands=[4 8; 6 10; 8 12; 10 14; 12 16; 14 18; 16 20; 18 22; ...
%               20 24; 22 26; 24 28; 26 30; 28 32; 30 34; 32 36; 34 38; 36 40];
%        params.fs=fs;
%        params.m = 3;
%        [x_train, x_test, bands_selected] = DFBCSP_training_Fisher(epoch_train, y_train, epoch_test, params);
%        band_selected(fold)={bands_selected};
%        SaveFileName='DFBCSP_Fisher';
        
       %% DFBCSP mRmR
%        params.bands=[4 8; 6 10; 8 12; 10 14; 12 16; 14 18; 16 20; 18 22; ...
%               20 24; 22 26; 24 28; 26 30; 28 32; 30 34; 32 36; 34 38; 36 40];
%        params.fs=fs;
%        params.m = 3;
%        [x_train, x_test, bands_selected] = DFBCSP_training_mRmR(epoch_train, y_train, epoch_test, params);
%        band_selected(fold)={bands_selected};
%        SaveFileName='DFBCSP_mRmR';

       %% DFBCSP FmRmR
%        params.bands=[4 8; 6 10; 8 12; 10 14; 12 16; 14 18; 16 20; 18 22; ...
%               20 24; 22 26; 24 28; 26 30; 28 32; 30 34; 32 36; 34 38; 36 40];
%        params.fs=fs;
%        params.m = 3;
%        params.num_selected_band = 6;
%        [x_train, x_test, bands_selected] = DFBCSP_training_FmRmR(epoch_train, y_train, epoch_test, params);
%        band_selected(fold)={bands_selected};
%        SaveFileName='DFBCSP_FmRmR';

       %% Classification
        model = fitcdiscr(x_train,y_train);
        [y_predicted,score] = predict(model, x_test);
        TP = sum((y_predicted==1) & (y_test == 1));
        FP = sum((y_predicted==1) & (y_test == 2)); 
        FN = sum((y_predicted==2) & (y_test == 1)); 
        TN = sum((y_predicted==2) & (y_test == 2)); 
        cfm = [TP FP; FN TN]; 
        cfm_LDA = cfm_LDA + cfm; 

        
        cfm_result(fold)={cfm}; 
        miniTime(fold)={toc};
        varName(fold)=cellstr(sprintf('FOLD %d',fold));
        ROC_result(end+1:end+length(score),1:3)=[score, y_test];

    end
    result.cfm{i}=cfm_LDA;
    %accuracy
    acc_cfm = 100*trace(cfm_LDA)/sum(cfm_LDA(:));%acc of LDA, 1 fold ra 1 confusion matrix => qua 5 fold (5 confusion matrix=> cộng lại TN và TP) mới tính acc
    %Kappa Coefficients
    p0=acc_cfm/100; % độ chính xác
    pa=sum(cfm_LDA(1,:))/sum(cfm_LDA(:)); %Right in predict
    pb=sum(cfm_LDA(:,1))/sum(cfm_LDA(:)); %Right in test
    pe=(pa*pb)+((1-pa)*(1-pb)); % tổng xác suất right và xác suất fall
    k= (p0-pe)/(1-pe);
    %F1-score
    precision=cfm_LDA(1,1)/sum(cfm_LDA(1,:));
    recall=cfm_LDA(1,1)/sum(cfm_LDA(:,1));
    F1=(2 * precision * recall) / (precision + recall);
    %display
    fprintf('accuracy= %.1f; ',acc_cfm);
    fprintf('kappa= %.4f ',k);
    fprintf('F1-score= %.4f \n',F1);
    disp(cfm_LDA);
    
    %Save the result
    table=cell2table([miniTime; cfm_result; band_selected],'VariableNames',varName','RowNames',{'Time','cfm','Band selected'});
    final_result.One_vs_One.(classpair_varname).ROC=ROC_result;
    final_result.One_vs_One.(classpair_varname).cfm_LDA=cfm_LDA;
    final_result.One_vs_One.(classpair_varname).acc=round(acc_cfm,2);
    final_result.One_vs_One.(classpair_varname).kappa=round(k,2);
    final_result.One_vs_One.(classpair_varname).F1=round(F1,2);
    final_result.One_vs_One.(classpair_varname).Table=table;

end

clear classpair_name class_pair
    %% one vs all
fprintf('xxxxxxxxxxxxx ONE VS ALL xxxxxxxxxxxxx\n');
class_pair=[1 5;2 5;3 5]; %LH(1)-RH(2)-F(3)-All(5)
classpair_name = {'LH-All','RH-All','F-All'};
fprintf('Binary Classification (%d fold-cross validation)\n',FOLD);%FOLD=10
for i=1:size(class_pair,1)

    clear classify_data label CV epoch_train epoch_test label_train label_test x_train x_test y_train y_test model y_predicted score ROC_result

    classify_data = data_3class;
    label = label_3class ;
    label(find(label~=class_pair(i,1)))=5;
    label(find(label==class_pair(i,1)))=1;
    label(find(label==5))=2;
    classpair_varname=strrep(char(classpair_name(i)),'-','_');


    CV= cvpartition(label,'Kfold',FOLD); %Data partitions for cross validation
    cfm_LDA=[0 0; 0 0];
    rank_feature=[];
    acc=[];
    ROC_result=[];
    fprintf('[%s] LDA ',classpair_name{i}); 
    for fold=1:CV.NumTestSets

       epoch_train = classify_data(CV.training(fold)==1,:)';  
       epoch_test = classify_data(CV.test(fold)==1,:)'; 
       y_train = label(CV.training(fold)==1);
       y_test = label(CV.test(fold)==1);

        %% CSP
       trainParams.m = 3; % 2m <= channels
       [WCSP, x_train, x_test] = CSP_training(epoch_train, y_train, epoch_test, trainParams);
       band_selected(fold)={'None'};
       SaveFileName='CSP';

       %% FBCSP 
%        params.bands=[4 8; 6 10; 8 12; 10 14; 12 16; 14 18; 16 20; 18 22];
%             %20 24; 22 26; 24 28; 26 30; 28 32; 30 34; 32 36; 34 38; 36 40];
%        params.fs=fs;
%        params.m = 3;
%        [x_train, x_test]=FBCSP_training(epoch_train, y_train, epoch_test, params);
%        band_selected(fold)={'None'};
%        SaveFileName='FBCSP';

       %% DFBCSP Fisher
%        params.bands=[4 8; 6 10; 8 12; 10 14; 12 16; 14 18; 16 20; 18 22; ...
%               20 24; 22 26; 24 28; 26 30; 28 32; 30 34; 32 36; 34 38; 36 40];
%        params.fs=fs;
%        params.m = 3;
%        [x_train, x_test, bands_selected] = DFBCSP_training_Fisher(epoch_train, y_train, epoch_test, params);
%        band_selected(fold)={bands_selected};
%        SaveFileName='DFBCSP_Fisher';
        
       %% DFBCSP mRmR
%        params.bands=[4 8; 6 10; 8 12; 10 14; 12 16; 14 18; 16 20; 18 22; ...
%               20 24; 22 26; 24 28; 26 30; 28 32; 30 34; 32 36; 34 38; 36 40];
%        params.fs=fs;
%        params.m = 3;
%        [x_train, x_test, bands_selected] = DFBCSP_training_mRmR(epoch_train, y_train, epoch_test, params);
%        band_selected(fold)={bands_selected};
%        SaveFileName='DFBCSP_mRmR';

       %% DFBCSP FmRmR
%        params.bands=[4 8; 6 10; 8 12; 10 14; 12 16; 14 18; 16 20; 18 22; ...
%               20 24; 22 26; 24 28; 26 30; 28 32; 30 34; 32 36; 34 38; 36 40];
%        params.fs=fs;
%        params.m = 3;
%        params.num_selected_band = 6;
%        [x_train, x_test, bands_selected] = DFBCSP_training_FmRmR(epoch_train, y_train, epoch_test, params);
%        band_selected(fold)={bands_selected};
%        SaveFileName='DFBCSP_FmRmR';

       %% Classification
        model = fitcdiscr(x_train,y_train);
        [y_predicted,score] = predict(model, x_test);
        TP = sum((y_predicted==1) & (y_test == 1));
        FP = sum((y_predicted==1) & (y_test == 2)); 
        FN = sum((y_predicted==2) & (y_test == 1)); 
        TN = sum((y_predicted==2) & (y_test == 2)); 
        cfm = [TP FP; FN TN]; 
        cfm_LDA = cfm_LDA + cfm; 
        
        
        cfm_result(fold)={cfm};
        miniTime(fold)={toc};
        varName(fold)=cellstr(sprintf('FOLD %d',fold));
        ROC_result(end+1:end+length(score),1:3)=[score, y_test];

    end
    result.cfm{i}=cfm_LDA;
    %accuracy
    acc_cfm = 100*trace(cfm_LDA)/sum(cfm_LDA(:));%acc of LDA, 1 fold ra 1 confusion matrix => qua 5 fold (5 confusion matrix=> cộng lại TN và TP) mới tính acc
    %Kappa Coefficients
    p0=acc_cfm/100; % độ chính xác
    pa=sum(cfm_LDA(1,:))/sum(cfm_LDA(:)); %Right in predict
    pb=sum(cfm_LDA(:,1))/sum(cfm_LDA(:)); %Right in test
    pe=(pa*pb)+((1-pa)*(1-pb)); % tổng xác suất right và xác suất fall
    k= (p0-pe)/(1-pe);
    %F1-score
    precision=cfm_LDA(1,1)/sum(cfm_LDA(1,:));
    recall=cfm_LDA(1,1)/sum(cfm_LDA(:,1));
    F1=(2 * precision * recall) / (precision + recall);
    %display
    fprintf('accuracy= %.1f; ',acc_cfm);
    fprintf('kappa= %.4f ',k);
    fprintf('F1-score= %.4f \n',F1);
    disp(cfm_LDA);
    
    %Save the result
    table=cell2table([miniTime; cfm_result; band_selected],...
        'VariableNames',varName','RowNames',{'Time','cfm','Band selected'});
    final_result.One_vs_All.(classpair_varname).ROC=ROC_result;
    final_result.One_vs_All.(classpair_varname).cfm_LDA=cfm_LDA;
    final_result.One_vs_All.(classpair_varname).acc=round(acc_cfm,2);
    final_result.One_vs_All.(classpair_varname).kappa=round(k,2);
    final_result.One_vs_All.(classpair_varname).F1=round(F1,2);
    final_result.One_vs_All.(classpair_varname).Table=table;
end

%% Save File
eval(sprintf('%s=final_result',SaveFileName));
Files_check_final = dir(fullfile([Path], sprintf('final_result_%s',FileName)));
if isempty(Files_check_final)
    save([Path,'\',sprintf('final_result_%s',FileName)],SaveFileName);
else
    save([Path,'\',sprintf('final_result_%s',FileName)],SaveFileName,'-append');
end
