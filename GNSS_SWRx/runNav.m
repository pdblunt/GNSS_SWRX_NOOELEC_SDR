%% Calculate navigation solutions =========================================
    disp('   Calculating navigation solutions...');
    navSolutions = postNavigation(trackResults, settings);

    disp('   Processing is complete for this data block');
    
     save('navSolutions', 'navSolutions');
     
     plotNavigation(navSolutions, settings);

