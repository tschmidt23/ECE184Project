function impairment_multipath(inFile, outFile, attenuation, delay_time)
%impairment_AWGN

[signal, Fs, N] = wavread(inFile);

len = length(signal);

a = 1/attenuation;

impaired_signal = signal;
impaired_signal(delay_time:len) = signal(delay_time:len) + ...
    a.*signal(1:(len-delay_time+1));

impaired_signal = 0.99.*impaired_signal./max(impaired_signal);

wavwrite(impaired_signal,Fs,N,outFile);

end