function [Vars, Deficit] = adjust_cycle_fmin(Vars, Inputs, Param)

assert( sum(size(Vars) == [3,1]) == 2 )

T_amb  = Inputs(3);
T_pod  = Inputs(4);
    
%Var Extents
lb(1) = SatLookupTP('P','T', T_amb);
ub(1) = 4100;
lb(2) = 500;
ub(2) = SatLookupTP('P','T', T_pod);
lb(3) = 0;
ub(3) = 1;

%
%
% Make Objective Function

    function [Obj] = objective( Vars )
        [x1,x2,x3,x4,x5,x6,x7,x8, Obj] = make_cycle( Vars, Inputs, Param );
        
        Obj = 1000*(Obj'*Obj);
    end
%
%
% Make Nonlinear Constraint for T_SH

%     function [c,ceq] = nonlcon( Vars )
%         c   = Vars(3) - (T_pod - SatLookupTP('T','P', Vars(2))) ;
%         ceq = [];
%     end

%
%
% Make Linear Constraints

A = [];
b = [];
Aeq = [];
beq = [];

%Options
%options = optimoptions('fmincon','Display','iter','Algorithm','sqp');

%
% Solve the problem.
%
    Vars = fmincon( @objective, Vars, A, b, Aeq,beq, lb, ub);
%
% ---

%
% Return Final Deficit
%
    Deficit = objective( Vars );
%
% ---

end

