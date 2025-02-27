 function [P, T, h, abcissa] = Evap_Proc(input_state, flowrate, T_pod )


% Input state must be a row vector containing pressure 
% and enthalpy in that order
% input_state = [P, h]


% Artificial Input
airspeed = 2.5; %[m/s]

%
% Initialize Vars
%----------------------
P_in = input_state(1);
P    = P_in*[ 1; 1; 1; 1 ];
h    = 0*P;
T    = h;

abcissa = h;
dz_1 = 0;
dz_2 = 0;
dz_3 = 0;


%=========================================================================%
% set up us the properties
%
h_in  = input_state(2);
    
T_sat = SatLookupTP('T','P',P_in);
    
h_f   = SatLookupTP('hf','P',P_in);   
h_g   = SatLookupTP('hg','P',P_in);    
h_fg  = h_g - h_f;    


%=========================================================================%
% Calculate Vars
%

[UA_1, UA_3] = generate_HTCOEFF( P_in, flowrate, flowrate, airspeed, 'EVAP');

%Temporary
UA_g = UA_3;
UA_f = UA_1;

%Properties
c_p_g = SuperHT_Cp(T_sat)*1000;
c_p_f = SubCL_Cp(T_sat)*1000;

rho_g   = Ther_rho( P_in, 1, 'reg');
rho_f   = Ther_rho( P_in, 0, 'reg');
%rho_fg  = rho_f - rho_g; or rho_g - rho_f?
rho_rat = rho_g/rho_f;

%Vol Void Frac
x_in  = ( h_in - h_f )/h_fg;
gamma = 1/(1-rho_rat) + rho_rat/(rho_rat-1)^2/( 1 - x_in )*log( x_in - rho_rat*(x_in-1) );

UA_2 = UA_f*(1-gamma) + UA_g*(gamma);




%=========================================================================%
%
%  begin integration procedure, piecewise
%
%=

if h_in >= h_f  %There is no subcooled region

    dz_1 = 0;
% assign output
%----------------
    T(1) = T_sat;
    h(1) = h_in;
    T(2) = T_sat;
    h(2) = h_in;
%----------------

%Vol Void Frac
x_in  = ( h_in - h_f )/h_fg;
gamma = 1/(1-rho_rat) + rho_rat/(rho_rat-1)^2/( 1 - x_in )*log( x_in - rho_rat*(x_in-1) );

%Twophase region HT coeff
UA_2 = UA_f*(1-gamma) + UA_g*(gamma);



else %calculate subcooled region
%--- Subcooled-into-SatLiq Process ---

    T_in = T_sat + (h_in - h_f)/c_p_f*1000;

    dh_1 = h_f - h_in;
    dz_1 = ( c_p_f*flowrate/UA_1 )*log( (T_pod-T_in)/(T_pod-T_sat) );
    
    % assign output
%----------------
    T(1) = T_in;
    h(1) = h_in;
    T(2) = T_sat;
    h(2) = h_f;
%----------------

%Vol Void Frac
x_in  = 0;
gamma = 1/(1-rho_rat) + rho_rat/(rho_rat-1)^2/( 1 - x_in )*log( x_in - rho_rat*(x_in-1) );

%twophase region HT coeff.
UA_2 = UA_f*(1-gamma) + UA_g*(gamma);


end


%--- SatLiq-into-SatVap Process ---

dh_2 = h_g - h(2);
dz_2 = 1000*flowrate*dh_2/(UA_2*( T_pod - T_sat ));

    %Begin exception if saturation phase takes up the 
    %remainder of the HX domain
    if (dz_2) > (1 - dz_1)
        warning('Partial Evaporation')
        
        dz_2 = (1 - dz_1);
        %Solve system for dh_1 and gamma
        x_out = @(dh) ( dh + h(2) - h_f )/h_fg;
        
        f = @(var) [ ...
            dz_2*( T_pod-T_sat )*( UA_f + ( UA_g-UA_f )*var(1) ) - ( 1000*flowrate*var(2) );...
            ...
              ( x_out(var(2))-x_in )*( 1/(1-rho_rat) - var(1) ) - rho_rat/(rho_rat-1)^2*...
                    log( (rho_rat*( x_out(var(2))-1 ) - x_out(var(2)) )/...
                         (rho_rat*( x_in         -1 ) - x_in          ) ) ...
            ];
        
        b = fsolve( f, [gamma, h_fg/2]);
        %gamma = b(1);
        dh_2  = b(2);
        
        %-----------------
        % Produce Output
        %
            h_out = h_in + dh_2; 
        %
        % assign output
        %-----------------
            T(3) = T_sat;
            h(3) = h_out;
            T(4) = T_sat;
            h(4) = h_out;
        %-----------------


    %Otherwise go to superheat process  
    else
% assign output
%-----------------
    T(3) = T_sat;
    h(3) = h_g;
%-----------------      
        
        
        
%--- SatLiq-into-Subcool Process ---        

dz_3 = 1 - dz_2 - dz_1;

T_out = (T_sat-T_pod)*exp( -UA_3/(c_p_g*flowrate)*dz_3 ) + T_pod;
h_out = h_g + SuperHT_Cp_integral( T_sat, T_out );


% assign output
%-----------------
    T(4) = T_out;
    h(4) = h_out;
%-----------------
        
    end
    

% assign output
%-----------------------------------
    abcissa(2) = abcissa(1) + dz_1;
    abcissa(3) = abcissa(2) + dz_2;
    abcissa(4) = 1;
%-----------------------------------    
    



end