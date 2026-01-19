% 7）Smith 预估器控制器设计
T = 0.1;                          % 采样周期
L = 0.2;                          % 延迟时间
s = tf('s');
z = tf('z', T);

% 被控对象 Gp(s) 带延迟项
Gp_s = 1 / (s + 1);              
Gp_z = c2d(exp(-L*s) * Gp_s, T, 'zoh');  % 离散化含延迟系统

% PI 控制器参数（可替换为调优值）
Kp = 8;
Ki = 1.5;

% 后向差分离散 PI 控制器
D_pi_base = Kp * (1 + Ki * T * z / (z - 1)); 

% Smith 预估器部分，预测延迟带来的影响
D_z = c2d((1 - exp(-L*s)) * Gp_s, T, 'zoh');
D_pi = D_pi_base / (1 + D_pi_base * D_z);  % Smith 校正器结构

% 闭环系统
G_cl = feedback(D_pi * Gp_z, 1);

% 阶跃响应仿真
[y, t] = step(G_cl, 10);
y_final = y(end);

% 绘制响应图
figure;
stairs(t, y, 'LineWidth', 1.5);
hold on;
plot([t(1), t(end)], [1, 1], 'r--');   % 目标值参考线
xlabel('时间 (s)');
ylabel('输出');
title('Smith 预估器闭环响应');
legend('系统响应', '期望值');
grid on;

% 计算性能指标
Mp = (max(y) - y_final) / y_final * 100;     % 最大超调量（%）

% 上升时间 Tr（10% 到 90%）
y_norm = y / y_final;
t10 = t(find(y_norm >= 0.1, 1));
t90 = t(find(y_norm >= 0.9, 1));
Tr = t90 - t10;

% 调节时间 Ts（±2% 误差带）
lower_bound = 0.98 * y_final;
upper_bound = 1.02 * y_final;
out_of_band = find(y < lower_bound | y > upper_bound);
if ~isempty(out_of_band)
    Ts = t(out_of_band(end));
else
    Ts = 0;
end

% 静态误差判断
ess = abs(1 - y_final);
if ess < 0.01
    fprintf('系统无明显静态误差。\n');
else
    fprintf('系统存在静态误差，误差为: %.4f\n', ess);
end

% 输出性能指标
fprintf('性能指标（Smith 预估器）:\n');
fprintf('最大超调量 Mp: %.2f%%\n', Mp);
fprintf('上升时间 Tr: %.4f s\n', Tr);
fprintf('调节时间 Ts: %.4f s\n', Ts);
fprintf('稳态输出值: %.4f\n', y_final);
