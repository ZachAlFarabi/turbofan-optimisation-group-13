%% Aerospace Propulsion 2026 
% Group 13
% Zach Al-Farabi - a1851552

function obj = turbofan_objectives(x, gamma, cp, atm_path)

    % Unpack design variables
    M0 = x(1); alt = x(2); Tt4 = x(3); hPR = x(4);
    alpha = x(5); pi_c = x(6); pi_f = x(7);

    % Find T0 using atmosphere table
    [T0, ~, ~, a0] = atmosphere(alt, 'standard', atm_path);

    % Temperature ratios
    tau_r = 1 + ((gamma-1)/2) * M0^2;
    tau_c = pi_c^((gamma-1)/gamma);
    tau_f = pi_f^((gamma-1)/gamma);
    tau_lambda = Tt4 / T0;
    tau_t = 1 - (tau_r/tau_lambda) * (tau_c - 1 + alpha*(tau_f - 1));

    if ~isfinite(tau_t) || tau_t <= 0
        obj = [1, 1, -1, -1, -1]; return;
    end

    % Exit velocities relative to freestream sound speed
    V9_a0_sq = (2/(gamma-1)) * (tau_lambda/(tau_r*tau_c)) * (tau_r*tau_c*tau_t - 1);
    V19_a0_sq = (2/(gamma-1)) * (tau_r*tau_f - 1);

    if V9_a0_sq <= 0 || V19_a0_sq <= 0
        obj = [1, 1, -1, -1, -1]; return;
    end

    V9_a0 = sqrt(V9_a0_sq);
    V19_a0 = sqrt(V19_a0_sq);

    % Velocity ratios
    V9_V0  = V9_a0 / M0;
    V19_V0 = V19_a0 / M0;

    % Specific thrust, fuel-air ratio and TSFC
    F_m0 = (a0/(1+alpha)) * (V9_a0 - M0 + alpha*(V19_a0 - M0));
    f = (cp*T0/hPR) * (tau_lambda - tau_r*tau_c);
    S = f / ((1+alpha) * F_m0);

    % Thermal, propulsive and overall efficiency
    eta_T = 1 - 1/(tau_r*tau_c);
    eta_P = 2*(V9_V0 - 1 + alpha*(V19_V0 - 1)) / (V9_V0^2 - 1 + alpha*(V19_V0^2 - 1));
    eta_O = eta_T * eta_P;

    if ~isfinite(F_m0) || F_m0 <= 0 || ~isfinite(S) || S <= 0
        obj = [1, 1, -1, -1, -1]; return;
    end

    % Pack objective values
    obj = [-F_m0, S, -eta_T, -eta_P, -eta_O];
end
