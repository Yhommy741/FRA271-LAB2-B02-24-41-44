clear; clc; close all;

% ------------------
% Motor Parameters
% ------------------
% Stall torque (Nm)
tau_st_12 = 0.2037;
tau_st_9  = 0.1637;
tau_st_6  = 0.1025;

% Assume no-load speed scales linearly with voltage.
% --- CHANGE THIS TO YOUR ACTUAL MOTOR NO-LOAD SPEED ---
omega_nl_12 = 500;    % rad/s (example)
omega_nl_9  = omega_nl_12 * (9/12);
omega_nl_6  = omega_nl_12 * (6/12);

% ------------------
% Torque vector
% ------------------
tau = linspace(0, max([tau_st_12 tau_st_9 tau_st_6]), 200);

% ------------------
% Angular velocity model: ω = ω_nl (1 - τ/τ_st)
% ------------------
omega_12 = omega_nl_12 * (1 - tau/tau_st_12);
omega_9  = omega_nl_9  * (1 - tau/tau_st_9);
omega_6  = omega_nl_6  * (1 - tau/tau_st_6);

% Remove negative values
omega_12(omega_12<0) = NaN;
omega_9(omega_9<0)   = NaN;
omega_6(omega_6<0)   = NaN;

% ------------------
% Plot
% ------------------
figure; hold on; grid on;

plot(tau, omega_12, 'LineWidth', 2);
plot(tau, omega_9,  'LineWidth', 2);
plot(tau, omega_6,  'LineWidth', 2);

xlabel('Torque (Nm)');
ylabel('Angular Velocity (rad/s)');
title('Torque vs Angular Velocity at Different Voltages');
legend('12 V','9 V','6 V','Location','northeast');

