function [dataFrame, lost] = GNSS_SDR_capture(releaseFlag)

persistent rx

if isempty(rx)
    % The System object is created only if it isn't already in memory.
    %declare the SDR receiver
%     rx = comm.SDRRTLReceiver;
     rx = comm.SDRRTLReceiver('CenterFrequency',1575.32e6, 'SampleRate', 2.9e6,'EnableTunerAGC', false, 'TunerGain', 1000);
    % set to 100 kHz below L1
%     rx.CenterFrequency=1575.32e6;
    % enable Automatic Gain Control
%     rx.EnableTunerAGC=true;
    % use int16 (8bit I, 8bit Q)
%     rx.OutputDataType='int16';
    % sample rate
%     rx.SampleRate=1.5e6;
    % frame size
%     rx.SamplesPerFrame=1024;
    % disable bursts 
%     rx.EnableBurstMode=false;
end

if releaseFlag
    % When finished, release the object and all resources used by the object.
    release(rx)
    dataFrame = int16(zeros(rx.SamplesPerFrame,1));
    lost = uint32(zeros(1,1));
    
else
    % Execute the RTL-SDR receiver System object that was created earlier.
    [dataFrame, ~, lost] = rx();
end