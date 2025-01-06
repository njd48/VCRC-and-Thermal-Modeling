function DrawDome(  ordinate, abscissa, varargin )

if nargin < 2
    error('nargin < 2')
    
else
    color = 'k';
    type  = 'linear';
    
end

if nargin > 2
    if mod(nargin, 2) ~= 0 
        error('options mismatch')
    end
    
    for j = 1:(nargin - 2)/2
        p = 2*j - 1;
        
        if strcmp(varargin{p},'color')
            color = varargin{p+1};
            
        elseif strcmp(varargin{p},'type')
            type = varargin{p+1};
            
        else
            error('do not recognize this property ''%s'' ', varargin{p})
        end
    end
end
    

%Take in string arguments
if strcmp('T', ordinate)
    Tlims = [-100, 70];
    
elseif strcmp('P', ordinate)
    Tlims = [3.75, 4714];
    
else
    error('ordinate must be ''T'' or ''P'' ')
end
    

n = 100;
T = linspace( Tlims(1), Tlims(2), n )';

sf = 0*T;
sg = sf;

for j = 1:n
    
    sf(j) = SatLookupTP( [abscissa,'f'], ordinate, T(j) );
    sg(j) = SatLookupTP( [abscissa,'g'], ordinate, T(j) );
    
end

% % % Add filler to cap the graph for lacking data
% % % By interpolating a 5th degree polynomial
% % % Between the nearest 6 points
% % x_edge = [ sf(end-2); sf(end-1); sf(end); sg(end); sg(end-1);  sg(end-2) ];
% % y_edge = [  T(end-2);  T(end-1);  T(end);  T(end);  T(end-1);   T(end-2) ];
% % 
% % A = zeros(6,6);
% % for i = 1:6
% %     for j = 1:6
% %         
% %         A(i,j) = x_edge(i)^(j-1);
% %         
% %     end
% % end
% % 
% % coeffs = A\y_edge;
% % 
% % x_int  = linspace( sf(end-7), sg(end-7), 20 );
% % 
% % y_int  = coeffs(1)          + ...
% %          coeffs(2)*x_int    + ...
% %          coeffs(3)*x_int.^2 + ...
% %          coeffs(4)*x_int.^3 + ... 
% %          coeffs(5)*x_int.^4 + ...
% %          coeffs(6)*x_int.^5 ;
% % 
% % 
% % % Plot results

switch type
    
    case 'linear'
        plot( sf, T, color, sg, T, color ); hold on

      % %  plot( x_int, y_int, ['--',color]);  hold off
        
    case 'semilogy'
        semilogy( sf, T, color, sg, T, color )
        
    case 'semilogx'
        semilogx( sf, T, color, sg, T, color )    
        
    case 'loglog'
        loglog( sf, T, color, sg, T, color )   
        
    otherwise
        error('this is not a valid plot type for this function ')
end

    xlabel(abscissa)
    ylabel(ordinate)

end