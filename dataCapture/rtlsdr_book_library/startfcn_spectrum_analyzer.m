%% startfcn_spectrum_analyzer
function startfcn_spectrum_analyzer

try
    
    % custom colours
    h_spectrum_colour.window_grey = [0.95 0.95 0.95];   % background light grey
    h_spectrum_colour.axes_grey = [0.1 0.1 0.1];        % dark grey for axes titles etc
    h_spectrum_colour.plot_white = [1 1 1];             % white for plot background
    h_spectrum_colour.line = [...                       % line colours  (RGB colour code)
        0.0000    0.4470    0.7410                      % blue          0072BD
        1.0000    0.5490    0.0000                      % orange        FF8C00
        0.4000    0.7500    0.1000                      % green         66BF19
        1.0000    0.0000    0.0000                      % red           FF0000
        0.4940    0.1840    0.5560                      % purple        7E2F8E
        0.3010    0.7450    0.9330                      % light blue    4DBEEE
        0.5451    0.2706    0.1000                      % brown         8C451A
        0.2000    0.2000    0.2000                      % grey          333333
        1.0000    0.1000    0.5000                      % pink          FF1A80
        0.1000    0.5000    0.0000 ];                   % dark green    1A8000
    
    % turn on all handles
    set(0, 'showhiddenhandles', 'on');
    
    % get all 'spectrum analyzer' figure handle
    h_spectrum = findobj(0, 'Tag', 'spcui_scope_framework');
    
    % work on one at a time
    for j=1:1:length(h_spectrum)
        
        % check if spectrum analyzer or constellation diagram
        x_title = h_spectrum(j).CurrentAxes.XLabel.String;
        if strcmp(x_title(1:9),'Frequency');                                    % is it a spectrum analyzer?
            
            % modify figure/ axes
            h_spectrum(j).Renderer = 'painters';                                % change render mode to remove pixelation
            h_spectrum(j).Color = h_spectrum_colour.window_grey;                % window background
            h_spectrum(j).CurrentAxes.Color = h_spectrum_colour.plot_white;     % plot background
            h_spectrum(j).CurrentAxes.GridColor = h_spectrum_colour.axes_grey;	% grid
            h_spectrum(j).CurrentAxes.GridLineStyle = '--';                     % dashed grid
            h_spectrum(j).CurrentAxes.XColor = h_spectrum_colour.axes_grey;     % xaxis colour
            h_spectrum(j).CurrentAxes.YColor = h_spectrum_colour.axes_grey;     % yaxis colour
            h_spectrum(j).CurrentAxes.ZColor = h_spectrum_colour.axes_grey;     % zaxis colour
            
            % get line handles
            h_spectrum_line = findobj(h_spectrum(j).CurrentAxes,'type','line');
            
            % modify lines
            for i=0:1:length(h_spectrum_line)-1
                if i<10
                    set(h_spectrum_line(length(h_spectrum_line)-i),'linewidth',1.5);
                    set(h_spectrum_line(length(h_spectrum_line)-i),'color',h_spectrum_colour.line(1+i,:));
                end
            end
            
        end
        
    end
    
    clear('i','j');
    
end

end

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