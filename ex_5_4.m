clc; clear;
% 系统建模
s = tf('s');
Gp = 4 / ((2*s + 1)*(0.5*s + 1));  % 被控对象
H = 1 / (0.05*s + 1);              % 传感器
Ts = 0.1;
Gz = c2d(Gp, Ts, 'zoh');
Hz = c2d(H, Ts, 'zoh');
GHz = c2d(Gp * H, Ts, 'zoh');
z = tf('z', Ts);

% 枚举 PID 参数范围
Kp_list = 1.9;
Ki_list = 0.4;
Kd_list = 0.4;

% 存储满足条件的解
results = [];

% 穷举搜索满足条件的参数组合
for Kp = Kp_list
    for Ki = Ki_list
        for Kd = Kd_list

            % PID 控制器公式
            Gc = Kp * (1 + (Ki * Ts * z) / (z - 1) + (Kd * (z - 1)) / (Ts * z));

            % 闭环系统
            CL = (Gc * Gz) / (1 + Gc * GHz);

            % 阶跃响应性能指标
            [y, t] = step(CL, 10);
            [Mo, kp, kr, ks, ess] = kstats(t, y, 1);
            info.Kp = Kp;
            info.Mo = Mo;
            info.tp = kp;
            info.tr = kr;
            info.ts = ks;
            info.ess = ess;

            if info.Mo <= 5 && ...
               info.tr <= 0.35 && ...
               info.ts <= 1.4
                % 记录满足条件的参数并绘图
                figure;
                plot(t, y, 'LineWidth', 1.5);
                grid on;
                
                % 添加坐标轴标签和标题
                xlabel('时间 (s)', 'FontSize', 10);
                ylabel('系统输出', 'FontSize', 10);
                title(sprintf('PID控制阶跃响应 (Kp=%.1f, Ki=%.1f, Kd=%.1f)', Kp, Ki, Kd), ...
                      'FontSize', 12, 'FontWeight', 'bold');                
                results = [results; struct(...
                    'Kp', Kp, 'Ki', Ki, 'Kd', Kd, ...
                    'Overshoot', info.Mo,'RiseTime', info.tr, 'PeakTime', info.tp,...
                    'SettlingTime', info.ts,'SteadyState',info.ess )];
            end
        end
    end
end

fprintf('\n满足设计指标的 PID 参数如下：\n');
for i = 1:length(results)
    r = results(i);
    fprintf('Kp = %.1f\n', r.Kp);
    fprintf('Ki = %.1f\n', r.Ki);
    fprintf('Kd = %.1f\n', r.Kd);
    fprintf('Overshoot = %.2f%%\n', r.Overshoot);
    fprintf('Rise Time = %.4fs\n', r.RiseTime);
    fprintf('Peak Time = %.4fs\n', r.PeakTime);
    fprintf('Settling Time = %.4fs\n', r.SettlingTime);
    fprintf('Steady State Error = %.4f\n', r.SteadyState);
end

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