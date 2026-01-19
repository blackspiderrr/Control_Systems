clear; clc; close all;
Ts = 1; 
theta = pi/4; % π/4相位角
pole_G = 0.9*[exp(1j*theta); exp(-1j*theta)]; % 复数极点
num_G = 0.2*[1 -0.85]; % 分子多项式
den_G = poly(pole_G);  % 分母多项式
G = tf(num_G, den_G, Ts, 'Variable', 'z');
pole_H = [0.8; 0.1];
num_H = [1 -0.3];
den_H = poly(pole_H);
H = tf(num_H, den_H, Ts, 'Variable', 'z');
T = feedback(G, H);
disp('==== 闭环传递函数T(z) ====');
disp('多项式形式:'); 
disp(['分子: ', poly2str(T.num{1}, 'z')]);
disp(['分母: ', poly2str(T.den{1}, 'z')]);
disp('==== 系统特性 ====');
disp(['系统增益: ', num2str(dcgain(T))]);
disp('G(z)零点:'); disp(zero(G));
disp('T(z)零点:'); disp(zero(T));
disp('G(z)极点:'); disp(pole(G));
disp('H(z)极点:'); disp(pole(H));
disp('T(z)极点:'); disp(pole(T));
figure;
subplot(2,2,1);
pzmap(G);
title('G(z)零极点图');
subplot(2,2,2);
pzmap(H);
title('H(z)零极点图');
subplot(2,2,[3,4]);
pzmap(T);
title('T(z)零极点图');

figure;
%子图1：0-20s
subplot(2,1,1);
step(T, 0:1:20);
title('闭环系统阶跃响应（局部：0 到 20s）');
xlabel('时间步 k');
ylabel('输出');
grid on;
%子图2：0-250s
subplot(2,1,2);
step(T, 0:1:250);
title('闭环系统阶跃响应（全局：0 到 250s）');
xlabel('时间步 k');
ylabel('输出');
grid on;
