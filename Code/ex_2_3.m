% 分子和分母系数
num = [2, -2.2, 0.56];
den = [1, -0.6728, 0.0463, 0.4860];

% G(z)/z
num_div_z = [0, 2, -2.2, 0.56]; 

% residuez 展开
[r, p, k] = residuez(num_div_z, den);

% 显示展开结果
disp('残差（A_i）:'); disp(r);
disp('极点（p_i）:'); disp(p);
disp('直接项（k）:'); disp(k);

% 构建传递函数对象，单位采样周期
G = tf(num, den, 1);

% 绘制单位脉冲响应
[y, k] = impulse(G); 
stem(k, y, 'filled');
title('单位脉冲响应 g(k)');
xlabel('k'); ylabel('g(k)');
grid on;