function [ var_out ] = Ther_rho( P, qual, str )

%Param

a_f = [-0.155879910840299,1364.54475389209];
a_g = [6.94731512896260e-06,0.0251713529109981,2.55358156238750];

if strcmp(str, 'reg' )
    
    
    
    var_out = ( qual )*( a_g(1)*P.^2  +  a_g(2)*P  +  a_g(3) ) +...
              (1-qual)*(                 a_f(1)*P  +  a_f(2)  ) ;
          
          
    
elseif strcmp(str, 'd/dP' )
    
    
    var_out = ( qual )*( 2*a_g(1)*P  +  a_g(2) ) +...
              (1-qual)*(                a_f(1) ) ;
    
          
else
    
    error('bad string arg')
    
end




end

