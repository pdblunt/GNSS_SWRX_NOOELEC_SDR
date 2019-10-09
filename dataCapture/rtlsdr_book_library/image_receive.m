%% Image Transfer Protocol Parameters - Used by Receiver for Image Recovery
% The script contains the protocol parameters used by the receiver to
% recover the image frames. It uses the declared parameters to determine
% and calculate the required information for successful recovery.

%% PULL DATA FROM MASK
% Pull data from mask parameter
frm.binary_len = str2num( get_param(gcbh,'binary_len') );                  % obtain the binary length and convert char type to num

%% PROTOCOL PARAMETERS
frm.frame_len = 1000;                                                      % total length of a frame

% bit length declarations
frm.seq_num_bit_len = 8;                                                   % # of bits in header - frame sequence number length
frm.end_flag_bit_len = 1;                                                  % # of bits in header - end frame flag length
frm.header_bit_len = 8;                                                    % # of bits in header - header length
frm.payload_bit_len = 10;                                                  % # of bits in header - payload length
frm.pad_bit_len = 9;                                                       % # of bits in header - padding length

%% Frame Header Structure
%-------------------------------------------------------------------------%
% Frame Header- [preamble, sequence number, end flag, header length,
%                payload length, padding length]
%-------------------------------------------------------------------------%

% set the preamble in unipolar form - used at the beginning of each frame
frm.preamble = [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,1,1,1,1,1,1,0,0,0,1,1,1,0,0,0,1,1,1];
frm.preamble_len = length(frm.preamble);                                   % calculate decimal length of the preamble sequence
frm.preamble_pad_len = rem(frm.preamble_len,2);                            % determine if preamble requires padding
frm.preamble_pad = zeros(1,frm.preamble_pad_len);                          % create padding to make preamble an even length (if required)

% determine the length of the header from the individual field lengths
frm.header_len = frm.preamble_len...                                       % calculate the full length of the header (bits)
    + frm.preamble_pad_len...
    + frm.seq_num_bit_len...
    + frm.end_flag_bit_len...
    + frm.header_bit_len...
    + frm.payload_bit_len...
    + frm.pad_bit_len;

frm.payload_len = frm.frame_len - frm.header_len;                          % calculate the # of available payload storage bits in a frame
frm.data_len = 800;                                                        % set at this value to transmit one pixel column per frame

%-------------------------------------------------------------------------%
% create the matched filter coefficients from the preamble
frm.filter_coeff = fliplr(frm.preamble);                                   % flip the preamble left to right
for l = 1:1:frm.preamble_len                                               % execute for the length of the preamble
    if frm.filter_coeff(l) == 0                                            % convert unipolar sequence to bipolar coefficients
        frm.filter_coeff(l) = -1;
    else
        frm.filter_coeff(l) = 1;
    end
end
clear('l');                                                                % clear variable

% create even and odd filter coefficients for parallel symbol rate filters
frm.filter_coeff_odd = frm.filter_coeff([1 3 5 7 9 11 13 15 17 19 21 23 25 27 29 31 33 35 37 39]);
frm.filter_coeff_even = frm.filter_coeff([2 4 6 8 10 12 14 16 18 20 22 24 26 28 30 32 34 36 38]);
% set value for frame synchronisation associated frame padding
frm.frame_pad_len = 2;

frm.master_frame_len = frm.frame_len;                                      % determine length of master frame

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