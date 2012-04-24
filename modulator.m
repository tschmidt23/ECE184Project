function modulator(imgFile, wavFile)
%MODULATOR Converts a JPEG to a .wav file in NOAA Marine Weather Fax Format
%   Y = MODULATOR(X) takes an 8-bit grayscale JPEG image and converts it
%   into a 16-bit, single channel .wav file with sampling frequency, fs =
%   16 KHz. The .wav file will be formatted according to the NOAA Marine
%   Weather Fax Format.
clc; clear;
%% Constants
WAV_FS = 16000; %Hz
WAV_TS = 1/WAV_FS; %seconds
WAV_NBITS = 16; %bits/sample
JPEG_NBITS = 8; %bits
JPEG_WIDTH = 800; %pixels
SAMP_PIX = 10; %samples / pixel

BLACK = 1500; %Hz
WHITE = 2300; %Hz

START_TIME = 5; %seconds
START_FREQ = 300; %Hz
STOP_TIME = 5; %seconds
STOP_FREQ = 450; %Hz

%% Functions
    % --- Encodes black/white pixels varying at freq for given duration.
    function y = startStop(freq, duration)
        colors = [BLACK WHITE];
        n = 0 : duration * WAV_FS - 1;
        samp = 1/(2*freq) * WAV_FS; %Samples per black/white pixel
        color = mod(floor(n / samp), 2); %Divide into even, odd colors 
        y = .99*cos(2*pi*colors(color+1).*n.*WAV_TS);
    end
% y = startStop(START_FREQ, 5);
% wavwrite(y, WAV_FS, WAV_NBITS,'start2.wav');

%% Read in Image
img = imread(imgFile);
img = double(img(:,:,1));

imwrite(img/255,'test.jpg');

len = size(img, 1);
width = size(img, 2);

%% Generate Start Signal
start_signal = zeros(1,START_TIME*WAV_FS);
phi = 0;
freq = WHITE;
TS = 1/(2*START_FREQ);
time = 0;



for i = 1:size(start_signal,2)
    if (time + WAV_TS <= TS)
        time = time + WAV_TS;
        phi = phi + 2*pi*freq*WAV_TS;
        start_signal(i) = 0.99*cos(phi);        
    else 
        phi = phi + 2*pi*freq*(TS - time);
        if (freq == WHITE)
            freq = BLACK;
        else
            freq = WHITE;
        end
        time = WAV_TS-(TS-time);
        phi = phi + 2*pi*freq*time;
        start_signal(i) = 0.99*cos(phi);
    end
end

wavwrite(start_signal,WAV_FS,WAV_NBITS,'start.wav');

start_signal(1:320)

%% generate chirps
chirp = zeros(8000,1);
phi = 0;
for i=1:7600
    chirp(i) = 0.99*cos(phi);
    phi = phi + 2*pi*BLACK*WAV_TS;
end
for i=7601:8000
   chirp(i) = 0.99*cos(phi);
   phi = phi +2*pi*WHITE*WAV_TS;
end
chirp = repmat(chirp,40,1);
wavwrite(chirp,WAV_FS,WAV_NBITS,'chirp.wav');

%% Modulate Image
phi = 0;

t = 0:WAV_TS:((SAMP_PIX - 1)*WAV_TS);

wav_data = zeros(1, SAMP_PIX*width*len);
for i = 1 : len
    for j = 1 : width
        freq = BLACK + (WHITE-BLACK) * (img(i,j) / 255);
        for k = 1 : SAMP_PIX
           wav_data(SAMP_PIX*((i-1)*width + (j-1)) + (k)) = ...
               0.99*cos(2*pi*freq*t(k) + phi);
        end
        phi = phi+(2*pi*freq*WAV_TS*SAMP_PIX);
    end
end

%% Generate Stop Signal
stop_signal = startStop(STOP_FREQ, STOP_TIME);
wavwrite(stop_signal, WAV_FS, WAV_NBITS, 'stop.wav');

%% Write to WAVE file
wavwrite(wav_data, WAV_FS, WAV_NBITS, wavFile);
end

