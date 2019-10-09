function doFFTplot(fs,signals,signalLabels,decFactor,figNum,w_type)
%Plot a scaled fft
%  'fs' is the sampling frequency in Hertz
%  'signals' is a matrix comprising all the signal vectors whose FFTs are to be
%  calculated and plotted.  
%  'signalLabels' contains strings that correspond to each signal vector in the
%  'signals' matrix.  Each string must be the same length, so padding with
%  spaces may be necessary before calling the function.
%  'decFactor' is the decimation factor and is an OPTIONAL ARGUMENT
%  'figNum' is the number you want to attach to the figure and is an OPTIONAL ARGUMENT
%  Do not pass in a value for figNum if you want to overlay plots
%  Example: If 3 signals, x; y and z are to be
%  plotted and the sampling frequency is 100MHz, then this function will be
%  called as follows:
%  doFFTplot(100e6,[x,y,z],['labelX';'labelY';labelZ'])
%  The components that make up 'signals' must be vectors
%  Author: G.Stephen
%  Date:30/03/2006
%  FFT plotting code adapted from:
%  http://www.mathworks.com/support/tech-notes/1700/1702.html
%-------------------------------------------------------------
% Modification to incorporate window selection.
% Author: L. Crockett
% Date:   20/07/2007
% A further parameter is added to the function to allow the user
% to specify a windowing function for FFT plotting. Choices are:
% HANN
% HAMMING
% BLACKMAN
% and the default is RECTANGULAR (i.e. no explicit window).
% 'w_type' is the window type and is an OPTIONAL ARGUMENT.
%-------------------------------------------------------------
% Modification to 20*log10(abs(fft(x)))
% Author: L. Crockett
% Date:   7/7/08
%-------------------------------------------------------------
% Modification to perform scaling on magnitude to produce 0dB
% Author: L. Crockett
% Date:   26/11/13
%-------------------------------------------------------------
% Modification to scale X (frequency axis) for decimation cases
% Modification to set axis limits appropriately
% Author: L. Crockett
% Date:   05/12/13
%-------------------------------------------------------------

% check if a decimation factor has been supplied
if nargin < 4 
   decFactor = 1; 
end 

% check if a figure number has been supplied
if nargin > 4 
   figure(figNum); 
end 

% assign default window if none supplied
if nargin < 6
    w_type = 'rect';
end    
    

numSamples = length(signals(:,1));

%the number of FFTs to be plotted
numVectors = length(signals(1,:));

% Use next highest power of 2 greater than or equal to 
% length of signal to calculate FFT. 
N = 2^(nextpow2(length(signals(:,1))));

if strncmpi(w_type,'hann',4)
    w = hann(N)';
elseif strncmpi(w_type,'hamming',4)
    w = hamming(N)';
elseif strncmpi(w_type,'blackman',4)
    w = blackman(N)';
elseif strncmpi(w_type,'rect',4)
    w = ones(1,N);
else
    w = ones(1,N);                      
end



% Calculate the number of unique points 
numUniquePts = ceil((N+1)/2);

% This is an evenly spaced frequency vector with 
% NumUniquePts points. 
f = (0:numUniquePts-1)*fs/(N*decFactor); 

mag = zeros(numUniquePts,numVectors);

min_mag_temp = 500;

for i=1:numVectors
    
    % create zero padded array for this signal
    sig_vec(i,1:N) = zeros;
    sig_vec(i,1:length(signals(:,i))) = signals(:,i);
    
    % perform windowing on the zero padded signal
    sig_window = sig_vec(i,1:N) .* w;
    
    
    % Take fft, padding with zeros so that length(FFT) is equal to N
    FFTvec = fft(decFactor*sig_window,N);
    
    % FFT is symmetric, throw away second half 
    FFTvec = FFTvec(1:numUniquePts);
    
    % Take the magnitude of fft of x.
    mag(:,i)= abs(FFTvec);

    % Perform scaling to get peak at 0dB.
    max_mag = max(mag(:,i));
    mag(:,i)= mag(:,i)/max_mag;
    
    % get minimum magnitude for later scaling
    min_mag = 20*log10(min(mag(:,i)));
    if min_mag < min_mag_temp
        min_mag_temp = min_mag;
    end
    
    % Generate the plot and labels.
    plot(f,20*log10(mag)); 
    
    if(i==1)
        hold;
    end
        
end

legend(signalLabels,'Location','SouthWest');
xlabel('Frequency (Hz)'); 
ylabel('Magnitude (dB)'); 
grid;

% set an appropriate upper limit for Y based on lower limit calculated
% above.
max_mag_temp = min(5,ceil(min_mag_temp/-10));

axis([0 max(f) min_mag_temp max_mag_temp]);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Software, Simulation Examples and Design Exercises Licence Agreement  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         
%  This license agreement refers to the simulation examples, design
%  exercises and files, and associated software MATLAB and Simulink
%  resources that accompany the book:
% 
%    Title: Software Defined Radio using MATLAB & Simulink and the RTL-SDR 
%    Published by Strathclyde Academic Media, 2015
%    Authored by Robert W. Stewart, Kenneth W. Barlee, Dale S.W. Atkinson, 
%    and Louise H. Crockett
%
%  and made available as a download from www.desktopSDR.com or variously 
%  acquired by other means such as via USB storage, cloud storage, disk or 
%  any other electronic or optical or magnetic storage mechanism. These 
%  files and associated software may be used subject to the terms of 
%  agreement of the conditions below:
%
%    Copyright © 2015 Robert W. Stewart, Kenneth W. Barlee, 
%    Dale S.W. Atkinson, and Louise H. Crockett. All rights reserved.
%
%  Redistribution and use in source and binary forms, with or without 
%  modification, are permitted provided that the following conditions are
%  met:
%
%   (1) Redistributions of source code must retain the above copyright 
%       notice, this list of conditions and the following disclaimer.
%
%   (2) Redistributions in binary form must reproduce the above copyright
%       notice, this list of conditions and the following disclaimer in 
%       the documentation and/or other materials provided with the 
%       distribution.
%
%   (3) Neither the name of the copyright holder nor the names of its 
%       contributors may be used to endorse or promote products derived 
%       from this software without specific prior written permission.
%
%   (4) In all cases, the software is, and all modifications and 
%       derivatives of the software shall be, licensed to you solely for
%       use in conjunction with The MathWorks, Inc. products and service
%       offerings.
%
%  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS 
%  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT 
%  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR 
%  A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT 
%  HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 
%  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT 
%  LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, 
%  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY 
%  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT 
%  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
%  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
%
%%  Audio Tracks used in Simulations Examples and Design Exercises
% 
%  The music and vocal files used within the Examples files and software 
%  within the book were variously written, arranged, performed, recorded 
%  and produced by Garrey Rice, Adam Struth, Jamie Struth, Iain 
%  Thistlethwaite and also Marshall Craigmyle who collectively, and 
%  individually where appropriate, assert and retain all of their 
%  copyright, performance and artistic rights. Permission to use and 
%  reproduce this music is granted for all purposes associated with 
%  MATLAB and Simulink software and the simulation examples and design 
%  exercises files that accompany this book. Requests to use the music 
%  for any other purpose should be directed to: info@desktopSDR.com. For
%  information on music track names, full credits, and links to the 
%  musicians please refer to www.desktopSDR.com/more/audio.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%