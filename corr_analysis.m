function [feat_feat_corr_under_0_7,feat_feat_corr,feat_label_corr,best_feat_feat...
    best_feat_label]=corr_analysis(feat_label_mat,feat_names)
    best_feat_label={};
    best_feat_feat={};
    %Slice the data to make it comfortable to work with
    label_vec=feat_label_mat(:,end);                                      %Separate the Labels from matrix
    feat_mat=feat_label_mat(:,1:end-1);                                   %Separate Features from labels
    %Compute correlation
    feat_label_corr=corr(feat_mat,label_vec,'type','Spearman');           %Features-Labels correlation
    feat_feat_corr=corr(feat_mat,feat_mat,'type','Spearman');             %Features-Features correlation
    feat_feat_corr_under_0_7=sum(sum(abs(feat_feat_corr)<0.7))/2;         %Counts number of correlation under 0.7
    gplotmatrix(feat_mat,[],label_vec');                                  %gplot
    best_feat_label{1}=max(abs(feat_label_corr));
    best_feat_label{2}=find(feat_label_corr==max(abs(feat_label_corr)));
    best_feat_label{3}=feat_names(best_feat_label{2});
    [M,I] = min(abs(feat_feat_corr),[],'all');
    index1=floor(I/size(feat_feat_corr,2));
    if mod(I,size(feat_feat_corr,2))==0
        index2=size(feat_feat_corr,2);
    else
        index2=mod(I,size(feat_feat_corr,2));
    end
    best_feat_feat{1}=M;
    best_feat_feat{2}=[index1,index2];
    best_feat_feat{3}=[feat_names{index1},feat_names{index2}];