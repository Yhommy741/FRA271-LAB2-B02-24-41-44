% ==============================================================
% Experiment: Frequency–Velocity Characterization of Stepper Motor
% Test Condition: Half Step, 3 Trials (30 s Each)
% ==============================================================

% -------------------------------
% Load all datasets
% -------------------------------
load("Half_20000hz_30s_1.mat");
freq1 = squeeze(data{1}.Values.Data);
w1    = squeeze(data{2}.Values.Data);

load("Half_20000hz_30s_2.mat");
freq2 = squeeze(data{1}.Values.Data);
w2    = squeeze(data{2}.Values.Data);

load("Half_20000hz_30s_3.mat");
freq3 = squeeze(data{1}.Values.Data);
w3    = squeeze(data{2}.Values.Data);

% -------------------------------
% Trim to equal length
% -------------------------------
minLength = min([length(freq1), length(freq2), length(freq3)]);

freq1 = freq1(1:minLength);
freq2 = freq2(1:minLength);
freq3 = freq3(1:minLength);

w1 = w1(1:minLength);
w2 = w2(1:minLength);
w3 = w3(1:minLength);

% -------------------------------
% Plot: Trials 1, 2, and 3
% -------------------------------
figure;

p1 = plot(freq1, w1, 'LineWidth', 1.3); hold on;
p2 = plot(freq2, w2, 'LineWidth', 1.3);
p3 = plot(freq3, w3, 'LineWidth', 1.3);

grid on;

xlabel('Input Frequency (Hz)', 'FontSize', 12);
ylabel('Angular Velocity \omega (rad/s)', 'FontSize', 12);

title('Experiment Measurement: Angular Velocity of Stepper Motor in Half Step Mode', ...
      'FontSize', 14, 'FontWeight', 'bold');

% -------------------------------
% Add Legend for Line Explanation
% -------------------------------
legend([p1 p2 p3], {'Trial 1', 'Trial 2', 'Trial 3'}, 'Location', 'best');

