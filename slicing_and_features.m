%Hi Tomer! this is a message for you bro.
%I did some code, to integrate with what you did so far.
%I hope it can be helpful, this is basically a skeletal code for window
%slicing, feature extraction, correlation computing etc.
%Happy reading!
%Ilay
%%
%Slicing the Data
window_size=5;step=2;counter=0;sliced_signal=[];%Define parameters for
                                                %window and overlap.
for i=1:round(length(signal)/step)              
   if counter*step+window_size>length(signal)   %Stopping indices error.
       break
   end
   sliced_signal(i)=signal(counter*step+1:counter*step+window_size);
   counter=counter+1;
end
%%
%Feature Extraction
Mean= mean(sliced_signal);               %Mean value of window
Std= std(sliced_signal);                 %STD value of window
Ent = wentropy(sliced_signal,'shannon'); %Entropy of window
Ene= sum((abs(sliced_signal))^2);        %Energy of window
Var= var(sliced_signal);                 %Variance of window
Med= median(sliced_signal);              %Median for window
Min= min(sliced_signal);                 %Minimal value for window
Max= max(sliced_signal);                 %Maximal value for window
Range= range(sliced_signal);             %Range of window - same as min and max
zcd = dsp.ZeroCrossingDetector;
zero_cross= zcd(sliced_signal);          %Zero crossing of window
pos = sliced_signal>0;
changes = xor(pos(1:end-1),pos(2:end));
sign_change = sum(changes);              %Sign changes of window
Rms= rms(sliced_signal);                 %Root Mean Square of window
Band_p= bandpower(sliced_signal);        %Bandpower of window
Slew= slewrate(sliced_signal);           %Slewrate of window
Skew= skewness(sliced_signal);           %Skewness of window
Kurt= kurtosis(sliced_signal);           %Kurtosis of window
Iqr= iqr(sliced_signal);                 %IQR of window
Pxx= pwelch(sliced_signal);              %Welch’s power spectral density estimate

%There are some features missing which I didn't know how to implement.
[imf,residual] = emd(x); %Dont know how to use EMD yet but we'll figure it out.
%%
%Normalazing data
%We should consider how to normalize. In any case, a few methods:
%'zscore'(default),'norm', 'scale', 'range', 'center', 'medianiqr'
N = normalize(feature,method);

%%
%Creating the data matrix of all the features:
data=cat(Mean,Std,Ent,Ene,Var,Med,Min,Max,Range,zero_cross,sign_change,Rms,Band_p,Slew,Skew, ...
    Kurt,Iqr,Pxx);
data=cat(data,true_labels); %add the true labels of the windows.
%%
%Checking correlation between features
%Between features and labels:
corr_pearson_l=corr(data(1:end-1),data(end));                    %Pearson correlation
corr_kendall_l=corr(data(1:end-1),data(end),'type','Kendall');   %Kendall correlation
corr_spearman_l=corr(data(1:end-1),data(end),"type","Spearman"); %Spearman correlation

%Between features:
corr_pearson_f=corr(data(1:end-1),data(1:end-1));                    %Pearson correlation
corr_kendall_f=corr(data(1:end-1),data(1:end-1),'type','Kendall');   %Kendall correlation
corr_spearman_f=corr(data(1:end-1),data(1:end-1),"type","Spearman"); %Spearman correlation

%computing CFS using code from Tirgul 5(was added to our shared file):
CFS=calculate_CFS(rcf,rff,feature_ind);

%Heatmap for correlations?
%features and labels
figure(1);
subplot(3,1,1);heatmap(corr_pearson_l);
subplot(3,1,2);heatmap(corr_kendall_l);
subplot(3,1,3);heatmap(corr_spearman_l);
%features and features
figure(2);
subplot(3,1,1);heatmap(corr_pearson_f);
subplot(3,1,2);heatmap(corr_kendall_f);
subplot(3,1,3);heatmap(corr_spearman_f);

%%
%%gplotmatrix to see if each pair of features could separate the data
%gplotmatrix(X,Y,group)
%%
%Removing excess features
%After seeing both correlation values and the ability of the features to
%distinguish between labels, we should decide which features are thrown out!
data(row_num,:)=[];


