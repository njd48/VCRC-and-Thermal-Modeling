 function [P, h, abcissa] = Evaporator_Dynamics_Ph(input_state, flowrate, T_amb, resolution)

% Input state must be a row vector containing pressure 
% and enthalpy in that order
% input_state = [P, h]

%=========================================================================%

P    = input_state(1);

%-------------------------------------------------------------------------%
% Design Parameters 
%-------------------------------------------------------------------------%

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

airspeed = 2.5; %[m/s]

%Need Adjusted airspeed based on obstructed area

adjspeed = airspeed*( ( (t_pitch)*(cell_l + f_thc))/(cell_l*cell_h) );




%-------------------------------------------------------------------------%
% Refrigerant Constants (R410a) 
%-------------------------------------------------------------------------%

kf  = 0.104;    %[W/m-K] 
kg  = 0.0133;    %[W/m-K] 
muf = 151E-6;  %[Pa-s] 
mug = 13.2E-6;  %[Pa-s]

hf  = SatLookupTP('hf','P', P); %[kJ/kg]
hg  = SatLookupTP('hg','P', P); %[kJ/kg]

%T_sat = SatLookupTP( 'T', 'P', P );
c_p_f = 2.9900;   %[kJ/kg-K] 
c_p_g = 0.7875;   %[kJ/kg-K]  

         

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



%Two-Phase Conductivity, function of enthalpy
k  = @(h)  (h<hf)*kf  + (h>hg)*kg  + ( (hf <= h)&(h <= hg) ).*...
             ( kg*(h-hf)/(hg-hf)  + kf*(hg-h)/(hg-hf) ) ;
         
%Two-Phase Viscosity, function of enthalpy
mu = @(h)  (h<hf)*muf + (h>hg)*mug + ( (hf <= h)&(h <= hg) ).*...
             ( mug*(h-hf)/(hg-hf) + muf*(hg-h)/(hg-hf) ) ;

%Specific Heat function wut?
c_p = @(h) (h<hf)*c_p_f + (h>hg)*c_p_g + ( (hf <= h)&(h <= hg) ).*...
             ( c_p_g*(h-hf)/(hg-hf) + c_p_f*(hg-h)/(hg-hf) ) ;



%HT-coefficient, contribution from airside and pipe wall     
Re_a    = rho_a*adjspeed*D_h_o/mu_a;
Pr_a    = c_a*mu_a/k_a*1000;                   %Factor of 1000 changes units
Nu_a    = Circular_Duct_Nu( Re_a, Pr_a, 'h' );
h_a     = k_a*Nu_a/D_h_o;

%Fin efficiency
fin_eff = 0.92;

addcnst = A_i*R_tw + A_i/(h_a*fin_eff*A_a);



%HT-coefficient, contribution from refrigerant side
Re  = @(h) 4*flowrate./(pi*D_i*mu(h));
Pr  = @(h) c_p(h).*mu(h)./k(h)*1000;                %Factor of 1000 changes units
Nu  = @(h) Circular_Duct_Nu( Re(h), Pr(h), 'c' );
h_i = @(h) k(h).*Nu(h)/D_i;



%Local overall heat transfer coefficient
U = @(h) ( 1./h_i(h) + addcnst ).^-1;

% Temperature lookup

T = @(h) XR410a( 'T', 'Ph', P, h );


%forcing function
q_forcing = @(h)  U(h)*A_i*( T_amb - T(h) )/flowrate/1000; 
%Factor of 1000 changes units, as h is in kJ/kg


%=========================================================================%

%-------------------------------------------------------------------------%
% Integration routine follows
%-------------------------------------------------------------------------%


dx   = 1/( resolution - 1 );

h    = zeros(resolution, 1);
h(1) = input_state(2);

abcissa = [0:dx:1];


for j = 1:(resolution-1)
    
   q1  = q_forcing( h(j) );
   q2  = q_forcing( h(j) + dx*q1/2 );
   q3  = q_forcing( h(j) + dx*q2/2 );
   q4  = q_forcing( h(j) + dx*q3   );
   
   h(j+1) = h(j) + dx/6*( q1 + 2*q2 + 2*q3 + q4  );
    
end

%=========================================================================%
   P = input_state(1)*ones(resolution, 1);

        


end