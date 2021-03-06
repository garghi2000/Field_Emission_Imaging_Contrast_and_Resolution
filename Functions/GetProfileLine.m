function GetProfileLine(alldata)

%-----------------------------------------------------------------------------------------
%   Readme
%   
%   Hint: Before using this function set the custom properties of the
%   images aspects(function SetImageDefaultProperties(alldata))
%   
% 
%   This function does the following: 
%   - Plots the data "alldata" using the matrix representation(origin on topleft corner);
%   The aspect of the figure is defined by the function SetImageDefaultProperties()
%   - Lets the user draw the line and drag or modify it after created.
%   - Plots the line profile and upload it every time the drawn line is
%   moved or modified
% 
%                                                                           G.B. 03.07.2018
%-----------------------------------------------------------------------------------------


%% Main Part
pos=my_GetPosProfileLine(alldata);%Draw the line; pos is the vector defining the position of the line
my_PlotProfLine(pos);%Plot the profile line

%% Functions used in this code

%Create the position of the inizial point and the final point of the line
function pos = my_GetPosProfileLine(alldata)
    %let user create a line
    profline = imline();%matlab function to produce the line
    strtitle = sprintf('Left clicking on the line to drag or modify it \n(the mouse icon changes)');
    strtitle = compose(strtitle);
    title(strtitle);%change title of the figure to help the user 
    pos=profline.getPosition();%use the position of the line to create the profile
    addNewPositionCallback(profline,@my_PlotProfLine)%callbacks the function @fnc when pos changes
end

%Use the output of GetProfileLine to plot the profile line of the image
function my_PlotProfLine(pos)   
    n = findobj('type','figure');
    n = length(n);
    if n <2 %create the figure for the profile line
        figure('Name','Profile Line','NumberTitle','off','Units','normalized','pos', [0.4717 0.1667 0.2830 0.3333]) 
    else %if the figure already exists it change the current figure to overwrite the profile
    PrlinFig =  findobj('type','figure','Name','Profile Line');
    set(0,'CurrentFigure',PrlinFig);%makes the Profile line figure the current figure
    end
    xi =pos(:,1);
    yi =pos(:,2);
    h = improfile(alldata,xi,yi);%matlab function to profile line
    plot(h);
end

end