Ts = 0.05;  % 采样周期

% 定义 G1(z) 和 G2(z)
G1 = tf(0.06059, [1 -0.9394], Ts);
G2 = tf(0.2212, [1 -0.7788], Ts);

% 构建复合系统 G = [G1*G2; G2]，单输入双输出
G = [G1 * G2; G2];

% 计算单位阶跃响应
[Y, T] = step(G);

% 绘图
plot(T, Y(:,1), 'o-', T, Y(:,2), 'x-');
xlabel('Time (s)');
ylabel('Output');
legend('y_1(k)', 'y_2(k)');
title('单位阶跃响应');
grid on;
