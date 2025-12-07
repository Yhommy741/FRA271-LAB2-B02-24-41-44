% -----------------------------
% Define Load Conditions and Time Windows
% -----------------------------

% --- PHYSICAL CONSTANTS (VERIFY RADIUS!) ---
GRAVITY = 9.81; % Acceleration due to gravity (m/s^2)
PULLEY_RADIUS = 0.015; % Assumed pulley radius (m). **ADJUST THIS VALUE BASED ON YOUR SETUP.**

% Loads to process (100g to 1300g, step 100g)
loads = 100:100:1300; 
% Number of repeats (iterations) per load
num_repeats = 4;

% Time window for current (i)
t_start_i = 2.3;
t_end_i = 2.8;
% Time window for angular velocity (w)
t_start_w = 2.5;
t_end_w = 2.95;

% Initialize final arrays to store the GRAND AVERAGES for each load
final_avg_currents = zeros(length(loads), 1);
final_avg_omegas = zeros(length(loads), 1);
% Initialize array for the calculated Torque values
all_torque_values = zeros(length(loads), 1);

fprintf('Starting analysis for %d different load conditions...\n', length(loads));

% -----------------------------
% Outer Loop: Iterate through each Load
% -----------------------------
for load_index = 1:length(loads)
    current_load_g = loads(load_index);
    
    % --- CONVERSION: Load (g) to Torque (Nm) ---
    current_load_kg = current_load_g / 1000;
    current_torque = current_load_kg * GRAVITY * PULLEY_RADIUS;
    all_torque_values(load_index) = current_torque; 
    
    % Initialize temporary arrays for this specific load's repeats
    avg_currents_per_repeat = zeros(num_repeats, 1);
    avg_omegas_per_repeat = zeros(num_repeats, 1);
    
    fprintf('\n--- Analyzing Load: %dg (Torque: %.4f Nm) ---\n', current_load_g, current_torque);
    
    % -----------------------------
    % Inner Loop: Iterate through the 4 Repeats (k=1 to 4)
    % -----------------------------
    for k = 1:num_repeats
        % Construct the file name using the current load and repeat number
        current_file = sprintf('%dg_12V_%d.mat', current_load_g, k);
        
        % Check if file exists before trying to load (good practice)
        if exist(current_file, 'file') ~= 2
            warning('File not found: %s. Skipping this repeat.', current_file);
            avg_currents_per_repeat(k) = NaN; % Use NaN for skipped runs
            avg_omegas_per_repeat(k) = NaN;
            continue; % Skip to the next iteration
        end
        
        % Load dataset
        load(current_file);
        
        % Extract data
        i  = squeeze(data{1}.Values.Data);
        t_i = squeeze(data{1}.Values.Time);
        w  = squeeze(data{2}.Values.Data);
        t_w = squeeze(data{2}.Values.Time);
        
        % --- Calculate Average Current ---
        idx_i = (t_i >= t_start_i) & (t_i <= t_end_i);
        avg_currents_per_repeat(k) = mean(i(idx_i));
        
        % --- Calculate Average Angular Velocity ---
        idx_w = (t_w >= t_start_w) & (t_w <= t_end_w);
        avg_omegas_per_repeat(k) = mean(w(idx_w));
        
    end % End of Inner Loop (repeats)
    
    % -----------------------------
    % Calculate Grand Averages for the Current Load
    % -----------------------------
    
    % Use nanmean to correctly handle NaN values (skipped runs)
    final_avg_currents(load_index) = nanmean(avg_currents_per_repeat);
    final_avg_omegas(load_index) = nanmean(avg_omegas_per_repeat);

end % End of Outer Loop (loads)

% -----------------------------
% Display Final Results Table
% -----------------------------
fprintf('\n======================================================================\n');
fprintf('        FINAL RESULTS: DC Motor Performance (Torque-Based)\n');
fprintf(' (Pulley Radius used: %.4f m)\n', PULLEY_RADIUS);
fprintf('======================================================================\n');
fprintf('Torque (Nm) | Avg Current (A) | Avg Omega (rad/s)\n');
fprintf('----------------------------------------------------------------------\n');

results_table = table(...
    all_torque_values, ...
    final_avg_currents, ...
    final_avg_omegas, ...
    'VariableNames', {'Torque_Nm', 'Avg_Current_A', 'Avg_Omega_rad_s'});

disp(results_table);


% -----------------------------
% Plotting Motor Characteristics (Current vs Torque & Omega vs Torque)
% -----------------------------
figure;

% Plot 1: Avg Current vs Torque
subplot(2,1,1);
plot(all_torque_values, final_avg_currents, '-o', 'LineWidth', 1.5, 'MarkerSize', 6);
grid on;
title('Average Current vs Torque', 'FontSize', 14, 'FontWeight', 'bold');
xlabel('Torque (Nm)', 'FontSize', 12);
ylabel('Avg Current (A)', 'FontSize', 12);

% Plot 2: Avg Angular Velocity vs Torque
subplot(2,1,2);
plot(all_torque_values, final_avg_omegas, '-s', 'LineWidth', 1.5, 'MarkerSize', 6);
grid on;
title('Average Angular Velocity ($\omega$) vs Torque', 'FontSize', 14, 'FontWeight', 'bold');
xlabel('Torque (Nm)', 'FontSize', 12);
ylabel('Avg $\omega$ (rad/s)', 'FontSize', 12);

sgtitle('DC Motor Characteristic Curves', 'FontSize', 16, 'FontWeight', 'bold');