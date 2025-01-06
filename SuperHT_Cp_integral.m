function [ deltaH ] = SuperHT_Cp_integral( T1, T2 )



%Convert to kelvin
T1 = T1 + 273.15;
T2 = T2 + 273.15;

%R-410a constants
c1  = [ 2.676084E-1, 2.115353E-3, -9.848184E-7, 6.493781E-11 ];

c1  = [1, 1/2, 1/3, 1/4].*c1;

vec1 = [  T1;  T1.^2;  T1.^3;  T1.^4 ];
vec2 = [  T2;  T2.^2;  T2.^3;  T2.^4 ];

deltaH  = c1*vec2 - c1*vec1;


end

