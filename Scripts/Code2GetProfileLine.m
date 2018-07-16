clear all;
close all;

%% path for file and NanoLib library

% Uncomment/comment for dialog box appearing

% NanoLib_path = uigetdir('..\','Select the NanoLib folder');
% addpath(NanoLib_path);%path for nanolib
% [filename,pathfile,~] = uigetfile('*.sxm');%get file sxn to analyze and path for it
% loc=strcat(pathfile, filename);%concatenate path and name
% functions_path = uigetdir('..\','Select the functions folder');
% addpath(functions_path);%path for functions

% Uncomment/comment for a faster definition of paths

% my paths
addpath('..\Functions');%path for functions
addpath('..\..\my_matlab_nanonis.git\NanoLib');%path for NanoLib
loc = '..\..\Data_for_chemical_contrast\2017_02_02_2_W110_polished_file_003.sxm';%path + file name 

%% Load file with the NanoLib function loadProcessedSxM
img=sxm.load.loadProcessedSxM(loc,'Mean');

%% Get the index of the channel named Z backward scan 
Chbkw=utility.getChannel(img.channels,'Z','backward');

%% Store the only data in the matrix alldata
alldata=img.channels(Chbkw).data.*1e12;%from meter to picometer

%% Code for profile line
GetProfileLine(alldata);
