function [stop_index] = stop_detector(signal)
%STOP_DETECTOR Detects the stop signal.
%   STOP_INDEX = STOP_DETECTOR(SIGNAL) The stop detector uses a sliding
%   STFT with a Hamming window to detect the stop signal. The stop signal
%   is characterized in the frequency domain by a few strong peaks
%   separated by 450 Hz. We identified four frequency bands with such
%   peaks, and find the location of the highest value within each band. If
%   we go a number of samples while observing peaks separated by 450Hz,
%   we have reached the beginning of the stop signal.

%% constants
WAV_FS = 16000;
FFT_LEN = 1024;
MAX_DEVIATION = 15;
MIN_CONSECUTIVE = 1000;
PEAK_SEPARATION = 450;

%% setup

f = (0:(FFT_LEN-1))*(WAV_FS/FFT_LEN);
w = hamming(FFT_LEN);

% look for peaks in these four frequency bands (characteristic of start
% signal)
peak_i = [ find(f > 900,1) find(f > 1300, 1);...
           find(f > 1350,1) find(f > 1750, 1);...
           find(f > 1800,1) find(f > 2200, 1);...
           find(f > 2250,1) find(f > 2650, 1)];
             
found_start = 0;
index = 0;
consecutive = 0;
first_valid = 0;

%% find the beginning of the stop signal
while (~found_start)
    % if the last sample looked good, increment by 1
    if (consecutive)
        index = index + 1;
    % if the last sample did not look good, skip forward (for speed)
    else
        index = index+250;
    end
    % windowed STFT
    Y = abs(fft(w.*signal(index:index+FFT_LEN-1)));
    % peaks in the four bands
    peaks = [ max(Y(peak_i(1,1):peak_i(1,2)));...
              max(Y(peak_i(2,1):peak_i(2,2)));...
              max(Y(peak_i(3,1):peak_i(3,2)));...
              max(Y(peak_i(4,1):peak_i(4,2)))];
    % frequencies of the peaks
    peak_freqs = [f(Y==peaks(1)); f(Y==peaks(2)); f(Y==peaks(3)); f(Y==peaks(4))];
    % separation of the peaks
    separation = [peak_freqs(2)-peak_freqs(1);...
                  peak_freqs(3)-peak_freqs(2);...
                  peak_freqs(4)-peak_freqs(3)];
    mean_separation = mean(separation);
    % reset if separation deviates
    if (abs(mean_separation-PEAK_SEPARATION) > MAX_DEVIATION)
       consecutive = 0;
       first_valid = index;
    else
        consecutive = consecutive + 1;
        if (consecutive > MIN_CONSECUTIVE)
           found_start = 1;
       end
    end
end

stop_index = first_valid;
end