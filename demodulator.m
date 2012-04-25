function [ img ] = demodulator( wavFile, imgFile )
%DEMODULATOR Converts a .wav file in NOAA weather fax format to a JPEG.
%   Y = DEMODULATOR(F) reads in the .wav file specified by F and outputs an
%   8-bit grayscale JPEG image. F is expected to be a 16-bit, single
%   channel WAVE file sampled at 16 KHz in proper NOAA Weather Fax Format. 

%% Constants
WAV_FS = 16000; %Hz
WAV_NBITS = 16; %bits/sample
JPEG_NBITS = 8; %bits
IMG_WIDTH = 800; %pixels
SAMP_PIX = 10; %samples / pixel

BLACK = 1500; %Hz
WHITE = 2300; %Hz

START_TIME = 5; %seconds
START_FREQ = 300; %Hz
STOP_TIME = 5; %seconds
STOP_FREQ = 450; %Hz

FFT_LEN = 256;

SKIP_SAMPLES = 880000;

%% Functions
w = hamming(10);

%% Read in .wav file
[signal, fs, ~] = wavread(wavFile);

%% Extract pixel data between start and stop signals
signal_start = start_detector(signal)
signal_stop = signal_start+SKIP_SAMPLES + ...
    stop_detector(signal(signal_start+SKIP_SAMPLES:length(signal)))
signal = signal(signal_start:signal_stop);

%% Demodulate the image data
len = length(signal);
img_pixels = len/SAMP_PIX;
img_height = img_pixels/IMG_WIDTH;

% range of frequencies in the FFT
f = (0:(FFT_LEN-1))*(WAV_FS/FFT_LEN);

img = zeros(IMG_WIDTH, img_height);

% extract a pixel at a time using fft of 10 samples and the hamming window
for i=1:img_height
    for j=1:IMG_WIDTH
        start_index = SAMP_PIX*((i-1)*IMG_WIDTH + (j-1) ) + 1;
        chunk = signal(start_index:start_index + SAMP_PIX - 1).*w;
        Y = fft(chunk,FFT_LEN);
        freq = f(Y == max(Y(1:(FFT_LEN/2))));
        color = min((freq - BLACK)/(WHITE-BLACK),1);
        img(i,j) = color;
    end
end

imwrite(img,imgFile);

end

