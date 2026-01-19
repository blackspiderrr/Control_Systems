% 6）达林算法设计控制器

T = 0.1;       % 采样周期
T_0 = 0.2;     % 延迟时间
s = tf('s');
z = tf('z', T);
N = round(T_0 / T);

% 用Pade近似代替时滞
delay_order = 1; % 一阶Pade近似即可
[num_delay, den_delay] = pade(T_0, delay_order);
Delay_approx = tf(num_delay, den_delay);

% 被控对象传递函数，代替exp(-T_0*s)用Pade近似
G_s = Delay_approx * (1 / (s + 1));

% 离散化采用状态空间方法，避免警告
sys_ss = ss(G_s);
sys_d = c2d(sys_ss, T, 'zoh');

% 达林算法控制器设计
alpha = exp(-T / T_0);

D_z = (1 - (1 / z) * exp(-T)) * (1 - alpha) / ...
      (1 - exp(-T)) / ...
      (1 - alpha / z - (1 - alpha) * z^(-N-1));

% 闭环系统
sys_cl = feedback(D_z * sys_d, 1);

% 绘制阶跃响应
figure;
step(sys_cl, 10);
grid on;

% 计算性能指标
info6 = stepinfo(sys_cl);
fprintf('最大超调量 Mp = %.2f%%\n', info6.Overshoot);
fprintf('上升时间 Tr = %.2f s\n', info6.RiseTime);
fprintf('调节时间 Ts = %.2f s\n', info6.SettlingTime);
