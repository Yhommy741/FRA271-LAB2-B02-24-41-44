%%%% --- Frequencies and number of files ---
freqs = [2000 5000 10000 15000 20000];
nFiles = 5;

avgSignals = cell(length(freqs),1);
timeAxis = cell(length(freqs),1);   % <-- FIX

for f = 1:length(freqs)
    freq = freqs(f);
    fprintf("Processing frequency %d Hz...\n", freq);

    allX = cell(nFiles,1);
    allT = cell(nFiles,1);
    minLen = inf;

    for k = 1:nFiles
        filename = sprintf("Wnl_Freq%d_%d.mat", freq, k);
        fprintf("  Loading %s\n", filename);
        S = load(filename);
        data = S.data;

        Wsig = getWsignal(data);

        t = Wsig.Values.Time;
        x = Wsig.Values.Data;

        allT{k} = t(:)';
        allX{k} = x(:)';

        minLen = min(minLen, length(x));
    end

    signals = zeros(nFiles, minLen);
    for k = 1:nFiles
        signals(k,:) = allX{k}(1:minLen);
    end

    timeAxis{f} = allT{1}(1:minLen);   % <-- FIX
    avgSignals{f} = mean(signals, 1);
end

%% --- Plot ---
figure; hold on; grid on;
colors = lines(length(freqs));

for f = 1:length(freqs)
    plot(timeAxis{f}, avgSignals{f}, 'LineWidth', 1.5, 'Color', colors(f,:));
end

legend(string(freqs) + " Hz");
xlabel("Time (s)");
ylabel("Amplitude");
title("Average Speed Signal W for Each Frequency");



%% --- ROBUST W-SIGNAL FINDER FUNCTION ---
function Wsig = getWsignal(data)
%GETWSIGNAL Extracts the W signal from a Simulink Dataset or nested Datasets.

    Wsig = [];  % default

    % If top-level is Dataset
    if isa(data, "Simulink.SimulationData.Dataset")
        N = data.numElements;
        for i = 1:N
            el = data{i};

            % Case 1: direct signal
            if isa(el, "Simulink.SimulationData.Signal")
                if strcmpi(strtrim(el.Name), "W")
                    Wsig = el;
                    return;
                end
            end

            % Case 2: nested dataset
            if isa(el, "Simulink.SimulationData.Dataset")
                try
                    Wsig = getWsignal(el);
                    if ~isempty(Wsig)
                        return;
                    end
                catch
                end
            end
        end
    end

    if isempty(Wsig)
        error("W signal not found in this MAT file.");
    end
end
