function [ asdf ] = plotcycle_TS( T, s, varargin)

assert(numel(T) == numel(s) );


%Begin parsing arguments
k = nargin-2;
j = 0;

cyclecolor = '';
domecolor  = 'k';

while (k ~= 0)
    if strcmp(varargin{j+1}, 'T_env')
        T_amb = varargin{j+2};
        T_pod = varargin{j+3};
        
        %draw cycle environment lines
        env_c = T_amb*[1,1];
        env_e = T_pod*[1,1];
        sssss = [0.6, 2.2];
        plot(sssss,env_e,'--c'), hold on
        plot(sssss,env_c,'--m')
        
        k = k-3;
        j = j+3;
        
    elseif strcmp(varargin{j+1},'cyclecolor')
        cyclecolor = varargin{j+2};
        k = k-2;
        j = j+2;
    elseif strcmp(varargin{j+1},'domecolor')
        domecolor = varargin{j+2};   
        k = k-2;
        j = j+2;
    elseif strcmp(varargin{j+1},'stationlabels')
        for i = 1:numel(T)
            text( 0.025+s(i), 3+T(i), num2str(i) )
        end
        k = k-1;
        j = j+1;
    else
        error('failed to parse arguments or argument not recognized')
    end
    
end

DrawDome('T','s','type','linear','color',domecolor), hold on

asdf = plot(s,T,'-o','color',cyclecolor,'linewidth',2);

hold off
grid on
ylim([-15, 110])


end