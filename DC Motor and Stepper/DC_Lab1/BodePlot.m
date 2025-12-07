%% =========================================================================
%  BodePlot - Generates Bode Plot (Magnitude and Phase) with Log Frequency Scale
%  =========================================================================
clc;
% Filter Parameters from your Lowpass Filter block
Fs = 1000;              % Sample rate (Hz)
Fp = 7.5;               % Passband edge frequency (Fp)
Fst = 15;               % Stopband edge frequency (Fst)
Ap = 0.1;               % Max passband ripple (Ap)
Ast = 80;               % Min stopband attenuation (Ast)

% 1. Define the Specifications
spec = fdesign.lowpass('Fp,Fst,Ap,Ast', Fp, Fst, Ap, Ast, Fs);

% 2. Design the Minimum-Order FIR Filter
D_fir = design(spec, 'equiripple'); 

% 3. Extract Filter Coefficients
N = D_fir.Numerator; 
D = 1; % Denominator is 1 for an FIR filter

% 4. Define the specific frequency range (0.1 Hz to 50 Hz for log scale)
% Log scales cannot start at 0, so we start slightly above (e.g., 0.1 Hz).
F_plot_min = 0.1; 
F_plot_max = 50;
N_points = 512; 

% Use logspace to get points distributed logarithmically, covering 0.1 to 50 Hz
% Alternatively, linspace and then plot using semilogx is common too.
F_vector = logspace(log10(F_plot_min), log10(F_plot_max), N_points); 

% 5. Calculate the Frequency Response using the defined F_vector
[H, W] = freqz(N, D, F_vector, Fs); 

% 6. Plot the Magnitude and Phase Response
figure('Name', 'Bode Plot Log Scale 0.1-50 Hz');

% --- Top Subplot: Magnitude ---
subplot(2,1,1);
% **CHANGE:** Use semilogx for log scale on the X-axis (Frequency)
semilogx(W, 20*log10(abs(H))); 
title('Magnitude Response');
ylabel('Magnitude (dB)');
grid on;
% Set the X-axis limits based on the log scale definition
xlim([F_plot_min, F_plot_max]);

% --- Bottom Subplot: Phase ---
subplot(2,1,2);
% **CHANGE:** Use semilogx for log scale on the X-axis (Frequency)
semilogx(W, unwrap(angle(H)) * 180/pi); 
title('Phase Response');
ylabel('Phase (degrees)');
xlabel('Frequency (Hz)');
grid on;
% Set the X-axis limits based on the log scale definition
xlim([F_plot_min, F_plot_max]);

sgtitle('Bode Plot for Lowpass Filter', 'FontSize', 16, 'FontWeight','bold');

disp('✅ Bode Plot with Log Frequency Scale (0.1 Hz to 50 Hz) generated successfully.');