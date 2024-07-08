%% read data
%https://www.kaggle.com/code/chtalhaanwar/code-to-start
data = readlines('data/data.csv');
row = strsplit(data(1),",");
idname = row(1);
labelname = row(2);
index = str2double(row(3:end));
for i=length(data):-1:2
    if data(i)==""
        data(i) = [];
    end
end
data(1) = [];
%% convert data to struct
ppgs = struct;
for i=1:length(data)
    row = strsplit(data(i),",");
    ppgs(i).subject_id = row(1);
    ppgs(i).label = row(2);
    ppgs(i).seq = str2double(row(3:end));
end
%% plot
fs = 1000;
i = 1;
x = ppgs(i).seq;
ppgs(i).label
t = cumsum(x(1:end-1)) - x(1);
x = x(1:end-1);
plot(t/fs,x)
i = 28;
x = ppgs(i).seq;
ppgs(i).label
t = cumsum(x(1:end-1)) - x(1);
x = x(1:end-1);
hold on;
plot(t/fs,x)
hold off;
legend('baseline','stressed')
%% Remove Outliers
fs = 1000;
i = 1;
x = ppgs(i).seq;
x = x(1:end-1);
x(x>1000|x<600) = median(x);
t = cumsum(x) - x(1);
plot(t/fs,x)
i = 28;
x = ppgs(i).seq;
x = x(1:end-1);
x(x>1000|x<600) = median(x);
t = cumsum(x) - x(1);
hold on;
plot(t/fs,x)
hold off;
legend('baseline','stressed')
%% spline
i = 1;
x = ppgs(i).seq;
x = x(1:end-1);
x(x>1000|x<600) = median(x);
t = cumsum(x) - x(1);
tt = 0:t(end);
xx = spline(t,x,tt);
plot(t,x)
hold on;
plot(tt,xx)
hold off;
%% power spectrum
w = hanning(length(xx));
%w = ones(1,length(xx));
[Pxx2,Fx2] = pwelch(xx,w,0,length(xx),fs);
plot(Fx2,Pxx2);
hold on;
xline(0.15);
hold off;
xlim([0.04,0.4]);
%%
idx = (Fx2>=0.04) & (Fx2<0.15);
LF = trapz(Fx2(idx),Pxx2(idx));
idx = (Fx2>=0.15) & (Fx2<0.4);
HF = trapz(Fx2(idx),Pxx2(idx));
[LF HF LF/HF]

%% loop
fs = 1000;
features = [];
for i = 1:length(ppgs)
    % spline
    x = ppgs(i).seq;
    x = x(1:end-1);
    x(x>1000|x<600) = median(x);
    t = cumsum(x) - x(1);
    tt = 0:t(end);
    xx = spline(t,x,tt);
    w = hanning(length(xx));
    [Pxx2,Fx2] = pwelch(xx,w,0,length(xx),fs);
    idx = (Fx2>=0.04) & (Fx2<0.15);
    LF = trapz(Fx2(idx),Pxx2(idx));
    idx = (Fx2>=0.15) & (Fx2<0.4);
    HF = trapz(Fx2(idx),Pxx2(idx));
    features = [features; LF HF LF/HF];
end
labels = [];
for i = 1:length(ppgs)
    labels = [labels; ppgs(i).label=='stress'];
end
%% train test split
cv = cvpartition(size(features,1),'HoldOut',0.3);
idx = cv.test;
% Separate to training and test data
featureTrain = features(~idx,:);
featureTest = features(idx,:);
labelTrain = labels(~idx,:);
labelTest = labels(idx,:);
%% 배깅 결정 트리의 앙상블
nTrees=50;
B = TreeBagger(nTrees,featureTrain,labelTrain, 'Method', 'classification'); 
predChar1 = B.predict(featureTest);  % Predictions is a char though. We want it to be a number.
c = str2double(predChar1);
consistency=sum(c==labelTest)/length(labelTest);
res = [c labelTest]
%% SVC
Mdl = fitckernel(featureTrain,labelTrain,'IterationLimit',5,'Verbose',1);
label = predict(Mdl,featureTest);
ConfusionTest = confusionchart(labelTest,label);
%% Loss
L = loss(Mdl,featureTest,labelTest)
UpdatedMdl = resume(Mdl,featureTrain,labelTrain);
%% update
UpdatedLabel = predict(UpdatedMdl,featureTest);
UpdatedConfusionTest = confusionchart(labelTest,UpdatedLabel);
sum(UpdatedLabel==labelTest)/length(labelTest);
