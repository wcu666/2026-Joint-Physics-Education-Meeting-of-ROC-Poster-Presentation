clc; close all; % 保持工作區乾淨

% =======================================================
% 🌟 實驗數據輸入區 (Delay = 100)
% =======================================================
angle = [0, 5, 10, 15, 20];
force = [2.7967, 2.6219, 2.4630, 2.2564, 2.2405];

% =======================================================
% 📊 開始繪製趨勢圖 (黑線 + 曲線擬合)
% =======================================================
fig = figure('Color', 'w', 'Position', [150, 150, 800, 500]);
hold on; grid on;

% 1. 數學曲線擬合 (Curve Fitting - 二次多項式)
% 產生 100 個細密點讓曲線平滑
p = polyfit(angle, force, 2); 
angle_fit = linspace(min(angle), max(angle), 100);
force_fit = polyval(p, angle_fit);

% 2. 繪製「擬合趨勢線」(純黑色粗實線)
plot(angle_fit, force_fit, 'k-', 'LineWidth', 2, 'HandleVisibility', 'off');

% 3. 繪製「真實數據點」(純黑色圓點)
plot(angle, force, 'ko', 'MarkerSize',5, 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'w');

% 4. 在每個原始數據點的上方加上精確數值標籤
for i = 1:length(angle)
    text(angle(i), force(i) + 0.04, sprintf('%.4f', force(i)), ...
        'FontName', 'Times New Roman', 'FontSize', 11, ...
        'HorizontalAlignment', 'center', 'Color', 'k', 'FontWeight', 'bold');
end

% 5. 設定座標軸範圍與刻度
xlim([-2, 22]);
ylim([2.1, 2.95]); % 稍微拉高一點，避免數字被頂部切到
xticks(0:5:20);   % X軸刻度明確標示 0, 5, 10, 15, 20

% 6. 設定座標軸標籤
xlabel('Peel Angle (Degree)', 'FontName', 'Times New Roman', 'FontSize', 14, 'FontWeight', 'bold');
ylabel('Average Critical Force (N)', 'FontName', 'Times New Roman', 'FontSize', 14, 'FontWeight', 'bold');

% 7. 設定論文級標題
title('Effect of Peel Angle on Critical Force (Delay = 100ms)', ...
    'FontName', 'Times New Roman', 'FontSize', 15, 'FontWeight', 'bold');

% 8. 全域排版微調
set(gca, 'FontName', 'Times New Roman', 'FontSize', 12, 'LineWidth', 1.2, 'TickDir', 'in');
% 將網格線調淡一點，不喧賓奪主
set(gca, 'GridColor', [0.8 0.8 0.8], 'GridAlpha', 0.5); 
box on;
hold off;

% =======================================================
% 💾 自動存檔
% =======================================================
filename = 'Angle_vs_Force_Fitted_Delay100.png';
saveas(fig, filename);

fprintf('--- 📊 趨勢圖繪製完成 ---\n');
fprintf('💾 【儲存成功】已自動儲存高解析度圖表：\n');
fprintf('   👉 檔名：%s\n\n', filename);