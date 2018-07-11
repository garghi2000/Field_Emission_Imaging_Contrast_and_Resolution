function [maskA,maskB,contrast] = GetContrast(alldata)

%-----------------------------------------------------------------------------------------
%   Readme
%   Hint: all figures created by this function have the position and the
%   sizes set in centimetres respect to the botton left corner of the
%   screen. Changed them using figure('Unit','Centimeters','pos',[.. .. .. ..])to
%   better suit on your screen.
% 
%   This function does the following:
%   
%   - Plots the data "alldata" using the matrix representation(origin on topleft corner);
%   The aspect of the figure is defined by the function SetImageDefaultProperties()
%   - Let the user to draw a first region A inside the image loaded by clicking 
%   and dragging the mouse and a second region B.
%   - The mean value per line of the two regions is calculated and plot as contrast per line;
%   - The total mean value of the two regions is calculated and printed as title of figure contrast per line;
%   - The contrast per line and the total contrast is calculated as following: 
%   Contrast = |(A - B)/(A + B)|   where A and B are the mean values of the regions.
%   - Plots the histograms of the values for the two regions, to justify the total contrast
%   looking at the mean values. 
%   - Plots the histogram of the contrast for every line. If the line
%   doesn't contain value for one of the two regions, it forces the contrast
%   to be zero, and it is not counted on the histogram.
%   
%                                                       G.B. 04.07.2018
%-----------------------------------------------------------------------------------------

%% Main Part

my_Plotdata(alldata);%see the function

    tip= {'Click and drag the mouse to' 'draw the contour of the Region A'};%hint as title
    title(tip)

    regOfIntA = imfreehand;%draw region A
    setColor(regOfIntA,'k');
    addNewPositionCallback(regOfIntA,@my_Show_Select_regions_and_start_calculations)

    h = msgbox({'Region A selected,' 'now select a region B'});%message box after ending the drawing
    set(h,'Units','centimeters','pos',[15 15 4 2])
    uiwait(h);
    tip = sprintf('Click and drag the mouse to \ndraw the contour of the Region B');%hint as title
    tip = compose(tip);
    title(tip)

    regOfIntB = imfreehand;%draw region B
    setColor(regOfIntB,'r');
    addNewPositionCallback(regOfIntB,@my_Show_Select_regions_and_start_calculations)%callback select_regions when drawing is dragged

    posA = regOfIntA.getPosition();%read note
my_Show_Select_regions_and_start_calculations(posA);%see the function
    %note: pos of the roi are not needed but it is necessary passing a function of pos
    %in order to let the roi callback working

%% Functions used in this code    
    
% Show the selected regions, and call the functions for the histograms and contrast calculations
function [maskA,maskB] = my_Show_Select_regions_and_start_calculations(~)
    
%-----------------------------------first part------------------------------------
maskA = my_Mask(regOfIntA);%see the function
maskB = my_Mask(regOfIntB);%see the function

    mask = maskA + maskB;%create a mask of both regions only for visual purposes
    mask(mask==2) = 1;%avoiding overlap between mask
    mask = mask.*alldata;%apply total mask to data 
    maskA = maskA.*alldata;%apply mask region A to data 
    maskB = maskB.*alldata;%apply mask region B to data 
    mask(mask==0) = nan;
    maskA(maskA==0) = nan;
    maskB(maskB==0) = nan;

    AB = findobj('Type','figure','Name','Region A & B');
    if isempty(AB)
        figure('Name','Region A & B','NumberTitle','off','Units','centimeters','pos', [22 2 9 9])
    else
        set(0,'CurrentFigure',AB);%makes the Redion A figure the current figure
    end
    figure(gcf)
    imagesc(mask);
    tip= sprintf('THIS IS THE REGION OF DATA SELECTED!');
my_SetSmallImageDefaultProperties(alldata);%see the function
    title(tip)
    
%----------------------------------second part-----------------------------
my_Show_hist(maskA,maskB);%see the function
my_Calculate_contrast(maskA,maskB);%see the function

end

% Create a binary mask of the region inside the drawing(regOfInt)
function maskera = my_Mask(regOfInt)

    maskera=createMask(regOfInt);%create a binary img with "1s" inside the region and "0" outside
    maskera=double(maskera);%changes mask from binary to double matrix
     
end

% Show the histograms of the data inside the region A and B
function my_Show_hist(maskA,maskB)

    hisfig = findobj('Type','figure','Name','histograms');
    if isempty(hisfig)
        figure('Name','histograms','NumberTitle','off','Units','centimeters','pos', [22 14 12 8])
    else
        set(0,'CurrentFigure',hisfig);%makes the histograms figure the current figure
    end
    figure(gcf)
    hA = histogram(maskA(:),100);%histogram of the data inside region A
    set(hA,'FaceColor','k','EdgeColor','k','FaceAlpha',0.6);
    hold on
    hB = histogram(maskB(:),100);%histogram of the data inside region B
    set(hB,'FaceColor','r','EdgeColor','r','FaceAlpha',0.6);
my_SetHistDefaultProperties();%see the function
    hold off

end

% Calculate the total contrast, the contrast per line and plot them
function contrast = my_Calculate_contrast(Areg,Breg)
    
    xlineBreg = zeros(1,size(Areg,1));%initialization
    xlineAreg = xlineBreg;%initialization
    contrast = xlineAreg;%initialization
    TotAreg= abs(nanmean(Areg(:)));%mean value on the TOTAL region A
    TotBreg= abs(nanmean(Breg(:)));%mean value on the TOTAL region B
    Totcontrast = (TotAreg - TotBreg)/(TotAreg +TotBreg);%TOTAL contrast
    %note: absolute values are needed to avoid TOTAL contrast >1.
    results = sprintf('<RegA> = %.2f \n<RegB> = %.2f \n Total Contrast = %.2f',TotAreg,TotBreg,Totcontrast);
    %results is used as title on the next figure

    for i=1:size(Areg,1)%for loop on the lines
        xlineAreg(i) = abs(nanmean(Areg(i,:)));%mean value on the region A of the i-th line 
        xlineBreg(i) = abs(nanmean(Breg(i,:)));%mean value on the region B of the i-th line 
        contrast(i) = (xlineAreg(i) -xlineBreg(i))/(xlineAreg(i) +xlineBreg(i));%contrast of the i-th line
        %note: absolute values are needed to avoid contrast >1.
        %note: for those lines where one of the two regions doesn't fall
        %in, the contrast is nan, so it is not counted on the contrast per
        %line
    end
    
    Contrastperlinefig = findobj('Type','figure','Name','Contrast per line');
    if isempty(Contrastperlinefig)%check if the figure already exists, in that case overwrite it
        figure('Name','Contrast per line','NumberTitle','off','Units','centimeters','pos', [34 14 12 8])
    else
        set(0,'CurrentFigure',Contrastperlinefig);%makes the histogramms figure the current figure
    end
    figure(gcf)
    hcontrast= histogram(contrast,100);%make the histogram of the contrast per line
    set(hcontrast,'FaceColor','r','EdgeColor','r');
    title(results);%on the title the total values appear
my_SetHistDefaultProperties();%see the function
    ca=gca;
    ca.XLabel.String = 'Contrast per line';
end

% Plot the data
function my_Plotdata(alldata)
    figure('Name','Data','NumberTitle','off','Units','centimeters','pos', [2 2 20 20])
    imagesc(alldata);
my_SetImageDefaultProperties(alldata);%see the function
    hold on %keep the figure for next plot
end

% Set the properties of the current image
function my_SetHistDefaultProperties()
    ca=gca;
    ca.YLabel.String = 'Incidence';
    ca.FontSize = 18;
    ca.TitleFontSizeMultiplier = 0.8;
    ca.LineWidth = 2;
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

% Set the properties of the current image
function my_SetSmallImageDefaultProperties(alldata)
    avg=nanmean(alldata(:));%mean
    sigma=nanstd(alldata(:));%standard deviation
    axis square;
    colormap(sxm.op.nanonisMap(128));% colormap defined by the nanonisMap NanoLib function
    caxis([avg-2*sigma avg+2*sigma])% Edge of the colormap
    ca=gca;
    ca.FontSize = 12;
    ca.TitleFontSizeMultiplier = 1;
    ca.LineWidth = 1;
    ca.YLim =  [0 size(alldata,1)];
    ca.XLim = [0 size(alldata,2)];
end

end