
function [UA_g,UA_f] = generate_HTCOEFF(P, m_dot_g, m_dot_f, V_extr, subsys)

%Table lookup uses kPa

if strcmp(subsys, 'EVAP')
    
%Interior (refrigerant side)

D_i     = 6.1595/1000;      %[m]
    n_tubes = 78;
    L       = 0.35482; 
A_i     = pi*D_i*n_tubes*L; %[m2]

%Pipe Wall

    d_o = 7.9375/1000;  %[m]
    k_Al= 205;          %[W/m-K]
    
R_tw    = log(d_o/D_i)/(2*pi*k_Al*n_tubes*L); %[K/W]

%Exterior (air side)
 
    f_pitch = 750;         %[fpm]
    f_thc   = 0.15/1000;   %[m]
    t_pitch = 0.01080;     %[m] tube pitch center-to-center
    cell_h  = t_pitch - d_o;
    cell_l  = f_pitch^-1 - f_thc;
    
     
D_h_o   = 4*( cell_h*cell_l )/(2*cell_h + 2*cell_l); %[m]      %effective hydraulic diam
% D_h_o   = 0.0017; %[m]      %effective hydraulic diam
A_a     = 3.5606; %[m2] %Heat transfer area airside

%V_extr = 2.5; %[m/s]

%Need Adjusted airspeed based on obstructed area

adjspeed = V_extr*( ( (t_pitch)*(cell_l + f_thc))/(cell_l*cell_h) );

%-------------------------------------------------------------------------%
% Refrigerant Constants (R410a) 
%-------------------------------------------------------------------------%

k_f  = 0.104;    %[W/m-K] 
k_g  = 0.0133;    %[W/m-K] 
mu_f = 151E-6;  %[Pa-s] 
mu_g = 13.2E-6;  %[Pa-s]
c_p_f = SubCL_Cp( SatLookupTP( 'T', 'P', P ) );   %[kJ/kg-K] 
c_p_g = SuperHT_Cp( SatLookupTP( 'T', 'P', P ) );   %[kJ/kg-K]           

%-------------------------------------------------------------------------%
% Air Constants (R134a) 
%-------------------------------------------------------------------------%

k_a   = 0.0262;   %[W/m-K]   
mu_a  = 1.846E-5; %[Pa-s]   
rho_a = 1.127;    %[kg/m3] 
c_a   = 1.0049;   %[kJ/kg-K]


%-------------------------------------------------------------------------%
% Derived Relations
%-------------------------------------------------------------------------%


%HT-coefficient, contribution from airside and pipe wall     
Re_a    = rho_a*adjspeed*D_h_o/mu_a;
Pr_a    = c_a*mu_a/k_a*1000;                   %Factor of 1000 changes units
Nu_a    = Circular_Duct_Nu( Re_a, Pr_a, 'h' );
h_a     = k_a*Nu_a/D_h_o;

%Fin efficiency
fin_eff = 0.92;

addcnst = A_i*R_tw + A_i/(h_a*fin_eff*A_a);



%HT-coefficient, gaseous, contribution from refrigerant side
Re_g  =  4*m_dot_g./(pi*D_i*mu_g);
Pr_g  =  c_p_g*mu_g/k_g*1000;                %Factor of 1000 changes units
Nu_g  =  Circular_Duct_Nu( Re_g, Pr_g, 'c' );  %Needs considerations for boiling
h_i_g =  k_g*Nu_g/D_i;


%HT-coefficient, liquid, contribution from refrigerant side
Re_f  =  4*m_dot_f./(pi*D_i*mu_f);
Pr_f  =  c_p_f*mu_f/k_f*1000;                %Factor of 1000 changes units
Nu_f  =  Circular_Duct_Nu( Re_f, Pr_f, 'c' );  %Needs considerations for boiling
h_i_f =  k_f*Nu_f/D_i;


%Local overall heat transfer coefficient
U_g = ( 1./h_i_g + addcnst ).^-1;
U_f = ( 1./h_i_f + addcnst ).^-1;

%Output UA
UA_g = U_g*A_i;
UA_f = U_f*A_i;


%U = 0.5*( U_g + U_f );



elseif strcmp(subsys, 'COND')
    
%Interior (refrigerant side)

D_i     = 2.9972/1000; %[m]
    n_tubes = 21;
    L       = 0.3556; 
A_i     = pi*D_i*n_tubes*L; %[m2]

%Pipe Wall

    d_o = 4.7625/1000; %[m]
    k_Al= 205;          %[W/m-K]
    
R_tw    = log(d_o/D_i)/(2*pi*k_Al*n_tubes*L); %[K/W]

%Exterior (air side)
 
    f_pitch = 600;         %[fpm]
    f_thc   = 0.15/1000;   %[m]
    cell_h  = 0.012 - d_o;
    cell_l  = f_pitch^-1 - f_thc;
    
     
D_h_o   = 4*(cell_l*cell_h)/( 2*cell_l + 2*cell_h ); %[m]      %effective hydraulic diam
A_a     = 1.23; %[m2] %Heat transfer area


%Need Adjusted airspeed based on obstructed area

adjspeed = V_extr*( (0.012*(cell_l + f_thc))/(cell_l*cell_h) );


% % % UA = 117;  %[W/K] %kill this


%-------------------------------------------------------------------------%
% Refrigerant Constants (R410a) 
%-------------------------------------------------------------------------%

k_f  = 0.0749;    %[W/m-K] 
k_g  = 0.0315;    %[W/m-K] 
mu_f = 70.4E-6;  %[Pa-s] 
mu_g = 19.4E-6;  %[Pa-s]
c_p_f = SubCL_Cp( SatLookupTP( 'T', 'P', P ) );   %[kJ/kg-K] 
c_p_g = SuperHT_Cp( SatLookupTP( 'T', 'P', P ) );   %[kJ/kg-K]  

         
%-------------------------------------------------------------------------%
% Air Constants (R134a) 
%-------------------------------------------------------------------------%

k_a   = 0.0262;   %[W/m-K] 
mu_a  = 1.846E-5; %[Pa-s] 
rho_a = 1.127;    %[kg/m3]
c_a   = 1.0049;   %[kJ/kg-K]


%-------------------------------------------------------------------------%
% Derived Relations
%-------------------------------------------------------------------------%



%HT-coefficient, contribution from airside and pipe wall     
Re_a    = rho_a*adjspeed*D_h_o/mu_a;
Pr_a    = c_a*mu_a/k_a*1000;                   %Factor of 1000 changes units
Nu_a    = Circular_Duct_Nu( Re_a, Pr_a, 'c' );
h_a     = k_a*Nu_a/D_h_o;

%Fin efficiency
fin_eff = 0.95;

addcnst = A_i*R_tw + A_i/(h_a*fin_eff*A_a);



%HT-coefficient, gaseous, contribution from refrigerant side
Re_g  =  4*m_dot_g./(pi*D_i*mu_g);
Pr_g  =  c_p_g*mu_g/k_g*1000;                %Factor of 1000 changes units
Nu_g  =  Circular_Duct_Nu( Re_g, Pr_g, 'h' );  %Needs considerations for boiling
h_i_g =  k_g*Nu_g/D_i;


%HT-coefficient, liquid, contribution from refrigerant side
Re_f  =  4*m_dot_f./(pi*D_i*mu_f);
Pr_f  =  c_p_f*mu_f/k_f*1000;                %Factor of 1000 changes units
Nu_f  =  Circular_Duct_Nu( Re_f, Pr_f, 'h' );  %Needs considerations for boiling
h_i_f =  k_f*Nu_f/D_i;


%Local overall heat transfer coefficient
U_g = ( 1./h_i_g + addcnst ).^-1;
U_f = ( 1./h_i_f + addcnst ).^-1;
    
  
%Output UA
UA_g = U_g*A_i;
UA_f = U_f*A_i;

else 
    error('IDK what this %s subsystem is', subsys)
end




end

