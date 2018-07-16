function CreateStepBorder(alldata)
%-----------------------------------------------------------------------------------------
%   Readme
% 
%   This code does the following:
%
% - Plots alldata matrix using the colormap defined by nanonisMap (NanoLib/op/nanonisMap.m)
% - Allows the user to select the region of interest(roi) inside the image loaded by clicking 
% and dragging the mouse. When double click the fit starts.
% - Fits to every scan line inside the roi the step function -A*tanh(B*(x-C)-D with A,B,C,D>0; 
% the fit parameter C is x coordinate of the inflection point of the tanh function
% i.e. the position of the step in a scanline. The y coordinate is the scan line index.
% All of these x,y coordinates define the points of the border line between W and C regions.
% Note: The shape of the function used for the fit defines an up/down step from left to right.
% - Asks to the user whether to save the border points in a txt file.
% - Plots the border line points as a  green line.
% - Creates a figure where only the roi is visible.
%
%  
%                                                                          G.B. 08.06.2018
%-----------------------------------------------------------------------------------------

%% Main Part

my_Plotdata(alldata);
mask = my_Mask(alldata);%Define the region called mask where to find the step
pos = my_Findstep(alldata,mask);%find the step inside the region selected
my_SavePoints(pos);%store the points in a file txt


%% Functions used in this code

% Plot the data
function my_Plotdata(alldata)
    
    figure('Name','Data','NumberTitle','off','Units','normalized','pos', [0.0377 0.0667 0.3774 0.6667])
    imagesc(alldata);
    tip= {'Click and drag the mouse to draw' 'the contour of the region containing the border'};
    title(tip)
my_SetImageDefaultProperties(alldata);
    hold on %keep the figure for next plot
    end

% Define the region called mask where to find the step
function mask = my_Mask(alldata)

    regOfInt = imfreehand;
    addNewPositionCallback(regOfInt,@nastyfcn)
    tip= {'Double-clicking on the drawn contourt to start' 'the tanh fit and find the border'...
        'inside using the step positions'};%hint as title
    title(tip)    
    wait(regOfInt);
    mask = nastyfcn();
    function mask = nastyfcn(~)
        mask=createMask(regOfInt);%create a binary img with 1s inside the region and 0 outside
        mask = double(mask);   
        mask=mask.*alldata;
        msk = findobj('Type','figure','Name','Mask');
        if isempty(msk)
            figure('Name','Mask','NumberTitle','off','Units','normalized','pos',[0.4151 0.0667 0.1509 0.2667])
        else
            set(0,'CurrentFigure',msk);%makes the Redion A figure the current figure
        end
        figure(gcf)
        imagesc(mask);
        tip= 'THIS IS THE REGION SELECTED!';
        title(tip);
my_SetSmallImageDefaultProperties(alldata);
    end

end

% Do the routine to find the boundary points
function pos = my_Findstep(alldata,mask)      
    % loop over every scan line 
    posx=zeros(1,size(alldata,1)); %initialization of the border points coordinates
    posy=posx;%initialization of the border points coordinate
    fitbar = waitbar(0,{'fitting the scan lines...' 'Please wait'});
    
    for i = 1:size(alldata,1)
        xnonzero = find(mask(i,:));%x coords of those non zero pxs inside the mask 
        posy(i) = i;
        if i == round(size(alldata,1)/3)
            waitbar(.33,fitbar,{'fitting the scan lines.' 'Please wait'});
        end
        if i == round(size(alldata,1)*2/3)
            waitbar(.66,fitbar,{'fitting the scan lines..' 'Please wait'});
        end
        if i == round(size(alldata,1)-1)
            waitbar(.99,fitbar,{'fitting the scan lines...' 'Please wait'});
        end
        
        
        %check the scanline contains at least 3 points of the region interested
        if ~isempty(xnonzero) && (size(xnonzero,2)>=3) 
            %initialization of the fit, defining the guess coefficients
            % -A*tanh(B*(x-C)-D with A B C>0
            stepHightG = abs(max(mask(i,xnonzero)-min(mask(i,xnonzero)))/2);%A
            stepWidthG = 2;%B guess is 2 pxs(sharp step)
            stepPosG = abs((xnonzero(end)+xnonzero(1))/2);%C guess is in the middle
            stepOffsetG = abs(mask(i,xnonzero(1)) - stepHightG);%D depends on A coef
            guessCoef=[stepHightG stepWidthG stepPosG stepOffsetG];%array of guess coefficients
            %fit
            cfit = lsqnonlin(@my_tanhfit,guessCoef,[],[],[],xnonzero,mask(i,xnonzero));
            cfit = abs(cfit);%avoiding negative coeff.
            cadata = findobj('Type','figure','Name','Data');%handle of the figure data
            dataaxes = get(cadata,'CurrentAxes');

            %check if the step position fall outside of the image
            if cfit(3) >= max(get(dataaxes,'XLim'))
                posx(i) = max(get(dataaxes,'XLim'));
            elseif cfit(3) <= min(get(dataaxes,'XLim'))
                posx(i) = min(get(dataaxes,'XLim'));
            else
                posx(i) = cfit(3);
            end
%%check every fit on the step
%             fit=(-cfit(1).*tanh(cfit(2).*(xnonzero-cfit(3)))-cfit(4));
%             fittest = (-guessCoef(1).*tanh(guessCoef(1).*(xnonzero-guessCoef(3)))-guessCoef(4));   
%             figure()
%             hold on
%             plot(xnonzero,mask(i,xnonzero),'.b')
%             plot(xnonzero,fittest,'-r')
%             plot(xnonzero,fit,'-k')
%             hold off
        else
            posx(i) = nan;
            posy(i) = nan;       
        end
       
    end
    close(fitbar);
    
    % plot the image with the boundary points found
    figure('Name','Border','NumberTitle','off','Units','normalized','pos', [0.0377 0.0667 0.3774 0.6667])
    imagesc(alldata);
    tip= 'Border';
    title(tip)
my_SetImageDefaultProperties(alldata)

    hold on %keep the figure for next plot
    plot(posx,posy,'-g','MarkerSize',15)
    posx = posx';
    posy = posy';
    pos=[posx posy];%vector of points to be saved
    hold off

end

% Open the file named filename and print the pos vector.
function my_SavePoints(pos)
    
    %pos = borderOfInt.getPosition();%read note
    prompt = {'Insert file name:'};
    titl = 'Save coordinates in txt file';
    dims = [1 40];
    definput = {'StepBorder.txt'};
    filename = char(inputdlg(prompt,titl,dims,definput));
    fid = fopen(filename,'wt');
    pos=pos';
    
    if ~isempty(find(isnan(pos),1))
        pos(isnan(pos))=[];%remove nan
        pos = reshape(pos,[size(pos,2)/2,2]);%reshape the set of points in 2 colomns(x and y)
    end
    
    
    fprintf(fid,'%f %f\n',pos); %overwrites previous data, data in pixels
    fclose('all');
    msg=sprintf('Coordinates saved in the %s file',filename);
    msgbox(msg);
   
end

% Do a tanh fit to find the step position
function res=my_tanhfit(p,x,y)
    %returns -A*tanh(B*(x-C)-D with A,B,C,D>0
    A = p(1);
    B = p(2);
    C = p(3);
    D = p(4); 
    res=(-abs(A).*tanh(abs(B).*(x-abs(C)))-abs(D))-y;%in case we take Current channel the step is a down step

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