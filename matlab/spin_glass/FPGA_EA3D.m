% =========================================================================
% Edwards–Anderson 3D Spin Glass — Simulated Annealing on FPGA
% Author: Navid Anjum Aadit (UC Santa Barbara, OPUS LAB)
% -------------------------------------------------------------------------
% Simulated annealing of the EA 3D Ising spin glass on distributed FPGA p-bit
% fabric with a linear β schedule. Residual energy is tracked vs time and the
% gap to the known ground energy is reported (%). 
% Can run immediately after the CPU demo (reusing its UI) or standalone.
% =========================================================================

% Ensure common helpers are on MATLAB path
repo_root = fileparts(fileparts(mfilename('fullpath')));  % one level up from demo folder
addpath(fullfile(repo_root, 'common'));

%% Defaults when launched standalone (overridden if CPU script already set them)
if ~exist('instanceSize','var'),    instanceSize    = 37;  end
if ~exist('instanceID','var'),      instanceID      = 0;   end
if ~exist('run_timeout_sec','var'), run_timeout_sec = 10;  end   % seconds

%% Reuse UI if present; otherwise build the same layout (and a Run button)
needNewUI = ~exist('hFig','var') || ~ishandle(hFig) || ~exist('hAxes','var') || ~ishandle(hAxes) || ...
            ~exist('progress_axes','var') || ~ishandle(progress_axes) || ...
            ~exist('progress_bar','var') || ~ishandle(progress_bar) || ...
            ~exist('info_text','var') || ~ishandle(info_text);

if needNewUI
    % Visual parameters (match CPU style)
    fontBase    = 18;
    fontBig     = 20;
    groundColor = [0.00 0.55 0.00];
    xlim_time   = [0, run_timeout_sec];
    residual_ylim = [-0.05, 1.00];

    % Figure
    hFig = figure('NumberTitle','off','Units','normalized','OuterPosition',[0 0 1 1], ...
                  'Color','w','Name',sprintf('L=%d, ID=%04d',instanceSize,instanceID));

    % Left image
    hSubplot1 = subplot(1,2,1);
    imgPathFPGA = './images/distributed_PC.png';
    if exist(imgPathFPGA,'file')
        imshow(imgPathFPGA);
    else
        imshow(ones(100,100));
        text(0.05,0.5,'(FPGA slide missing)','Units','normalized','FontSize',fontBig,'FontWeight','bold','Color','k');
    end
    set(hSubplot1,'Position',[0.01, 0.1, 0.45, 0.85]);

    % Right plot
    energyPlotPosition = [0.52, 0.15, 0.45, 0.6];
    hAxes = axes('Position', energyPlotPosition); hold(hAxes,'on'); box(hAxes,'on');
    set(hAxes,'FontSize',fontBase,'LineWidth',1.5,'FontWeight','bold');
    xlabel(hAxes,'Time (s)','FontSize',fontBase,'FontWeight','bold');
    ylabel(hAxes,'Residual Energy','FontSize',fontBase,'FontWeight','bold');
    xlim(hAxes, xlim_time);
    ylim(hAxes, residual_ylim);
    grid(hAxes,'on');
    ticks  = get(hAxes,'YTick');
    labels = arrayfun(@(x) sprintf('%.2f',x), ticks, 'UniformOutput', false);
    labels(abs(ticks + 0.05) < 1e-12) = {''};     % hide −0.05 label only
    set(hAxes,'YTick',ticks,'YTickLabel',labels);

    % Ground reference line
    yline(hAxes, 0, '--', 'Color', groundColor, 'LineWidth', 2.0, 'DisplayName','residual = 0 (ground)');

    % Progress panel
    wbHeight = 0.13; wbWidth = 0.27; wbXPosition = 0.56; wbYPosition = 0.8;
    progress_axes = axes('Parent', hFig, 'Position', [wbXPosition, wbYPosition, wbWidth, wbHeight], ...
                         'XLim', [0 1], 'YLim', [0 1]);
    axis(progress_axes,'off');
    progress_bar = rectangle('Parent', progress_axes, 'Position', [0 0 0 1], ...
                             'FaceColor', [0 1 0], 'EdgeColor', 'none');
    info_text = text('Parent', progress_axes, 'Position', [0.1, 0.5], 'String', '', ...
                     'FontSize', 18, 'FontWeight', 'bold');

    % Title above progress bar
    text('Parent', progress_axes, 'Units','normalized','Position',[0.22, 1.1], ...
         'String', sprintf('Solving: L=%d, ID=%04d', instanceSize, instanceID), ...
         'FontSize', 18, 'FontWeight', 'bold', 'HorizontalAlignment','left', ...
         'VerticalAlignment','bottom', 'Color','k');

    % Standalone "run FPGA" button and wait gate (mirrors CPU button behavior)
    btnWidth  = 0.1; btnHeight = 0.05; top_margin = 0.075; right_margin = 0.03;
    leftPosFPGA  = 1 - btnWidth - right_margin;
    bottomPosFPGA= 1 - btnHeight - top_margin;

    set(hFig, 'UserData', struct('runFPGA', false));
    uicontrol('Parent', hFig, 'Style', 'pushbutton', 'String', 'run FPGA', ...
        'Units', 'normalized', 'Position', [leftPosFPGA, bottomPosFPGA, btnWidth, btnHeight], ...
        'FontWeight', 'bold', 'FontSize', 18, 'Callback', @fpgaButtonCallbackStandalone, ...
        'BackgroundColor', [0.00 0.65 0.35], 'ForegroundColor', [1 1 1]);

    while ~hFig.UserData.runFPGA
        if ~ishandle(hFig); return; end
        pause(0.1);
    end
else
    % If reusing CPU UI, retitle if present
    if exist('runTitleTextHandle','var') && isgraphics(runTitleTextHandle)
        set(runTitleTextHandle,'String',sprintf('Solving: L=%d, ID=%04d', instanceSize, instanceID));
    end
end

%% Remove CPU curve if present and rebuild legend with FPGA + ground
cpuLines = findobj(hAxes,'Type','line','-and','DisplayName','CPU SA'); delete(cpuLines);
groundLine = findobj(hAxes,'Type','ConstantLine');   % keep
fpgaColor  = [0.85 0.33 0.10]; fpgaFace = [1 1 1];
hLineFPGA = plot(hAxes, NaN, NaN, 's-','MarkerSize',4.5,'LineWidth',1.75, ...
                 'Color',fpgaColor,'MarkerFaceColor',fpgaFace,'MarkerEdgeColor',fpgaColor, ...
                 'DisplayName','FPGA SA');

legendHandles = hLineFPGA; legendNames = {'FPGA SA'};
if ~isempty(groundLine) && isgraphics(groundLine(1))
    legendHandles(end+1) = groundLine(1); legendNames{end+1} = 'residual = 0 (ground)';
end
hLeg = legend(hAxes, legendHandles, legendNames, 'Location','northeast','Box','off','FontSize',18,'FontWeight','bold');
set(hLeg,'AutoUpdate','off');

set(progress_bar,'Position',[0 0 0 1]); set(info_text,'String',''); drawnow;

%% FPGA/experiment knobs
partitionTool     = 'potts';     % 'potts' | 'metis' | 'kahip'
cut               = 5139;        % for 'potts'
num_sweeps        = 10;          % sweeps read per beta
max_PingRetries   = 50;

% Hard wall time
timeout_sec = run_timeout_sec;

%% Instance and ground energy
if ~exist('J','var') || isempty(J)
    pathName  = fullfile(sprintf('./instances/size%02d', instanceSize));
    addpath(pathName);
    JFileName = ['JOrig_' num2str(instanceID,'%04d') '.mat'];
    load(JFileName,'J');
    rmpath(pathName);
end
W = sparse(J); N = size(W,1); h = zeros(1,N); target = double(logical(J)); num_pbits = N;

if ~exist('groundEnergy','var') || isempty(groundEnergy)
    geFile = sprintf('./Ground_energies/energyData_L=%d.txt', instanceSize);
    if exist(geFile,'file')
        ge = load(geFile); groundEnergy = ge(instanceID+1, 2);
    else
        warning('ground:missing','groundEnergy file missing; progress gap%% uses current best only.');
        groundEnergy = NaN;
    end
end

%% Cache matrices
cacheDir = './fpga_cache'; if ~exist(cacheDir,'dir'); mkdir(cacheDir); end
cacheTag = sprintf('L%02d_ID%04d_%s', instanceSize, instanceID, lower(partitionTool));
if strcmpi(partitionTool,'potts'), cacheTag = sprintf('%s_cut%d', cacheTag, cut); end
cacheFile = fullfile(cacheDir, ['saved_matrices_' cacheTag '.mat']);

needCompute = true;
if exist(cacheFile,'file')
    S = load(cacheFile);
    shuffle_indices        = S.shuffle_indices;
    target_graph           = S.target_graph;
    max_num_neighbors      = S.max_num_neighbors;
    triu_adjacency         = S.triu_adjacency;
    J_indices              = S.J_indices;
    J_binary_reshaped      = S.J_binary_reshaped;
    h_binary               = S.h_binary;
    partition_J_indices    = S.partition_J_indices;
    partition_pbit_indices = S.partition_pbit_indices;
    part_pbits             = S.part_pbits;
    num_partitions         = S.num_partitions;
    needCompute = false;
end

if needCompute
    if strcmpi(partitionTool, 'potts')
        load(sprintf('./optimal_partitions/optimal_potts_partitions_target_L%02d_6parts_cut%d.mat', instanceSize, cut));
    else
        load(sprintf('./optimal_partitions/optimal_%s_partitions_target_L%02d_6parts.mat', partitionTool, instanceSize));
    end
    partitions_unique = double(unique(partitions));
    num_partitions = length(partitions_unique);

    shuffle_indices = zeros(1, num_pbits);
    current_index = 1;
    for i = 1:num_partitions
        indices = find(partitions == partitions_unique(i));
        shuffle_indices(current_index:current_index + length(indices) - 1) = indices;
        current_index = current_index + length(indices);
    end

    target_graph = target(shuffle_indices, shuffle_indices);
    max_num_neighbors = max(degree(graph(target_graph)));

    W_shuffled = W(shuffle_indices, shuffle_indices);
    J_bipolar  = W_shuffled;
    h_bipolar  = h(shuffle_indices)';  % zeros

    [triu_adjacency, J_indices] = get_triu_adjacency(target_graph, max_num_neighbors);
    J_indices = sparse(J_indices);
    [J_binary_reshaped, h_binary] = triu_weight_converter(J_bipolar, h_bipolar, J_indices, max_num_neighbors);

    partition_J_indices    = cell(1, num_partitions);
    partition_pbit_indices = cell(1, num_partitions);
    part_pbits             = zeros(1, num_partitions);

    start_index = 1;
    for part = 1:num_partitions
        part_pbits(part) = nnz(partitions == partitions_unique(part));
        end_index = start_index + part_pbits(part) - 1;
        partition_pbit_indices{part} = start_index:end_index;

        for m = start_index:end_index
            upper_adj = triu_adjacency(m, :);
            partition_J_indices{part} = full(unique([partition_J_indices{part}, upper_adj]));
        end
        start_index = end_index + 1;
    end

    save(cacheFile, 'shuffle_indices','target_graph','max_num_neighbors', ...
        'triu_adjacency','J_indices','J_binary_reshaped','h_binary', ...
        'partition_J_indices','partition_pbit_indices','part_pbits','num_partitions');
end

%% Clock divider factors to each FPGA (if present in design)
original_freq = 15e6;
divider_factor = 0 ;
comm_divider_factor = 0;
if divider_factor == 0
    pbit_clk = original_freq;
else
    pbit_clk = original_freq/2/divider_factor;
end
% if no clock divider, set it directly
% pbit_clk = 35e6;

bram_read_clk = 100e6;
%% communication clock divider (if present in design)
if comm_divider_factor == 0
    bram_read_clk_slow = bram_read_clk;
else
    bram_read_clk_slow = bram_read_clk/2/comm_divider_factor;
end

ref_clk = 125e6; %200 MHz clock counts 200e6 in 1s

%% Annealing schedule
beta = 0.5:0.5:5;
compute_energy_betas = beta;

fixed_a = 4; fixed_b = 1; % fixed points as ([s]a.b), a=int bits, b=fraction bits
actual_sweeps_per_beta = 1.2e7;
time_per_beta = actual_sweeps_per_beta/pbit_clk; % input time per JT

RESET = 1; SHIFT = 1;

%% Ethernet AXI managers (retry on ping)
fpga_memories = cell(1, num_partitions);
for i = 1:num_partitions
    fpgaID  = i; success = false; attempts = 0;
    while ~success && attempts < max_PingRetries
        [status, ~] = system(['ping 192.168.0.', num2str(fpgaID), ' -n 1']);
        if status ~= 0
            attempts = attempts + 1; continue;
        end
        try
            fpga_memories{i} = aximanager('AMD','interface','PLEthernet', ...
                'DeviceAddress',['192.168.0.',num2str(fpgaID)], ...
                'Port',num2str(50100+fpgaID));
            success = true;
        catch
            attempts = attempts + 1;
            fprintf('AXI manager creation attempt %d for FPGA %d failed. Retrying...\n',attempts,fpgaID);
        end
    end
    if ~success
        error('Failed to create AXI manager for FPGA %d after %d attempts. Reprogram and retry.',fpgaID);
    end
end

%% Address map
weight_address                  = hex2dec('007A1220');
h_address                       = hex2dec('00802CA0');
reset_tictoc_address            = hex2dec('00000000');
tictoc_counter_limit_address    = hex2dec('00000004');
s_address                       = hex2dec('00000020');
J_trigger_address               = hex2dec('0081B340');
h_trigger_address               = hex2dec('0081B344'); %#ok<NASGU>
frozen_flag_address             = hex2dec('0081B348');
weight_load_done_flag_address   = hex2dec('0081B34C');
clock_divider_address           = hex2dec('0081B368');
clock_enable_address            = hex2dec('0081B36C');
comm_clock_divider_address      = hex2dec('0081B370');
comm_clock_enable_address       = hex2dec('0081B374');

tictoc_counter_limit_per_beta  = ceil(ref_clk*time_per_beta);
tictoc_counter_limit_per_sweep = ceil(ref_clk*time_per_beta/num_sweeps);

%% Clock configuration across FPGAs
for i = 1:num_partitions
    writememory_with_retry(fpga_memories{i}, clock_enable_address, 0,  'Fixed', max_PingRetries, i);
    writememory_with_retry(fpga_memories{i}, clock_divider_address, uint32(divider_factor), 'Fixed', max_PingRetries, i);
    writememory_with_retry(fpga_memories{i}, clock_enable_address, 1,  'Fixed', max_PingRetries, i);
end

%% Randomize initialization with beta=0
for i = 1:num_partitions
    writememory_with_retry(fpga_memories{i}, tictoc_counter_limit_address, uint32(tictoc_counter_limit_per_sweep), 'Fixed', max_PingRetries, i);
end
for i = 1:num_partitions
    writememory_with_retry(fpga_memories{i}, comm_clock_enable_address, 0,  'Fixed', max_PingRetries, i);
    writememory_with_retry(fpga_memories{i}, comm_clock_divider_address, uint32(0),  'Fixed', max_PingRetries, i);
    writememory_with_retry(fpga_memories{i}, comm_clock_enable_address, 1,  'Fixed', max_PingRetries, i);
end

[J_fpga0,h_fpga0] = fixed_point_weights (fixed_a, fixed_b, 0, J_binary_reshaped, h_binary);
for i = 1:num_partitions
    start_idx = partition_pbit_indices{i}(1);
    end_idx   = partition_pbit_indices{i}(end);
    partition_J_idx = partition_J_indices{i};
    writememory_with_retry(fpga_memories{i}, weight_address, J_fpga0(partition_J_idx), 'Increment', max_PingRetries, i);
    writememory_with_retry(fpga_memories{i}, h_address, h_fpga0(start_idx:end_idx), 'Increment', max_PingRetries, i);
    writememory_with_retry(fpga_memories{i}, J_trigger_address, [SHIFT SHIFT], 'Increment', max_PingRetries, i);
end

loaded = 0;
while ~loaded
    loaded = readmemory_with_retry(fpga_memories{end}, weight_load_done_flag_address, 1, 'Increment', max_PingRetries, num_partitions);
end
writememory_with_retry(fpga_memories{1}, reset_tictoc_address, RESET, 'Increment', max_PingRetries, 1);
frozen = 0;
while ~frozen
    frozen = readmemory_with_retry(fpga_memories{end}, frozen_flag_address, 1, 'Increment', max_PingRetries, num_partitions);
end

% Restore desired communication divider
for i = 1:num_partitions
    writememory_with_retry(fpga_memories{i}, comm_clock_enable_address, 0,  'Fixed', max_PingRetries, i);
    writememory_with_retry(fpga_memories{i}, comm_clock_divider_address, uint32(comm_divider_factor),  'Fixed', max_PingRetries, i);
    writememory_with_retry(fpga_memories{i}, comm_clock_enable_address, 1,  'Fixed', max_PingRetries, i);
end

%% Buffers and labels
s_shuffled = zeros(num_sweeps, num_pbits);
s_buf      = zeros(num_sweeps, num_pbits);
resid_fpga = [];
tvec_fpga  = [];
bestResid  = inf;

xlabel(hAxes,'Time (s)','FontSize',18,'FontWeight','bold');
ylabel(hAxes,'Residual Energy','FontSize',18,'FontWeight','bold');
grid(hAxes,'on');

%% Run schedule with hard timeout; zero-offset for plotted time
compute_energy_flag_prev = false;
overall_tic = tic;
t0_offset = [];          % set on first data point
timeoutHit = false;

for kk = 1:length(beta)
    if timeoutHit, break; end

    [J_fpga,h_fpga] = fixed_point_weights (fixed_a, fixed_b, beta(kk), J_binary_reshaped, h_binary);
    for i = 1:num_partitions
        start_idx = partition_pbit_indices{i}(1);
        end_idx   = partition_pbit_indices{i}(end);
        partition_J_idx = partition_J_indices{i};
        writememory_with_retry(fpga_memories{i}, weight_address, J_fpga(partition_J_idx), 'Increment', max_PingRetries, i);
        writememory_with_retry(fpga_memories{i}, h_address, h_fpga(start_idx:end_idx), 'Increment', max_PingRetries, i);
        writememory_with_retry(fpga_memories{i}, J_trigger_address, [SHIFT SHIFT], 'Increment', max_PingRetries, i);
    end
    loaded = 0;
    while ~loaded
        loaded = readmemory_with_retry(fpga_memories{end}, weight_load_done_flag_address, 1, 'Increment', max_PingRetries, num_partitions);
    end

    compute_energy_flag = ismember(beta(kk), compute_energy_betas);
    if (compute_energy_flag ~= compute_energy_flag_prev) || (kk == 1)
        if compute_energy_flag
            for i = 1:num_partitions
                writememory_with_retry(fpga_memories{i}, tictoc_counter_limit_address, uint32(tictoc_counter_limit_per_sweep), 'Fixed', max_PingRetries, i);
            end
        else
            for i = 1:num_partitions
                writememory_with_retry(fpga_memories{i}, tictoc_counter_limit_address, uint32(tictoc_counter_limit_per_beta), 'Fixed', max_PingRetries, i);
            end
        end
        compute_energy_flag_prev = compute_energy_flag;
    end

    if compute_energy_flag
        for k = 1:num_sweeps
            % Wall time and zero-offset
            tAbs = toc(overall_tic);
            if isempty(t0_offset), t0_offset = tAbs; end
            tPlot = tAbs - t0_offset;
            if tPlot >= timeout_sec
                timeoutHit = true; break;
            end

            % One sweep: step, freeze, read states
            writememory_with_retry(fpga_memories{1}, reset_tictoc_address, RESET, 'Increment', max_PingRetries, 1);
            frozen = 0;
            while ~frozen
                frozen = readmemory_with_retry(fpga_memories{end}, frozen_flag_address, 1, 'Increment', max_PingRetries, num_partitions);
            end

            start_idx = 1;
            for i = 1:num_partitions
                end_idx = start_idx + part_pbits(i) - 1;
                s_shuffled(k, start_idx:end_idx) = readmemory_with_retry(fpga_memories{i}, s_address + (start_idx - 1) * 4, part_pbits(i), 'Increment', max_PingRetries, i);
                start_idx = end_idx + 1;
            end
            s_buf(k, shuffle_indices) = s_shuffled(k, :);

            % Energy and residual
            m = 2 * s_buf(k, :) - 1;
            E = -0.5 * (m * (W * m')) - (h * m');
            r = (E - groundEnergy)/N;

            resid_fpga(end+1) = r;             %#ok<AGROW>
            tvec_fpga(end+1)  = tPlot;         %#ok<AGROW>

            if r < bestResid, bestResid = r; end
            set(hLineFPGA,'XData',tvec_fpga,'YData',resid_fpga);

            % Progress and info text (current + best)
            progressFraction = min(tPlot / timeout_sec, 1);
            set(progress_bar, 'Position', [0 0 progressFraction 1]);
            flips_taken = tPlot * pbit_clk * num_pbits;
            runPct      = round(progressFraction * 100);

            if isfinite(groundEnergy)
                curGapPct  = max(0, 100 * (r * N) / abs(groundEnergy));
                bestGapPct = max(0, 100 * (bestResid * N) / abs(groundEnergy));
                info_str = sprintf(['Progress: %d%%\n' ...
                                    'Gap to ground: %.2f%%  |  Best: %.2f%%\n' ...
                                    'Flips: %s   Time: %.2f s'], ...
                                    runPct, curGapPct, bestGapPct, ...
                                    formatFlips(flips_taken), tPlot);
            else
                info_str = sprintf(['Progress: %d%%\n' ...
                                    'Residual: %.4f  |  Best: %.4f\n' ...
                                    'Flips: %s   Time: %.2f s'], ...
                                    runPct, r, bestResid, ...
                                    formatFlips(flips_taken), tPlot);
            end
            set(info_text,'String',info_str);

            drawnow;
            if ~ishandle(hFig), timeoutHit = true; break; end
        end
        if timeoutHit, break; end
    else
        % Single long interval (no reads)
        writememory_with_retry(fpga_memories{1}, reset_tictoc_address, RESET, 'Increment', max_PingRetries, 1);
        frozen = 0;
        while ~frozen
            frozen = readmemory_with_retry(fpga_memories{end}, frozen_flag_address, 1, 'Increment', max_PingRetries, num_partitions);
        end

        % Progress heartbeat
        tAbs = toc(overall_tic);
        if isempty(t0_offset), t0_offset = tAbs; end
        tPlot = tAbs - t0_offset;

        if tPlot >= timeout_sec
            timeoutHit = true;
        end
        progressFraction = min(tPlot / timeout_sec, 1);
        set(progress_bar, 'Position', [0 0 progressFraction 1]);
        flips_taken = tPlot * pbit_clk * num_pbits;
        runPct      = round(progressFraction * 100);

        if isfinite(groundEnergy) && isfinite(bestResid)
            bestGapPct = max(0, 100 * (bestResid * N) / abs(groundEnergy));
            info_str = sprintf('Progress: %d%%\nBest: %.2f%%\nFlips: %s   Time: %.2f s', ...
                               runPct, bestGapPct, formatFlips(flips_taken), tPlot);
        else
            info_str = sprintf('Progress: %d%%\nFlips: %s   Time: %.2f s', ...
                               runPct, formatFlips(flips_taken), tPlot);
        end
        set(info_text,'String',info_str);
        drawnow;

        if timeoutHit, break; end
    end
end

%% Finalize and release (show CURRENT and BEST like CPU)
if isempty(t0_offset)
    tPlot = 0; r_end = NaN;
else
    tPlot = min(tPlot, timeout_sec);
    if ~isempty(resid_fpga), r_end = resid_fpga(end); else, r_end = NaN; end
end
set(progress_bar,'Position',[0 0 1 1]);
flips_taken = tPlot * pbit_clk * num_pbits;

if isfinite(groundEnergy) && ~isnan(r_end)
    curGapPct_end  = max(0, 100 * (r_end * N) / abs(groundEnergy));
    bestGapPct_end = max(0, 100 * (bestResid * N) / abs(groundEnergy));
    info_str = sprintf(['Progress: %d%%\n' ...
                        'Gap to ground: %.2f%%  |  Best: %.2f%%\n' ...
                        'Flips: %s   Time: %.2f s'], ...
                        100, curGapPct_end, bestGapPct_end, ...
                        formatFlips(flips_taken), tPlot);
else
    info_str = sprintf('Progress: %d%%\nFlips: %s   Time: %.2f s', ...
                       100, formatFlips(flips_taken), tPlot);
end
set(info_text,'String',info_str);
drawnow;

for i = 1:num_partitions
    release(fpga_memories{i});
end
fprintf('FPGA SA finished: %s\n', datestr(now));

%% Local helpers
function formattedString = formatFlips(flips)
if flips < 1e6
    formattedString = sprintf('%.0f', flips);
elseif flips < 1e9
    formattedString = sprintf('%.2f million', flips/1e6);
elseif flips < 1e12
    formattedString = sprintf('%.2f billion', flips/1e9);
else
    formattedString = sprintf('%.2f trillion', flips/1e12);
end
end

function fpgaButtonCallbackStandalone(~, ~)
ud = get(gcbf, 'UserData');
if ~isstruct(ud), ud = struct; end
ud.runFPGA = true;
set(gcbf, 'UserData', ud);
end
