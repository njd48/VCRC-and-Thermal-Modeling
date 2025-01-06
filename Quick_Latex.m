
%Make latex report

titular  = '';
author = '';

%Declare additional vars
r_c = 2.8;        % Compression Ratio
Disp = 7.3E-6;

%List of variable names
var_name = {...
    'valve coeff.';...
    'compr. speed';...
    'compression ratio';...
    'displacement';
    'Pod Environment'};
    
%List of variable symbols
var_sym = {...
    'CA';...
    'N';...
    'r_c';...
    'V_{disp}';...
    'T_{pod}'};
    
    
    
%List of values
vals = [...
    CA;...
    RPM;...
    r_c;...
    Disp;...
    T_pod ];
    
    
%List of units
units = {...
    'm^2';...
    'RPM';...
    '';...
    'm^3/rev';...
    '^oC';  };
    
    

%List of figures
list_of_figs = [19:23];

%Name captions
capt = {...
    '';...
    '';...
    '';...
    '';...
    '' };
% '';...
% 'Ts-diagram. example cycles for ambient $T_{amb} = 35 ^oC$';...
% 'Ph-diagram. example cycles for ambient $T_{amb} = 35 ^oC$';...
% 'flow behavior vs ambient';...
% 'Coefficient of Performance vs ambient';...
% 'evaporator overheat vs ambient';...
% 'pressure difference vs ambient';...
% 'flow behavior vs pressure difference';...
% 'evaporator overheat vs pressure difference';...
% };

%Figure width, zero to one
fig_w = 0.8;


assert(numel(var_name) == numel(var_sym));
assert(numel(var_name) == numel(vals));
assert(numel(var_name) == numel(units));

%% Write to file

%open file
% Filename

filename = 'A_Quick_Latex.tex';
fid = fopen( filename, 'wt' );

% write header

fprintf( fid,'\\documentclass[10pt,a4paper]{article} \n');
fprintf( fid,'\\usepackage[utf8]{inputenc} \n');
fprintf( fid,'\\usepackage[english]{babel} \n');
fprintf( fid,'\\usepackage{amsmath} \n');
fprintf( fid,'\\usepackage{amsfonts} \n');
fprintf( fid,'\\usepackage{amssymb} \n');
fprintf( fid,'\\usepackage{graphicx} \n');
fprintf( fid,'\\usepackage{pgfplots} \n');
fprintf( fid,'\\usepackage[a4paper,margin=1in]{geometry} \n');
% 
% \\def\\O{\\mathcal{O}}
% \\def\\e{\\varepsilon}
% \\def\\asm{\\sim}
% \\def\\yh{\\hat{y}}
% \\def\\xh{\\hat{x}}
% \\def\\atan{\\operatorname{atan}}
% \\def\\d{\\operatorname{d}}

%AUTHOR
fprintf( fid,'\\author{%s} \n', author);

%TITLE
fprintf( fid,'\\title{%s} \n', titular);

fprintf( fid,'\n\n');
fprintf( fid,'\\begin{document} \n');
fprintf( fid,'\\maketitle \n');


%----------------------------------------------
%write params table

fprintf( fid,'\\subsection{Parameters} \n\n');

fprintf( fid,'\\begin{table}[h] \n');
fprintf( fid,'\\begin{tabular}{lll} \n');

for j = 1:numel(vals)
    
    if abs(log10(vals(j))) < 4
        fprintf( fid,'%s &: $ %s $ &= %g $ %s $\\\\ \n', var_name{j}, var_sym{j}, vals(j), units{j} );
    else
        fprintf( fid,'%s &: $ %s $ &= %d $ %s $\\\\ \n', var_name{j}, var_sym{j}, vals(j), units{j} );
    end
    
end

fprintf( fid,'\\end{tabular} \n');
fprintf( fid,'\\end{table} \n');
%----------------------------------

%Save figures and Write Figures

fprintf( fid,'\n');
fprintf( fid,'\\subsection{Figures} \n\n');

for j = 1:numel(list_of_figs)
    
    figure( list_of_figs(j) )
    fig_name = sprintf('L_Fig_%g',j);
    saveas(gcf, fig_name, 'png')
    
    fprintf( fid,'\\begin{figure}\n');
    fprintf( fid,'  \\centering\n');
    fprintf( fid,'    \\includegraphics[width=%s\\textwidth]{%s} \n', num2str(fig_w,2),fig_name);
    fprintf( fid,'       \\caption{%s}\n', capt{j});
    fprintf( fid,'\\end{figure}\n');
end

fprintf( fid, '\n\n');
fprintf( fid,'\\end{document}');
