clc; clear; close all;

Ts = 1; % 采样周期

% 构建子系统 H1(z)
num_G1 = 0.02 * [2 1.4];
den_G1 = [1 -1.7 0.72];
G1 = tf(num_G1, den_G1, Ts, 'Variable', 'z');

% 构建子系统 H2(z)，包含复共轭极点
angle_rad = pi / 5;
p_G2 = [-0.8; 0.9 * exp(1j * angle_rad); 0.9 * exp(-1j * angle_rad)];
num_G2 = [1 0.2];
den_G2 = poly(p_G2);
G2 = tf(num_G2, den_G2, Ts, 'Variable', 'z');

% 构建子系统 H3(z)，简单一阶系统
G3 = tf([1 0.5], [1 0.75], Ts, 'Variable', 'z');

% 构建子系统 H4(z)，含 z 项，三阶多项式极点
p_G4 = [0.9; 0.8; -0.8];
G4 = tf(0.15 * [1 0], poly(p_G4), Ts, 'Variable', 'z');

% 系统连接：串联 + 并联结构
sys_series = series(G1, G2); % H1 串联 H2
sys_parallel = parallel(sys_series, G3); % 与 H3 并联
Sys_all = series(sys_parallel, G4); % 并联后再串联 H4

% 输出极点信息
disp('==== 各子系统极点 ====');
disp('G1 的极点:'); disp(pole(G1));
disp('G2 的极点:'); disp(pole(G2));
disp('G3 的极点:'); disp(pole(G3));
disp('G4 的极点:'); disp(pole(G4));
disp('整体系统极点:'); disp(pole(Sys_all));

% 输出零点信息
disp('==== 各子系统零点 ====');
disp('G1 的零点:'); disp(zero(G1));
disp('G2 的零点:'); disp(zero(G2));
disp('G3 的零点:'); disp(zero(G3));
disp('G4 的零点:'); disp(zero(G4));
disp('整体系统零点:'); disp(zero(Sys_all));

% 绘制阶跃响应图
figure;
step(Sys_all, 50);
title('整体系统阶跃响应');
xlabel('时间步 k');
ylabel('系统输出');
grid on;

% 绘制零极点图
figure;
pzmap(Sys_all);
title('整体系统的零极点图');
grid on;