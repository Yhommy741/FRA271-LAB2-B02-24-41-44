%% ------------------------------------------------------------
%     No-Load Angular Velocity and Current Calculation
% ------------------------------------------------------------
clear; clc;
%% ---------------------- Load Data --------------------------------
% NOTE: Assuming Angular Velocity (w) is in {2} and Current (i) is in {1}
load("Wnl_12V_Freq5000_1.mat"); data12 = data;
load("Wnl_9V_Freq5000_1.mat");  data9  = data;
load("Wnl_6V_Freq5000_1.mat");  data6  = data;
datasets = {data12, data9, data6};
voltages = [12, 9, 6];  % Volts
colors = [0 0.4470 0.7410; 0.8500 0.3250 0.0980; 0.9290 0.6940 0.1250]; % Blue, Orange, Yellow

%% ---------------------- Preallocate results ----------------------
avgAngularVelocity = zeros(1,length(datasets));
avgNoLoadCurrent   = zeros(1,length(datasets));
%% ---------------------- Process Each Dataset --------------------
figure('Color','w','Position',[200 100 1000 600]);
subplot(2,1,1); hold on; grid on; box on;
ylabel('Angular Velocity (rad/s)','FontSize',12,'FontWeight','bold');
title('Experimental Measurement of No Load Angluar Velocity & Current','FontSize',14,'FontWeight','bold');
subplot(2,1,2); hold on; grid on; box on;
xlabel('Time (s)','FontSize',12,'FontWeight','bold');
ylabel('No-Load Current (A)','FontSize',12,'FontWeight','bold');

for v = 1:length(datasets)
    D = datasets{v};
    
    % --- 1. Angular Velocity (w) ---
    t_w = D{2}.Values.Time;  x_w = squeeze(D{2}.Values.Data);
    
    % Average angular velocity using repeating windows (t[3-7], t[10-14], ...)
    [avgVals_w, winTimes] = averageRepeatingWindows(t_w, x_w);
    avg_w = mean(avgVals_w);
    avgAngularVelocity(v) = avg_w;
    
    % Plot Angular Velocity
    subplot(2,1,1);
    plot(t_w, x_w,'Color',colors(v,:),'LineWidth',1.6);
    
    % --- 2. Current (i) ---
    t_i = D{1}.Values.Time;  x_i = squeeze(D{1}.Values.Data);
    
    % Average current using same windows (winTimes from w calculation)
    avgVals_i = zeros(size(avgVals_w));
    for k = 1:size(winTimes,1)
        s = winTimes(k,1);
        e = winTimes(k,2);
        idx = (t_i >= s) & (t_i <= e);
        if any(idx)
             avgVals_i(k) = mean(x_i(idx));
        end
    end
    avgCurrent = mean(avgVals_i);
    avgNoLoadCurrent(v) = avgCurrent;
    
    % Plot Current
    subplot(2,1,2);
    plot(t_i, x_i,'Color',colors(v,:),'LineWidth',1.6);
end

subplot(2,1,1); legend('12 V','9 V','6 V','Location','best','FontSize',12);
subplot(2,1,2); legend('12 V','9 V','6 V','Location','best','FontSize',12);

%% ---------------------- Add Automatically Spaced Text Boxes -------------------
n = length(datasets);        % number of voltages
top_margin = 0.05;           % margin from top of subplot
vertical_span = 0.15;        % total span for all boxes

% Angular Velocity Text Boxes (top subplot)
subplot(2,1,1);
ax1 = gca;
ylim1 = ax1.YLim;
xlim1 = ax1.XLim;
for v = 1:n
    yPos = ylim1(2) - top_margin*(ylim1(2)-ylim1(1)) - ((v-1)/(n-1))*vertical_span*(ylim1(2)-ylim1(1));
    xPos = xlim1(1) + 0.05*(xlim1(2)-xlim1(1));
    text(xPos, yPos, sprintf('%d V Avg Angular Velocity = %.2f rad/s', voltages(v), avgAngularVelocity(v)), ...
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
    text(xPos, yPos, sprintf('%d V Avg Current = %.3f A', voltages(v), avgNoLoadCurrent(v)), ...
        'FontSize',11, 'FontWeight','bold', 'Color',colors(v,:), ...
        'BackgroundColor','white', 'EdgeColor',colors(v,:), 'LineWidth',1.2);
end

%% ============================================================
%      Local Function: Average Repeating Windows
%      Set for t[3-7], t[10-14], t[17-21], ...
% ============================================================
function [avgValues, windowTimes] = averageRepeatingWindows(t, x)
    start0 = 3;   % first window start (s)
    width  = 4;   % window width (s)
    period = 7;   % distance between windows
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