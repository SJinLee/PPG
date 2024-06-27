%%
% https://hasri.co.kr/28 : feature 설명
clear all
load('Geonu ppg_0529.mat')

%%
x_org = data(1:end);
y_filtered = myfilter(x_org);

[pks,locs,w,p] = findpeaks(y_filtered);

peak_locs = locs(pks>500);
peak_vals = pks(pks>500);

[xx_hrv,yy_hrv,RR_locs,RR] = getHRV(peak_locs);

%% plot spline
plot(xx_hrv,yy_hrv);
hold on;
scatter(RR_locs,RR,'o')
hold off;

%%
fs = 1000;
minutes = length(yy_hrv)/fs/60;
wminutes = 5;
LFseq = zeros(length(0:minutes-wminutes),1);
HFseq = zeros(length(0:minutes-wminutes),1);
for m = 0:minutes-5
    x = yy_hrv(m*fs*60+1:(m+wminutes)*fs*60);
    if length(x)<fs*60*wminutes
        x = vertcat(x,zeros(1,fs*wminutes*60-length(x)));
    end
    w = hanning(length(x));
    %w = ones(1,length(x));
    y = fft(x.*w');
    my = abs(y).^2;
    NumUniquePts = length(my)/2+1;
    my = my(1:NumUniquePts);
    my(2:end-1) = my(2:end-1)*2;
    Pxx1 = my/fs/(w'*w);
    Fx1 = (0:NumUniquePts-1)*fs/length(y); % 0~fs Hz ($Y_k = \int_0^1 f(t)e^{-jtk} dt$이므로 $t=1$이 wminutes분을 의미함)
    startLF = 0.04*fs*wminutes*60/fs;
    endLF = 0.15*fs*wminutes*60/fs;
    endHF = 0.4*fs*wminutes*60/fs;
    LF = sum((Pxx1(startLF:endLF-1)+Pxx1(startLF+1:endLF))/2) / fs;
    HF = sum((Pxx1(endLF:endHF-1)+Pxx1(endLF+1:endHF))/2) / fs;
    LFseq(m+1) = LF;
    HFseq(m+1) = HF;
    % break
end
LFHFratio = LFseq./HFseq;
[LFseq HFseq LFHFratio]
%%
figure;
plot(Fx1(startLF:endHF),Pxx1(startLF:endHF))
hold on;
xline(0.15);
hold off;
xlim([0.04,0.4])

%%
figure;
[Pxx2,Fx2] = pwelch(x,w,0,length(x),fs);
plot(Fx1(startLF:endHF),Pxx1(startLF:endHF))
hold on;
plot(Fx2(startLF:endHF),Pxx2(startLF:endHF))
xline(0.15);
hold off;
xlim([0.04,0.4])
Pxx1(12:22)
Pxx2(12:22)'
