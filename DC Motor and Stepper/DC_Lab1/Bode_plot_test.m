% 1. โหลดข้อมูล
% ไฟล์ .mat ที่สร้างจาก Simulink จะถูกโหลดเป็น struct
% โดยทั่วไปข้อมูลสัญญาณจะอยู่ใน field ที่ชื่อ 'data' (หรือชื่อที่คุณตั้งไว้)
fprintf('Loading data...\n');
data_struct = load('Wnl_Freq5000_1.mat');

% ตัวแปร 'data' ภายใน struct เป็นอ็อบเจ็กต์ Simulink.SimulationData.Dataset
logsout = data_struct.data;

% 2. ดึงข้อมูลสัญญาณ (timeseries)
% จากการวิเคราะห์ไฟล์ Python พบว่า:
% สัญญาณ 'W' (Current: 1) คือตัวที่ 1
% สัญญาณ 'Raw_w' (Raw_W) คือตัวที่ 2
try
    w_signal = logsout.get(1);     % ดึงสัญญาณ 'W' (Output)
    raw_w_signal = logsout.get(2); % ดึงสัญญาณ 'Raw_w' (Input)
catch ME
    fprintf('Error accessing signals. Please check the element names or indices in logsout.\n');
    rethrow(ME);
end

% 3. ดึงค่าข้อมูลและเวลา
% แปลงข้อมูลให้เป็น vector (:) เพื่อให้แน่ใจว่าเป็นคอลัมน์เดียว
w_output = w_signal.Values.Data(:);
raw_w_input = raw_w_signal.Values.Data(:);
time = w_signal.Values.Time(:); % สองสัญญาณใช้เวลาเดียวกัน

% ตรวจสอบความยาวข้อมูลและตัดให้เท่ากัน (เผื่อไว้)
n_samples = min(length(w_output), length(raw_w_input));
w_output = w_output(1:n_samples);
raw_w_input = raw_w_input(1:n_samples);
time = time(1:n_samples);

% 4. คำนวณค่าพารามิเตอร์
dt = mean(diff(time));      % คำนวณ Sampling Time
fs = 1.0 / dt;             % คำนวณ Sampling Frequency
fprintf('Sampling Frequency (fs): %.0f Hz\n', fs);

% 5. คำนวณ Transfer Function Estimate
fprintf('Calculating frequency response using tfestimate...\n');

% ลบ DC offset/trend ออกจากสัญญาณ
input_detrended = detrend(raw_w_input);
output_detrended = detrend(w_output);

% ตั้งค่า parameters สำหรับ Welch's method (คล้ายกับใน Python)
nperseg = min(n_samples, 4096); % ขนาดของ Segment
noverlap = nperseg / 2;         % Overlap 50%
nfft = nperseg;                 % NFFT เท่ากับขนาด segment

% คำนวณ Transfer Function Estimate H(f) = Pxy(f) / Pxx(f)
% Txy คือ complex transfer function estimate, F คือ vector ของความถี่
[Txy, F] = tfestimate(input_detrended, output_detrended, hanning(nperseg), noverlap, nfft, fs);

% 6. คำนวณ Magnitude (dB) และ Phase (degrees)
magnitude_db = 20 * log10(abs(Txy));
phase_deg = unwrap(angle(Txy)) * 180/pi; % ใช้ unwrap เพื่อให้เฟสต่อเนื่อง

% 7. สร้าง Bode Plot
fprintf('Generating Bode plot...\n');
figure;
set(gcf, 'Position', [100, 100, 800, 600]); % ตั้งขนาดหน้าต่าง

% --- กราฟขนาด (Magnitude Plot) ---
subplot(2, 1, 1);
semilogx(F, magnitude_db); % ใช้แกน X เป็น log scale
title(['Bode Plot (fs = ' num2str(fs, '%.0f') ' Hz)']);
ylabel('Magnitude (dB)');
grid on;
axis tight; % ปรับแกนให้พอดี
if length(F) > 1
    xlim([F(2), fs/2]); % เริ่มที่ F(2) เพื่อเลี่ยงความถี่ 0 Hz
end
ylim([-60, 10]); % ตั้งค่าแกน Y ให้อ่านง่าย

% --- กราฟเฟส (Phase Plot) ---
subplot(2, 1, 2);
semilogx(F, phase_deg); % ใช้แกน X เป็น log scale
ylabel('Phase (degrees)');
xlabel('Frequency (Hz)');
grid on;
axis tight; % ปรับแกนให้พอดี
if length(F) > 1
    xlim([F(2), fs/2]);
end

disp('Plot generated.');