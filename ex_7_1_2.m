clc; clear;

% 参数定义
s = tf('s');
T = 1;
z = tf('z', T);

% 被控对象
Gs = 10 / (s*(s+1));

% 离散系统及参考输入
Gz = c2d(Gs, T, 'zoh');
Rz = 1 / (1 - 1/z);

%% 有纹波最小拍控制器设计

WBz1 = 1 / z;  % 有纹波控制器的闭环传递函数

% 计算 Y(z) 和 U(z)
Yz1 = WBz1 * Rz;
[num_Yz1, den_Yz1] = tfdata(Yz1, 'v');
result_Yz1 = polynomial_process(num_Yz1, den_Yz1);

Uz1 = Yz1 / Gz;
[num1, den1] = tfdata(Uz1, 'v');
result_Uz1 = polynomial_process(num1, den1);

% 离散时间向量
t_discrete = 0:1:12;

% 离散控制信号用零阶保持器转换为连续信号
[t_continuous1, u_continuous1] = zero_order_hold(t_discrete, result_Uz1);

% 系统响应仿真
y_step1 = lsim(Gs, u_continuous1, t_continuous1);

% 选取部分离散点绘制
t_select1 = zeros(1, 4);
y_select1 = zeros(1, 4);
for i = 1:4
    t_select1(i) = t_continuous1(51 + 10*i);
    y_select1(i) = y_step1(51 + 10*i);
end

%% 无纹波最小拍控制器设计

% 计算无纹波控制器的闭环传递函数WBz2
zeros_Gz = zero(Gz);
WBz2 = 1 / (1 - zeros_Gz) * 1 / z * (1 - zeros_Gz * 1 / z);

% 计算 Y(z) 和 U(z)
Yz2 = WBz2 * Rz;
[num_Yz2, den_Yz2] = tfdata(Yz2, 'v');
result_Yz2 = polynomial_process(num_Yz2, den_Yz2);

Uz2 = Yz2 / Gz;
[num2, den2] = tfdata(Uz2, 'v');
result_Uz2 = polynomial_process(num2, den2);

% 离散控制信号用零阶保持器转换为连续信号
[t_continuous2, u_continuous2] = zero_order_hold(t_discrete, result_Uz2);

% 系统响应仿真
y_step2 = lsim(Gs, u_continuous2, t_continuous2);

% 选取部分离散点绘制
t_select2 = zeros(1, 4);
y_select2 = zeros(1, 4);
for i = 1:4
    t_select2(i) = t_continuous2(51 + 10*i);
    y_select2(i) = y_step2(51 + 10*i);
end

%% 绘图
figure('Position', [100, 100, 1000, 500]);

% 子图1：有纹波最小拍控制器响应
subplot(1,2,1);
hold on;
plot(t_continuous1, y_step1, 'b-', 'LineWidth', 2, 'DisplayName', '连续信号');
stem(t_discrete, result_Yz1, 'r-o', 'LineWidth', 1.5, 'MarkerFaceColor', 'r', 'DisplayName', '离散序列');
stem(t_select1, y_select1, 'go', 'LineWidth', 1.5, 'MarkerSize', 8, 'MarkerFaceColor', 'g', 'DisplayName', '选取点');
ylim([0 1.4]);
grid on;
xlabel('时间 (秒)', 'FontSize', 12);
ylabel('信号幅度', 'FontSize', 12);
title('有纹波最小拍控制器响应', 'FontSize', 14);
legend('Location', 'best');
hold off;

% 子图2：无纹波最小拍控制器响应
subplot(1,2,2);
hold on;
plot(t_continuous2, y_step2, 'b-', 'LineWidth', 2, 'DisplayName', '连续信号');
stem(t_discrete, result_Yz2, 'r-s', 'LineWidth', 1.5, 'MarkerFaceColor', 'r', 'DisplayName', '离散序列');
stem(t_select2, y_select2, 'go', 'LineWidth', 1.5, 'MarkerSize', 8, 'MarkerFaceColor', 'g', 'DisplayName', '选取点');
ylim([0 1.4]);
grid on;
xlabel('时间 (秒)', 'FontSize', 12);
ylabel('信号幅度', 'FontSize', 12);
title('无纹波最小拍控制器响应', 'FontSize', 14);
legend('Location', 'best');
hold off;

%% 函数
function [t_continuous, y_continuous] = zero_order_hold(t_discrete, y_discrete, dt_continuous)
    if nargin < 3
        dt_continuous = (t_discrete(2) - t_discrete(1)) / 50;
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
        result(i) = num(1) / den(1);
        for j = 1:length(den)
            temp(j) = den(j) * result(i);
            num(j) = num(j) - temp(j);
        end
        for k = 1:length(den) - 1
            num(k) = num(k + 1);
        end
        num(length(den)) = 0;
    end
end
