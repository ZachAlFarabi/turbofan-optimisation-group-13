%% Aerospace Propulsion 2026 
% Group 13
% Zach Al-Farabi - a1851552

function obj = real_turbofan_objectives(x, gamma_c, gamma_t, cp_c, cp_t)
    
    % Unpack design variables
    M0 = x(1); alt = x(2); Tt4 = x(3); hPR = x(4);
    alpha = x(5); pi_c = x(6); pi_f = x(7);

    % Find T0 using atmosphere table
    [T0, ~, ~, ~] = atmosphere(alt, 'standard');

    % Define component performance technology level 4
    pi_d = 0.96; 
    e_c = 0.90; 
    pi_b  = 0.95; 
    eta_b = 0.99;
    e_t = 0.90; 
    pi_n = 0.97; 
    pi_fn = 0.97; 
    e_f = 0.95; 
    eta_m = 0.99;

    % Initialisation 
    Rc = (gamma_c-1)/gamma_c * cp_c;
    Rt = (gamma_t-1)/gamma_t * cp_t;
    a0 = sqrt(gamma_c * Rc * T0);
    g = 9.81;

    % Temperature ratios and fuel-air ratio
    tau_r = 1 + ((gamma_c-1)/2) * M0^2;
    tau_c = pi_c ^ ((gamma_c-1)/(gamma_c*e_c));
    tau_f  = pi_f ^ ((gamma_c-1)/(gamma_c*e_f));
    tau_lambda = (cp_t * Tt4) / (cp_c * T0);
    f = (tau_lambda - tau_r*tau_c) / ((hPR*eta_b)/(cp_c*T0) - tau_lambda);
    tau_t = 1 - (1/(eta_m*(1+f))) * (tau_r/tau_lambda) * (tau_c - 1 + alpha*(tau_f - 1));

    if ~isfinite(f) || f <= 0 || ~isfinite(tau_t) || tau_t <= 0
        obj = [1, 1, -1, -1, -1]; return;
    end

    % Pressure ratios
    pi_r  = tau_r ^ (gamma_c/(gamma_c-1));
    pi_t = tau_t ^ (gamma_t/((gamma_t-1)*e_t));
    Pt9_P9 = pi_r * pi_d * pi_c * pi_b * pi_t * pi_n;
    Pt19_P19 = pi_r * pi_d * pi_f * pi_fn;

    if Pt9_P9 <= 1 || Pt19_P19 <= 1
        obj = [1, 1, -1, -1, -1]; return;
    end

    % Exit mach number
    M9  = sqrt((2/(gamma_t-1)) * (Pt9_P9 ^ ((gamma_t-1)/gamma_t) - 1));
    M19 = sqrt((2/(gamma_c-1)) * (Pt19_P19 ^ ((gamma_c-1)/gamma_c) - 1));

    % Temperature ratios
    T9_T0 = (tau_lambda * tau_t) / (Pt9_P9 ^ ((gamma_t-1)/gamma_t)) * (cp_c/cp_t);
    T19_T0 = (tau_r * tau_f) / (Pt19_P19 ^ ((gamma_c-1)/gamma_c));

    if T9_T0 <= 0 || T19_T0 <= 0
        obj = [1, 1, -1, -1, -1]; return;
    end

    % Exit velocities relative to freestream sound speed
    V9_a0  = M9  * sqrt((gamma_t*Rt)/(gamma_c*Rc) * T9_T0);
    V19_a0 = M19 * sqrt(T19_T0);

    if V9_a0 <= 0 || V19_a0 <= 0
        obj = [1, 1, -1, -1, -1]; return;
    end

    % Specific thrust and TSFC
    F_m0 = (a0/(1+alpha)) * ((1+f)*V9_a0 + alpha*V19_a0 - (1+alpha)*M0);
    S = f / ((1+alpha) * F_m0);

    % Thermal, propulsive and overall efficiency
    eta_T = a0^2 * ((1+f)*V9_a0^2 + alpha*V19_a0^2 - (1+alpha)*M0^2) / (2*f*hPR);
    eta_P = (2*M0 * ((1+f)*V9_a0 + alpha*V19_a0 - (1+alpha)*M0)) / ...
            ((1+f)*V9_a0^2 + alpha*V19_a0^2 - (1+alpha)*M0^2);
    eta_O = eta_T * eta_P;

    if ~isfinite(F_m0) || F_m0 <= 0 || ~isfinite(S) || S <= 0
        obj = [1, 1, -1, -1, -1]; return;
    end

    % Pack objective values
    obj = [-F_m0, S, -eta_T, -eta_P, -eta_O];
end
