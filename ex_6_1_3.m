% 3）调节比例积分控制器的比例参数
% 系统参数
T = 0.1;                         % 采样时间(s)
Gp_s = tf(1, [1 1]);             % 连续系统 Gp(s) = 1 / (s + 1)
z = tf('z', T);                  
Gp_z = c2d(Gp_s, T, 'zoh');      % 离散化被控对象

% PI 控制器参数
Kp = 8;
Ki = 1.5;
D_pi = Kp * (1 + Ki*T*z/(z - 1)); % PI 控制器离散形式

% 闭环系统传递函数
G_cl = (D_pi * Gp_z) / (1 + D_pi * Gp_z);

% 阶跃响应仿真
[y, t] = step(G_cl, 5);                  % 仿真 5 秒
steady_state_value = y(end);            % 稳态值

% 绘图
figure;
stairs(t, y, 'LineWidth', 1.5);         % 离散响应
hold on;
plot([t(1), t(end)], [1, 1], 'r--');    % 参考线
xlabel('时间 (s)');
ylabel('输出');
title('闭环系统阶跃响应 (Kp=8, Ki=1.5)');
legend('系统响应', '期望值');
grid on;

% 计算性能指标
Mp = (max(y) - steady_state_value)/steady_state_value * 100; % 最大超调量 (%)

% 上升时间 Tr（10%~90%）
y_normalized = y / steady_state_value;
t10 = t(find(y_normalized >= 0.1, 1));
t90 = t(find(y_normalized >= 0.9, 1));
Tr = t90 - t10;

% 调节时间 Ts（进入±2%误差带）
lower = 0.98 * steady_state_value;
upper = 1.02 * steady_state_value;
idx = find(y < lower | y > upper);
if ~isempty(idx)
    Ts = t(idx(end));
else
    Ts = 0;
end

% 静态误差分析
steady_state_error = abs(1 - steady_state_value);
if steady_state_error < 0.01
    fprintf('系统无静差\n');
else
    fprintf('系统存在静差，静差为: %.4f\n', steady_state_error);
end

% 输出性能参数
fprintf('性能指标 (Kp=%.1f, Ki=%.1f):\n', Kp, Ki);
fprintf('最大超调量 Mp: %.2f%%\n', Mp);
fprintf('上升时间 Tr: %.4f s\n', Tr);
fprintf('调节时间 Ts: %.4f s\n', Ts);
fprintf('稳态输出值: %.4f\n', steady_state_value);
