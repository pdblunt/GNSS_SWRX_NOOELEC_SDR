%% Code used to determine parameters for ASCII string receiver
% Parameters such as lengths associated with the master frame are
% calculated, as well as the preamble and filter coefficients
% for the matched filter frame synchronisation

%% PULL DATA FROM MASK
rec.msg_len = str2num( get_param(gcbh,'msg_len') );                        % obtain the ASCII message
rec.ascii_len = str2num( get_param(gcbh,'ascii_len') );                    % obtain the ASCII length and convert char type to num 
rec.fs = str2num( get_param(gcbh,'fs') );                                  % obtain the sampling rate and convert char type to num

%% Initialise Variables
rec.preamble = [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,1,1,1,1,1,1,0,0,0,1,1,1,0,0,0,1,1,1]; % set the preamble in unipolar form — used at the beginning of each frame
rec.preamble_len = length(rec.preamble);                                   % find length of the preamble
rec.preamble_pad_len = rem(rec.preamble_len,2);                            % determine if preamble requires padding
rec.preamble_pad = zeros(1,rec.preamble_pad_len);                          % create padding to make preamble an even length (if required)

rec.frame_pad_len = 2;                                                     % set the padding to be appended to the end of the frame
rec.frame_pad = zeros(1,rec.frame_pad_len);                                % initialise padding variable to length set by pad_len

%% FIND MASTER LENGTHS

rec.master_msg_len = rec.msg_len*rec.ascii_len;                            % calculate length of ascii message in bits
rec.master_frame_len = rec.preamble_len+rec.preamble_pad_len+rec.master_msg_len+rec.frame_pad_len; % calculate length of the full frame of data

%% PREAMBLE FILTER COEFFICIENT GENERATION

% create the filter coefficients from the preamble
rec.filter_coeff = fliplr(rec.preamble);                                   % flip the preamble left to right
for l = 1:1:rec.preamble_len                                               % execute for the length of the preamble
    if rec.filter_coeff(l) == 0                                            % convert unipolar sequence to bipolar coefficients
        rec.filter_coeff(l) = -1;
    else
        rec.filter_coeff(l) = 1;
    end
end

% create even and odd filter coefficients for parallel symbol rate filters
rec.filter_coeff_odd = rec.filter_coeff([1 3 5 7 9 11 13 15 17 19 21 23 25 27 29 31 33 35 37 39]);
rec.filter_coeff_even = rec.filter_coeff([2 4 6 8 10 12 14 16 18 20 22 24 26 28 30 32 34 36 38]);

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