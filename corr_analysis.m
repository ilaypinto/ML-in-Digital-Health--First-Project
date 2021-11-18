function [feat_feat_corr_under_0_7,feat_feat_corr,feat_label_corr]=...
        corr_analysis(feat_label_mat)
    %Slice the data to make it comfortable to work with
    label_vec=feat_label_mat(:,end);                               %Separate the Labels from matrix
    feat_mat=feat_label_mat(:,1:end-1);                            %Separate Features from labels
    %Compute correlation
    feat_label_corr=corr(feat_mat,label_vec,'type','Spearman');    %Features-Labels correlation
    feat_feat_corr=corr(feat_mat,feat_mat,'type','Spearman');      %Features-Features correlation
    feat_feat_corr_under_0_7=sum(sum(abs(feat_feat_corr)<0.7))/2;  %Counts number of correlation under 0.7
    gplotmatrix(feat_mat,[],label_vec');                           %gplot
end