function [Vars, Deficit] = adjust_cycle(Vars, Inputs, Param, epsilon)

assert( sum(size(Vars) == [3,1]) == 2 )


dx  = [ epsilon; 0; 0 ];
dy  = [ 0; epsilon; 0 ];
dz  = [ 0; 0; epsilon ];

[x1,x2,x3,x4,x5,x6,x7,x8, Deficit] = make_cycle( Vars,      Inputs, Param );
[x1,x2,x3,x4,x5,x6,x7,x8, f_x_for] = make_cycle( Vars + dx, Inputs, Param );
[x1,x2,x3,x4,x5,x6,x7,x8, f_y_for] = make_cycle( Vars + dy, Inputs, Param );
[x1,x2,x3,x4,x5,x6,x7,x8, f_z_for] = make_cycle( Vars + dz, Inputs, Param );


df_dx = (1/epsilon)*( f_x_for - Deficit );
df_dy = (1/epsilon)*( f_y_for - Deficit );
df_dz = (1/epsilon)*( f_z_for - Deficit );

J = [ df_dx, df_dy, df_dz ];

Vars = Vars - J\Deficit;

end

