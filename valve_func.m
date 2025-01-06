function [ m_dot ] = valve_func( CA_param, P_up, P_down, x)

% CA_par : [m2]  dimensional parameter
% P_up   : [kPa] upstream press
% P_down : [kPa] downstream press
% x      : [  ]  valve opening fraction

%At 0.80 valve opening we have the rated value

% Density 
rho_v     = Ther_rho( P_up, 0, 'reg');

% Mass flow rate
m_dot = CA_param.*( x/0.80 ).*sqrt( rho_v.*1000.*(P_up - P_down) );

end