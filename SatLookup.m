function [var_out] = SatLookup(str_o, str_i, varargin )



  inx_str = {'T';'P';'v';'u';'h';'s';'x'};
                       
  
  if nargin < 3
      error('Too few input arguments')
      
  elseif nargin == 3
      var_1 = varargin{1};
      
  elseif nargin == 4
      var_1 = varargin{1};
      var_2 = varargin{2};
      
  elseif nargin > 4
      error('Too many input args')
  end
  

%-----------------------------------------------------------------------
% Case when f, or g prop are requested or Tsat, vs Psat
%-----------------------------------------------------------------------
  if ( numel(str_o) == 2 && nargin == 3 )...
  || ( ( nargin == 3)&&( strcmp(str_o, 'T') && strcmp(str_i, 'P') ) )...
  || ( ( nargin == 3)&&( strcmp(str_i, 'T') && strcmp(str_o, 'P') ) )...

      
      var_out = SatLookupTP(str_o, str_i, var_1 );
      return;
  end
  
%-----------------------------------------------------------------------
% Case when fg prop is requested
%-----------------------------------------------------------------------
  if ( numel(str_o) == 3 && nargin == 3 )...
  
    %check
    if ~strcmp('fg', str_o(2:3))
        error('str_o = ''%s'' not supported', str_o)
    end
    
%     %check
%     if ~( strcmp('T', str_i) || strcmp('P', str_i) )
%         error('need input property T or P for this request')
%     end
    % I think SatLookupTP will handle this check
    
    gstr = [str_o(1), 'g'];
    fstr = [str_o(1), 'f'];
    
    gstate = SatLookupTP( gstr, str_i, var_1 );
    fstate = SatLookupTP( fstr, str_i, var_1 );
    
      var_out = gstate - fstate;
      return;
  end
  
  
%-----------------------------------------------------------------------
% Case when x is supplied
%-----------------------------------------------------------------------
if strcmp('x', str_i(2)) && nargin == 4
    
    gstr = [str_o, 'g'];
    fstr = [str_o, 'f'];
    
    gstate = SatLookupTP( gstr, str_i(1), var_1 );
    fstate = SatLookupTP( fstr, str_i(1), var_1 );
    
    var_out = (1-var_2)*fstate + (var_2)*gstate;
    return;
    
elseif strcmp('x', str_i(1)) && nargin == 4
    
    gstr = [str_o, 'g'];
    fstr = [str_o, 'f'];
    
    gstate = SatLookupTP( gstr, str_i(2), var_2 );
    fstate = SatLookupTP( fstr, str_i(2), var_2 );
    
    var_out = (1-var_1)*fstate + (var_1)*gstate;
    return;

end

%-----------------------------------------------------------------------
% Case when state-property is supplied
%----------------------------------------------------------------------- 
    
    ii_1 = 0;   ii_2 = 0;   ii_o = 0;
    
    %Assign index for input variables
    for i = 1:numel(inx_str)
        
        if strcmp(inx_str{i}, str_i(1) )
            
            ii_1 = i;
            
        end
        if strcmp(inx_str{i}, str_i(2) )
            
            ii_2 = i;
            
        end
        if strcmp(inx_str{i}, str_o)
            
            ii_o = i;

        end
        
    end
    
    
    %Check ii were assigned
    if ii_1 == 0 || ii_2 == 0 || ii_o == 0
        %this property is not tabulated
        proceed_stateprop = 0;
    else
        %this property is tabulated
        proceed_stateprop = 1;
    end
    
    if proceed_stateprop
        %Find Quality
        if ( ii_1 > 2 )&&( ii_1 < 7 )
            gstr = [str_i(1), 'g'];
            fstr = [str_i(1), 'f'];
            
            gstate_i = SatLookupTP( gstr, str_i(2), var_2 );
            fstate_i = SatLookupTP( fstr, str_i(2), var_2 );
            
            x = ( var_1 - fstate_i )/( gstate_i - fstate_i );
            q = 1;
            
        elseif ( ii_2 > 2 )&&( ii_2 < 7 )
            gstr = [str_i(2), 'g'];
            fstr = [str_i(2), 'f'];
            
            gstate_i = SatLookupTP( gstr, str_i(1), var_1 );
            fstate_i = SatLookupTP( fstr, str_i(1), var_1 );
            
            x = ( var_2 - fstate_i )/( gstate_i - fstate_i );
            q = 2;
            
        end
        
        if ii_o == 7
            
            var_out = x;
            return;
        
        elseif ( ii_o == 1 )||( ii_o == 2 )
            
            if ( ii_1 == 1 )||( ii_1 == 2 )
                
                var_out = SatLookupTP(str_o, str_i(1), var_1);
                return;
                
            elseif ( ii_2 == 1 )||( ii_2 == 2 )
                
                var_out = SatLookupTP(str_o, str_i(2), var_2);
                return; 
                
            else                 
                                
                error('%s, not resolvable under the dome without T or P', str_o);
                
            end
        else
            
            gstr = [str_o, 'g'];
            fstr = [str_o, 'f'];
            
            switch q
                
                case 1
                  
                gstate_o = SatLookupTP( gstr, str_i(2), var_2 );
                fstate_o = SatLookupTP( fstr, str_i(2), var_2 );
                
                case 2
            
                gstate_o = SatLookupTP( gstr, str_i(1), var_1 );
                fstate_o = SatLookupTP( fstr, str_i(1), var_1 ); 
                
            end
            
            var_out = fstate_o + x*( gstate_o - fstate_o );
            return;
        end
        
    end
    
    
    
    error('Incomplete code')


end

