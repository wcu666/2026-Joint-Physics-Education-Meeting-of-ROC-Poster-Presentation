clc; close all; 
peelAngle  = 20;                    

force_offset    = 1.0068; 
time_start      = 5     
time_end        = 100;   
min_force_limit = 2;   
min_drop_value  = 0.2; 

if ~exist('raw_data', 'var') || isempty(raw_data)
    raw_data = []; 
    openvar('raw_data'); 
    return; 
end
fprintf('偵測到 raw_data 數據，開始進行分析與角度校正...\n');
raw_time  = raw_data(:, 1);   
raw_force = abs(raw_data(:, 2)) - force_offset; 
raw_force(raw_force < 0) = 0; 

force_threshold = 0.05;
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
        valid_locs(end+1) = curr_loc; 
    end
end

if isempty(valid_locs)
    valid_range_idx = find((t >= time_start) & (t <= time_end));
    if ~isempty(valid_range_idx)
        [~, max_idx_in_range] = max(force(valid_range_idx));
        keep_locs = valid_range_idx(max_idx_in_range);
        fprintf('在區間未偵測到符合落差的點，已抓取最高點！\n');
    else
        keep_locs = find(force == max(force), 1, 'last');
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

% === 顯示文字報告 ===
fprintf('\n--- 📊 角度試驗：力量校正與統計報告 ---\n');
fprintf('試驗剝離角度：%d 度 (Peel Angle)\n', peelAngle);
fprintf('🔧 感測器已校正平移：-%.4f N\n', force_offset);
fprintf('偵測到的真實剝離次數：%d 次\n', num_peaks);
if num_peaks > 0
    fprintf('校正後多點平均臨界力量：%.4f N\n', avg_critical_force);
end
fprintf('--------------------------------------------------\n');



fig1 = figure('Color', 'w', 'Position', [100, 100, 800, 450]); 
plot(t, force, 'r-', 'LineWidth', 1.2); 
xlim([0 100])
ylim([0 3.5])
xlabel('Time (s)', 'FontName', 'Times New Roman', 'FontSize', 12);
ylabel('Force (N)', 'FontName', 'Times New Roman', 'FontSize', 12);
title_str1 = sprintf('%d^{\\circ} Peel Angle: Complete Raw Waveform', peelAngle); 
title(title_str1, 'FontName', 'Times New Roman', 'FontSize', 13, 'FontWeight', 'bold');
set(gca, 'FontName', 'Times New Roman', 'FontSize', 12, 'LineWidth', 1.2, 'TickDir', 'in');
box on; 

filename1 = sprintf('Angle_%d_FullWave.png', peelAngle);
saveas(fig1, filename1);


fig2 = figure('Color', 'w', 'Position', [150, 150, 800, 450]); 
plot(t, force, 'r-', 'LineWidth', 1.2); hold on; 

if num_peaks > 0
    plot(final_t, final_pks, 'ko', 'MarkerSize', 6, 'LineWidth', 1.5); 
    yline(avg_critical_force, 'b--', 'LineWidth', 1.5);
    text(t(end)*0.05, avg_critical_force * 1.05, ...
        sprintf('Average Critical Force = %.4f N', avg_critical_force), ...
        'Color', 'b', 'FontName', 'Times New Roman', 'FontWeight', 'bold', 'FontSize', 11);
end
xlim([0 100])
ylim([0 3.5])
xlabel('Time (s)', 'FontName', 'Times New Roman', 'FontSize', 12);
ylabel('Force (N)', 'FontName', 'Times New Roman', 'FontSize', 12);
title_str2 = sprintf('%d^{\\circ} Peel Angle: Analyzed Force vs Time', peelAngle); 
title(title_str2, 'FontName', 'Times New Roman', 'FontSize', 13, 'FontWeight', 'bold');
set(gca, 'FontName', 'Times New Roman', 'FontSize', 12, 'LineWidth', 1.2, 'TickDir', 'in');
box on; 
hold off;

filename2 = sprintf('Angle_%d_Analyzed.png', peelAngle);
saveas(fig2, filename2);


fprintf('【儲存成功】已自動儲存兩張角度圖表（已移除校正字眼）：\n');
fprintf('   1️⃣ 完整波圖：%s\n', filename1);
fprintf('   2️⃣ 分析過圖：%s\n\n', filename2);