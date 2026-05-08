clear; clc;

% Constants
gamma = 1.4;   
cp = 1005;
gamma_c = 1.4;   
cp_c = 1004;
gamma_t = 1.33;  
cp_t = 1156;

copyfile('atmosphere.db', 'atmosphere_rw.db');
atm_path = fullfile('atmosphere_rw.db');

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
    title(['$F/\dot{m}_0$ and TSFC vs ' param_labels{p}], 'Interpreter', 'latex', 'FontSize', 12);
    legend('Ideal $F/\dot{m}_0$', 'Real $F/\dot{m}_0$', 'Ideal TSFC', 'Real TSFC', ...
           'Interpreter', 'latex', 'Location', 'eastoutside');
    set(gca, 'TickLabelInterpreter', 'latex'); grid on;

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
    title(['Efficiencies vs ' param_labels{p}], 'Interpreter', 'latex', 'FontSize', 12);
    legend('Ideal $\eta_T$', 'Real $\eta_T$', 'Ideal $\eta_P$', 'Real $\eta_P$', ...
           'Ideal $\eta_O$', 'Real $\eta_O$', 'Interpreter', 'latex', 'Location', 'best');
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
    title(['Optimal Config: $F/\dot{m}_0$ and TSFC vs ' opt_labels{p}], ...
           'Interpreter', 'latex', 'FontSize', 12);
    legend('Ideal $F/\dot{m}_0$', 'Real $F/\dot{m}_0$', 'Ideal TSFC', 'Real TSFC', ...
           'Interpreter', 'latex', 'Location', 'eastoutside');
    set(gca, 'TickLabelInterpreter', 'latex'); grid on;

    subplot(2,1,2);
    plot(sweep, ideal.opt_sweep(p).eta_T,    'b-',  'LineWidth', 1.5); hold on;
    plot(sweep, real_eng.opt_sweep(p).eta_T, 'b--', 'LineWidth', 1.5);
    plot(sweep, ideal.opt_sweep(p).eta_P,    'r-',  'LineWidth', 1.5);
    plot(sweep, real_eng.opt_sweep(p).eta_P, 'r--', 'LineWidth', 1.5);
    plot(sweep, ideal.opt_sweep(p).eta_O,    'g-',  'LineWidth', 1.5);
    plot(sweep, real_eng.opt_sweep(p).eta_O, 'g--', 'LineWidth', 1.5);
    ylabel('Efficiency', 'Interpreter', 'latex', 'FontSize', 12);
    xlabel(opt_labels{p}, 'Interpreter', 'latex', 'FontSize', 12);
    title(['Optimal Config: Efficiencies vs ' opt_labels{p}], ...
           'Interpreter', 'latex', 'FontSize', 12);
    legend('Ideal $\eta_T$', 'Real $\eta_T$', 'Ideal $\eta_P$', 'Real $\eta_P$', ...
           'Ideal $\eta_O$', 'Real $\eta_O$', 'Interpreter', 'latex', 'Location', 'eastoutside');
    set(gca, 'TickLabelInterpreter', 'latex'); grid on;
end
