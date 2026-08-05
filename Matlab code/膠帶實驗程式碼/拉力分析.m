clc; close all; % ⚠️ 注意：千萬不能加 clear，否則貼好的數據會被清空

% =======================================================
% 🌟 實驗參數設定區（會自動連動圖片命名與圖表標題）
% =======================================================
tapeType  = 'Large Narrow Tape(3)';       % 膠帶名稱
delayTime = '100ms';                   % 延遲時間

% =======================================================
% 📝 試算表偵測與自動開啟機制
% =======================================================
if ~exist('raw_data', 'var') || isempty(raw_data)
    % 1. 如果工作區沒有數據，就建立一個空矩陣
    raw_data = []; 
    
    % 2. 自動幫你彈出 MATLAB 的試算表編輯視窗
    openvar('raw_data'); 
    
    % 3. 在下方命令視窗印出操作提示
    fprintf('\n====== 💡 請跟著以下步驟操作 ======\n');
    fprintf('1️⃣ MATLAB 已經幫你打開 "raw_data" 的空白試算表視窗了。\n');
    fprintf('2️⃣ 請去 Excel 複製你的「兩直欄」數字（左邊時間、右邊力量）。\n');
    fprintf('3️⃣ 回到 MATLAB 試算表，點擊第一個格子 (1,1)，按 Ctrl+V 貼上。\n');
    fprintf('4️⃣ 貼好後，**「再一次點擊執行 (Run)」** 這個程式即可！\n');
    fprintf('==============================================\n\n');
    return; % 暫停程式，等待你貼數據
end

% =======================================================
% 🚀 ② 數據處理與分析（當你貼好數據，第二次按下 Run 時）
% =======================================================
fprintf('偵測到 raw_data 數據，開始進行分析...\n');

% 抓取第 1 直欄當時間，第 2 直欄當力量
raw_time  = raw_data(:, 1);   
raw_force = abs(raw_data(:, 2)); % 力量自動取絕對值

% === ③ 處理時間延遲（自動對齊起點） ===
force_threshold = 0.1; 
start_idx = find(raw_force > force_threshold, 1, 'first');
if isempty(start_idx), start_idx = 1; end

t = raw_time(start_idx:end) - raw_time(start_idx);
force = raw_force(start_idx:end);
fs = 1 / mean(diff(t));  

% === ④ 尋找臨界剝離力量（導入「快速往下掉」物理過濾機制） ===
% 找出所有局部最大值點
is_local_max = [false; ...
                force(2:end-1) > force(1:end-2) & ...
                force(2:end-1) > force(3:end); ...
                false];
            
% 基礎高度門檻
base_threshold = max(force) * 0.10; 
all_locs = find(is_local_max & (force > base_threshold));

% 🔥 核心修正：檢查波峰後方是否有「快速往下掉」的落差
valid_locs = [];
for i = 1:length(all_locs)
    curr_loc = all_locs(i);
    
    % 定義尋找下一個谷底的範圍（到下一個波峰前，或是數據尾端）
    if i < length(all_locs)
        search_end = all_locs(i+1);
    else
        search_end = length(force);
    end
    
    % 找出這個波峰過後的局部最低點（谷底）
    local_min = min(force(curr_loc:search_end));
    
    % 💡 物理判斷：真正剝離的波峰，力量衰減落差必須大於最大力量的 8%
    % 尾部的微小雜訊因為沒有「快速往下掉」的落差，會在這裡被全部過濾掉！
    if (force(curr_loc) - local_min) > (max(force) * 0.08)
        valid_locs(end+1) = curr_loc; %#ok<AGROW>
    end
end

% 移除非必要的密集重複點（維持原有時間間隔限制）
min_dist_sec = 0.01; 
min_dist_samples = max(1, round(min_dist_sec * fs));

pks = force(valid_locs);
[sorted_pks, sort_idx] = sort(pks, 'descend');
sorted_locs = valid_locs(sort_idx);
keep_locs = []; 

for i = 1:length(sorted_locs)
    curr_loc = sorted_locs(i);
    if isempty(keep_locs) || all(abs(keep_locs - curr_loc) >= min_dist_samples)
        keep_locs(end+1) = curr_loc; %#ok<AGROW>
    end
end

% 最終確認的真實剝離波峰
keep_locs = sort(keep_locs);
final_pks = force(keep_locs);
final_t = t(keep_locs);

if ~isempty(final_pks)
    avg_critical_force = mean(final_pks);
    num_peaks = length(final_pks);
else
    avg_critical_force = 0;
    num_peaks = 0;
end

% === ⑤ 顯示文字報告 ===
fprintf('\n--- 📊 膠帶黏滑現象 (Stick-Slip) 力量統計報告 ---\n');
fprintf('偵測到的真實剝離次數：%d 次\n', num_peaks);
if num_peaks > 0
    fprintf('單次最大臨界剝離力量：%.4f N\n', max(final_pks));
    fprintf('多點平均臨界剝離力量：%.4f N\n', avg_critical_force);
end
fprintf('--------------------------------------------------\n');

% === ⑥ 畫圖與 saveas 自動儲存 ===
fig = figure('Color', 'w', 'Position', [100, 100, 800, 450]); 
plot(t, force, 'r-', 'LineWidth', 1.2); hold on; 

if num_peaks > 0
    plot(final_t, final_pks, 'ko', 'MarkerSize', 6, 'LineWidth', 1.5); 
    yline(avg_critical_force, 'b--', 'LineWidth', 1.5);
    text(t(end)*0.05, avg_critical_force * 1.05, ...
        sprintf('Average Critical Force = %.4f N', avg_critical_force), ...
        'Color', 'b', 'FontName', 'Times New Roman', 'FontWeight', 'bold', 'FontSize', 11);
end

xlabel('Time (s)', 'FontName', 'Times New Roman', 'FontSize', 12);
ylabel('Absolute Force (N)', 'FontName', 'Times New Roman', 'FontSize', 12);

title_str = sprintf('%s (Delay %s): Force vs Time', tapeType, delayTime); 
title(title_str, 'FontName', 'Times New Roman', 'FontSize', 13, 'FontWeight', 'bold');
set(gca, 'FontName', 'Times New Roman', 'FontSize', 12, 'LineWidth', 1.2, 'TickDir', 'in');
box on; 

% 儲存圖片
filename = sprintf('%s delay %s.png', tapeType, delayTime);
saveas(fig, filename);
fprintf('💾 【儲存成功】圖片已自動儲存為：%s\n\n', filename);