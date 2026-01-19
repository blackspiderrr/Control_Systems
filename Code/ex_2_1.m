% 建立传递函数
clear
num = [0.1, 0.03, -0.07];
den = [1, -2.7, 2.42, -0.72];

G = tf(num, den, -1) % '-1' 表示未指定采样周期的离散系统

% 显示对象的属性
get(G)

% 提取分子和分母
[num_poly, den_poly] = tfdata(G, 'v')

% 提取零点、极点、增益
[z, p, k] = tf2zp(num, den)

% 绘制 z 平面上的零极点图
pzmap(G)
grid on
