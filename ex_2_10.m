clc; clear; close all;

% 定义系统的零点和极点
zeros = [-0.3, exp(1j*0.5), exp(-1j*0.5)];  % 包括一个实零点和一对共轭复数零点
poles = [0.9, 0.7, 0.7, -0.5];              % 包括两个重复的极点和一个负极点
gain = 1;                                   % 系统增益

% 构造ZPK（零极点增益）模型，采样时间为1（即离散系统）
sys_zpk = zpk(zeros, poles, gain, 1);

% 将ZPK模型转换为传递函数的分子和分母系数向量
[num, den] = tfdata(sys_zpk, 'v');

% 通过分子多项式求解系统的零点，用于验证
calc_zeros = roots(num);                   

% 显示零点信息
disp('ZPK对象指定的零点:');
disp(zeros');  % 转置成列向量输出

disp('通过分子多项式计算的零点:');
disp(calc_zeros);

% 定义时间序列k，从0到50
k = 0:50;

% 构造两个不同频率的输入信号
u1 = sin(0.5*k);   % 输入信号1：频率较高
u2 = sin(0.2*k);   % 输入信号2：频率较低

% 分别对两个输入信号进行离散系统的响应仿真
y1 = lsim(sys_zpk, u1, k);  % 系统对u1的响应
y2 = lsim(sys_zpk, u2, k);  % 系统对u2的响应

% 绘制系统响应图像
figure;

% 第一个子图：输入u1和其系统响应
subplot(2,1,1);
stem(k, u1, 'b'); hold on;                      % 蓝色离散点表示输入信号
stem(k, y1, 'r', 'LineWidth', 1.5);             % 红色离散点表示输出响应
title('输入u(k)=sin(0.5k)的响应');
legend('输入信号', '输出响应');
xlabel('采样时刻k'); ylabel('幅值');
grid on;

% 第二个子图：输入u2和其系统响应
subplot(2,1,2);
stem(k, u2, 'b'); hold on;                      % 蓝色离散点表示输入信号
stem(k, y2, 'r', 'LineWidth', 1.5);             % 红色离散点表示输出响应
title('输入u(k)=sin(0.2k)的响应');
legend('输入信号', '输出响应');
xlabel('采样时刻k'); ylabel('幅值');
grid on;
