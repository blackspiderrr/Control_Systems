% 连续系统定义
s = tf('s');
D_s = (s^2 + s + 64) / (s^2 + 10*s + 64);

%% 双线性变换法离散化（普通 Tustin）
T1 = 0.2; 
D_z1 = c2d(D_s, T1, 'tustin');

%% 预畸变双线性变换法离散化（prewarp）
T2 = 0.2;           % 较小采样周期
omega0 = 8;         % 预畸变频率 rad/s
D_z2 = c2d(D_s, T2, 'prewarp', omega0);

%% 幅频&相频响应对比
w = logspace(-1, 2, 500);  % 频率范围
[mag_cont, phase_cont] = bode(D_s, w);
[mag_z1, phase_z1] = bode(D_z1, w);
[mag_z2, phase_z2] = bode(D_z2, w);

figure;
% 幅频响应
subplot(2,1,1);
semilogx(w, 20*log10(squeeze(mag_cont)), 'k--', 'LineWidth', 1.5); hold on;
semilogx(w, 20*log10(squeeze(mag_z1)), 'r-');
semilogx(w, 20*log10(squeeze(mag_z2)), 'b-');
legend('连续系统', '双线性变换', '预畸变变换');
title('幅频响应对比');
ylabel('幅值 (dB)');
grid on;

% 相频响应
subplot(2,1,2);
semilogx(w, squeeze(phase_cont), 'k--', 'LineWidth', 1.5); hold on;
semilogx(w, squeeze(phase_z1), 'r-');
semilogx(w, squeeze(phase_z2), 'b-');
legend('连续系统', '双线性变换', '预畸变变换');
xlabel('频率 (rad/s)');
ylabel('相位 (deg)');
title('相频响应对比');
grid on;