function [T0, P0, rho0, a0] = atmosphere(h, day_type, db_path)

% Ensure function can take valid inputs
if nargin < 2 || isempty(day_type), day_type = 'standard'; end
if nargin < 3 || isempty(db_path), db_path = fullfile('database', 'atmosphere.db'); end

% Standard constants
P_std = 101325;
T_std = 288.15;
rho_std = 1.225;
a_std = 340.3;

% Ensure can only access valid day types
if ~ismember(day_type, {'standard','cold','hot','tropical'})
    error('atmosphere: day_type must be standard/cold/hot/tropical. Got ''%s''.', day_type);
end

% Ensure can only access valid altitudes
h_km = h ./ 1000;
if any(h_km(:) < 0) || any(h_km(:) > 30)
    error('atmosphere: altitude must be 0-30,000 m.');
end

% Switch case for theta in different day types
switch day_type
    case 'standard', theta_col = 'theta_std';
    case 'cold', theta_col = 'theta_cold';
    case 'hot', theta_col = 'theta_hot';
    case 'tropical', theta_col = 'theta_trop';
end

% Connect and fetch database
conn = sqlite(db_path, 'readonly');
tbl = fetch(conn, ['SELECT h_km, delta, ' theta_col ' AS theta FROM atmosphere ORDER BY h_km ASC']);
close(conn);

% Interpolate linearly within database for theta and delta
delta_h = interp1(tbl.h_km, tbl.delta, h_km(:), 'linear');
theta_h = interp1(tbl.h_km, tbl.theta, h_km(:), 'linear');

% Calculate for references
T0 = reshape(theta_h .* T_std, size(h));
P0 = reshape(delta_h .* P_std, size(h));
rho0 = reshape((delta_h ./ theta_h) .* rho_std, size(h));
a0 = reshape(a_std .* sqrt(theta_h), size(h));

end