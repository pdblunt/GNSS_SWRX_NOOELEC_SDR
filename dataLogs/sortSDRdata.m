% split SDR data into separate I and Q files for the SW receiver
% written by P. Blunt 2019

clear all;
logFileName = 'test3';

load([logFileName '.mat']);


filenameI = [logFileName '_dataI.dat'];
filenameQ = [logFileName '_dataQ.dat'];
fidI = fopen(filenameI, 'w');
fidQ = fopen(filenameQ, 'w');

for i = 1:length(rtlsdr_data.data)
   
    dataI = real(rtlsdr_data.data(i,:));
    dataQ = imag(rtlsdr_data.data(i,:));
    
    fwrite(fidI, dataI, 'int8');
    fwrite(fidQ, dataQ, 'int8');
    
end

fclose(fidI);
fclose(fidQ);
