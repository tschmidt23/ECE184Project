function impairment_AWGN(inFile, outFile, SNR)
%impairment_AWGN

[signal, Fs, N] = wavread(inFile);

len = length(signal);

nfft = 2^nextpow2(len);
Pxx = abs(fft(signal,nfft)).^2/len/Fs;
Hpsd=dspdata.psd(Pxx,'Fs',Fs);
    
Psignal = avgpower(Hpsd);
Pnoise = Psignal / SNR;
    
impaired_signal = signal + randn(len,1).*sqrt(Pnoise/2);
impaired_signal = 0.99.*impaired_signal./max(impaired_signal);

wavwrite(impaired_signal,Fs,N,outFile);

end