disp ('Starting processing...');

[fidI, message] = fopen(settings.fileNameI, 'rb');
[fidQ, message] = fopen(settings.fileNameQ, 'rb');

%If success, then process the data
if (fidI > 0)&&(fidQ > 0)
    
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

%% Track the signal =======================================================
    startTime = now;
    disp (['   Tracking started at ', datestr(startTime)]);
    
    % Process all channels for given data block
    [trackResults, channel] = tracking_FLL_2ndOrderUnknownDataComplex(fidI,fidQ, channel, settings);

    % Close the data files
    fclose(fidI);
    fclose(fidQ);
    
    disp(['   Tracking is over (elapsed time ', ...
                                        datestr(now - startTime, 13), ')'])     

    % Auto save the acquisition & tracking results to a file to allow
    % running the positioning solution afterwards.
    disp('   Saving Acq & Tracking results to file "trackingResults.mat"')
    save('trackingResults', ...
                      'trackResults', 'settings', 'acqResults', 'channel');    
    disp ('   Ploting results...');
    PRNlist= zeros(1, settings.numberOfChannels);
    for i=1:settings.numberOfChannels
        if channel(i).PRN ~= 0
            PRNlist(i)=channel(i).PRN;
        end
    end    
    plotIndex = find(PRNlist~=0);
    if settings.plotTracking
        plotTracking(plotIndex, trackResults, settings);
    end
end
