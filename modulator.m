function modulator(imgFile, wavFile)
%MODULATOR Converts a JPEG to a .wav file in NOAA Marine Weather Fax Format
%   Y = MODULATOR(X) takes an 8-bit grayscale JPEG image and converts it
%   into a 16-bit, single channel .wav file with sampling frequency, fs =
%   16 KHz. The .wav file will be formatted according to the NOAA Marine
%   Weather Fax Format.

%% Constants
WAV_FS = 16000; %Hz
WAV_TS = 1/WAV_FS; %seconds
WAV_NBITS = 16; %bits/sample
JPEG_NBITS = 8; %bits
JPEG_WIDTH = 800; %pixels

BLACK = 1500; %Hz
WHITE = 2300; %Hz

START_TIME = 5; %seconds
START_FREQ = 300; %Hz
STOP_TIME = 5; %seconds
STOP_FREQ = 450; %Hz

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
TS = 1/START_FREQ;
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

%% Modulate Image
phi = 0;

t = 0:WAV_TS:(9*WAV_TS);

wav_data = zeros(1, 10*width*len);
for i = 1 : len
    for j = 1 : width
        freq = BLACK + (WHITE-BLACK) * (img(i,j) / 255);
        for k = 1 : 10
           wav_data(10*((i-1)*width + (j-1)) + (k)) = 0.99*cos(2*pi*freq*t(k) + phi);
        end
        phi = phi+(2*pi*freq*WAV_TS*10);
    end
end

%% Write to WAVE file
wavwrite(wav_data, WAV_FS, WAV_NBITS, wavFile);
end

