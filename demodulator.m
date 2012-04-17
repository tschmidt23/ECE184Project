function [ img ] = demodulator( wavFile, imgFile )
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

FFT_LEN = 256;

%% Read in .wav file
[signal, fs, ~] = wavread(wavFile);
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

len = length(signal);
img_pixels = len/10;
img_width = 800;
img_height = img_pixels/img_width;

f = (0:(FFT_LEN-1))*(WAV_FS/FFT_LEN);

img = zeros(img_width,img_height);

for i=1:img_height
    for j=1:img_width
        start_index = 10*((i-1)*img_width + (j-1) ) + 1;
        Y = fft(signal(start_index:start_index+9),FFT_LEN);
        freq = f(find(Y == max(Y(1:(FFT_LEN/2)))));
        color = (freq - BLACK)/(WHITE-BLACK);
        img(i,j) = color;
    end
end

imwrite(img,imgFile);

end

function [f,Y] = formattedFourier(t, ts, func)
L = length(t);
NFFT = 2^nextpow2(L);
Y = 2* abs(fftshift(fft(func,NFFT)/length(t)));
f = (1/ts)/2*linspace(-1,1,NFFT);
end
