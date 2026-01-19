clc; clear;

% 离散系统建模
s = tf('s');
Gp = 4 / ((2*s + 1)*(0.5*s + 1));   % 被控对象
H = 1 / (0.05*s + 1);               % 传感器
Ts = 0.1;
Gz = c2d(Gp, Ts, 'zoh');
Hz = c2d(H, Ts, 'zoh');
GHz = c2d(Gp * H, Ts, 'zoh');
z = tf('z', Ts);

% 参数列表
Kp_list = [0.3, 0.5, 0.7, 0.9, 1.1];
Ki_list = [0.3, 0.5, 1.0];

% 响应图与性能记录
figure;
idx = 1;
infos = [];

for i = 1:length(Ki_list)
    Ki = Ki_list(i);
    subplot(length(Ki_list), 1, i);
    hold on;

    for j = 1:length(Kp_list)
        Kp = Kp_list(j);

        % 控制器结构：Gc(z) = Kp * (1 + Ki*Ts*z / (z-1))
        Gc = Kp * (1 + Ki * Ts * z / (z - 1));

        % 闭环系统
        CL = (Gc * Gz) / (1 + Gc * GHz);

        % 绘图
        [y, t] = step(CL, 10);
        plot(t, y, 'DisplayName', ['Kp=', num2str(Kp)]);

        % 记录性能
        [Mo, tp, tr, ts, ess] = kstats(t, y, 1);
        infos = [infos; struct('Kp', Kp, 'Ki', Ki, ...
            'Overshoot', Mo, 'RiseTime', tr, 'PeakTime', tp, ...
            'SettlingTime', ts, 'SteadyState', ess)];
    end

    title(['Ki = ', num2str(Ki), ' 的单位阶跃响应']);
    xlabel('时间 (s)'); ylabel('输出');
    legend show; grid on;
end

% 输出满足条件的参数组合
fprintf('\n满足条件（超调<10%% 且调整时间≤5s）参数如下：\n');
fprintf('\n%-6s %-6s %-12s %-12s %-12s %-15s %-12s\n', ...
    'Kp', 'Ki','Overshoot(%)', 'RiseTime(s)', 'PeakTime(s)', 'SettlingTime(s)', 'SteadyState(%)');

for i = 1:length(infos)
    if infos(i).Overshoot < 10 && infos(i).SettlingTime <= 5
        fprintf('%-6.1f %-6.1f %-12.2f %-12.4f %-12.4f %-15.4f %-12.4f\n', ...
            infos(i).Kp, infos(i).Ki, infos(i).Overshoot, infos(i).RiseTime, ...
            infos(i).PeakTime, infos(i).SettlingTime, infos(i).SteadyState);
    end
end

% ------------------ 分析最优参数下的扰动响应 ------------------
% 可根据上面的打印结果替换为实际满足条件的最优参数
Kp_star = 0.563;   % 示例值
Ki_star = 0.5;     % 示例值

Gc = Kp_star * (1 + Ki_star * Ts * z / (z - 1));
CL_ref = (Gc * Gz) / (1 + Gc * GHz);   % 参考输入响应
CL_dist = Gz / (1 + Gc * GHz);         % 扰动输入响应

% 仿真时间向量
k = 0:Ts:10;

% 获取单位阶跃响应数据
[y_ref, ~] = step(CL_ref, k);

% 提取性能指标
[Mo, kp, kr, ks, ess] = kstats(k, y_ref, 1.0);

% 作图
figure;
subplot(2,1,1);
step(CL_ref, 10);
title(['单位阶跃参考输入响应 (Kp=', num2str(Kp_star), ', Ki=', num2str(Ki_star), ')']);
ylabel('输出'); grid on;

subplot(2,1,2);
step(CL_dist, 10);
title('单位阶跃扰动输入响应');
xlabel('时间 (s)'); ylabel('输出'); grid on;

% 打印性能指标
fprintf('\n最优参数对应的性能指标:\n');
fprintf('  Mo  = %.2f %%\n', Mo);
fprintf('  tp  = %.2f s\n', kp);
fprintf('  tr  = %.2f s\n', kr);
fprintf('  ts  = %.2f s\n', ks);
fprintf('  ess = %.2f %%\n', ess);

%% 函数
function [Mo, tp, tr, ts, ess] = kstats(k, y, ref)
    if nargin < 3
        ref = 1;
        disp('参考值未指定，默认设为 1');
    end

    % 超调量和峰值时间
    [y_max, idx_peak] = max(y);
    tp = k(idx_peak);
    Mo = max(100 * (y_max - ref) / ref, 0);  % 百分比超调量

    % 上升时间（从 10% 到 90%）
    idx_10 = find(y >= 0.1 * ref, 1, 'first');
    idx_90 = find(y >= 0.9 * ref, 1, 'first');

    if ~isempty(idx_10) && ~isempty(idx_90) && idx_10 > 1 && idx_90 > 1
        Ts = k(2) - k(1);
        t10 = k(idx_10) - Ts * (y(idx_10) - 0.1 * ref) / (y(idx_10) - y(idx_10 - 1));
        t90 = k(idx_90) - Ts * (y(idx_90) - 0.9 * ref) / (y(idx_90) - y(idx_90 - 1));
        tr = t90 - t10;
    else
        tr = NaN;
    end

    % 调节时间（进入 2% 区间）
    idx_settle = find(abs(y - ref) > 0.02 * ref, 1, 'last');
    if isempty(idx_settle) || idx_settle == length(y)
        ts = k(end);
    else
        ts = k(idx_settle + 1);
    end

    % 稳态误差
    ess = abs(100 * (y(end) - ref) / ref);
end
