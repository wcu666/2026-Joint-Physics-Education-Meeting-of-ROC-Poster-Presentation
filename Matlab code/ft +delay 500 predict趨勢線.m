% ---------------------------------------------------------
% 膠帶黏滑現象 - 力量與速度關係圖 (Speed: mm/s 雙圖版本)
% ---------------------------------------------------------
clear; clc; close all;

% 1. 輸入原始數據 (cm/s)
v_cms = [4.6250 0.9250 0.4625 0.3083 0.2313 0.2202 0.2102 0.2011 0.19271 0.18500 0.15417 0.09250 0.04625 0.03083 0.02313 0.01542 0.01321 0.01233 0.01186 0.01171 0.01165 0.01159 0.01156 0.01128 0.01076 0.01051 0.01028 0.00925 0.00841 0.00771];
F = [1.5758 1.4933 1.4792 1.4202 1.46095 1.46255 1.431 1.4233 1.6325 2.93015 2.84835 2.72105 2.8608 2.8041 2.72015 2.661633333 2.5786 2.56095 2.5026 2.4228 2.4257 2.4096 2.3775 2.3582 2.2598 2.2498 2.2309 2.2271 2.226 2.2223];

% 轉換速度單位為 mm/s
v = v_cms * 10; 

% 2. 依照速度 (X軸) 由小到大重新排序
[v_sorted, sort_idx] = sort(v);
F_sorted = F(sort_idx);

% 定義臨界點 (對應原始數據，並轉換為 mm/s)
v_min_cms = 0.01156; v_max_cms = 0.19271;
F_min = F(abs(v_cms - v_min_cms) < 1e-5); 
F_max = F(abs(v_cms - v_max_cms) < 1e-5);
v_min = v_min_cms * 10; 
v_max = v_max_cms * 10;

% =========================================================
% 🎯 定義繪圖與外推範圍
% =========================================================
extrap_factor = 10;
v_left_limit = min(v_sorted) / extrap_factor;  
v_right_limit = max(v_sorted) * extrap_factor; 

% 共用的文字與排版設定
y_text_pos = 3.5; 
pos_left_center   = sqrt(v_left_limit * v_min);
pos_middle_center = sqrt(v_min * v_max);
pos_right_center  = sqrt(v_max * v_right_limit);

% =========================================================
% 📈 Figure 1: 包含內插實線與外插預測虛線 (完整版)
% =========================================================
fig1 = figure('Color', 'w', 'Position', [100, 100, 1000, 650], 'Name', 'With Extrapolation');
hold on; grid on;

% 繪製平滑擬合趨勢線 (內插)
v_fit = logspace(log10(min(v_sorted)), log10(max(v_sorted)), 500); 
F_fit = interp1(v_sorted, F_sorted, v_fit, 'pchip'); 
plot(v_fit, F_fit, '-', 'Color', [0.4 0.4 0.4], 'LineWidth', 1.5, 'HandleVisibility', 'off'); 

% 高速端 (右側) 虛線理論預測 (外插)
v_last_right = v_sorted(end); 
F_last_right = F_sorted(end);
p_fit_right = polyfit(log10(v_sorted(end-3:end)), F_sorted(end-3:end), 1);
tangent_slope_right = p_fit_right(1); 
v_extrap_right = logspace(log10(v_last_right), log10(v_right_limit), 100);
F_extrap_right = F_last_right + tangent_slope_right * (log10(v_extrap_right) - log10(v_last_right));
plot(v_extrap_right, F_extrap_right, '--', 'Color', [0.4 0.4 0.4], 'LineWidth', 1.5, 'HandleVisibility', 'off');

% 低速端 (左側) 虛線理論外推趨勢 (外插)
v_last = v_sorted(1); 
F_last = F_sorted(1); 
p_fit = polyfit(log10(v_sorted(1:4)), F_sorted(1:4), 1);
tangent_slope = p_fit(1); 
F_plateau = 2.2; 
beta = tangent_slope / (F_last - F_plateau);
v_extrap = logspace(log10(v_left_limit), log10(v_last), 100);
F_extrap = F_plateau + (F_last - F_plateau) * exp(beta * (log10(v_extrap) - log10(v_last)));
plot(v_extrap, F_extrap, '--', 'Color', [0.4 0.4 0.4], 'LineWidth', 1.5, 'HandleVisibility', 'off');

% 繪製真實數據的散佈點
plot(v_sorted, F_sorted, 'o', 'Color', 'k', 'MarkerSize', 5, 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'none');

% 畫出縱向紅色虛線與標記點
xline(v_min, '--r', 'LineWidth', 1.5, 'Alpha', 0.7);
xline(v_max, '--r', 'LineWidth', 1.5, 'Alpha', 0.7);
plot(v_min, F_min, 'ro', 'MarkerSize', 6, 'MarkerFaceColor', 'r');
plot(v_max, F_max, 'ro', 'MarkerSize', 6, 'MarkerFaceColor', 'r');

% 座標軸與文字設定
set(gca, 'XScale', 'log');
xlim([v_left_limit, v_right_limit]); 
ylim([1.2, 3.8]); 
text(pos_left_center, y_text_pos, sprintf('Low-Speed Zone\n(Continuous White)'), 'HorizontalAlignment', 'center', 'Color', [0 0.4 0.7], 'FontSize', 12, 'FontWeight', 'bold');
text(pos_middle_center, y_text_pos, sprintf('Stick-Slip\nOscillation Zone'), 'HorizontalAlignment', 'center', 'Color', [0.8 0.3 0], 'FontSize', 12, 'FontWeight', 'bold');
text(pos_right_center, y_text_pos, sprintf('High-Speed Zone\n(Continuous Transparent)'), 'HorizontalAlignment', 'center', 'Color', [0 0.5 0], 'FontSize', 12, 'FontWeight', 'bold');
xlabel('Pullying Speed (mm/s)', 'FontSize', 14, 'FontWeight', 'bold', 'FontName', 'Times New Roman');
ylabel('Mean Peel Force (N)', 'FontSize', 14, 'FontWeight', 'bold', 'FontName', 'Times New Roman');
title('Force vs. Speed: Polymeric Stick-Slip Transition', 'FontSize', 16, 'FontWeight', 'bold', 'FontName', 'Times New Roman');
set(gca, 'FontSize', 12, 'LineWidth', 1.2);
box on; hold off;

% =========================================================
% 📉 Figure 2: 僅有內插實線，無外插預測版本
% =========================================================
fig2 = figure('Color', 'w', 'Position', [150, 150, 1000, 650], 'Name', 'Interpolation Only');
hold on; grid on;

% 繪製平滑擬合趨勢線 (僅內插，連接真實數據範圍)
v_fit2 = logspace(log10(min(v_sorted)), log10(max(v_sorted)), 500); 
F_fit2 = interp1(v_sorted, F_sorted, v_fit2, 'pchip'); 
plot(v_fit2, F_fit2, '-', 'Color', [0.4 0.4 0.4], 'LineWidth', 1.5, 'HandleVisibility', 'off'); 

% 直接繪製真實數據的散佈點
plot(v_sorted, F_sorted, 'o', 'Color', 'k', 'MarkerSize', 5, 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'none');

% 畫出縱向紅色虛線與標記點
xline(v_min, '--r', 'LineWidth', 1.5, 'Alpha', 0.7);
xline(v_max, '--r', 'LineWidth', 1.5, 'Alpha', 0.7);
plot(v_min, F_min, 'ro', 'MarkerSize', 6, 'MarkerFaceColor', 'r');
plot(v_max, F_max, 'ro', 'MarkerSize', 6, 'MarkerFaceColor', 'r');

% 座標軸與文字設定
set(gca, 'XScale', 'log');
xlim([v_left_limit, v_right_limit]); 
ylim([1.2, 3.8]); 
text(pos_left_center, y_text_pos, sprintf('Low-Speed Zone\n(Continuous White)'), 'HorizontalAlignment', 'center', 'Color', [0 0.4 0.7], 'FontSize', 12, 'FontWeight', 'bold');
text(pos_middle_center, y_text_pos, sprintf('Stick-Slip\nOscillation Zone'), 'HorizontalAlignment', 'center', 'Color', [0.8 0.3 0], 'FontSize', 12, 'FontWeight', 'bold');
text(pos_right_center, y_text_pos, sprintf('High-Speed Zone\n(Continuous Transparent)'), 'HorizontalAlignment', 'center', 'Color', [0 0.5 0], 'FontSize', 12, 'FontWeight', 'bold');
xlabel('Pullying Speed (mm/s)', 'FontSize', 14, 'FontWeight', 'bold', 'FontName', 'Times New Roman');
ylabel('Mean Peel Force (N)', 'FontSize', 14, 'FontWeight', 'bold', 'FontName', 'Times New Roman');
title('Force vs. Speed: Polymeric Stick-Slip Transition', 'FontSize', 16, 'FontWeight', 'bold', 'FontName', 'Times New Roman');
set(gca, 'FontSize', 12, 'LineWidth', 1.2);
box on; hold off;