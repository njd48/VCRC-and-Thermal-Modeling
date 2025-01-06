function [cycle_props, global_props, Vars, Deficit] = Big_Make_Cycle( Q_load, valve, T_amb, T_pod, N)


% Sim Param 
epsilon = 0.00001;

load param_4.mat
%.mat includes:
%CA
%RPM


% Init
T_SH = 3;
P_c  = 3200;
P_e  = 1000;

Vars    = [ P_c; P_e; T_SH ]; 
Inputs  = [ Q_load; valve; T_amb; T_pod  ];
Param   = [ RPM, CA ]; 


for n = 1:N
   
    [Vars, Deficit] = adjust_cycle(Vars, Inputs, Param, epsilon);
    disp(Vars)
    
    
end

[P,T,h,z, m_dot, Q_L, Q_H, W, Deficit] = make_cycle(Vars, Inputs, Param);

cycle_props = [z,P,T,h];
global_props = [m_dot,Q_L,Q_H,W];

end

