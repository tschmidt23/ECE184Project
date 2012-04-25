function impairment_multipath(inFile, outFile, attn, delay)
%IMPAIRMENT_MULTIPATH Adds a multipath echo to a WAVE file
%   IMPAIRMENT_MULTIPATH(IN,OUT,ATTN,DELAY) adds a multipath echo to the
%   WAVE file IN using a single-echo model, where the echo's attenuation
%   ATTN is in decibels. The echo is delayed by DELAY samples and the
%   number of samples read in from IN will be equal to the number of
%   samples written to the resultant signal at OUT.

% Read in .wav file
[signal, Fs, N] = wavread(inFile);
len = length(signal);

% Attenuation in dB
alpha = 10^(attn/10);
A = 1 / alpha;

% Create impaired signal with echo
impaired_signal = signal;
impaired_signal(delay : len) = signal(delay : len) + ...
    A .* signal(1: (len - delay + 1));

% Normalize and write out
impaired_signal = 0.99.*impaired_signal./max(abs(impaired_signal));
wavwrite(impaired_signal, Fs, N, outFile);
end