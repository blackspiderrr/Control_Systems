% 5） 调节参数以保持最大超调量基本不变
T = 0.1;                                 % 采样周期 (秒)
s = tf('s');
z = tf('z', T);

Gp_s = tf(1, [1 1]);                     % 连续系统 Gp(s) = 1 / (s + 1)
Gp_z = c2d(Gp_s, T, 'zoh');              % 离散化（ZOH）

% PI 控制器设计参数
Kp = 1;
Ki = 1.65;
D_pi = Kp * (1 + Ki * T * z / (z - 1));  % 后向差分离散 PI 控制器

% 闭环传递函数
G_cl = feedback(D_pi * Gp_z, 1);

% 获取阶跃响应
[y, t] = step(G_cl, 10);
steady_value = y(end);                  % 稳态值

% 绘图
figure;
stairs(t, y, 'LineWidth', 1.5);
hold on;
plot([t(1), t(end)], [1 1], 'r--');     % 期望输出参考线
xlabel('时间 (s)');
ylabel('输出');
title('闭环阶跃响应（调整后参数）');
legend('系统响应', '期望值');
grid on;

% 性能指标计算
Mp = (max(y) - steady_value) / steady_value * 100;  % 最大超调(%)

% 上升时间 Tr（10% -> 90%）
y_norm = y / steady_value;
t10 = t(find(y_norm >= 0.1, 1));
t90 = t(find(y_norm >= 0.9, 1));
Tr = t90 - t10;

% 调节时间 Ts（±2% 带内）
lower = 0.98 * steady_value;
upper = 1.02 * steady_value;
idx = find(y < lower | y > upper);
if ~isempty(idx)
    Ts = t(idx(end));
else
    Ts = 0;
end

% 静态误差
ess = abs(1 - steady_value);
if ess < 0.01
    fprintf('系统无明显静态误差。\n');
else
    fprintf('系统存在静态误差，误差为：%.4f\n', ess);
end

% 输出性能指标
fprintf('性能指标（Kp = %.2f, Ki = %.2f）:\n', Kp, Ki);
fprintf('最大超调量 Mp: %.2f%%\n', Mp);
fprintf('上升时间 Tr: %.4f s\n', Tr);
fprintf('调节时间 Ts: %.4f s\n', Ts);
fprintf('稳态输出值: %.4f\n', steady_value);
