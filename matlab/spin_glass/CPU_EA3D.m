% =========================================================================
% Edwards–Anderson 3D Spin Glass — Simulated Annealing (CPU)
% Author: Navid Anjum Aadit (UC Santa Barbara, OPUS LAB)
% -------------------------------------------------------------------------
% Graph-colored simulated annealing on a 3D Ising spin glass (EA model).
% Linear inverse-temperature schedule; residual energy tracked vs time.
% Live progress displays percent completion and gap-to-ground (%).
% Press "run FPGA" to hand off to FPGA_EA3D.m for a timed FPGA run.
% =========================================================================

clc
clearvars
close all force

% Ensure common helpers are on MATLAB path
repo_root = fileparts(fileparts(mfilename('fullpath')));  % one level up from demo folder
addpath(fullfile(repo_root, 'common'));

% ================== USER KNOBS ==================
instanceSize        = 37;
instanceID          = 0;
num_sweeps_SA       = 500;
num_betas           = 10;                         % linear schedule stages
sweeps_per_beta     = num_sweeps_SA/num_betas;
initial_beta        = 0.5;
final_beta          = 5;
run_timeout_sec     = 10;                         % hard timeout (seconds)
rng(0,'twister');

% Visual
fontBase    = 18;
fontBig     = 20;
markerSize  = 4.5;
lineWidth   = 1.75;
seriesColor = [0.00 0.45 0.74];                   % blue
seriesFace  = [1 1 1];
groundColor = [0.00 0.55 0.00];                   % high-contrast green
% Fixed axes
xlim_time     = [0, run_timeout_sec];
residual_ylim = [-0.05, 1.00];
% =================================================

% ================== LOAD INSTANCE ==================
pathName  = fullfile(sprintf('./instances/size%02d', instanceSize));
addpath(pathName);
JFileName = ['JOrig_' num2str(instanceID,'%04d') '.mat'];
load(JFileName,'J');     % NxN
rmpath(pathName);

W = double(logical(J));
h = zeros(size(J,1),1);
N = length(J);

% Ground energy
geFile = sprintf('./Ground_energies/energyData_L=%d.txt', instanceSize);
ge = load(geFile);
groundEnergy = ge(instanceID+1, 2);

% ================== COLORING ==================

S = load('./colorMap/L37_colorMap.mat');
colorMap = S.colorMap;

numColors = numel(unique(colorMap));
Groups = cell(1,numColors);
for k = 1:numColors
    Groups{k} = find(colorMap==k);
end
J = sparse(J);

% ================== SCHEDULE ==================
beta_vals = linspace(initial_beta, final_beta, num_betas);

% ================== UI LAYOUT ==================
hFig = figure('NumberTitle','off','Units','normalized','OuterPosition',[0 0 1 1], ...
    'Color','w','Name',sprintf('L=%d, ID=%04d',instanceSize,instanceID));

% Left image
hSubplot1 = subplot(1,2,1);
imgPath = './images/distributed_PC.png';
if exist(imgPath,'file')
    imshow(imgPath);
else
    imshow(ones(100,100));
    text(0.05,0.5,'(distributed_PC.png missing)','Units','normalized','FontSize',fontBig,'FontWeight','bold','Color','k');
end
set(hSubplot1, 'Position', [0.01, 0.1, 0.45, 0.85]);

% Right plot
energyPlotPosition = [0.52, 0.15, 0.45, 0.6];
hAxes = axes('Position', energyPlotPosition); hold(hAxes,'on'); box(hAxes,'on');
set(hAxes,'FontSize',fontBase,'LineWidth',1.5,'FontWeight','bold');
xlabel(hAxes,'Time (s)','FontSize',fontBase,'FontWeight','bold');
ylabel(hAxes,'Residual Energy','FontSize',fontBase,'FontWeight','bold');
xlim(hAxes, xlim_time);
ylim(hAxes, residual_ylim);

hGround = yline(hAxes, 0, '--', 'Color', groundColor, 'LineWidth', 2.0, 'DisplayName','residual = 0 (ground)');
hLine = plot(hAxes, NaN, NaN, 'o-','MarkerSize',markerSize,'LineWidth',lineWidth, ...
    'Color',seriesColor,'MarkerFaceColor',seriesFace,'MarkerEdgeColor',seriesColor, ...
    'DisplayName','CPU SA');
hLeg = legend(hAxes,[hLine,hGround],{'CPU SA','residual = 0 (ground)'}, ...
    'Location','northeast','Box','off','FontSize',18,'FontWeight','bold');
set(hLeg,'AutoUpdate','off');
grid(hAxes,'on');
ticks  = get(hAxes,'YTick');
labels = arrayfun(@(x) sprintf('%.2f',x), ticks, 'UniformOutput', false);
labels(abs(ticks + 0.05) < 1e-12) = {''};     % hide −0.05 label only
set(hAxes,'YTick',ticks,'YTickLabel',labels);

% Progress panel
wbHeight = 0.13; wbWidth = 0.27; wbXPosition = 0.56; wbYPosition = 0.8;
progress_axes = axes('Parent', hFig, 'Position', [wbXPosition, wbYPosition, wbWidth, wbHeight], ...
    'XLim', [0 1], 'YLim', [0 1]);
axis(progress_axes,'off');
progress_bar = rectangle('Parent', progress_axes, 'Position', [0 0 0 1], ...
    'FaceColor', [0 1 0], 'EdgeColor', 'none');
info_text = text('Parent', progress_axes, 'Position', [0.1, 0.5], 'String', '', ...
    'FontSize', 18, 'FontWeight', 'bold');

% Title text above progress bar
textYPosition = 1.1;
runTitleText = sprintf('Solving: L=%d, ID=%04d', instanceSize, instanceID);
runTitleTextHandle = text('Parent', progress_axes, ...
    'Units', 'normalized', ...
    'Position', [0.22, textYPosition], ...
    'String', runTitleText, ...
    'FontSize', 18, ...
    'FontWeight', 'bold', ...
    'HorizontalAlignment', 'left', ...
    'VerticalAlignment', 'bottom', ...
    'Color', 'k'); %#ok<NASGU>

% Buttons
btnWidth  = 0.1; btnHeight = 0.05; top_margin = 0.075; right_margin = 0.03;
leftPosCPU   = 1 - btnWidth - right_margin;
bottomPosCPU = 1 - btnHeight - top_margin;
leftPosFPGA  = leftPosCPU;
bottomPosFPGA = bottomPosCPU - btnHeight - 0.02;

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

% ================== SA LOOP (CPU) ==================
m            = sign(2.*rand(N,1)-1);
ener         = zeros(1,num_sweeps_SA);
resid_ps     = zeros(1,num_sweeps_SA);
bestResid_ps = inf;
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

    % Energy and residual
    E = -0.5*(m'*(J*m)) - (h'*m);
    ener(sweep)     = E;
    resid_ps(sweep) = (E - groundEnergy)/N;

    % Time stamp and live plot
    tNow = toc; tvec(sweep) = tNow;
    set(hLine,'XData',tvec(1:sweep),'YData',resid_ps(1:sweep));

    % Linear beta schedule
    if mod(sweep, sweeps_per_beta) == 0 && bidx < num_betas
        bidx = bidx + 1;
    end

    % Progress (%)
    flips_taken = sweep * N;
    progressFraction = min(tNow / run_timeout_sec, 1);
    set(progress_bar, 'Position', [0 0 progressFraction 1]);

    curR = resid_ps(sweep);
    if curR < bestResid_ps, bestResid_ps = curR; end

    % Gap-to-ground (%)
    curGapPct  = max(0, 100 * (curR * N) / abs(groundEnergy));
    bestGapPct = max(0, 100 * (bestResid_ps * N) / abs(groundEnergy));
    runPct     = round(progressFraction * 100);

    info_str = sprintf(['Progress: %d%%\n' ...
        'Gap to ground: %.2f%%  |  Best: %.2f%%\n' ...
        'Flips: %s   Time: %.2f s'], ...
        runPct, curGapPct, bestGapPct, ...
        formatFlips(flips_taken), tNow);
    set(info_text, 'String', info_str);

    drawnow;
    if ~ishandle(hFig); return; end

    % Timeout
    if tNow >= run_timeout_sec
        set(progress_bar, 'Position', [0 0 1 1]);
        runPct = 100;
        info_str = sprintf(['Progress: %d%%\n' ...
            'Gap to ground: %.2f%%  |  Best: %.2f%%\n' ...
            'Flips: %s   Time: %.2f s'], ...
            runPct, curGapPct, bestGapPct, ...
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
FPGA_EA3D;   % Script executed next (reuses UI handles)

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
userData = get(gcbf, 'UserData');
userData.runCPU = true;
set(gcbf, 'UserData', userData);
end

function fpgaButtonCallback(~, ~)
userData = get(gcbf, 'UserData');
userData.runFPGA = true;
set(gcbf, 'UserData', userData);
end
