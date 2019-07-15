# SWRX_NOOELEC_SDR

## dataCapture folder
This folder contains a simulink model, **Record_and_view_L1_Signal.slx** , that allows you to configure the Nooelec SDR front end, visualise the raw data in the time and frequency domains and capture raw data.  **NOTE** – When recording raw data, comment out other monitors (spectrum, etc) and set Matlab task priority to ‘real time’ in the task manager.

## dataLogs folder

**SortSDRdata.m** – splits up raw SDR data into separate I and Q files for the SW receiver


## GNSS_SWRX folder
This folder contains a Maltlab based software GNSS receiver for Nooelec SDR front ends

Software GNSS receiver based on code orignally written by Darius Plausinaitis and Dennis M. Akos
from "A Software-Defined GPS and Galileo Receiver" K. Borre et al.

The script **initNOOELEC.m** initializes settings and environment of the software receiver.
Then the processing is started.  

Processing is now split into the 3 stages - Acquisition, tracking and navigation.  These stages are executed by running the following scripts.

**runAcquisition.m** - Finds the satellites present in the data log and records the satellite Doppler and PRN code delay to initialise the tracking.  

**runTracking_PLL.m** - Tracks the detected signals using a Phase Locked Loop (PLL).

**runTracking_FLL.m** - Tracks the detected signals using a Frequency Locked Loop (FLL).

**runNav.m** - runs the navigation code to calculate the position, velocity and time (PVT) solution
