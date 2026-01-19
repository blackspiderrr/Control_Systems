clc; clear; close all;

% 设置采样时间
Ts = 1;  
z = tf('z', Ts);

% 定义原始离散系统 G(z)
num1 = [2 -2.2 0.56];   
den1 = [1 -2.2 0.56];  
Gz = tf(num1, den1, Ts);

% 构造通过 impulse 模拟阶跃响应的等效系统：G(z)/1/(1 - z^-1)
num_eq = conv(num1, [1 0]);        % 分子乘 z
den_eq = conv(den1, [1 -1]);       % 分母乘 (1 - z^-1)
Gz_eq = tf(num_eq, den_eq, Ts);

% 设置仿真时间范围
N = 20;
t = 0:Ts:N;

% 分别计算系统的单位冲激响应和阶跃响应
[resp_impulse, t1] = impulse(Gz_eq, t); 
[resp_step, t2] = step(Gz, t);

% 可视化结果
figure('Position', [100 100 800 600])

subplot(2,1,1);
stem(t1, resp_impulse, 'filled', 'LineWidth', 1.5);
title('单位冲激响应（对应等效阶跃系统）');
xlabel('时间 (s)'); ylabel('幅度'); grid on;

subplot(2,1,2);
stem(t2, resp_step, 'filled', 'LineWidth', 1.5);
title('step函数计算的阶跃响应');
xlabel('时间 (s)'); ylabel('幅度'); grid on;

% 输出系统信息与误差指标
disp('=== 系统信息对比 ===');
disp('原始传递函数 G(z):'); disp(Gz);
disp('等效传递函数 G_step_equiv(z):'); disp(Gz_eq);

diff_norm = norm(resp_impulse - resp_step(1:length(resp_impulse)));
disp(['两种方式结果差异（L2范数）: ', num2str(diff_norm)]);
