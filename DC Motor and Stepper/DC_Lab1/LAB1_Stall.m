%% ============================================================
%                MAIN SCRIPT START
% ============================================================

clear; clc;
load("Stall_torque_12V_Freq5000.mat");

%% ----------------- Extract Weight Data (grams) -----------------
t_w = data{3}.Values.Time;
x_w = data{3}.Values.Data;

%% ----------------- Extract Current Data (A) --------------------
t_i = data{1}.Values.Time;
x_i = data{1}.Values.Data;

%% ----------------- Trim data to 30–104 seconds -----------------
idx_w = (t_w >= 30) & (t_w <= 104);
idx_i = (t_i >= 30) & (t_i <= 104);

t_w_cut = t_w(idx_w);
x_w_cut = x_w(idx_w);

t_i_cut = t_i(idx_i);
x_i_cut = x_i(idx_i);

%% ----------------- Weight averaging windows --------------------
[avgVals_w, winTimes] = averageRepeatingWindows(t_w, x_w);

% Use windows 5–14
selectedAvg_w = avgVals_w(5:14);

% Convert gram → Newton
avg_g = mean(selectedAvg_w);
avg_N = (avg_g / 1000) * 9.81;

% Torque (Force × radius)
arm_length = 0.1105;  % meters
avgT_st = avg_N * arm_length;

fprintf("Average Stall Torque = %.4f N·m\n", avgT_st);


%% ============================================================
%         Compute average CURRENT using SAME time windows
% ============================================================

avgVals_i = zeros(size(avgVals_w));

for k = 1:size(winTimes,1)
    s = winTimes(k,1);
    e = winTimes(k,2);
    idx = (t_i >= s) & (t_i <= e);
    avgVals_i(k) = mean(x_i(idx));
end

selectedAvg_i = avgVals_i(5:14);
avgCurrent = mean(selectedAvg_i);

fprintf("Average Stall Current = %.3f A\n", avgCurrent);


%% ============================================================
%                          PLOTTING
% ============================================================

figure('Color','w');

% -------- Weight Plot --------
subplot(2,1,1);
plot(t_w_cut, x_w_cut, 'LineWidth', 1.5);
grid on;
ylabel('Weight (g)', 'FontSize', 12, 'FontWeight','bold');
title('Experimental Measurement of Stall Torque & Stall Current for a DC Motor at 12 V', ...
      'FontSize', 14, 'FontWeight','bold');
set(gca,'FontSize',12,'LineWidth',1);
box on;

% Annotate torque only (weight graph)
text(0.02, 0.90, sprintf('Avg Stall Torque = %.4f N·m', avgT_st), ...
     'Units','normalized', 'FontSize',12, 'FontWeight','bold', ...
     'BackgroundColor','white','EdgeColor','black');


% -------- Current Plot --------
subplot(2,1,2);
plot(t_i_cut, x_i_cut, 'LineWidth', 1.5);
grid on;
xlabel('Time (s)', 'FontSize',12,'FontWeight','bold');
ylabel('Current (A)', 'FontSize',12,'FontWeight','bold');
set(gca,'FontSize',12,'LineWidth',1);
box on;

% Annotate CURRENT (on current graph)
text(0.02, 0.90, sprintf('Avg Stall Current = %.3f A', avgCurrent), ...
     'Units','normalized', 'FontSize',12, 'FontWeight','bold', ...
     'BackgroundColor','white','EdgeColor','black');


%% ============================================================
%                LOCAL FUNCTION (must be last)
% ============================================================
function [avgValues, windowTimes] = averageRepeatingWindows(t, x)
% Averages data inside repeating windows

    start0 = 1;        % first window start (sec)
    width  = 4;        % window width (sec)
    period = 7.5;      % distance between windows

    maxT = max(t);
    starts = start0 : period : maxT;

    avgValues = [];
    windowTimes = [];

    for s = starts
        e = s + width;
        if s > maxT, break; end

        idx = (t >= s) & (t <= e);

        if any(idx)
            avgValues(end+1) = mean(x(idx));
            windowTimes(end+1,:) = [s, e];
        end
    end
end
