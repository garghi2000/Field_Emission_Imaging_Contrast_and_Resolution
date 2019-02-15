function GetResolution(alldata)
%-----------------------------------------------------------------------------------------
%   Readme
%  
%   This script does the following:
%   
% - Plots alldata matrix using the colormap defined by nanonisMap (NanoLib/op/nanonisMap.m).\\
% Note: The x and y axis are in pixels and the origin is top/left corner(matrix representation).
% - Lets the user load two text files which are supposed to contain two set of points inside the image representing the borders the user wants to compare.
% - Plots the borders from the files.
% - The code starts to compare for every line the $x$ position of the of the first border with the $x'$ position of the second border, creating the histogram called ''reshist'' of the displacement. Those scan line that do not contain points of one of the two borders are excluded.
% - When one of the two borders is dragged the histogram is updated.
% - The total shift between the two borders and the standard deviation is shown in the title of the reshist figure.
% - A button to rotate one of the two borders is also present on top of the Data figure. It gives to the user the possibility to rotate one of the borders respect to a point chosen.  
% - A threshold on the displacement calculation is used to cut those scan line where the step border fails in finding the position of the step. 
%
%                                                       G.B. 08.06.2018
%-----------------------------------------------------------------------------------------
%% Main Part

[posA,posB] = my_ReadBorderfiles();%see the function
%my_ShowBorders(posA,posB);%uncomment to see the original files points
[hA,hB] = my_MakeBorderRoi(posA,posB);%see the function
my_botton_for_rotation();

%% Function used in this code
% Define botton to rotate one border
function my_botton_for_rotation()
    dataaxes = findobj('Type','figure','name','Data');
    set(0,'CurrentFigure',dataaxes);%makes the Data figure the current figure
    btn_h = uicontrol('Style', 'pushbutton', 'String', 'Rotate the border',...
    'Units','normalized','Position', [0.25 0.95 0.5 0.05],...
    'Callback',@my_botton_for_rotation_callback);%pushbotton
end

% Rotation applyed to one of the borders
function my_botton_for_rotation_callback(btn_handle,~)
    btn_handle.Visible ='off';%make the button unvisible
    title('Use the mouse to select the border to rotate');%update the title
    w = waitforbuttonpress;%wait until you select one of the borders
    border_line = gco;%get the handle of the last selection
    posbl = [border_line.XData ; border_line.YData]';%take the position of the object selected
    poshA= hA.getPosition;%to be compare with posbl
    poshB = hB.getPosition;%to be compare with posbl
    if w == 1 %
        msgbox('A key botton was press, please use the mouse','error','error');
    else

        if isequal(posbl,poshA)%comparison to check which border was selected
            bl=hA;
            msgb1= msgbox('Blue border has been selected','Border selection');
            uiwait(msgb1);%wait until 
        elseif isequal(posbl,poshB)%comparison to check which border was selected
            bl=hB;
            msgb2= msgbox('Green border has been selected','Border selection');
            uiwait(msgb2);
        else
            msgbox('Please use the mouse to select one of the borders','error','error');
            dataaxes = findobj('Type','figure','name','Data');
            set(0,'CurrentFigure',dataaxes);%makes the Data figure the current figure
            title('You can drag the borders for a better overlap');
            btn_handle.Visible ='on';
            return
        end
        prompt = 'Insert the angle [deg](- for clockwise rotations)' ;
        titl = 'Load rotation angle';
        num_line = 1;
        definput = {'90'};
        theta= str2double(inputdlg(prompt,titl,num_line,definput));%angle for rotation
        title({'Choose the center of the rotation' ' by clicking a point in the figure'});
        CofRot=impoint;% get center using impoint maltab functin
        CofRotpos= CofRot.getPosition;% get center of rotation by clicking in the image
        newpos = my_rotation_object(CofRotpos,theta,bl);%new positions after rotation
        dataaxes = findobj('Type','figure','name','Data');
        set(0,'CurrentFigure',dataaxes);%makes the Data figure the current figure
        title('You can drag the borders for a better overlap');
        if isequal(bl,hA)
            delete(hA,CofRot);% remove old roi object
            delete(CofRot);% remove old point object
            hA = imfreehand(gca,newpos,'Closed',0);% create new(rotated) roi object
            addNewPositionCallback(hA,@my_interpolation_callback);%callback my_interpolation_callback when drawing is dragged
            setColor(hA,'b');
        elseif isequal(bl,hB)
            delete(hB);% remove old roi object
            delete(CofRot);% remove old point object
            hB = imfreehand(gca,newpos,'Closed',0);% create new(rotated) roi object
            addNewPositionCallback(hB,@my_interpolation_callback);%callback my_interpolation_callback when drawing is dragged
            setColor(hB,'g');
        end
        
        my_interpolation(hA,hB);
        btn_handle.Visible ='on';

    end
end

function pos_rotated = my_rotation_object(center,theta,object)
    pos = object.getPosition;
    pos = pos';%rowlike
    theta = theta*pi/2/90;%from deg to rad
    center = repmat([center(1);center(2)], 1, numel(pos(1,:)));% center point rowlike
    R = [cos(theta) -sin(theta); sin(theta) cos(theta)];%matrix of rotation
    pos_rotated = R*(pos - center) + center; % rotation respect to the center point
    pos_rotated= pos_rotated';%columnlike

end

% Calculate resolution and show the histogram
function my_calculate_resolution(cutposA,cutposB)
    
        cyA = cutposA(:,2);%coordinates separated in different vectors
        cxA = cutposA(:,1);
        cyB = cutposB(:,2);
        cxB = cutposB(:,1);
        %define number of scan line as the min between  A and B
    if numel(cutposA(:))<= numel(cutposB(:))
        Nscanline = unique(cutposA(:,2));%vector containing index of scanline common(y coords)
        
    else
        Nscanline = sort(unique(cutposB(:,2)));% sort y coords not repeated
    end
    res = nan(size(Nscanline,1),1);
    for i = Nscanline'
        
        k = i - (Nscanline(1)-1);%index starting from 1
        %taking the points along the same scan lines which have minimum
        %distances
        xAsamey = cxA(cyA==i);% x coord values at the k scan line for the border A
        xBsamey = cxB(cyB==i);% x coord values at the k scan line for the border B
        xBsamey = xBsamey'; 
        BB = repmat(xBsamey,size(xAsamey));
        AA = repmat(xAsamey,size(xBsamey));
        DifMatrix = AA-BB;% all differences betweeen x coords of A and x coords of B at k scan line
        res(k)= min(DifMatrix(:));% res is the minumum between the distances
        %cutting bad scan lines
        dThreshold = 35;
        if abs(res(k))>= dThreshold% distance threshold in px between borders to exclude the scan lines 
            res(k) = NaN;%cut scan lines that have a creal point outside of the border.
        end
    
    end
    rhis = findobj('type','figure','Name','reshist');
    if isempty(rhis)
        
    figure('Name','reshist','NumberTitle','off','Units','normalized','pos', [0.4151 0.0667 0.2264 0.2667])
    else
        set(0,'CurrentFigure',rhis);%makes the histogram figure the current figure
    end
    figure(gcf)
%     res(isnan(res)) = [];%remove nan elements
    resh= histogram(res,50);
%     fitdist(res,'Normal') %checked if the distribution is normal
    avgDisp=nanmean(res(:));%mean
    sigmaDisp=nanstd(res(:));%standard deviation
    tltres = sprintf('(std)resolution = %.2f px',sigmaDisp);
    tltdisp =sprintf('(x0)shift = %.2f px',avgDisp);
    tltthrhold =sprintf('threshold used = %.2f px',dThreshold);

    xlabel('Displacement by data [px]');
    ylabel('Incidence');
    set(resh,'FaceColor','r','EdgeColor','r');
    title({tltres tltdisp tltthrhold});
    
    dataaxes = findobj('Type','figure','name','Data');
    set(0,'CurrentFigure',dataaxes);%makes the Data figure the current figure
end

% This is needed in order to upload everything when the borders are dragged
function my_interpolation_callback(~)
    my_interpolation(hA,hB);
end

% Make borders draggable
function [hA,hB] = my_MakeBorderRoi(posA,posB)
    
    ca = gca;
    title('You can drag the borders for a better overlap');

    hA = imfreehand(ca,posA,'Closed',0);
    hB = imfreehand(ca,posB,'Closed',0);
    addNewPositionCallback(hA,@my_interpolation_callback);%callback my_interpolation_callback when drawing is dragged
    addNewPositionCallback(hB,@my_interpolation_callback);%same
    setColor(hB,'g');
    setColor(hA,'b');

my_interpolation(hA,hB);

end

%interpolate the borders on those scanlines in common 
function my_interpolation(hA,hB)
    
    
    newposA = getPosition(hA);%set of points updated
    newposB = getPosition(hB);%set of points updated

    %interpolation using improfile
    yA = newposA(:,2);%coordinates separated in different vectors
    xA = newposA(:,1);
    yB = newposB(:,2);
    xB = newposB(:,1);

    %get the coordinates of those pixel under the line drawn
    [cxA,cyA,~] = improfile(alldata,xA,yA);% ~ are the intensities not needed
    [cxB,cyB,~] = improfile(alldata,xB,yB);

%         %check that the lines are made of a set of pixels          
%         plot(cxA,cyA,'.b','MarkerSize',5);
%         plot(cxB,cyB,'.g','MarkerSize',5);

    %rounding for having real pixels
    cyA= round(cyA);
    cyB= round(cyB);

    %cut borders for comparison on the same scanline. 
    iline = max(min(cyA),min(cyB)); %initial line
    fline = min(max(cyA),max(cyB)); %final line

    %delete points on those lines where one of the 2 borders do not exist
    %x coordinates
    cxA(cyA<=iline | cyA>=fline) = [];
    cxB(cyB<=iline | cyB>=fline) = [];
    %y coordinates
    cyA(cyA<=iline | cyA>=fline) = [];
    cyB(cyB<=iline | cyB>=fline) = [];

    %cutted positions stored
    cutposA = [cxA cyA];%coordinates separated in different vectors
    cutposB = [cxB cyB];%coordinates separated in different vectors

    %check that the lines were cutted
%         plot(cxA,cyA,'.b','MarkerSize',5);
%         plot(cxB,cyB,'.g','MarkerSize',5);

    my_calculate_resolution(cutposA,cutposB);

end

% Plot borders in data
function my_ShowBorders(posf1,posf2)
    plot(posf1(:,1),posf1(:,2),'.b','MarkerSize',15);
    plot(posf2(:,1),posf2(:,2),'.g','MarkerSize',15);
    
end

% Read position of border from files
function [posf1,posf2] = my_ReadBorderfiles(~)

    prompt = {'Insert file name for the first border:' ' Inserte file name for the second border:'};
    titl = 'Load coordinates from txt files';
    num_line = 1;
    definput = {'stm_border.txt','nfesem_border.txt'};
    files = inputdlg(prompt,titl,num_line,definput);
    filenam1 = char(files(1));
    filenam2 = char(files(2));
    f1= fopen(filenam1);
    f2= fopen(filenam2);
    if f1~=3 || f2~=4
        msg=sprintf('no file found with that name, please ensure you selecte an existing file');
        msgbox(msg);
    else
    posf1 = textscan(f1,'%f %f', 'TreatAsEmpty',{'NaN','nan','na','NA'});%read the coordinates in the file f2 and save in posf2
    posf2 = textscan(f2,'%f %f', 'TreatAsEmpty',{'NaN','nan','na','NA'});%read the coordinates in the file f2 and save in posf2
    posf1 =cell2mat(posf1);
    posf2 =cell2mat(posf2);
    fclose('all');
    msg=sprintf('Coordinates loaded from %s and %s files',filenam1,filenam2);
    msgbox(msg);
    
    %check nan values inside the border files and delete them
    if ~isempty(find(isnan(posf2),1))
        posf2(isnan(posf2))=[];%remove nan
        posf2 = reshape(posf2,[size(posf2,2)/2,2]);%reshape the set of points in 2 colomns(x and y)
    end
    
    if ~isempty(find(isnan(posf1),1))
        posf1(isnan(posf1))=[];%remove nan
        posf1 = reshape(posf1,[size(posf1,2)/2,2]);%reshape the set of points in 2 colomns(x and y)
    end
    
    end

end

end