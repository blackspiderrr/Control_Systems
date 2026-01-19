clear; clc; close all;
Ts = 0.04;

% 定义控制器传递函数 Gi(z)
Kp = 10;
Ki = 1/20;
num_Gi = Kp * Ki * Ts * [1 0];  % 0.02z/(z-1)
den_Gi = [1 -1];
Gi = tf(num_Gi, den_Gi, Ts, 'Variable', 'z');

% 定义对象传递函数 G(z)
num_G = [0.0031 0.003];  % 0.0031z + 0.003
den_G = [1 -1.9 0.905];
G = tf(num_G, den_G, Ts, 'Variable', 'z');

% 定义传感器传递函数 H(z)
num_H = 0.55;
den_H = [1 -0.45];
H = tf(num_H, den_H, Ts, 'Variable', 'z');

% 闭环传递函数：参考输入 R(z) 到输出 Y(z)
YR = feedback(Gi * G, H);

% 闭环传递函数：扰动输入 D(z) 到输出 Y(z)
YD = feedback(G, Gi * H);

% 显示零极点
disp('YR 的零点：'); disp(zero(YR));
disp('YR 的极点：'); disp(pole(YR));
disp('YD 的零点：'); disp(zero(YD));
disp('YD 的极点：'); disp(pole(YD));

% 绘制单位阶跃响应
figure;
step(YR, 'b', YD, 'r');
legend('参考输入 R(z) 的响应', '扰动输入 D(z) 的响应');
title('参考输入和扰动输入的单位阶跃响应');
grid on;