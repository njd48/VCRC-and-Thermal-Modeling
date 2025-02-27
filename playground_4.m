%% Initialize
format compact
format short
clear all
close all

% Sim Param 
epsilon = 0.00001;

load param_4.mat
% Phys Param
%N      = 5000;
valve  = 0.725;
T_amb  = 40;
T_pod  = 17;


Q_load = 2.000;  %kJ

%Try this many inits

% %         % Init
% %         T_SH   = 5;
% %         P_c  = 3300;
% %         P_e  = 1000;

Vars_i_1  = [   2900;  1000; 3 ]; 
Vars_i_2  = [   3300;  1000; 3 ]; 
Vars_i_3  = [   3200;   900; 3 ]; 
Inputs    = [ Q_load; valve; T_amb; T_pod  ];
Param     = [    RPM, CA ]; 

%% Adjust

%Make init cycle
[Pi1,Ti1,hi1,zi1, mi1,QLi1,QHi1,Wi1,  Deficit_i_1] = make_cycle(Vars_i_1, Inputs, Param);
[Pi2,Ti2,hi2,zi2, mi2,QLi2,QHi2,Wi2,  Deficit_i_2] = make_cycle(Vars_i_2, Inputs, Param);
[Pi3,Ti3,hi3,zi3, mi3,QLi3,QHi3,Wi3,  Deficit_i_3] = make_cycle(Vars_i_3, Inputs, Param);


%adjust vars
%Keep history
%init outputs and history
N  = 7;
nn = [0:N]; 

Vars_f_1        = Vars_i_1;
Vars_f_2        = Vars_i_2;
Vars_f_3        = Vars_i_3;

var_hist_1      = zeros(3,N+1);
var_hist_2      = var_hist_1;
var_hist_3      = var_hist_1;

var_hist_1(:,1) = Vars_i_1;
var_hist_2(:,1) = Vars_i_2;
var_hist_3(:,1) = Vars_i_3;

def_hist_1      = var_hist_1;
def_hist_2      = var_hist_2;
def_hist_3      = var_hist_3;

def_hist_1(:,1) = Deficit_i_1;
def_hist_2(:,1) = Deficit_i_2;
def_hist_3(:,1) = Deficit_i_3;

for n = 1:N

    [ Vars_f_1, Deficit_f_1 ] = adjust_cycle_fmin( Vars_f_1,Inputs,Param,epsilon);
    var_hist_1( :, n+1) = Vars_f_1;
    def_hist_1( :, n+1) = Deficit_f_1;
%     
    [ Vars_f_2, Deficit_f_2 ] = adjust_cycle_fmin( Vars_f_2,Inputs,Param,epsilon);
    var_hist_2( :, n+1) = Vars_f_2;
    def_hist_2( :, n+1) = Deficit_f_2;
    
    [ Vars_f_3, Deficit_f_3 ] = adjust_cycle_fmin( Vars_f_3,Inputs,Param,epsilon);
    var_hist_3( :, n+1) = Vars_f_3;
    def_hist_3( :, n+1) = Deficit_f_3;
       
end

%Make final cycle
[Pf1,Tf1,hf1,zf1, mf1,QLf1,QHf1,Wf1, Deficit_f_1] = make_cycle(Vars_f_1, Inputs, Param);
[Pf2,Tf2,hf2,zf2, mf2,QLf2,QHf2,Wf2, Deficit_f_2] = make_cycle(Vars_f_2, Inputs, Param);
[Pf3,Tf3,hf3,zf3, mf3,QLf3,QHf3,Wf3, Deficit_f_3] = make_cycle(Vars_f_3, Inputs, Param);

disp(datetime('now'))
disp('init. Deficit ')
disp(Deficit_i_1')
disp(Deficit_i_2')
disp(Deficit_i_3')
disp('final Deficit ')
disp(Deficit_f_1')
disp(Deficit_f_2')
disp(Deficit_f_3')
disp('final Vars')
disp(Vars_f_1')
disp(Vars_f_2')
disp(Vars_f_3')


%% Track Var Iteration Paths

figure(1)
subplot(3,1,1)
    plot( nn, var_hist_1(1,:),'--o')
    hold on
    plot( nn, var_hist_2(1,:),'--o')
    plot( nn, var_hist_3(1,:),'--o')
    hold off
    ylabel('P_c (kPa)')
    grid on
subplot(3,1,2)    
    plot( nn, var_hist_1(2,:),'--o')
    hold on
    plot( nn, var_hist_2(2,:),'--o')
    plot( nn, var_hist_3(2,:),'--o')
    hold off
    ylabel('P_e (kPa)')
    grid on
subplot(3,1,3)    
    plot( nn, var_hist_1(3,:),'--o')
    hold on
    plot( nn, var_hist_2(3,:),'--o')
    plot( nn, var_hist_3(3,:),'--o')
    hold off
    ylabel('T_{SH} (*C)')
    grid on