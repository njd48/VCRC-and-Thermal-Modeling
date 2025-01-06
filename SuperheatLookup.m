function [var_out] = SuperheatLookup(str_o, str_i, var_1, var_2)


% Subroutine incase a moron (like me) asks for quality in superheated
% regime
if strcmp(str_o, 'x')
    
    var_out = 1.1;
    warning('Request for quality of superheated');    
    return;
    
end


if numel(str_i) ~= 2
    error('string argument, ''%s'', requests too many or too few inputs')
end
if numel(str_o) ~= 1
    error('string argument, ''%s'',  requests too many outputs', str_o)
end

load SupVarsR410a.mat
N = numel(Press);



% Two cases.  
% case one, pressure is included
% case two, pressure is not included


% Case where pressure is included

if strcmp( str_i(1), 'P' ) || strcmp( str_i(2), 'P' )
    
    if strcmp( str_i(1), 'P' )
        
        P = var_1;
        T = var_2;
        
        switch str_i(2)
            
            case 'u'
                error('cannot perform lookups with ''u'' in input')
                
            case 'T'
                col_T = 1;
                
            case 'v'
                col_T = 2;
                
            case 'h'
                col_T = 3;
                
            case 's'
                col_T = 4;
                
            otherwise
                error('This property, ''%s'', is not tabulated', str_i(2))
        end
        
    else
        
        T = var_1;
        P = var_2;
        
        switch str_i(1)
            
            case 'u'
                error('cannot perform lookups with ''u'' in input')
                
            case 'T'
                col_T = 1;
                
            case 'v'
                col_T = 2;
                
            case 'h'
                col_T = 3;
                
            case 's'
                col_T = 4;
                
            otherwise
                error('This property, ''%s'', is not tabulated', str_i(1))
        end
        
        
        
    end
    
    %Now compute output column index
    switch str_o
            
            case 'u'
                
                error('''u'' not yet implemented for output')
                %
                %
                % Later insert recursion routine for calculating 'u'
                %
                %
    
            case 'T'
                col_Q = 1;
                
            case 'v'
                col_Q = 2;
                
            case 'h'
                col_Q = 3;
                
            case 's'
                col_Q = 4;
                
            otherwise
                error('This property, ''%s'', is not tabulated', str_o)
    end
    
    %Sanity check if identical
    if col_T == col_Q
        
        error('Requested output as function of itself');
        
    end
        
    

% Determine pressure indicies
iP = 0;

    for j = 2:N
        
        if Press(j-1) <= P && P <= Press(j)
            
            iP = j;
            break;
            
        end
        
    end
    
    %Enter extrapolating    
    if iP == 0
        
        if P < Press(1)
            
            iP = 2;
            warning('Pressure input below tables, Extrapolating below');
            
        elseif P > Press(N)
            
            iP = N;
            warning('Pressure input above tables, Extrapolating above');
            
        end
    end
    
% Determine non-pressure input indicies
for k = 1:2

iT(3-k) = 0;

s = size(Block{iP - k + 1});

    for j = 2:s(1)
        
        if Block{iP - k + 1}(j-1, col_T) <= T && T <= Block{iP - k + 1}(j, col_T)
            
            iT(3-k) = j;
            break;
            
        end
        
    end
    
    %Enter extrapolating    
    if iT(3-k) == 0
        
        if T < Block{iP - k + 1}(1, col_T)
            
            iT(3-k) = 2;
            warning('nonpressure input belowBlock{iP - k + 1}(:, col_T) tables, Extrapolating below');
            
        elseif T > Block{iP - k + 1}(s(1), col_T)
            
            iT(3-k) = N;
            warning('nonpressure input above tables, Extrapolating above');
            
        end
    end
    
end


P2  = Press( iP   );
P1  = Press( iP-1 );

T22 = Block{ iP   }( iT(2)    , col_T );
T21 = Block{ iP-1 }( iT(1)    , col_T );
T12 = Block{ iP   }( iT(2)-1  , col_T );
T11 = Block{ iP-1 }( iT(1)-1  , col_T );

Q22 = Block{ iP   }( iT(2)    , col_Q );
Q21 = Block{ iP-1 }( iT(1)    , col_Q );
Q12 = Block{ iP   }( iT(2)-1  , col_Q );
Q11 = Block{ iP-1 }( iT(1)-1  , col_Q );


Q2  = Q21 + (Q22 - Q21)/(P2 - P1)*(P - P1);
Q1  = Q11 + (Q12 - Q11)/(P2 - P1)*(P - P1);

T2  = T21 + (T22 - T21)/(P2 - P1)*(P - P1);
T1  = T11 + (T12 - T11)/(P2 - P1)*(P - P1);

var_out = Q1 + (Q2 - Q1)/(T2 - T1)*(T - T1);

else
    
    error('Incomplete code')
    
end