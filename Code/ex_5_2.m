clc; clear; close all;

%% 系统建模
Ts = 0.1;  % 采样周期
Gp = tf(4, conv([2 1], [0.5 1]));   % Gp(s) = 4/[(2s+1)(0.5s+1)]
H = tf(1, [0.05 1]);                % H(s) = 4/(0.05s+1)

% 离散化
Gpz = c2d(Gp, Ts, 'zoh');           % 零阶保持离散化
Hz  = c2d(H, Ts, 'zoh');            % 零阶保持离散化
GHz = c2d(Gp*H, Ts, 'zoh');

%% (a) 根轨迹分析与交互选点
OpenLoop = GHz;

% 绘制根轨迹
figure;
rlocus(OpenLoop);
title('Z 平面内系统根轨迹');
grid on;

% 用户交互选取临界极点
disp('请在根轨迹图中点击你认为系统临界稳定的极点位置...');
[Kcrit, PolesCrit] = rlocfind(OpenLoop);
fprintf('\n你选择的临界极点对应 Kp = %.4f，对应极点为：\n', Kcrit);
disp(PolesCrit);

% 添加阻尼比线 ζ = 0.8 并交互选点
figure;
rlocus(OpenLoop);
hold on;
theta = acos(0.8); % 阻尼比线对应角度
r = linspace(0, 1.5, 100);
x = r .* cos(theta);
y = r .* sin(theta);
plot(x, y, 'r--');         % 上半部
plot(x, -y, 'r--');        % 下半部
title('根轨迹 + 阻尼比线 ζ = 0.8');
grid on;
disp('请点击根轨迹上满足 ζ ≈ 0.8 的极点...');
[Kzeta, PolesZeta] = rlocfind(OpenLoop);
fprintf('ζ ≈ 0.8 时的 Kp = %.4f，对应极点为：\n', Kzeta);
disp(PolesZeta);

%% (b) Kp = 0.5, 2.5, 5, 7 的闭环响应分析
Kp_list = [0.5, 2.5, 5, 7];
figure;
sgtitle('不同 Kp 下的单位阶跃响应');

fprintf('\n%-8s%-12s%-12s%-12s%-12s\n', 'Kp', 'Overshoot(%)', 'RiseTime(s)', 'PeakTime(s)', 'SteadyState');

for i = 1:length(Kp_list)
    Kp = Kp_list(i);
    Gc = Kp;

    CL = (Gc * Gpz) / (1 + Gc * GHz);

    % 生成阶跃响应数据
    [y, k] = step(CL, 5);        % y: 响应, k: 时间向量
    k = k(:); y = y(:);          % 确保是列向量

    % 计算性能指标
    [Mo, kp_, kr, ks, ess] = kstats(k, y, 1);

    % 绘图
    subplot(2,2,i);
    plot(k, y, 'b', 'LineWidth', 1.5);
    grid on;
    title(['Kp = ', num2str(Kp)]);
    xlabel('Time (s)'); ylabel('Output');

    % 显示结果
    fprintf('%-8.2f%-12.2f%-12.2f%-12.2f%-12.2f\n', ...
        Kp, Mo, kr, kp_, 1 - ess/100);  % 将稳态值=1-稳态误差（百分比）
end

%% (c) Kp = 1.032 时的参考输入响应与扰动输入响应

Kp = 1.032;
Gc = Kp;       % 离散控制器

% 参考输入响应（R → Y）
T_r = (Gc * Gpz) / (1 + Gc * GHz);

% 扰动输入响应（D → Y）
T_d = Gpz / (1 + Gc * GHz);

% 绘图
figure;
subplot(2,1,1);
step(T_r, 5);
title('Kp = 1.032：单位阶跃参考输入响应 R → Y');
grid on;

subplot(2,1,2);
step(T_d, 5);
title('Kp = 1.032：单位阶跃扰动输入响应 D → Y');
grid on;

% 输出性能指标
info_r = stepinfo(T_r);
info_d = stepinfo(T_d);

fprintf('\nKp = 1.032 时系统性能指标：\n');
fprintf('参考输入响应：超调 %.2f%%，上升时间 %.2f s，稳态值 %.2f\n', ...
    info_r.Overshoot, info_r.RiseTime, info_r.SettlingMax);
fprintf('扰动输入响应：超调 %.2f%%，上升时间 %.2f s，稳态值 %.2f\n', ...
    info_d.Overshoot, info_d.RiseTime, info_d.SettlingMax);
%% 函数
function [Mo, tp, tr, ts, ess] = kstats(k, y, ref)
% KSTATS 计算离散时间系统的性能指标
% [Mo, tp, tr, ts, ess] = kstats(k, y, ref)
%
% 输入参数：
%   k   - 离散时间向量
%   y   - 对应的阶跃响应
%   ref - 参考输入的稳态值（默认值为 1）
%
% 输出参数：
%   Mo  - 超调量（以百分比表示）
%   tp  - 峰值时间（单位：秒）
%   tr  - 上升时间（10%~90%）
%   ts  - 调节时间（2% 区间）
%   ess - 稳态误差（以百分比表示）

    % 默认参考值为 1
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
        Ts = k(2) - k(1);  % 采样周期

        % 线性插值精确估计 10% 与 90% 时刻
        t10 = k(idx_10) - Ts * (y(idx_10) - 0.1 * ref) / (y(idx_10) - y(idx_10 - 1));
        t90 = k(idx_90) - Ts * (y(idx_90) - 0.9 * ref) / (y(idx_90) - y(idx_90 - 1));

        tr = t90 - t10;  % 上升时间
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

    % 稳态误差（以百分比计）
    ess = abs(100 * (y(end) - ref) / ref);

end
