main('C:\Users\tomer\Documents\test folders')

%%

final_ET_feat_train = create_ET_best_feat_set(ET_train_set, labels_tags);
final_ET_feat_test = create_ET_best_feat_set(ET_test_set, labels_tags);

final_all_feat = cat(1,final_ET_feat_train,final_ET_feat_test);
%%
options = statset('Display', 'iter', 'UseParallel', true);  % UseParallel to speed up the computations and Display so we can see the progress
template = templateTree('MaxNumSplits', 40, 'MinLeafSize', 10);                % define the trees to use in the ensemble model

%SFS- using loss function as criteria
fun = @(Xtrain,Ytrain,Xtest,Ytest)loss(fitcensemble(Xtrain, Ytrain, 'Method', 'RUSBoost', 'Learners', template), Xtest, Ytest);

% compute ET SFS
[Indx_ET, history_ET] = sequentialfs(fun, final_ET_feat_train(:,1:end-1), final_ET_feat_train(:,end), 'options', options);
save('mat files/sfs_ET_from_best','Indx_ET', 'history_ET')


%% ###### put the optimal hyperparameters ######
trees_ET = templateTree('MaxNumSplits', 150, 'MinLeafSize', 30);
num_trees_ET = 80;
Boosted_Tree_ET = fitcensemble(final_ET_feat_train(:,1:end - 1), final_ET_feat_train(:,end),'Method','RUSBoost', ...
'NumLearningCycles',num_trees_ET,'Learners',trees_ET,'NPrint',10);

predictions = predict(Boosted_Tree_ET, final_ET_feat_test(:,1:end - 1));
table = confusionmat(final_ET_feat_test(:,end), predictions, 'order',[12 22 3 4 5 6 11 21 0]);
figure('Name','test');
confusionchart(table,[12 22 3 4 5 6 11 21 0]);

predictions = predict(Boosted_Tree_ET, final_ET_feat_train(:,1:end - 1));
table = confusionmat(final_ET_feat_train(:,end), predictions, 'order',[12 22 3 4 5 6 11 21 0]);
figure('Name','train');
confusionchart(table,[12 22 3 4 5 6 11 21 0]);