clc; close all; 
delayValue = 100;                     
velocity   = 9 / delayValue;        

time_start      = 0;     
time_end        = 110;   
min_force_limit = 2.7;   
min_drop_value  = 0.2;  

if ~exist('raw_data', 'var') || isempty(raw_data)
    raw_data = []; 
    openvar('raw_data'); 
    return; 
end

raw_time  = raw_data(:, 1);   
raw_force = abs(raw_data(:, 2)); 

force_threshold = 0.1; 
start_idx = find(raw_force > force_threshold, 1, 'first');
if isempty(start_idx), start_idx = 1; end
t = raw_time(start_idx:end) - raw_time(start_idx);
force = raw_force(start_idx:end);

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


if isempty(valid_locs)
    valid_range_idx = find((t >= time_start) & (t <= time_end));
    if ~isempty(valid_range_idx)
        [~, max_idx_in_range] = max(force(valid_range_idx));
        keep_locs = valid_range_idx(max_idx_in_range);
        fprintf('在 %.1f ~ %.1f 秒區間未偵測到符合落差的點，已抓取該區間最高點！\n', time_start, time_end);
    else
        keep_locs = find(force == max(force), 1, 'last');
        fprintf('指定的時間區間內無數據，已全域抓取最後一個最高點！\n');
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
fprintf('剝離速度：%.4f cm/s (Delay: %d)\n', velocity, delayValue);
fprintf('分析時間區間：%.2f s 至 %.2f s\n', time_start, time_end);
fprintf('目前設定條件：大於 %.2f N、落差至少 %.2f N\n', min_force_limit, min_drop_value);
fprintf('偵測到的真實剝離次數：%d 次\n', num_peaks);
if num_peaks > 0
    fprintf('單次最大臨界剝離力量：%.4f N\n', max(final_pks));
    fprintf('多點平均臨界剝離力量：%.4f N\n', avg_critical_force);
end
fprintf('--------------------------------------------------\n');

% === 畫圖與 saveas 自動儲存 ===
% 📉 【圖表 1：乾淨的完整波形圖】
fig1 = figure('Color', 'w', 'Position', [100, 100, 800, 450]); 
plot(t, force, 'r-', 'LineWidth', 1.2); 
xlim([0 100])
ylim([0 3])
xlabel('Time (s)', 'FontName', 'Times New Roman', 'FontSize', 12);
ylabel('Absolute Force (N)', 'FontName', 'Times New Roman', 'FontSize', 12);

title_str1 = sprintf('%.4f cm/s (Delay %d): Complete Raw Waveform', velocity, delayValue); 
title(title_str1, 'FontName', 'Times New Roman', 'FontSize', 13, 'FontWeight', 'bold');
set(gca, 'FontName', 'Times New Roman', 'FontSize', 12, 'LineWidth', 1.2, 'TickDir', 'in');
box on; 
filename1 = sprintf('Delay_%d_FullWave.png', delayValue);
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


title_str2 = sprintf('%.4f cm/s (Delay %d): Analyzed Force vs Time', velocity, delayValue); 
title(title_str2, 'FontName', 'Times New Roman', 'FontSize', 13, 'FontWeight', 'bold');
set(gca, 'FontName', 'Times New Roman', 'FontSize', 12, 'LineWidth', 1.2, 'TickDir', 'in');
box on; 
filename2 = sprintf('Delay_%d_Analyzed.png', delayValue);
%saveas(fig2, filename2);

fprintf('已自動儲存兩張圖表：\n');
fprintf('  1. 完整波形圖：%s\n', filename1);
fprintf('  2. 標記分析圖：%s\n\n', filename2);
