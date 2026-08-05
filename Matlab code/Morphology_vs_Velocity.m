clc; close all;
% =======================================================
% 🌟 實驗數據輸入區 
% =======================================================
delay = [50	100	150	200	300]; 
w_mean = [0.2933	0.7733	1.0800	1.0286	1.5500]; 
w_std  = [0.0944	0.1100	0.0775	0.1462	0.1849]; 
t_mean = [1.8867	1.2467	1.3714	1.2786	1.3000];
t_std  = [0.1167	0.2477	0.1773	0.2007	0.2089]; 

% =======================================================
% ⚙️ 物理量轉換與資料預處理
% =======================================================
velocity = 46.25 ./ delay;
[v_sorted, sort_idx] = sort(velocity);
w_mean_sorted = w_mean(sort_idx);
w_std_sorted  = w_std(sort_idx);
t_mean_sorted = t_mean(sort_idx);
t_std_sorted  = t_std(sort_idx);
l_mean_sorted = w_mean_sorted + t_mean_sorted;
l_std_sorted  = sqrt(w_std_sorted.^2 + t_std_sorted.^2);

% =======================================================
% 📈 數學擬合 (曲線模型設定)
% =======================================================
% 白帶 (White) 與 總波長 (\lambda) 隨速度降低而飆升，採用反比擬合: y = a/v + b
p_w = polyfit(1./v_sorted, w_mean_sorted, 1);
p_l = polyfit(1./v_sorted, l_mean_sorted, 1);
% 透明帶 (Transparent) 隨速度降低而微幅縮短，採用標準線性擬合: y = a*v + b
p_t = polyfit(v_sorted, t_mean_sorted, 1);

% =======================================================
% 🗺️ 定義繪圖範圍 (包含 delay 400 的外插預測)
% =======================================================
v_min_exp = min(v_sorted); % 實驗量測到的最低速 (delay 300)
v_max_exp = max(v_sorted); % 實驗量測到的最高速 (delay 50)
v_ext_low_limit = 46.25 / 400; % 預測延伸的低速極限 (delay 400)
v_ext_high_limit = v_max_exp * 1.15; % 預測延伸的高速極限

% 產生各種區間的 X 軸高密度點
v_inside = linspace(v_min_exp, v_max_exp, 100);
v_predict_low = linspace(v_ext_low_limit, v_min_exp, 50);
v_predict_high = linspace(v_max_exp, v_ext_high_limit, 50);

% =======================================================
% 📊 畫圖
% =======================================================
fig = figure('Color', 'w', 'Position', [150, 150, 850, 600]);
hold on; grid on;

% --- A. Stripe spacing (\lambda) : 黑色反比曲線 ---
h1_fit = plot(v_inside, p_l(1)./v_inside + p_l(2), 'k-', 'LineWidth', 2);
plot(v_predict_low, p_l(1)./v_predict_low + p_l(2), 'k--', 'LineWidth', 1.5, 'HandleVisibility', 'off');
plot(v_predict_high, p_l(1)./v_predict_high + p_l(2), 'k--', 'LineWidth', 1.5, 'HandleVisibility', 'off');
% ⚠️ 已修正：數據點與 errorbar 完全對齊真實速度 v_sorted
h1_data = errorbar(v_sorted, l_mean_sorted, l_std_sorted, 'Color', [0.2 0.2 0.2], 'LineStyle', 'none', 'LineWidth', 1.0, 'CapSize', 4);
set(h1_data, 'Marker', 's', 'MarkerSize', 7, 'MarkerFaceColor', 'w', 'MarkerEdgeColor', 'k');

% --- B. Transparent Zone : 藍色線性趨勢 ---
h2_fit = plot(v_inside, p_t(1).*v_inside + p_t(2), '-', 'Color', [0, 0.447, 0.741], 'LineWidth', 2);
plot(v_predict_low, p_t(1).*v_predict_low + p_t(2), '--', 'Color', [0, 0.447, 0.741], 'LineWidth', 1.5, 'HandleVisibility', 'off');
plot(v_predict_high, p_t(1).*v_predict_high + p_t(2), '--', 'Color', [0, 0.447, 0.741], 'LineWidth', 1.5, 'HandleVisibility', 'off');
% ⚠️ 已修正：數據點與 errorbar 完全對齊真實速度 v_sorted
h2_data = errorbar(v_sorted, t_mean_sorted, t_std_sorted, 'Color', [0, 0.447, 0.741], 'LineStyle', 'none', 'LineWidth', 1.0, 'CapSize', 4);
set(h2_data, 'Marker', '^', 'MarkerSize', 7, 'MarkerFaceColor', 'w', 'MarkerEdgeColor', [0, 0.447, 0.741]);

% --- C. White Zone : 紅色反比曲線 ---
h3_fit = plot(v_inside, p_w(1)./v_inside + p_w(2), '-', 'Color', [0.850, 0.325, 0.098], 'LineWidth', 2);
plot(v_predict_low, p_w(1)./v_predict_low + p_w(2), '--', 'Color', [0.850, 0.325, 0.098], 'LineWidth', 1.5, 'HandleVisibility', 'off');
plot(v_predict_high, p_w(1)./v_predict_high + p_w(2), '--', 'Color', [0.850, 0.325, 0.098], 'LineWidth', 1.5, 'HandleVisibility', 'off');
% ⚠️ 已修正：數據點與 errorbar 完全對齊真實速度 v_sorted
h3_data = errorbar(v_sorted, w_mean_sorted, w_std_sorted, 'Color', [0.850, 0.325, 0.098], 'LineStyle', 'none', 'LineWidth', 1.0, 'CapSize', 4);
set(h3_data, 'Marker', 'o', 'MarkerSize', 7, 'MarkerFaceColor', 'w', 'MarkerEdgeColor', [0.850, 0.325, 0.098]);

% =======================================================
% 🎨 介面優化
% =======================================================
xlim([0, v_ext_high_limit]);
y_max_estimated = p_l(1)./v_ext_low_limit + p_l(2);
ylim([0, y_max_estimated * 1.1]); 

xlabel('Pulling Speed (mm/s)', 'FontName', 'Times New Roman', 'FontSize', 14, 'FontWeight', 'bold');
ylabel('Feature Length (mm)', 'FontName', 'Times New Roman', 'FontSize', 14, 'FontWeight', 'bold');
title('Effect of Pulling Speed on Stick-Slip Morphological Features', 'FontName', 'Times New Roman', 'FontSize', 15, 'FontWeight', 'bold');

legend([h1_fit, h2_fit, h3_fit], ...
    {'Stripe spacing (\lambda)', 'Transparent Zone Length', 'White Zone Length'}, ...
    'Location', 'eastoutside', 'FontName', 'Times New Roman', 'FontSize', 12);

set(gca, 'FontName', 'Times New Roman', 'FontSize', 12, 'LineWidth', 1.2, 'TickDir', 'in');
set(gca, 'GridColor', [0.8 0.8 0.8], 'GridAlpha', 0.4);
box on;
hold off;

saveas(fig, 'Morphology_vs_Velocity_Physics_Fitted.png');
disp('✅ 帶有物理預測虛線的反比擬合圖已繪製完成！');