

input_state = [ 3000; 435]; %[ kPa; kJ/kg ]
strarg      = 'h';          %
flowrate    = 1.96E-2;      %[ kg/s ]
% flowrate    = 1.0E-2;
T_amb       = 40;           %[ *C ]
T_pod       = 15;           %[ *C ]

P       = zeros(7,1);
T       = P;
h       = P;
abcissa = P;

% ---- Calculate -----------------------------------------------
[P(1:4), T(1:4), h(1:4), abcissa(1:4)] ...
    = Condenser_Proc( input_state, strarg, flowrate, T_amb );

    input_state_2 = [ 800; h(4)];

[P(5:8), T(5:8), h(5:8), abcissa(5:8)] ...
    = Evap_Proc(    input_state_2, flowrate, T_pod );

abcissa(5:8) = abcissa(5:8) + 1;
%----------------------------------------------------------------


s = 0*h;

for j = 1:numel(P)
    
    s(j) = XR410a('s','Ph', P(j), h(j) );
    
end

figure(1)
plot(abcissa, T, '-o')

figure(2)
plot( s, T, '-o'), hold on
DrawDome('T','s'), hold off

figure(3)
semilogy( h, P, '-o'), hold on
DrawDome('P','h'), hold off

%% TEst case where evap only partially evaps

input_state_2 = [ 500; SatLookupTP('hf','P', 500)-20];

[ P1, T1, h1, abcissa1 ] ...
    = Evap_Proc(    input_state_2, flowrate, T_pod+20 )

for j = 1:numel(P1)
    
    s1(j) = XR410a('s','Ph', P1(j), h1(j) );
    
end

figure(1)
plot(abcissa1, T1, '-o')

figure(2)
plot( s1, T1, '-o'), hold on
DrawDome('T','s'), hold off

figure(3)
semilogy( h1, P1, '-o'), hold on
DrawDome('P','h'), hold off

%% Test With Compressor

%Sim params
strarg      = 'h';          %

%phys params
P_hi        = 3000;         %[ kPa ]
P_lo        = 800;          %[ kPa ]
h_1         = 425;          %[ kJ/kg ]
flowrate    = 1.96E-2;      %[ kg/s ]
% flowrate    = 1.0E-2;
T_amb       = 40;           %[ *C ]
T_pod       = 15;           %[ *C ]
RPM         = 1609.19;      %[ rpm ]

%Initialize
P       = zeros(8,1);
T       = P;
h       = P;
abcissa = P;

% ---- Calculate -----------------------------------------------
   input_state = [P_lo; h_1];
   
   m_dot = compr_func( input_state, RPM);
   
   P(1) = P_lo; h(1) = h_1; 
   T(1) = XR410a('T','Ph', P(1), h(1) ); 
   abcissa(1) = 0;
%---------
   s = XR410a('s','Ph', P(1), h(1) ); 
   input_state = [P_hi, XR410a('h','Ps', P_hi, s)];
   
[P(2:5), T(2:5), h(2:5), abcissa(2:5)] ...
    = Condenser_Proc( input_state, strarg, m_dot, T_amb );

%---------
    input_state = [ P_lo; h(5)];

[P(6:9), T(6:9), h(6:9), abcissa(6:9)] ...
    = Evap_Proc(    input_state, m_dot, T_pod );

abcissa(6:9) = abcissa(6:9) + 1;
%----------------------------------------------------------------


s = 0*h;

for j = 1:numel(P)
    
    s(j) = XR410a('s','Ph', P(j), h(j) );
    
end

figure(1)
plot(abcissa, T, '-o')

figure(2)
plot( s, T, '-o'), hold on
DrawDome('T','s'), hold off

figure(3)
semilogy( h, P, '-o'), hold on
DrawDome('P','h'), hold off


