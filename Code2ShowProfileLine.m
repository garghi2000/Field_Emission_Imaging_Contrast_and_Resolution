%-----------------------------------------------------------------------------------------
%   Readme
%   
%   Hint: 
% 
%   This script does the following:
%                                                       G.B. 15.06.2018
%-----------------------------------------------------------------------------------------

%% Inizialization of the code
clear all;
close all;
%path for file and NanoLib library
addpath('..\..\matlab Library\NanoLib');
loc='2017_02_02_2_W110_polished_file_003.sxm';

%Load file with the NanoLib function loadProcessedSxM
img=sxm.load.loadProcessedSxM(loc,'Mean');

%Get the index of the channel named Z backward scan 
Chbkw=utility.getChannel(img.channels,'Z','backward');

%Store the only data in the matrix alldata
alldata=img.channels(Chbkw).data.*1e12;%from meter to picometer

%Code for profile line
ShowProfileLine(alldata);
