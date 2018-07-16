clear all;
close all;

%% path for file and NanoLib library

% Uncomment/comment for dialog box appearing ----------------------
% NanoLib_path = uigetdir('..\','Select the NanoLib folder');
% addpath(NanoLib_path);%path for nanolib
% [filename,pathfile,~] = uigetfile('*.sxm');%get file sxn to analyze and path for it
% loc=strcat(pathfile, filename);%concatenate path and name
% functions_path = uigetdir('..\','Select the functions folder');
% addpath(functions_path);%path for functions
% -----------------------------------------------------------------

% Uncomment/comment for a faster definition of paths --------------
% my paths
addpath('..\Functions');%path for functions
addpath('..\..\my_matlab_nanonis.git\NanoLib');%path for NanoLib
loc = '..\..\Data_for_chemical_contrast\2017_02_02_2_W110_polished_file_005.sxm';%path + file name 
% -----------------------------------------------------------------

%% Load file with the NanoLib function loadProcessedSxM
file=sxm.load.loadProcessedSxM(loc,'Raw');

%uncomment\comment to look the channeltron current instead of the channeltron 
%% Get the index of the channel named Current backward scan
Chbkw=utility.getChannel(file.channels,'Current','backward');

%% Store the only data in the matrix alldata
alldata=file.channels(Chbkw).data.*1e9;%covert the data from A in nA

% %%comment\uncomment to look the channeltron channel instead of the current 
% %% Get the index of the channel named Channeltron backward scan
% Chbkw=utility.getChannel(file.channels,'Channeltron','backward');
% 
% %% Store the only data in the matrix alldata
% alldata=file.channels(Chbkw).data.*-1e-3;%covert the data from counts to Kcounts

%% Get the border using the CreateStepBorder() function
CreateStepBorder(alldata);
