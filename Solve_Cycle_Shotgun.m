%% Initialize

%-------------------------------------------------------------
%-- Uncomment this section to test code for a select input ---
%-------------------------------------------------------------
% format compact
% format short
% clear all
% close all
% 
% load param_4.mat
% % Phys Param
% %N     = 5000;
% T_SH  = 5;
% T_amb  = 25;
% T_pod  = 17;


Q_load = 2.000;  %kJ

Inputs    = [ Q_load; T_SH; T_amb; T_pod  ];
Param     = [    RPM, CA ]; 

% Adjust

SPREAD = 2;

%Var Extents
lb(1) = SatLookupTP('P','T', T_amb);
ub(1) = 4100;
lb(2) = 500;
ub(2) = SatLookupTP('P','T', T_pod);

%Starting points
P_c   = lb(1) + ( ub(1)-lb(1) )*linspace( 0.35, 0.65, SPREAD);
P_e   = lb(2) + ( ub(2)-lb(2) )*linspace( 0.40, 0.70, SPREAD);
init_valve  = 0.8;

[C,E] = meshgrid( P_c, P_e );

%Initialize Vars and Deficits
nor_Deficit = zeros( SPREAD^2, 1);
Deficit     = zeros( 3, SPREAD^2 );
Vars        = Deficit;

for k = 1:SPREAD^2
    %Make init cycle
    p = 1 + mod(k-1,SPREAD);
    q = 1 + floor((k-1)/SPREAD);
    %fprintf(' %g:: ( %g, %g )\n',k,p,q)
    Vars(1,k) = C(p,q);
    Vars(2,k) = E(p,q);
    Vars(3,k) = init_valve;
    
    %Step Vars Forward
    [Vars(:,k), Objective] = adjust_cycle_fmin( Vars(:,k), Inputs, Param );


end
%%
%Did converge?
k = find( Objective == min(Objective), 1 );
Vars    = Vars(:,k);

%Run Again
[Vars, Objective] = adjust_cycle_fmin( Vars, Inputs, Param );

%Calc
[ P, T, h, abcissa, m_dot, Q_L, Q_H, W, Deficit] = ...
        make_cycle(Vars, Inputs, Param);

converged = 1;
if ( norm(Deficit) > 0.03 )
    converged = 0;
    fprintf('Warning: |Deficit| = %f.  \n', norm(Deficit));
end
% %%
% figure(1)
% %TSdiag
% s = 0*h;
%     for j = 1:numel(P)
%         s(j) = XR410a('s','Ph', P(j), h(j) ); 
%     end
% plotcycle_TS( T, s, 'T_env',T_amb,T_pod,'cyclecolor','r','stationlabels');