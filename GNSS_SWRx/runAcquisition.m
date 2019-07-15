% Script for running the acquisition code, identifying 
% the satellites in the file

disp ('Starting processing...');

%--- Do the acquisition -------------------------------------------
disp ('Acquiring satellites ...'); 
disp ('PRN detected? Yes = number displayed, No = . displayed) ');


acqResults = acquisition(settings);
plotAcquisition(acqResults);

%% Initialize channels and prepare for the run ============================

% Start further processing only if a GNSS signal was acquired (the
% field FREQUENCY will be set to 0 for all not acquired signals)
if (any(acqResults.carrFreq))
    channel = preRun(acqResults, settings);
    showChannelStatus(channel, settings);
else
    % No satellites to track, exit
    disp('No GNSS signals detected, signal processing finished.');
    trackResults = [];
    return;
end