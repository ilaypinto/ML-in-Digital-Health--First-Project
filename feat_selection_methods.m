%%Feature selection methods
%Try all, choose one for main!
%%
%%Filters%%
%
%%
%%CHI^2
idx_MW = fscchi2(features_MW(:,1:end-1),features_MW(:,end));
idx_ET = fscchi2(features_ET(:,1:end-1),features_ET(:,end));
chi_best_feat_MW=features_names{idx_MW(1:2)};
chi_best_feat_ET=features_names{idx_ET(1:2)};
%%
%Minimum redundancy maximum relevance
idx_MW = fscmrmr(features_MW(:,1:end-1),features_MW(:,end));
idx_ET = fscmrmr(features_ET(:,1:end-1),features_ET(:,end));
MRMR_best_feat_MW=features_names{idx_MW(1:2)};
MRMR_best_feat_ET=features_names{idx_ET(1:2)};
%%
%Laplacian score
idx_MW = fsulaplacian(features_MW(:,1:end-1));
idx_ET = fsulaplacian(features_ET(:,1:end-1));
Laplace_best_feat_MW=features_names{idx_MW(1:2)};
Laplace_best_feat_ET=features_names{idx_ET(1:2)};
%%
%ReliefF
idx_MW = relieff(features_MW(:,1:end-1),features_MW(:,end));
idx_ET = relieff(features_ET(:,1:end-1),features_ET(:,end));
reliefF_best_feat_MW=features_names{idx_MW(1:2)};
reliefF_best_feat_ET=features_names{idx_ET(1:2)};
%%
%%Wrappers%%
%%
%SFS- using loss function as criteria
[inmodel_MW,history_MW] = sequentialfs(fun,features_MW(:,1:end-1),features_MW(:,end));
[inmodel_ET,history_ET] = sequentialfs(fun,features_ET(:,1:end-1),features_ET(:,end));
fun = @(Xtrain,Ytrain,Xtest,Ytest)loss(fitcensemble(Xtrain,Ytrain,'AdaBoostM2'),Xtest,Ytest);