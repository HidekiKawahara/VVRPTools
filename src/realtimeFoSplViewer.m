function varargout = realtimeFoSplViewer(varargin)
% REALTIMEFOSPLVIEWER MATLAB code for realtimeFoSplViewer.fig
%      REALTIMEFOSPLVIEWER, by itself, creates a new REALTIMEFOSPLVIEWER or raises the existing
%      singleton*.
%
%      H = REALTIMEFOSPLVIEWER returns the handle to a new REALTIMEFOSPLVIEWER or the handle to
%      the existing singleton*.
%
%      REALTIMEFOSPLVIEWER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in REALTIMEFOSPLVIEWER.M with the given input arguments.
%
%      REALTIMEFOSPLVIEWER('Property','Value',...) creates a new REALTIMEFOSPLVIEWER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before realtimeFoSplViewer_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to realtimeFoSplViewer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Designed and implemented by Hideki Kawahara
%
%Copyright 2018 Hideki Kawahara
%
%Licensed under the Apache License, Version 2.0 (the "License");
%you may not use this file except in compliance with the License.
%You may obtain a copy of the License at
%
%    http://www.apache.org/licenses/LICENSE-2.0
%
%Unless required by applicable law or agreed to in writing, software
%distributed under the License is distributed on an "AS IS" BASIS,
%WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%See the License for the specific language governing permissions and
%limitations under the License.

% Edit the above text to modify the response to help realtimeFoSplViewer

% Last Modified by GUIDE v2.5 10-Sep-2019 17:21:55

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @realtimeFoSplViewer_OpeningFcn, ...
    'gui_OutputFcn',  @realtimeFoSplViewer_OutputFcn, ...
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
end

% --- Executes just before realtimeFoSplViewer is made visible.
function realtimeFoSplViewer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to realtimeFoSplViewer (see VARARGIN)

% Choose default command line output for realtimeFoSplViewer
handles.output = hObject;
delete(timerfindall);
myGUIdata = guidata(hObject);
myGUIdata.handles = handles;
if nargin == 4 && varargin{1} == 442
    myGUIdata.A4frequency = 442;
else
    myGUIdata.A4frequency = 440;
end
myGUIdata = setDefault(myGUIdata);
myGUIdata = initializeGraphics(myGUIdata);
myGUIdata.avfoDisplay = 110;
myGUIdata.bestSyncCenter = [];
%--- timer function to update waveform display
timerForWaveDraw = timer('TimerFcn',@waveDisplayTimerFcn,'ExecutionMode','singleshot', ...
    'userData',myGUIdata);
myGUIdata.timerForWaveDraw = timerForWaveDraw;
%--- timer function to update waveform display
timerForMonitorDraw = timer('TimerFcn',@monitorDisplayTimerFcn,'ExecutionMode','singleshot', ...
    'userData',myGUIdata);
myGUIdata.timerForMonitorDraw = timerForMonitorDraw;
%--- timer function to update wavelet analysis display
timerForWaveletDraw = timer('TimerFcn',@waveletDisplayTimerFcn,'ExecutionMode','singleshot', ...
    'userData',myGUIdata);
myGUIdata.timerForWaveletDraw = timerForWaveletDraw;
%--- audio monitor preparation
myGUIdata.recordObj1 = audiorecorder(myGUIdata.samplingFrequency,24,1);
set(myGUIdata.recordObj1,'TimerPeriod',myGUIdata.recorderTimerInterval, ...
    'TimerFcn', @recorderTimerFcn, 'userdata', myGUIdata);
myGUIdata.maxAudioRecorderCount = myGUIdata.maxTargetPoint;
myGUIdata.audioRecorderCount = myGUIdata.maxAudioRecorderCount;
set(myGUIdata.counterTxt, 'String', num2str(myGUIdata.audioRecorderCount));
%--- audio replay preparation
myGUIdata.audiomode = 'record';
%--- finalize
guidata(hObject, myGUIdata);
myGUIdata = startRealtime(myGUIdata);
guidata(hObject, myGUIdata);

set(myGUIdata.startButton, 'enable', 'off');
set(myGUIdata.stopbutton, 'enable', 'on');
set(myGUIdata.quitbutton, 'enable', 'on');
set(myGUIdata.saveButton, 'enable', 'off');
set(myGUIdata.loadRefButton, 'enable', 'off');
set(myGUIdata.playRefButton, 'enable', 'off');
set(myGUIdata.setWorkButton, 'enable', 'off');
set(myGUIdata.refSlowdBText, 'visible', 'off');
set(myGUIdata.playButton, 'enable', 'off');
set(myGUIdata.rawSpecButton, 'value', 1);
set(myGUIdata.TifSpecButton, 'value', 1);
set(myGUIdata.TFifSpecButton, 'value', 1);
myGUIdata.output = hObject;

guidata(hObject, myGUIdata);

pause(5);

% UIWAIT makes realtimeFoSplViewer wait for user response (see UIRESUME)
% uiwait(handles.realtimeFoVierGUI);
end

% --- Outputs from this function are returned to the command line.
function varargout = realtimeFoSplViewer_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end

%--- user defined functions

function myGUIdata = setDefault(myGUIdata)
myGUIdata.samplingFrequency = 44100;
myGUIdata.channels_in_octav = 6;
myGUIdata.low_frequency = 110 * 2 ^ (-12 / 12);%110 * 2 ^ (-12 / 12);% A2 55 * 2 ^ (-6 / 12);%
myGUIdata.low_frequency_init = myGUIdata.low_frequency;
myGUIdata.high_freuency = 1300;%1301;
myGUIdata.high_freuency_init = myGUIdata.high_freuency;
myGUIdata.halfTimeSpan = 0.008; % 8 ms (default)
myGUIdata.fftl = 4096;
myGUIdata.downSampling = 1; % 1:on 0:off
myGUIdata.lastPoint = 1;
myGUIdata.wavePowerDuration = 2.4;
myGUIdata.stretching_factor = 1.05;
myGUIdata.recorderTimerInterval = 0.067;
myGUIdata.playerTimerInterval = 0.05;
myGUIdata.maxTargetPoint = 400;% This is for audio recorder
%myGUIdata.prob_threshold = 0.9; %
%myGUIdata.periodicity_mask_level = prob2maskingLevel(myGUIdata.prob_threshold);%[0.25 0.12 0.064 0.044];
myGUIdata.periodicity_mask_level = 4;%6; % noisy candidate suppressor (default 3)
myGUIdata.sync_indicator_level = 0.2;
fs = myGUIdata.samplingFrequency;
xt = rand(round(fs / 5), 1);
%myGUIdata.initialStruct = sourceInformationAnalysis(xt, fs, [1 length(xt)], ...
%    myGUIdata.low_frequency, myGUIdata.high_freuency, ...
%    myGUIdata.channels_in_octav, myGUIdata.downSampling, myGUIdata.stretching_factor);
myGUIdata.initialStruct = sourceAttributesAnalysis(xt, fs, [1 length(xt)], ...
    myGUIdata.low_frequency, myGUIdata.high_freuency, ...
    myGUIdata.channels_in_octav, myGUIdata.downSampling, myGUIdata.stretching_factor, ...
    'dpss', 8, 4);
myGUIdata.wvltStrDs = myGUIdata.initialStruct.wvltStrDs;
myGUIdata.lastPointer = 1;
end

function myGUIdata = initializeGraphics(myGUIdata)
waveAxisHandle = myGUIdata.waveMonitorAxis;
fs = myGUIdata.samplingFrequency;
%------ running waveform display
axes(myGUIdata.wavePowerAxis);
wavePowerDuration = myGUIdata.wavePowerDuration;
waveP_time_Axis = (0:round(fs * wavePowerDuration)) / fs;
myGUIdata.waveWaveHandle = plot(waveP_time_Axis, zeros(length(waveP_time_Axis), 1), 'k');
set(gca, 'xlim', [0 wavePowerDuration], 'fontsize', 14, 'xtick', [], 'ytick', []);
myGUIdata.waveWaveBuffer = get(myGUIdata.waveWaveHandle, 'ydata');
myGUIdata.recordingBuffer = zeros(round((wavePowerDuration + 1) * fs), 1);
%-------- musical axis
axes(myGUIdata.musicalAxis);
% A4 is 440 Hz
% G clef
chromaticScale = myGUIdata.A4frequency / 16 * 2 .^ (0:1 / 12:log2(myGUIdata.high_freuency / 27.5));
for ii = 1:length(chromaticScale)
    semilogy([0 1], chromaticScale(ii) * [1 1], 'linewidth', 1, ...
        'color', [0.6 0.6 0.6]);
    hold all;
end
axes(myGUIdata.GcrefAxis);
%imshow('gclefsg2.jpg');
%aaa = imread('gclefsg2.jpg');
[X,map,alpha] = imread('gclefsg2.png');
%aaa(aaa > 230) = round(237/255*63);
%image(aaa); 
image(X,"AlphaData",alpha)
colormap(gray);axis off
axes(myGUIdata.FcrefAxis);
%imshow('fclefsg2.jpg');
%aaa = imread('fclefsg2.jpg');
[X,map,alpha] = imread('fclefsg2.png');
%aaa(aaa > 230) = round(237/255*63);
%image(aaa); 
image(X,"AlphaData",alpha)
colormap(gray);axis off
axes(myGUIdata.FcrefAxis);
axes(myGUIdata.musicalAxis);
gclefstaff = myGUIdata.A4frequency * 2 .^ ([-5 -2 2 5 8] / 12);
gclefExtstaff = myGUIdata.A4frequency * 2 .^ ([12 15 19 22] / 12);
for ii = 1:5
    semilogy([0.1 0.9], gclefstaff(ii) * [1 1], 'k', 'linewidth', 2);
    hold all
end
for ii = 1:4
    semilogy([0.5 0.7], gclefExtstaff(ii) * [1 1], 'k', 'linewidth', 2);
    hold all
end
axis([0 1 myGUIdata.low_frequency myGUIdata.high_freuency]);
fclefstaff = myGUIdata.A4frequency * 2 .^ (([-14 -10 -7 -4 0] - 12) / 12);
fclefExtstaff = myGUIdata.A4frequency * 2 .^ (([-17 -21 -24] - 12) / 12);
for ii = 1:5
    semilogy([0.1 0.9], fclefstaff(ii) * [1 1], 'k', 'linewidth', 2);
    hold all
end
for ii = 1:3
    semilogy([0.5 0.7], fclefExtstaff(ii) * [1 1], 'k', 'linewidth', 2);
    hold all
end
semilogy([0.5 0.7], [1 1] * 440 * 2 ^ (-9 / 12), 'k', 'linewidth', 2);
fL = myGUIdata.low_frequency;
fH = myGUIdata.high_freuency;
axis([0 1 fL fH]);
axis off
wholeClef = sort([gclefstaff gclefExtstaff fclefstaff fclefExtstaff 440 * 2 ^ (-9 / 12)]);
for ii = 1:length(wholeClef)
    text(0.92, wholeClef(ii) * 2 ^ (1.5/24), num2str(ii), 'fontsize', 14, 'VerticalAlignment', 'cap', 'FontWeight', 'bold');
end
myGUIdata.noteHandle1 = plot(0.6, 440, 'ro', 'markersize', 16, 'linewidth', 4);
myGUIdata.noteHandle2 = plot(0.6, 220, 'co', 'markersize', 16, 'linewidth', 1);
set(myGUIdata.noteHandle2, 'visible', 'off');
%------ fo candidates display
axes(myGUIdata.mainViewerAxis);
xt = 1:round(fs * myGUIdata.wavePowerDuration);
bufferLengthInTime = myGUIdata.maxTargetPoint * myGUIdata.recorderTimerInterval;
myGUIdata.recordingDuration = bufferLengthInTime;

axes(myGUIdata.mainViewerAxis);
for ii = 1:length(chromaticScale)
    semilogy([-10, bufferLengthInTime + 10], chromaticScale(ii) * [1 1], 'linewidth', 1, ...
        'color', [0.8 0.8 1]);
    hold all;
end
semilogy([-10, bufferLengthInTime + 10], 440 * [1 1], 'g', 'linewidth', 2);
for ii = 1:5
    semilogy([-10, bufferLengthInTime + 10], gclefstaff(ii) * [1 1], 'linewidth', 2, ...
        'color', 0.4 * [1 1 1]);
    semilogy([-10, bufferLengthInTime + 10], fclefstaff(ii) * [1 1], 'linewidth', 2, ...
        'color', 0.4 * [1 1 1]);
end
%outputSrept = sourceInformationAnalysis(randn(length(xt), 1), fs, ...
%    [1 length(xt)], myGUIdata.initialStruct);
outputSrept = sourceAttributesAnalysis(randn(length(xt), 1), fs, ...
    [1 length(xt)], myGUIdata.initialStruct);
%myGUIdata.foCandHandle = semilogy(outputSrept.time_axis_wavelet, ...
%    outputSrept.fixed_points_freq(:, 1:4), '.');
colorList = [0 0.4 0.4; 0.5 0.75 0.75; 0.65 0.85 0.85; 0.75 0.95 0.95];
sizeList = [12 7 4 2];
for ii = 1:4
    myGUIdata.foCandHandle(ii) = semilogy(outputSrept.time_axis_wavelet, ...
        outputSrept.fixed_points_freq(:, ii), '.', 'color', colorList(ii, :), ...
        'markersize', sizeList(ii));
end
set(myGUIdata.mainViewerAxis, 'ylim', [myGUIdata.low_frequency myGUIdata.high_freuency], ...
    'xlim', outputSrept.time_axis_wavelet([1 end]));
grid off;
set(myGUIdata.mainViewerAxis, 'fontsize', 14);
ytick = [3 4 5 6 7 8 9 10 15 20 30 40 50 60 70 80 90 100 120 200] * 10;
yticklabel = num2str(ytick');
ylabel('frequency (Hz)');
set(myGUIdata.mainViewerAxis, 'ytick', ytick, 'yticklabel', yticklabel);
%------- fo indicator
axes(myGUIdata.IndicatorAxis);
initialStruct = myGUIdata.initialStruct;
fc_list = initialStruct.wvltStrDs.fc_list;
freq_sample = fc_list(1:4);
myGUIdata.foMarkerHandle = semilogy([0 1], diag(freq_sample) * ones(4, 2), ...
    'linewidth', 4);
set(myGUIdata.foMarkerHandle(1), 'linewidth', 5);
set(myGUIdata.foMarkerHandle(2), 'linewidth', 3);
set(myGUIdata.foMarkerHandle(3), 'linewidth', 2);
set(myGUIdata.foMarkerHandle(4), 'linewidth', 1);
hold all
for ii = 1:length(chromaticScale)
    semilogy([0 1], chromaticScale(ii) * [1 1], 'linewidth', 1, ...
        'color', [0.8 0.8 0.8]);
end
axis([0 1 myGUIdata.low_frequency myGUIdata.high_freuency]);
set(myGUIdata.IndicatorAxis, 'xtick', [], 'ytick', [])
notoNames = {'A1', 'B1', 'C2', 'D2', 'E2', 'F2', 'G2', ...
    'A2', 'B2', 'C3', 'D3', 'E3', 'F3', 'G3', ...
    'A3', 'B3', 'C4', 'D4', 'E4', 'F4', 'G4', ...
    'A4', 'B4', 'C5', 'D5', 'E5', 'F5', 'G5', 'A5', 'B5', 'C6', 'D6'};
noteFreq = myGUIdata.A4frequency / 8 * 2 .^ ([0 2 3 5 7 8 10 ...
    [0 2 3 5 7 8 10] + 12  [0 2 3 5 7 8 10] + 24 [0 2 3 5 7 8 10 12 14 15 17] + 36] / 12);
n_note = length(noteFreq);
for ii = 1:2:n_note
    text(0.1, noteFreq(ii) * 2 ^ (1.2/24), notoNames{ii}, 'VerticalAlignment', 'cap', 'FontWeight', 'bold');
end
for ii = 2:2:n_note
    text(0.6, noteFreq(ii) * 2 ^ (1.2/24), notoNames{ii}, 'VerticalAlignment', 'cap', 'FontWeight', 'bold');
end
%-- clef size adjust
sizeMulti = log(myGUIdata.high_freuency_init / myGUIdata.low_frequency_init) / log(fH / fL);
gClefLoc = 0.3710777626193724 + 0.477 * log(gclefstaff(2) / fL) / log(fH / fL);
fClefLoc = 0.3710777626193724 + 0.477 * log(fclefstaff(4) / fL) / log(fH / fL);
gClefPosition = get(myGUIdata.GcrefAxis, 'position');
%gClefPosition(2) = gClefLoc - 0.0916 * sizeMulti;
gClefPosition(2) = gClefLoc - 0.0716 * sizeMulti;
gClefPosition(4) = 0.1964 * sizeMulti;
set(myGUIdata.GcrefAxis, 'position', gClefPosition);
fClefPosition = get(myGUIdata.FcrefAxis, 'position');
%fClefPosition(2) = fClefLoc - 0.0770 * sizeMulti;
fClefPosition(2) = fClefLoc - 0.0620 * sizeMulti;
fClefPosition(4) = 0.0899 * sizeMulti;
set(myGUIdata.FcrefAxis, 'position', fClefPosition);
%------- periodicity display
axes(myGUIdata.periodicityAxis);
myGUIdata.perCandHandle = plot(outputSrept.time_axis_wavelet, ...
    outputSrept.estPeriod(:, 1:4), '.');
set(myGUIdata.periodicityAxis, 'ylim', [0 1], ...
    'xlim', outputSrept.time_axis_wavelet([1 end]));
grid on;
set(myGUIdata.periodicityAxis, 'fontsize', 14);
ylabel('periodicity');
xlabel('time (s)')
%------ wave monitor display
halfTimeSpan = myGUIdata.halfTimeSpan;
axes(waveAxisHandle);
time_axis = (-round(halfTimeSpan * fs):round(halfTimeSpan * fs)) / fs;
myGUIdata.waveHandle = plot(time_axis, randn(length(time_axis), 1), 'k');
set(gca, 'xlim', halfTimeSpan*[-1 1], 'fontsize', 14, 'xtick', [], 'ytick', []);
%xlabel('time (s)')
grid on;
%------- Spectrum display
axes(myGUIdata.SpectrumAxis);
fftl = myGUIdata.fftl;
fx = (0:fftl - 1) / fftl * fs;
ydata = get(myGUIdata.waveHandle, 'ydata');
w = nuttallwin(length(ydata));
w = w / sqrt(sum(w .^ 2));
%pw = 20 * log10(abs(fft(w .* ydata(:) / sum(w), fftl)) / sqrt(fftl)) + 100;
pwWin = abs(fft(w, fftl)) .^ 2 / fftl;
pw = 10 * log10(abs(fft(w .* ydata(:), fftl)) .^ 2 / fftl * 2) + 100 - 10*log10(pwWin(1));
myGUIdata.rawSpectrumHandle = ...
    plot(fx(1:fftl / 2 + 1) / 1000, pw(1:fftl / 2 + 1), 'color', [0.2 0.8 0.2]);
hold all
pw = 20 * log10(abs(fft(w .* ydata(:) / sum(w), fftl)));
myGUIdata.TifSpectrumHandle = ...
    plot(fx(1:fftl / 2 + 1) / 1000, pw(1:fftl / 2 + 1), 'color', [0.8 0.2 0.2]);
pw = 20 * log10(abs(fft(w .* ydata(:) / sum(w), fftl)));
myGUIdata.TFifSpectrumHandle = ...
    plot(fx(1:fftl / 2 + 1) / 1000, pw(1:fftl / 2 + 1), 'k', 'linewidth', 2);
grid on;
set(gca, 'fontsize', 13, 'xlim', [0 5], 'ylim', [5 105]);
xlabel('frequency (kHz)');
ylabel('sound pressure level (dB)');
%legend({'raw', 'T-if', 'TF-if'}, 'location', 'northoutside');
axes(myGUIdata.syncIndicatorAxis);
myGUIdata.syncIndicatorHandle = plot(0, 0, 'go', 'markersize', 10, 'linewidth', 5);
axis off
%----- Level Indicator display
axes(myGUIdata.LevelIndicatorAxis);
axis([-101 1 -0.08 1.08]);
axis off
grid off
patch([-101 1 1 -101], [-0.08 -0.08 1.08 1.08], 'k');
hold all
patch([-100 0 0 -100], [0 0 1 1], 'w', 'edgecolor', 'w');
for ii = [-90 -70 -50 -30 -10]
    patch(ii + [0 10 10 0], [0 0 1 1], [0.8 0.9 0.9], 'edgecolor', [0.8 0.9 0.9])
end
%plot([-100 0 0 -100 -100], [0 0 1 1 0], 'k', 'linewidth', 1);
myGUIdata.slowRmsHandle = plot([-80 -80], [ 0.05 0.95], 'g', 'linewidth', 6);
myGUIdata.rmsHandle = plot([-75 -75], [ 0.05 0.95], 'b', 'linewidth', 3);
myGUIdata.peakHandle = plot([-70 -70], [ 0.05 0.95], 'r', 'linewidth', 2);
myGUIdata.slowRms = 10 ^ (-20 / 10);
myGUIdata.refslowRmsdB = -30; % default setting is -20 dB (re. MSB)
set(myGUIdata.calLevelDefine, 'value', 2, 'enable', 'on');
set(myGUIdata.refSlowdBText, 'string', num2str(myGUIdata.refslowRmsdB));
myGUIdata.refLevel = 70; % 80 dB
%----- SPL indicator axis
axes(myGUIdata.splAxis)
myGUIdata.barFastHandle = bar(0.5, 70, 'facecolor', [0 0.8 0]);
hold all
myGUIdata.barSlowHandle = plot([0 1], [71 71], 'color', [0.7 0 0], 'linewidth', 3);
grid on;
hold off
ylabel('Sound pressure level (dB)')
axis([0 1 30 130]);
set(gca, 'xtick', []);
%----- directory information
myGUIdata.workingDirectory = [pwd '/'];
myGUIdata.referenceDirectory = '...';
workDirView = myGUIdata.workingDirectory;
refDirView = myGUIdata.referenceDirectory;
myGUIdata.viewMargin = 55;
if length(workDirView) > myGUIdata.viewMargin
    workDirView = workDirView(end - myGUIdata.viewMargin:end);
end
if length(refDirView) > myGUIdata.viewMargin
    refDirView = refDirView(end - myGUIdata.viewMargin:end);
end
set(myGUIdata.workDirText, 'string', ['....' workDirView])
set(myGUIdata.refPathText, 'string', ['....' refDirView]);
end

function myGUIdata = startRealtime(myGUIdata)
ydata = get(myGUIdata.waveWaveHandle, 'ydata');
set(myGUIdata.waveWaveHandle, 'ydata', ydata * 0);
for ii = 1:4
    ydata = get(myGUIdata.foCandHandle(ii), 'ydata');
    set(myGUIdata.foCandHandle(ii), 'ydata', ydata * 0);
    ydata = get(myGUIdata.perCandHandle(ii), 'ydata');
    set(myGUIdata.perCandHandle(ii), 'ydata', ydata * 0);
end
myGUIdata.audioRecorderCount = myGUIdata.maxAudioRecorderCount;
%myGUIdata.lastPosition = 1;
myGUIdata.lastPointer = 1;
record(myGUIdata.recordObj1);
%pause(0.5)
%switch get(myGUIdata.timerForWaveDraw,'running')
%    case 'off'
%        start(myGUIdata.timerForWaveDraw);
%    case 'on'
%    otherwise
%        disp('timer is bloken!');
%end
end

function playerTimerFcn(hObject, event, handle)
handles = get(hObject, 'userdata');
%recorderHandles = get(handles.recordObj1, 'userdata');
switch get(handles.audioplayer1, 'running')
    case 'on'
        set(handles.playingText, 'string', 'playing...');
        n_audio = get(handles.audioplayer1, 'CurrentSample');
        handles.previousPoint = handles.lastPoint + 1;
        handles.updateLength = n_audio - handles.lastPoint;
        handles.lastPoint = n_audio;
        set(hObject, 'userdata', handles);
        %handles.recordingBuffer = recorderHandles.recordingBuffer;
        if handles.updateLength > 10
            set(handles.timerForWaveDraw, 'userdata', handles);
            set(handles.timerForWaveletDraw, 'userdata', handles);
            start(handles.timerForWaveDraw);
            %waveDisplayTimerFcn(hObject, event, handles)
            start(handles.timerForWaveletDraw);
            endTime = handles.updateLength / handles.samplingFrequency;
            set(handles.counterTxt, 'string', num2str(endTime * 1000, '%03.2f'));
        end
    case 'off'
        set(handles.playingText, 'string', ' ');
end
end

function playerStopFcn(hObject, event, handle)
handles = get(hObject, 'userdata');
set(handles.playingText, 'string', ' ');
set(handles.startButton, 'enable', 'on');
end

function recorderTimerFcn(hObject, event, handle)
handles = get(hObject, 'userdata');
%handles = get(handlesXX.simulExTest, 'userdata');
tmpAudio = getaudiodata(handles.recordObj1);
n_audio = length(tmpAudio);
handles.updateLength = n_audio - handles.lastPoint;
handles.recordingBuffer(handles.lastPoint:n_audio) = ...
    tmpAudio(handles.lastPoint:n_audio);
handles.previousPoint = handles.lastPoint + 1;
handles.lastPoint = n_audio;
%set(handles.simulExTest, 'userdata', handles);
set(hObject, 'userdata', handles);
set(handles.timerForWaveDraw, 'userdata', handles);
set(handles.timerForWaveletDraw, 'userdata', handles);
if n_audio > handles.recordingDuration * handles.samplingFrequency
    stop(handles.recordObj1);
    %disp('baffer ends');
    set(handles.counterTxt, 'string', 'Initializing....');
    startButton_Callback(handles.startButton, 'dummy', handles)
else
    %set(hObject, 'userdata', handles);
    %waveDisplayTimerFcn(hObject, event, handles);
    start(handles.timerForWaveDraw);
    start(handles.timerForWaveletDraw);
    %start(handles.timerForMonitorDraw);
    %waveletDisplayTimerFcn(hObject, event, handles);
    endTime = handles.updateLength / handles.samplingFrequency;
    set(handles.counterTxt, 'string', num2str(endTime * 1000, '%03.2f'));
end
%set(hObject, 'userdata', handles);
end

function waveDisplayTimerFcn(hObject, event, handles)
%start_tic = tic;
handles = get(hObject, 'userdata');
bias = handles.initialStruct.wvltStrDs.wvlt(1).bias;
bias = bias * handles.initialStruct.downSamplinbgRate;
ydata = get(handles.waveWaveHandle, 'ydata');
sampleLength = length(ydata);
tmpWave = handles.recordingBuffer(max(1, min(length(handles.recordingBuffer), ...
    (handles.lastPoint - sampleLength + 1 - 2*bias):handles.lastPoint - 2*bias)));
set(handles.waveWaveHandle, 'ydata', tmpWave);
if max(abs(tmpWave)) < 0.000001
    ylim = [-1 1];
else
    ylim = max(abs(tmpWave)) * [-1, 1];
end
set(handles.wavePowerAxis, 'ylim', ylim);
output = loudnessWithC(tmpWave, handles.samplingFrequency);
refSlowdB = str2double(get(handles.refSlowdBText, 'string'));
calCf = handles.refLevel - refSlowdB;
set(handles.barFastHandle, 'ydata', output.fast(end) + calCf);
set(handles.barSlowHandle, 'ydata', (output.slow(end) + calCf) * [1 1]);
%set(handles.skipText, 'string', num2str(toc(start_tic) * 1000));
%set(handles.wavePowerAxis, 'ylim', [-1, 1]);
end

function waveletDisplayTimerFcn(hObject, event, handles)
start_tic = tic;
handles = get(hObject, 'userdata');
fs = handles.samplingFrequency;
fc_list = handles.wvltStrDs.fc_list;
maxBias = handles.initialStruct.wvltStrDs.wvlt(1).bias * 2 + 2;
bias = handles.initialStruct.wvltStrDs.wvlt(1).bias + 12; % 12 is a dirty fix
downSamplinbgRate = handles.initialStruct.downSamplinbgRate;
updatefoLength = round(handles.updateLength / downSamplinbgRate);
tmp_length = max(1, maxBias * downSamplinbgRate + round(handles.updateLength * 1.5));
x_trim = handles.recordingBuffer(max(1, min(length(handles.recordingBuffer), ...
    (handles.lastPoint - tmp_length + 1):handles.lastPoint)));
handles.bestSyncCenter = [];
mean_freq = 110;
if length(x_trim) > 10
    outputSrept = sourceAttributesAnalysis(x_trim, fs, ...
        [1 length(x_trim)], handles.initialStruct);
    for ii = 1:4
        tmp_Mask = outputSrept.fixed_points_measure(end - 2*bias - updatefoLength + 1:end - 2*bias, ii);
        tmp_Mask(tmp_Mask < handles.periodicity_mask_level) = NaN;
        tmp_Mask(tmp_Mask >= handles.periodicity_mask_level) = 1;
        xdata = get(handles.foCandHandle(ii), 'xdata');
        xdata = xdata - xdata(end) + handles.lastPoint / fs;
        ydata = get(handles.foCandHandle(ii), 'ydata');
        ydata(1:end - updatefoLength) = ydata(1 + updatefoLength:end);
        ydata(end - updatefoLength + 1:end) = ...
            outputSrept.fixed_points_freq(end - 2*bias - updatefoLength + 1:end - 2*bias, ii) ...
            .* tmp_Mask;
        set(handles.foCandHandle(ii), 'ydata', ydata);
        set(handles.foCandHandle(ii), 'xdata', xdata);
        set(handles.foMarkerHandle(ii), 'ydata', [1 1] * ydata(end), ...
            'visible', 'on');
        ydata = get(handles.perCandHandle(ii), 'ydata');
        ydata(1:end - updatefoLength) = ydata(1 + updatefoLength:end);
        ydata(end - updatefoLength + 1:end) = ...
            outputSrept.estPeriod(end - 2*bias - updatefoLength + 1:end - 2*bias, ii);
        set(handles.perCandHandle(ii), 'ydata', ydata);
        set(handles.perCandHandle(ii), 'xdata', xdata);
    end
    set(handles.mainViewerAxis, 'xlim', xdata([1 end]));
    set(handles.periodicityAxis, 'xlim', xdata([1 end]));
    %---- musical note and frequency
    if mean(outputSrept.estPeriod(end - 2*bias - updatefoLength + 1:end - 2*bias, 1)) > handles.sync_indicator_level
        mean_freq = mean(outputSrept.fixed_points_freq(end - 2*bias - updatefoLength + 1:end - 2*bias, 1));
        set(handles.freqText, 'string', [num2str(mean_freq, '%5.2f') '  Hz'], 'visible', 'on');
        ydata = get(handles.noteHandle1, 'ydata');
        set(handles.noteHandle1, 'visible', 'on', 'ydata', ydata * 0 + mean_freq);
        set(handles.syncIndicatorHandle, 'visible', 'on');
        [~, bestChannel] = min(abs(mean_freq - fc_list));
        fundamentalPhase = angle(outputSrept.rawWavelet(end - 2*bias - updatefoLength + 1:end - 2*bias, bestChannel));
        base_idx = 1:length(fundamentalPhase);
        anchorCandidates = base_idx(fundamentalPhase .* fundamentalPhase([2:end end]) < 0 ...
            & fundamentalPhase < 0 & abs(fundamentalPhase - fundamentalPhase([2:end end])) < pi);
        if length(anchorCandidates) > 1
            [~, bestSyncCenter] = min(abs(anchorCandidates - length(fundamentalPhase) / 2));
            handles.bestSyncCenter = anchorCandidates(bestSyncCenter) * downSamplinbgRate;
        end
    else
        set(handles.freqText, 'visible', 'off');
        set(handles.noteHandle1, 'visible', 'off');
        set(handles.syncIndicatorHandle, 'visible', 'off');
    end
    spectrumMonitor(handles, mean_freq, x_trim);
    levelMonitorUpdate(handles, x_trim);
end
set(handles.timerForMonitorDraw, 'userdata', handles);
%start(handles.timerForMonitorDraw);
monitorDisplayTimerFcn(handles.timerForMonitorDraw, event, handles);
set(handles.skipText, 'string', num2str(toc(start_tic) * 1000));
end

function levelMonitorUpdate(handles, x_trim)
peakdB = 20 * log10(max(abs(x_trim)));
rmsdB = 20 * log10(std(x_trim));
tmpSlowRmddB = get(handles.slowRmsHandle, 'xdata');
slowRms = 10 ^ (tmpSlowRmddB(1) / 10);
slowRms = slowRms * 0.75 + 0.25 * std(x_trim) ^ 2;
slowRmsdB = 10 * log10(slowRms);
refSlowdB = str2double(get(handles.refSlowdBText, 'string'));
set(handles.peakHandle, 'xdata', [0 0] + peakdB);
set(handles.rmsHandle, 'xdata', [0 0] + rmsdB);
set(handles.slowRmsHandle, 'xdata', [0 0] + slowRmsdB);
set(handles.slowdBText, 'string', [num2str(slowRmsdB, '%6.1f') '  dB re.MSB']);
slowSPLdB = slowRmsdB + handles.refLevel - refSlowdB; %handles.refslowRmsdB;
set(handles.slowSPLText, 'string', ['SPL: ' num2str(slowSPLdB, '%6.1f') '  dB']);
%set(handles.slowSPLText, 'string', [num2str(handles.refLevel - refSlowdB, '%6.1f') '  dB (SPL)']);
end

function monitorDisplayTimerFcn(hObject, event, handles)
%handles = get(hObject, 'userdata');
ydata = get(handles.waveHandle, 'ydata');
sampleLength = length(ydata);
bias = handles.initialStruct.wvltStrDs.wvlt(1).bias * handles.initialStruct.downSamplinbgRate * 2;
if ~isempty(handles.bestSyncCenter)
    tmpWave = handles.recordingBuffer(max(1,(handles.lastPoint - bias ...
        - handles.updateLength + 1):handles.lastPoint - bias));
    %tmpWave = tmpWave(max(1, min(length(tmpWave), end - handles.updateLength + handles.bestSyncCenter + (1:sampleLength) - round(sampleLength / 2))));
    tmpWave = tmpWave(max(1, min(length(tmpWave), (1:sampleLength) - round(sampleLength / 2) ...
        + handles.bestSyncCenter + 12)));
else
    tmpWave = handles.recordingBuffer(max(1,(handles.lastPoint - sampleLength + 1):handles.lastPoint));
end
set(handles.waveHandle, 'ydata', tmpWave);
if max(abs(tmpWave)) < 0.000001
    ylim = [-1 1];
else
    ylim = max(abs(tmpWave)) * [-1, 1];
end
set(handles.waveMonitorAxis, 'ylim', ylim);
end

function spectrumMonitor(handles, mean_freq, x_trim)
refSlowdB = str2double(get(handles.refSlowdBText, 'string'));
%calCf = handles.refLevel - handles.refslowRmsdB;
calCf = handles.refLevel - refSlowdB;
fs = handles.samplingFrequency;
fftl = handles.fftl;
l_segment = round(fs / mean_freq * 4);
w = blackman(l_segment);
pwrWin = abs(fft(w / sum(w), fftl)) .^ 2 / fftl;
xsegment = x_trim(max(1, min(length(x_trim), ...
    round(length(x_trim) / 2) + (1:l_segment) - round(l_segment / 2))));
rawSpectrum = 10 * log10(2 * abs(fft(w .* xsegment / sum(w), fftl)) .^ 2 / fftl);
statStr = staticTrigBsplinePowerSpec(x_trim, ...
    length(x_trim) / fs / 2, fs, mean_freq, 2, fftl);
set(handles.rawSpectrumHandle, 'ydata', ...
    rawSpectrum(1:fftl / 2 + 1) - 10*log10(pwrWin(1)) + calCf);
set(handles.TifSpectrumHandle, 'ydata', ...
    10 * log10(2 * abs(statStr.pw(1:fftl / 2 + 1)) / fftl) - 10*log10(pwrWin(1)) + calCf);
set(handles.TFifSpectrumHandle, 'ydata', ...
    10 * log10(2 * abs(statStr.pws) / fftl) - 10*log10(pwrWin(1)) + calCf);
if get(handles.rawSpecButton, 'value') == 1
    set(handles.rawSpectrumHandle, 'visible', 'on');
else
    set(handles.rawSpectrumHandle, 'visible', 'off');
end
if get(handles.TifSpecButton, 'value') == 1
    set(handles.TifSpectrumHandle, 'visible', 'on');
else
    set(handles.TifSpectrumHandle, 'visible', 'off');
end
if get(handles.TFifSpecButton, 'value') == 1
    set(handles.TFifSpectrumHandle, 'visible', 'on');
else
    set(handles.TFifSpectrumHandle, 'visible', 'off');
end
end


%--- end of user defined functions

% --- Executes on button press in startButton.
function startButton_Callback(hObject, eventdata, handles)
% hObject    handle to startButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
myGUIdata = guidata(handles.realtimeFoVierGUI);
myGUIdata.audioRecorderCount = myGUIdata.maxAudioRecorderCount;
myGUIdata.lastPoint = 1;
record(myGUIdata.recordObj1);
%pause(1)
%start(myGUIdata.timerForWaveDraw);
set(myGUIdata.startButton, 'enable', 'off');
set(myGUIdata.stopbutton, 'enable', 'on');
set(myGUIdata.quitbutton, 'enable', 'on');
set(myGUIdata.saveButton, 'enable', 'off');
set(myGUIdata.playButton, 'enable', 'off');
set(myGUIdata.loadRefButton, 'enable', 'off');
set(myGUIdata.setWorkButton, 'enable', 'off');
set(myGUIdata.playRefButton, 'enable', 'off');
guidata(hObject, myGUIdata);
end

% --- Executes on button press in stopbutton.
function stopbutton_Callback(hObject, eventdata, handles)
% hObject    handle to stopbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
myGUIdata = guidata(hObject);
recorderUserData = get(myGUIdata.recordObj1, 'userdata');
recorderUserData.finalPoint = recorderUserData.lastPoint;
switch get(myGUIdata.timerForWaveDraw, 'running')
    case 'on'
        stop(myGUIdata.timerForWaveDraw);
end
switch get(myGUIdata.recordObj1, 'running')
    case 'on'
        stop(myGUIdata.recordObj1);
end
set(myGUIdata.recordObj1, 'userdata', recorderUserData);
%{
modeID = 1;%get(myGUIdata.CalibModePopup, 'value');
if modeID == 2
    set(myGUIdata.CalibModePopup, 'value', 1);
    tmpSlowRmsdB = get(myGUIdata.slowRmsHandle, 'xdata');
    myGUIdata.refslowRmsdB = tmpSlowRmsdB(1);
    set(myGUIdata.refSlowdBText, 'string', num2str(tmpSlowRmsdB(1)));
    soundHandle = get(myGUIdata.recordObj1, 'userdata');
    outFileName = ['calibData' datestr(now, 30) '.wav'];
    audiowrite([myGUIdata.workingDirectory outFileName], ...
        soundHandle.recordingBuffer(1:soundHandle.lastPoint), myGUIdata.samplingFrequency, ...
        'BitsPerSample', 32, 'comment', ['SPLcalibdB: ' num2str(myGUIdata.refLevel) '  refRMSdB: ' num2str(tmpSlowRmsdB(1))]);
    disp(['calibration file:' outFileName]);
else
end
%}
set(myGUIdata.saveButton, 'enable', 'on');
set(myGUIdata.playButton, 'enable', 'on');
set(myGUIdata.stopbutton, 'string', 'STOP');
set(myGUIdata.calLevelDefine, 'enable', 'off');
set(myGUIdata.startButton, 'enable', 'on');
set(myGUIdata.stopbutton, 'enable', 'off');
set(myGUIdata.quitbutton, 'enable', 'on');
set(myGUIdata.loadRefButton, 'enable', 'on');
set(myGUIdata.setWorkButton, 'enable', 'on');
if isfield(myGUIdata, 'referenceBuffer')
    set(myGUIdata.playRefButton, 'enable', 'on');
end
guidata(hObject, myGUIdata);
end

% --- Executes on button press in saveButton.
function saveButton_Callback(hObject, eventdata, handles)
% hObject    handle to saveButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
myGUIdata = guidata(hObject);
soundHandle = get(myGUIdata.recordObj1, 'userdata');
outFileName = ['snapD' datestr(now, 30) '.wav'];
audiowrite([myGUIdata.workingDirectory outFileName], ...
    soundHandle.recordingBuffer(1:soundHandle.lastPoint), myGUIdata.samplingFrequency, ...
    'BitsPerSample', 24, 'comment', ['SPLconvdB: ' num2str(myGUIdata.refLevel - myGUIdata.refslowRmsdB)]);
disp(['snapshot file:' outFileName]);
set(myGUIdata.saveButton, 'enable', 'off');
end

% --- Executes on button press in playButton.
function playButton_Callback(hObject, eventdata, handles)
% hObject    handle to playButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
myGUIdata = guidata(hObject);
soundHandle = get(myGUIdata.recordObj1, 'userdata');
myGUIdata.audioplayer1 = audioplayer(soundHandle.recordingBuffer(1:soundHandle.finalPoint), ...
    myGUIdata.samplingFrequency);
%playerTimerFcn
myGUIdata.recordingBuffer = soundHandle.recordingBuffer;
set(myGUIdata.audioplayer1, 'TimerFcn', @playerTimerFcn, ...
    'TimerPeriod', myGUIdata.playerTimerInterval, 'stopFcn', @playerStopFcn, ...
    'userdata', myGUIdata);
myGUIdata.lastPoint = 1;
%disp(num2str(soundHandle.finalPoint / myGUIdata.samplingFrequency));
set(myGUIdata.startButton, 'enable', 'off');
guidata(hObject, myGUIdata);
play(myGUIdata.audioplayer1);
end

% --- Executes on button press in quitbutton.
function quitbutton_Callback(hObject, eventdata, handles)
% hObject    handle to quitbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
myGUIdata = guidata(hObject);
%stop(myGUIdata.timerForWaveDraw);
switch get(myGUIdata.recordObj1, 'running')
    case 'on'
        stop(myGUIdata.recordObj1);
end
if isfield(myGUIdata, 'audioplayer1')
    switch get(myGUIdata.audioplayer1, 'running')
        case 'on'
            stop(myGUIdata.audioplayer1);
    end
end
delete(timerfindall);
%stop(myGUIdata.recordObj1);
close(handles.realtimeFoVierGUI);
end


% --- Executes on button press in rawSpecButton.
function rawSpecButton_Callback(hObject, eventdata, handles)
% hObject    handle to rawSpecButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rawSpecButton
end


% --- Executes on button press in TifSpecButton.
function TifSpecButton_Callback(hObject, eventdata, handles)
% hObject    handle to TifSpecButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of TifSpecButton
end


% --- Executes on button press in TFifSpecButton.
function TFifSpecButton_Callback(hObject, eventdata, handles)
% hObject    handle to TFifSpecButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of TFifSpecButton
end


% --- Executes on button press in playRefButton.
function playRefButton_Callback(hObject, eventdata, handles)
% hObject    handle to playRefButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
myGUIdata = guidata(hObject);
%soundHandle = myGUIdata.referenceBuffer;
myGUIdata.audioplayer1 = audioplayer(myGUIdata.referenceBuffer, ...
    myGUIdata.samplingFrequencyRef);
%playerTimerFcn
myGUIdata.recordingBuffer = myGUIdata.referenceBuffer;
set(myGUIdata.audioplayer1, 'TimerFcn', @playerTimerFcn, ...
    'TimerPeriod', myGUIdata.playerTimerInterval, 'stopFcn', @playerStopFcn, ...
    'userdata', myGUIdata);
myGUIdata.lastPoint = 1;
%disp(num2str(soundHandle.finalPoint / myGUIdata.samplingFrequency));
set(myGUIdata.startButton, 'enable', 'off');
guidata(hObject, myGUIdata);
play(myGUIdata.audioplayer1);
end


% --- Executes on button press in loadRefButton.
function loadRefButton_Callback(hObject, eventdata, handles)
% hObject    handle to loadRefButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
myGUIdata = guidata(hObject);
[fileName, pathName, filterIndex] = uigetfile({'*.wav', '*.WAV'}, 'Select wave file:');
[x, fs] = audioread([pathName fileName]);
myGUIdata.referenceDirectory = pathName;
myGUIdata.referenceFile = fileName;
refDirView = [pathName fileName];
if length(refDirView) > myGUIdata.viewMargin
    refDirView = refDirView(end - myGUIdata.viewMargin:end);
end
set(myGUIdata.refPathText, 'string', ['....' refDirView]);
myGUIdata.referenceBuffer = x(:, 1);
myGUIdata.samplingFrequencyRef = fs;
set(myGUIdata.playRefButton, 'enable', 'on');
guidata(hObject, myGUIdata);
end


% --- Executes on button press in setWorkButton.
function setWorkButton_Callback(hObject, eventdata, handles)
% hObject    handle to setWorkButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
myGUIdata = guidata(hObject);
pathName = uigetdir(myGUIdata.workingDirectory, 'Set work direcotry');
myGUIdata.workingDirectory = [pathName '/'];
workDirView = myGUIdata.workingDirectory;
if length(workDirView) > myGUIdata.viewMargin
    workDirView = workDirView(end - myGUIdata.viewMargin:end);
end
set(myGUIdata.workDirText, 'string', ['....' workDirView]);
guidata(hObject, myGUIdata);
end

% --- Executes on selection change in calLevelDefine.
function calLevelDefine_Callback(hObject, eventdata, handles)
% hObject    handle to calLevelDefine (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns calLevelDefine contents as cell array
%        contents{get(hObject,'Value')} returns selected item from calLevelDefine
myGUIdata = guidata(hObject);
levelList = [60 70 80 90 100];
tmpValue = max(1, min(5, get(hObject,'Value')));
myGUIdata.refLevel = levelList(tmpValue);
guidata(hObject, myGUIdata);
end

% --- Executes during object creation, after setting all properties.
function calLevelDefine_CreateFcn(hObject, eventdata, handles)
% hObject    handle to calLevelDefine (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


% --- Executes on button press in calibrateButton.
function calibrateButton_Callback(hObject, eventdata, handles)
% hObject    handle to calibrateButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
myGUIdata = guidata(hObject);
soundHandle = get(myGUIdata.recordObj1, 'userdata');
outFileName = ['calibData' datestr(now, 30) '.wav'];
output = loudnessWithC(soundHandle.recordingBuffer(1:soundHandle.lastPoint), ...
    myGUIdata.samplingFrequency);
tmpCweight = output.slow(end);
soundHandle.refslowRmsdB = tmpCweight;
myGUIdata.refslowRmsdB = tmpCweight;
set(myGUIdata.refSlowdBText, 'string', num2str(tmpCweight));
audiowrite([myGUIdata.workingDirectory outFileName], ...
    soundHandle.recordingBuffer(1:soundHandle.lastPoint), myGUIdata.samplingFrequency, ...
    'BitsPerSample', 24, 'comment', ['SPLcalibdB: ' num2str(myGUIdata.refLevel) '  refRMSdB: ' num2str(tmpCweight)]);
disp(['calibration file:' outFileName]);
set(myGUIdata.calLevelDefine, 'enable', 'off');
set(myGUIdata.calibrateButton, 'enable', 'off');
set(myGUIdata.calibrateRefButton, 'enable', 'off');
%guidata(myGUIdata.recordObj1, soundHandle);
guidata(hObject, myGUIdata);
disp(myGUIdata.refLevel - tmpCweight);
end


% --- Executes on button press in calibrateRefButton.
function calibrateRefButton_Callback(hObject, eventdata, handles)
% hObject    handle to calibrateRefButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
myGUIdata = guidata(hObject);
biasMicPosition = 20*log10(3); % mic ref at 30cm and using headset mic
soundHandle = get(myGUIdata.recordObj1, 'userdata');
outFileName = ['calibData' datestr(now, 30) '.wav'];
output = loudnessWithC(soundHandle.recordingBuffer(1:soundHandle.lastPoint), ...
    myGUIdata.samplingFrequency);
tmpCweight = output.slow(end) + biasMicPosition; % convert level at 30cm ref.
soundHandle.refslowRmsdB = tmpCweight;
myGUIdata.refslowRmsdB = tmpCweight;
set(myGUIdata.refSlowdBText, 'string', num2str(tmpCweight));
audiowrite([myGUIdata.workingDirectory outFileName], ...
    soundHandle.recordingBuffer(1:soundHandle.lastPoint), myGUIdata.samplingFrequency, ...
    'BitsPerSample', 24, 'comment', ['SPLcalibdB: ' num2str(myGUIdata.refLevel) '  refRMSdB: ' num2str(tmpCweight)]);
disp(['calibration file:' outFileName]);
set(myGUIdata.calLevelDefine, 'enable', 'off');
set(myGUIdata.calibrateButton, 'enable', 'off');
set(myGUIdata.calibrateRefButton, 'enable', 'off');
%guidata(myGUIdata.recordObj1, soundHandle);
guidata(hObject, myGUIdata);
disp(myGUIdata.refLevel - tmpCweight);
end
