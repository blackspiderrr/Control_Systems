clc; clear; close all;

%% (a) 高采样频率近似连续信号的频谱分析
Fs1 = 1000;               % 高采样频率
T = 1;                    % 持续1秒
t1 = 0:1/Fs1:T-1/Fs1;     % 时间轴
x1 = sin(2*pi*t1);        % 连续信号近似

N1 = length(x1);
X1 = fft(x1);             % FFT
magX1 = abs(X1)/N1;       % 幅值谱归一化
magX1 = magX1(1:N1/2+1);  
magX1(2:end-1) = 2*magX1(2:end-1);
f1 = Fs1*(0:N1/2)/N1;

figure;
plot(f1, magX1);
title('近似连续信号 sin(2\pi t) 的幅值谱');
xlabel('Frequency (Hz)');
ylabel('Magnitude');
grid on;

%% (b) 周期信号频谱（10Hz采样）
Fs = 10;
t = 0:0.1:0.9;
x = sin(2*pi*t);

N = 10;
X = fft(x, N);
magX = abs(X);

f_base = 0:N-1;
f_extended = 0:29;
magX_extended = repmat(magX, 1, ceil(length(f_extended)/N));
magX_extended = magX_extended(1:length(f_extended));

figure;
stem(f_extended, magX_extended, 'filled');
xlabel('Frequency (Hz)');
ylabel('Magnitude');
title('周期信号 sin(2\pi t) 的离散频谱（10Hz 采样）');
grid on;

%% (c) ZOH系统频响作用下的频谱变化
Fs = 10;
t = 0:0.1:0.9;
x = sin(2*pi*t);

N = 10;
X = fft(x, N);
X_mag = abs(X);
X_phase = angle(X);

f_base = 0:N-1;
f_ext = 0:29;
X_mag_ext = repmat(X_mag, 1, ceil(length(f_ext)/N));
X_mag_ext = X_mag_ext(1:length(f_ext));
X_phase_ext = repmat(X_phase, 1, ceil(length(f_ext)/N));
X_phase_ext = X_phase_ext(1:length(f_ext));

T = 1/Fs;
f = f_ext;

H_zoh = sinc(f * T) .* exp(-1j * pi * f * T);  
H_mag = abs(H_zoh);
H_phase = angle(H_zoh);

Y_mag = X_mag_ext .* H_mag;
Y_phase = X_phase_ext + H_phase;

figure;
subplot(3,1,1);
stem(f, X_mag_ext, 'filled');
title('原始离散信号的幅值谱');
xlabel('Frequency (Hz)'); ylabel('Magnitude'); grid on;

subplot(3,1,2);
plot(f, H_mag, 'r');
title('ZOH 的幅值响应');
xlabel('Frequency (Hz)'); ylabel('|H_{ZOH}(f)|'); grid on;

subplot(3,1,3);
stem(f, Y_mag, 'filled');
title('输出信号的幅值谱（乘积）');
xlabel('Frequency (Hz)'); ylabel('Magnitude'); grid on;

%% (d) ZOH插值与频域重建信号比较
Fs = 10;
T = 1/Fs;
t = 0:T:1;
f = 1;
x = sin(2*pi*f*t);

t_zoh = 0:T/100:1;
x_zoh = interp1(t, x, t_zoh, 'previous');

L = length(t_zoh);
X_fft = fft(x_zoh);
f_axis = (0:L-1)*(Fs*100/L);

X_mag = abs(X_fft/L);
X_mag_half = X_mag(2:floor(L/2));
[~, idx] = maxk(X_mag_half, 5);
idx = idx + 1;
frequencies = f_axis(idx);
phases = angle(X_fft(idx));

x_components = zeros(length(t_zoh), 5);
for i = 1:5
    x_components(:, i) = 2*X_mag(idx(i)) * cos(2*pi*frequencies(i)*t_zoh + phases(i));
end
x_reconstructed = sum(x_components, 2);

figure;
plot(t_zoh, x_zoh, 'k-', 'LineWidth', 1.2); hold on;
plot(t_zoh, x_reconstructed, 'b--', 'LineWidth', 1.2);
stem(t, x, 'ro', 'LineWidth', 1.2);
legend('ZOH输出信号', '频谱前5项重建信号', '采样信号');
title('采样、ZOH输出与频率重建信号对比');
xlabel('时间 (s)');
ylabel('幅度');
grid on;
