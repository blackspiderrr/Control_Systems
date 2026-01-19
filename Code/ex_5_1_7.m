% 连续系统
s = tf('s');
D_s = (s^2 + s + 64) / (s^2 + 10*s + 64);
T = 1;

% 双线性变换法离散化
D_z = c2d(D_s, T, 'tustin');

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
ylabel('幅值 (dB)');
grid on;

% 相频响应
subplot(2,1,2);
semilogx(w, squeeze(phase_cont), 'b--', 'LineWidth', 1.5); hold on;
semilogx(w, squeeze(phase_disc), 'r');
title('相频响应');
xlabel('频率 (rad/s)');
ylabel('相位 (deg)');
grid on;

% 阶跃响应对比
t_cont = 0:0.01:20;
t_disc = 0:T:20;
y_cont = step(D_s, t_cont);
y_disc = step(D_z, t_disc);

figure;
plot(t_cont, y_cont, 'b--', 'LineWidth', 1.5); hold on;
stairs(t_disc, y_disc, 'r', 'LineWidth', 1.5);
legend('连续系统', '离散系统');
xlabel('时间 (s)');
ylabel('幅值');
title('阶跃响应对比');
grid on;
