% ========================================================================
%  DC Motor Polynomial Fit Script: Equations Displayed in Legend
%  *** Updated Experimental Data Used ***
% ========================================================================
clear; clc;

%% ---------------------- 1. Experimental Data Input ---------------------
% Input Voltage
V_in = 12;

% Data extracted from the provided table (NEW DATA)
tau_exp = [0.014715, 0.02943, 0.044145, 0.05886, 0.073575, 0.08829, 0.103, 0.11772, 0.13243, 0.14715, 0.16187, 0.17658, 0.1913]; % Torque (Nm)
i_exp   = [1.874, 2.1867, 2.7637, 2.9952, 3.3907, 3.7072, 3.9666, 4.1694, 4.3948, 4.5808, 4.6491, 4.7064, 4.7287]; % Average Current (A)
omega_exp = [149.12, 112.99, 96.644, 66.276, 67.077, 56.328, 46.863, 32.399, 25.149, 15.487, 8.6049, 3.1657, 1.3491]; % Angular Velocity (rad/s)

% Define the polynomial degree for the fit
FIT_ORDER = 2; 
tau_fit = linspace(min(tau_exp), max(tau_exp), 500); 

%% ---------------------- 2. Polynomial Fitting and R-Squared Analysis -----------------
% --- Function to calculate R-Squared ---
calculate_Rsquared = @(y_exp, f_fit) (1 - sum((y_exp - f_fit).^2) / sum((y_exp - mean(y_exp)).^2));

% --- A. Speed–Torque Fit (omega vs tau) ---
P_omega = polyfit(tau_exp, omega_exp, FIT_ORDER);
omega_fit = polyval(P_omega, tau_fit);
R2_omega = calculate_Rsquared(omega_exp, polyval(P_omega, tau_exp));
omega_fit(omega_fit < 0) = 0; 

% --- B. Current–Torque Fit (i vs tau) ---
P_i = polyfit(tau_exp, i_exp, FIT_ORDER);
i_fit = polyval(P_i, tau_fit);
R2_i = calculate_Rsquared(i_exp, polyval(P_i, tau_exp));

%% ---------------------- 3. Derived Characteristics and Equation Strings -------------
P_out_exp = tau_exp .* omega_exp;
P_in_exp = V_in * i_exp;
eta_percent = (P_out_exp ./ P_in_exp) * 100;

P_out_fit = tau_fit .* omega_fit;
P_in_fit = V_in * i_fit;
eta_percent_fit = (P_out_fit ./ P_in_fit) * 100;

% --- Generate Equation Strings for Legend ---
p_omega = P_omega;
p_i = P_i;

% Speed-Torque Legend String: \omega = a\tau^2 + b\tau + c (uses LaTeX)
omega_legend_str = sprintf('$\\omega = %.4f\\tau^2 %+.4f\\tau %+.4f \\, (R^2 = %.4f)$', ...
                           p_omega(1), p_omega(2), p_omega(3), R2_omega);

% Current-Torque Legend String: i = a\tau^2 + b\tau + c (uses LaTeX)
i_legend_str = sprintf('$i = %.4f\\tau^2 %+.4f\\tau %+.4f  (R^2 = %.4f)$', ...
                      p_i(1), p_i(2), p_i(3), R2_i);

%% ---------------------- 4. Plotting Results ------------------------------

figure('Color','w','Position',[200 100 800 800]);
sgtitle(sprintf('DC Motor 12V Experimental Characteristics (Updated Data)'), 'FontSize', 16, 'FontWeight','bold');

% --- (1) Speed–Torque Characteristic ---
subplot(2,2,1);
plot(tau_exp, omega_exp, 'ko', 'MarkerSize', 8, 'MarkerFaceColor', [0.7 0.7 0.7], 'DisplayName', 'Experimental Data'); hold on;
% Use the equation string as the display name for the fitted curve
plot(tau_fit, omega_fit, '-', 'Color', [0 0 0.5], 'LineWidth', 2, 'DisplayName', omega_legend_str);
grid on;
title('Speed–Torque Characteristic');
xlabel('Load Torque \tau_L (N·m)');
ylabel('Angular Velocity \omega (rad/s)');
legend('Location', 'SouthWest', 'Interpreter', 'latex', 'FontSize', 10); % **Set Interpreter to LATEX**

% --- (2) Current–Torque Characteristic ---
subplot(2,2,2);
plot(tau_exp, i_exp, 'ko', 'MarkerSize', 8, 'MarkerFaceColor', [0.7 0.7 0.7], 'DisplayName', 'Experimental Data'); hold on;
% Use the equation string as the display name for the fitted curve
plot(tau_fit, i_fit, '-', 'Color', [0.6 0 0], 'LineWidth', 2, 'DisplayName', i_legend_str);
grid on;
title('Current–Torque Characteristic');
xlabel('Load Torque \tau_L (N·m)');
ylabel('Current (A)');
legend('Location', 'NorthWest', 'Interpreter', 'latex', 'FontSize', 10); % **Set Interpreter to LATEX**

% --- (3) Output Power vs Load Torque ---
subplot(2,2,3);
plot(tau_exp, P_out_exp, 'ko', 'MarkerSize', 8, 'MarkerFaceColor', [0.7 0.7 0.7], 'DisplayName', 'Experimental Data'); hold on;
plot(tau_fit, P_out_fit, '-', 'Color', [0 0.5 0], 'LineWidth', 2, 'DisplayName', 'Fitted Curve');
grid on;
title('Power-Torque Characteristic');
xlabel('Load Torque \tau_L (N·m)');
ylabel('Output Power P_{out} (W)');
legend('Location', 'NorthEast');
hold off;

% --- (4) Efficiency vs Load Torque ---
subplot(2,2,4);
plot(tau_exp, eta_percent, 'ko', 'MarkerSize', 8, 'MarkerFaceColor', [0.7 0.7 0.7], 'DisplayName', 'Experimental Data'); hold on;
plot(tau_fit, eta_percent_fit, '-', 'Color', [0.5 0 0.5], 'LineWidth', 2, 'DisplayName', 'Fitted Curve');
grid on;
title('Efficiency-Torque Characteristic');
xlabel('Load Torque \tau_L (N·m)');
ylabel('Efficiency \eta (%)');
legend('Location', 'NorthEast');
hold off;