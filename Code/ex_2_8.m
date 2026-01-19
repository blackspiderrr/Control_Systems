Ts = 0.2;  % 采样周期
t = 0:Ts:40;  % 时间向量，时间间隔 0<=k<=40

% 设定输入信号 u(k)
u = zeros(size(t));  % 初始为全零
u(t >= 0 & t < 10) = 2;    % 0 <= k < 10 时，u(k) = 2
u(t >= 10) = 0.5;          % k >= 10 时，u(k) = 0.5

% 定义系统传递函数 G(z)，假设与例子中式(2.5)一致
% 这里假设系统的传递函数形式为：
num = [2 -2.2 0.56];
den = [1 -0.6728 0.0463 0.4860];
G = tf(num, den, Ts);  % 定义传递函数 G(z)

% 使用 lsim 计算零状态响应
[y, t_out] = lsim(G, u, t);

% 绘制响应
figure;
plot(t_out, y, 'b-o', 'DisplayName', 'System Response');
hold on;
plot(t, u, 'r--s', 'DisplayName', 'Input u(k)');
xlabel('时间 k');
ylabel('响应 / 输入');
title('零状态响应与输入信号对比');
legend;
grid on;
