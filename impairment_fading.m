function rt = impairment_fading(inFile, outFile, variance)
%IMPAIRMENT_FADING Adds Rayleigh Fading to a WAVE file
%   IMPAIRMENT_FADING(IN,OUT,VAR) adds frequency nonselective Rayleigh
%   fading to the WAVE file at IN with variance equal to VAR and writes the
%   resultant signal to a WAVE file at OUT. Rayleigh fading is added on a
%   per sample basis, and so the number of samples in IN equals the number
%   of samples in OUT.

% Read in WAVE file
[signal, Fs, N] = wavread(inFile);
len = length(signal);

% Distribution Parameters
mu = zeros(1, len);
sigma = sqrt(variance);

% Generate Gaussians
cr = normrnd(mu, sigma);
ci = normrnd(mu, sigma);

% Calculate Rayleigh Parameters
alpha = sqrt(cr.^2 + ci.^2);
phi = atan(ci / cr);

ct = alpha.*exp(1j*phi);
rt = ct.*signal';

%Normalize and write out
wavwrite(.99.*rt./max(abs(rt)), Fs, N, outFile);
end