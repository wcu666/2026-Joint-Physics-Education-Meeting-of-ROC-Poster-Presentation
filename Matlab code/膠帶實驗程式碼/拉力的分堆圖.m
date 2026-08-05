clc; clear; close all;
% ========================================================================
% 📂 1. 彈出檔案選取視窗 (讀取各角度原始數據)
% ========================================================================
[filename, pathname] = uigetfile({'*.xlsx;*.xls;*.csv', 'Excel/CSV Files (*.xlsx, *.xls, *.csv)'}, '選擇角度實驗數據');
if isequal(filename,0) || isequal(pathname,0), disp('❌ 取消選擇'); return; end
fullPath = fullfile(pathname, filename);
rawCellData = readcell(fullPath);

% ========================================================================
% ⚙️ 2. 核心參數設定
% ========================================================================
forceThreshold = 0.1;   % 拉力門檻 (N)，達到此值即定義為 t = 0 (起跑點校正)

% ========================================================================
% 🚀 3. 數據解讀與自動分類 (角度標籤防呆判定)
% ========================================================================
[numRows, numCols] = size(rawCellData);
validGroups = {}; groupNames = {};
col = 1;

while col <= numCols
    header = rawCellData{1, col};
    
    % 防呆處理：跳過空行或無效表頭
    if isempty(header) || all(ismissing(header))
        col = col + 1; 
        continue; 
    end
    
    % 智慧判斷表頭名稱 (將數字自動轉為 Angle XX°)
    if isnumeric(header)
        groupStr = sprintf('Angle %g%c', header, char(176)); % 加上度數符號 (°)
    else
        groupStr = char(header); 
        if ~contains(lower(groupStr), 'angle') && ~contains(groupStr, char(176))
            groupStr = ['Angle ' groupStr char(176)]; 
        end
    end
    
    t_vec = []; F_vec = [];
    for row = 2:numRows
        t_val = rawCellData{row, col};
        if col+1 <= numCols
            F_val = rawCellData{row, col+1}; 
        else
            F_val = missing; 
        end
        
        % 防呆處理：略過缺失數據
        if isempty(t_val) || isempty(F_val) || all(ismissing(t_val)) || all(ismissing(F_val))
            continue; 
        end
        
        t_vec = [t_vec; double(t_val)]; 
        F_vec = [F_vec; abs(double(F_val))];
    end
    
    if ~isempty(t_vec)
        validGroups{end+1} = [t_vec, F_vec]; %#ok<AGROW>
        groupNames{end+1} = groupStr; %#ok<AGROW>
    end
    col = col + 2; % 預設為一欄 Time、一欄 Force，所以跳 2 格
end

numGroups = length(validGroups);
if numGroups == 0, error('❌ 找不到有效數據'); end

% ========================================================================
% 🖼️ 4. 論文級「多聯幅圖 (Subplots)」自動排版與繪圖
% ========================================================================
% 自動計算網格 (每列放 3 張圖)
subCols = 3; 
subRows = ceil(numGroups / subCols);
plotFig = figure('Color', 'w', 'Units', 'centimeters', 'Position', [2 2 24 (subRows*6)]);

% 學術質感配色庫 (依序套用在不同圖上)
colors = [0.000, 0.447, 0.741; 0.850, 0.325, 0.098; 0.466, 0.674, 0.188; ...
          0.494, 0.184, 0.556; 0.301, 0.745, 0.933; 0.635, 0.078, 0.184; ...
          0.929, 0.694, 0.125; 0.466, 0.674, 0.188; 0.301, 0.745, 0.933];

for i = 1:numGroups
    subplot(subRows, subCols, i);
    hold on; grid on;
    
    data = validGroups{i};
    t_raw = data(:, 1); F_raw = data(:, 2);
    
    % 起跑點校正 (抓取大於門檻值的第一個點)
    idxStart = find(F_raw >= forceThreshold, 1, 'first');
    if isempty(idxStart), idxStart = 1; end
    
    t_aligned = t_raw(idxStart:end) - t_raw(idxStart);
    F_cut = F_raw(idxStart:end);
    
    % 分配顏色並畫線
    colorIdx = mod(i-1, size(colors, 1)) + 1;
    plot(t_aligned, F_cut, '-', 'Color', colors(colorIdx, :), 'LineWidth', 1.2);
    
    % 🚀 套用你指定的固定座標軸範圍
    xlim([0, 100]);  
    ylim([0, 3.5]); 
    
    % 小圖標題與美化
    title(groupNames{i}, 'FontName', 'Times New Roman', 'FontSize', 12, 'FontWeight', 'bold');
    set(gca, 'FontName', 'Times New Roman', 'FontSize', 10, 'LineWidth', 1.0, 'TickDir', 'in', 'Box', 'on');
    
    % 將網格線調淡一點，讓數據更凸顯
    set(gca, 'GridColor', [0.8 0.8 0.8], 'GridAlpha', 0.5); 
    
    % 只在最左邊的圖加 Y 軸標籤，最下方的圖加 X 軸標籤，保持畫面乾淨
    if mod(i-1, subCols) == 0
        ylabel('Force (N)', 'FontName', 'Times New Roman', 'FontSize', 11, 'FontWeight', 'bold');
    end
    if i > (numGroups - subCols)
        xlabel('Time (s)', 'FontName', 'Times New Roman', 'FontSize', 11, 'FontWeight', 'bold');
    end
end

% 大標題與存檔
sgtitle('Dynamic Peeling Force Response at Different Angles', 'FontName', 'Times New Roman', 'FontSize', 16, 'FontWeight', 'bold');
outputName = 'Angle_Force_Subplot_Matrix.png';
print(plotFig, '-dpng', '-r300', outputName);
fprintf('\n✅ 角度分堆圖已成功生成並儲存為：[%s]\n', outputName);