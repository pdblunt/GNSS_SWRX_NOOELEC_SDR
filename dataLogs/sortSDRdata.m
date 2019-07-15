% split SDR data into separate I and Q files for the SW receiver
% written by P. Blunt 2019

clear all;
% input file name
logFileName = 'test_1p5MHz_1kHz_figure8_4';
% load the file
load([logFileName '.mat']);
% output file names
filenameI = [ logFileName '_dataI.dat'];
filenameQ = [logFileName '_dataQ.dat'];
% open output fopen	
fidI = fopen(filenameI, 'w');
fidQ = fopen(filenameQ, 'w');
% write data to output files in int8 format
fwrite(fidI, real(rtlsdr_data.data), 'int8');
fwrite(fidQ, imag(rtlsdr_data.data), 'int8');
% close files
fclose(fidI);
fclose(fidQ);