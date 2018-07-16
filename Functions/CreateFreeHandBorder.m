function pos = CreateFreeHandBorder(alldata)
%-----------------------------------------------------------------------------------------
%   Readme
% 
%   This code does the following:
%
% - Plots alldata matrix using the colormap defined by nanonisMap (NanoLib/op/nanonisMap.m).
% Note:The x and y axis are in pixels and the origin is top/left corner(matrix representation).
% - Allows the user to draw a border inside the image loaded by clicking and dragging the mouse.
% - When double click on the line, the $x$ and $y$ coordinates of those points are saved
% in the txt file typed.
%                                                                          G.B. 08.06.2018
%-----------------------------------------------------------------------------------------

%% Main part

my_Plotdata(alldata);%see the function

    tip= {'Click and drag the mouse to' 'draw the border'};%hint as title
    title(tip)
    hca = gca;
    fcn = makeConstrainToRectFcn('imfreehand',get(gca,'XLim'),...
        get(gca,'YLim'));%limit where the border is draggable
    borderOfInt = imfreehand(hca,'Closed',0,'PositionConstraintFcn',fcn);%draw region A inside the axes

    setColor(borderOfInt,'k');
    tip= {'Double-clicking on the drawn line' 'to save it as set of x and y coordinates'};%hint as title
    title(tip)
    pos = wait(borderOfInt);
    my_SavePoints(pos);

%% Functions used in this code

% Open the file named filename and print the pos vector.
function my_SavePoints(pos)
    
    %pos = borderOfInt.getPosition();%read note
    prompt = {'Insert file name:'};
    titl = 'Save coordinates in txt file';
    dims = [1 40];
    definput = {'border.txt'};
    filename = char(inputdlg(prompt,titl,dims,definput));
    fid = fopen(filename,'wt');
    pos = pos';
    fprintf(fid,'%f %f\n',pos); %overwrites previous data, data in pixels
    fclose('all');
    msg=sprintf('Coordinates saved in the %s file',filename);
    msgbox(msg);
   
end

% Plot the data
function my_Plotdata(alldata)
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
end