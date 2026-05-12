%% Aerospace Propulsion 2026 
% Group 13
% Zach Al-Farabi - a1851552

function obj = turbofan_objectives(x, gamma, cp)
% Unpack design variables
M0 = x(1); alt = x(2); Tt4 = x(3); hPR = x(4);
alpha = x(5); pi_c = x(6); pi_f = x(7);

% Find T0 using atmosphere table
[T0, ~, ~, a0] = atmosphere(alt, 'standard');

% Compute tau ratios
tau_r = 1 + ((gamma-1)/2) * M0^2;
tau_c = pi_c^((gamma-1)/gamma);
tau_f = pi_f^((gamma-1)/gamma);
tau_lambda = Tt4 / T0;
tau_t = 1 - (tau_r/tau_lambda) * (tau_c - 1 + alpha*(tau_f - 1));

if ~isfinite(tau_t) || tau_t <= 0
    obj = [1, 1, -1, -1, -1]; return;
end

% Pressure ratios
pi_r = tau_r^(gamma/(gamma-1));
pi_t = tau_t^(gamma/(gamma-1));
Pt9_P9 = pi_r * pi_c * pi_t;
Pt19_P19 = pi_r * pi_f;

if Pt9_P9 <= 1 || Pt19_P19 <= 1
    obj = [1, 1, -1, -1, -1]; return;
end

% Nozzle exit Mach numbers
M9  = sqrt((2/(gamma-1)) * (Pt9_P9  ^ ((gamma-1)/gamma) - 1));
M19 = sqrt((2/(gamma-1)) * (Pt19_P19 ^ ((gamma-1)/gamma) - 1));

% Temperature ratios at nozzle exit
T9_T0  = tau_lambda * tau_t / (Pt9_P9  ^ ((gamma-1)/gamma));
T19_T0 = tau_r * tau_f / (Pt19_P19 ^ ((gamma-1)/gamma));

if T9_T0 <= 0 || T19_T0 <= 0
    obj = [1, 1, -1, -1, -1]; return;
end

% Exit velocity ratios
V9_a0 = M9  * sqrt(T9_T0);
V19_a0 = M19 * sqrt(T19_T0);

% Specific thrust, fuel-air ratio and TSFC
f = (cp*T0/hPR) * (tau_lambda - tau_r*tau_c);
F_m0 = (a0/(1+alpha)) * ((1+f)*V9_a0 + alpha*V19_a0 - (1+alpha)*M0);
S = f / ((1+alpha) * F_m0);

% Thermal, propulsive and overall efficiency
eta_T = (a0^2 * ((1+f)*V9_a0^2 + alpha*V19_a0^2 - (1+alpha)*M0^2)) / (2*f*hPR);
eta_P = (2*M0 * ((1+f)*V9_a0 + alpha*V19_a0 - (1+alpha)*M0)) / ...
        ((1+f)*V9_a0^2 + alpha*V19_a0^2 - (1+alpha)*M0^2);
eta_O = eta_T * eta_P;

if ~isfinite(F_m0) || F_m0 <= 0 || ~isfinite(S) || S <= 0
    obj = [1, 1, -1, -1, -1]; return;
end

% Pack objective values
obj = [-F_m0, S, -eta_T, -eta_P, -eta_O];
end