%% ============================================================
%   Torque–Speed Curves for DC Motor at 12 V, 9 V, and 6 V
%   Automatically Positioned Text Boxes
% ============================================================

clear; clc; close all;

%% ---------------------- Motor Parameters ----------------------

voltages = [12, 9, 6];   % volts

stallTorque = [ ...
    0.2037;   % 12V
    0.1637;   % 9V
    0.1025];  % 6V

% No-load speeds scale linearly with voltage
% --- CHANGE this if you have actual motor no-load speed ---
omega_nl_12 = 500;               % rad/s (example)
omega_nl = omega_nl_12 * (voltages ./ 12);

colors = [0 0.4470 0.7410;
          0.8500 0.3250 0.0980;
          0.9290 0.6940 0.1250];

%% ---------------------- Torque vector --------------------------
tau = linspace(0, max(stallTorque), 200);

%% ---------------------- Compute ω(τ) curves --------------------

omega_curves = zeros(length(voltages), length(tau));

for k = 1:length(voltages)
    omega = omega_nl(k) * (1 - tau / stallTorque(k));  % linear model
    omega(omega < 0) = NaN;
    omega_curves(k,:) = omega;
end

%% ---------------------- Plot ----------------------------------
figure('Color','w','Position',[300 150 900 600]);
hold on; grid on; box on;

title('Torque–Speed Relationship of DC Motor in 6V 9V & 12V at Frequency 5000Hz','FontSize',14,'FontWeight','bold');
xlabel('Torque (N·m)','FontSize',12,'FontWeight','bold');
ylabel('Angular Velocity (rad/s)','FontSize',12,'FontWeight','bold');

for k = 1:length(voltages)
    plot(tau, omega_curves(k,:), 'LineWidth', 2.0, 'Color', colors(k,:));
end

legend('12 V','9 V','6 V','Location','northeast','FontSize',12);

%% ============================================================
%                 End of Script
% ============================================================
