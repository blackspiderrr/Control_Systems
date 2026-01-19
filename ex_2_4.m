clc; clear;

% 原系统 G(z)
num = [2, -2.2, 0.56];
den = [1, -0.6728, 0.0463, 0.4860];

% 构造 G(z)/z
num_div_z = [0, 2, -2.2, 0.56];     % 在前面加0相当于除以z
den_div_z = conv([1, 0], den);      % 分母加一个z=0的极点

% 使用 residue 分解
[r, p, ~] = residue(num_div_z, den_div_z);

% 输出极点和留数
disp('极点和对应留数：');
for i = 1:length(p)
    fprintf('p(%d) = %.4f%+.4fj,\t r(%d) = %.4f%+.4fj\n', ...
        i, real(p(i)), imag(p(i)), i, real(r(i)), imag(r(i)));
end

% 时间向量
k_time = 0:30;

% 初始化
g_real_all = zeros(size(k_time));
g_complex = zeros(size(k_time));

for i = 1:length(p)
    if imag(p(i)) == 0
        % 实极点响应（z=0 或 -0.6）
        g_real_all = g_real_all + real(r(i) * (p(i).^k_time));
    elseif imag(p(i)) > 0
        % 复极点对（只算正虚部一个，乘2取实部）
        g_complex = g_complex + cpole2k(p(i), r(i), k_time);
    end
end

% 总响应
g_total = g_real_all + g_complex;

% impulse 响应（G(z)）
G = tf(num, den, 1); 
[y, k_imp] = impulse(G, length(k_time)-1);

% ------------------------ 画图 ------------------------
figure;

subplot(3,1,1);
stem(k_time, g_real_all, 'filled');
title('实极点（z = 0 和 z = -0.6）的脉冲响应');
ylabel('g_{real}(k)');
grid on;

subplot(3,1,2);
stem(k_time, g_complex, 'filled');
title('复极点对的脉冲响应');
ylabel('g_{complex}(k)');
grid on;

subplot(3,1,3);
stem(k_time, g_total, 'filled', 'DisplayName', 'g_{total}(k)'); hold on;
stem(k_imp, y, 'r--', 'DisplayName', 'impulse(G)');
title('总响应 vs impulse(G)');
xlabel('k');
ylabel('响应');
legend;
grid on;

%% 函数
function  y = cpole2k(cp,res,dtime)
%        Performs inverse z transform for two complex 
%        conjugate poles and generates a discrete-time 
%        function. 
temp = zeros(size(dtime));
temp(1) = res;
for kk = 2:length(dtime)
   temp(kk) = temp(kk-1)*cp;
end
y = 2 * real(temp);
end
