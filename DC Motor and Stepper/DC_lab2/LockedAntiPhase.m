% ==============================================================
% Experiment: Analysis of Angular Velocity and Current Response
% Device Under Test: 12V DC Motor
% Description:
%   This script processes and visualizes motor current (i) and 
%   angular velocity (w) data, converting the time axis into an
%   equivalent PWM duty-cycle scale (0–100%). Only data
%   corresponding to t >= 2 seconds is analyzed to ensure
%   steady-state and valid measurement conditions.
% ==============================================================

% -------------------------------
% Load the MAT file
% -------------------------------
load("Wnl_lockAntiPhase.mat");

% Extract and squeeze data
i = squeeze(data{1}.Values.Data);
t_i = squeeze(data{1}.Values.Time);

w = squeeze(data{2}.Values.Data);
t_w = squeeze(data{2}.Values.Time);

% -------------------------------
% Filter: Only consider t >= 2 s
% -------------------------------
idx_i = t_i >= 2;
idx_w = t_w >= 2;

% -------------------------------
% Convert Time to Duty Cycle (0–100%)
% Mapping:  t = 2 → 0%   and   t = 22 → 100%
% -------------------------------
duty_i = 100 * (t_i(idx_i) - 2) / (22 - 2);
duty_w = 100 * (t_w(idx_w) - 2) / (22 - 2);

% Clip duty cycle to 0–100%
idx_i_clip = duty_i <= 100;
idx_w_clip = duty_w <= 100;

% Apply clipping to data
i_clip = i(idx_i, :);
i_clip = i_clip(idx_i_clip, :);

w_clip = w(idx_w, :);
w_clip = w_clip(idx_w_clip, :);

duty_i_clip = duty_i(idx_i_clip);
duty_w_clip = duty_w(idx_w_clip);

% -------------------------------
% Plot Results
% -------------------------------
figure;

% ---- Current Plot ----
subplot(2,1,1);
plot(duty_i_clip, i_clip, 'LineWidth', 1.5);
xlabel('Duty Cycle (%)', 'FontSize', 12);
ylabel('Motor Current i (A)', 'FontSize', 12);
title('Relationship Between 12V DC Motor Current vs. Duty Cycle (0–100%)', 'FontSize', 14, 'FontWeight', 'bold');
grid on;

% ---- Angular Velocity Plot ----
subplot(2,1,2);
plot(duty_w_clip, w_clip, 'LineWidth', 1.5);
xlabel('Duty Cycle (%)', 'FontSize', 12);
ylabel('Angular Velocity \omega (rad/s)', 'FontSize', 12);
title('Relationship Between 12V DC Motor Angular Velocity & Duty Cycle (0–100%)', 'FontSize', 14, 'FontWeight', 'bold');
grid on;

% ---- Overall Figure Title ----
sgtitle('Experimental Measurement of Angular Velocity and Current of a 12V DC Motor at Locked Anti-Phase Mode', ...
        'FontSize', 16, 'FontWeight', 'bold');
