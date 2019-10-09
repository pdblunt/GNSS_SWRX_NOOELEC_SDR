% script to plot the results from the carrier and timing synch loop

% -------------------------------------------------------------------------
% 
% Plot the results
% 
% use the following lines of code when printing for EPS with Courier font
% set the fonts used to Courier for the current figure
set(gcf,'defaultTextFontName', 'Courier');
set(gcf,'defaultAxesFontName', 'Courier');
%
% -------------------------------------------------------------------------

% % plot I and Q phases prior to the derotation block

% omit unless desired - limited information in this plot.

% figure(100)
% subplot(2,1,1)
% plot(x_in.time,squeeze(x_in.signals.values),'b-x');
% xlabel('Time (s)');
% ylabel('Amplitude');
% title('Unrotated I samples');
% axis([0 max(x_in.time) -0.6 0.6]);
% grid on;
% subplot(2,1,2)
% plot(y_in.time,squeeze(y_in.signals.values),'b-x');
% xlabel('Time (s)');
% ylabel('Amplitude');
% title('Unrotated Q samples');
% axis([0 max(x_in.time) -0.6 0.6]);
% grid on;
% setStandardFigSize(100);
% set(100,'Name','X and Y Prior to Derotation','NumberTitle','off');


% plot sine and cosine errors supplied to the derotation block
figure(101)
subplot(2,1,1)
plot(x_in.time,squeeze(cos_e.signals.values),'b:x');
xlabel('Time');
ylabel('Amplitude');
title('Cosine error');
axis([0 max(x_in.time) -1.1 1.1]);
subplot(2,1,2)
plot(y_in.time,squeeze(sin_e.signals.values),'b:x');
xlabel('Time (s)');
ylabel('Amplitude');
title('Sine error');
axis([0 max(x_in.time) -1.1 1.1]);
setStandardFigSize(101);
set(101,'Name','Sine and Cosine Errors Supplied to Derotation Block','NumberTitle','off');

% plot a sweep of the errors (cosine and sine on X and Y axes) - should
% draw a circle!
figure(102)
hold off
plot(squeeze(cos_e.signals.values),squeeze(sin_e.signals.values),'bx');
xlabel('Cosine Error');
ylabel('Sine Error');
axis square;
grid on;
setStandardFigSize(102);
set(102,'Name','Trajectory of Cosine v Sine Errors','NumberTitle','off');


% plot derotated outputs of the derotation block - should be clear to see
% from this where in the simulation the loops both converge. 
figure(103)
subplot(2,1,1)
plot(x_derot.time,squeeze(x_derot.signals.values),'b.');
xlabel('Time');
ylabel('Amplitude');
title('Derotated X');
axis([0 max(x_derot.time) -1.2 1.2]);
grid on
subplot(2,1,2)
plot(y_derot.time,squeeze(y_derot.signals.values),'b.');
xlabel('Time (s)');
ylabel('Amplitude');
title('Derotated Y');
axis([0 max(y_derot.time) -1.2 1.2]);
grid on
setStandardFigSize(103);
set(103,'Name','Derotated X and Y Components','NumberTitle','off');

% plot the behaviour of the carrier synchroniser loop filter... should show
% transient at the beginning until locked, then straight line incrementing
% phase.
% first obtain some parameters to help define the plot axes
all_CS_signals = [loop_in.signals.values loop_out.signals.values int_out.signals.values];
min_val_CS = min(min(all_CS_signals));
max_val_CS = max(max(all_CS_signals));

if max(abs(max_val_CS)) > max(abs(min_val_CS))      % if the integration is +ve
    y_axis_min = 5*min_val_CS;
    y_axis_max = 1.1*max_val_CS;
else
    y_axis_min = 1.1*min_val_CS;
    y_axis_max = 5*max_val_CS;
end;
    
figure(104)
hold off
plot(loop_in.time,loop_in.signals.values,'Color',[0.1 0.8 0.3]);
title('Carrier Loop Signals');
hold on
plot(loop_out.time,loop_out.signals.values,'Color',[0.8 0.0 0.8]);
plot(int_out.time,int_out.signals.values,'b');
grid on
axis([0 max(loop_out.time) y_axis_min y_axis_max]);
xlabel('Time (s)');
ylabel('Amplitude');
legend('Loop Filter In','Loop Filter Out', 'Integrator Out', 'location','East');
setStandardFigSize(104);
set(104,'Name','Carrier Synchroniser Loop Filter Behaviour','NumberTitle','off');

% show the sine and cosine that are generated in the carrier synchroniser
% to de-rotate the constellation points.
figure(105)
hold off
plot(sin_e.time,sin_e.signals.values,'b')
hold on 
plot(cos_e.time,cos_e.signals.values,'r')
legend('Sine','Cosine');
xlabel('Time (s)');
ylabel('Amplitude');
%grid on;
axis([0 max(sin_e.time) -1.1 1.1]);
setStandardFigSize(105);
set(105,'Name','Sine and Cosine Generated in the Carrier Synchroniser','NumberTitle','off');

% view the step size adjustment of the timing synchroniser to obtain an
% indication of its locking behaviour. 
figure(106)
hold off
plot(timing_ss.time,timing_ss.signals.values,'b');
hold on 
plot(timing_ss.time,1*ones(1,length(timing_ss.time)),'r');
legend('Adjusted Step Size','Nominal Step Size','location','NorthEast');
xlabel('Time (s)');
ylabel('Step Size');
grid on;
axis([0 max(timing_ss.time) (0.9*min(timing_ss.signals.values)) (1.1*max(timing_ss.signals.values))]);
grid on;
setStandardFigSize(106);
set(106,'Name','Step Size Adjustment in the Symbol Timing Synchroniser','NumberTitle','off');

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
