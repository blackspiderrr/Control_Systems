% 2）设计比例积分控制器，求阶跃响应
% 系统参数
T = 0.1;                        % 采样时间 (s)
Gp_s = tf(1, [1 1]);            % 被控对象连续传递函数 Gp(s) = 1 / (s + 1)

% 离散化对象（ZOH 零阶保持）
Gp_z = c2d(Gp_s, T, 'zoh');

% 设计比例积分控制器 D(z) = Kp * (1 + Ki * T * z / (z - 1))
Kp = 10;
Ki = 2;
D_pi = Kp * (1 + Ki * T * z / (z - 1));

% 闭环系统传递函数 G_cl = D(z)Gp(z)/(1 + D(z)Gp(z))
G_cl = feedback(D_pi * Gp_z, 1);

% 仿真并获取阶跃响应
[y, t] = step(G_cl, 5);              % 仿真时长 5 秒
steady_state_value = y(end);        % 稳态值估计

% 绘制阶跃响应曲线
figure;
stairs(t, y, 'LineWidth', 1.5);      % 使用 stairs 更适合离散系统响应
hold on;
plot([t(1), t(end)], [1, 1], 'r--'); % 单位阶跃参考线
xlabel('时间 (s)');
ylabel('系统输出');
title('闭环系统阶跃响应（PI 控制器）');
legend('系统响应', '参考值');
grid on;

% 计算性能指标
Mp = (max(y) - steady_state_value) / steady_state_value * 100;  % 最大超调量 (%)

% 上升时间 Tr（从10%到90%）
y_normalized = y / steady_state_value;
t10 = t(find(y_normalized >= 0.1, 1));
t90 = t(find(y_normalized >= 0.9, 1));
Tr = t90 - t10;

% 调节时间 Ts（±2%误差带内）
lower_bound = 0.98 * steady_state_value;
upper_bound = 1.02 * steady_state_value;
settling_indices = find(y < lower_bound | y > upper_bound);
if ~isempty(settling_indices)
    Ts = t(settling_indices(end));
else
    Ts = 0;
end

% 稳态误差判断
steady_state_error = abs(1 - steady_state_value);
if steady_state_error < 0.01
    fprintf('系统无静差。\n');
else
    fprintf('系统存在静差，大小为: %.4f\n', steady_state_error);
end

% 输出性能指标
fprintf('闭环系统性能指标（PI 控制器：Kp = %.1f, Ki = %.1f）：\n', Kp, Ki);
fprintf('最大超调量 Mp: %.2f%%\n', Mp);
fprintf('上升时间 Tr: %.4f s\n', Tr);
fprintf('调节时间 Ts: %.4f s\n', Ts);
fprintf('稳态输出值: %.4f\n', steady_state_value);
