function demodulator( wavFile, imgFile )
%DEMODULATOR Converts a .wav file in NOAA weather fax format to a JPEG.
%   DEMODULATOR(IN,OUT) reads in the .wav file specified by IN and outputs
%   an 8-bit grayscale JPEG image to the file OUT. IN is expected to be a
%   16-bit, single channel WAVE file sampled at 16KHz in proper NOAA
%   Weather Fax Format.
%
%   See also MODULATOR, START_DETECTOR, STOP_DETECTOR

%% Constants
WAV_FS = 16000; %Hz
IMG_WIDTH = 800; %pixels
SAMP_PIX = 10; %samples / pixel

BLACK = 1500; %Hz
WHITE = 2300; %Hz

FFT_LEN = 256;

SKIP_SAMPLES = 880000;

%% Read in .wav file
[signal, ~, ~] = wavread(wavFile);

%% Extract pixel data between start and stop signals
signal_start = start_detector(signal);
signal_stop = signal_start + SKIP_SAMPLES + ...
    stop_detector(signal( signal_start + SKIP_SAMPLES : length(signal)));
signal = signal(signal_start : signal_stop);

%% Demodulate the image data
len = length(signal);
img_pixels = len / SAMP_PIX;
img_height = floor(img_pixels/IMG_WIDTH);

% Range of frequencies in the FFT
f = (0:(FFT_LEN - 1)) * (WAV_FS / FFT_LEN);
% Generate Hamming Window
win = hamming(10);

img = zeros(img_height, IMG_WIDTH);

% Extract a pixel at a time using fft of 10 samples and the hamming window
for i = 1 : img_height
    for j= 1 : IMG_WIDTH
        start_index = SAMP_PIX*((i-1)*IMG_WIDTH + (j-1) ) + 1;
        chunk = signal(start_index : start_index + SAMP_PIX - 1) .* win;
        Y = fft(chunk, FFT_LEN);
        freq = f(Y == max(Y(1 : (FFT_LEN/2))));
        color = min((freq - BLACK)/(WHITE-BLACK), 1); %Scale color 0-1
        img(i, j) = color;
    end
end

%% Write image to file
imwrite(img, imgFile);
end

