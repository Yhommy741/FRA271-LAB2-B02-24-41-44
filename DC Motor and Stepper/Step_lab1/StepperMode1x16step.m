% ==============================================================
% Experiment: Stepper Motor Frequency–Velocity Comparison
% Motor: 12V Stepper Motor
% Test: Single-Trial Comparison Across Multiple PWM Frequencies
% ==============================================================

clear; clc; close all;

% -------------------------------
% Load all datasets
% -------------------------------
load("Full_10000hz_30s_1.mat");
freq_Full = squeeze(data{1}.Values.Data);
w_Full    = squeeze(data{2}.Values.Data);

load("Half_20000hz_30s_1.mat");
freq_Half = squeeze(data{1}.Values.Data);
w_Half    = squeeze(data{2}.Values.Data);

load("1.4_40000hz_30s_1.mat");
freq_40k = squeeze(data{1}.Values.Data);
w_40k    = squeeze(data{2}.Values.Data);

load("1.8_80000hz_30s_1.mat");
freq_80k = squeeze(data{1}.Values.Data);
w_80k    = squeeze(data{2}.Values.Data);

load("1.16_160000hz_30s_1.mat");
freq_160k = squeeze(data{1}.Values.Data);
w_160k    = squeeze(data{2}.Values.Data);

load("1.32_320000hz_30s_1.mat");
freq_320k = squeeze(data{1}.Values.Data);
w_320k    = squeeze(data{2}.Values.Data);

% -------------------------------
% Plot all conditions
% -------------------------------
figure; hold on;

plot(freq_Full,  w_Full,  'LineWidth', 1.6);
plot(freq_Half,  w_Half,  'LineWidth', 1.6);
plot(freq_40k,   w_40k,   'LineWidth', 1.6);
plot(freq_80k,   w_80k,   'LineWidth', 1.6);
plot(freq_160k,  w_160k,  'LineWidth', 1.6);
plot(freq_320k,  w_320k,  'LineWidth', 1.6);

grid on;
xlabel('Input Frequency (Hz)', 'FontSize', 12);
ylabel('Angular Velocity \omega (rad/s)', 'FontSize', 12);

title('Comparison of Angular Velocity of Stepper Motor in Different Mode', ...
      'FontSize', 14, 'FontWeight', 'bold');

legend( ...
    'Full Step', ...
    'Half Step', ...
    '1/4 Step', ...
    '1/8 Step', ...
    '1/16 Step', ...
    '1/32 Step', ...
    'Location', 'best');

xlim([0 150000]);

hold off;
