
clear; clc; close all;
v = [9.0000, 1.8000, 0.9000, 0.6000, 0.4500, 0.4286, 0.4091, 0.3913, 0.3750, 0.3600, ...
     0.3000, 0.1800, 0.0900, 0.0600, 0.0450, 0.0300, 0.0257, 0.0240, 0.0231, 0.0228, ...
     0.0227, 0.0226, 0.0225, 0.0220, 0.0209, 0.0205, 0.0200, 0.0180];
 
F = [1.7666, 1.4933, 1.4792, 1.4202, 1.46095, 1.46255, 1.4310, 1.4233, 1.6325, 2.93015, ...
     2.84835, 2.72105, 2.8608, 2.8041, 2.72015, 2.661633333, 2.5786, 2.56095, 2.5026, 2.4228, ...
     2.4257, 2.4096, 2.3775, 2.3582, 2.2598, 2.3240, 2.2309, 2.3714];

[v_sorted, sort_idx] = sort(v);
F_sorted = F(sort_idx);

figure('Color', 'w', 'Position', [100, 100, 1000, 650]);
hold on; grid on;

v_fit = logspace(log10(min(v_sorted)), log10(max(v_sorted)), 500); 
F_fit = interp1(v_sorted, F_sorted, v_fit, 'pchip'); 
plot(v_fit, F_fit, '-', 'Color', [0.4 0.4 0.4], 'LineWidth', 1.5, 'HandleVisibility', 'off'); 

plot(v_sorted, F_sorted, 'o', 'Color', 'k', 'MarkerSize', 5, ...
    'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'none');

v_min = 0.0225; F_min = F(v == v_min); 
v_max =0.375; F_max = F(v == v_max); 

xline(v_min, '--r', 'LineWidth', 1.5, 'Alpha', 0.7);
xline(v_max, '--r', 'LineWidth', 1.5, 'Alpha', 0.7);
plot(v_min, F_min, 'ro', 'MarkerSize', 6, 'MarkerFaceColor', 'r');
plot(v_max, F_max, 'ro', 'MarkerSize', 6, 'MarkerFaceColor', 'r');
set(gca, 'XScale', 'log');
y_text_pos = 3.3; 
text(0.021, y_text_pos, sprintf('Low-Speed Zone\n(Continuous White)'), ...
    'HorizontalAlignment', 'right', 'Color', [0 0.4 0.7], 'FontSize', 11, 'FontWeight', 'bold');
text(sqrt(v_min * v_max), y_text_pos, sprintf('Stick-Slip\nOscillation Zone'), ...
    'HorizontalAlignment', 'center', 'Color', [0.8 0.3 0], 'FontSize', 11, 'FontWeight', 'bold');
text(0.42, y_text_pos, sprintf('High-Speed Zone\n(Continuous Transparent)'), ...
    'HorizontalAlignment', 'left', 'Color', [0 0.5 0], 'FontSize', 11, 'FontWeight', 'bold');
ylim([1.2, 3.6]); 
xlabel('Peel Velocity (cm/s)', 'FontSize', 14, 'FontWeight', 'bold', 'FontName', 'Times New Roman');
ylabel('Mean Peel Force (N)', 'FontSize', 14, 'FontWeight', 'bold', 'FontName', 'Times New Roman');
title('Force vs. Velocity: Polymeric Stick-Slip Transition', 'FontSize', 16, 'FontWeight', 'bold', 'FontName', 'Times New Roman');
set(gca, 'FontSize', 12, 'LineWidth', 1.2);
box on;
hold off;
