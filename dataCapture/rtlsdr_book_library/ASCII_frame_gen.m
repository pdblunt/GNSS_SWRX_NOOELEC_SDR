%% ASCII Framing Script - Used by the Transmitter for Frame Generation
% The code in this script performs the operations required to convert the
% ASCII message into individual frames with an appended frame number. 
% The parameters set in the ASCII Transfer Binary Source block mask are 
% retrieved and used to: limit the number of ASCII characters, append 
% appropriate frame numbers to the ASCII message, insert the required 
% number of padding bits to each frame and finally construct the full 
% frame with preamble header.

%% Clear workspace structure
clear('src');                                                              % remove the 'src' (Source) structure if it already exists

%% Obtain Parameters Set in the Simulink Block Mask
src.msg_tx = get_param(gcbh,'msg_tx');                                     % obtain the ASCII message
src.ascii_len = str2num( get_param(gcbh,'ascii_len') );                    % obtain the length for each ASCII bit representation and convert char type to num 
src.fs = str2num( get_param(gcbh,'fs') );                                  % obtain the sampling rate and convert char type to num

%% Initialise Variables
src.preamble = [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,1,1,1,1,1,1,0,0,0,1,1,1,0,0,0,1,1,1]; % set the preamble in unipolar form — used at the beginning of each frame
src.preamble_len = length(src.preamble);                                   % find length of the preamble
src.preamble_pad_len = rem(src.preamble_len,2);                            % determine if preamble requires padding
src.preamble_pad = zeros(1,src.preamble_pad_len);                          % create padding to make preamble an even length (if required)

src.frame_pad_len = 2;                                                     % set the padding to be appended to the end of the frame
src.frame_pad = zeros(1,src.frame_pad_len);                                % initialise padding variable to length set by pad_len

%% Append Frame Number To ASCII Message
src.input_len = length(src.msg_tx);                                        % find length of ASCII message
if src.input_len > 50                                                      % if message length > 50
    src.msg_tx = src.msg_tx(1:50);                                         % limit the message length
end

src.count_lim = 100;                                                       % set max number for counter appended to frames
src.counter = (1:src.count_lim);                                           % create counter
src.ascii_msg = zeros(100,1);                                              % initialise variable for storing full ASCII message
clear('msg_output');
% generate frames of bits after appending counter number
for c = 1:1:src.count_lim
    src.full_msg = [src.msg_tx,' ',num2str(src.counter(c),'%03d')];        % append space character and counter number
    msg_output(c,:) = src.full_msg;                                        % store the generated frames for observation
    src.ascii_msg = de2bi(int8(src.full_msg),src.ascii_len,'left-msb');    % convert message string to matrix of ASCII bit representations  
    
    src.len = size(src.ascii_msg);                                         % obtain both dimensions of ASCII matrix
    src.msg_len = src.len(:,1);                                            % obtain the number of ASCII characters
    src.data_len = src.len(:,1)*src.len(:,2);                              % multiply dimensions to get the vector length of the data
    
    src.temp_msg = reshape(double(src.ascii_msg).',src.data_len,1)';       % reshape ASCII matrix into a single vector
    src.master_msg(c,:) = src.temp_msg;                                    % fill storage variable with bit sequences for each frame
end
clear('c');

%% Construct the Full Frame — With Any Additional Padding
src.hasField = isfield(src , 'master_frame');                              % check if master_frame already exists
if src.hasField
    src = rmfield(src , 'master_frame');                                   % remove master_frame from structure if it does exist
end

% append the message bits to the preamble
for c = 1:1:src.count_lim
    src.temp_frame = [src.preamble,src.preamble_pad,src.master_msg(c,:),src.frame_pad]';   % construct each new frame with the preamble and insert padding
    src.master_frame(:,c) = src.temp_frame;                                % store the frames for transmission
end
src.master_frame_len = length(src.temp_frame);                             % determine length of master frame

run_time = (length(src.temp_frame)*(src.count_lim+1))/src.fs;              % create time variable for running model

% create time variable
src.hasField = isfield(src , 'master_time');                               % check if master_time exists
if src.hasField
    src = rmfield(src , 'master_time');                                    % remove master_time from structure if it does exist
end
src.master_time = (0:1/src.fs:(length(src.master_frame)-1)/src.fs)';       % create time variable for the master frame

%% Create Structure of Parameter Variables for Receiver Simulation
rec.msg_len = src.msg_len;                                                 % create msg_len for simulation of receiver design
rec.ascii_len = src.ascii_len;                                             % create ascii_len for simulation of receiver design
rec.preamble = src.preamble;                                               % create preamble for simulation of receiver design
rec.preamble_len = src.preamble_len;                                       % create preamble_len for simulation of receiver design
rec.preamble_pad_len = src.preamble_pad_len;                               % create preamble_pad_len for simulation of receiver design
rec.frame_pad_len = src.frame_pad_len;                                     % create frame_pad_len for simulation of receiver design
rec.master_frame_len = src.master_frame_len;                               % create master_frame_len for simulation of receiver design

% create the filter coefficients from preamble
rec.filter_coeff = fliplr(src.preamble);                                   % flip the preamble left to right
for l = 1:1:src.preamble_len                                               % execute for the length of the preamble
    if rec.filter_coeff(l) == 0                                            % convert unipolar sequence to bipolar coefficients
        rec.filter_coeff(l) = -1;
    else
        rec.filter_coeff(l) = 1;
    end
end

%% Clear Workspace Variables
clear('src.i','src.ascii_msg','src.data_len','c');                         % clear particular variables from structure

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