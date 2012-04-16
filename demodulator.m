function [ img ] = demodulator( file )
%DEMODULATOR Converts a .wav file in NOAA weather fax format to a JPEG.
%   Y = DEMODULATOR(F) reads in the .wav file specified by F and outputs an
%   8-bit grayscale JPEG image. F is expected to be a 16-bit, single
%   channel WAVE file sampled at 16 KHz in proper NOAA Weather Fax Format. 

%% Constants
WAV_FS = 16000; %Hz
WAV_NBITS = 16; %bits/sample
JPEG_NBITS = 8; %bits
JPEG_WIDTH = 800; %pixels

BLACK = 1500; %Hz
WHITE = 2300; %Hz

START_TIME = 5; %seconds
START_FREQ = 300; %Hz
STOP_TIME = 5; %seconds
STOP_FREQ = 450; %Hz

%% Read in .wav file
[signal, fs, ~] = wavread(file);
%% Time Domain Plot
figure(1)
t = 1/fs.*(0 : length(signal)-1);
plot(t, signal')
xlabel('t seconds'); ylabel('signal')

%% Frequency Domain Plot
[f, y] = formattedFourier(t, 1./fs, signal);

figure(2)
plot(f, y);
xlabel('Frequency Hz'); ylabel('FFT signal')
end

function [f,Y] = formattedFourier(t, ts, func)
L = length(t);
NFFT = 2^nextpow2(L);
Y = 2* abs(fftshift(fft(func,NFFT)/length(t)));
f = (1/ts)/2*linspace(-1,1,NFFT);
end
