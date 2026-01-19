% 定义传递函数（TF）对象
num = [0.1, 0.03, -0.07];
den = [1, -2.7, 2.42, -0.72];
G = tf(num, den, -1);  % 采样时间 -1 表示未指定的离散系统

% 转换为 ZPK（零极点增益）对象
Gzpk = zpk(G);

% 提取零点、极点、增益和采样时间
z = Gzpk.Z{:};
p = Gzpk.P{:};
k = Gzpk.K;
Ts = Gzpk.Ts;

% 显示结果
disp('零点:'); disp(z);
disp('极点:'); disp(p);
disp('增益:'); disp(k);
disp('采样时间 Ts:'); disp(Ts);

% 转换为状态空间模型
Gss = ss(G);

% 显示状态空间矩阵
disp('A ='); disp(Gss.A);
disp('B ='); disp(Gss.B);
disp('C ='); disp(Gss.C);
disp('D ='); disp(Gss.D);

% 特征根（Eigenvalues）
eig_A = eig(Gss.A);
disp('特征根（极点）='); disp(eig_A);

% 特征多项式（Characteristic polynomial）
char_poly = poly(Gss.A);  % 返回多项式系数
disp('特征多项式系数 ='); disp(char_poly);
