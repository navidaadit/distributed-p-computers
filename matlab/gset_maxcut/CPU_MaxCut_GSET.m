% =========================================================================
% GSET Max-Cut — Simulated Annealing (CPU)
% Author: Navid Anjum Aadit (UC Santa Barbara)
% -------------------------------------------------------------------------
% Graph-colored simulated annealing for GSET Max-Cut on weighted graphs.
% Ising mapping: J = -W, h = -h. Plots Cut Value vs wall time.
% Progress panel reports current and best cut.
% =========================================================================

clc
clearvars
close all force

% ================== USER KNOBS ==================
gset_name          = 'G81';                 % expects '<name>.txt' in gset_dir
gset_dir           = './GSET';              % folder containing GSET .txt
num_sweeps_SA      = 250;                   % total sweeps
num_betas          = 10;                    % linear schedule stages
sweeps_per_beta    = max(1, floor(num_sweeps_SA/num_betas));
initial_beta       = 0.5;
final_beta         = 5.0;
run_timeout_sec    = 10;                    % wall-time (s)
max_cut_known      = 14060;                 % known Max-Cut for this instance
cut_ylim           = [0, max_cut_known*1.05];
rng(0,'twister');

% Visual
fontBase    = 18;
fontBig     = 20;
markerSize  = 4.5;
lineWidth   = 1.75;
seriesColor = [0.00 0.45 0.74];
seriesFace  = [1 1 1];
refColor    = [0.00 0.55 0.00];
xlim_time   = [0, run_timeout_sec];
% =================================================

% ================== LOAD GSET INSTANCE ==================
gset_path = fullfile(gset_dir, [gset_name '.txt']);
[W_in, h_in] = txt_to_A_droplet_new_Navid(gset_path);
J  = -W_in;
h  = -h_in;
W  = W_in;

N = size(J,1);
if size(h,1) == 1, h = h'; end

% Edge list for cut evaluation
[edge_i, edge_j, edge_w] = find(W);

% ================== COLORING ==================
S = load('./colorMap/G81_colorMap.mat'); colorMap = S.colorMap;

numColors = numel(unique(colorMap));
Groups = cell(1,numColors);
for k = 1:numColors, Groups{k} = find(colorMap==k); end
J = sparse(J);

% ================== BETA SCHEDULE ==================
beta_vals = linspace(initial_beta, final_beta, num_betas);

% ================== UI LAYOUT ==================
hFig = figure('NumberTitle','off','Units','normalized','OuterPosition',[0 0 1 1], ...
    'Color','w','Name',sprintf('GSET: %s', gset_name));

% Left image
hSubplot1 = subplot(1,2,1);
imgPath = './images/distributed_PC.png';
if exist(imgPath,'file'), imshow(imgPath);
else, imshow(ones(100,100)); text(0.05,0.5,'(distributed_PC.png missing)','Units','normalized','FontSize',fontBig,'FontWeight','bold','Color','k');
end
set(hSubplot1, 'Position', [0.01, 0.1, 0.45, 0.85]);

% Right plot
plotPos = [0.52, 0.15, 0.45, 0.6];
hAxes = axes('Position', plotPos); hold(hAxes,'on'); box(hAxes,'on');
set(hAxes,'FontSize',fontBase,'LineWidth',1.5,'FontWeight','bold');
xlabel(hAxes,'Time (s)','FontSize',fontBase,'FontWeight','bold');
ylabel(hAxes,'Cut Value','FontSize',fontBase,'FontWeight','bold');
xlim(hAxes, xlim_time);
ylim(hAxes, cut_ylim);
hRef = yline(hAxes, max_cut_known, '--', 'Color', refColor, 'LineWidth', 2.0, ...
             'DisplayName', sprintf('max-cut = %d', max_cut_known));
hLine = plot(hAxes, NaN, NaN, 'o-','MarkerSize',markerSize,'LineWidth',lineWidth, ...
    'Color',seriesColor,'MarkerFaceColor',seriesFace,'MarkerEdgeColor',seriesColor, ...
    'DisplayName','CPU SA');
hLeg = legend(hAxes,[hLine,hRef],{'CPU SA',sprintf('max-cut = %d',max_cut_known)}, ...
    'Location','east','Box','off','FontSize',18,'FontWeight','bold');
set(hLeg,'AutoUpdate','off'); grid(hAxes,'on');

% Progress panel
wbHeight = 0.13; wbWidth = 0.3; wbXPosition = 0.56; wbYPosition = 0.8;
progress_axes = axes('Parent', hFig, 'Position', [wbXPosition, wbYPosition, wbWidth, wbHeight], ...
    'XLim', [0 1], 'YLim', [0 1]); axis(progress_axes,'off');
progress_bar = rectangle('Parent', progress_axes, 'Position', [0 0 0 1], ...
    'FaceColor', [0 1 0], 'EdgeColor', 'none');
info_text = text('Parent', progress_axes, 'Position', [0.1, 0.5], 'String', '', ...
    'FontSize', 18, 'FontWeight', 'bold');
runTitleTextHandle = text('Parent', progress_axes, 'Units','normalized','Position',[0.22, 1.1], ...
    'String', sprintf('Solving: GSET %s', gset_name), 'FontSize', 18, 'FontWeight', 'bold', ...
    'HorizontalAlignment','left', 'VerticalAlignment','bottom', 'Color','k'); %#ok<NASGU>

% Buttons
btnWidth  = 0.1; btnHeight = 0.05; top_margin = 0.075; right_margin = 0.03;
leftPosCPU    = 1 - btnWidth - right_margin; bottomPosCPU  = 1 - btnHeight - top_margin;
leftPosFPGA   = leftPosCPU;                  bottomPosFPGA = bottomPosCPU - btnHeight - 0.02;
set(hFig, 'UserData', struct('runCPU', false, 'runFPGA', false));
uicontrol('Parent', hFig, 'Style', 'pushbutton', 'String', 'run CPU', ...
    'Units', 'normalized', 'Position', [leftPosCPU, bottomPosCPU, btnWidth, btnHeight], ...
    'FontWeight', 'bold', 'FontSize', 18, 'Callback', @cpuButtonCallback, ...
    'BackgroundColor', [0.10 0.45 0.85], 'ForegroundColor', [1 1 1]);
uicontrol('Parent', hFig, 'Style', 'pushbutton', 'String', 'run FPGA', ...
    'Units', 'normalized', 'Position', [leftPosFPGA, bottomPosFPGA, btnWidth, btnHeight], ...
    'FontWeight', 'bold', 'FontSize', 18, 'Callback', @fpgaButtonCallback, ...
    'BackgroundColor', [0.00 0.65 0.35], 'ForegroundColor', [1 1 1]);

% ================== WAIT FOR CPU START ==================
while ~hFig.UserData.runCPU
    if ~ishandle(hFig); return; end
    pause(0.1);
end

% ================== SA LOOP (CPU, MAX-CUT) ==================
m            = sign(2.*rand(N,1)-1);
cut_series   = zeros(1,num_sweeps_SA);
bestCut      = -inf;
tvec         = zeros(1,num_sweeps_SA);

tic;
bidx = 1;
for sweep = 1:num_sweeps_SA
    beta = beta_vals(bidx);

    % Graph-colored updates
    for g = 1:numColors
        idx = Groups{g};
        x = beta .* (J(idx,:)*m + h(idx));
        m(idx) = sign(tanh(x) - 2*rand(numel(idx),1) + 1);
    end

    % Cut value
    diffPart          = m(edge_i) ~= m(edge_j);
    current_cut       = sum(edge_w(diffPart))/2;
    cut_series(sweep) = current_cut;

    % Live plot
    tNow = toc; tvec(sweep) = tNow;
    set(hLine,'XData',tvec(1:sweep),'YData',cut_series(1:sweep));

    % Linear schedule
    if mod(sweep, sweeps_per_beta) == 0 && bidx < num_betas, bidx = bidx + 1; end

    % Progress
    flips_taken = sweep * N;
    progressFraction = min(tNow / run_timeout_sec, 1);
    set(progress_bar, 'Position', [0 0 progressFraction 1]);

    if current_cut > bestCut, bestCut = current_cut; end
    runPct = round(progressFraction * 100);
    info_str = sprintf(['Progress: %d%%\n' ...
                        'Cut: %.2f  |  Best: %.2f (%.2f%%)\n' ...
                        'Flips: %s   Time: %.2f s'], ...
                        runPct, current_cut, bestCut, 100*(bestCut/max_cut_known), ...
                        formatFlips(flips_taken), tNow);
    set(info_text, 'String', info_str);

    drawnow;
    if ~ishandle(hFig); return; end

    % Timeout
    if tNow >= run_timeout_sec
        set(progress_bar, 'Position', [0 0 1 1]);
        runPct = 100;
        info_str = sprintf(['Progress: %d%%\n' ...
                            'Cut: %.2f  |  Best: %.2f (%.2f%%)\n' ...
                            'Flips: %s   Time: %.2f s'], ...
                            runPct, current_cut, bestCut, 100*(bestCut/max_cut_known), ...
                            formatFlips(flips_taken), run_timeout_sec);
        set(info_text, 'String', info_str);
        drawnow;
        break;
    end
end

% ================== HANDOFF TO FPGA ==================
while ~hFig.UserData.runFPGA
    if ~ishandle(hFig); return; end
    pause(0.1);
end
SA_FPGA_after_CPU;   % FPGA script below in a separate file

% ================== HELPERS ==================
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

function cpuButtonCallback(~, ~)
userData = get(gcbf, 'UserData'); userData.runCPU = true; set(gcbf, 'UserData', userData);
end

function fpgaButtonCallback(~, ~)
userData = get(gcbf, 'UserData'); userData.runFPGA = true; set(gcbf, 'UserData', userData);
end

function [W, h] = txt_to_A_droplet_new_Navid(txtfile)
fid = fopen(txtfile, 'r');
if fid < 0, error('Cannot open file: %s', txtfile); end
fgetl(fid);
data = textscan(fid, '%f %f %f', 'CommentStyle', '#');
fclose(fid);
rows = data{1}; cols = data{2}; vals = data{3};
n = max(max(rows), max(cols));
h = zeros(n, 1);
diagMask = (rows == cols);
h(rows(diagMask)) = vals(diagMask);
offDiagMask = (rows ~= cols);
i = [rows(offDiagMask); cols(offDiagMask)];
j = [cols(offDiagMask); rows(offDiagMask)];
v = [vals(offDiagMask); vals(offDiagMask)];
W = sparse(i, j, v, n, n);
end
