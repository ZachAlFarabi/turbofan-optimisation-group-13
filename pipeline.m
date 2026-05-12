%% Aerospace Propulsion 2026 
% Group 13
% Zach Al-Farabi - a1851552

clear; clc;

% Constants
gamma = 1.4;   
cp = 1005;
gamma_c = 1.4;   
cp_c = 1004;
gamma_t = 1.33;  
cp_t = 1156;


% Shared sweep definitions
param_labels = {'$M_0$','$h$ [m]','$T_{t4}$ [K]','$h_{PR}$ [J/kg]', ...
                '$\alpha$','$\pi_c$','$\pi_f$'};
param_ranges = {linspace(0.7,0.9,50), linspace(7000,12000,50), ...
                linspace(1500,1800,50), linspace(40e6,50e6,50), ...
                linspace(1,5,50), linspace(5,40,50), ...
                linspace(1,5,50)};
opt_sweeps = {linspace(5,40,50), linspace(1,5,50)};
opt_labels = {'$\pi_c$','$\pi_f$'};
opt_idx = [6, 7];

% Run engines
ideal_engine;
real_engine;

% Shared nominal - use ideal optimal as baseline for fair comparison
x_shared = ideal.x_nom;

for p = 1:7
    sweep = param_ranges{p};
    n_sw = length(sweep);

    Fi = nan(n_sw,1); TSFCi = nan(n_sw,1); etaTi = nan(n_sw,1); etaPi = nan(n_sw,1); etaOi = nan(n_sw,1);
    Fr = nan(n_sw,1); TSFCr = nan(n_sw,1); etaTr = nan(n_sw,1); etaPr = nan(n_sw,1); etaOr = nan(n_sw,1);

    for i = 1:n_sw
        x_sw = x_shared; x_sw(p) = sweep(i);

        ri = turbofan_objectives(x_sw, gamma, cp);
        if all(isfinite(ri)) && ri(1) < 0 && ri(2) > 0 && ri(2) < 1
            Fi(i) = -ri(1); TSFCi(i) = ri(2);
            etaTi(i) = -ri(3); etaPi(i) = -ri(4); etaOi(i) = -ri(5);
        end

        rr = real_turbofan_objectives(x_sw, gamma_c, gamma_t, cp_c, cp_t);
        if all(isfinite(rr)) && rr(1) < 0 && rr(2) > 0 && rr(2) < 1
            Fr(i) = -rr(1); TSFCr(i) = rr(2);
            etaTr(i) = -rr(3); etaPr(i) = -rr(4); etaOr(i) = -rr(5);
        end
    end

    % Store back into structs for plotting
    ideal.sweep(p).F = Fi;    ideal.sweep(p).TSFC = TSFCi;
    ideal.sweep(p).eta_T = etaTi; ideal.sweep(p).eta_P = etaPi; ideal.sweep(p).eta_O = etaOi;
    real_eng.sweep(p).F = Fr; real_eng.sweep(p).TSFC = TSFCr;
    real_eng.sweep(p).eta_T = etaTr; real_eng.sweep(p).eta_P = etaPr; real_eng.sweep(p).eta_O = etaOr;
end

% Optimal pi_c and pi_f sweeps at shared nominal
for p = 1:2
    sweep = opt_sweeps{p};
    n_sw = length(sweep);

    Fi = nan(n_sw,1); TSFCi = nan(n_sw,1); etaTi = nan(n_sw,1); etaPi = nan(n_sw,1); etaOi = nan(n_sw,1);
    Fr = nan(n_sw,1); TSFCr = nan(n_sw,1); etaTr = nan(n_sw,1); etaPr = nan(n_sw,1); etaOr = nan(n_sw,1);

    for i = 1:n_sw
        x_sw = x_shared; x_sw(opt_idx(p)) = sweep(i);

        ri = turbofan_objectives(x_sw, gamma, cp);
        if all(isfinite(ri)) && ri(1) < 0 && ri(2) > 0 && ri(2) < 1
            Fi(i) = -ri(1); TSFCi(i) = ri(2);
            etaTi(i) = -ri(3); etaPi(i) = -ri(4); etaOi(i) = -ri(5);
        end

        rr = real_turbofan_objectives(x_sw, gamma_c, gamma_t, cp_c, cp_t);
        if all(isfinite(rr)) && rr(1) < 0 && rr(2) > 0 && rr(2) < 1
            Fr(i) = -rr(1); TSFCr(i) = rr(2);
            etaTr(i) = -rr(3); etaPr(i) = -rr(4); etaOr(i) = -rr(5);
        end
    end

    ideal.opt_sweep(p).F = Fi;    ideal.opt_sweep(p).TSFC = TSFCi;
    ideal.opt_sweep(p).eta_T = etaTi; ideal.opt_sweep(p).eta_P = etaPi; ideal.opt_sweep(p).eta_O = etaOi;
    real_eng.opt_sweep(p).F = Fr; real_eng.opt_sweep(p).TSFC = TSFCr;
    real_eng.opt_sweep(p).eta_T = etaTr; real_eng.opt_sweep(p).eta_P = etaPr; real_eng.opt_sweep(p).eta_O = etaOr;
end

% Objective labels
objective = {'Max F/mdot'; 'Min TSFC'; 'Max eta_T'; 'Max eta_P'; 'Max eta_O'};

% Ideal config table
[~, i_max_F_i] = max(ideal.F);
[~, i_min_TSFC_i] = min(ideal.TSFC);
[~, i_max_etaT_i] = max(ideal.eta_T);
[~, i_max_etaP_i] = max(ideal.eta_P);
[~, i_max_etaO_i] = max(ideal.eta_O);

configs_i = [ideal.x_front(i_max_F_i,:); ideal.x_front(i_min_TSFC_i,:); ...
             ideal.x_front(i_max_etaT_i,:); ideal.x_front(i_max_etaP_i,:); ...
             ideal.x_front(i_max_etaO_i,:)];
perfs_i   = [ideal.F(i_max_F_i), ideal.TSFC(i_max_F_i), ideal.eta_T(i_max_F_i), ideal.eta_P(i_max_F_i), ideal.eta_O(i_max_F_i);
             ideal.F(i_min_TSFC_i), ideal.TSFC(i_min_TSFC_i), ideal.eta_T(i_min_TSFC_i), ideal.eta_P(i_min_TSFC_i), ideal.eta_O(i_min_TSFC_i);
             ideal.F(i_max_etaT_i), ideal.TSFC(i_max_etaT_i), ideal.eta_T(i_max_etaT_i), ideal.eta_P(i_max_etaT_i), ideal.eta_O(i_max_etaT_i);
             ideal.F(i_max_etaP_i), ideal.TSFC(i_max_etaP_i), ideal.eta_T(i_max_etaP_i), ideal.eta_P(i_max_etaP_i), ideal.eta_O(i_max_etaP_i);
             ideal.F(i_max_etaO_i), ideal.TSFC(i_max_etaO_i), ideal.eta_T(i_max_etaO_i), ideal.eta_P(i_max_etaO_i), ideal.eta_O(i_max_etaO_i)];

fprintf('\n=== Ideal — Optimal Configurations per Objective ===\n');
disp(table(objective, configs_i(:,1), configs_i(:,2), configs_i(:,3), configs_i(:,4), ...
    configs_i(:,5), configs_i(:,6), configs_i(:,7), ...
    perfs_i(:,1), perfs_i(:,2), perfs_i(:,3), perfs_i(:,4), perfs_i(:,5), ...
    'VariableNames', {'Objective','M0','alt_m','Tt4_K','hPR_Jkg','alpha','pi_c','pi_f', ...
    'F_m0','TSFC','eta_T','eta_P','eta_O'}));

% Real config table
[~, i_max_F_r]    = max(real_eng.F);
[~, i_min_TSFC_r] = min(real_eng.TSFC);
[~, i_max_etaT_r] = max(real_eng.eta_T);
[~, i_max_etaP_r] = max(real_eng.eta_P);
[~, i_max_etaO_r] = max(real_eng.eta_O);

configs_r = [real_eng.x_front(i_max_F_r,:);    real_eng.x_front(i_min_TSFC_r,:); ...
             real_eng.x_front(i_max_etaT_r,:); real_eng.x_front(i_max_etaP_r,:); ...
             real_eng.x_front(i_max_etaO_r,:)];
perfs_r = [real_eng.F(i_max_F_r),    real_eng.TSFC(i_max_F_r),    real_eng.eta_T(i_max_F_r),    real_eng.eta_P(i_max_F_r),    real_eng.eta_O(i_max_F_r);
             real_eng.F(i_min_TSFC_r), real_eng.TSFC(i_min_TSFC_r), real_eng.eta_T(i_min_TSFC_r), real_eng.eta_P(i_min_TSFC_r), real_eng.eta_O(i_min_TSFC_r);
             real_eng.F(i_max_etaT_r), real_eng.TSFC(i_max_etaT_r), real_eng.eta_T(i_max_etaT_r), real_eng.eta_P(i_max_etaT_r), real_eng.eta_O(i_max_etaT_r);
             real_eng.F(i_max_etaP_r), real_eng.TSFC(i_max_etaP_r), real_eng.eta_T(i_max_etaP_r), real_eng.eta_P(i_max_etaP_r), real_eng.eta_O(i_max_etaP_r);
             real_eng.F(i_max_etaO_r), real_eng.TSFC(i_max_etaO_r), real_eng.eta_T(i_max_etaO_r), real_eng.eta_P(i_max_etaO_r), real_eng.eta_O(i_max_etaO_r)];

fprintf('\n=== Real — Optimal Configurations per Objective ===\n');
disp(table(objective, configs_r(:,1), configs_r(:,2), configs_r(:,3), configs_r(:,4), ...
    configs_r(:,5), configs_r(:,6), configs_r(:,7), ...
    perfs_r(:,1), perfs_r(:,2), perfs_r(:,3), perfs_r(:,4), perfs_r(:,5), ...
    'VariableNames', {'Objective','M0','alt_m','Tt4_K','hPR_Jkg','alpha','pi_c','pi_f', ...
    'F_m0','TSFC','eta_T','eta_P','eta_O'}));

% Figures 1-7: parameter sweeps (ideal vs real overlaid)
% Subplot top = F/mdot & TSFC, bottom = efficiencies
for p = 1:7
    sweep = param_ranges{p};

    figure;

    % Top subplot: F/mdot (left axis) and TSFC (right axis)
    subplot(2,1,1);
    yyaxis left;
    plot(sweep, ideal.sweep(p).F,    'b-',  'LineWidth', 1.5); hold on;
    plot(sweep, real_eng.sweep(p).F, 'b--', 'LineWidth', 1.5);
    ylabel('$F/\dot{m}_0$ [N$\cdot$s/kg]', 'Interpreter', 'latex', 'FontSize', 12);
    yyaxis right;
    plot(sweep, ideal.sweep(p).TSFC,    'r-',  'LineWidth', 1.5); hold on;
    plot(sweep, real_eng.sweep(p).TSFC, 'r--', 'LineWidth', 1.5);
    ylabel('$S$ [kg/N/s]', 'Interpreter', 'latex', 'FontSize', 12);
    xlabel(param_labels{p}, 'Interpreter', 'latex', 'FontSize', 12);
    title(['a1851552 - $F/\dot{m}_0$ and TSFC vs ' param_labels{p}], 'Interpreter', 'latex', 'FontSize', 12);
    legend('Ideal $F/\dot{m}_0$', 'Real $F/\dot{m}_0$', 'Ideal TSFC', 'Real TSFC', ...
           'Interpreter', 'latex', 'Location', 'eastoutside');
    set(gca, 'TickLabelInterpreter', 'latex'); grid on;
    ax=gca;
    ax.YAxis(1).Color='k'; % Left Y axis
    ax.YAxis(2).Color='k'; % Right Y axis

    % Bottom subplot: efficiencies
    subplot(2,1,2);
    plot(sweep, ideal.sweep(p).eta_T,    'b-',  'LineWidth', 1.5); hold on;
    plot(sweep, real_eng.sweep(p).eta_T, 'b--', 'LineWidth', 1.5);
    plot(sweep, ideal.sweep(p).eta_P,    'r-',  'LineWidth', 1.5);
    plot(sweep, real_eng.sweep(p).eta_P, 'r--', 'LineWidth', 1.5);
    plot(sweep, ideal.sweep(p).eta_O,    'g-',  'LineWidth', 1.5);
    plot(sweep, real_eng.sweep(p).eta_O, 'g--', 'LineWidth', 1.5);
    ylabel('Efficiency', 'Interpreter', 'latex', 'FontSize', 12);
    xlabel(param_labels{p}, 'Interpreter', 'latex', 'FontSize', 12);
    title(['a1851552 - Efficiencies vs ' param_labels{p}], 'Interpreter', 'latex', 'FontSize', 12);
    legend('Ideal $\eta_T$', 'Real $\eta_T$', 'Ideal $\eta_P$', 'Real $\eta_P$', ...
           'Ideal $\eta_O$', 'Real $\eta_O$', 'Interpreter', 'latex', 'Location', 'eastoutside');
    set(gca, 'TickLabelInterpreter', 'latex'); grid on;
end

% Figures 8-9: optimal config sweeps over pi_c and pi_f
for p = 1:2
    sweep = opt_sweeps{p};

    figure;

    subplot(2,1,1);
    yyaxis left;
    plot(sweep, ideal.opt_sweep(p).F,    'b-',  'LineWidth', 1.5); hold on;
    plot(sweep, real_eng.opt_sweep(p).F, 'b--', 'LineWidth', 1.5);
    ylabel('$F/\dot{m}_0$ [N$\cdot$s/kg]', 'Interpreter', 'latex', 'FontSize', 12);
    yyaxis right;
    plot(sweep, ideal.opt_sweep(p).TSFC,    'r-',  'LineWidth', 1.5); hold on;
    plot(sweep, real_eng.opt_sweep(p).TSFC, 'r--', 'LineWidth', 1.5);
    ylabel('$S$ [kg/N/s]', 'Interpreter', 'latex', 'FontSize', 12);
    xlabel(opt_labels{p}, 'Interpreter', 'latex', 'FontSize', 12);
    title(['a1851552 - Optimal Config: $F/\dot{m}_0$ and TSFC vs ' opt_labels{p}], ...
           'Interpreter', 'latex', 'FontSize', 12);
    legend('Ideal $F/\dot{m}_0$', 'Real $F/\dot{m}_0$', 'Ideal TSFC', 'Real TSFC', ...
           'Interpreter', 'latex', 'Location', 'eastoutside');
    set(gca, 'TickLabelInterpreter', 'latex'); grid on;
    ax=gca;
    ax.YAxis(1).Color='k'; % Left Y axis
    ax.YAxis(2).Color='k'; % Right Y axis

    subplot(2,1,2);
    plot(sweep, ideal.opt_sweep(p).eta_T,    'b-',  'LineWidth', 1.5); hold on;
    plot(sweep, real_eng.opt_sweep(p).eta_T, 'b--', 'LineWidth', 1.5);
    plot(sweep, ideal.opt_sweep(p).eta_P,    'r-',  'LineWidth', 1.5);
    plot(sweep, real_eng.opt_sweep(p).eta_P, 'r--', 'LineWidth', 1.5);
    plot(sweep, ideal.opt_sweep(p).eta_O,    'g-',  'LineWidth', 1.5);
    plot(sweep, real_eng.opt_sweep(p).eta_O, 'g--', 'LineWidth', 1.5);
    ylabel('Efficiency', 'Interpreter', 'latex', 'FontSize', 12);
    xlabel(opt_labels{p}, 'Interpreter', 'latex', 'FontSize', 12);
    title(['a1851552 - Optimal Config: Efficiencies vs ' opt_labels{p}], ...
           'Interpreter', 'latex', 'FontSize', 12);
    legend('Ideal $\eta_T$', 'Real $\eta_T$', 'Ideal $\eta_P$', 'Real $\eta_P$', ...
           'Ideal $\eta_O$', 'Real $\eta_O$', 'Interpreter', 'latex', 'Location', 'eastoutside');
    set(gca, 'TickLabelInterpreter', 'latex'); grid on;
end

% Save all figures into Desktop
desktop_path = fullfile(getenv('HOME'), 'Desktop', 'turbofan_figures');
if ~exist(desktop_path, 'dir')
    mkdir(desktop_path);
end

for fig_num = 1:9
    fig = figure(fig_num);
    set(fig, 'Units', 'centimeters', 'Position', [0 0 24 18]);
    exportgraphics(fig, fullfile(desktop_path, sprintf('figure_%02d.pdf', fig_num)), ...
        'ContentType', 'vector', ...
        'BackgroundColor', 'white');
    fprintf('Saved figure %d\n', fig_num);
end

fprintf('All figures saved to: %s\n', desktop_path);

% Save tables to CSV

% Ideal configurations table
ideal_configs = table(objective, configs_i(:,1), configs_i(:,2), configs_i(:,3), configs_i(:,4), ...
    configs_i(:,5), configs_i(:,6), configs_i(:,7), ...
    perfs_i(:,1), perfs_i(:,2), perfs_i(:,3), perfs_i(:,4), perfs_i(:,5), ...
    'VariableNames', {'Objective','M0','alt_m','Tt4_K','hPR_Jkg','alpha','pi_c','pi_f', ...
    'F_m0','TSFC','eta_T','eta_P','eta_O'});
writetable(ideal_configs, fullfile(desktop_path, 'ideal_optimal_configs.csv'));

% Real configurations table
real_configs = table(objective, configs_r(:,1), configs_r(:,2), configs_r(:,3), configs_r(:,4), ...
    configs_r(:,5), configs_r(:,6), configs_r(:,7), ...
    perfs_r(:,1), perfs_r(:,2), perfs_r(:,3), perfs_r(:,4), perfs_r(:,5), ...
    'VariableNames', {'Objective','M0','alt_m','Tt4_K','hPR_Jkg','alpha','pi_c','pi_f', ...
    'F_m0','TSFC','eta_T','eta_P','eta_O'});
writetable(real_configs, fullfile(desktop_path, 'real_optimal_configs.csv'));

% Ideal Pareto front
ideal_pareto = table(ideal.x_front(:,1), ideal.x_front(:,2), ideal.x_front(:,3), ...
    ideal.x_front(:,4), ideal.x_front(:,5), ideal.x_front(:,6), ideal.x_front(:,7), ...
    ideal.F, ideal.TSFC, ideal.eta_T, ideal.eta_P, ideal.eta_O, ...
    'VariableNames', {'M0','alt_m','Tt4_K','hPR_Jkg','alpha','pi_c','pi_f', ...
    'F_m0','TSFC','eta_T','eta_P','eta_O'});
writetable(ideal_pareto, fullfile(desktop_path, 'ideal_pareto_front.csv'));

% Real Pareto front
real_pareto = table(real_eng.x_front(:,1), real_eng.x_front(:,2), real_eng.x_front(:,3), ...
    real_eng.x_front(:,4), real_eng.x_front(:,5), real_eng.x_front(:,6), real_eng.x_front(:,7), ...
    real_eng.F, real_eng.TSFC, real_eng.eta_T, real_eng.eta_P, real_eng.eta_O, ...
    'VariableNames', {'M0','alt_m','Tt4_K','hPR_Jkg','alpha','pi_c','pi_f', ...
    'F_m0','TSFC','eta_T','eta_P','eta_O'});
writetable(real_pareto, fullfile(desktop_path, 'real_pareto_front.csv'));

fprintf('All CSVs saved to: %s\n', desktop_path);