function [start_index] = start_detector(signal)
%start_detector

%% constants
WAV_FS = 16000;
FFT_LEN = 2048;
REL_PEAK_THRESH = 5;
SKIP_SAMPLES =3*WAV_FS;
MAX_DEVIATION = 10;
MAX_CONSECUTIVE = 100;

%% finds the beginning of start signal

f = (0:(FFT_LEN-1))*(WAV_FS/FFT_LEN);
w = hamming(FFT_LEN);

% look for peaks in these four frequency bands (characteristic of start
% signal)
peak_i = [ find(f > 1250,1) find(f > 1550, 1);...
           find(f > 1550,1) find(f > 1850, 1);...
           find(f > 1850,1) find(f > 2150, 1);...
           find(f > 2150,1) find(f > 2450, 1)];
             
found_start = 0;
index = 0;

while (~found_start)
    index = index+1;
    Y = abs(fft(w.*signal(index:index+FFT_LEN-1)));
    peaks = [ max(Y(peak_i(1,1):peak_i(1,2)));...
              max(Y(peak_i(2,1):peak_i(2,2)));...
              max(Y(peak_i(3,1):peak_i(3,2)));...
              max(Y(peak_i(4,1):peak_i(4,2)))];
    rel_peaks = [peaks(1)/mean(Y(peak_i(1,1):peak_i(1,2)));...
                 peaks(2)/mean(Y(peak_i(2,1):peak_i(2,2)));...
                 peaks(3)/mean(Y(peak_i(3,1):peak_i(3,2)));...
                 peaks(4)/mean(Y(peak_i(4,1):peak_i(4,2)))];
    if (mean(rel_peaks) > REL_PEAK_THRESH)
        found_start = 1;
    end
end

%% skip over some of the middle
index = index + SKIP_SAMPLES;

%% find the end of the start signal
found_end = 0;
last_valid = index;
consecutive = 0;

while (~found_end)
    index = index+1;
    Y = abs(fft(w.*signal(index:index+FFT_LEN-1)));
    peaks = [ max(Y(peak_i(1,1):peak_i(1,2)));...
              max(Y(peak_i(2,1):peak_i(2,2)));...
              max(Y(peak_i(3,1):peak_i(3,2)));...
              max(Y(peak_i(4,1):peak_i(4,2)))];
    peak_freqs = [f(Y==peaks(1)); f(Y==peaks(2)); f(Y==peaks(3)); f(Y==peaks(4))];
    separation = [peak_freqs(2)-peak_freqs(1);...
                  peak_freqs(3)-peak_freqs(2);...
                  peak_freqs(4)-peak_freqs(3)];
    mean_separation = mean(separation);
    if (abs(mean_separation-300) > MAX_DEVIATION)
       consecutive = consecutive + 1;
       if (consecutive > MAX_CONSECUTIVE)
           found_end = 1;
       end
    else
        consecutive = 0;
        last_valid = index;
    end
end

start_index = last_valid + FFT_LEN/2;

end