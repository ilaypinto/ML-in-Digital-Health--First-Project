function CFS=calculate_CFS(rcf,rff,feature_ind)

%  Procedure to calculate correlation feature selection. This parameter
%  actually take into consideration both feature/feature correlation and
%  feature/label correlation within its value and it can be used as
%  feature selection criterion.
%
%  Input :    rcf - vector correlations between the features that are part of the subset and label (use abs values!)
%             rff - matrix correlation between features in the subset and the other features in this subset (use abs values!)
%             feature_ind - vector of feature indexes we want to calculate
%             their CSF value
% 
%  Output :   CFS - correlation for feature selection values for each
%  feature

partial_rcf=abs(rcf(feature_ind));
partial_rff=abs(rff(feature_ind,feature_ind));
CFS=sum(partial_rcf)/sqrt(sum(sum(partial_rff)));
