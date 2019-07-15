%--------------------------------------------------------------------------
%                           Software GNSS receiver
% 
% Based on code orignally written by Darius Plausinaitis and Dennis M. Akos
% from "A Software-Defined GPS and Galileo Receiver" K. Borre et al.
%--------------------------------------------------------------------------
%
% This script initializes settings and environment of the software receiver.
% Then the processing is started.  Processing is now split into three stages
% Acquisition, Tracking and Navigation.  Use runAcquisition and 
% (runTracking_FLL or runTracking_PLL) and runNav to perform each stage. 
%
% Adapted and updated by P Blunt 2019
%% Clean up the environment first =========================================
clear; close all; clc;

format ('compact');
format ('long', 'g');

%--- Include folders with functions ---------------------------------------
addpath include             % The software receiver functions
addpath geoFunctions        % Position calculation related functions

%% Print startup ==========================================================
fprintf(['\n',...
    'Initialise GNSS SW RX \n\n']);
fprintf('                   -------------------------------\n\n');

%% Initialize constants, settings =========================================
[settings] = initSettingsNOOELEC();

%% Generate plot of raw data and ask if ready to start processing =========
try
    fprintf('Probing data (%s) \n', settings.fileNameI)
	fprintf('and (%s) ...\n', settings.fileNameQ)
    probeData(settings);
catch
    % There was an error, print it and exit
    errStruct = lasterror;
    disp(errStruct.message);
    disp('  (change settings in "initSettingsNOOELEC.m" to reconfigure)')    
    return;
end
    
disp('  Raw IF data plotted ')
disp('  (change settings in "initSettingsNOOELEC.m" to reconfigure)')
disp(' ');
disp('  Processing is now split into three stages;  Acquisition, Tracking and Navigation')
disp('  Use runAcquisition and (runTracking_FLL or runTracking_PLL) and runNav to perform each stage ')

