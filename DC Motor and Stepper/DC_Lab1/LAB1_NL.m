%% ============================================================
%      No-Load Angular Velocity and Current Analysis (12 V)
% ============================================================

clear; clc;

load("Inl.mat");

%% ============================================================
%          Extract and squeeze data (fix data dimensions)
% ============================================================

% Angular velocity
w = squeeze(data{2}.Values.Data);      % rad/s
t_w = data{2}.Values.Time;             % time (s)

% Current
i = squeeze(data{1}.Values.Data);      % A
t_i = data{1}.Values.Time;             % time (s)

%% ============================================================
%     Compute No-Load Average Values (for t ≥ 0.3 s)
% ============================================================

idx_w = (t_w >= 0.3);
idx_i = (t_i >= 0.3);

W_NL = mean(w(idx_w));     % No-load speed
I_NL = mean(i(idx_i));     % No-load current

fprintf("Average No-Load Angular Velocity : %.3f rad/s\n", W_NL);
fprintf("Average No-Load Current         : %.3f A\n", I_NL);

%% ============================================================
%                           Plotting
% ============================================================

figure('Color','w');

%% -------- Angular Velocity (subplot 1) --------
subplot(2,1,1);
plot(t_w, w, 'LineWidth', 1.5);
grid on; box on;

ylabel('Angular Velocity (rad/s)', 'FontSize', 12, 'FontWeight','bold');
title('Experimental Measurement of No-Load Angular Velocity (12 V)', ...
      'FontSize', 14, 'FontWeight','bold');

set(gca, 'FontSize', 12, 'LineWidth', 1);

% Annotate
text(0.02, 0.92, sprintf('Average No-Load Angular Velocity = %.3f rad/s', W_NL), ...
     'Units', 'normalized', 'FontSize', 12, 'FontWeight','bold', ...
     'BackgroundColor','white', 'EdgeColor','black');

%% -------- Current (subplot 2) --------
subplot(2,1,2);
plot(t_i, i, 'LineWidth', 1.5);
grid on; box on;

xlabel('Time (s)', 'FontSize', 12, 'FontWeight','bold');
ylabel('Current (A)', 'FontSize', 12, 'FontWeight','bold');

set(gca, 'FontSize', 12, 'LineWidth', 1);

% Annotate
text(0.02, 0.92, sprintf('Average No-Load Current = %.3f A', I_NL), ...
     'Units', 'normalized', 'FontSize', 12, 'FontWeight','bold', ...
     'BackgroundColor','white', 'EdgeColor','black');
