%% Initialize
format compact
format long
%clear all
close all

% Sim Param 
res = 50;
epsilon = 0.000001;

load param_2.mat
% Phys Param
%N      = 5000;
valve  = 0.8;
T_amb  = 40;
T_pod  = 17;
Q_load = 2.000;  %kJ
T_SH =    5;

% Init
P_c  = 3000;
P_e  =  850;

Vars_i  = [P_c; P_e];
Param_i = [ RPM, CA, valve, T_amb, T_pod, Q_load, T_SH, res  ]; 

%% Numerically Solve Steady State

%----------------------------------
% MODIFY PARAMS IF YOU WANT TO
%--
 Param_i(1) = 1.10*Param_i(1);
 Param_i(3) = 0.80;  %newparam;
%
%
%--

[hvec1,hpnt1,Pvec1,Ppnt1,Deficit_1] = make_cycle(Vars_i, Param_i);

    n = 9; %iterate this many times
    Var_hist = zeros(2,n+1); %track progress
    Def_hist = Var_hist;
    m_hist_v = zeros(1,n+1);
    m_hist_s = m_hist_v;
    nn     = [0:1:n];%initialize
    Vars_2 = Vars_i; 
    
    Var_hist(:,1) = Vars_2;
    Def_hist(:,1) = Deficit_1;
    m_hist_v(1) = valve_func( Param_i(2), Vars_i(1), Vars_i(2), Param_i(3) );
    m_hist_s(1) = compr_func( Vars_i(2), hpnt1(5), Param_i(1)  );
    
for j = 1:n
    disp(j);
    [ Vars_2, Deficit_2] = adjust_cycle(Vars_2, Param_i, epsilon);
    Var_hist(:,j+1) = Vars_2;
    Def_hist(:,j+1) = Deficit_2;
m_hist_v(j+1) = valve_func( Param_i(2), Vars_2(1), Vars_2(2), Param_i(3));
m_hist_s(j+1) = compr_func( Vars_2(2), hpnt1(5), Param_i(1)  );

end
[hvec2,hpnt2,Pvec2,Ppnt2,Deficit_2] = make_cycle(Vars_2, Param_i);

disp(datetime('now'))
disp('init. Deficit ')
disp(Deficit_1)
disp('final Deficit ')
disp(Deficit_2)

%Iteration path of the pressure state
figure(1)
plot(nn, Var_hist(1,:),'-o'), hold on
semilogy(nn, Var_hist(2,:),'-o'), hold off
xlabel('iterate')
ylabel('pressure (kPa)')
title('Iteration Path of State Vars')
legend('condensor press.','evaporator press.','location','west')
grid on

%Iteration Path of the Objective
figure(2)
plotyy(nn, Def_hist(1,:),nn, Def_hist(2,:)), 
xlabel('iterate')
ylabel('deficit')
title('Iteration Path of Objective')
legend('mass deficit (kg/s)','evap. energy deficit (kW)','location','northwest')
grid on

figure(3)
plot(nn, m_hist_v, '-o', nn, m_hist_s, '-o')
xlabel('iterate')
ylabel('flow (kg/s)')
title('Iteration Path of flowrates')
legend('valve','compressor','location','west')
grid on

figure(4)
%dome
DrawDome('P','h','type','semilogy'), hold on
%first pass
qwe1 = semilogy(hvec1,Pvec1,'-r','linewidth',2);
semilogy(hpnt1,Ppnt1,'or'), 
%second pass
qwe2 = semilogy(hvec2,Pvec2,'-b','linewidth',2);
semilogy(hpnt2,Ppnt2,'ob'), 
hold off
grid on
legend([qwe1,qwe2],{'Initial Iterate';'Final Iterate'},'location','southwest')
ylim([2E2, 1E4])

figure(5)
%dome
DrawDome('T','s','type','linear'), hold on
%draw cycle environment lines
env_c = T_amb*[1,1];
env_e = T_pod*[1,1];
sssss = [0.6, 2.2];
plot(sssss,env_e,'--c')
plot(sssss,env_c,'--m')
    %Convert to TS
        Tvec1 = 0*Pvec1;
        svec1 = Tvec1;
        Tvec2 = Tvec1;
        svec2 = Tvec1;
        Tpnt1 = 0*Ppnt1;
        spnt1 = Tpnt1;
        Tpnt2 = Tpnt1;
        spnt2 = Tpnt1;
    for j = 1:numel(hvec1)
        Tvec1(j) = XR410a('T','Ph', Pvec1(j), hvec1(j) );
        svec1(j) = XR410a('s','Ph', Pvec1(j), hvec1(j) );
        Tvec2(j) = XR410a('T','Ph', Pvec2(j), hvec2(j) );
        svec2(j) = XR410a('s','Ph', Pvec2(j), hvec2(j) );
    end
    for j = 1:numel(hpnt1)
        Tpnt1(j) = XR410a('T','Ph', Ppnt1(j), hpnt1(j) );
        spnt1(j) = XR410a('s','Ph', Ppnt1(j), hpnt1(j) );
        Tpnt2(j) = XR410a('T','Ph', Ppnt2(j), hpnt2(j) );
        spnt2(j) = XR410a('s','Ph', Ppnt2(j), hpnt2(j) );
    end
%first pass
pwe1 = plot(svec1,Tvec1,'-r','linewidth',2);
plot(spnt1,Tpnt1,'or'), 
%second pass
pwe2 = plot(svec2,Tvec2,'-b','linewidth',2);
plot(spnt2,Tpnt2,'ob'), 
hold off
grid on
legend([pwe1,pwe2],{'Initial Iterate';'Final Iterate'},'location','southwest')
ylim([-15, 80])

m_dot_v = valve_func( CA, Vars_2(1), Vars_2(2), Param_i(3));
m_dot_s = compr_func( Vars_2(2), hpnt2(5), Param_i(1)  );
cp      = SuperHT_Cp( SatLookupTP( 'T', 'P', Vars_2(2) ) );
hg      = SatLookupTP('hg','P', Vars_2(2) );

fprintf(' \n')
fprintf('|Compresser Speed:       %d  (rpm)  \n', Param_i(1) )
fprintf('|Valve Opening:          %d  ( )    \n', Param_i(3) )
fprintf('------------------------ ------------- ------- \n' )
fprintf('|Mass Deficit:           %d  (kg/s) \n', Deficit_2(1) )
fprintf('|Mass Flow Rate, V:      %d  (kg/s) \n', m_dot_v)
fprintf('|Mass Flow Rate, S:      %d  (kg/s) \n', m_dot_s)
fprintf('|Heat Deficit:           %d  (kW)   \n', Deficit_2(2) )
fprintf('|Evap Heat Transfer, V:  %d  (kW)   \n', m_dot_v*(hpnt2(5)-hpnt2(4)) )
fprintf('|Evap Heat Transfer, S:  %d  (kW)   \n', m_dot_s*(hpnt2(5)-hpnt2(4)) )
fprintf('|Evap Superheat: DT =    %d  (*C)   \n', (cp^(-1))*(hpnt2(5)-hg) )
fprintf('------------------------ ------------- ------- \n' )


