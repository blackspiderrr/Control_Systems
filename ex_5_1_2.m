% 连续系统
s = tf('s');
D_s = (s^2 + s + 64) / (s^2 + 10*s + 64);
T = 0.2;

% 定义离散变量 z
z = tf('z', T);

% 后向差分替换：s = (1 - z^-1)/T = (z - 1)/(T * z)
s_backward = (z - 1) / (T * z);

% 将 s 替换到 D(s) 中
D_z = (s_backward^2 + s_backward + 64) / (s_backward^2 + 10*s_backward + 64);

% 验证频率响应
w = logspace(-1, 2, 500);  % 频率范围
[mag_cont, phase_cont] = bode(D_s, w);
[mag_disc, phase_disc] = bode(D_z, w);

% 绘图：幅频响应
figure;
subplot(2,1,1);
semilogx(w, 20*log10(squeeze(mag_cont)), 'b--', 'LineWidth', 1.5); hold on;
semilogx(w, 20*log10(squeeze(mag_disc)), 'r');
title('幅频响应');
legend('连续系统', '离散系统');
grid on;

% 相频响应
subplot(2,1,2);
semilogx(w, squeeze(phase_cont), 'b--', 'LineWidth', 1.5); hold on;
semilogx(w, squeeze(phase_disc), 'r');
title('相频响应');
xlabel('频率 (rad/s)');
grid on;

