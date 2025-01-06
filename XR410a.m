function [var_out] = XR134a(str_o, str_i, varargin)

%String codes for state variables
% 'T'
% 'P'
% 'v'
% 'u'
% 'h'
% 's'

if nargin == 3
    
    var_1 = varargin{1};
    
    %Check to make sure properties are in the saturated domain
    %Then call SatLookup(); 
    switch str_i
        
        case 'T'
            Tlims = [-100, 70];
            
        case 'P'    
            Tlims = [3.75, 4714];
            
        otherwise
            Tlims = [SatLookup(str_i, 'T', -100), SatLookup(str_i, 'T', 70 )];
            Tlims = sort(Tlims);
           
    end
    
    if ~(Tlims(1) <= var_1 && var_1 < Tlims(2))
        error('request for saturated property not in the saturated domain.  i.e. %s is supercritical', str_i)
    end

    
    var_out = SatLookup(str_o, str_i, var_1);
    return;
    
elseif nargin == 4
    inx_str = {'T';'P';'v';'u';'h';'s';'x'};
    
    var_1 = varargin{1};
    var_2 = varargin{2};
    
    
    
    ii_1 = 0; ii_2 = 0;
    %Assign index for input variables
    for i = 1:numel(inx_str)
        
        if strcmp(inx_str{i}, str_i(1))
            
            ii_1 = i;
            
        end
        if strcmp(inx_str{i}, str_i(2))
            
            ii_2 = i;
            
        end
        
    end
    %Ensure both ii were assigned
    if ( ii_1 == 0 )||( ii_2 == 0 )
        error('props not assigned.  do not recognize input combination: ''%s'' ',str_i)
    end
    
    %Ensure distinct vars are requested
    if ii_1 == ii_2
        error('must supply distinct input vars')
    end
    
    %Case where quality, x, is supplied
    if ii_1 == 7 || ii_2 == 7
        
        var_out = SatLookup( str_o, str_i, var_1, var_2 );
            return;
            
    end
        
    %Determine whether sat or supheated
    
    
    if (ii_1 <=2 )&&( ii_2 <=2)
        % Case where temperature and pressure are supplied
        % This is almost certainly superheated (or subcooled)
        
        if ( ii_1 == 2 )          
            T = var_2;
            P = var_1;          
        elseif (ii_1 == 1)       
            T = var_1;
            P = var_2;
        end
        
        % First check that this combination is indeed superheated 
        % (or subcooled)
        T_sat   = SatLookup( 'T', 'P', P );
    
        if T >= T_sat
            var_out = SuperheatLookup(str_o, str_i, var_1, var_2);
            return;
            
        elseif T < T_sat
            var_out = SubCool(str_o, str_i, var_1, var_2);
            return;
            
        else  
            error('TP combination is not superheated.  may be saturated, in such case supply either T or P')
        end
    
    elseif ( ii_1 > 2 )||( ii_2 > 2 )
        
        if ( ii_1 > 2 )
            
            q = 1; 
            p = 2; 
            
            T = var_2;
            s = var_1;
            
        elseif (ii_2 > 2)
            
            q = 2; 
            p = 1;
            
            T = var_1;
            s = var_2;
            
        end
        %Check whether subcooled, superheated, or saturated and assign the output        
        sg = SatLookupTP( [str_i(q),'g'], str_i(p), T );
        sf = SatLookupTP( [str_i(q),'f'], str_i(p), T );
        
        if s < sf  %SUBCOOLED
            
            var_out = SubCool( str_o, str_i, var_1, var_2 );
            return;
            
        elseif s <= sg  %SATURATED
            
            var_out = SatLookup( str_o, str_i, var_1, var_2 );
            return;
            
        elseif s > sg %SUPERHEATED
           
            var_out = SuperheatLookup( str_o, str_i, var_1, var_2 );
            return;
            
        else
            error('not superheated or saturated or subcooled.  (you fucked up)')
            %This error should never happen
            
        end
        
    end
    % Exception for pressure and temperature
    %
    %
    
elseif nargin < 3
    error('state underdetermined')
    
else
    error('state overdetermined')
    
end
    

end

