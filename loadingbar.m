%loading bar

function loadingbar( k, K )
    
    barh(k/K*100)
    xlim([0,100])
    title('Program Progress')
    drawnow;
end