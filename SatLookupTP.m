function [var_out] = SatLookupTP(str_o, str_i, var_i )


    inx_str = {'T';'P';'vf';'vg';'hf';'hg';'sf';'sg'};
    
    
    ii_i = 0;  ii_o = 0;
    
    %Assign index for input variables
    for i = 1:numel(inx_str)
        
        if strcmp(inx_str{i}, str_i)
            
            ii_i = i;
            
        end
        if strcmp(inx_str{i}, str_o)
            
            ii_o = i;

        end
        
        
    end
    
    %Add exception for u
    if strcmp('u',str_o(1))
       
        switch str_i(1)
            
            case 'P'
                h = SatLookupTP( ['h',str_o(2)], str_i, var_i );  
                P = var_i;
                v = SatLookupTP( ['v',str_o(2)], str_i, var_i );
        
            case 'h'
                h = var_i;
                P = SatLookupTP(  'P',           str_i, var_i );
                v = SatLookupTP( ['v',str_o(2)], str_i, var_i );
                
            case 'v'
                h = SatLookupTP( ['h',str_o(2)], str_i, var_i );
                P = SatLookupTP(  'P',           str_i, var_i );
                v = var_i;
                
            case 'u' %This is an error case
                error('Requested u as a function of u');
                
            otherwise 
                h = SatLookupTP( ['h',str_o(2)], str_i, var_i );
                P = SatLookupTP(  'P',           str_i, var_i );
                v = SatLookupTP( ['v',str_o(2)], str_i, var_i );
        
        end
        
        var_out = h - P.*v;
        return;
        
    end
    
    
    %Check ii were assigned
    if ii_o == 0
        error([str_o,' : this property is not tabulated for output'])
    elseif ii_i == 0
        error([str_i,' : this property is not tabulated for input'])
    elseif ii_o == ii_i
        error('requested %s as a function of %s');
    end
    
        
    %========================%
      load SatVarsR410a.mat  %
    %========================%

    [M,N] = size(SatR410a);
    
    J = 0;
    % Begin Interpolation
    for j = 2:M
    
        if ((SatR410a( j, ii_i ) >= var_i ) &&( var_i > SatR410a( j-1, ii_i ) ))||...
           ((SatR410a( j, ii_i ) <= var_i ) &&( var_i < SatR410a( j-1, ii_i ) ))
           
           J = j; 
           break;
            
        end
        
    end
    
    
    %add exception
    if J == 0
        if ((SatR410a( M, ii_i ) >= var_i ) &&(  SatR410a( 1, ii_i ) >= var_i ))
                    
             if (SatR410a( M, ii_i ) - SatR410a( 1, ii_i )) > 0
                 
                  J = 2;
             else
                  J = M-1;
             end
             
            warning('%s outside range of table, extrapolating \n',...
                         str_i,  str_i, var_i - SatR410a( J, ii_i ));
                     
                     
        elseif ((SatR410a( M, ii_i ) <= var_i ) &&(  SatR410a( 1, ii_i ) <= var_i ))
                
            if (SatR410a( M, ii_i ) - SatR410a( 1, ii_i )) > 0
                
                  J = M-1;
            else
                  J = 2;
            end
            
            warning('%s outside range of table, extrapolating \n',...
                         str_i,  str_i, var_i - SatR410a( J, ii_i )) ;
        else 
            error('Interpol exceptions too complicated for this programmer')
        end        
    end
    
    %Collect table values and interpolate
        x1 = SatR410a( J-1, ii_i );
        x2 = SatR410a( J,   ii_i );
        y1 = SatR410a( J-1, ii_o );
        y2 = SatR410a( J,   ii_o );
    
    
    var_out = y1 + ( y2 - y1 )/( x2 - x1 )*( var_i - x1 );
    
    
end

