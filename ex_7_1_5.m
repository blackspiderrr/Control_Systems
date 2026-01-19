% 参数定义
s = tf('s');
T = 1;
z = tf('z', T);

% 被控对象 G(s) = 1/s（纯积分环节）
Gs = 1 / s;
Gz = c2d(Gs, T, 'zoh');   % ZOH 离散模型
t_discrete = 0:1:12;

%% 控制器 D(z)（满足超调<30%，斜坡12拍稳态）
alpha = 0.55;
beta  = 0.84;
Dz = (1 - alpha*z^(-1)) / (1 - beta*z^(-1));

% 闭环传递函数 W(z)
Wz = (Dz * Gz) / (1 + Dz * Gz);

%% --- 阶跃响应分析 ---
Rz_step = 1 / (1 - z^-1);      % Z域阶跃输入
Yz_step = Wz * Rz_step;        % 输出 Y(z)
[num_Ys, den_Ys] = tfdata(Yz_step, 'v');
result_Ys = polynomial_process(num_Ys, den_Ys);   % 得到 y[k]

Uz_step = Yz_step / Gz;
[num_Us, den_Us] = tfdata(Uz_step, 'v');
result_Us = polynomial_process(num_Us, den_Us);   % 得到 u[k]

[t_continuous_s, u_continuous_s] = zero_order_hold(t_discrete, result_Us);
y_step = lsim(Gs, u_continuous_s, t_continuous_s);

% --- 计算超调量 ---
steady_value = mean(y_step(end-5:end)); % 稳态值取末尾均值
peak_value = max(y_step);
overshoot = (peak_value - steady_value) / steady_value * 100;
fprintf('阶跃响应超调量: %.2f%%\n', overshoot);

%% --- 斜坡响应分析 ---
Rz_ramp = z / (z - 1)^2;       % Z域斜坡输入
Yz_ramp = Wz * Rz_ramp;
[num_Yr, den_Yr] = tfdata(Yz_ramp, 'v');
result_Yr = polynomial_process(num_Yr, den_Yr);   % y[k]

Uz_ramp = Yz_ramp / Gz;
[num_Ur, den_Ur] = tfdata(Uz_ramp, 'v');
result_Ur = polynomial_process(num_Ur, den_Ur);

[t_continuous_r, u_continuous_r] = zero_order_hold(t_discrete, result_Ur);
y_ramp = lsim(Gs, u_continuous_r, t_continuous_r);

% --- 自动判断斜坡稳态是否在12拍内达到 ±5% ---
ramp_ref = 0:12;                  % 理想参考：r[k] = k
y12 = result_Yr(1:13);            % y[0] 到 y[12]
err = abs(y12 - ramp_ref);
tolerance = 0.05 * ramp_ref;
tolerance(ramp_ref == 0) = 0.05;  % 避免 t=0 除0错误
within_bounds = err <= tolerance;

satisfied = all(within_bounds(9:end));  % 例如从第9拍到第12拍都满足
if satisfied
    disp('斜坡响应在第12拍前达到±5%稳态。');
else
    disp('斜坡响应未在第12拍达到稳态。');
end

%% --- 标注点 ---
for i = 1:4
    t_select(i) = t_continuous_s(51 + 10 * i);
    y_select(i) = y_step(51 + 10 * i);
end

%% --- 绘图 ---
figure('Position', [100, 100, 1000, 450]);

% 阶跃响应图
subplot(1,2,1);
plot(t_continuous_s, y_step, 'b-', 'LineWidth', 2, 'DisplayName', '连续信号'); hold on;
stem(t_discrete, result_Ys, 'r-s', 'LineWidth', 1.5, 'MarkerFaceColor', 'r', 'DisplayName', '离散序列');
stem(t_select, y_select, 'go', 'LineWidth', 1.5, 'MarkerSize', 8, 'MarkerFaceColor', 'g', 'DisplayName', '选取点');
ylim([0 1.4]);
xlabel('时间 (秒)', 'FontSize', 12);
ylabel('信号幅度', 'FontSize', 12);
title('阶跃响应（折衷控制器）', 'FontSize', 14);
legend('Location', 'best'); grid on; hold off;

% 斜坡响应图
subplot(1,2,2);
plot(t_continuous_r, y_ramp, 'b-', 'LineWidth', 2, 'DisplayName', '连续信号'); hold on;
stem(t_discrete, result_Yr, 'r-s', 'LineWidth', 1.5, 'MarkerFaceColor', 'r', 'DisplayName', '离散序列');
yline(12 * 1.05, 'k--', '5%上界'); yline(12 * 0.95, 'k--', '5%下界');
ylim([0 15]);
xlabel('时间 (秒)', 'FontSize', 12);
ylabel('信号幅度', 'FontSize', 12);
title('斜坡响应（折衷控制器）', 'FontSize', 14);
legend('Location', 'best'); grid on; hold off;

%% --- 支持函数 ---
function [t_continuous, y_continuous] = zero_order_hold(t_discrete, y_discrete, dt_continuous)
    if nargin < 3
        dt_continuous = (t_discrete(2) - t_discrete(1)) / 50;
    end
    t_continuous = t_discrete(1):dt_continuous:t_discrete(end);
    y_continuous = zeros(size(t_continuous));
    for i = 1:length(t_continuous)
        idx = find(t_discrete <= t_continuous(i), 1, 'last');
        if ~isempty(idx)
            y_continuous(i) = y_discrete(idx);
        end
    end
end

function result = polynomial_process(num, den)
    if nargin < 2
        error('需要提供分子和分母多项式系数');
    end
    temp = zeros(1, length(den));
    result = zeros(1, 13);
    for i = 1:13
        result(i) = num(1)/den(1);
        for j = 1:length(den)
            temp(j) = den(j)*result(i);
            num(j) = num(j) - temp(j);
        end
        for k = 1:length(den)-1
            num(k) = num(k+1);
        end
        num(length(den)) = 0;
    end
end
