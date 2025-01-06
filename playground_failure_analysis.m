

load failstate_1.mat

n = numel(Var_hist(1,:));
nn     = [0:1:n-1];%initialize

for k = 1:n
    
[hvec,hpnt,Pvec,Ppnt,Deficit] = make_cycle(Var_hist(:,k), Param_i);


figure(3)
%dome
DrawDome('P','h','type','semilogy'), hold on
semilogy(hvec,Pvec,'-b','linewidth',2);
semilogy(hpnt,Ppnt,'ob'), 
hold off
grid on
ylim([2E2, 1E4])
title(['iterate ',num2str(k)])
drawnow;

figure(4)
%dome
DrawDome('T','s','type','linear'), hold on
%draw cycle environment lines
env_c = T_amb*[1,1];
env_e = T_pod*[1,1];
sssss = [0.6, 2.2];
plot(sssss,env_e,'--c')
plot(sssss,env_c,'--m')
    %Convert to TS

        Tvec = 0*Ppnt;
        svec = Tvec;
        Tpnt = 0*Ppnt;
        spnt = Tpnt;
    for j = 1:numel(hvec1)
        Tvec(j) = XR410a('T','Ph', Pvec(j), hvec(j) );
        svec(j) = XR410a('s','Ph', Pvec(j), hvec(j) );
    end
    for j = 1:numel(hpnt1)
        Tpnt(j) = XR410a('T','Ph', Ppnt(j), hpnt(j) );
        spnt(j) = XR410a('s','Ph', Ppnt(j), hpnt(j) );
    end
plot(svec,Tvec,'-r','linewidth',2);
plot(spnt,Tpnt,'or'), 
hold off
grid on
title(['iterate ',num2str(k)])
drawnow;

pause(0.5)


m_dot_v(k) = valve_func( Param_i(2), Var_hist(1,k), Var_hist(2,k), Param_i(3));
m_dot_s(k) = compr_func( Var_hist(2,k), hpnt(5), Param_i(1)  );


end


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



figure(5)
plot(nn, m_dot_v, '-o', nn, m_dot_s, '-o')
xlabel('iterate')
ylabel('flow (kg/s)')
title('Iteration Path of flowrates')
legend('valve','compressor','location','west')
grid on
