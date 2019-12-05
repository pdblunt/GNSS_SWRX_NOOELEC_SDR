close all; clear all;

% logfile name
logFileName = '..\dataLogs\trial1p5MHz';

filenameI = [logFileName '_dataI.dat'];
filenameQ = [logFileName '_dataQ.dat'];
fidI = fopen(filenameI, 'w');
fidQ = fopen(filenameQ, 'w');

% log duration in seconds
logTime = 60;
sampleRate=1.5e6;
samplesPerFrame=1024;
frames = ceil(logTime*sampleRate/samplesPerFrame);

sdrsetup;

% initialise the SDR receiver
GNSS_SDR_capture_mex(false);

dataFrame = double(zeros(samplesPerFrame,1));
lost = uint32(zeros(frames,1));

for p=1:frames
    [dataFrame, lost(p)] = GNSS_SDR_capture_mex(false);
    
    fwrite(fidI, real(dataFrame), 'int8');
    fwrite(fidQ, imag(dataFrame), 'int8');
end

lostSamples=sum(lost)

GNSS_SDR_capture_mex(true);

fclose(fidI);
fclose(fidQ);