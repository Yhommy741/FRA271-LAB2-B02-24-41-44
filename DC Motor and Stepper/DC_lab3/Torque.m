%% ============================================================
%       Stall Torque & Current Calculation for All Voltages
%       Shown on a Single Figure with Automatically Positioned Text Boxes
% ============================================================

clear; clc;

%% ---------------------- Load Data --------------------------------
load("Stall_12V_Freq5000_1.mat"); data12 = data;
load("Stall_9V_Freq5000_1.mat");  data9  = data;
load("Stall_6V_Freq5000_1.mat");  data6  = data;

datasets = {data12, data9, data6};
voltages = [12, 9, 6];  % Volts
colors = [0 0.4470 0.7410; 0.8500 0.3250 0.0980; 0.9290 0.6940 0.1250]; % Blue, Orange, Yellow
arm_length = 0.1105;    % meters

%% ---------------------- Preallocate results ----------------------
stallTorque = zeros(1,length(datasets));
stallCurrent = zeros(1,length(datasets));

%% ---------------------- Process Each Dataset --------------------
figure('Color','w','Position',[200 100 1000 600]);

subplot(2,1,1); hold on; grid on; box on;
ylabel('Weight (g)','FontSize',12,'FontWeight','bold');
title('Experiment Measurement of Stall Torque & Stall Current','FontSize',14,'FontWeight','bold');

subplot(2,1,2); hold on; grid on; box on;
xlabel('Time (s)','FontSize',12,'FontWeight','bold');
ylabel('Current (A)','FontSize',12,'FontWeight','bold');

for v = 1:length(datasets)
    D = datasets{v};
    
    % Extract data
    t_w = D{2}.Values.Time;  x_w = squeeze(D{2}.Values.Data);
    t_i = D{1}.Values.Time;  x_i = squeeze(D{1}.Values.Data);

    % Trim to 30–104 s
    idx_w = (t_w >= 30) & (t_w <= 104);
    idx_i = (t_i >= 30) & (t_i <= 104);
    t_w_cut = t_w(idx_w); x_w_cut = x_w(idx_w);
    t_i_cut = t_i(idx_i); x_i_cut = x_i(idx_i);

    % Average weight using repeating windows
    [avgVals_w, winTimes] = averageRepeatingWindows(t_w, x_w);
    selectedAvg_w = avgVals_w(5:14);  % windows 5–14
    avg_g = mean(selectedAvg_w);
    avg_N = (avg_g / 1000) * 9.81;    % g -> N
    avgT_st = avg_N * arm_length;     % Torque
    stallTorque(v) = avgT_st;

    % Average current using same windows
    avgVals_i = zeros(size(avgVals_w));
    for k = 1:size(winTimes,1)
        s = winTimes(k,1);
        e = winTimes(k,2);
        idx = (t_i >= s) & (t_i <= e);
        avgVals_i(k) = mean(x_i(idx));
    end
    selectedAvg_i = avgVals_i(5:14);
    avgCurrent = mean(selectedAvg_i);
    stallCurrent(v) = avgCurrent;

    % Plot Weight
    subplot(2,1,1);
    plot(t_w_cut, x_w_cut,'Color',colors(v,:),'LineWidth',1.6);

    % Plot Current
    subplot(2,1,2);
    plot(t_i_cut, x_i_cut,'Color',colors(v,:),'LineWidth',1.6);
end

subplot(2,1,1); legend('12 V','9 V','6 V','Location','best','FontSize',12);
subplot(2,1,2); legend('12 V','9 V','6 V','Location','best','FontSize',12);

%% ---------------------- Add Automatically Spaced Text Boxes -------------------
n = length(datasets);        % number of voltages
top_margin = 0.05;           % margin from top of subplot
vertical_span = 0.15;        % total span for all boxes

% Torque Text Boxes (top subplot)
subplot(2,1,1);
ax1 = gca;
ylim1 = ax1.YLim;
xlim1 = ax1.XLim;

for v = 1:n
    % evenly space from top down
    yPos = ylim1(2) - top_margin*(ylim1(2)-ylim1(1)) - ((v-1)/(n-1))*vertical_span*(ylim1(2)-ylim1(1));
    xPos = xlim1(1) + 0.05*(xlim1(2)-xlim1(1));
    text(xPos, yPos, sprintf('%d V Avg Torque = %.4f N·m', voltages(v), stallTorque(v)), ...
        'FontSize',11, 'FontWeight','bold', 'Color',colors(v,:), ...
        'BackgroundColor','white', 'EdgeColor',colors(v,:), 'LineWidth',1.2);
end

% Current Text Boxes (bottom subplot)
subplot(2,1,2);
ax2 = gca;
ylim2 = ax2.YLim;
xlim2 = ax2.XLim;

for v = 1:n
    yPos = ylim2(2) - top_margin*(ylim2(2)-ylim2(1)) - ((v-1)/(n-1))*vertical_span*(ylim2(2)-ylim2(1));
    xPos = xlim2(1) + 0.05*(xlim2(2)-xlim2(1));
    text(xPos, yPos, sprintf('%d V Avg Current = %.3f A', voltages(v), stallCurrent(v)), ...
        'FontSize',11, 'FontWeight','bold', 'Color',colors(v,:), ...
        'BackgroundColor','white', 'EdgeColor',colors(v,:), 'LineWidth',1.2);
end

%% ============================================================
%      Local Function: Average Repeating Windows
% ============================================================
function [avgValues, windowTimes] = averageRepeatingWindows(t, x)
    start0 = 1;   % first window start (s)
    width  = 4;   % window width (s)
    period = 7.5; % distance between windows

    maxT = max(t);
    avgValues = [];
    windowTimes = [];

    for s = start0:period:maxT
        e = s + width;
        if s > maxT, break; end
        idx = (t >= s) & (t <= e);
        if any(idx)
            avgValues(end+1) = mean(x(idx));
            windowTimes(end+1,:) = [s,e];
        end
    end
end
