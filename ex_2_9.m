clc; clear; close all;

% 定义系统传递函数 G(z)
num = [3 1.8 1.08];  % 分子系数
den = [1 -1.252 0.495 -0.0035 -0.1862];  % 分母系数
Ts = 1;  % 采样周期
G = tf(num, den, Ts);  % 离散时间传递函数

% 1. 求系统的极点和零点
poles = roots(den);
zeros_ = roots(num);

% 也可以通过 pole / zero 命令
disp('极点（poles）:');
disp(poles);
disp('零点（zeros）:');
disp(zeros_);

% 2. 判断系统稳定性（所有极点是否在单位圆内）
is_stable = all(abs(poles) < 1);
if is_stable
    disp('系统稳定：所有极点都在单位圆内。');
else
    disp('系统不稳定：存在极点在单位圆外或在圆上。');
end

% 3. 绘制 Z 平面极点零点图
figure;
zplane(zeros_, poles);
title('G(z) 的极点与零点图');
grid on;

% 4. 冲激响应
figure;
impulse(G);
title('系统单位冲激响应');

% 可视化判断系统响应是否收敛
