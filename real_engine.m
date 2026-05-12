%% Aerospace Propulsion 2026 
% Group 13
% Zach Al-Farabi - a1851552

% ------
% Set-up
% ------

% Initialisation
scale = [1/1000, 1/0.0001, 1/0.5, 1/0.8, 1/0.5];
lb = [0.7, 7000,  1500, 40e6, 1.0, 5,  1.0];
ub = [0.9, 12000, 1800, 50e6, 5.0, 40, 5.0];
x0_mid = [0.8, 7000, 1800, 45e6, 1.0, 10, 1.5];
opts = optimoptions('fmincon', 'Display', 'off', 'Algorithm', 'sqp');

r_test = real_turbofan_objectives(x0_mid, gamma_c, gamma_t, cp_c, cp_t);
fprintf('[Real] Feasibility check: F_m0=%.4f  TSFC=%.8f\n', -r_test(1), r_test(2));

% Number Pareto points, design variable matrix and objective value matrix
n_pareto = 50;
x_pareto_r = zeros(n_pareto, 7);
f_pareto_r = zeros(n_pareto, 5);

% Create a weight matrix, W, where each row sums to 1
rng(42);
raw = -log(rand(n_pareto, 5));
W = raw ./ sum(raw, 2);

% ------------
% Optimisation
% ------------

for i = 1:n_pareto

    % Select row from weight matrix
    w = W(i,:);

    % Function combining objective values into a number using weights and scale
    obj_fn = @(x) sum(w .* real_turbofan_objectives(x, gamma_c, gamma_t, cp_c, cp_t) .* scale);

    % Minimise function subject to lb < x < ub
    [x_opt, ~, flag] = fmincon(obj_fn, x0_mid, [], [], [], [], lb, ub, [], opts);

    % If solution is successful
    if flag > 0

        % Compute the actual objective values at this minimised value
        f_test = real_turbofan_objectives(x_opt, gamma_c, gamma_t, cp_c, cp_t);

        % If objectives are feasible
        if f_test(1) < 0 && f_test(2) > 0 && f_test(2) < 1

            % Store optimal design variables and objective values
            x_pareto_r(i,:) = x_opt;
            f_pareto_r(i,:) = f_test;
        end
    end
    fprintf('[Real] Solution %d/%d\n', i, n_pareto);
end

% -------------------
% Create Pareto front
% -------------------

% Remove unfilled rows from design variable matrix and objective value matrix
valid_r = any(x_pareto_r, 2);
x_pareto_r = x_pareto_r(valid_r,:);
f_pareto_r = f_pareto_r(valid_r,:);
fprintf('[Real] Valid solutions: %d\n', size(x_pareto_r,1));

% Assume every solution is optimal
is_pareto_r = true(size(f_pareto_r,1),1);

% Compare one solution with every other solution except itself
for i = 1:size(f_pareto_r,1)
    for j = 1:size(f_pareto_r,1)
        if i == j, continue; end

        % If solution j dominates solution i
        if all(f_pareto_r(j,:) <= f_pareto_r(i,:)) && any(f_pareto_r(j,:) < f_pareto_r(i,:))

            % Solution i is no longer optimal, no need to compare further
            is_pareto_r(i) = false; break;
        end
    end
end

% Remove rows which are not of Pareto front
x_front_r = x_pareto_r(is_pareto_r,:);
f_front_r = f_pareto_r(is_pareto_r,:);

% ---------------------
% Optimal configuration
% ---------------------

% Find index of maximum total efficiency
[~, best_r] = max(-f_front_r(:,5));

% Pareto design variables
real_eng.x_front = x_front_r;

% Minimised/maximised performance metrics
real_eng.F       = -f_front_r(:,1);
real_eng.TSFC    =  f_front_r(:,2);
real_eng.eta_T   = -f_front_r(:,3);
real_eng.eta_P   = -f_front_r(:,4);
real_eng.eta_O   = -f_front_r(:,5);

% Select best design
real_eng.x_nom   = x_front_r(best_r,:);

% Optimal configuration
fprintf('\n=== [Real] Optimal Config (max eta_O) ===\n');
disp(table(real_eng.x_nom(1), real_eng.x_nom(2), real_eng.x_nom(3), real_eng.x_nom(4), ...
    real_eng.x_nom(5), real_eng.x_nom(6), real_eng.x_nom(7), ...
    'VariableNames', {'M0','alt_m','Tt4_K','hPR_Jkg','alpha','pi_c','pi_f'}));
disp(table(real_eng.F(best_r), real_eng.TSFC(best_r), real_eng.eta_T(best_r), ...
    real_eng.eta_P(best_r), real_eng.eta_O(best_r), ...
    'VariableNames', {'F_m0','TSFC','eta_T','eta_P','eta_O'}));

% --------------
% Sweep analysis
% --------------

% For each of the design variables
for p = 1:7

    % Design variable linspaces
    sweep = param_ranges{p};
    n_sw = length(sweep);

    % Empty vectors to store the results
    F_sw = nan(n_sw,1); TSFC_sw = nan(n_sw,1);
    etaT_sw = nan(n_sw,1); etaP_sw = nan(n_sw,1); etaO_sw = nan(n_sw,1);

    % For each point in linspace
    for i = 1:n_sw

        % Start at the optimal design and change one parameter
        x_sw = real_eng.x_nom; x_sw(p) = sweep(i);

        % Compute the actual objective values
        r = real_turbofan_objectives(x_sw, gamma_c, gamma_t, cp_c, cp_t);

         % If objectives are feasible
        if all(isfinite(r)) && r(1) < 0 && r(2) > 0 && r(2) < 1

            % Store optimal objective values
            F_sw(i) = -r(1); TSFC_sw(i) = r(2);
            etaT_sw(i) = -r(3); etaP_sw(i) = -r(4); etaO_sw(i) = -r(5);
        end
    end

    % Save sweep results
    real_eng.sweep(p).F = F_sw; real_eng.sweep(p).TSFC = TSFC_sw;
    real_eng.sweep(p).eta_T = etaT_sw; real_eng.sweep(p).eta_P = etaP_sw;
    real_eng.sweep(p).eta_O = etaO_sw;
end

% Loop over pi_c and pi_f
for p = 1:2

    % Design variable linspaces
    sweep = opt_sweeps{p};
    n_sw = length(sweep);

    % Empty vectors to store the results
    F_sw = nan(n_sw,1); TSFC_sw = nan(n_sw,1);
    etaT_sw = nan(n_sw,1); etaP_sw = nan(n_sw,1); etaO_sw = nan(n_sw,1);

    % For each point in linspace
    for i = 1:n_sw

        % Start at the optimal design and change one parameter
        x_sw = real_eng.x_nom; x_sw(opt_idx(p)) = sweep(i);

        % Compute the actual objective values
        r = real_turbofan_objectives(x_sw, gamma_c, gamma_t, cp_c, cp_t);

         % If objectives are feasible
        if all(isfinite(r)) && r(1) < 0 && r(2) > 0 && r(2) < 1

            % Store optimal objective values
            F_sw(i) = -r(1); TSFC_sw(i) = r(2);
            etaT_sw(i) = -r(3); etaP_sw(i) = -r(4); etaO_sw(i) = -r(5);
        end
    end

    % Save sweep results
    real_eng.opt_sweep(p).F = F_sw; real_eng.opt_sweep(p).TSFC = TSFC_sw;
    real_eng.opt_sweep(p).eta_T = etaT_sw; real_eng.opt_sweep(p).eta_P = etaP_sw;
    real_eng.opt_sweep(p).eta_O = etaO_sw;
end

clearvars -except ideal real_eng gamma gamma_c gamma_t cp cp_c cp_t  param_ranges param_labels opt_sweeps opt_labels opt_idx