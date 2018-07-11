clear all;
close all;

%% path for file and NanoLib library
addpath('..\..\matlab Library\NanoLib');
%loc='2017_02_02_W110_polished_file_010.sxm';
loc='2017_02_02_2_W110_polished_file_005.sxm';


%% Load file with the NanoLib function loadProcessedSxM
file=sxm.load.loadProcessedSxM(loc,'Raw');

% %-----------uncomment\comment to look the channeltron current instead of the channeltron 
% %% Get the index of the channel named Current backward scan
% Chbkw=utility.getChannel(file.channels,'Current','backward');
% 
% %% Store the only data in the matrix alldata
% alldata=file.channels(Chbkw).data.*1e9;%covert the data from A in nA
% %---------------------------------------------------------------------------------------

%-----------comment\uncomment to look the channeltron channel instead of the current 
%% Get the index of the channel named Channeltron backward scan
Chbkw=utility.getChannel(file.channels,'Channeltron','backward');

%% Store the only data in the matrix alldata
alldata=file.channels(Chbkw).data.*-1e-3;%covert the data from counts to Kcounts
%---------------------------------------------------------------------------------------

%% Get contrast between region A and region B
GetContrast(alldata);

