% ========================================================================
%  DC Motor Characteristics: Ideal vs. Experimental (Combined Plot)
% ========================================================================
clear; clc;

%% ---------------------- 1. EXPERIMENTAL DATA INPUT ---------------------
V_in = 12; % Input Voltage

% Data extracted from the provided table (NEW DATA)
tau_exp = [0.014715, 0.02943, 0.044145, 0.05886, 0.073575, 0.08829, 0.103, 0.11772, 0.13243, 0.14715, 0.16187, 0.17658, 0.1913]; % Torque (Nm)
i_exp   = [1.874, 2.1867, 2.7637, 2.9952, 3.3907, 3.7072, 3.9666, 4.1694, 4.3948, 4.5808, 4.6491, 4.7064, 4.7287]; % Average Current (A)
omega_exp = [149.12, 112.99, 96.644, 66.276, 67.077, 56.328, 46.863, 32.399, 25.149, 15.487, 8.6049, 3.1657, 1.3491]; % Angular Velocity (rad/s)

FIT_ORDER = 2; 
tau_range = linspace(min(tau_exp), max(tau_exp), 500); % Range for plotting smooth curves

%% ---------------------- 2. EXPERIMENTAL FIT CALCULATION -----------------
% --- Function to calculate R-Squared (for legend display) ---
calculate_Rsquared = @(y_exp, f_fit) (1 - sum((y_exp - f_fit).^2) / sum((y_exp - mean(y_exp)).^2));

% --- Speed–Torque Fit ---
P_omega = polyfit(tau_exp, omega_exp, FIT_ORDER);
omega_fit = polyval(P_omega, tau_range);
R2_omega = calculate_Rsquared(omega_exp, polyval(P_omega, tau_exp));
omega_fit(omega_fit < 0) = 0; 

% --- Current–Torque Fit ---
P_i = polyfit(tau_exp, i_exp, FIT_ORDER);
i_fit = polyval(P_i, tau_range);
R2_i = calculate_Rsquared(i_exp, polyval(P_i, tau_exp));

% Derived Characteristics (Experimental Fit)
P_out_fit = tau_range .* omega_fit;
eta_percent_fit = (P_out_fit ./ (V_in * i_fit)) * 100;

% Experimental Data (for plotting points)
P_out_exp = tau_exp .* omega_exp;
eta_percent_exp = (P_out_exp ./ (V_in * i_exp)) * 100;


%% ---------------------- 3. IDEAL LINEAR MODEL CALCULATION ----------------

% Use the SPECIFIC Ideal Parameters provided by the user
T_st     = 0.1699;
i_ST     = 4.164;
omega_NL = 192.211;
i_NL     = 1.142;

% Use a range specific to the Ideal model's T_st for maximum clarity
tau_ideal_range = linspace(0, T_st, 500);

% ----------------- IDEAL LINEAR CURVES -----------------
% Linear Speed: ω(τ_L) = ω_NL * (1 - τ_L / T_st)
omega_ideal = omega_NL * (1 - tau_ideal_range / T_st);
omega_ideal(omega_ideal < 0) = 0; % Speed cannot be negative

% Linear Current: i(τ_L) = i_NL + (i_ST - i_NL)*(τ_L / T_st)
i_ideal = i_NL + (i_ST - i_NL) .* (tau_ideal_range / T_st);

% Linear Derived Characteristics
P_out_ideal = tau_ideal_range .* omega_ideal;
eta_ideal   = (P_out_ideal ./ (V_in * i_ideal)) * 100;


%% ---------------------- 4. GENERATE LEGEND STRINGS ---------------------

% Speed-Torque Fit Equation String (for Plot 1)
p_omega = P_omega;
omega_fit_str = sprintf('$\\omega = %.4f\\tau^2 %+.4f\\tau %+.4f \\, (R^2 = %.4f)$', ...
                           p_omega(1), p_omega(2), p_omega(3), R2_omega);

% Current-Torque Fit Equation String (for Plot 2)
p_i = P_i;
i_fit_str = sprintf('$i = %.4f\\tau^2 %+.4f\\tau %+.4f  (R^2 = %.4f)$', ...
                      p_i(1), p_i(2), p_i(3), R2_i);


%% ---------------------- 5. PLOTTING RESULTS ------------------------------

figure('Color','w','Position',[200 100 800 800]);
sgtitle('Comparision of Ideal & Experimental Model for DC Motor 12V Characteristics', 'FontSize', 16, 'FontWeight','bold');

% --- (1) Speed–Torque Characteristic ---
subplot(2,2,1);
% Plot 1: Experimental Data Points
plot(tau_exp, omega_exp, 'ko', 'MarkerSize', 6, 'MarkerFaceColor', [0.7 0.7 0.7], 'DisplayName', 'Experimental Data'); hold on;
% Plot 2: Polynomial Fitted Curve
plot(tau_range, omega_fit, '-', 'Color', [0 0 0.5], 'LineWidth', 2, 'DisplayName', ['Fitted: ' omega_fit_str]);
% Plot 3: Ideal Linear Model Curve
plot(tau_ideal_range, omega_ideal, '--', 'Color', [0.8 0 0], 'LineWidth', 1.5, 'DisplayName', 'Ideal Linear Model');
grid on;
title('Speed–Torque Characteristic');
xlabel('Load Torque \tau_L (N·m)');
ylabel('Angular Velocity \omega (rad/s)');
legend('Location', 'SouthWest', 'Interpreter', 'latex', 'FontSize', 9); 

% --- (2) Current–Torque Characteristic ---
subplot(2,2,2);
% Plot 1: Experimental Data Points
plot(tau_exp, i_exp, 'ko', 'MarkerSize', 6, 'MarkerFaceColor', [0.7 0.7 0.7], 'DisplayName', 'Experimental Data'); hold on;
% Plot 2: Polynomial Fitted Curve
plot(tau_range, i_fit, '-', 'Color', [0.6 0 0], 'LineWidth', 2, 'DisplayName', ['Fitted: ' i_fit_str]);
% Plot 3: Ideal Linear Model Curve
plot(tau_ideal_range, i_ideal, '--', 'Color', [0 0.5 0], 'LineWidth', 1.5, 'DisplayName', 'Ideal Linear Model');
grid on;
title('Current–Torque Characteristic');
xlabel('Load Torque \tau_L (N·m)');
ylabel('Current (A)');
legend('Location', 'NorthWest', 'Interpreter', 'latex', 'FontSize', 9); 

% --- (3) Output Power vs Load Torque ---
subplot(2,2,3);
% Plot 1: Experimental Data Points
plot(tau_exp, P_out_exp, 'ko', 'MarkerSize', 6, 'MarkerFaceColor', [0.7 0.7 0.7], 'DisplayName', 'Experimental Data'); hold on;
% Plot 2: Polynomial Fitted Curve
plot(tau_range, P_out_fit, '-', 'Color', [0 0.5 0], 'LineWidth', 2, 'DisplayName', 'Experimental Fit');
% Plot 3: Ideal Linear Model Curve
plot(tau_ideal_range, P_out_ideal, '--', 'Color', [0.5 0.5 0], 'LineWidth', 1.5, 'DisplayName', 'Ideal Linear Model');
grid on;
title('Power-Torque Characteristic');
xlabel('Load Torque \tau_L (N·m)');
ylabel('Output Power P_{out} (W)');
legend('Location', 'NorthEast');
hold off;

% --- (4) Efficiency vs Load Torque ---
subplot(2,2,4);
% Plot 1: Experimental Data Points
plot(tau_exp, eta_percent_exp, 'ko', 'MarkerSize', 6, 'MarkerFaceColor', [0.7 0.7 0.7], 'DisplayName', 'Experimental Data'); hold on;
% Plot 2: Polynomial Fitted Curve
plot(tau_range, eta_percent_fit, '-', 'Color', [0.5 0 0.5], 'LineWidth', 2, 'DisplayName', 'Experimental Fit');
% Plot 3: Ideal Linear Model Curve
plot(tau_ideal_range, eta_ideal, '--', 'Color', [0 0 0], 'LineWidth', 1.5, 'DisplayName', 'Ideal Linear Model');
grid on;
title('Efficiency-Torque Characteristic');
xlabel('Load Torque \tau_L (N·m)');
ylabel('Efficiency \eta (%)');
legend('Location', 'NorthEast');
hold off;