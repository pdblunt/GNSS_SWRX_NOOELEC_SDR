close all; clear all;

% logfile name
logFileName = '..\dataLogs\testCapture';

filenameI = [logFileName '_dataI.dat'];
filenameQ = [logFileName '_dataQ.dat'];
fidI = fopen(filenameI, 'w');
fidQ = fopen(filenameQ, 'w');

centerFrequency = 1575.32e6;
sampleRate = 2.4e6;
logTime = 60;

rx = comm.SDRRTLReceiver('0',CenterFrequency = centerFrequency,...
    SampleRate = sampleRate,OutputDataType = 'int16');

[data,metadata] = capture(rx,logTime,'Seconds');
release(rx);

disp('data capture complete writing to file')
fwrite(fidI, real(data), 'int8');
fwrite(fidQ, imag(data), 'int8');

fclose(fidI);
fclose(fidQ);

