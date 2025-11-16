% --- 1. โหลดไฟล์ .mat ---
load('Motor_Velocity2_ForFFT.mat');

% --- 2. ดึงข้อมูลสัญญาณและเวลาออกจากอ็อบเจกต์ ---
signal = data.Data; % ดึงข้อมูลสัญญาณ
time = data.Time;   % ดึงข้อมูลเวลา

% --- 3. คำนวณ Sampling Frequency (fs) ---
dt = mean(diff(time)); 
fs = 1 / dt; % Sampling Frequency (Hz)
fprintf('Sampling Frequency (fs): %.2f Hz\n', fs);

% --- 4. ทำ Fast Fourier Transform (FFT) ---
N = length(signal); 
Y_complex = fft(signal); 

% --- 5. คำนวณขนาดและแกนความถี่สำหรับพล็อต ---
P2 = abs(Y_complex / N);
P1 = P2(1:floor(N/2)+1);
P1(2:end-1) = 2 * P1(2:end-1);
f = (0:(N/2)) * (fs / N);

% --- 6. พล็อตกราฟสเปกตรัมความถี่ ---
figure;
plot(f, P1);
title('Frequency Spectrum (Magnitude 0-2)');
xlabel('Frequency (Hz)');
ylabel('Magnitude');
grid on;

% --- นี่คือส่วนที่ปรับแก้ตามคำขอ ---
% กำหนดให้แกน Y (Magnitude) แสดงในช่วง 0 ถึง 2
ylim([0, 50]); 
% --- จบส่วนที่ปรับแก้ ---

% (ทางเลือก) พล็อตกราฟสัญญาณดั้งเดิม
figure;
plot(time, signal);
title('Original Signal (Time Domain)');
xlabel('Time (s)');
ylabel('Amplitude');
grid on;