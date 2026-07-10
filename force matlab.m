clc; close all; % ⚠️ 注意：千萬不能加 clear，否則貼好的數據會被清空

% =======================================================
% 🌟 實驗參數設定區（自動連動圖片與運算邏輯）
% =======================================================
tapeType  = 'Large Narrow Tape 5-Degree Angle(1)';       % 膠帶名稱
delayTime = '100ms';                  % 延遲時間

% 👇 --- 自訂波峰抓取條件 --- 👇
time_start      = 0;   % 【條件 0：起始時間】只分析此時間 (秒) 之後的數據
time_end        = 320;   % 【條件 0：結束時間】只分析此時間 (秒) 之前的數據 (若不限制可填入 Inf)

min_force_limit = 2;   % 【條件 1：範圍以上】只抓力量大於此數值 (N) 的數據
min_drop_value  = 0.1;   % 【條件 2：垂直落差】波峰到下一個谷底，力量至少要掉落多少 (N)
% =======================================================

% =======================================================
% 📝 試算表偵測與自動開啟機制
% =======================================================
if ~exist('raw_data', 'var') || isempty(raw_data)
    raw_data = []; 
    openvar('raw_data'); 
    fprintf('\n====== 💡 請跟著以下步驟操作 ======\n');
    fprintf('1️⃣ MATLAB 已經幫你打開 "raw_data" 的空白試算表視窗了。\n');
    fprintf('2️⃣ 請去 Excel 複製你的「兩直欄」數字（左邊時間、右邊力量）。\n');
    fprintf('3️⃣ 回到 MATLAB 試算表，點擊第一個格子 (1,1)，按 Ctrl+V 貼上。\n');
    fprintf('4️⃣ 貼好後，**「再一次點擊執行 (Run)」** 這個程式即可！\n');
    fprintf('==============================================\n\n');
    return; 
end

% =======================================================
% 🚀 ② 數據處理與分析
% =======================================================
fprintf('偵測到 raw_data 數據，開始進行分析...\n');

raw_time  = raw_data(:, 1);   
raw_force = abs(raw_data(:, 2)); 

% === ③ 處理時間延遲（自動對齊起點） ===
force_threshold = 0.1; 
start_idx = find(raw_force > force_threshold, 1, 'first');
if isempty(start_idx), start_idx = 1; end
t = raw_time(start_idx:end) - raw_time(start_idx);
force = raw_force(start_idx:end);

% === ④ 尋找臨界剝離力量 ===
is_local_max = [false; ...
                force(2:end-1) > force(1:end-2) & ...
                force(2:end-1) > force(3:end); ...
                false];
            
all_locs = find(is_local_max & (force > min_force_limit) & (t >= time_start) & (t <= time_end));

valid_locs = [];
for i = 1:length(all_locs)
    curr_loc = all_locs(i);
    if i < length(all_locs)
        search_end = all_locs(i+1);
    else
        end_idx = find(t <= time_end, 1, 'last');
        search_end = min(length(force), end_idx);
    end
    local_min = min(force(curr_loc:search_end));
    
    if (force(curr_loc) - local_min) >= min_drop_value
        valid_locs(end+1) = curr_loc; %#ok<AGROW>
    end
end

% 保底機制修正：在指定區間內找最大值
if isempty(valid_locs)
    valid_range_idx = find((t >= time_start) & (t <= time_end));
    if ~isempty(valid_range_idx)
        [~, max_idx_in_range] = max(force(valid_range_idx));
        keep_locs = valid_range_idx(max_idx_in_range);
        fprintf('⚠️ 注意：在 %.1f ~ %.1f 秒區間未偵測到符合落差的點，已抓取該區間最高點！\n', time_start, time_end);
    else
        keep_locs = find(force == max(force), 1, 'last');
        fprintf('⚠️ 警告：指定的時間區間內無數據，已全域抓取最後一個最高點！\n');
    end
else
    keep_locs = valid_locs;
end

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
fprintf('分析時間區間：%.2f s 至 %.2f s\n', time_start, time_end);
fprintf('目前設定條件：大於 %.2f N、落差至少 %.2f N\n', min_force_limit, min_drop_value);
fprintf('偵測到的真實剝離次數：%d 次\n', num_peaks);
if num_peaks > 0
    fprintf('單次最大臨界剝離力量：%.4f N\n', max(final_pks));
    fprintf('多點平均臨界剝離力量：%.4f N\n', avg_critical_force);
end
fprintf('--------------------------------------------------\n');

% === ⑥ 畫圖與 saveas 自動儲存 ===

% 📉 【圖表 1：乾淨的完整波形圖】
fig1 = figure('Color', 'w', 'Position', [100, 100, 800, 450]); 
plot(t, force, 'r-', 'LineWidth', 1.2); 
xlabel('Time (s)', 'FontName', 'Times New Roman', 'FontSize', 12);
ylabel('Absolute Force (N)', 'FontName', 'Times New Roman', 'FontSize', 12);
title_str1 = sprintf('%s (Delay %s): Complete Raw Waveform', tapeType, delayTime); 
title(title_str1, 'FontName', 'Times New Roman', 'FontSize', 13, 'FontWeight', 'bold');
set(gca, 'FontName', 'Times New Roman', 'FontSize', 12, 'LineWidth', 1.2, 'TickDir', 'in');
box on; 

filename1 = sprintf('%s delay %s_FullWave.png', tapeType, delayTime);
saveas(fig1, filename1);

% 📊 【圖表 2：帶有標記的分析圖】
fig2 = figure('Color', 'w', 'Position', [150, 150, 800, 450]); 
plot(t, force, 'r-', 'LineWidth', 1.2); hold on; 

xline(time_start, 'k:', 'LineWidth', 1.5, 'Alpha', 0.5);
if time_end ~= Inf
    xline(time_end, 'k:', 'LineWidth', 1.5, 'Alpha', 0.5);
end

if num_peaks > 0
    plot(final_t, final_pks, 'ko', 'MarkerSize', 6, 'LineWidth', 1.5); 
    yline(avg_critical_force, 'b--', 'LineWidth', 1.5);
    text(t(end)*0.05, avg_critical_force * 1.05, ...
        sprintf('Average Critical Force = %.4f N', avg_critical_force), ...
        'Color', 'b', 'FontName', 'Times New Roman', 'FontWeight', 'bold', 'FontSize', 11);
end

xlabel('Time (s)', 'FontName', 'Times New Roman', 'FontSize', 12);
ylabel('Absolute Force (N)', 'FontName', 'Times New Roman', 'FontSize', 12);
title_str2 = sprintf('%s (Delay %s): Analyzed Force vs Time', tapeType, delayTime); 
title(title_str2, 'FontName', 'Times New Roman', 'FontSize', 13, 'FontWeight', 'bold');
set(gca, 'FontName', 'Times New Roman', 'FontSize', 12, 'LineWidth', 1.2, 'TickDir', 'in');
box on; 

filename2 = sprintf('%s delay %s_Analyzed.png', tapeType, delayTime);
saveas(fig2, filename2);

fprintf('💾 【儲存成功】已自動儲存兩張圖表：\n');
fprintf('  1. 完整波形圖：%s\n', filename1);
fprintf('  2. 標記分析圖：%s\n\n', filename2);