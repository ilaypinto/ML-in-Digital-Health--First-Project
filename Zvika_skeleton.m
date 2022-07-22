%% Demo Fisher's Iris
%%%%%%%%%%%%%%%%%%%%%%%%
load fisheriris.mat
% Explore features
figure
gplotmatrix(meas,[],species)

%% feature-feature correlation
rff_Pearson=corr(meas,'type','Pearson'); figure; heatmap(abs(rff_Pearson));title('Pearson correlation - Heatmap')
rff_Spearman=corr(meas,'type','Spearman');figure; heatmap(abs(rff_Spearman));title('Spearman correlation - Heatmap')

%% feature-label correlation
len=size(meas,2);
W=zeros(len,1);
for j=1:len
    [~,W(j)] = relieff(meas(:,j),species,10);
end
disp(['relieff weights are: ',num2str(W')])

%% 2-features-label exhaustic search
couples=logical(...
    [1,1,0,0;...
    1,0,1,0;...
    1,0,0,1;...
    0,1,1,0;...
    0,1,0,1;...
    0,0,1,1]);
len=size(couples,1);
W2=zeros(len,2);
for j=1:len
    [~,W2(j,:)] = relieff(meas(:,couples(j,:)),species,10);
end
disp(['relieff weights for couples are: '])
[couples,W2]

%% Use mutual information to test correlation and demo SFS
y=zeros(150,1);y(51:100)=1;y(101:150)=2;
len=size(meas,2);
d_meas=zeros(size(meas));
for r=1:len
    [d_meas(:,r),~]=discretize(meas(:,r),tsprctile(meas(:,r),[0,30,50,70,100]));
end
MI=zeros(len,1);
for r=1:len
    MI(r)=mutual_information2(d_meas(:,r),y);
    disp(['Mutual information of feature #',num2str(r),' = ',num2str(MI(r))])
end
[~,max_ind]=max(MI);
disp(['Maximum mutual information between feature #',num2str(max_ind),' with label'])
columns_indices=1:len;
columns_indices=setdiff(columns_indices,max_ind);
MI2=zeros(len-1,1);
for r=columns_indices
    MI2(r)=mutual_information2(d_meas(:,[max_ind,r]),y);
    disp(['Mutual information of feature #',num2str(max_ind),' with feature #',num2str(r),' = ',num2str(MI2(r))])
end
[~,second_feature_ind]=max(MI2);
best_indices=[max_ind,columns_indices(second_feature_ind)];

%% Partition the data for quality assessment
rng(10,'twister')         % For reproducibility
part = cvpartition(species,'Holdout',0.3);
disp(part)
istrain = training(part); % Data for fitting
istest = test(part);      % Data for quality assessment
tabulate(species(istrain))


%% Create the RandomForest ensemble
t = templateTree('MaxNumSplits',3,'NumVariablesToSample',1);
num_trees=35;
features=1:4;%[2,4];%1:4;
tic
bagTree = fitcensemble(meas(istrain,features),species(istrain),'Method','bag', ...
'NumLearningCycles',num_trees,'Learners',t,'nprint',10);
disp('Training time for RandomForest:')
toc

for r=1:5
    view(bagTree.Trained{r},'Mode','graph')
end


%% Calculate confusion matrix
tab=tabulate(species(istest));
disp(tab)
tic;
[Yfit_bag,score] = predict(bagTree,meas(istest,features));
disp('Prediction time for RandomForest prediction:');
toc
disp('Confusion matrix (percentage) with Random Forest:');
confusionmat(species(istest),Yfit_bag)

%% ROC
positive=3;
[x_ROC,y_ROC,threshold,AUC]=perfcurve(species(istest),score(:,positive),tab{positive});
disp(['AUC (ROC) : ',num2str(AUC)]);
figure;plot(x_ROC,y_ROC);line([0 1],[0 1],'color','r');xlim([0 1]);ylim([0 1])
xlabel('FPR');ylabel('TPR');title('ROC curve')

%% PRC
[x_PRC,y_PRC,threshold_PRC,AUC_PRC]=perfcurve(species(istest),score(:,positive),tab{positive},'XCrit','tpr','YCrit','ppv');
disp(['AUC (PRC) : ',num2str(AUC_PRC)]);
figure;plot(x_PRC,y_PRC);line([0 1],[tab{positive,2}/sum(istest) tab{positive,2}/sum(istest)],'color','r');xlim([0 1]);ylim([0 1])
xlabel('Recall');ylabel('Precision');title('PRC curve')

%% The Model you want to release to the world
bagTree_submit = fitcensemble(meas(:,features),species(:),'Method','bag', ...
'NumLearningCycles',num_trees,'Learners',t,'nprint',10);


%% How to select a working point??
% select a working point with maximum sensitivity on 'versicolor'
figure
[Yfit_bag,score] = predict(bagTree,meas(istrain,features));
plot(score)

[Yfit_bag,score] = predict(bagTree,meas(istest,features));
ind=find(score(:,2)>0.20);
Yfit_bag(ind)={'versicolor'};
confusionmat(species(istest),Yfit_bag)


%% How to select a working point
% select a working point with zero false alarms on 'virginica'
