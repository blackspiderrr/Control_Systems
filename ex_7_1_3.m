% G(s)=1/s, T=1s, 阶跃输入信号作用下，无纹波最小拍控制器设计
clc; clear;

% 参数定义
s = tf('s');
T = 1;
z = tf('z', T);

% 被控对象 G(s) = 1/s（纯积分环节）
Gs = 1 / s;
Rz = 1 / (1 - 1 / z);
Gz = c2d(Gs, T, 'zoh');   % Gz = Z变换后得到的离散模型
WBz = 1 / z;              % 无纹波情况

% 无纹波最小拍控制器设计
Dz = WBz / (Gz * (1 - WBz));
Yz = WBz * Rz;

% 提取 Yz 序列
[num_Yz, den_Yz] = tfdata(Yz, 'v');
result_Yz = polynomial_process(num_Yz, den_Yz);

% Uz 序列（控制器输出序列）
Uz = Yz / Gz;
[num_Uz, den_Uz] = tfdata(Uz, 'v');
result_Uz = polynomial_process(num_Uz, den_Uz);

% 离散到连续转换
t_discrete = 0:1:12;
[t_continuous, u_continuous] = zero_order_hold(t_discrete, result_Uz);
y_step = lsim(Gs, u_continuous, t_continuous);

% 选取4个用于标记的点
for i = 1:4
    t_select(i) = t_continuous(51 + 10 * i);
    y_select(i) = y_step(51 + 10 * i);
end

%% 绘图
figure('Position', [100, 100, 800, 500]);
subplot(1,1,1);
hold on;

% 连续响应
plot(t_continuous, y_step, 'b-', 'LineWidth', 2, 'DisplayName', '连续信号');

% 离散输出序列
stem(t_discrete, result_Yz, 'r-s', 'LineWidth', 1.5, 'MarkerFaceColor', 'r', 'DisplayName', '离散序列');

% 标记点
stem(t_select, y_select, 'go', 'LineWidth', 1.5, 'MarkerSize', 8, 'MarkerFaceColor', 'g', 'DisplayName', '选取点');

grid on;
xlabel('时间 (秒)', 'FontSize', 12);
ylabel('信号幅度', 'FontSize', 12);
title('无纹波最小拍控制器响应', 'FontSize', 14);
legend('Location', 'best');
hold off;

%% 函数
function [t_continuous, y_continuous] = zero_order_hold(t_discrete, y_discrete, dt_continuous)
    if nargin < 3
        dt_continuous = (t_discrete(2) - t_discrete(1))/50;
    end
    t_continuous = t_discrete(1):dt_continuous:t_discrete(end);
    y_continuous = zeros(size(t_continuous));
    for i = 1:length(t_continuous)
        idx = find(t_discrete <= t_continuous(i), 1, 'last');
        if ~isempty(idx)
            y_continuous(i) = y_discrete(idx);
        end
    end
end

function result = polynomial_process(num, den)
    if nargin < 2
        error('需要提供分子和分母多项式系数');
    end
    temp = zeros(1, length(den));
    result = zeros(1, 13);
    for i = 1:13
        result(i) = num(1)/den(1);
        for j = 1:length(den)
            temp(j) = den(j)*result(i);
            num(j) = num(j) - temp(j);
        end
        for k = 1:length(den)-1
            num(k) = num(k+1);
        end
        num(length(den)) = 0;
    end
end
