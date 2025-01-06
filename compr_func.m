
function [ m_dot ] = compr_func( inlet_state, RPM )

P_e   = inlet_state(1);
h_e_o = inlet_state(2);

%Param
r_c = 2.8;        % Compression Ratio
Disp = 7.3E-6;    %[m^3 per rev] %volume displacement
%gamma = 1.1548; % Polytropic Exponent R410a
%Numbers estimated from samsung catalog

h_g   = SatLookupTP('hg','P',P_e);
if h_e_o < h_g
    warning('Flooded Compressor, vapor quality < 1')
end
rho_c = XR410a( 'v', 'Ph', P_e, h_e_o )^(-1);

m_dot = RPM/60*Disp*r_c*rho_c;

end