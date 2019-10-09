function varargout = control_panel(varargin)
% CONTROL_PANEL MATLAB code for Control_Panel.fig
%      CONTROL_PANEL, by itself, creates a new CONTROL_PANEL or raises the existing
%      singleton*.
%
%      H = CONTROL_PANEL returns the handle to a new CONTROL_PANEL or the handle to
%      the existing singleton*.
%
%      CONTROL_PANEL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CONTROL_PANEL.M with the given input arguments.
%
%      CONTROL_PANEL('Property','Value',...) creates a new CONTROL_PANEL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Control_Panel_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Control_Panel_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Control_Panel

% Last Modified by GUIDE v2.5 17-Jul-2014 14:24:38

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @control_panel_OpeningFcn, ...
                   'gui_OutputFcn',  @control_panel_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before control_panel is made visible.
function control_panel_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output_f args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to control_panel (see VARARGIN)

% Choose default command line output for control_panel
handles.output = hObject;
handles.gain = 25;                % set initial value of gain slider

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes control_panel wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = control_panel_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output_f args (see VARARGOUT);
% Get default command line output from handles structure
varargout{1} = handles.output;

%% Frequency Slider Callback
% --- Executes on slider movement.
function frequency_Callback(hObject, eventdata, handles)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
center_frequency = handles.center_frequency;    % required to use center_frequency from structure
middle = handles.middle;                        % required to use middle from structure
value = get(hObject, 'Value');                  % obtain current value of slider
output = center_frequency + (value-middle);     % compute new slider value
if (output < 20)                                % stop value from being less than 20MHz
    output = 20;
end
output_str = num2str(output);                   % change number to string
set(handles.output_f,'string',output);          % display value to user
set_param('exploring_the_spectrum/Centre Frequency (MHz)','value',output_str); % alter the carrier frequency in the simulation


% --- Executes during object creation, after setting all properties.
function frequency_CreateFcn(hObject, eventdata, handles)

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
middle = 0;                     % set middle value for slider
handles.middle = middle;        % set variable middle as part of handles structure
guidata(hObject, handles);      % add to the guidata for global use
set(hObject,'Value', middle);   % set the slider to the middle value upon creation

% --- Executes on key press with focus on frequency and none of its controls.
function frequency_KeyPressFcn(hObject, eventdata, handles)


%% Input Frequency TextBox
function input_frequency_Callback(hObject, eventdata, handles)
% obtain value of user input and convert string to type double
center_frequency = str2double(get(handles.input_frequency,'String'));
if (center_frequency < 0)                            % invert negative values
    center_frequency = -center_frequency;
end
if (center_frequency < 20)                           % stop value being less than 20MHz
    center_frequency = 20;
end
handles.center_frequency = center_frequency;         % set center_frequency as part of structure
guidata(hObject,handles);                            % add it to the guidata for global use
output_frequency = num2str(center_frequency);        % convert back to string for output
set(handles.output_f,'String', output_frequency);    % set output to show user current carrier frequency
set_param('exploring_the_spectrum/Centre Frequency (MHz)','value',output_frequency); % alter the carrier frequency in the simulation
set(handles.frequency,'Value',0);                    % reset the slider to the middle value 

% --- Executes during object creation, after setting all properties.
function input_frequency_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%% Input Frequency Radio Button Group
% --- Executes on selection change of radio buttons
function uipanel2_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uipanel2 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
switch get(eventdata.NewValue, 'Tag') % get the 'Tag' of the selected button
    case 'fm_range'
        FM = 100;                                          % set frequency for FM  radio region
        center_frequency = FM;                             % set the center frequency 
        handles.center_frequency = center_frequency;       % set center_frequency as part of structure
        guidata(hObject,handles);                          % add it to the guidata for global use
        output_frequency = num2str(center_frequency);      % convert back to string for output
        handles.center_frequency = output_frequency;       % set global value to new frequency 
        set(handles.output_f,'String', output_frequency);  % set output to show user current carrier frequency
        set_param('exploring_the_spectrum/Centre Frequency (MHz)','value',output_frequency); % alter the carrier frequency in the simulation
        set(handles.frequency,'Value',0);   % reset the slider to the middle value 
        
    case 'dab_range'
        DAB = 210;                                         % set frequency for DAB radio region
        center_frequency = DAB;                            % set the center frequency 
        handles.center_frequency = center_frequency;       % set center_frequency as part of structure
        guidata(hObject,handles);                          % add it to the guidata for global use
        output_frequency = num2str(center_frequency);      % convert back to string for output
        handles.center_frequency = output_frequency;       % set global value to new frequency 
        set(handles.output_f,'String', output_frequency);  % set output to show user current carrier frequency
        set_param('exploring_the_spectrum/Centre Frequency (MHz)','value',output_frequency); % alter the carrier frequency in the simulation
        set(handles.frequency,'Value',0);   % reset the slider to the middle value
        
    case 'dtv_range'
        DTV = 480;                                         % set frequency for DTV region
        center_frequency = DTV;                            % set the center frequency 
        handles.center_frequency = center_frequency;       % set center_frequency as part of structure
        guidata(hObject,handles);                          % add it to the guidata for global use
        output_frequency = num2str(center_frequency);      % convert back to string for output
        handles.center_frequency = output_frequency;       % set global value to new frequency 
        set(handles.output_f,'String', output_frequency);  % set output to show user current carrier frequency
        set_param('exploring_the_spectrum/Centre Frequency (MHz)','value',output_frequency); % alter the carrier frequency in the simulation
        set(handles.frequency,'Value',0);   % reset the slider to the middle value 
        
    case 'gsm_range'
        GSM = 900;                                         % set frequency for GSM region
        center_frequency = GSM;                            % set the center frequency 
        handles.center_frequency = center_frequency;       % set center_frequency as part of structure
        guidata(hObject,handles);                          % add it to the guidata for global use
        output_frequency = num2str(center_frequency);      % convert back to string for output
        handles.center_frequency = output_frequency;       % set global value to new frequency 
        set(handles.output_f,'String', output_frequency);  % set output to show user current carrier frequency
        set_param('exploring_the_spectrum/Centre Frequency (MHz)','value',output_frequency); % alter the carrier frequency in the simulation
        set(handles.frequency,'Value',0);   % reset the slider to the middle value 
end

%% Input Frequency Menu Select
% --- Executes on selection change in menu_frequency.
function menu_frequency_Callback(hObject, eventdata, handles)

% Hints: contents = cellstr(get(hObject,'String')) returns menu_frequency contents as cell array
%        contents{get(hObject,'Value')} returns selected item from menu_frequency

contents = get(hObject,'Value');

switch contents
    
    case 1                                                 % left blank in order to show instruction in menu
        
    case 2 
        FM = 100;                                          % set frequency for FM  radio region
        center_frequency = FM;                             % set the center frequency 
        handles.center_frequency = center_frequency;       % set center_frequency as part of structure
        guidata(hObject,handles);                          % add it to the guidata for global use
        output_frequency = num2str(center_frequency);      % convert back to string for output
        set(handles.test,'String', output_frequency);  % set output to show user current carrier frequency
        set_param('exploring_the_spectrum/Centre Frequency (MHz)','value',output_frequency); % alter the carrier frequency in the simulation
        set(handles.frequency,'Value',0);   % reset the slider to the middle value 
        
    case 3 
        DAB = 220;                                         % set frequency for DAB radio region
        center_frequency = DAB;                            % set the center frequency 
        handles.center_frequency = center_frequency;       % set center_frequency as part of structure
        guidata(hObject,handles);                          % add it to the guidata for global use
        output_frequency = num2str(center_frequency);      % convert back to string for output
        set(handles.output_f,'String', output_frequency);  % set output to show user current carrier frequency
        set_param('exploring_the_spectrum/Centre Frequency (MHz)','value',output_frequency); % alter the carrier frequency in the simulation
        set(handles.frequency,'Value',0);   % reset the slider to the middle value 
        
    case 4 
        DTV = 430;                                         % set frequency for DTV region
        center_frequency = DTV;                            % set the center frequency 
        handles.center_frequency = center_frequency;       % set center_frequency as part of structure
        guidata(hObject,handles);                          % add it to the guidata for global use
        output_frequency = num2str(center_frequency);      % convert back to string for output
        set(handles.output_f,'String', output_frequency);  % set output to show user current carrier frequency
        set_param('exploring_the_spectrum/Centre Frequency (MHz)','value',output_frequency); % alter the carrier frequency in the simulation
        set(handles.frequency,'Value',0);   % reset the slider to the middle value 
        
    case 5
        GSM = 900;                                         % set frequency for GSM region
        center_frequency = GSM;                            % set the center frequency 
        handles.center_frequency = center_frequency;       % set center_frequency as part of structure
        guidata(hObject,handles);                          % add it to the guidata for global use
        output_frequency = num2str(center_frequency);      % convert back to string for output
        set(handles.output_f,'String', output_frequency);  % set output to show user current carrier frequency
        set_param('exploring_the_spectrum/Centre Frequency (MHz)','value',output_frequency); % alter the carrier frequency in the simulation
        set(handles.frequency,'Value',0);   % reset the slider to the middle value 
        
    otherwise 
end

% --- Executes during object creation, after setting all properties.
function menu_frequency_CreateFcn(hObject, eventdata, handles)
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%% Input Gain Textbox
function input_gain_Callback(hObject, eventdata, handles)

% Hints: get(hObject,'String') returns contents of input_gain as text
%        str2double(get(hObject,'String')) returns contents of input_gain as a double
% obtain value of user input and convert string to type double
gain = str2double(get(handles.input_gain,'String'));
handles.gain = gain;                                % set gain as part of structure
guidata(hObject, handles);                          % add it to the guidata for global use
if (gain < 0)                                       % invert negative gain values
    gain = -gain;
end
if (gain > 50)                                      % give max value of 50 for gain
    gain = 50;
end
output_gain = num2str(gain,'%.0f');                 % convert back to string for output
set(handles.output_gain,'String', output_gain);     % set output to show user current gain
set(handles.gain_slider,'Value', gain);             % set slider value to user input
set_param('exploring_the_spectrum/RF Gain','value',output_gain);   % alter the gain in the simulation

% --- Executes during object creation, after setting all properties.
function input_gain_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%% Gain Slider Callback
% --- Executes on slider movement.
function gain_slider_Callback(hObject, eventdata, handles)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
gain = handles.gain;                                % set gain as part of structure
middle_gain = gain;                                 % set middle value to gain
gain_value = get(hObject, 'Value');                 % obtain value from slider
gain_value_str = num2str(gain_value,'%.0f');        % convert to string for output
gain_output = gain + (gain_value-middle_gain);      % compute the new position of the gain value
gain_output_num = str2num(num2str(gain_output,'%.1f')); % limit output to 1 decimal place
set(handles.output_gain,'string',gain_output_num);  % set output to show user current gain
set_param('exploring_the_spectrum/RF Gain','value',gain_value_str);% alter the gain in the simulation

% --- Executes during object creation, after setting all properties.
function gain_slider_CreateFcn(hObject, eventdata, handles)
% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
maximum_gain = get(hObject,'Max');                  % obtain max gain value
middle_gain = maximum_gain/2;                       % obtain middle value from max
handles.middle_gain = middle_gain;                  % set gain as part of structure
guidata(hObject, handles);                          % add it to the guidata for global use
initial_gain = handles.initial_gain;                % use initial gain value from structure
set(hObject,'Value', initial_gain);                 % set the initial slider position

% --- Executes on button press in simulation_stop.
function simulation_stop_Callback(hObject, eventdata, handles)

% stop simulation on button press
set_param('exploring_the_spectrum','SimulationCommand', 'stop');  

% --- Executes on button press in simulation_start.
function simulation_start_Callback(hObject, eventdata, handles)

% start simulation on button press
set_param('exploring_the_spectrum','SimulationCommand', 'start'); 

% --- Executes during object creation, after setting all properties.
function output_f_CreateFcn(hObject, eventdata, handles)
% hObject    handle to output_f (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% obtain initial frequency from the model
initial_freq = get_param('exploring_the_spectrum/Centre Frequency (MHz)','value');
initial_freq = str2num(initial_freq); % convert the string to a number 
if (initial_freq < 0)                 % invert negative frequency values
    initial_freq = -initial_freq;
    % alter the carrier frequency in the simulation
    set_param('exploring_the_spectrum/Centre Frequency (MHz)','value',num2str(initial_freq)); 
end
handles.initial_freq = initial_freq;  % add to the structure
handles.center_frequency = initial_freq; 
guidata(hObject,handles);             % add to guidata
set(hObject,'String', initial_freq);  % set output to show user initial carrier frequency


% --- Executes during object creation, after setting all properties.
function output_gain_CreateFcn(hObject, eventdata, handles)
% hObject    handle to output_gain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% obtain initial gain value from the model
initial_gain = get_param('exploring_the_spectrum/RF Gain','value');
initial_gain = str2num(initial_gain); % convert string to a number
if (initial_gain < 0)                 % invert negative gain values
    initial_gain = -initial_gain;
elseif (initial_gain > 50)            % limit gain to a maximum of 50
    initial_gain = 50;
end
handles.initial_gain = initial_gain;  % add to structure for use elsewhere
guidata(hObject, handles);            % add to guidata
set(hObject,'String', initial_gain);  % set output to show user initial gain


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