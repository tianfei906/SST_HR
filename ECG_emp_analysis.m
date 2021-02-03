function [N_hat, std_hat, EMD_all] = ECG_emp_analysis(X_A, We, BPM_comp)
%% empirical analysis
% e.g. 60 bpm <= ke <= 85 bpm

addpath('./SST_compare-master/comparison');
addpath('./SST_compare-master/FastEMD');


[~, L_hsz] = size(X_A);
[~, K_e] = size(We);

fprintf("EMD all\n");
EMD_all = zeros(K_e, L_hsz);
for ke=1:K_e
    fprintf("%u/%u ", ke, K_e);
    EMD_all(ke, :) = EMDMatGen(X_A, We(:, ke));
end
fprintf("\n");

% save("EMD_all_ECG_test2thoracic.mat", 'EMD_all');
% load("EMD_all_ECG_test2thoracic.mat");

[~, ke_vec] = min(EMD_all, [], 1);
% histogram de ke_vec
N_vec = zeros(1, K_e);

for ke=ke_vec
    N_vec(ke) = N_vec(ke) + 1;
end
N_vec = N_vec/sum(N_vec);

[~, ke_peak] = max(N_vec);
[~, I_zero] = find(N_vec == 0);
D_peak = I_zero - ke_peak;
ke_H = min(nonzeros(I_zero.*(D_peak > 0)));
ke_L = max(nonzeros(I_zero.*(D_peak < 0)));

figure;
hold on;
plot(1:K_e, N_vec);
plot(ke_L, N_vec(ke_L), 'o');
plot(ke_peak, N_vec(ke_peak), 'x');
plot(ke_H, N_vec(ke_H), 'o');
hold on;

A1 = 0;
for n=1:L_hsz
    c_ke = ke_vec(n);
    A1 = A1 + (ke_L <= c_ke && c_ke <= ke_H); % fix : unit of c_ke
end

p_hat = A1/L_hsz; % Bernoulli estimation

fprintf("compute binomal\n");
N_max = 200;
Y_vec = zeros(1, N_max);
for Ni = 1:N_max
    mid = floor(Ni/2);
    Y_vec(Ni) = binocdf(mid, Ni, p_hat);
end

N_hat = find(Y_vec >= 0.0001, 1, 'last');

[~, ke2_vec] = min(EMD_all(ke_L:ke_H, :), [], 1);
std_hat = std(BPM_comp(ke2_vec));
end
