function modulator(imgFile, wavFile)
%MODULATOR Converts a JPEG to a .wav file in NOAA Marine Weather Fax Format
%   Y = MODULATOR(IN, OUT) treats IN as a path to an 8-bit grayscale JPEG
%   image that should be converted into a 16-bit, single channel WAVE file
%   with sampling frequency, fs = 16 KHz. The .wav file will be formatted
%   according to the NOAA Marine Weather Fax Format (HF Fax) and will be
%   written to the path specified by OUT.
%
%   See also DEMODULATOR

%% Constants
WAV_FS = 16000; %Hz
WAV_TS = 1/WAV_FS; %seconds
WAV_NBITS = 16; %bits/sample
SAMP_PIX = 10; %samples / pixel

BLACK = 1500; %Hz
WHITE = 2300; %Hz

START_TIME = 5; %seconds
START_FREQ = 300; %Hz
STOP_TIME = 5; %seconds
STOP_FREQ = 450; %Hz

phi = 0;

%% Functions
    % --- Encodes black/white pixels varying at freq for given duration.
    function y = start_stop(frequency, duration)
        signal = zeros(1, duration * WAV_FS);
        TS = 1/(2*frequency);
        time = 0;
        colors = [WHITE BLACK];
        c = 0; %Color index: 0 is white, and 1 is black
        f = colors(c + 1);
        
        for l = 1:size(signal,2)
            % stay on same frequency
            if (time + WAV_TS <= TS)
                time = time + WAV_TS;
                phi = phi + 2*pi*f*WAV_TS;
                signal(l) = 0.99*cos(phi); 
            % switch freuquency 
            else 
                phi = phi + 2*pi*f*(TS - time);
                c = ~c;
                f = colors(c + 1); %MATLAB is 1 indexed, add 1
                time = WAV_TS-(TS-time);
                phi = phi + 2*pi*f*time;
                signal(l) = 0.99*cos(phi);
            end
        end
        y = signal;
    end

%% Read in Image
img = imread(imgFile);
img = double(img(:, :, 1));

len = size(img, 1);
width = size(img, 2);

%% Generate Start Signal
start_signal = start_stop(START_FREQ, START_TIME);

%% Generate Chirps
chirp = zeros(1, WAV_FS / 2); %.5 seconds

% Long black signal
for i = 1 : 7600
    chirp(i) = 0.99*cos(phi);
    phi = phi + 2*pi*BLACK*WAV_TS;
end

% Short white pulse
for i=7601: WAV_FS / 2
   chirp(i) = 0.99*cos(phi);
   phi = phi +2*pi*WHITE*WAV_TS;
end
chirp = repmat(chirp, 1, 40);

%% Modulate Image
t = 0:WAV_TS:((SAMP_PIX - 1) * WAV_TS);

wav_data = zeros(1, SAMP_PIX*width*len);
for i = 1 : len
    for j = 1 : width
        freq = BLACK + (WHITE-BLACK) * (img(i,j) / 255);
        for k = 1 : SAMP_PIX
           wav_data(SAMP_PIX*((i-1)*width + (j-1)) + (k)) = ...
               0.99*cos(2*pi*freq*t(k) + phi);
        end
        % maintain phase consistency
        phi = phi + (2*pi*freq*WAV_TS*SAMP_PIX);
    end
end

%% Generate Stop Signal
stop_signal = start_stop(STOP_FREQ, STOP_TIME);

%% Concatenate WAVE data
wav_data = [start_signal chirp wav_data stop_signal zeros(1, 16000)]; 

%% Write to WAVE file
wavwrite(wav_data, WAV_FS, WAV_NBITS, wavFile);
end
