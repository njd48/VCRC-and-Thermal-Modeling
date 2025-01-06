function [Vars, Deficit] = adjust_cycle(Vars, Inputs, Param, epsilon)

assert( sum(size(Vars) == [3,1]) == 2 )

T_amb  = Inputs(3);
T_pod  = Inputs(4);
    
%Var Extents
a(1) = SatLookupTP('P','T', T_amb);
b(1) = 4100;
a(2) = 500;
b(2) = SatLookupTP('P','T', T_pod);
a(3) = 0;
b(3) = T_pod - SatLookupTP('T','P', Vars(2)+1);

%Transform Vars
t = 0*Vars;
dx_dt = t;
for j = 1:3
    
    t(j)     = -log( ( b(j)-a(j) )/( Vars(j)-a(j) ) - 1 );
    dx_dt(j) = (b(j)-a(j))*exp(-t(j))/(1+exp(-t(j)))^2;
    
end

%Differentials
dx  = [ epsilon; 0; 0 ];
dy  = [ 0; epsilon; 0 ];
dz  = [ 0; 0; epsilon ];

%Outputs
[x1,x2,x3,x4,x5,x6,x7,x8, Deficit] = make_cycle( Vars,      Inputs, Param );
[x1,x2,x3,x4,x5,x6,x7,x8, f_x_for] = make_cycle( Vars + dx, Inputs, Param );
[x1,x2,x3,x4,x5,x6,x7,x8, f_y_for] = make_cycle( Vars + dy, Inputs, Param );
[x1,x2,x3,x4,x5,x6,x7,x8, f_z_for] = make_cycle( Vars + dz, Inputs, Param );

%Derivatives
df_dx  = (1/epsilon)*( f_x_for - Deficit );
df_dy  = (1/epsilon)*( f_y_for - Deficit );
df_dz  = (1/epsilon)*( f_z_for - Deficit );

df_dt1 = dx_dt(1)*df_dx;
df_dt2 = dx_dt(2)*df_dy;
df_dt3 = dx_dt(3)*df_dz;


%Form Jacobian
J = [ df_dt1, df_dt2, df_dt3 ];


%Newton Step
t = t - J\Deficit;

%Detransform
for j = 1:3
    Vars(j) = a(j) + ( b(j)-a(j) )/( 1+exp(-t(j)) );
end

%Return Output

end

