clear all;
close all;
%get coordinates on click-left click for new point,right click to stop
%loc is the name of the file that is plotted
%change addpath to personal nanolib library
%points are (over)written to stm_border_test.txt in the same directory as this file

%%  path for file and NanoLib library
addpath('..\..\matlab Library\NanoLib');
loc='2017_02_02_2_W110_polished_file_003.sxm';

%% Load file with the NanoLib function loadProcessedSxM
file=sxm.load.loadProcessedSxM(loc,'Mean');

%% Get the index of the channel named Z backward scan 
Chbkw=utility.getChannel(file.channels,'Z','backward');

%% Store the only data in the matrix alldata

alldata=file.channels(Chbkw).data.*1e12;%from meter to picometer

%% Open the file stm_border_test and store the points clicked 

CreateFreeHandBorder(alldata);
