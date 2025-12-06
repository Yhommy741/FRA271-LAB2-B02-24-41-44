%% --- Frequencies and number of files ---
freqs = [2000 5000 10000 15000 20000];
nFiles = 5;

avgSignals = cell(length(freqs),1);
timeAxis   = cell(length(freqs),1);

for f = 1:length(freqs)
    freq = freqs(f);
    fprintf("\nProcessing frequency %d Hz...\n", freq);

    allX = cell(nFiles,1);
    allT = cell(nFiles,1);
    minLen = inf;

    for k = 1:nFiles
        filename = sprintf("Wnl_Freq%d_%d.mat", freq, k);
        fprintf("  Loading %s\n", filename);
        S = load(filename);
        data = S.data;

        % --- extract CURRENT signal ---
        Isig = getCurrentsignal(data);

        % ❗ STOP if signal not found
        if isempty(Isig)
            error("❌ Current signal missing in file: %s", filename);
        end

        % Now safe to access
        t = Isig.Values.Time;
        I = Isig.Values.Data;

        allT{k} = t(:)';
        allX{k} = I(:)';

        minLen = min(minLen, length(I));
    end

    signals = zeros(nFiles, minLen);
    for k = 1:nFiles
        signals(k,:) = allX{k}(1:minLen);
    end

    timeAxis{f}   = allT{1}(1:minLen);
    avgSignals{f} = mean(signals,1);
end

%% --- Plot Current ---
figure; hold on; grid on;
colors = lines(length(freqs));

for f = 1:length(freqs)
    t = timeAxis{f};
    y = avgSignals{f};

    % Keep only t >= 2 seconds
    idx = t >= 2;

    plot(t(idx), y(idx), 'LineWidth', 1.5, 'Color', colors(f,:));
end

legend(string(freqs) + " Hz");
xlabel("Time (s)");
ylabel("Current (A)");
title("Average Motor Current for Each Frequency");

%% --- Local Function ---
function Isig = getCurrentsignal(data)
    Isig = [];

    for i = 1:numel(data)
        d = data{i};

        % === CASE 1: Dataset ===
        if isa(d,"Simulink.SimulationData.Dataset")
            for k = 1:d.numElements
                elem = d.getElement(k);

                % Direct signal
                if isSignalMatch(elem)
                    Isig = elem;
                    return;
                end

                % Nested Values: (must use isprop, not isfield)
                if isprop(elem,"Values") && isa(elem.Values,"Simulink.SimulationData.Signal")
                    if isSignalMatch(elem.Values)
                        Isig = elem.Values;
                        return;
                    end
                end
            end
        end

        % === CASE 2: Simple signal ===
        if isa(d,"Simulink.SimulationData.Signal")
            if isSignalMatch(d)
                Isig = d;
                return;
            end
        end
    end
end

function tf = isSignalMatch(sig)
    tf = false;

    % Name match
    if isprop(sig,"Name") && ~isempty(sig.Name)
        if contains(sig.Name,"Current","IgnoreCase",true)
            tf = true; return;
        end
    end

    % BlockPath match
    if isprop(sig,"BlockPath")
        try
            bp = char(sig.BlockPath.getBlock(1));
            if contains(bp,"Current","IgnoreCase",true)
                tf = true; return;
            end
        end
    end
end
