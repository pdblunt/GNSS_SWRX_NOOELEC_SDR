classdef import_rtlsdr_data < matlab.System
    
    %IMPORT_RTLSDR_DATA Import saved RTL-SDR data from a timeseries file
    %
    %   - This system object can be used in place of a comm.SDRRTLReceiver
    %     system object in sitations where you wish to use recorded data rather
    %     than data received live from an RTL-SDR
    %   - It works on the same basis that the 'Import RTL-SDR Data' Simulink
    %     block does, allowing you to reference and load data from a timeseries
    %     file created with the 'Save RTL-SDR Data' block
    %   - You can specify what you want the filepath to be, along with the output
    %     frame size
    %   - Frames of data can be extracted from an object of this class using the
    %     step(...) function
    %
    %     TUNABLE PARAMETERS:
    %
    %       filepath	% filepath to timeseries data file
    %       frm_size	% output frame size
    %       data_type   % output data type (int16, single, double)
    %
    %     NON-TUNABLE PARAMETERS:
    %
    %       data    	% matrix that stores all RTL-SDR data from the loaded timeseries
    %       fs          % sampling frequency of loaded data
    %
    %     EXAMPLE USE:
    %
    %       % initialise system object
    %       obj_rtlsdr = rtlsdr_import_data(...
    %           'filepath', 'folder\folder\file.mat',...
    %           'frm_size', 4096,...
    %           'data_type', 'single');
    %
    %       % get a frame of data
    %       data = step(obj_rtlsdr);
    %
    %       % print the sampling frequency of the data to the MATLAB command window
    %       disp(['fs = ',num2str(obj_rtlsdr.fs),'Hz']);
    %
    %       % plot the real component of the data
    %       figure;
    %       xaxis = 0:1/obj_rtlsdr.fs:(length(data)-1)/obj_rtlsdr.fs;
    %       plot(xaxis,real(data));
    %       xlim([0,max(xaxis)]);
    %       title('Real Component of Imported RTL-SDR Data');
    %       xlabel('Time (seconds)');
    %       ylabel('Signal Amplitude');
    %
    %     See also STEP, COMM.SDRRTLReceiver
    
    %% PROPERTIES
    
    % public, tunable properties
    properties
        filepath = '';  % filepath to data
        frm_size;       % output frame size
        data_type = ''; % output data type
    end
    
    % public read only property
    properties (Nontunable)
        data;       % matrix to store all data from the loaded timeseries
        fs;         % sampling frequency of loaded data
    end
    
    % private property
    properties (Access = private)
        nsample;    % counter used to store position
    end
    
    %% METHODS
    
    % public methods
    methods
        % constructor to allow parameter setting
        function obj = import_rtlsdr_data(varargin)
            % support 'name-value' pair input
            setProperties(obj,nargin,varargin{:});
        end
    end
    
    % private methods
    methods (Access = protected)
        
        % run setup first time step(...) is called
        function setupImpl(obj)
            
            % try to load data
            try
                file = load(obj.filepath);
            catch
                error('import_rtlsdr_data: Failed to open data file');
            end
            
            % try to extract information from time series
            try
                % timeseries parameters
                ts_data = file.rtlsdr_data.data;
                ts_data = ts_data(:,:)';
                [ts_nfrm,ts_frmsize] = size(file.rtlsdr_data.data);
                ts_fs = ts_frmsize/file.rtlsdr_data.TimeInfo.Increment;
            catch
                error('import_rtlsdr_data: Cannot load required data from file');
            end
            
            % save sampling frequency
            obj.fs = ts_fs;
            
            % make into single dimension matrix
            obj.data = reshape(ts_data,1,ts_frmsize*ts_nfrm)';
            
            % initialise nsample
            obj.nsample = 1;
            
            % check that the entered data type is allowed
            if (strcmp(obj.data_type,'int16') + ...
               strcmp(obj.data_type,'double') + ...
               strcmp(obj.data_type,'single') ~= 1)
           
                error('import_rtlsdr_data: Invalid data type');
            end
            
        end
        
        % return data through step(...) process
        function frm = stepImpl(obj)
            
            % try to output data (while it is still available)
            try
                % output next frame of data
                frm = obj.data(obj.nsample:obj.nsample+obj.frm_size-1);
                
                % update frame position
                obj.nsample = obj.nsample + obj.frm_size;

            catch
                
                % try to output first frame again
                try
                    % reset frame position
                    obj.nsample = 1;
                    
                    % output first frame of data again
                    frm = obj.data(obj.nsample:obj.nsample+obj.frm_size-1);
                
                % if this fails, output generic frame to avoid errors    
                catch
                    for sample = 1:obj.frm_size
                        frm(sample,1) = single(0.1 + 0.1i);
                    end
                end                
            end
            
            % try to perform typecast before outputting
            try
                % typecast to change frame data type
                frm = cast(frm,obj.data_type);
            catch
                error('import_rtlsdr_data: Invalid data type');
            end
        end        
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