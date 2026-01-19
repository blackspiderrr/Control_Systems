clear; close all; clc;
fs = 10;         % 采样频率
f = 0:0.1:50;    % 频率轴
omega = 2*pi*f/fs;
H = sin(omega/2) ./ (fs* omega/2) .* exp(-1i*omega/2);  % ZOH 频率响应

mag = abs(H);
phase = angle(H);

subplot(2,1,1);
plot(f, mag);
title('ZOH 幅值谱');
xlabel('频率 (Hz)'); ylabel('|H(jω)|'); grid on;

subplot(2,1,2);
plot(f, phase);
title('ZOH 相位谱');
xlabel('频率 (Hz)'); ylabel('∠H(jω)'); grid on;
