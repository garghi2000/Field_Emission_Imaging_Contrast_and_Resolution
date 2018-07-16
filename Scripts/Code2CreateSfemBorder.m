%-----------------------------------------------------------------------------------------
%   Readme
%   Hint: this script loads the sxm file with name defined by "loc" vector and using
%   the personal NanoLib library found in '..\..\my_matlab_nanonis.git\NanoLib' path. 
%   Before run the code be sure both file name and path of the library are
%   correct.
% 
%   This script does the following:
%   
%  - Plots the raw data of the channel chosen using loadProcessedSxM. Note that in case of the
%   channeltron channel all data were moltiplied by a -1, so that the all routine doen't have
%   to be changed since the fit function is a down step function(it is negative).
%  - Allows the user to select the region of interest(roi) inside the image loaded by clicking 
%   and dragging the mouse. 
%  - Fits to everyscan line of the roi the step function -A*tanh(B*(x-C)-D with A,B,C,D>0; 
%   the fit parameter C is x coordinate of the inflection point of the tanh function
%   i.e. the position of the step in a scanline. The y coordinate is the scan line index.
%   All of these x,y coordinates define the points of the border line between W and C regions.
%  - Saves the border line points in a txt file.
%  - Plot the histogram of the contrast for every scan line using the ratio A/D of the fit
%   coefficients. Note that this definition of contrast is equivalent to the one given by
%   (W-C)/(W+C) where W and C are the mean values of the regions W and C.
%  - Plot the histogram of the contrast for every scan line using (W-C)/(W+C) where W and C are
%   the mean values respectively on the left and on the right region respect to the step 
%   position on the masked image. 
%   
%  
%  
%
%                                                       G.B. 08.06.2018
%-----------------------------------------------------------------------------------------

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
loc = '..\..\Data_for_chemical_contrast\2017_02_02_2_W110_polished_file_005.sxm';%path + file name 

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
