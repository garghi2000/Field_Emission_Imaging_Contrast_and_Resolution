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

%% Plot the data
my_PlotData(alldata);%see the function

%% get the resolution using 2 border files
GetResolution(alldata);

% Plot the data
function my_PlotData(alldata)
    figure('Name','Data','NumberTitle','off','Units','normalized','pos', [0.0377 0.0667 0.3774 0.6667])
    imagesc(alldata);
    my_SetImageDefaultProperties(alldata);%see the function
    hold on %keep the figure for next plot
end

% Set the properties of the current image
function my_SetImageDefaultProperties(alldata)
    avg=nanmean(alldata(:));%mean
    sigma=nanstd(alldata(:));%standard deviation
    axis square;
    colormap(sxm.op.nanonisMap(128));% colormap defined by the nanonisMap NanoLib function
    caxis([avg-2*sigma avg+2*sigma])% Edges of the colormap
    ca=gca;
    ca.FontSize = 26;
    ca.TitleFontSizeMultiplier = 0.8;
    ca.LineWidth = 2;
    ca.YLim =  [0 size(alldata,1)];
    ca.XLim = [0 size(alldata,2)];
end