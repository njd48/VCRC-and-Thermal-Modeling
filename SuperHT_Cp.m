function [ Cp ] = SuperHT_Cp( T )



%Convert to kelvin
T = T + 273.15;

%R-410a constants
c1  = [ 2.676084E-1, 2.115353E-3, -9.848184E-7, 6.493781E-11 ];

vec = [  1;  T;  T.^2;  T.^3 ];

Cp  = c1*vec;


end

