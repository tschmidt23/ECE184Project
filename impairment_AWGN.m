function impairment_AWGN(inFile, outFile, SNR)
%IMPAIRMENT_AWGN Adds AWGN noise to the specified WAVE file.
%   IMPAIRMENT_AWGN(IN, OUT, SNR) takes in a .wav file at path IN and adds
%   additive white Gaussian noise to that WAVE file such that the output
%   file at OUT has a signal-to-noise power ratio of SNR in decibels.

% Read in WAVE file
[signal, Fs, N] = wavread(inFile);
len = length(signal);

% Calculate Signal and Noise Power
Psig = sum(abs(signal) .^ 2) / len;
Pnoise = Psig / 10^(SNR/10);

% Add noise to signal
y = signal + randn(len, 1) .* sqrt(Pnoise / 2);

% Normalize and write out
impaired_signal = 0.99 .* y ./ max(abs(y));
wavwrite(impaired_signal, Fs, N, outFile);
end