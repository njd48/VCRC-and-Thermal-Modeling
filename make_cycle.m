function [ P, T, h, abscissa, m_dot, Q_L, Q_H, W, Deficit] = make_cycle(Vars, Inputs, Param)

%----------------------------------------------%
%==------ Vars  -------==
    P_c    = Vars(1);
    P_e    = Vars(2);
    valve  = Vars(3);
%----------------------------------------------%
%==------ Inputs ------==
    
    Q_load = Inputs(1);
    T_SH   = Inputs(2);
    T_amb  = Inputs(3);
    T_pod  = Inputs(4);
%----------------------------------------------%
%==------ Param -------==
    RPM    = Param(1);
    CA     = Param(2);
    
    
%----------------------------------------------%
%==-- Init. Outputs  --==
    P       = zeros(9,1);
    T       = P;
    h       = P;
    abscissa = P;  
    % var "abscissa" is the nondimensional 
    % Heat exchanger position 
    % for each of these stations
    % domain = [0,1]U[1,2]
    % [0,1] <-- in condensor
    % [1,2] <-- in evaporator
    
%=========================================================================%
% Calculate
%=========================================================================%

% Init state
    T_sat_e = SatLookupTP('T','P',P_e);
    h_g     = SatLookupTP('hg','P',P_e);
    
    P(1)       = P_e;
    T(1)       = T_sat_e + T_SH;
    h(1)       = h_g +SuperHT_Cp_integral( T_sat_e, T(1) );
    abscissa(1) = 0;
    s_1        = XR410a('s','Ph', P_e, h(1) );
    
    STATE   = [P(1),h(1)];
    
    
%   calculate compressor
m_dot_s = compr_func( STATE, RPM );
    s_2 = s_1;
    
    P(2) = P_c;
    h(2) = XR410a('h','Ps', P_c, s_2);

    STATE = [P(2); h(2)];
    
    
%   calculate condenser
[P(2:5), T(2:5), h(2:5), abscissa(2:5)] ...
    = Condenser_Proc( STATE, 'h', m_dot_s, T_amb );


%   calculate expansion
m_dot_v = valve_func( CA, P_c, P_e, valve );
    
    P(6) = P_e;
    h(6) = h(5);
    
    STATE = [ P(6); h(6)];
    

%   calculate evap
[P(6:9), T(6:9), h(6:9), abscissa(6:9)] ...
    = Evap_Proc(    STATE, m_dot_v, T_pod );

abscissa(6:9) = abscissa(6:9) + abscissa(5);

% Energy and Mass Deficits
Q_evap = m_dot_v*( h(9) - h(6) );
Q_absr = m_dot_v*( h(1) - h(6) );

m_def  =  (m_dot_s - m_dot_v)/m_dot_s;  %Mass Deficit
h_def  =  (Q_absr  - Q_evap)/Q_evap;   %evap deficit
Q_def  =  (Q_evap  - Q_load)/Q_load;   %Pod energy deficit

Deficit = [m_def; h_def; Q_def];


%Other Outputs
m_dot = m_dot_v;
Q_L   = Q_evap;
Q_H   = m_dot_v*( h(2)-h(5) );
W     = m_dot_s*( h(2)-h(1) );



end

