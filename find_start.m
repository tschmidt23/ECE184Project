start = wavread('start.wav');
test = rand(1000000,1);
test(457:457+79999) = start;

test_start = start;
test_start = wavread('OTA_startsignal.wav');
test_start = test_start/max(test_start);
test = 0.05.*rand(1000000,1);
test(457:456+size(test_start,1)) = test_start;

test =  wavread('OTA_grayscale_sat_image.wav');
%test = [randn(5000,1); test./max(test)];

highest = 0;
index = 0;

start_piece = start(1:320);
c = zeros(1,500000);

% for i = 1:500000 %(size(test,1)-size(start,1))
%      correlation = sum(start_piece.*test(i:i+319));
% %      if (correlation > highest)
% %         highest = correlation
% %         index = i
% %      end
%      c(i) = correlation;
% end
% 
%  %plot(c)
%  avgs = zeros(1,500000);
%  
% for i=321:499680
%     avgs(i) = mean(c(i-160:i+160).*c(i-160:i+160));
% end
% 
% plot(c)
% figure(2)
% plot(avgs);

[c1,lags] = xcorr(test(1:100000),start_piece);
plot(c1)

best = 0;
best_index = 0;

FFT_LEN = 256;

w = zeros(27,1);
for i=0:26
   w(i+1) = 0.54-0.46*cos(2*pi*i/26);
end

peaks = zeros(1,90000);

WAV_FS = 16000;
f = (0:(FFT_LEN-1))*(WAV_FS/FFT_LEN);

% for i=1:53
%     chunk = w.*test(457+i:457+i+26);
%     Y = abs(fft(chunk,FFT_LEN));
%     peak = max(Y);
%     f(Y==peak)
%     if (peak > best)
%        best = peak
%        best_index = i
%     end
%     figure(i)
%     plot(f,abs(Y))
% end



last = 0;
last_index = 0;

% for i=1:90000
%     %chunk = w.*test(i+length(test_start):i+length(test_start)+26);
%     chunk = w.*test(i:i+26);
%     Y = abs(fft(chunk,FFT_LEN));
%     peak = max(Y(23:39)); %max([Y(23:27); Y(35:39)]);
%     peaks(i) = peak;
%     
%     if (peak < last)
%         if (i-last_index > 9)
%             i-last_index;
%             last_index = i;
%         end
%     end
%     last = peak;
%     
% end


%plot(peaks);