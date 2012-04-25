function start_index = start_detector(signal)
%START_DETECTOR Detects the start signal of an HF Fax transmission
%   START_INDEX = START_DETECTOR(SIGNAL) The start detector uses a sliding
%   STFT with a Hamming window to detect the start signal. The start signal
%   is characterized in the frequency domain by a few strong peaks
%   separated by 300 Hz. We identified four frequency bands with such
%   peaks, and find the location of the highest value within each band. If
%   these peaks are approximately 300 Hz apart, we are in the start signal.
%   If we go a number of samples without seeing peaks separated by 300Hz,
%   we have reached the end of the start signal.
%
%   See also STOP_DETECTOR, DEMODULATOR

%% Constants
WAV_FS = 16000;
FFT_LEN = 2048;
SAMPLE_LEN = 512;
REL_PEAK_THRESH = 0.5;
SKIP_SAMPLES = 3 * WAV_FS;
MAX_DEVIATION = 10;
MAX_CONSECUTIVE = 20;
PEAK_SEPARATION = 300;

%% Setup
f = (0:(FFT_LEN-1))*(WAV_FS/FFT_LEN);
w = hamming(SAMPLE_LEN);

% look for peaks in these four frequency bands (characteristic of start
% signal)
peak_i = [ find(f > 1275,1) find(f > 1525, 1); ...
           find(f > 1575,1) find(f > 1825, 1); ...
           find(f > 1875,1) find(f > 2125, 1); ...
           find(f > 2175,1) find(f > 2425, 1)];
             
found_start = 0;
index = 0;

%% Find beginning of start signal
while (~found_start)
    index = index + 1;
    % windowed fft
    Y = abs(fft(w.*signal(index:index+SAMPLE_LEN-1),FFT_LEN));
    % vector of the the peaks in the four bands
    peaks = [ max(Y(peak_i(1,1):peak_i(1,2)));...
              max(Y(peak_i(2,1):peak_i(2,2)));...
              max(Y(peak_i(3,1):peak_i(3,2)));...
              max(Y(peak_i(4,1):peak_i(4,2)))];
    % peaks relative to mean in their bands
    rel_peaks = [peaks(1)/mean(Y(peak_i(1,1):peak_i(1,2)));...
                 peaks(2)/mean(Y(peak_i(2,1):peak_i(2,2)));...
                 peaks(3)/mean(Y(peak_i(3,1):peak_i(3,2)));...
                 peaks(4)/mean(Y(peak_i(4,1):peak_i(4,2)))];
    % found the start when the peaks exceed the threshold
    if (mean(rel_peaks) > REL_PEAK_THRESH)
        found_start = 1;
    end
end

%% Skip over some of the middle
index = index + SKIP_SAMPLES;

%% find the end of the start signal
found_end = 0;
last_valid = index;
consecutive = 0;

while (~found_end)
    index = index + 1;
    % windowed fft
    Y = abs(fft(w.*signal(index:index+SAMPLE_LEN-1),FFT_LEN));
    % peaks of the four bands
    peaks = [ max(Y(peak_i(1,1):peak_i(1,2))); ...
              max(Y(peak_i(2,1):peak_i(2,2))); ...
              max(Y(peak_i(3,1):peak_i(3,2))); ...
              max(Y(peak_i(4,1):peak_i(4,2)))];
    % frequencies of the four peaks
    peak_freqs = [f(Y==peaks(1)); f(Y==peaks(2)); ...
                  f(Y==peaks(3)); f(Y==peaks(4))];
    % separation of the four peaks
    separation = [peak_freqs(2)-peak_freqs(1); ...
                  peak_freqs(3)-peak_freqs(2); ...
                  peak_freqs(4)-peak_freqs(3)];
    mean_separation = mean(separation);
    if (abs(mean_separation-PEAK_SEPARATION) > MAX_DEVIATION)
       consecutive = consecutive + 1;
       if (consecutive > MAX_CONSECUTIVE)
           found_end = 1;
       end
    else
        consecutive = 0;
        last_valid = index;
    end
end

% the actual end of the start signal is a little beyond the last valid
% index, and was empirically determined to be about 2/3 of the number of
% samples used in the STFT.
start_index = last_valid + round(SAMPLE_LEN*2/3);
end