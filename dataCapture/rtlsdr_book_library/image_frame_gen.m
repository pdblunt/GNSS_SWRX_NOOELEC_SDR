%% Image Framing Script - Used by the Transmitter for Frame Generation
% The code loads the image to be transmitted and implements a segmentation
% process to store columns of the image in individual frames. These frames
% are constructed from a header which contains the preamble sequence and
% information fields, and the payload with appended padding. The padding
% ensures that all frames are of equal length.
%
% The frame structure used is shown here:
%
% General Frame Structure: [___Header___|_____________Payload_____________]
%
% Normal Frame - with pad: [___Header___|__________Data_________|_Padding_]
%
% When the data in a frame is less than the data field length:
%
% Padding increases:       [___Header___|______Data_____|_____Padding_____]

%% Obtain Parameters Set in the Simulink Block Mask
frm.filename = get_param(gcbh,'filename');                                                  % obtain the filename of the image to be sent
frm.binary_len = str2num( get_param(gcbh,'binary_len') );                                   % obtain the ASCII length and convert char type to num 
frm.fs = str2num( get_param(gcbh,'fs') );                                                   % obtain the sampling rate and convert char type to num 

%% Declare Protocol Parameters

% frame length declaration
frm.frame_len = 1000;                                                                       % total length of a frame

% bit length declarations
frm.seq_num_bit_len = 8;                                                                    % # of bits in header - frame sequence number length
frm.end_flag_bit_len = 1;                                                                   % # of bits in header - end frame flag length
frm.header_bit_len = 8;                                                                     % # of bits in header - header length
frm.payload_bit_len = 10;                                                                   % # of bits in header - payload length
frm.pad_bit_len = 9;                                                                        % # of bits in header - padding length

%% Frame Header Structure
%-------------------------------------------------------------------------%
% Frame Header- [preamble, sequence number, end flag, header length,
%                payload length, padding length]
%-------------------------------------------------------------------------%

% set the preamble in unipolar form - used at the beginning of each frame
frm.preamble = [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,1,1,1,1,1,1,0,0,0,1,1,1,0,0,0,1,1,1];
frm.preamble_len = length(frm.preamble);                                                    % calculate decimal length of the preamble sequence
frm.preamble_pad_len = rem(frm.preamble_len,2);                                             % determine if preamble requires padding
frm.preamble_pad = zeros(1,frm.preamble_pad_len);                                           % create padding to make preamble an even length (if required)

% determine the length of the header from the individual field lengths
frm.header_len = frm.preamble_len...                                                        % calculate the full length of the header (bits)
    + frm.preamble_pad_len...
    + frm.seq_num_bit_len...
    + frm.end_flag_bit_len...
    + frm.header_bit_len...
    + frm.payload_bit_len...
    + frm.pad_bit_len;

frm.payload_len = frm.frame_len - frm.header_len;                                           % calculate the # of available payload storage bits in a frame
frm.data_len = 800;                                                                         % set at this value to transmit one pixel column per frame

%-------------------------------------------------------------------------%
% convert decimal lengths of fields to binary and construct header
frm.end_flag_low = 0;                                                                       % declare data end flag low for all frames but last
frm.end_flag_high = 1;                                                                      % declare data end flag high for last frame
frm.header_len_bits = de2bi(frm.header_len,frm.header_bit_len,'left-msb');                  % convert decimal header length to binary representation
frm.payload_len_bits = de2bi(frm.payload_len,frm.payload_bit_len,'left-msb');               % convert decimal payload length to binary representation

frm.header_norm = [frm.preamble,...                                                         % construct normal frame header with end flag low
    frm.preamble_pad,...
    frm.end_flag_low,...
    frm.header_len_bits,...
    frm.payload_len_bits];

frm.header_final = [frm.preamble,...                                                        % construct final frame header with end flag high
    frm.preamble_pad,...
    frm.end_flag_high,...
    frm.header_len_bits,...
    frm.payload_len_bits];

%% Message Acquisition & Frame/ Padding Calculation
%-------------------------------------------------------------------------%
% -Load image data
% -Calculate length of data to be transmitted in bits
% -Calculate # of frames required and pad lengths; three possibilities:
%       > Only one frame is needed to transmit data:
%                 Either - [___Header___|__________Data_________|_Padding_]
%                 Or -     [___Header___|______Data_____|_____Padding_____]
%
%       > More than one frame is needed; last frame's data field is full:
%             All Frames - [___Header___|__________Data_________|_Padding_]
%
%       > More than one frame is needed; last frame's data field is not
%         full and requires a larger amount of padding:
%          Normal Frames - [___Header___|__________Data_________|_Padding_]
%             Last Frame - [___Header___|______Data_____|_____Padding_____]
%
%-------------------------------------------------------------------------%

frm.input = load(frm.filename);                                                             % acquire the data to be sent
frm.image_size = size(frm.input.image);                                                     % find the dimensions of the image
frm.total_img_pixels = frm.image_size(:,1)*frm.image_size(:,2);                             % find the number of pixels in the image
frm.pixels_bit_len = frm.total_img_pixels*frm.binary_len;                                   % convert this length to a binary representation length

frm.padding_len = frm.payload_len - frm.data_len;                                           % calculate the # of padding bits required in a 'normal' frame
frm.normal_frame_pad = randi([0 1], 1, frm.padding_len);                                    % create variable and store normal frame padding                                       
frm.pad_bits_norm = de2bi(int8(frm.padding_len),frm.pad_bit_len,'left-msb');                % convert padding length to binary representation
frm.header_norm = [frm.header_norm, frm.pad_bits_norm];                                     % append binary representation to normal frame header

if frm.pixels_bit_len > frm.data_len                                                        % execute if the data to be transmitted is longer than the data length of one frame
    frm.final_data_bits = rem(frm.pixels_bit_len,frm.data_len);                             % calculate the amount of data that will be sent in the last frame
    if frm.final_data_bits > 0                                                              % execute if the last frame's data does not exactly equal the data_len 
        frm.no_of_frames = floor(frm.pixels_bit_len/frm.data_len) + 1;                      % calculate the # of frames required, including the additional last frame             
        frm.final_frame_pad = randi([0 1], 1, frm.payload_len - frm.final_data_bits);       % calculate the padding required for the last frame
    else
        frm.no_of_frames = floor(frm.pixels_bit_len/frm.data_len);                          % calculate the # of frames when the image data is exactly divisible by the data_len
        frm.final_frame_pad = frm.normal_frame_pad;                                         % final frame padding is the same as a normal frame padding in this case
    end
    frm.pad_len_final = length(frm.final_frame_pad);                                        % find decimal length of final frame padding
    frm.pad_bits_final = de2bi(frm.pad_len_final,frm.pad_bit_len,'left-msb');               % convert value to binary form
    frm.header_final = [frm.header_final, frm.pad_bits_final];                              % append binary representation to final frame header
else                                                                                        % execute if data to be transmitted can be sent using one frame
    frm.no_of_frames = 1;                                                                   % set frame # to 1
    if frm.pixels_bit_len == frm.data_len                                                   % execute if the data to be transmitted exactly fills the data_len space in the frame
        frm.one_frame_pad = frm.normal_frame_pad;                                           % set the padding for this one frame equal to normal frame padding
    else                                                                                    % execute if the data to be transmitted is less than the data_len space in the frame                   
        frm.one_frame_pad = randi([0 1], 1, frm.payload_len-frm.pixels_bit_len);            % create the larger padding required for this frame
    end
    frm.pad_len_one = length(frm.one_frame_pad);                                            % find decimal length of the one frame padding
    frm.pad_bits_one = de2bi(frm.pad_len_one,frm.pad_bit_len,'left-msb');                   % convert value to binary form
    frm.header_one = [frm.header_final, frm.pad_bits_one];                                  % append binary representation to final frame header; as one frame in this case is the final frame
end

%% Data Segmentation, Payload Creation & Frame Construction

% convert decimal pixel values to a matrix of binary bits
frm.binary_image = reshape(frm.input.image,1,frm.total_img_pixels)';                        % reshape loaded data to a single column of data 
frm.binary_image = de2bi(frm.binary_image,frm.binary_len,'left-msb');                       % convert decimal values to binary representations

% reshape ascii matrix into a single vector
frm.temp_storage = reshape(frm.binary_image',frm.pixels_bit_len,1)';                        % reshape binary row representations to a single row of data

frm.hasField = isfield(frm , 'master_frame');                                               % test to see if 'master_frame' already exists in the 'frm' structure
if frm.hasField
    frm = rmfield(frm , 'master_frame');                                                    % if it exists, remove it
end

for i = 1:1:frm.no_of_frames                                                                % loop for # of frames calculated earlier
    if frm.no_of_frames == 1;                                                               % if only one frame - construct frame with header_one and one_frame_pad
        frm.master_frame = [frm.header_one(1:frm.preamble_len+frm.preamble_pad_len),...     % preamble sequence
                             de2bi(i,frm.seq_num_bit_len,'left-msb'),...                    % convert frame number to binary representation for sequence number
                             frm.header_one(frm.preamble_len+frm.preamble_pad_len+1:end),...                     % remaining header fields
                             frm.temp_storage(1:end),...                                    % all of the data to be transmitted in data field of frame
                             frm.one_frame_pad];                                            % one frame padding
    else
        if i ~= frm.no_of_frames
            frm.temp_frame = [frm.header_norm(1:frm.preamble_len+frm.preamble_pad_len),...  % preamble sequence
                               de2bi(i,frm.seq_num_bit_len,'left-msb'),...                  % convert frame number to binary representation for sequence number
                               frm.header_norm(frm.preamble_len+frm.preamble_pad_len+1:end),...                  % remaining header fields
                               frm.temp_storage(((i-1)*frm.data_len)+1:i*frm.data_len),...  % fill data_len field with a part of the image data
                               frm.normal_frame_pad];                                       % normal frame padding
        else
            frm.temp_frame = [frm.header_final(1:frm.preamble_len+frm.preamble_pad_len),... % preamble sequence
                               de2bi(i,frm.seq_num_bit_len,'left-msb'),...                  % convert frame number to binary representation for sequence number
                               frm.header_final(frm.preamble_len+frm.preamble_pad_len+1:end),...                 % remaining header fields
                               frm.temp_storage(((i-1)*frm.data_len)+1:end),...             % fill data_len field with remaining image data
                               frm.final_frame_pad];                                        % final frame padding
        end
        frm.master_frame(:,i) = frm.temp_frame;                                             % store each generated frame in a master_frame variable
    end
end
clear('i');                                                                                 % clear the frame # counter

frm.master_frame_len = length(frm.temp_frame);                                              % determine length of master frame

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