function [ out ] = Circular_Duct_Nu( Re,Pr,str )

if numel(Re)~=numel(Pr)
    error('Re and Pr require same number of elements')
end


out = 0*Re;

for j = 1:numel(Re)

%-----------------------------------%
  if Re(j) <= 2000 % Laminar Regime %
%-----------------------------------%

    out(j) = 3.66;

%--------------------------------------------%
  elseif Re(j) >= 2300 % Turbulent Regime    %
%--------------------------------------------%

    switch str
        case 'c'
            out(j) = 0.023*(Re(j).^(0.8)).*(Pr(j).^0.4); %Cold Side is being heated
            %Diddus and Boehler
        case 'h'
            out(j) = 0.023*(Re(j).^(0.8)).*(Pr(j).^0.3); %Hot side being cooled
            %Diddus and Boehler
        otherwise
            error('%s not recognized. need either h for hot and c for cold-side')
    end
    
%------------------------------%
  else  % Transition Regime    %
%------------------------------%

    out1 = 3.66;

    switch str
        case 'c'
            out2 = 0.023*(Re(j).^(0.8)).*(Pr(j).^0.4); %Cold Side is being heated
            %Diddus and Boehler
        case 'h'
            out2 = 0.023*(Re(j).^(0.8)).*(Pr(j).^0.3); %Hot side being cooled
            %Diddus and Boehler
        otherwise
            error('%s not recognized. need either h for hot and c for cold-side')
    end

    out(j) = ( out1.*(2300-Re(j)) + out2.*(Re(j) - 2000) )/300;

%-----%
  end %
%-----%
end

end

