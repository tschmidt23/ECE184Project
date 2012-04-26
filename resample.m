data = wavread('demodtest2.wav');
full_chunks = floor(length(data)/32000);
out_data = [];
for i = 1:full_chunks
   out_data = [out_data; data(32000*(i-1)+1:32000*i); 0]; 
end
out_data = [out_data; data(32000*full_chunks+1:length(data))];

wavwrite(out_data,16000,16,'FOR_EMMA_demodtest2_resampled.wav');