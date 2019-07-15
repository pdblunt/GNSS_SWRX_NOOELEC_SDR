function [settings, EKF_track]  = initSettingsNOOELEC()
%Functions initializes and saves settings. Settings can be edited inside of
%the function or updated from the command line 
%
%All settings are described inside function code.
%
%settings = initSettingsNOOELEC()
%
%   Inputs: none
%
%   Outputs:
%       settings     - Receiver settings (a structure). 
%
% Adapted and updated by P Blunt 2019

%% Processing settings ====================================================
% Number of milliseconds to be processed used 36000 + any transients (see
% below - in Nav parameters) to ensure nav subframes are provided
settings.msToProcess        = 55000;        %[ms]

% Number of channels to be used for signal processing
settings.numberOfChannels   = 6;

%% Raw signal file name and other parameter ===============================
% This is a "default" name of the data file (signal record) to be used in
% the post-processing mode
% The NOELEC generates two files one to I and Q baseband data, therefore 
% they are given the same root and just end in either I or Q

logFileName = 'L1_m1kHz_1P5MHz_roof_point6_60s_try3';

filenameI = [logFileName '_dataI.dat'];
filenameQ = [logFileName '_dataQ.dat'];

settings.fileNameI           = ['..\datalogs\' filenameI];
settings.fileNameQ           = ['..\datalogs\' filenameQ];;

% Data type used to store one sample
settings.dataType           = 'int8';

% Intermediate, sampling and code frequencies
settings.IF                 = 100e3;      %[Hz]
settings.samplingFreq       = 1.5e6;     %[Hz]
settings.codeFreqBasis      = 1.023e6;      %[Hz]
% Account for any spectrum inversion by the RF front end
settings.spectrumInversion = 1;
% Define number of chips in a code period
settings.codeLength         = 1023;
% Move the starting point of processing. Can be used to start the signal
% processing at any point in the data record (e.g. for long records). fseek
% function is used to move the file read point, therefore advance is byte
% based only. 
% skip one second at the start of the file
settings.skipNumberOfBytes     = settings.samplingFreq;

%% Acquisition settings ===================================================
% Skips acquisition in the script postProcessing.m if set to 1
settings.skipAcquisition    = 0;
% plots FFT surfaces for each satellite if set to 1
settings.plotFFTs    = 0;
% List of satellites to look for. Some satellites can be excluded to speed
% up acquisition
settings.acqSatelliteList   = 1:32;         %[PRN numbers]
% Band around IF to search for satellite signal. Depends on max Doppler
settings.acqSearchBand      = 20;           %[kHz]
% Threshold for the signal presence decision rule
settings.acqThreshold       = 5;
% Threshold for using the tracking measurement in the solution
settings.trackingThreshold  = 25.0;

%% Navigation solution settings ===========================================

% Period for calculating pseudoranges and position
settings.navSolPeriod       = 1000;          %[ms]
% Elevation mask to exclude signals from satellites at low elevation
settings.elevationMask      = 0;           %[degrees 0 - 90]
% Enable/dissable use of tropospheric correction
settings.useTropCorr        = 0;            % 0 - Off
                                            % 1 - On

% True position of the antenna in UTM system (if known). Otherwise enter
% all NaN's and mean position will be used as a reference .
settings.truePosition.E     = nan;
settings.truePosition.N     = nan;
settings.truePosition.U     = nan;

%% Plot settings ==========================================================
% Enable/disable plotting of the tracking results for each channel
settings.plotTracking       = 1;            % 0 - Off
                                            % 1 - On

%% Constants ==============================================================

settings.c                  = 299792458;    % The speed of light, [m/s]
settings.startOffset        = 68.802;       %[ms] Initial sign. travel time

