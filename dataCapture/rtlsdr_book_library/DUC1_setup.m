% -------------------------------------------------------------------------
% Script to design filters (and create filter objects) 
% for a Digital Upconverter (DUC).
%
% Louise Crockett, December 2013.
%
% Filter cascade is:
%                      (1) Square Root Raised Cosine        (RRC)
%                      (2) CIC Compensation Filter          (CFIR)
%                      (3) Cascade Integrate Comb Filter    (CIC)
%
% rates (based on initial values in the script):
%
%        1.5625MHz        6.25MHz        12.5MHz            100MHz
%
% input             RRC             CFIR            CIC             output
%                   (^4)            (^2)            (^8)
%
%--------------------------------------------------------------------------

%-----------------------------
% ROOT RAISED COSINE SECTION
%-----------------------------

% Original data rate is 1.5625 MSPS. Hence original signal BW is 0.78125 MHz.
% Rolloff factor will increase the BW by that ratio, e.g. with rolloff =
% 0.25, the BW will be 0.78125 * 1.25 = 0.9765625MHz. Call it 1MHz for
% filtering!

RRC_rolloff     = 0.22;     % RRC rolloff factor
RRC_order       = 34;       % RRC order is one less than the filter length.
RRC_L_factor    = 4;        % interpolate by this number in the RRC

% create a SQUARE ROOT RAISED COSINE filter based on the above parameters. 
dRRC = fdesign.pulseshaping(RRC_L_factor,'Square Root Raised Cosine','N,Beta',RRC_order,RRC_rolloff);
hRRCtemp = design(dRRC);
hRRC = mfilt.firinterp(RRC_L_factor, hRRCtemp.Numerator);

%---------------------------------------------------------------
% CIC COMPENSATION (CFIR) SECTION
% (Note: some parameters belong to the CIC being compensated.)
%---------------------------------------------------------------

CFIR_L_factor       = 2;        % interpolation factor of CFIR
CIC_D               = 1;        % differential delay of CIC
CIC_N               = 5;        % number of stages in CIC
CIC_R               = 8;        % interpolation factor of CIC
CFIR_Fp             = 1e6;      % passband edge frequency of CFIR
CFIR_Fst            = 2e6;      % stopband edge frequency of CFIR
CFIR_Ap             = 0.2;      % passband ripple of CFIR (in dB)
CFIR_Ast            = 80;       % stopband attenuation of CFIR (in dB)
CFIR_Fs             = 12.5e6;   % OUTPUT (interpolated) sampling frequency of CFIR

% create a CIC COMPENSATION FILTER based on the above parameters
dCFIR = fdesign.interpolator(CFIR_L_factor,'ciccomp', CIC_D, CIC_N, CIC_R, ...
	'Fp,Fst,Ap,Ast', ...
	CFIR_Fp, CFIR_Fst, CFIR_Ap, CFIR_Ast, CFIR_Fs);
hCFIR = design(dCFIR,'equiripple');

% create a CFIR SCALING FACTOR OBJECT
% (NOTE: the coefficients are scaled to prevent loss of signal power due to
% insertion of zero samples - this requires correction for convenient 
% plotting of the spectrum.)
K_cfir = 1/CFIR_L_factor;        % gain compensation value
hKcfir = dfilt.scalar(K_cfir);

%--------------
% CIC SECTION
%--------------

CIC_Fs              = 100e6;    % OUTPUT (interpolated) sampling frequency of CIC
CIC_iwl             = 10;       % CIC input

% create a CIC filter object
hCIC = mfilt.cicinterp(CIC_R, CIC_D, CIC_N);%, 10, CIC_Fs);

% create a CIC scaling factor object
K_cic = 1/(CIC_R^CIC_N);        % gain compensation value
hK = dfilt.scalar(K_cic);

%------------------
% CASCADE SECTION
%------------------

% create a cascade of the objects
hCIChK = mfilt.cascade(hCIC,hK);                    % CIC with scaling applied
hCFIRhKcfir = mfilt.cascade(hCFIR,hKcfir);          % CFIR with scaling applied
hCASC = mfilt.cascade(hRRC,hCFIR,hKcfir,hCIC,hK);   % cascade of all filters and scalings

%-----------------------------------------------
% PLOTTING SECTION 1
% (NOTE: floating point designs are used here, 
% fixed point to come later...)
%------------------------------------------------

% plot a superposition of the responses using the filter visualisation tool
fv(1) = fvtool(hRRC,'Fs',6.25e6,'ShowReference','off');
hold on
addfilter(fv(1), hCFIRhKcfir,'Fs',12.5e6,'ShowReference','off');
addfilter(fv(1), hCIChK,'Fs',100e6,'ShowReference','off');
addfilter(fv(1), hCASC, 'Fs', 100e6,'ShowReference','off');
hold off
grid on
title('Cascaded Responses for a Chain of Interpolating Filters (FLOATING POINT)');
legend(fv(1),'RRC','CFIR (scaled)','CIC (scaled)','RRC-CFIR-CIC Cascade','Location','SouthEast');

% this formatting section only works in versions up to 2014a 
% (will add code for custom formatting in 2014b+ at a later date)
if verLessThan('matlab','8.4.0')
    % change the cascaded response to black and embolden, and alter the other
    % colours to make the responses easier to distinguish.
    set(fv(1),'DesignMask','off');                    % Turn off design mask
    fv_children  = get(fv(1),'children');
    fv_axes = fv_children(strcmpi(get(fv_children,'type'),'axes'));
    fv_line = get(fv_axes,'children');
    set(fv_line(1),'linewidth',1.5)                   % make cascaded response thicker
    set(fv_line(1),'color','k');                      % make it black
    set(fv_line(2),'color','b');                      % make CIC blue
    set(fv_line(3),'color',[0.1 0.8 0.1]);            % make CFIR green
    set(fv_line(4),'color','r');                      % make RRC red
end

%--------------------------------------------------------
% FIXED POINT SECTION
% (NOTE: the wordlengths used for the coefficients will
% affect the overall quality of the DUC filtering.)
%--------------------------------------------------------

% Specify the fixed point parameters of the RRC

set(hRRC, ...
    'Arithmetic',           'fixed',...
    'CoeffWordLength',      12,...
    'CoeffAutoScale',       true,...
    'FilterInternals',      'SpecifyPrecision',...
    'InputWordLength',      16,...
    'InputFracLength',      15,...
    'ProductWordLength',    27,...
    'ProductFracLength',    27,...
    'AccumWordLength',      27+ceil(log2(length(hRRC.Numerator))),...
    'AccumFracLength',      27,...
    'OutputWordLength',     16,...
    'OutputFracLength',     15,...
    'RoundMode',            'nearest',...
    'OverflowMode',        'wrap');

% Specify the fixed point parameters of the CFIR

set(hCFIR, ...
    'Arithmetic',           'fixed',...
    'CoeffWordLength',      12,...
    'CoeffAutoScale',       true,...
    'FilterInternals',      'SpecifyPrecision',...
    'InputWordLength',      16,...
    'InputFracLength',      15,...
    'ProductWordLength',    27,...
    'ProductFracLength',    27,...
    'AccumWordLength',      27+ceil(log2(length(hCFIR.Numerator))),...
    'AccumFracLength',      27,...
    'OutputWordLength',     16,...
    'OutputFracLength',     15,...
    'RoundMode',            'nearest',...
    'OverflowMode',        'wrap');

% Specify the fixed point parameters of the CIC

set(hCIC, ...
    'Arithmetic',           'fixed',...
    'FilterInternals',      'FullPrecision',...
    'InputWordLength',      16,...
    'InputFracLength',      15);

%-----------------------------------------------
% PLOTTING SECTION 2
% (NOTE: fixed point this time.)
%------------------------------------------------

% plot a superposition of the responses using the filter visualisation tool
fv(2) = fvtool(hRRC,'Fs',6.25e6,'ShowReference','off');
hold on
addfilter(fv(2), hCFIRhKcfir,'Fs',12.5e6,'ShowReference','off');
addfilter(fv(2), hCIChK,'Fs',100e6,'ShowReference','off');
addfilter(fv(2), hCASC, 'Fs', 100e6,'ShowReference','off');
hold off
grid on
title('Cascaded Responses for a Chain of Interpolating Filters (FIXED POINT)');
legend(fv(2),'RRC','CFIR (scaled)','CIC (scaled)','RRC-CFIR-CIC Cascade','Location','SouthEast');


% this formatting section only works in versions up to 2014a
% (will add code for custom formatting in 2014b+ at a later date)
if verLessThan('matlab','8.4.0')
    % change the cascaded response to black and embolden, and alter the other
    % colours to make the responses easier to distinguish.
    set(fv(2),'DesignMask','off');                    % Turn off design mask
    fv_children  = get(fv(2),'children');
    fv_axes = fv_children(strcmpi(get(fv_children,'type'),'axes'));
    fv_line = get(fv_axes,'children');
    set(fv_line(1),'linewidth',1.5)                   % make cascaded response thicker
    set(fv_line(1),'color','k');                      % make it black
    set(fv_line(2),'color','b');                      % make CIC blue
    set(fv_line(3),'color',[0.1 0.8 0.1]);            % make CFIR green
    set(fv_line(4),'color','r');                      % make RRC red
end