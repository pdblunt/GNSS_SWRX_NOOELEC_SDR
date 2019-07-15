function acqResults = acquisition(settings)
%Function performs cold start acquisition on the collected "data". It
%searches for GPS signals of all satellites, which are listed in field
%"acqSatelliteList" in the settings structure. Function saves code phase
%and frequency of the detected signals in the "acqResults" structure.
%
%acqResults = acquisition(longSignal, settings)
%
%   Inputs:
%       settings      - Receiver settings. Provides information about
%                       sampling and intermediate frequencies and other
%                       parameters including the list of the satellites to
%                       be acquired.
%   Outputs:
%       acqResults    - Function saves code phases and frequencies of the 
%                       detected signals in the "acqResults" structure. The
%                       field "carrFreq" is set to 0 if the signal is not
%                       detected for the given PRN number. 
 

%% Initialization =========================================================

% Find number of samples per spreading code
samplesPerCode = round(settings.samplingFreq / ...
                        (settings.codeFreqBasis / settings.codeLength));

%% Read in data for Acquisition
[fid, message] = fopen(settings.fileNameI, 'rb');

if (fid > 0)
    % Move the starting point of processing. Can be used to start the
    % signal processing at any point in the data record (e.g. for long
    % records).
    fseek(fid, settings.skipNumberOfBytes, 'bof');    
                          
    % Read 20ms of signal
    [data, count] = fread(fid, [1, 20*samplesPerCode], settings.dataType);

    fclose(fid);
else
    error('Could not data file %s: %s.', settings.fileNameI, message);
end

if (count < 10*samplesPerCode)
    % The file is to short
    error('Could not read enough data from the data file.');
end

% Create two 10msec vectors of data to correlate with and one with zero DC
signalI1 = data(1 : 10*samplesPerCode);
signalI2 = data(10*samplesPerCode+1 : 20*samplesPerCode);

%% Read-In and Create Q Vectors for Acusition
[fid, message] = fopen(settings.fileNameQ, 'rb');

if (fid > 0)
    % Move the starting point of processing. Can be used to start the
    % signal processing at any point in the data record (e.g. for long
    % records).
    fseek(fid, settings.skipNumberOfBytes, 'bof');    
                          
    % Read 20ms of signal
    %fseek(fid,8,'bof');                                                         %Skip to first imaginary value
    [dataQ, count] = fread(fid, [1, 20*samplesPerCode], settings.dataType);

    fclose(fid);
else
    error('Could not data file %s: %s.', settings.fileNameQ, message); 
end 

if (count < 10*samplesPerCode)
        % The file is to short
        error('Could not read enough data from the data file.');
end

% Create two 10msec vectors of data to correlate with and one with zero DC
signalQ1 = dataQ(1 : 10*samplesPerCode);
signalQ2 = dataQ(10*samplesPerCode+1 : 20*samplesPerCode);

% create complex signals
signal1 = signalI1 + 1i*signalQ1;
signal2 = signalI2 + 1i*signalQ2;

longSignal = [signal1 signal2];
signal0DC = longSignal - mean(longSignal);   

%% Initialize Generation of Carrier and CA-Code

% Find sampling period
ts = 1 / settings.samplingFreq;

% Find phase points of the local carrier wave 
phasePoints = (0 : (samplesPerCode-1)) * 2 * pi * ts;

% Number of the frequency bins for the given acquisition band (50Hz steps)
numberOfFrqBins = round(settings.acqSearchBand * 20) + 1;

% Generate all C/A codes and sample them according to the sampling freq.
caCodesTable = makeCaTable(settings);

%% Initialize arrays to speed up the code

% Search results of all frequency bins and code shifts (for one satellite)
results     = zeros(numberOfFrqBins, samplesPerCode);

% Carrier frequencies of the frequency bins
frqBins     = zeros(1, numberOfFrqBins);


%% Initialize acqResults 

% Carrier frequencies of detected signals
acqResults.carrFreq     = zeros(1, 32);
% C/A code phases of detected signals
acqResults.codePhase    = zeros(1, 32);
% Correlation peak ratios of the detected signals
acqResults.peakMetric   = zeros(1, 32);
% noise floor values for SNR estimation
acqResults.noiseValue = 0;

fprintf('(');

%% Perform search for all listed PRN numbers

for PRN = settings.acqSatelliteList
    
%% Correlate signals ======================================================   
    %--- Perform DFT of C/A code ------------------------------------------
    caCodeFreqDom = conj(fft(caCodesTable(PRN, :)));

    %--- Make the correlation for whole frequency band (for all freq. bins)
    for frqBinIndex = 1:numberOfFrqBins
        
        acqRes1 = zeros(1,samplesPerCode);
        acqRes2 = zeros(1,samplesPerCode);
        
        for timeIndex = 1:10

            %--- Generate carrier wave frequency grid (0.05kHz step) -----------
            frqBins(frqBinIndex) = settings.IF - ...
                                   (settings.acqSearchBand/2) * 1000 + ...
                                   0.05e3 * (frqBinIndex - 1);

            %--- Generate local sine and cosine -------------------------------
           sigCarr = exp(-i*frqBins(frqBinIndex) * phasePoints);
            
            %--- "Remove carrier" from the signal -----------------------------
            IP1 = signal1(((timeIndex-1)*samplesPerCode)+1:timeIndex*samplesPerCode);
            I1      = real(sigCarr .* IP1);
            Q1      = imag(sigCarr .* IP1);
            
            IP2 = signal2(((timeIndex-1)*samplesPerCode)+1:timeIndex*samplesPerCode);
            I2      = real(sigCarr .* IP2);
            Q2      = imag(sigCarr .* IP2);
            
            %--- Convert the baseband signal to frequency domain --------------
            IQfreqDom1 = fft(I1 + 1j*Q1);
            IQfreqDom2 = fft(I2 + 1j*Q2);

            %--- Multiplication in the frequency domain (correlation in time
            %domain)
            convCodeIQ1 = IQfreqDom1 .* caCodeFreqDom;
            convCodeIQ2 = IQfreqDom2 .* caCodeFreqDom;

            %--- Perform inverse DFT and store correlation results ------------
            acqRes1 = acqRes1 + (abs(ifft(convCodeIQ1)) .^ 2);
            acqRes2 = acqRes2 + (abs(ifft(convCodeIQ2)) .^ 2);
        end
        
        %--- Check which msec had the greater power and save that, will
        %"blend" 1st and 2nd msec but will correct data bit issues
        if (max(acqRes1) > max(acqRes2))
            results(frqBinIndex, :) = acqRes1;
        else
            results(frqBinIndex, :) = acqRes2;
        end
        
       TempNoiseValue(frqBinIndex) = mean(acqRes1);
                
    end % frqBinIndex = 1:numberOfFrqBins
    
    noiseValue(PRN) = mean(TempNoiseValue);
    
    %--- Plot FFTs of the signal acquistions if plotFFTs is high ---------
    if settings.plotFFTs == 1
        
        yrange = linspace(- 0.05e3*(numberOfFrqBins/2),0.05e3*(numberOfFrqBins/2),numberOfFrqBins);
        xrange = linspace(-settings.codeLength/2,settings.codeLength/2,samplesPerCode);
        
        figure(PRN)
        surf(xrange,yrange,results);
        shading INTERP;
         
        title ('Acquisition results');
        xlabel('Code delay (chips)');
        ylabel('Frequency offset (Hz)');
        axis  ([-settings.codeLength/2 settings.codeLength/2 ...
            -0.5e3*settings.acqSearchBand 0.5e3*settings.acqSearchBand ...
            min(min(results, [], 2)) max(max(results, [], 2))]);
    end %if

    
%% Look for correlation peaks in the results ==============================
    % Find the highest peak and compare it to the second highest peak
    % The second peak is chosen not closer than 1 chip to the highest peak
    
    %--- Find the correlation peak and the carrier frequency --------------
    [peakSize frequencyBinIndex] = max(max(results, [], 2));

    %--- Find code phase of the same correlation peak ---------------------
    [peakSize codePhase] = max(max(results));

    %--- Find 1 chip wide C/A code phase exclude range around the peak ----
    samplesPerCodeChip   = ceil(settings.samplingFreq / settings.codeFreqBasis);
    excludeRangeIndex1 = codePhase - samplesPerCodeChip;
    excludeRangeIndex2 = codePhase + samplesPerCodeChip;

    %--- Correct C/A code phase exclude range if the range includes array
    %boundaries
    if excludeRangeIndex1 < 2
        codePhaseRange = excludeRangeIndex2 : ...
                         (samplesPerCode + excludeRangeIndex1);
                         
    elseif excludeRangeIndex2 >= samplesPerCode
        codePhaseRange = (excludeRangeIndex2 - samplesPerCode) : ...
                         excludeRangeIndex1;
    else
        codePhaseRange = [1:excludeRangeIndex1, ...
                          excludeRangeIndex2 : samplesPerCode];
    end

    %--- Find the second highest correlation peak in the same freq. bin ---
    secondPeakSize = max(results(frequencyBinIndex, codePhaseRange));

    %--- Store result -----------------------------------------------------
    acqResults.peakMetric(PRN) = peakSize/secondPeakSize;
    % If the result is above threshold, then there is a signal ...
    if (peakSize/secondPeakSize) > settings.acqThreshold

%% Fine resolution frequency search =======================================
        
        %--- Indicate PRN number of the detected signal -------------------
        fprintf('%02d ', PRN);
        
        %--- Generate 10msec long C/A codes sequence for given PRN --------
        caCode = generateCAcode(PRN);
        
        codeValueIndex = floor((ts * (1:10*samplesPerCode)) / ...
                               (1/settings.codeFreqBasis));
                           
        longCaCode = caCode((rem(codeValueIndex, 1023) + 1));
    
        %--- Remove C/A code modulation from the original signal ----------
        % (Using detected C/A code phase)
        xCarrier = ...
            signal0DC(codePhase:(codePhase + 10*samplesPerCode-1)) ...
            .* longCaCode;
        
        %--- Find the next highest power of two and increase by 8x --------
        fftNumPts = 8*(2^(nextpow2(length(xCarrier))));
        
        %--- Compute the magnitude of the FFT, find maximum and the
        %associated carrier frequency 
        fftxc = abs(fft(xCarrier, fftNumPts)); 
        
        uniqFftPts = ceil((fftNumPts + 1) / 2);
        [fftMax, fftMaxIndex] = max(fftxc(5 : uniqFftPts-5));
        
        fftFreqBins = (0 : uniqFftPts-1) * settings.samplingFreq/fftNumPts;
        
        %--- Save properties of the detected satellite signal -------------
        acqResults.carrFreq(PRN)  = fftFreqBins(fftMaxIndex);
        acqResults.codePhase(PRN) = codePhase;
        %--- flag to remove the PRN from the noise floor calculation
        presentFlag = 1; 
    
    else
        %--- No signal with this PRN --------------------------------------
        fprintf('. ');
        %--- flag to keep the PRN in the noise floor calculation
        presentFlag = 0; 
            
    end   % if (peakSize/secondPeakSize) > settings.acqThreshold      
end    % for PRN = satelliteList

%=== Acquisition is over ==================================================
fprintf(')\n');
