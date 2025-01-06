function [var_out] = SubCool(str_o, str_i, varargin )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

if strcmp( str_o, 'x' )  
    var_out = -0.1;
    warning('Request for quality of subcooled')
    return;
end

if nargin ~= 4
    error('Need two properties to fix a state');
else
    var_1 = varargin{1};
    var_2 = varargin{2};
end


if numel(str_i) ~= 2
    error('string argument requests too many or too few inputs')
end
if numel(str_o) ~= 1
    error('string argument requests too many outputs')
end

% Specific Heat Capacity
% c_p = @(P) SubCool_Cp('P', P); %[kJ/kgK]  
c_p = @(P) SubCL_Cp(SatLookupTP( 'T', 'P', P ));

%Plans to extend this value as a function of pressure


if     strcmp(str_i, 'TP') || strcmp(str_i, 'PT') 
    switch str_i(1)
        case 'T'
            T = var_1; iT = 1;
            P = var_2; iP = 2;
        case 'P'
            P = var_1; iP = 1;
            T = var_2; iT = 2;
    end
    
    switch str_o
        
        case 'v'
            
            var_out = SatLookupTP('vf','P', P);
            
        case 'u'
            
            %calc enthalpy and subtract Pv            
            v       = SatLookupTP('vf', 'P', P);
            hf      = SatLookupTP('hf', 'P', P);
            Tsat    = SatLookupTP('T',  'P', P);
            
            var_out = hf + c_p(P)*( T - Tsat ) - P*v; 
            
        case 'h'
            
            v       = SatLookupTP('vf', 'P', P);
            hf      = SatLookupTP('hf', 'P', P);
            Tsat    = SatLookupTP('T',  'P', P);
            
            var_out = hf + c_p(P)*( T - Tsat ) - P*v; 
            
        case 's'
            
            T       = T + 273.15;
            sf      = SatLookupTP('sf', 'P', P);
            Tsat    = 273.15 + SatLookupTP('T', 'P', P);
            
            var_out = c_p(P)*log( T/Tsat ) + sf;
            
        otherwise
            error();
            
    end
    
elseif strcmp(str_i, 'Tv') || strcmp(str_i, 'vT') 
    
    warning('v = v_f to approximation in the subcooled region');
    
    switch str_i(1)
        case 'T'
            T = var_1; iT = 1;
            v = var_2; iv = 2;
        case 'v'
            v = var_1; iv = 1;
            T = var_2; iT = 2;
    end
    
    switch str_o
        
        case 'P'
            
            %use saturation value
            var_out = SatLookupTP('P','vf', v);
            
        case 'u'
            
            %calc enthalpy and subtract Pv            
            P       = SatLookupTP('P', 'vf', v);
            hf      = SatLookupTP('hf','vf', v);
            Tsat    = SatLookupTP('T', 'vf', v);
            var_out = hf + c_p(P)*( T - Tsat ) - P*v; 
            
        case 'h'
            
            P       = SatLookupTP('P', 'vf', v);
            hf      = SatLookupTP('hf','vf', v);
            Tsat    = SatLookupTP('T', 'vf', v);
            var_out = hf + c_p(P)*( T - Tsat ) - P*v; 
            
        case 's'
            
            T       = 273.15 + T;
            sf      = SatLookupTP('sf', 'vf', v); 
            Tsat    = 273.15 + SatLookupTP('T',  'vf', v);
            
            var_out = c_p(P)*log( T/Tsat ) + sf;
            
        otherwise
            error();
            
    end
    
% elseif strcmp(str_i, 'Tu') || strcmp(str_i, 'uT') 
% elseif strcmp(str_i, 'Th') || strcmp(str_i, 'hT') 
% elseif strcmp(str_i, 'Ts') || strcmp(str_i, 'sT')     
% elseif strcmp(str_i, 'Pv') || strcmp(str_i, 'vP') 
% This one above may be impossible

elseif strcmp(str_i, 'Pu') || strcmp(str_i, 'uP')
    
    switch str_i(1)
        case 'P'
            P = var_1; iP = 1;
            u = var_2; iu = 2;
        case 'u'
            u = var_1; iu = 1;
            P = var_2; iP = 2;
    end
    
    switch str_o
        
        case 'T'
                 
            v       = SatLookupTP('vf','P', P);
            h       = u + P*v;
            hf      = SatLookupTP('hf', 'P', P);
            Tsat    = SatLookupTP('T',  'P', P);
            
            var_out = Tsat + (h - hf)/c_p(P); 
            
        case 'v'
            
            %use saturation value
            var_out = SatLookupTP('vf','P', P);
             
        case 'h'
            
            v       = SatLookupTP('vf','P', P);
            h       = u + P*v;

        case 's'
            
            v       = SatLookupTP('vf', 'P', P);
            sf      = SatLookupTP('sf', 'P', P);
            hf      = SatLookupTP('hf', 'P', P);
            Tsat    = 273.15  + SatLookupTP('T',  'P', P);
            Tx      = ( u - P*v - hf )/c_p(P);
            
            var_out = c_p(P)*log( (Tx + Tsat)/Tsat ) + sf;
            
        otherwise
            error();
            
    end
    
elseif strcmp(str_i, 'Ph') || strcmp(str_i, 'hP') 
    
    switch str_i(1)
        case 'P'
            P = var_1; iP = 1;
            h = var_2; ih = 2;
        case 'h'
            h = var_1; ih = 1;
            P = var_2; iP = 2;
    end
    
    switch str_o
        
        case 'T'
                 
            hf      = SatLookupTP('hf', 'P', P);
            Tsat    = SatLookupTP('T',  'P', P);
            
            var_out = Tsat + (h - hf)/c_p(P); 
            
        case 'v'
            
            %use saturation value
            var_out = SatLookupTP('vf','P', P);
             
        case 'u'
            
            v = SatLookupTP('vf','P', P);
            var_out = h - P*v;

        case 's'
            
            sf      = SatLookupTP('sf', 'P', P);
            hf      = SatLookupTP('hf', 'P', P);
            Tsat    = 273.15 + SatLookupTP('T',  'P', P);
            Tx      = ( h - hf )/c_p(P);
            
            var_out = c_p(P)*log( (Tx + Tsat)/Tsat ) + sf;
            
        otherwise
            error();
            
    end
    
elseif strcmp(str_i, 'Ps') || strcmp(str_i, 'sP') 

    switch str_i(1)
        case 'P'
            P = var_1; iP = 1;
            s = var_2; is = 2;
        case 's'
            s = var_1; is = 1;
            P = var_2; iP = 2;
    end
    
    switch str_o
        
        case 'T'
                 
            sf      = SatLookupTP('sf', 'P', P);
            Tsat    = SatLookupTP('T',  'P', P) + 273.15;
            
            var_out = Tsat*exp( (s - sf)/c_p(P) ) - 273.15;
            
        case 'v'
            
            %use saturation value
            var_out = SatLookupTP('vf','P', P);
             
        case 'u'
            
            v       = SatLookupTP('vf', 'P', P);
            hf      = SatLookupTP('hf', 'P', P);
            sf      = SatLookupTP('sf', 'P', P);
            Tsat    = SatLookupTP('T',  'P', P) + 273.15;
            
            h       = c_p(P)*Tsat * (exp( (s - sf)/c_p(P) ) - 1) + hf;
            
            var_out = h - P*v;

        case 'h'
            v       = SatLookupTP('vf', 'P', P);
            hf      = SatLookupTP('hf', 'P', P);
            sf      = SatLookupTP('sf', 'P', P);
            Tsat    = SatLookupTP('T',  'P', P) + 273.15 ;
            
            var_out = c_p(P)*Tsat * (exp( (s - sf)/c_p(P) ) - 1) + hf;
            
        otherwise
            error();
            
    end
    
    
else
    error('cannot process input combination ''%s'' ', str_i)
end





end

