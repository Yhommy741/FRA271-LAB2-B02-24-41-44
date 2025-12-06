%% ========================================================================
%                 Motor Characteristics Visualization
%       Based on Linear DC Motor Model for Laboratory Analysis
%
%   Governing Relations:
%       ω(τ_L) = ω_NL * (1 - τ_L / T_st)
%       i(τ_L) = i_NL + (i_ST - i_NL)*(τ_L / T_st)
%       P_out(τ_L) = τ_L * ω(τ_L)
%       η(τ_L) = P_out / (V_in * i)
%
%   Given (Measured from Experiment):
%       T_st   = 0.1699  N·m       (Stall Torque)
%       i_ST   = 4.164   A         (Stall Current)
%       ω_NL   = 192.211 rad/s     (No-Load Angular Velocity)
%       i_NL   = 1.142   A         (No-Load Current)
%
%   Purpose: Scientific Laboratory Documentation
% ========================================================================

clear; clc;

%% ---------------------- Motor Parameters -------------------------------
T_st     = 0.1699;      % Stall torque (N·m)
i_ST     = 4.164;       % Stall current (A)
omega_NL = 192.211;     % No-load angular velocity (rad/s)
i_NL     = 1.142;       % No-load current (A)

V_in = 12;              % Supply voltage (V)

%% ---------------------- Load Torque Range ------------------------------
tauL = linspace(0, T_st, 600);

%% ---------------------- 1. Speed–Torque Relation -----------------------
omega = omega_NL .* (1 - tauL / T_st);

%% ---------------------- 2. Current–Torque Relation ---------------------
i = i_NL + (i_ST - i_NL) .* (tauL / T_st);

%% ---------------------- 3. Output Mechanical Power ---------------------
P_out = tauL .* omega;
[~, idxP] = max(P_out);
P_max = P_out(idxP);

%% ---------------------- 4. Efficiency ----------------------------------
P_in = V_in .* i;
eta = P_out ./ P_in;

%% ---------------------- Plotting --------------------------------------
figure('Color','w','Position',[200 100 1100 780]);

sgtitle('DC Motor 12V Characteristics', ...
        'FontSize', 16, 'FontWeight','bold');   % << MAIN TITLE

% ---------------- (1) Speed vs Torque ----------------------------------
subplot(2,2,1);
plot(tauL, omega, 'LineWidth', 1.8); grid on;
xlabel('Load Torque \tau_L (N·m)', 'FontWeight','bold');
ylabel('Angular Velocity \omega (rad/s)', 'FontWeight','bold');
title('Speed–Torque Characteristic', 'FontWeight','bold', 'FontSize', 12);

% ---------------- (2) Current vs Torque ---------------------------------
subplot(2,2,2);
plot(tauL, i, 'r', 'LineWidth', 1.8); grid on;
xlabel('Load Torque \tau_L (N·m)', 'FontWeight','bold');
ylabel('Current i (A)', 'FontWeight','bold');
title('Current–Torque Characteristic', 'FontWeight','bold', 'FontSize', 12);

% ---------------- (3) Output Power vs Torque ----------------------------
subplot(2,2,3);
plot(tauL, P_out, 'LineWidth', 1.8); grid on; hold on;
xlabel('Load Torque \tau_L (N·m)', 'FontWeight','bold');
ylabel('Output Power P_{out} (W)', 'FontWeight','bold');
title('Output Power vs Load Torque', 'FontWeight','bold', 'FontSize', 12);

% Mark Maximum Power (dot instead of circle)
plot(tauL(idxP), P_out(idxP), '.', 'MarkerSize', 22, 'Color', 'r');
text(tauL(idxP), P_out(idxP), sprintf('  P_{max} = %.2f W', P_max), ...
     'FontWeight','bold');

% ---------------- (4) Efficiency vs Torque ------------------------------
subplot(2,2,4);
plot(tauL, eta, 'LineWidth', 1.8); grid on;
xlabel('Load Torque \tau_L (N·m)', 'FontWeight','bold');
ylabel('Efficiency \eta', 'FontWeight','bold');
title('Efficiency vs Load Torque', 'FontWeight','bold', 'FontSize', 12);
