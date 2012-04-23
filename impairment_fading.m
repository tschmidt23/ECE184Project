function impairment_fading(inFile, outFile, variance)
%impairment_fading

[signal, Fs, N] = wavread(inFile);

len = length(signal);

alpha = raylrnd(1:len)'.*sqrt(variance);
phi = rand(len,1).*2*pi;

c = alpha.*exp(1i*phi);

impaired_signal = signal.*c;
impaired_signal = 0.99.*impaired_signal./max(impaired_signal);

wavwrite(impaired_signal,Fs,N,outFile);

end