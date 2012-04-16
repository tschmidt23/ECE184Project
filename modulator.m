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
len = size(img, 1);
width = size(img, 2);

%% Modulate Image
t = 0;
wav_data = zeros(1, 10*width*len);
for i = 1 : len
    for j = 1 : width
        freq = BLACK + (WHITE-BLACK) * (img(i,j) / 255);
        for k = 1 : 10
           wav_data(10*((i-1)*width + (j-1)) + (k)) = cos(2*pi*freq*t);
           t = t + WAV_TS;
        end
    end
end

%% Write to WAVE file
wavwrite(wav_data, WAV_FS, WAV_NBITS, wavFile);
end

