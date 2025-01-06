function [Outputs] = get_cycle_facts( Vars, Inputs, Param)

[P,T,h,z, Deficit] = make_cycle(Vars, Inputs, Param);

%----------------------------------------------%
%==------ Vars  -------==
    P_c    = Vars(1);
    P_e    = Vars(2);
    
%----------------------------------------------%
%==------ Inputs ------==
    T_SH   = Inputs(1);
    Q_load = Inputs(2);
   
%----------------------------------------------%
%==------ Param -------==
    RPM    = Param(1);
    CA     = Param(2);
    valve  = Param(3);
    T_amb  = Param(4);
    T_pod  = Param(5);

%----------------------------------------------%
%----------------------------------------------%


m_dot_s = compr_func( [P(1),h(1)],  RPM   );
m_dot_v = valve_func( CA, P_c, P_e, valve );

Q_evap_1  = m_dot_v*( h(8)-h(6) );
Q_evap_2  = m_dot_s*( h(1)-h(6) );
Q_cond    = m_dot_s*( h(2)-h(5) );
W_comp    = m_dot_s*( h(2)-h(1) );

fprintf('')
fprintf(' \n')
fprintf('|Compresser Speed:       %d  (rpm)  \n', RPM )
fprintf('|Valve Opening:          %d  ( )    \n', valve )
fprintf('------------------------ ------------- ------- \n' )
fprintf('|Mass Deficit:           %d  (kg/s) \n', Deficit(1) )
fprintf('|Heat Deficit:           %d  (kW)   \n', Deficit(2) )
fprintf('|Mass Flow Rate, V:      %d  (kg/s) \n', m_dot_v)
fprintf('|Mass Flow Rate, S:      %d  (kg/s) \n', m_dot_s)
fprintf('|Evap Heat Transfer, V:  %d  (kW)   \n', Q_evap_1 )
fprintf('|Evap Heat Transfer, S:  %d  (kW)   \n', Q_evap_2 )
fprintf('|Evap Superheat: DT =    %d  (*C)   \n', T_SH )
fprintf('|Cond Heat Transfer, S:  %d  (kW)   \n', Q_cond )
fprintf('|Compressor Work,        %d  (kW)   \n', W_comp )
fprintf('------------------------ ------------- ------- \n' )

Outputs = {Deficit; m_dot_v; m_dot_s; Q_evap_1; ...
           Q_evap_2; T_SH; Q_cond; W_comp };

end

