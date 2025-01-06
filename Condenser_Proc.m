 function [P, T, h, abcissa] = Condenser_Proc(input_state, strarg, flowrate, T_amb )


% Input state must be a row vector containing pressure 
% and enthalpy in that order
% input_state = [P, h]

% Input state could be a row vector containing pressure 
% and temperature in that order
% input_state = [P, T]


%Artificial Input
airspeed = 20;


%Initialize Vars
%----------------------
P_in = input_state(1);
P    = P_in*[ 1; 1; 1; 1];
h    = 0*P;
T    = h;

abcissa = h;
dz_1 = 0;
dz_2 = 0;
dz_3 = 0;

%=========================================================================%
% set up us the properties
%

P_in = input_state(1);

if strcmp(strarg, 'h')
    
    h_in  = input_state(2);
    T_sat = SatLookupTP('T','P',P_in);
    h_f   = SatLookupTP('hf','P',P_in);
    h_g   = SatLookupTP('hg','P',P_in);
    h_fg  = h_g - h_f;    

    T_in  = fsolve( @(t)(h_in-h_g) - SuperHT_Cp_integral(T_sat, t), T_sat+1);
    
    
    % assign output
    %----------------
        T(1) = T_in;
        h(1) = h_in;
    %----------------
    
elseif strcmp(strarg, 'T')
    
    T_in  = input_state(2);
    T_sat = SatLookupTP('T','P',P_in);
    h_f   = SatLookupTP('hf','P',P_in);
    h_g   = SatLookupTP('hg','P',P_in);
    h_fg  = h_g - h_f;
    
    h_in  = h_g + SuperHT_Cp_integral(T_sat, T_in);
    
    
    % assign output
    %----------------
        T(1) = T_in;
        h(1) = h_in;
    %----------------
    
else
    error('dont recognize input property ''%s'' ', strarg)
end



%=========================================================================%
% Calculate Vars
%

[UA_1, UA_3] = generate_HTCOEFF( P_in, flowrate, flowrate, airspeed, 'COND');

%Temporary
UA_g = UA_1;
UA_f = UA_3;

%Properties
c_p_g = 0.5*( SuperHT_Cp(T_sat) + SuperHT_Cp(T_in) )*1000;
c_p_f = SubCL_Cp(T_sat)*1000;

rho_g   = Ther_rho( P_in, 1, 'reg');
rho_f   = Ther_rho( P_in, 0, 'reg');
%rho_fg  = rho_f - rho_g; or rho_g - rho_f?
rho_rat = rho_g/rho_f;

%Vol Void Frac
gamma = 1/(1-rho_rat) + rho_rat/(rho_rat-1)^2*log( rho_rat );

UA_2 = UA_f*(1-gamma) + UA_g*(gamma);




%=========================================================================%
%
%  begin integration procedure, piecewise
%
%=

%--- Superheat-into-Saturation Process ---

dz_1 = c_p_g*flowrate/UA_1*log( (T_amb-T_in)/(T_amb-T_sat) );

    %Add exception if superheated phase takes up the
    %entire HX domain
    if (dz_1 > 1)
        T = NaN;
        h = NaN;
        P = NaN;
        abcissa = NaN;
        error('no exception when superheated phase takes up entire domain')
    %else
    end
    
% assign output
%-----------------
    T(2) = T_sat;
    h(2) = h_g;
%-----------------
    
    
%--- SatVap-into-SatLiq Process ---

dz_2 = 1000*flowrate*h_fg/(UA_2*(T_sat - T_amb));

    %Begin exception if saturation phase takes up the 
    %remainder of the HX domain
    if (dz_1 + dz_2) > 1

        dz_2   = 1 - dz_1;
        
        %solve system 
        %gamma and delta_h are the variables\
        x = @(dh) ( dh + h_fg )/h_fg; % % % x(var(2))
        f = @( var ) ...
            [ dz_2*( T_amb-T_sat )*( UA_f + ( UA_g-UA_f )*var(1) ) - ( 1000*flowrate*var(2) ) ;...
            ...
              ( 1-x(var(2)) )*( 1/(1-rho_rat) - var(1) ) + rho_rat/(rho_rat-1)^2*...
                    log( rho_rat + (1-rho_rat)*x(var(2)) )  ...
            ];
        
        b = fsolve( f, [gamma, -h_fg] );
        %gamma = b(1);
        dh_2  = b(2);
        
        %-----------------
        % Produce Output
        %
            h_out = h_g + dh_2;
        %
        % assign output
        %-----------------
            T(3) = T_sat;
            h(3) = h_out;
            T(4) = T(3);
            h(4) = h(3);
        %-----------------
        
    %Otherwise go to subcool process  
    else
        
% assign output
%-----------------
    T(3) = T_sat;
    h(3) = h_f;
%-----------------      
        
        
        
%--- SatLiq-into-Subcool Process ---        

dz_3 = 1 - dz_1 - dz_2;

T_out = (T_sat-T_amb)*exp( -UA_3/(c_p_f*flowrate)*dz_3 ) + T_amb;
h_out = h_f + c_p_f/1000*(T_out-T_sat);


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