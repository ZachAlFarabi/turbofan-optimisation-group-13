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
x0_mid = (lb + ub) / 2;
opts = optimoptions('fmincon', 'Display', 'off', 'Algorithm', 'sqp');

% Number Pareto points, design variable matrix and objective value matrix
n_pareto = 50;
x_pareto_i = zeros(n_pareto, 7);
f_pareto_i = zeros(n_pareto, 5);

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
    obj_fn = @(x) sum(w .* turbofan_objectives(x, gamma, cp) .* scale);

    % Minimise function subject to lb < x < ub
    [x_opt, ~, flag] = fmincon(obj_fn, x0_mid, [], [], [], [], lb, ub, [], opts);

    % If solution is successful
    if flag > 0

        % Compute the actual objective values at this minimised value
        f_test = turbofan_objectives(x_opt, gamma, cp);

        % If objectives are feasible
        if f_test(1) < 0 && f_test(2) > 0 && f_test(2) < 1

            % Store optimal design variables and objective values
            x_pareto_i(i,:) = x_opt;
            f_pareto_i(i,:) = f_test;
        end
    end
    fprintf('[Ideal] Solution %d/%d\n', i, n_pareto);
end

% -------------------
% Create Pareto front
% -------------------

% Remove unfilled rows from design variable matrix and objective value matrix
valid_i = any(x_pareto_i, 2);
x_pareto_i = x_pareto_i(valid_i,:);
f_pareto_i = f_pareto_i(valid_i,:);

% Assume every solution is optimal
is_pareto_i = true(size(f_pareto_i,1),1);

% Compare one solution with every other solution except itself
for i = 1:size(f_pareto_i,1)
    for j = 1:size(f_pareto_i,1)
        if i == j, continue; end

        % If solution j dominates solution i
        if all(f_pareto_i(j,:) <= f_pareto_i(i,:)) && any(f_pareto_i(j,:) < f_pareto_i(i,:))

            % Solution i is no longer optimal, no need to compare further
            is_pareto_i(i) = false; break;
        end
    end
end

% Remove rows which are not of Pareto front
x_front_i = x_pareto_i(is_pareto_i,:);
f_front_i = f_pareto_i(is_pareto_i,:);

% ---------------------
% Optimal configuration
% ---------------------

% Find index of maximum total efficiency
[~, best_i] = max(-f_front_i(:,5));

% Pareto design variables
ideal.x_front = x_front_i;

% Minimised/maximised performance metrics
ideal.F       = -f_front_i(:,1);
ideal.TSFC    =  f_front_i(:,2);
ideal.eta_T   = -f_front_i(:,3);
ideal.eta_P   = -f_front_i(:,4);
ideal.eta_O   = -f_front_i(:,5);

% Select best design
ideal.x_nom   = x_front_i(best_i,:);

% Optimal configuration
fprintf('\n=== [Ideal] Optimal Config (max eta_O) ===\n');
disp(table(ideal.x_nom(1), ideal.x_nom(2), ideal.x_nom(3), ideal.x_nom(4), ...
    ideal.x_nom(5), ideal.x_nom(6), ideal.x_nom(7), ...
    'VariableNames', {'M0','alt_m','Tt4_K','hPR_Jkg','alpha','pi_c','pi_f'}));
disp(table(ideal.F(best_i), ideal.TSFC(best_i), ideal.eta_T(best_i), ...
    ideal.eta_P(best_i), ideal.eta_O(best_i), ...
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
        x_sw = ideal.x_nom; x_sw(p) = sweep(i);

        % Compute the actual objective values
        r = turbofan_objectives(x_sw, gamma, cp);

        % If objectives are feasible
        if all(isfinite(r)) && r(1) < 0 && r(2) > 0 && r(2) < 1
            
            % Store optimal objective values
            F_sw(i) = -r(1); TSFC_sw(i) = r(2);
            etaT_sw(i) = -r(3); etaP_sw(i) = -r(4); etaO_sw(i) = -r(5);
        end
    end

    % Save sweep results
    ideal.sweep(p).F = F_sw; ideal.sweep(p).TSFC = TSFC_sw;
    ideal.sweep(p).eta_T = etaT_sw; ideal.sweep(p).eta_P = etaP_sw;
    ideal.sweep(p).eta_O = etaO_sw;
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
        x_sw = ideal.x_nom; x_sw(opt_idx(p)) = sweep(i);

        % Compute the actual objective values
        r = turbofan_objectives(x_sw, gamma, cp);

        % If objectives are feasible
        if all(isfinite(r)) && r(1) < 0 && r(2) > 0 && r(2) < 1

            % Store optimal objective values
            F_sw(i) = -r(1); TSFC_sw(i) = r(2);
            etaT_sw(i) = -r(3); etaP_sw(i) = -r(4); etaO_sw(i) = -r(5);
        end
    end

    % Save sweep results
    ideal.opt_sweep(p).F = F_sw; ideal.opt_sweep(p).TSFC = TSFC_sw;
    ideal.opt_sweep(p).eta_T = etaT_sw; ideal.opt_sweep(p).eta_P = etaP_sw;
    ideal.opt_sweep(p).eta_O = etaO_sw;
end

clearvars -except ideal real_eng gamma gamma_c gamma_t cp cp_c cp_t  param_ranges param_labels opt_sweeps opt_labels opt_idx
