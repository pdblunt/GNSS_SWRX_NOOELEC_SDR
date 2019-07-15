function probeData(settings)
%Function plots raw data information: time domain plot, a frequency domain
%plot and a histogram. 
%   Inputs:
%       fileName        - name of the data file. File name is read from
%                       settings if parameter fileName is not provided.
%
%       settings        - receiver settings. Type of data file, sampling
%                       frequency and the default filename are specified
%                       here. 
%
% Adapted and updated by P Blunt 2019

fileNameIStr = settings.fileNameI;
fileNameQStr = settings.fileNameQ;
     
%% Generate plot of raw data ==============================================
[fid_I, messageI] = fopen(fileNameIStr, 'rb');
[fid_Q, messageQ] = fopen(fileNameQStr, 'rb');

if ((fid_I > 0)&&(fid_Q > 0))
    % Move the starting point of processing. Can be used to start the
    % signal processing at any point in the data record (e.g. for long
    % records).
    fseek(fid_I, settings.skipNumberOfBytes, 'bof');    
    fseek(fid_Q, settings.skipNumberOfBytes, 'bof');    
    
    % Find number of samples per spreading code
    samplesPerCode = round(settings.samplingFreq / ...
                           (settings.codeFreqBasis / settings.codeLength));
                      
    % Read 30ms of signal
    blksize_ms=30;
    [dataI, countI] = fread(fid_I, [1, blksize_ms*samplesPerCode], settings.dataType);
    [dataQ, countQ] = fread(fid_Q, [1, blksize_ms*samplesPerCode], settings.dataType);
    % form complex data
    data=dataI + 1i .* dataQ;
    
    if ((countI < blksize_ms*samplesPerCode)||(countQ < blksize_ms*samplesPerCode))
        % The file is to short
        error('Could not read enough data from the data file.');
    end
    
    %--- Initialization ---------------------------------------------------
    figure(100);
    clf(100);

    timeScale = 0 : 1/settings.samplingFreq : blksize_ms*1e-3;

    %--- Time domain plot -------------------------------------------------
    
    subplot(3, 2, 4);
    plot(1000 * timeScale(1:round(samplesPerCode/50)), ...
        real(data(1:round(samplesPerCode/50))));

    axis tight;    grid on;
    title ('Time domain plot (I)');
    xlabel('Time (ms)'); ylabel('Amplitude');

    subplot(3, 2, 3);
    plot(1000 * timeScale(1:round(samplesPerCode/50)), ...
        imag(data(1:round(samplesPerCode/50))));

    axis tight;    grid on;
    title ('Time domain plot (Q)');
    xlabel('Time (ms)'); ylabel('Amplitude');

    

    %--- Frequency domain plot --------------------------------------------

    
    subplot(3,2,1:2);
    [sigspec,freqv]=pwelch(data, 32758, 2048, 16368, settings.samplingFreq,'twosided');

    plot(([-(freqv(length(freqv)/2:-1:1));freqv(1:length(freqv)/2)])/1e6, ...
        10*log10([sigspec(length(freqv)/2+1:end);
        sigspec(1:length(freqv)/2)]));


    axis tight;
    grid on;
    title ('Frequency domain plot');
    xlabel('Frequency (MHz)'); ylabel('Magnitude');

    %--- Histogram --------------------------------------------------------

    subplot(3, 2, 6);
    hist(real(data), -128:128)
    dmax = max(abs(data)) + 1;
    axis tight;     adata = axis;
    axis([-dmax dmax adata(3) adata(4)]);
    grid on;        title ('Histogram (I)');
    xlabel('Bin');  ylabel('Number in bin');

    subplot(3, 2, 5);
    hist(imag(data), -128:128)
    dmax = max(abs(data)) + 1;
    axis tight;     adata = axis;
    axis([-dmax dmax adata(3) adata(4)]);
    grid on;        title ('Histogram (Q)');
    xlabel('Bin');  ylabel('Number in bin');

elseif (fid_I > 0)
        %=== Error while opening the data Q file ================================
        error('Unable to read file %s: %s.', fileNameQStr, messageQ);
elseif (fid_Q > 0)
        %=== Error while opening the data I file ================================
        error('Unable to read file %s: %s.', fileNameIStr, messageI);
else
    %=== Error while opening the data files ================================
    error('Unable to read file %s: %s. and %s: %s.', fileNameIStr, messageI,fileNameQStr, messageQ);
end % if (fid_I > 0) or (fid_Q > 0)
