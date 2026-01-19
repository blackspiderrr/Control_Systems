% 连续系统
s = tf('s');
D_s = (s^2 + s + 64) / (s^2 + 10*s + 64);
T = 0.2;

% 阶跃响应不变法离散化
D_z = c2d(D_s, T, 'zoh');

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

% 仿真阶跃响应
t_continuous = 0:T:2;
y_continuous = step(D_s, t_continuous);

t_discrete = 0:T:2;
y_discrete = step(D_z, t_discrete);

% 绘图比较
figure;
stairs(t_discrete, y_discrete, 'r'); hold on;
plot(t_continuous, y_continuous, 'b--');
legend('离散 D(z)', '连续 D(s)');
xlabel('时间 (s)'); ylabel('阶跃响应');
title('验证');