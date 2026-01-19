% 时间向量
k = 0:20;

% 零点
z_zero = -0.5;

% 极点定义
p1 = exp(1j*pi/3);        % |z| = 1
p2 = 1.1 * exp(1j*pi/3);  % 模长 > 1
p3 = 0.9 * exp(1j*pi/3);  % 模长 < 1

% 构造三个系统（单位增益 G=1）
sys1 = zpk(z_zero, [p1, conj(p1)], 1, 1);       % 原始系统
sys2 = zpk(z_zero, [p2, conj(p2)], 1, 1);       % 放大系统
sys3 = zpk(z_zero, [p3, conj(p3)], 1, 1);       % 衰减系统

% 脉冲响应
[y1, k1] = impulse(sys1, k);
[y2, ~] = impulse(sys2, k);
[y3, ~] = impulse(sys3, k);

% 绘图
figure;
plot(k1, y1, 'b-o', 'DisplayName','|z| = 1');
hold on;
plot(k1, y2, 'r--s', 'DisplayName','|z| = 1.1');
plot(k1, y3, 'g-d', 'DisplayName','|z| = 0.9');
xlabel('时间 k');
ylabel('g(k)');
title('不同极点模长的脉冲响应比较');
legend;
grid on;
