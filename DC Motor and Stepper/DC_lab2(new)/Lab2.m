%% Clean Up and Setup
clear; 
clc; 
% === CONSTANTS FOR EFFICIENCY CALCULATION ===
Kt = 0.0408;       % Torque Constant (N*m/A): torque = 0.408 * current
V_supply = 12;    % Supply Voltage (V): Vin = dutyCycle * 12V
% ================================================
% Define the list of duty cycles (0, 20, 40, 60, 80, 100)
duty_cycles = 0:20:100;
num_duty_cycles = length(duty_cycles);
% Define the list of frequencies (UPDATED)
frequencies = [2000, 5000, 10000, 15000, 20000];
num_frequencies = length(frequencies);
% Define the time intervals for aggregation: [start, end] in seconds
time_intervals = [
    3, 12;
    18, 27;
    33, 42;
    48, 57
];
num_intervals = size(time_intervals, 1);
% --- Initialize a structure array to store ALL results ---
all_results = struct('DutyCycle', {}, 'Frequency', {}, 'GrandAvgCurrent', {}, 'GrandAvgAngularVel', {}, 'GrandAvgEfficiency', {});
result_index = 1;
disp('========================================================================');
disp('                  STARTING DETAILED AVERAGE ANALYSIS                    ');
disp('========================================================================');
% --- Outer Loop: Data Processing ---
for d = 1:num_duty_cycles
    current_dc = duty_cycles(d);
    
    for f = 1:num_frequencies
        current_freq = frequencies(f);
        filename = sprintf("%d%%_%dHz.mat", current_dc, current_freq);
        
        try
            load(filename);
            
            % --- Data Extraction ---
            current = squeeze(data{1}.Values.Data);
            t_current = squeeze(data{1}.Values.Time);
            w = squeeze(data{2}.Values.Data);
            t_w = squeeze(data{2}.Values.Time);
            
            % Changed variable names back to avg_...
            avg_current_intervals = zeros(num_intervals, 1);
            avg_w_intervals = zeros(num_intervals, 1);
            
            % --- DETAILED COMMAND WINDOW OUTPUT START ---
            
            disp(['']);
            disp(['--- RESULTS FOR FILE: ', filename, ' (Mean) ---']);
            fprintf('%-10s | %-15s | %-15s\n', 'Interval', 'Avg Current (A)', 'Avg Omega (rad/s)');
            fprintf('---------------------------------------------------\n');
            
            % --- Loop through time intervals (Iterations) ---
            for i = 1:num_intervals
                t_start = time_intervals(i, 1);
                t_end = time_intervals(i, 2);
                
                % Current Calculation (MEAN)
                idx_current = t_current >= t_start & t_current <= t_end;
                avg_current_intervals(i) = mean(current(idx_current));
                
                % Angular Velocity Calculation (MEAN)
                idx_w = t_w >= t_start & t_w <= t_end;
                avg_w_intervals(i) = mean(w(idx_w));
                
                % Print detailed iteration results
                interval_label = sprintf('%d-%d s', t_start, t_end);
                fprintf('%-10s | %-15.4f | %-15.4f\n', ...
                    interval_label, ...
                    avg_current_intervals(i), ...
                    avg_w_intervals(i));
            end
            fprintf('---------------------------------------------------\n');
            
            % --- Grand Average Calculation (MEAN) ---
            grand_avg_current = mean(avg_current_intervals);
            grand_avg_w = mean(avg_w_intervals);
            
            % === NEW EFFICIENCY CALCULATION ===
            % Convert Duty Cycle percentage (0-100) to decimal (0-1)
            dc_decimal = current_dc / 100; 
            
            % Calculate Vin (Input Voltage)
            Vin = dc_decimal * V_supply; % Vin = dutyCycle * 12V
            
            % Calculate Torque (Torque = Kt * Current)
            grand_avg_torque = Kt * grand_avg_current; 
            
            % Calculate Power Out (P_out = Torque * Omega) and Power In (P_in = Vin * Current)
            P_out = grand_avg_torque * grand_avg_w;
            P_in = Vin * grand_avg_current;
            
            % Calculate Efficiency
            if P_in == 0
                grand_avg_efficiency = 0; % Avoid division by zero
            else
                grand_avg_efficiency = P_out / P_in;
            end
            
            % Cap efficiency at 1.0 (100%) due to noise/measurement errors
            grand_avg_efficiency = min(grand_avg_efficiency, 1.0);
            
            % ====================================
            % Print Grand Averages
            fprintf('%-10s | %-15.4f | %-15.4f | %-15.4f%%\n', ...
                'GRAND AVG', ...
                grand_avg_current, ...
                grand_avg_w, ...
                grand_avg_efficiency * 100); % Print as percentage
            disp(['']);
            % --- DETAILED COMMAND WINDOW OUTPUT END ---
            
            
            % --- Store Grand Results (for plotting) ---
            all_results(result_index).DutyCycle = current_dc;
            all_results(result_index).Frequency = current_freq;
            all_results(result_index).GrandAvgCurrent = grand_avg_current;
            all_results(result_index).GrandAvgAngularVel = grand_avg_w;
            % === NEW STORAGE FIELD ===
            all_results(result_index).GrandAvgEfficiency = grand_avg_efficiency * 100; % Store as percentage (0-100)
            % =========================
            
            result_index = result_index + 1;
        catch ME
            warning('MATLAB:FileLoad', 'Could not load file: %s. Skipping this combination.', filename);
        end 
    end 
end 
%% ========================================================================
%  PLOTTING SECTION (6 Figures 2D, 3 Figures 3D)
%% ========================================================================
if isempty(all_results)
    disp('No data files were loaded successfully. Cannot plot.');
    return;
end
% 1. Prepare data tables for PLOT vs. Duty Cycle (DC vs. Output)
results_table = struct2table(all_results);
W_table_dc = unstack(results_table, 'GrandAvgAngularVel', 'Frequency', 'GroupingVariables', 'DutyCycle');
I_table_dc = unstack(results_table, 'GrandAvgCurrent', 'Frequency', 'GroupingVariables', 'DutyCycle');
% === NEW TABLE FOR EFFICIENCY PLOT (DC) ===
E_table_dc = unstack(results_table, 'GrandAvgEfficiency', 'Frequency', 'GroupingVariables', 'DutyCycle');
% ==========================================
% 2. Prepare data tables for PLOT vs. Frequency (Freq vs. Output)
W_table_freq = unstack(results_table, 'GrandAvgAngularVel', 'DutyCycle', 'GroupingVariables', 'Frequency');
I_table_freq = unstack(results_table, 'GrandAvgCurrent', 'DutyCycle', 'GroupingVariables', 'Frequency');
% === NEW TABLE FOR EFFICIENCY PLOT (Freq) ===
E_table_freq = unstack(results_table, 'GrandAvgEfficiency', 'DutyCycle', 'GroupingVariables', 'Frequency');
% ============================================
% Plotting variables
plot_frequencies = W_table_dc.Properties.VariableNames(2:end); 
num_plot_freqs = length(plot_frequencies);
plot_duty_cycles = W_table_dc.DutyCycle;
plot_duty_cycles_freq = W_table_freq.Properties.VariableNames(2:end); 
num_plot_dcs = length(plot_duty_cycles_freq); 
plot_frequencies_x = W_table_freq.Frequency; 
colors = lines(max(num_plot_freqs, num_plot_dcs)); 
fit_order = 2; 

%% ------------------------------------------------------------------------
%  EXISTING 2D PLOTS (FIGURES 1, 2, 5, 3, 4, 6)
%% ------------------------------------------------------------------------
% ========================================================================
% --- Figure 1: Angular Velocity (w) vs. Duty Cycle ---
% ========================================================================
figure(1); hold on; legend_handles_1 = [];
for f = 1:num_plot_freqs
    freq_column_name = plot_frequencies{f};
    Y_data = W_table_dc.(freq_column_name);
    X_data = plot_duty_cycles;
    valid_indices = ~isnan(Y_data);
    X_clean = X_data(valid_indices); Y_clean = Y_data(valid_indices);
    line_color = colors(f,:); legend_label = [freq_column_name, ' Hz'];
    if length(X_clean) >= fit_order + 1 
        p = polyfit(X_clean, Y_clean, fit_order);
        x_fit = linspace(min(X_clean), max(X_clean), 100);
        y_fit = polyval(p, x_fit);
        h(1) = plot(x_fit, y_fit, 'Color', line_color, 'LineWidth', 2, 'DisplayName', legend_label);
        h(2) = plot(X_clean, Y_clean, 'o', 'Color', line_color, 'MarkerFaceColor', line_color, 'MarkerSize', 6);
        legend_handles_1 = [legend_handles_1, h(1)];
    else
        h(1) = plot(X_clean, Y_clean, 'o', 'Color', line_color, 'MarkerFaceColor', line_color, 'MarkerSize', 6, 'DisplayName', legend_label);
        legend_handles_1 = [legend_handles_1, h(1)];
    end
end
hold off;
legend(legend_handles_1, 'Location', 'best');
title('Relationship Between Angular Velocity & DutyCycle in Different PWM Frequency');
xlabel('Duty Cycle (%)');
ylabel('Anugular Velocity \omega (rad/s)', 'Interpreter', 'latex');
grid on; box on;
% ========================================================================
% --- Figure 2: Current (I) vs. Duty Cycle ---
% ========================================================================
figure(2); hold on; legend_handles_2 = [];
for f = 1:num_plot_freqs
    freq_column_name = plot_frequencies{f};
    Y_data = I_table_dc.(freq_column_name);
    X_data = plot_duty_cycles;
    valid_indices = ~isnan(Y_data);
    X_clean = X_data(valid_indices); Y_clean = Y_data(valid_indices);
    line_color = colors(f,:); legend_label = [freq_column_name, ' Hz'];
    if length(X_clean) >= fit_order + 1 
        p = polyfit(X_clean, Y_clean, fit_order);
        x_fit = linspace(min(X_clean), max(X_clean), 100);
        y_fit = polyval(p, x_fit);
        h(1) = plot(x_fit, y_fit, 'Color', line_color, 'LineWidth', 2, 'DisplayName', legend_label);
        h(2) = plot(X_clean, Y_clean, 's', 'Color', line_color, 'MarkerFaceColor', line_color, 'MarkerSize', 6);
        legend_handles_2 = [legend_handles_2, h(1)];
    else
        h(1) = plot(X_clean, Y_clean, 's', 'Color', line_color, 'MarkerFaceColor', line_color, 'MarkerSize', 6, 'DisplayName', legend_label);
        legend_handles_2 = [legend_handles_2, h(1)];
    end
end
hold off;
legend(legend_handles_2, 'Location', 'best');
title('Relationship Between Current & DutyCycle in Different PWM Frequency');
xlabel('Duty Cycle (%)');
ylabel('Current (A)', 'Interpreter', 'latex');
grid on; box on;
% ========================================================================
% --- Figure 5: Efficiency (E) vs. Duty Cycle ---
% ========================================================================
figure(5); hold on; legend_handles_5 = [];
for f = 1:num_plot_freqs
    freq_column_name = plot_frequencies{f};
    Y_data = E_table_dc.(freq_column_name); % Use the E_table_dc
    X_data = plot_duty_cycles;
    valid_indices = ~isnan(Y_data);
    X_clean = X_data(valid_indices); Y_clean = Y_data(valid_indices);
    line_color = colors(f,:); legend_label = [freq_column_name, ' Hz'];
    if length(X_clean) >= fit_order + 1 
        p = polyfit(X_clean, Y_clean, fit_order);
        x_fit = linspace(min(X_clean), max(X_clean), 100);
        y_fit = polyval(p, x_fit);
        h(1) = plot(x_fit, y_fit, 'Color', line_color, 'LineWidth', 2, 'DisplayName', legend_label);
        h(2) = plot(X_clean, Y_clean, 'd', 'Color', line_color, 'MarkerFaceColor', line_color, 'MarkerSize', 6);
        legend_handles_5 = [legend_handles_5, h(1)];
    else
        h(1) = plot(X_clean, Y_clean, 'd', 'Color', line_color, 'MarkerFaceColor', line_color, 'MarkerSize', 6, 'DisplayName', legend_label);
        legend_handles_5 = [legend_handles_5, h(1)];
    end
end
hold off;
legend(legend_handles_5, 'Location', 'best');
title('Relationship Between Efficiency & DutyCycle in Different PWM Frequency');
xlabel('Duty Cycle (%)');
ylabel('Efficiency (%)', 'Interpreter', 'latex');
grid on; box on;
% ========================================================================
% --- Figure 3: Angular Velocity (w) vs. Frequency Subplots ---
% ========================================================================
rows = 2;
cols = 3; 
figure(3);
sgtitle('Relationship Between Angular Velocity & PWM Frequency in Different DutyCycle');
for d = 1:num_plot_dcs
    subplot(rows, cols, d);
    hold on;
    
    dc_column_name = plot_duty_cycles_freq{d};
    Y_data_w = W_table_freq.(dc_column_name);
    X_data = plot_frequencies_x;
    
    valid_indices = ~isnan(Y_data_w);
    X_clean = X_data(valid_indices); 
    Y_clean = Y_data_w(valid_indices);
    
    current_color = [0 0.4470 0.7410]; 
    if length(X_clean) >= fit_order + 1 
        p = polyfit(X_clean, Y_clean, fit_order);
        x_fit = linspace(min(X_clean), max(X_clean), 100);
        y_fit = polyval(p, x_fit);
        plot(x_fit, y_fit, 'Color', current_color, 'LineWidth', 2);
        plot(X_clean, Y_clean, 'o', 'Color', current_color, 'MarkerFaceColor', current_color, 'MarkerSize', 5);
    else
        plot(X_clean, Y_clean, 'o', 'Color', current_color, 'MarkerFaceColor', current_color, 'MarkerSize', 5);
    end
    
    hold off;
    title(sprintf('%s%% DutyCycle', dc_column_name));
    xlabel('Frequency (Hz)');
    ylabel('Anugular Velocity \omega (rad/s)', 'Interpreter', 'latex');
    grid on; box on;
end
% ========================================================================
% --- Figure 4: Current (I) vs. Frequency Subplots ---
% ========================================================================
figure(4);
sgtitle('Relationship Between Current & PWM Frequency in Different DutyCycle');
for d = 1:num_plot_dcs
    subplot(rows, cols, d);
    hold on;
    
    dc_column_name = plot_duty_cycles_freq{d};
    Y_data_i = I_table_freq.(dc_column_name);
    X_data = plot_frequencies_x;
    
    valid_indices = ~isnan(Y_data_i);
    X_clean = X_data(valid_indices); 
    Y_clean = Y_data_i(valid_indices);
    
    current_color = [0.8500 0.3250 0.0980];
    
    if length(X_clean) >= fit_order + 1 
        p = polyfit(X_clean, Y_clean, fit_order);
        x_fit = linspace(min(X_clean), max(X_clean), 100);
        y_fit = polyval(p, x_fit);
        plot(x_fit, y_fit, 'Color', current_color, 'LineWidth', 2);
        plot(X_clean, Y_clean, 's', 'Color', current_color, 'MarkerFaceColor', current_color, 'MarkerSize', 5);
    else
        plot(X_clean, Y_clean, 's', 'Color', current_color, 'MarkerFaceColor', current_color, 'MarkerSize', 5);
    end
    
    hold off;
    title(sprintf('%s%% DutyCycle', dc_column_name));
    xlabel('Frequency (Hz)');
    ylabel('Current (A)', 'Interpreter', 'latex');
    grid on; box on;
end
% ========================================================================
% --- Figure 6: Efficiency (E) vs. Frequency Subplots --- 
% ========================================================================
figure(6);
sgtitle('Relationship Between Efficiency & PWM Frequency in Different DutyCycle');
for d = 1:num_plot_dcs
    subplot(rows, cols, d);
    hold on;
    
    dc_column_name = plot_duty_cycles_freq{d};
    Y_data_e = E_table_freq.(dc_column_name); % Use the E_table_freq
    X_data = plot_frequencies_x;
    
    valid_indices = ~isnan(Y_data_e);
    X_clean = X_data(valid_indices); 
    Y_clean = Y_data_e(valid_indices);
    
    current_color = [0.4660 0.6740 0.1880]; % Greenish color
    
    if length(X_clean) >= fit_order + 1 
        p = polyfit(X_clean, Y_clean, fit_order);
        x_fit = linspace(min(X_clean), max(X_clean), 100);
        y_fit = polyval(p, x_fit);
        plot(x_fit, y_fit, 'Color', current_color, 'LineWidth', 2);
        plot(X_clean, Y_clean, 'd', 'Color', current_color, 'MarkerFaceColor', current_color, 'MarkerSize', 5);
    else
        plot(X_clean, Y_clean, 'd', 'Color', current_color, 'MarkerFaceColor', current_color, 'MarkerSize', 5);
    end
    
    hold off;
    title(sprintf('%s%% DutyCycle', dc_column_name));
    xlabel('Frequency (Hz)');
    ylabel('Efficiency (%)', 'Interpreter', 'latex');
    grid on; box on;
end

%% ------------------------------------------------------------------------
%  NEW 3D PLOTS (FIGURES 7, 8, 9)
%% ------------------------------------------------------------------------

% Extract X, Y, Z data in matrix format for surf plot
X_vec = duty_cycles; % Duty Cycle values (0, 20, ..., 100)
Y_vec = frequencies; % Frequency values (2000, 5000, ..., 20000)

% Create X and Y grid matrices (Duty Cycle as X-axis, Frequency as Y-axis)
% [DC_grid, F_grid] = meshgrid(X_vec, Y_vec) will result in a 5x6 grid.
[DC_grid, F_grid] = meshgrid(X_vec, Y_vec); 

% The unstacked tables (W_table_dc, etc.) have Duty Cycle as rows (6) and 
% Frequency as columns (5). We must transpose the table data to match the meshgrid dimensions (5x6).
Z_w = table2array(W_table_dc(:, 2:end))'; 
Z_i = table2array(I_table_dc(:, 2:end))';
Z_eff = table2array(E_table_dc(:, 2:end))';

% --- Plot 7: Angular Velocity (w) 3D Surface Plot ---
figure(7);
surf(DC_grid, F_grid, Z_w);
title('Angular Velocity \omega vs. Duty Cycle and Frequency');
xlabel('Duty Cycle (%)');
ylabel('Frequency (Hz)');
zlabel('Angular Velocity \omega (rad/s)');
colorbar;
shading interp; % Smooth the surface colors
view(3); % Set 3D view

% --- Plot 8: Current (I) 3D Surface Plot ---
figure(8);
surf(DC_grid, F_grid, Z_i);
title('Current I vs. Duty Cycle and Frequency');
xlabel('Duty Cycle (%)');
ylabel('Frequency (Hz)');
zlabel('Current (A)');
colorbar;
shading interp;
view(3);

% --- Plot 9: Efficiency (Eff) 3D Surface Plot ---
figure(9);
surf(DC_grid, F_grid, Z_eff);
title('Efficiency \eta vs. Duty Cycle and Frequency');
xlabel('Duty Cycle (%)');
ylabel('Frequency (Hz)');
zlabel('Efficiency (%)');
colorbar;
shading interp;
view(3);