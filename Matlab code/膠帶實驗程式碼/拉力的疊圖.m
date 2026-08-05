clc; clear; close all;

% ========================================================================
% 📂 1. 彈出檔案選取視窗 (Excel/CSV)
% ========================================================================
[filename, pathname] = uigetfile({'*.xlsx;*.xls;*.csv', 'Excel/CSV Files (*.xlsx, *.xls, *.csv)'}, '選擇膠帶實驗數據');

if isequal(filename,0) || isequal(pathname,0)
    disp('❌ 取消選擇，程式結束。');
    return;
end

fullPath = fullfile(pathname, filename);
fprintf('📂 正在讀取檔案: %s ...\n', filename);
rawCellData = readcell(fullPath);

% ========================================================================
% 🌟 2. 核心參數設定：請在這裡修改你想看的範圍 🌟
% ========================================================================
forceThreshold = 0.1;   % 拉力門檻 (N)，達到此值即定義為 t = 0
tStart = 0;             % 🌟 想要開始顯示的時間 (秒，從校正後的 0 開始算)
tEnd   = 200;             % 🌟 想要結束顯示的時間 (秒，例如只看前 5 秒)
% (如果 tEnd 設得比數據長，程式會自動抓到數據結束為止)

% ========================================================================
% ⚙️ 3. 數據解讀與校正演算法
% ========================================================================
[numRows, numCols] = size(rawCellData);
validGroups = {};
groupNames = {};

col = 1;
while col <= numCols
    header = rawCellData{1, col};
    if ismissing(header) || isempty(header), col = col + 1; continue; end
    
    if isnumeric(header), delayStr = sprintf('Delay %g', header);
    else, delayStr = char(header); if ~contains(lower(delayStr), 'delay'), delayStr = ['Delay ' delayStr]; end
    end
    
    t_vec = []; F_vec = [];
    for row = 2:numRows
        t_val = rawCellData{row, col};
        if col+1 <= numCols, F_val = rawCellData{row, col+1}; else, F_val = missing; end
        if ismissing(t_val) || ismissing(F_val) || isempty(t_val) || isempty(F_val), continue; end
        t_vec = [t_vec; double(t_val)]; 
        F_vec = [F_vec; abs(double(F_val))]; % 這裡保留 abs 以防萬一
    end
    
    if ~isempty(t_vec)
        validGroups{end+1} = [t_vec, F_vec]; %#ok<AGROW>
        groupNames{end+1} = delayStr; %#ok<AGROW>
    end
    col = col + 2; 
end

% ========================================================================
% 🖼️ 4. 論文級繪圖 (含時間區段裁切)
% ========================================================================
plotFig = figure('Color', 'w', 'Units', 'centimeters', 'Position', [5 5 16 12]);
hold on; grid on;

colors = [0.000, 0.447, 0.741; 0.850, 0.325, 0.098; 0.466, 0.674, 0.188; ...
          0.494, 0.184, 0.556; 0.301, 0.745, 0.933; 0.635, 0.078, 0.184];

h_lines = []; % 用於儲存有畫出來的線條握把

for i = 1:length(validGroups)
    data = validGroups{i};
    t_raw = data(:, 1);
    F_raw = data(:, 2);
    
    % 第一步：找出 0.1 N 起跑點
    idxStart = find(F_raw >= forceThreshold, 1, 'first');
    if isempty(idxStart), idxStart = 1; end
    
    % 第二步：初步時間校正 (以 0.1N 為 0 秒)
    t_temp = t_raw(idxStart:end) - t_raw(idxStart);
    F_temp = F_raw(idxStart:end);
    
    % 🌟 第三步：根據用戶指定的 timeRange 進行二次裁切 🌟
    % 找出落在 [tStart, tEnd] 範圍內的索引
    targetIdx = find(t_temp >= tStart & t_temp <= tEnd);
    
    if isempty(targetIdx)
        fprintf('⚠️ 警告：[%s] 在指定的時間範圍 [%g, %g] 內無數據，已跳過。\n', groupNames{i}, tStart, tEnd);
        continue;
    end
    
    t_final = t_temp(targetIdx);
    F_final = F_temp(targetIdx);
    
    % 畫圖
    colorIdx = mod(i-1, size(colors, 1)) + 1;
    h = plot(t_final, F_final, '-', ...
        'Color', [colors(colorIdx, :), 0.85], ...
        'LineWidth', 1.5);
    h_lines = [h_lines, h]; %#ok<AGROW>
    fprintf('📌 已繪製 [%s]：範圍 %g 到 %g 秒。\n', groupNames{i}, t_final(1), t_final(end));
end

% 圖表美化
xlabel(sprintf('Aligned Time $t$ (s) [Range: %g - %g]', tStart, tEnd), ...
    'Interpreter', 'latex', 'FontName', 'Times New Roman', 'FontSize', 12);
ylabel('Peeling Force $F$ (N)', 'Interpreter', 'latex', 'FontName', 'Times New Roman', 'FontSize', 14);
title('Cropped Dynamic Force Response', 'FontName', 'Times New Roman', 'FontSize', 16, 'FontWeight', 'bold');

if ~isempty(h_lines)
    [lg, ~] = legend(h_lines, groupNames(1:length(h_lines)), 'Location', 'best', ...
        'FontName', 'Times New Roman', 'FontSize', 11);
    set(lg, 'LineWidth', 1.0, 'Box', 'on', 'EdgeColor', [0.8 0.8 0.8]);
end

set(gca, 'FontName', 'Times New Roman', 'FontSize', 12, 'LineWidth', 1.5, ...
    'TickDir', 'in', 'Box', 'on', 'GridAlpha', 0.4);

% 自動設定 X 軸範圍為你指定的 [tStart, tEnd]
xlim([tStart tEnd]);

% 儲存檔案
outputName = sprintf('Force_Cropped_%g_to_%g.png', tStart, tEnd);
print(plotFig, '-dpng', '-r300', outputName);
fprintf('\n✅ 分析成功！圖表已裁切並儲存為：[%s]\n', outputName);