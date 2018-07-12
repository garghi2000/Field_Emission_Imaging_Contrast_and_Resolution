function GetResolution(alldata)

%% Main Part
my_Plotdata(alldata);%see the function
[posA,posB] = my_ReadBorderfiles();
%my_ShowBorders(posA,posB);%uncomment to see the original files points
my_MakeBorderRoi(posA,posB);


%% Function used in this code

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
        Nscanline = sort(unique(cutposB(:,2)));
    end
    res = nan(size(Nscanline,1),1);
    for i = Nscanline'
        
        k = i - (Nscanline(1)-1);%index starting from 1
        %part that need to be improved!!! The problem comes qhen there are
        %more than 1 x coord for scanline(every time a border contains
        %horizontal segments:
        %instead of mean those x coordinates at the same scanline it could check which are
        %those x coordinate that have minimum distances
        
        xmA = mean(cxA(cyA==i));%this takes the mean value of the x position at same scanline
        xmB = mean(cxB(cyB==i));%this takes the mean value of the x position at same scanline
        res(k) = xmA-xmB;%displacement defined as the different between averaged x coords

%         Calculate distance between 2 set of points
%         rng('default') % For reproducibility
%         X = rand(3,2);
%         pdist2('euclidean')
%     
    
    end
    rhis = findobj('type','figure','Name','reshist');
    if isempty(rhis)
        
    figure('Name','reshist','NumberTitle','off','Units','normalized','pos', [0.4151 0.0667 0.2264 0.2667])
    else
        set(0,'CurrentFigure',rhis);%makes the histogram figure the current figure
    end
    figure(gcf)
    resh= histogram(res,50);
       
    avgDisp=nanmean(res(:));%mean
    sigmaDisp=nanstd(res(:));%standard deviation
    tltres = sprintf('resolution in px = %.2f',sigmaDisp);
    tltdisp =sprintf('the shift is = %.2f',avgDisp);
    xlabel({'Displacement by data' tltres tltdisp });
    ylabel('Incidence');
    set(resh,'FaceColor','r','EdgeColor','r');
    
    % % % % % %Compute cross correlation
% % % % % XC=xcorr2(double(img1)-mean(mean(img1)),double(img2)-mean(mean(img2)));
% % % % % 
% % % % % %Get cross correlation max
% % % % % [M1, I1]=max(abs(XC));
% % % % % [~, Xoff]=max(M1);  %X is the second dimention!!!
% % % % % Yoff=I1(Xoff);
% % % % % 
% % % % % %Remove img2 size to get offset
% % % % % Xoff=Xoff-size(img2,2);
% % % % % Yoff=Yoff-size(img2,1);
    
end
   
% Make borders draggable
function my_MakeBorderRoi(posA,posB)
    
    ca = gca;
    hA = imfreehand(ca,posA,'Closed',0);
    addNewPositionCallback(hA,@my_interpolation)%callback my_interpolation when drawing is dragged
    hB = imfreehand(ca,posB,'Closed',0);
    addNewPositionCallback(hB,@my_interpolation)%callback my_interpolation when drawing is dragged

    setColor(hB,'g');
    setColor(hA,'b');
my_interpolation();

    %interpolate the borders 
    function my_interpolation(~)
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
        cxA(cyA<iline) = [];
        cxB(cyB<iline) = [];
        cxA(cyA>fline) = [];
        cxB(cyB>fline) = [];
        %y coordinates
        cyA(cyA<iline) = [];
        cyB(cyB<iline) = [];
        cyA(cyA>fline) = [];
        cyB(cyB>fline) = [];

        %cutted positions stored
        cutposA = [cxA cyA];%coordinates separated in different vectors
        cutposB = [cxB cyB];%coordinates separated in different vectors
       
        %check that the lines were cutted
%         plot(cxA,cyA,'.b','MarkerSize',5);
%         plot(cxB,cyB,'.g','MarkerSize',5);
 
        my_calculate_resolution(cutposA,cutposB);

    end

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
    definput = {'border2.txt','border1.txt'};
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
    
    %check nan values inside the 
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