function [asdf] = plotcycle_PH( P, h, varargin )

assert(numel(P) == numel(h) );

k = nargin-2;
j = 0;

cyclecolor = '';
domecolor  = 'k';
stationlabels = 0;

while (k ~= 0)
    if strcmp(varargin{j+1},'cyclecolor')
        cyclecolor = varargin{j+2};
        k = k-2;
        j = j+2;
    elseif strcmp(varargin{j+1},'domecolor')
        domecolor = varargin{j+2};   
        k = k-2;
        j = j+2;
    elseif strcmp(varargin{j+1},'stationlabels')
        stationlabels = 1;
        
        k = k-1;
        j = j+1;
    else
        error('failed to parse arguments')
    end
    
end

DrawDome('P','h','type','semilogy','color',domecolor), hold on
%first pass
asdf = plot(h,P,'-o','color',cyclecolor,'linewidth',2); 

if stationlabels
    for j = 1:numel(P)
            text( 10+h(j), 1.02*P(j), num2str(j) )
    end
end

hold off
grid on
ylim([2E2, 1E4])

end

