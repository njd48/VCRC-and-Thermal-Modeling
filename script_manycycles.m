

% Introduce Variable Parameters ------------------

Param_T = 25;%[ 40; 35; 30 ];


% Initialize Outputs -----------------------------




% Run Script -------------------------------------

for j = 1:numel(Param_T)
    %
    % Call Param
    T_amb = Param_T(j);
    % ---
    %
    % run
    
    run RUNCYCLE_wFULLSYS_wIN
    
    % ---
    %
    % store outputs
    
    % ---
    %
    % Satisfied? 
    
    my_great_aunt_sophie = input('Satisfactory? ( 0 to kill program )');
    if my_great_aunt_sophie == 0
        return;
    end
    
    % ---
    %
end

% ---------
