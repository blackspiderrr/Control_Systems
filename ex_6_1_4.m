% 4） 被控对象加入滞后环节（使用状态空间避免警告）
% 采样周期与延迟
T = 0.1;           % 采样周期 (s)
L = 0.2;           % 延迟时间 (s)

% 连续系统传递函数
s = tf('s');
Gp_s = exp(-L*s) / (s + 1);  % 被控对象带滞后项

% 转换为状态空间以提高建模效率
Gp_ss = ss(Gp_s);             % 转换为状态空间
Gp_z = c2d(Gp_ss, T, 'zoh');  % 离散化（ZOH法）

% 定义 PI 控制器参数
Kp = 8;
Ki = 1.5;
z = tf('z', T);
D_pi = Kp * (1 + Ki * T * z / (z - 1));  % 离散 PI 控制器（一阶后向差分）

% 闭环系统
G_cl = feedback(D_pi * Gp_z, 1);  % 闭环传递函数

% 仿真闭环系统阶跃响应
[y, t] = step(G_cl, 10);  % 仿真10秒
steady_state_value = y(end);  % 稳态值

% 绘图
figure;
stairs(t, y, 'LineWidth', 1.5);
hold on;
plot([t(1), t(end)], [1, 1], 'r--');
xlabel('时间 (s)');
ylabel('输出');
title('闭环阶跃响应（加入滞后环节）');
grid on;
legend('系统响应', '期望值');

% -------- 性能指标计算 --------
Mp = (max(y) - steady_state_value) / steady_state_value * 100;  % 最大超调率 %

% 上升时间 Tr（从10%到90%）
y_norm = y / steady_state_value;
t10 = t(find(y_norm >= 0.1, 1));
t90 = t(find(y_norm >= 0.9, 1));
Tr = t90 - t10;

% 调节时间 Ts（进入 ±2% 范围）
lower = 0.98 * steady_state_value;
upper = 1.02 * steady_state_value;
settle_idx = find(y < lower | y > upper);
if ~isempty(settle_idx)
    Ts = t(settle_idx(end));
else
    Ts = 0;
end

% 静态误差
steady_state_error = abs(1 - steady_state_value);
if steady_state_error < 0.01
    fprintf('系统无静差\n');
else
    fprintf('系统存在静差，静差大小为: %.4f\n', steady_state_error);
end

% -------- 输出性能指标 --------
fprintf('性能指标（加入滞后环节）:\n');
fprintf('最大超调量 Mp: %.2f%%\n', Mp);
fprintf('上升时间 Tr: %.4f s\n', Tr);
fprintf('调节时间 Ts: %.4f s\n', Ts);
fprintf('稳态输出值: %.4f\n', steady_state_value);
