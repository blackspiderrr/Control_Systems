clear; clc;

%% 连续时间信号
t_cont = 0:0.0001:1;
e1 = sin(2*pi*t_cont);
e2 = sin(18*pi*t_cont + pi);
e3 = sin(22*pi*t_cont);

%% 设置采样频率
Fs_list = [10, 20, 30];
colors = {'r', 'g', 'b'};

%% 创建图像窗口
figure('Position', [100, 100, 1200, 900]);

%% 连续信号（前三行）
subplot(6,3,1); plot(t_cont, e1, 'k'); title('e1 连续');
ylabel('e1'); grid on;
subplot(6,3,2); plot(t_cont, e2, 'k'); title('e2 连续');
ylabel('e2'); grid on;
subplot(6,3,3); plot(t_cont, e3, 'k'); title('e3 连续');
ylabel('e3'); grid on;

%% 每种采样频率下的采样信号（第4~6行）
for i = 1:length(Fs_list)
    Fs = Fs_list(i); Ts = 1/Fs;
    t_sample = 0:Ts:1;
    e1_s = sin(2*pi*t_sample);
    e2_s = sin(18*pi*t_sample + pi);
    e3_s = sin(22*pi*t_sample);
    
    row = i + 1;
    subplot(4,3,row*3 - 2);
    stem(t_sample, e1_s, colors{i}, 'filled');
    title(['e1 采样Fs=', num2str(Fs), 'Hz']); grid on;

    subplot(4,3,row*3 - 1);
    stem(t_sample, e2_s, colors{i}, 'filled');
    title(['e2 采样Fs=', num2str(Fs), 'Hz']); grid on;

    subplot(4,3,row*3);
    stem(t_sample, e3_s, colors{i}, 'filled');
    title(['e3 采样Fs=', num2str(Fs), 'Hz']); grid on;
end

sgtitle('连续信号与不同采样频率下的采样信号');

%% 新图绘制频谱（频域分析）
figure('Position', [100, 100, 1200, 900]);

for i = 1:length(Fs_list)
    Fs = Fs_list(i);
    t_sample = 0:1/Fs:1;
    
    plot_fft(sin(2*pi*t_sample), Fs, (i-1)*3 + 1, 'e1 频谱');
    plot_fft(sin(18*pi*t_sample + pi), Fs, (i-1)*3 + 2, 'e2 频谱');
    plot_fft(sin(22*pi*t_sample), Fs, (i-1)*3 + 3, 'e3 频谱');
end
sgtitle('不同采样频率下的频谱分析');

% 嵌套函数用于 FFT 绘图
function plot_fft(sig, Fs, subplot_idx, label)
    N = 1024;
    Y = abs(fft(sig, N));
    f = linspace(0, Fs, N);
    subplot(3,3,subplot_idx);
    plot(f, Y, 'b');
    title([label, ', Fs=', num2str(Fs), 'Hz']);
    xlim([0, Fs/2]);
    xlabel('Hz'); ylabel('|Y(f)|'); grid on;
end
