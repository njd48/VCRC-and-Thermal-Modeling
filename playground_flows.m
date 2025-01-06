%% Initialize
format compact
format long
clear all

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


%% manually find pressure levels

nRPM = RPM;
g = @(e,t) SatLookupTP('hg','P',e) + SuperHT_Cp(SatLookupTP('T','P',e))*t;
lmnop = @(e,t) compr_func( e, g(e,t),  nRPM);
f = @(c,e,x) valve_func( CA, c, e, x) - compr_func( e, g(e,T_SH), nRPM);


E = [750:5:1200]';
%balves = valve*[0.95;1;1.05];
balves = [0.74;0.76;0.8;0.84];
C = cell(1,numel(balves));
res = C;
M1  = C;
M2  = C;
L1  = C;
% L2  = C;
L3  = cell(1,2*numel(balves));

symb = '.o+*vvvv';

for i = 1:numel(balves)
    C{i} = 0*E;
    res{i} = C{i};
    M1{i} = C{i};
    M2{i} = C{i};
    for j = 1:numel(E) 
        h      = @(c) 1000*f( c, E(j), balves(i) ); 
        C{i}(j)  = fsolve( h, P_c);
        res{i}(j)  = h(C{i}(j))/1000;
    end
    L1{i}     =  ['valve opening, x = ',num2str(balves(i),3)];
    L3{2*i-1} =  ['valve flow, x = ',num2str(balves(i),3)];
    L3{2*i}   =  ['compr. flow, x = ',num2str(balves(i),3)];
    
        T_sat_c = 0*E;
        T_sat_e = T_sat_c;
    for j = 1:numel(E)
        T_sat_c(j) = SatLookupTP( 'T', 'P', C{i}(j));
        T_sat_e(j) = SatLookupTP( 'T', 'P', E(j));
    end
    j_c = find( T_sat_c >= 40, 1);
    %j_e = find( T_sat_e >   7, 1);
    x       = [min(E),max(E)];
    %y       = [min(C),max(C)];
    Pline_c = C{i}(j_c)*[1,1];
    %Pline_e = E(j_e)*[1,1];
    
    
figure(1)
    plot( E, C{i},[symb(i),'-']), hold on
    %plot( x, Pline_c, '-^')
    %plot( Pline_e, y, '->')
    %hold off
    
    M1{i} = valve_func( CA, C{i}, E, balves(i)); 
    M2{i} = 0*M1{i};
    for j = 1:numel(E)
        M2{i}(j) = lmnop( E(j), T_SH);
    end
figure(2)    
    semilogy( E, abs(res{i})./M1{i}, [symb(i),'-']) , hold on
    title('Normalized Resudual: |m_{valve}-m_{compr}|')
    %hold off
    
figure(3)    
    plot( E, M1{i}, [symb(i),'-']), hold on
    plot( E, M2{i}, [symb(i+numel(balves)),'-'])
    %hold off
    

end

figure(1)
hold off
grid on
xlabel('Evap Press (kPa)')
ylabel('Conds Press (kPa)')
title('Steady Mass Manifold')
legend( L1, 'location','northwest')

figure(2)
hold off
grid on
legend( L1,'location','southeast')
xlabel('Evap Press (kPa)')
% figure(7)
% %dome
% DrawDome('T','s','type','linear'), hold on
%     %Convert to TS
%         Tvec1 = 0*Pvec1;
%         svec1 = Tvec1;
%         Tvec2 = Tvec1;
%         svec2 = Tvec1;
%         Tpnt1 = 0*Ppnt1;
%         spnt1 = Tpnt1;
%         Tpnt2 = Tpnt1;
%         spnt2 = Tpnt1;
%     for j = 1:numel(hvec1)
%         Tvec1(j) = XR410a('T','Ph', Pvec1(j), hvec1(j) );
%         svec1(j) = XR410a('s','Ph', Pvec1(j), hvec1(j) );
%         Tvec2(j) = XR410a('T','Ph', Pvec2(j), hvec2(j) );
%         svec2(j) = XR410a('s','Ph', Pvec2(j), hvec2(j) );
%     end
%     for j = 1:numel(hpnt1)
%         Tpnt1(j) = XR410a('T','Ph', Ppnt1(j), hpnt1(j) );
%         spnt1(j) = XR410a('s','Ph', Ppnt1(j), hpnt1(j) );
%         Tpnt2(j) = XR410a('T','Ph', Ppnt2(j), hpnt2(j) );
%         spnt2(j) = XR410a('s','Ph', Ppnt2(j), hpnt2(j) );
%     end
% %first pass
% pwe1 = plot(svec1,Tvec1,'-r','linewidth',2);
% plot(spnt1,Tpnt1,'or'), 
% %second pass
% pwe2 = plot(svec2,Tvec2,'-b','linewidth',2);
% plot(spnt2,Tpnt2,'ob'), 
% hold off
% grid on
% legend([pwe1,pwe2],{'Initial Iterate';'Final Iterate'},'location','southwest')
% %ylim([2E2, 1E4])
% 
% ylabel('m/m_{v}')
% title('Normalized resudial : |m_{valve} - m_{compr}|')
% 
% ylim([ 10^floor(min(log10(abs(res{i})./M1{i}))), 2 ] )

figure(3)
hold off
grid on
xlabel('Evap Press (kPa)')
ylabel('flowrate (kg/s)')
title('Flowrates')

legend( L3, 'location','southeast')



%% First attempt to adjust pressures

[hvec1,hpnt1,Pvec1,Ppnt1,Deficit_1] = make_cycle(Vars_i, Param_i);

    n = 3; %adjust this many times
    Var_hist = zeros(2,n+1); %track progress
    Def_hist = Var_hist;
    Vars_2 = Vars_i; %initialize
    Var_hist(:,1) = Vars_2;
    Def_hist(:,1) = Deficit_1;
for j = 1:n
    disp(j);
    [ Vars_2, Deficit_2] = adjust_cycle(Vars_2, Param_i, epsilon);
    Var_hist(:,j+1) = Vars_2;
    Def_hist(:,j+1) = Deficit_2;
end
[hvec2,hpnt2,Pvec2,Ppnt2,Deficit_2] = make_cycle(Vars_2, Param_i);

disp(datetime('now'))
disp('init. Deficit ')
disp(Deficit_1)
disp('final Deficit ')
disp(Deficit_2)

figure(4)
plot(Var_hist(1,:),'-o'), hold on
semilogy(Var_hist(2,:),'-o'), hold off
xlabel('iterate')
ylabel('pressure (kPa)')
title('Iteration Path of State Vars')
legend('condensor press.','evaporator press.')
grid on

figure(5)
plot(Def_hist(1,:),'-o'), hold on
semilogy(Def_hist(2,:),'-o'), hold off
xlabel('iterate')
ylabel('deficit')
title('Iteration Path of Objective')
legend('mass deficit','evap. energy deficit')
grid on

figure(6)
%dome
DrawDome('P','h','type','semilogy'), hold on
%first pass
qwe1 = plot(hvec1,Pvec1,'-r','linewidth',2);
plot(hpnt1,Ppnt1,'or'), 
%second pass
qwe2 = plot(hvec2,Pvec2,'-b','linewidth',2);
plot(hpnt2,Ppnt2,'ob'), 
hold off
grid on
legend([qwe1,qwe2],{'Initial Iterate';'Final Iterate'},'location','southwest')
ylim([2E2, 1E4])

figure(7)
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


%% Without adjusting pressures
%first pass
[hvec1,hpnt1,Pvec1,Ppnt1,Deficit_1] = make_cycle(Vars_i, Param_i);

%second pass
Param2  = Param_i;
h_5     = hpnt1(end);
T_5     = XR410a('T','Ph', P_e, h_5);
T_sat_e = SatLookupTP('T','P',P_e);
T_SH_2  = T_5 - T_sat_e;
Param2(end-1) = T_SH_2;

[hvec2,hpnt2,Pvec2,Ppnt2,Deficit_2] = make_cycle(Vars_i, Param2);

%asymptotic pass
Param3 = Param2;
hpnt3  = hpnt2;
n=1;
while n <=10
    h_5     = hpnt3(end);
    T_5     = XR410a('T','Ph', P_e, h_5);
    T_sat_e = SatLookupTP('T','P',P_e);
    T_SH_3  = T_5 - T_sat_e;
    Param3(end-1) = T_SH_3;

    [hvec3,hpnt3,Pvec3,Ppnt3,Deficit3] = make_cycle(Vars_i, Param3);
    %evolution
    figure(2)
    DrawDome('P','h','type','semilogy'), hold on
    plot(hvec3,Pvec3,'-g','linewidth',2)
    plot(hpnt3,Ppnt3,'og'), 
    title(['n = ',num2str(n)])
    hold off
    grid on
    drawnow;
    n=n+1;
end

figure(3)
%dome
DrawDome('P','h','type','semilogy'), hold on
%first pass
plot(hvec1,Pvec1,'-r','linewidth',2)
plot(hpnt1,Ppnt1,'or'), 
%second pass
plot(hvec2,Pvec2,'-b','linewidth',2)
plot(hpnt2,Ppnt2,'ob'), 
%asymptotic pass
plot(hvec3,Pvec3,'-g','linewidth',2)
plot(hpnt3,Ppnt3,'og'), 

hold off
grid on

%%
