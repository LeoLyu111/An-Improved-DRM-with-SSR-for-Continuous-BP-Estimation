function [PPG] = filtering(PPG)
% load('BP001_20210315_M15_S5-10min.mat')
%  signal_start=1;
%  signal_end=200000;
%  x1=PPG
%  y=x1(signal_start:signal_end);
% % t=(signal_start:signal_end);
%  Fs=1000;
%  N=Fs;


 signal_start=1;
 signal_end=length(PPG);
 y=PPG(signal_start:signal_end);
 t=(signal_start:signal_end);
 Fs=125;
 N=Fs;

fmaxd_1=2;%cut off frequency 1Hz
fmaxn_1=fmaxd_1/(Fs/2);
[B,A]=butter(1,fmaxn_1,'low');
ppg_low=filtfilt(B,A,y);%low-pass filter
PPG=y-ppg_low; %delete the signal
end
