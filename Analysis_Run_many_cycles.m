format compact
format short
clear all
close all

%Put up Inputs
T_amb_vec = [   5 :   5 :  40 ];
T_SH      = 5;
%valve_vec = [ 0.5 : 0.1 :   1 ];

I = numel(T_amb_vec);
J = numel(T_SH);

load param_4.mat
T_pod  = 17;     % *C
Q_load = 2.000;  % kJ

%Initialize Outputs
Accur     = zeros(I,J);
Props     =  cell(I,J);
valve     = zeros(I,J);
flow      = zeros(I,J);
Evap_HT   = zeros(I,J);
Cond_HT   = zeros(I,J);
Compr_W   = zeros(I,J);
NormedErr = zeros(I,J);

for i = 1:I
    for j = 1:J
    % ----/
    % ---/
    % --| Supply Inputs |-----------------------------------\
        T_amb     = T_amb_vec(i);
        % T_SH = T_SH
        Inputs    = [ Q_load; T_SH; T_amb; T_pod  ];
        Param     = [    RPM, CA ]; 
        
    % --| Calculate     |-----------------------------------|
    %     ensure inputs are commented out in this script
        run Solve_Cycle_Shotgun  
        figure(1)
        loadingbar( J*(i-1) + j, I*J)
    % --| Record        |-----------------------------------|
    % [P, T, h, abcissa, m_dot, Q_L, Q_H, W, Deficit]
    % --| ------------- |-----------------------------------|
        Accur(i,j)      = converged;
        Props{i,j}      =[P,T,h,abcissa];
        valve(i,j)      = Vars(3);
        flow(i,j)       = m_dot;
        Evap_HT(i,j)    = Q_L;
        Cond_HT(i,j)    = Q_H;
        Compr_W(i,j)    = W;
        NormedErr(i,j)  = norm(Deficit);
        
    % --| ------------- |-----------------------------------/
    % ---\
    % ----\
    end
end

save('SimData.mat','T_amb_vec','T_SH','Accur',...
         'Props','valve','flow','Evap_HT','Cond_HT',...
         'Compr_W','NormedErr')
     
%% Analysis

load SimData.mat

wav = @(x) 0.5 + 0.5*cos(2*pi*x);
rgb_func = @(x) ...
         [ heaviside(0.5 -x).*wav(x),...
           heaviside(x -0.5).*wav(x),...
           (1-wav(x)).*exp(-25*(x-0.5).^2) ];
 
I    = numel(T_amb_vec);
J    = numel(T_SH);    
LEG = cell(J,1);

figure(1)
plot(T_amb_vec,NormedErr)
xlabel('T_{amb} (*C)')
ylabel(' error ')
title('Normed Normalized Error')


% j1 = 0*T_amb_vec;
% j2 = j1;
Del_P = T_SH;
for i = 1:I
    for j = 1:J
        Del_P(i,j)= Props{i,j}(2,1)-Props{i,j}(1,1);
        if ~Accur(i,j)
            Props{i,j}      = NaN(1,4);
            valve(i,j)      = NaN;
            flow(i,j)       = NaN;
            Evap_HT(i,j)    = NaN;
            Cond_HT(i,j)    = NaN;
            Compr_W(i,j)    = NaN;
            %T_SH(i,j)       = NaN;
            Del_P(i,j)      = NaN;
        end
    end
%     j1(i) = find( Accur(i,:), 1, 'first');
%     j2(i) = find( Accur(i,:), 1, 'last');
end


figure(2)
subplot(2,1,1)
    yyaxis left
        plot(T_amb_vec,valve,'-o')
        ylabel('valve opening: x')
    hold on
    yyaxis right
        plot(T_amb_vec,sqrt(Del_P),'-o')
        ylabel('(\Delta P)^{1/2} [kPa]')
    xlabel('T_{amb} [^oC]');
    hold off
    grid on
subplot(2,1,2)
    plot(T_amb_vec,flow,'-or')
    xlabel('T_{amb} [^oC]');
    ylabel('flowrate [kg/s]')
    grid on

    

%
%
% plot Ts diagrams
%
figure(3)
asdf = [];
j = J;
LEG = cell(1,I);
T = zeros(9,1);
s = T;
for i = 1:I
    T = Props{i,j}(:,2);
    if isnan(T(1))
        s = NaN;
        LEG{i} = ' ';
    else
        for k = 1:numel( T )
        s(k) = XR410a('s','Ph', Props{i,j}(k,1), Props{i,j}(k,3));
        LEG{i} = ['T_{amb} = ',num2str(T_amb_vec(i),3),' ^oC ;  valve: ',num2str(valve(i,j),3)];
        end
    end
    asdf(i)=plotcycle_TS( T, s, ...
        'cyclecolor', rgb_func(i/(I+1)) );
    
    hold on
end

hold off
grid on
legend(asdf, LEG, 'location', 'northwest')
xlabel('s (kJ/kg-K)')
ylabel('T (^oC)')
% % %    
% % % %
% % % % Plot Ph diagrams
% % % figure(3)
% % % 
% % % for j = 1:J
% % %     P = Props{i,j}(:,1);
% % %     h = Props{i,j}(:,3);
% % % 
% % %     asdf(j)=plotcycle_PH( P, h, ...
% % %         'cyclecolor', rgb_func(j/(J+1)) );
% % %     
% % %     if isnan(P(1))
% % %         LEG{j} = ' ';
% % %     else
% % %         LEG{j} = ['valve: x = ',num2str(valve_vec(j),3)];
% % %     end
% % %     
% % %     hold on
% % % end
% % % 
% % % hold off
% % % grid on
% % % legend(asdf, LEG, 'location', 'northwest')
% % % xlabel('h (kJ/kg)')
% % % ylabel('P (kPa)')
% % % 
% % % %
% % % %
% % % %
% % % 
% % % figure(4)
% % % for j = 1:J
% % %   
% % %     plot( T_amb_vec, flow(:,j), '-o',...
% % %             'color', rgb_func( j/(J+1)), 'linewidth', 2 )
% % %     LEG{j} = ['valve: x = ',num2str(valve_vec(j),3)];
% % %     hold on
% % % end
% % % 
% % % hold off
% % % grid on
% % % legend(LEG, 'location', 'southeast')
% % % ylabel('m_{dot} (kg/s)')
% % % xlabel('T_{amb} (^oC)')
% % % 
% % % %
% % % %-------- Plot COP ------------------------------------------------
% % % figure(5)
% % % 
% % % COP1 = Evap_HT./Compr_W;
% % % COP2 = 0*COP1;
% % % for j = 1:J
% % %     for i = 1:I
% % %         if ~isnan(COP2(i,j))
% % %         COP2(i,j) = ...
% % %        (  Props{i,j}(9,3)-Props{i,j}(6,3) )/...
% % %        (  Props{i,j}(2,3)-Props{i,j}(1,3) );
% % %         end
% % %     end
% % %     %plot( T_amb_vec, COP1(:,j), '-o',...
% % %     %        'color', rgb_func(j/(J+1)), 'linewidth', 2 )
% % %     LEG{j} = ['valve: x = ',num2str(valve_vec(j),3)];
% % %     
% % %     semilogy( T_amb_vec, COP2(:,j), '-o',...
% % %             'color', rgb_func(j/(J+1)), 'linewidth', 2 )
% % %     hold on
% % % end
% % % 
% % % hold off
% % % grid on
% % % legend(LEG, 'location', 'northeast')
% % % ylabel('COP')
% % % xlabel('T_{amb} (^oC)')
% % % 
% % % %
% % % %
% % % figure(6)
% % % for j = 1:J
% % %  
% % %     plot( T_amb_vec, T_SH(:,j), '-o',...
% % %             'color', rgb_func(j/(J+1)), 'linewidth', 2)
% % %     LEG{j} = ['valve: x = ',num2str(valve_vec(j),3)];
% % %     hold on
% % % end
% % % 
% % % hold off
% % % grid on
% % % legend(LEG, 'location', 'northeast')
% % % ylabel('T_{SH} (^oC)')
% % % xlabel('T_{amb} (^oC)')
% % % 
% % % figure(7)
% % % for j = 1:J
% % %  
% % %     plot( T_amb_vec, Del_P(:,j), '-o',...
% % %             'color', rgb_func(j/(J+1)), 'linewidth', 2)
% % %     LEG{j} = ['valve: x = ',num2str(valve_vec(j),3)];
% % %     hold on
% % % end
% % % 
% % % hold off
% % % grid on
% % % legend(LEG, 'location', 'northwest')
% % % ylabel('\DeltaP (kPa)')
% % % xlabel('T_{amb} (^oC)')
% % % 
% % % figure(8)
% % % for j = 1:J
% % %  
% % %     plot( Del_P(:,j), flow(:,j), '-o',...
% % %             'color', rgb_func(j/(J+1)), 'linewidth', 2)
% % %     LEG{j} = ['valve: x = ',num2str(valve_vec(j),3)];
% % %     hold on
% % % end
% % % for i = 1:I
% % %     plot( Del_P(i,:), flow(i,:), '--k') 
% % %     text( 50+Del_P(i,1), -0.00025+flow(i,1), sprintf('%g^oC',T_amb_vec(i)))     
% % % end
% % % LEG{j+1} = 'Lines of cnst. T_{amb}';
% % % 
% % % hold off
% % % grid on
% % % legend(LEG, 'location', 'northeast')
% % % xlabel('\Delta P (kPa)')
% % % ylabel('m_{dot} (kg/s)')
% % % 
% % % figure(9)
% % % for j = 1:J
% % %  
% % %     plot( Del_P(:,j), T_SH(:,j), '-o',...
% % %             'color', rgb_func(j/(J+1)), 'linewidth', 2)
% % %     LEG{j} = ['valve: x = ',num2str(valve_vec(j),3)];
% % %     hold on
% % % end
% % % for i = 1:I
% % %     plot( Del_P(i,:), T_SH(i,:), '--k') 
% % %     text( 100+Del_P(i,1), 1+T_SH(i,1), sprintf('%g^oC',T_amb_vec(i)))     
% % % end
% % % LEG{j+1} = 'Lines of cnst. T_{amb}';
% % % 
% % % hold off
% % % grid on
% % % legend(LEG, 'location', 'southeast')
% % % xlabel('\Delta P (kPa)')
% % % ylabel('T_{SH} (^oC)')
% % % 
% % % %
% % % %
% % % % plot COP vs DP
% % % figure(10)
% % % for j = 1:J
% % %  
% % %     loglog( Del_P(:,j), COP2(:,j), '-o',...
% % %             'color', rgb_func(j/(J+1)), 'linewidth', 2)
% % %     LEG{j} = ['valve: x = ',num2str(valve_vec(j),3)];
% % %     hold on
% % % end
% % % for i = 1:I
% % %     plot( Del_P(i,:), COP2(i,:), '--k') 
% % %     text( 1.08*Del_P(i,1), COP2(i,1), sprintf('%g^oC',T_amb_vec(i)))     
% % % end
% % % LEG{j+1} = 'Lines of cnst. T_{amb}';
% % % 
% % % hold off
% % % grid on
% % % legend(LEG, 'location', 'northeast')
% % % xlabel('\Delta P (kPa)')
% % % ylabel('COP')
% % % 
% % % figure(11)
% % % for j = 1:J
% % %  
% % %     plot( T_SH(:,j), flow(:,j), '-o',...
% % %             'color', rgb_func(j/(J+1)), 'linewidth', 2)
% % %     LEG{j} = ['valve: x = ',num2str(valve_vec(j),3)];
% % %     hold on
% % % end
% % % for i = 1:I
% % %     plot( T_SH(i,:), flow(i,:), '--k') 
% % %    % text( 1.08*T_SH(i,1), flow(i,1), sprintf('%g^oC',T_amb_vec(i)))     
% % % end
% % % LEG{j+1} = 'Lines of cnst. T_{amb}';
% % % 
% % % hold off
% % % grid on
% % % legend(LEG, 'location', 'northeast')
% % % xlabel('\Delta T_{SH} (^oC)')
% % % ylabel('m_{dot} (kg/s)')
% % % 
% % % %
% % % % plot Ts diagrams
% % % figure(12)
% % % LEG = cell(I,1);
% % % j = 1;
% % % T = zeros(9,1);
% % % s = T;
% % % for i = 1:I
% % %     T = Props{i,j}(:,2);
% % %     env_c = T_amb_vec(i)*[1,1];
% % %     sssss = [0.6, 2.2];
% % %     if isnan(T(1))
% % %         s = NaN;
% % %         LEG{i} = ' ';
% % %         env_c = NaN;
% % %         sssss = NaN;
% % %     else
% % %         for k = 1:numel(Props{i,j}(:,2))
% % %         s(k) = XR410a('s','Ph', Props{i,j}(k,1), Props{i,j}(k,3));
% % %         LEG{i} = ['T_{amb} = ',num2str(T_amb_vec(i),3)];
% % %         end
% % %     end
% % %     asdf(i)=plotcycle_TS( T, s, 'cyclecolor', rgb_func(i/(I+1)) );
% % %     hold on
% % %     plot(sssss,env_c,'-.','color',rgb_func(i/(I+1)))
% % % end
% % % 
% % % hold off
% % % grid on
% % % legend(asdf, LEG, 'location', 'northwest')
% % % text(1.2,80,sprintf('valve: x = %g ', valve_vec(j)))
% % % %text(0.65,-5+T_pod,sprintf('T_{pod} = %g ^oC',T_pod))
% % % xlabel('s (kJ/kg-K)')
% % % ylabel('T (^oC)')
% % %    
% % % 
% % % %
% % % % plot Ts diagrams
% % % figure(13)
% % % LEG = cell(I,1);
% % % j = 2;
% % % T = zeros(9,1);
% % % s = T;
% % % for i = 1:I
% % %     T = Props{i,j}(:,2);
% % %     
% % %     env_c = T_amb_vec(i)*[1,1];
% % %     sssss = [0.6, 2.2];
% % %     if isnan(T(1))
% % %         s = NaN;
% % %         LEG{i} = ' ';
% % %         env_c = NaN;
% % %         sssss = NaN;
% % %     else
% % %         for k = 1:numel(Props{i,j}(:,2))
% % %         s(k) = XR410a('s','Ph', Props{i,j}(k,1), Props{i,j}(k,3));
% % %         LEG{i} = ['T_{amb} = ',num2str(T_amb_vec(i),3)];
% % %         end
% % %     end
% % %     asdf(i)=plotcycle_TS( T, s, 'cyclecolor', rgb_func(i/(I+1)) );
% % %     hold on
% % %     plot(sssss,env_c,'-.','color',rgb_func(i/(I+1)))
% % % end
% % % 
% % % hold off
% % % grid on
% % % legend(asdf, LEG, 'location', 'northwest')
% % % text(1.2,80, sprintf('valve: x = %g ', valve_vec(j)))
% % % %text(0.65,-5+T_pod,sprintf('T_{pod} = %g ^oC',T_pod))
% % % xlabel('s (kJ/kg-K)')
% % % ylabel('T (^oC)')
% % % 
% % % %
% % % %
% % % % plot Ts diagrams
% % % figure(14)
% % % LEG = cell(I,1);
% % % j = 3;
% % % T = zeros(9,1);
% % % s = T;
% % % for i = 1:I
% % %     T = Props{i,j}(:,2);
% % %     
% % %     env_c = T_amb_vec(i)*[1,1];
% % %     sssss = [0.6, 2.2];
% % %     if isnan(T(1))
% % %         s = NaN;
% % %         LEG{i} = ' ';
% % %         env_c = NaN;
% % %         sssss = NaN;
% % %     else
% % %         for k = 1:numel(Props{i,j}(:,2))
% % %         s(k) = XR410a('s','Ph', Props{i,j}(k,1), Props{i,j}(k,3));
% % %         LEG{i} = ['T_{amb} = ',num2str(T_amb_vec(i),3)];
% % %         end
% % %     end
% % %     asdf(i)=plotcycle_TS( T, s, 'cyclecolor', rgb_func(i/(I+1)) );
% % %     hold on
% % %     plot(sssss,env_c,'-.','color',rgb_func(i/(I+1)))
% % % end
% % % 
% % % hold off
% % % grid on
% % % legend(asdf, LEG, 'location', 'northwest')
% % % text(1.2,80, sprintf('valve: x = %g ', valve_vec(j)))
% % % %text(0.65,-5+T_pod,sprintf('T_{pod} = %g ^oC',T_pod))
% % % xlabel('s (kJ/kg-K)')
% % % ylabel('T (^oC)')
% % % 
% % % 
% % % %
% % % %
% % % % plot Ts diagrams
% % % figure(15)
% % % LEG = cell(I,1);
% % % j = 4;
% % % T = zeros(9,1);
% % % s = T;
% % % for i = 1:I
% % %     T = Props{i,j}(:,2);
% % %     
% % %     env_c = T_amb_vec(i)*[1,1];
% % %     sssss = [0.6, 2.2];
% % %     if isnan(T(1))
% % %         s = NaN;
% % %         LEG{i} = ' ';
% % %         env_c = NaN;
% % %         sssss = NaN;
% % %     else
% % %         for k = 1:numel(Props{i,j}(:,2))
% % %         s(k) = XR410a('s','Ph', Props{i,j}(k,1), Props{i,j}(k,3));
% % %         LEG{i} = ['T_{amb} = ',num2str(T_amb_vec(i),3)];
% % %         end
% % %     end
% % %     asdf(i)=plotcycle_TS( T, s, 'cyclecolor', rgb_func(i/(I+1)) );
% % %     hold on
% % %     plot(sssss,env_c,'-.','color',rgb_func(i/(I+1)))
% % % end
% % % 
% % % hold off
% % % grid on
% % % legend(asdf, LEG, 'location', 'northwest')
% % % text(1.2,80, sprintf('valve: x = %g ', valve_vec(j)))
% % % %text(0.65,-5+T_pod,sprintf('T_{pod} = %g ^oC',T_pod))
% % % xlabel('s (kJ/kg-K)')
% % % ylabel('T (^oC)')
% % % 
% % % 
% % % %
% % % %
% % % % plot Ts diagrams
% % % figure(16)
% % % LEG = cell(I,1);
% % % j = 5;
% % % T = zeros(9,1);
% % % s = T;
% % % for i = 1:I
% % %     T = Props{i,j}(:,2);
% % %     
% % %     env_c = T_amb_vec(i)*[1,1];
% % %     sssss = [0.6, 2.2];
% % %     if isnan(T(1))
% % %         s = NaN;
% % %         LEG{i} = ' ';
% % %         env_c = NaN;
% % %         sssss = NaN;
% % %     else
% % %         for k = 1:numel(Props{i,j}(:,2))
% % %         s(k) = XR410a('s','Ph', Props{i,j}(k,1), Props{i,j}(k,3));
% % %         LEG{i} = ['T_{amb} = ',num2str(T_amb_vec(i),3)];
% % %         end
% % %     end
% % %     asdf(i)=plotcycle_TS( T, s, 'cyclecolor', rgb_func(i/(I+1)) );
% % %     hold on
% % %     plot(sssss,env_c,'-.','color',rgb_func(i/(I+1)))
% % % end
% % % 
% % % hold off
% % % grid on
% % % legend(asdf, LEG, 'location', 'northwest')
% % % text(1.2,80, sprintf('valve: x = %g ', valve_vec(j)))
% % % %text(0.65,-5+T_pod,sprintf('T_{pod} = %g ^oC',T_pod))
% % % xlabel('s (kJ/kg-K)')
% % % ylabel('T (^oC)')
% % % 
% % % 
% % % %
% % % %
% % % % plot COP vs T_SH
% % % figure(17)
% % % LEG = cell(J,1);
% % % for j = 1:J
% % %  
% % %     plot( T_SH(:,j), COP2(:,j), '-o',...
% % %             'color', rgb_func(j/(J+1)), 'linewidth', 2)
% % %     LEG{j} = ['valve: x = ',num2str(valve_vec(j),3)];
% % %     hold on
% % % end
% % % for i = 1:I
% % %     plot( T_SH(i,:), COP2(i,:), '--k') 
% % %     text( 1.04*T_SH(i,1), COP2(i,1), sprintf('%g^oC',T_amb_vec(i)))     
% % % end
% % % LEG{j+1} = 'Lines of cnst. T_{amb}';
% % % 
% % % hold off
% % % grid on
% % % legend(LEG, 'location', 'northwest')
% % % xlabel('\Delta T_{SH} (^oC)')
% % % ylabel('COP')
% % % 
% % % 
% % % 
% % % %
% % % %
% % % % plot COP vs m_dot
% % % figure(18)
% % % LEG = cell(J,1);
% % % for j = 1:J
% % %  
% % %     plot( flow(:,j), COP2(:,j), '-o',...
% % %             'color', rgb_func(j/(J+1)), 'linewidth', 2)
% % %     LEG{j} = ['valve: x = ',num2str(valve_vec(j),3)];
% % %     hold on
% % % end
% % % for i = 1:I
% % %     plot( flow(i,:), COP2(i,:), '--k') 
% % %     text( 1.02*flow(i,1), COP2(i,1), sprintf('%g^oC',T_amb_vec(i)))     
% % % end
% % % LEG{j+1} = 'Lines of cnst. T_{amb}';
% % % 
% % % hold off
% % % grid on
% % % legend(LEG, 'location', 'northeast')
% % % xlabel('m_{dot} (kg/s)')
% % % ylabel('COP')
% % % 
% % % %
% % % %
% % % % plot HX DT vs m_dot
% % % figure(19)
% % % LEG = cell(J,1);
% % % for j = 1:J
% % %  
% % %     asdf(j)=plot( T_amb_vec, CHXDT(:,j), '-o',...
% % %             'color', rgb_func(j/(J+1)), 'linewidth', 2);
% % %     LEG{j} = ['valve: x = ',num2str(valve_vec(j),3)];
% % %     hold on
% % % end
% % % % for i = 1:I
% % % %     plot( flow(i,:), COP2(i,:), '--k') 
% % % %     text( 1.02*flow(i,1), COP2(i,1), sprintf('%g^oC',T_amb_vec(i)))     
% % % % end
% % % % LEG{j+1} = 'Lines of cnst. T_{amb}';
% % % 
% % % hold off
% % % grid on
% % % legend(LEG, 'location', 'east')
% % % xlabel('T_{amb} (^oC)')
% % % ylabel('condenser \DeltaT (^oC))')
% % % 
% % % 
% % % figure(20)
% % % LEG = cell(J,1);
% % % for j = 1:J
% % %  
% % %     asdf(j)=plot( T_amb_vec, EHXDT(:,j), '-o',...
% % %             'color', rgb_func(j/(J+1)), 'linewidth', 2);
% % %     LEG{j} = ['valve: x = ',num2str(valve_vec(j),3)];
% % %     hold on
% % % end
% % % % for i = 1:I
% % % %     plot( flow(i,:), COP2(i,:), '--k') 
% % % %     text( 1.02*flow(i,1), COP2(i,1), sprintf('%g^oC',T_amb_vec(i)))     
% % % % end
% % % % LEG{j+1} = 'Lines of cnst. T_{amb}';
% % % 
% % % hold off
% % % grid on
% % % legend(LEG, 'location', 'northeast')
% % % xlabel('T_{amb} (^oC)')
% % % ylabel('evaporator \DeltaT (^oC))')
% % % 
% % % %
% % % %
% % % %
% % % figure(21)
% % % LEG = cell(J,1);
% % % for j = 1:J
% % %  
% % %     asdf(j)=plot( EHXDT(:,j), CHXDT(:,j), '-o',...
% % %             'color', rgb_func(j/(J+1)), 'linewidth', 2);
% % %     LEG{j} = ['valve: x = ',num2str(valve_vec(j),3)];
% % %     hold on
% % % end
% % % for i = 1:I
% % %     plot( EHXDT(i,:), CHXDT(i,:), '--k') 
% % %     if ~mod(i,2)
% % %     text( EHXDT(i,1)-0.8+0.8*i/I, CHXDT(i,1)+0.7, sprintf('%g^oC',T_amb_vec(i)))   
% % %     end
% % % end
% % % LEG{j+1} = 'Lines of cnst. T_{amb}';
% % % 
% % % hold off
% % % grid on
% % % legend(LEG, 'location', 'northwest')
% % % xlabel('evaporator \DeltaT (^oC))')
% % % ylabel('condenser \DeltaT (^oC))')
% % % 
% % % 
% % % % important
% % % %
% % % figure(22)
% % % LEG = cell(J,1);
% % % for j = 1:J
% % %  
% % %     asdf(j)=plot( EHXDT(:,j), flow(:,j), '-o',...
% % %             'color', rgb_func(j/(J+1)), 'linewidth', 2);
% % %     LEG{j} = ['valve: x = ',num2str(valve_vec(j),3)];
% % %     hold on
% % % end
% % % for i = 1:I
% % %     plot( EHXDT(i,:),flow(i,:), '--k') 
% % %    
% % %    % text( EHXDT(i,1)-0.8+0.8*i/I, flow(i,1)+0.7, sprintf('%g^oC',T_amb_vec(i)))   
% % %  
% % % end
% % % LEG{j+1} = 'Lines of cnst. T_{amb}';
% % % 
% % % hold off
% % % grid on
% % % legend(LEG, 'location', 'northeast')
% % % xlabel('evaporator \DeltaT (^oC))')
% % % ylabel('m_{dot} (kg/s)')
% % % 
% % % 
% % % % 
% % % %
% % % figure(23)
% % % LEG = cell(J,1);
% % % for j = 1:J
% % %  
% % %     asdf(j)=plot( CHXDT(:,j), flow(:,j), '-o',...
% % %             'color', rgb_func(j/(J+1)), 'linewidth', 2);
% % %     LEG{j} = ['valve: x = ',num2str(valve_vec(j),3)];
% % %     hold on
% % % end
% % % for i = 1:I
% % %     plot( CHXDT(i,:),flow(i,:), '--k') 
% % %    
% % %     text( CHXDT(i,1)-0.8+0.8*i/I, flow(i,1)+0.7, sprintf('%g^oC',T_amb_vec(i)))   
% % %  
% % % end
% % % LEG{j+1} = 'Lines of cnst. T_{amb}';
% % % 
% % % hold off
% % % grid on
% % % legend(LEG, 'location', 'northeast')
% % % xlabel('condenser \DeltaT (^oC))')
% % % ylabel('m_{dot} (kg/s)')
% % % 
% % % 
% % % %
% % % %
% % % % plot Ts diagrams
% % % figure(24)
% % % LEG = cell(I,1);
% % % j = 4;
% % % T = zeros(9,1);
% % % z = T;
% % % for i = 1:I
% % %     T = Props{i,j}(:,2);
% % %     z = Props{i,j}(:,4);
% % %     env_c = T_amb_vec(i)*[1,1];
% % %     sssss = [0,1];
% % %      LEG{i} = ['T_{amb} = ',num2str(T_amb_vec(i),3)];
% % %     asdf(i)=plot( z,T, '-o','linewidth',2,'color', rgb_func(i/(I+1)) );
% % %     hold on
% % %     plot(sssss,env_c,'-.','color',rgb_func(i/(I+1)))
% % % end
% % % hold off
% % % text(0.5,60,['valve: x = ', num2str(valve_vec(j))])
% % % legend(asdf,LEG) 