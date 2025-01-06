function [ var_out ] = Thermo_rhoH( P, qual, str )

%Param
a_f = [-0.0182516065386190,97.4923257248538,149470.470230018];
a_g = [0.00263712829854206,11.5686574702160,832.539441190425];


if strcmp(str, 'reg' )
    
    
    
    var_out = ( qual )*( a_g(1)*P.^2  +  a_g(2)*P  +  a_g(3) ) +...
              (1-qual)*( a_f(1)*P.^2  +  a_f(2)*P  +  a_f(3) ) ;
          
          
    
elseif strcmp(str, 'd/dP' )
    
    
    var_out = ( qual )*( 2*a_g(1)*P  +  a_g(2) ) +...
              (1-qual)*( 2*a_f(1)*P  +  a_f(2) ) ;
    
          
else
    
    error('bad string arg')
    
end




end

