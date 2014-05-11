%This function takes the throw history and actually plots that in 3
%different views.

function plotThrow(xHist, yHist, zHist, inHole, distanceToPin, handles)

%these are vectors that represent the scale of the disc at the various time
%steps.  The scale is based on distance from a 'camera' in each of the
%plots.  For example as the disc moves up it gets larger in the overhead
%view.  They range from 0-1.
[xScale, yScale, zScale] = findSize(xHist, yHist, zHist);

%These will be the limits of the plot area:
xMax = max(abs(xHist))+10;
yMax = max(abs(yHist))+10;
zMax = max(abs(zHist))+10;

%make sure the pin is included in the x direction:
if distanceToPin > xMax
    xMax = distanceToPin+20;
end

%These are lower limits for when we get close to the pin:
if xMax < 100
    xMax = 100;
end
if yMax < 20
    yMax = 20;
end
if zMax < 50
    zMax = 50;
end


xMin = -2;
yMin = -yMax;
zMin = -5;

hold off;

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% PLOTTING THE THROW: FILLING THE DISC ALONG THE PROJECTED PATH           %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
%plot view ratios:
%if we change the physical plot size we can just change these values
%instead of messing with the below sizes

%plotDimensions = get(xzPlot, 'OuterPosition'); %this didn't work
%very well, the y dimension doesn't seem right

profileRatio  = 3.2; %size of x / size of y, physical size of plot area
overheadRatio = 3.2;
HeadonRatio   = 1;

%these scale the disc based on axis size
%to adjust the size in x or y change the first number:
profileXSize = 61*(xMax - xMin)/profileRatio/100;
profileYSize =  5*(zMax - zMin)*profileRatio/100;

overheadXSize = 40*(xMax - xMin)/overheadRatio/100;
overheadYSize = 15*(yMax - yMin)*overheadRatio/100;

headonXSize = 100*(yMax - yMin)/HeadonRatio/100;
headonYSize =  20*(zMax - zMin)*HeadonRatio/100;

%basic disc shapes
discProfile  = [-profileXSize/2, profileXSize/2, profileXSize/2, -profileXSize/2; 0, 0, profileYSize, profileYSize];
discOverhead = [cos((1/(100*2):1/100:1)*2*pi) .* overheadXSize; sin((1/(100*2):1/100:1)*2*pi) .* overheadYSize];
discHeadon   = [0, headonXSize, headonXSize, 0; 0, 0, headonYSize, headonYSize];

%limits for background shapes/axis
if distanceToPin > xMax
    xLim = distanceToPin+20;
else
    xLim = xMax+20;
end

%background shapes
skyProfile = [-5, xLim, xLim, -5; 0, 0, zMax+20, zMax+20];
groundProfile = [-5, xLim, xLim, -5; -8 -8 0 0];
groundOverhead = [-5, xLim, xLim, -5;-yMax-25, -yMax-25, yMax+25, yMax+25];
skyHeadon = [yMin-5, yMin-5, yMax+5, yMax+5; zMax, .1*zMax, .1*zMax, zMax];
groundHeadon = [yMin-5, yMin-5, yMax+5, yMax+5; zMin .1*zMax .1*zMax zMin];
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
%  PROFILE VIEW PLOT: SETTING AXIS, CREATING A HANDLE FOR FILLED DISC
axes(handles.xzPlot);
hold off; %start with a clean slate for plotting
axis([-2, xLim, zMin, zMax]); %profile
fill(skyProfile(1,:),skyProfile(2,:),[176/255 226/255 1]); %draw the sky
hold on; %draw everything else on top of sky
set(gca,'XTick',[]); %remove ticks
set(gca,'YTick',[]); %remove ticks
fill(groundProfile(1,:),groundProfile(2,:),[0 139/255 69/255]); %draw the ground
fill([-handles.holeSize handles.holeSize handles.holeSize -handles.holeSize] + distanceToPin, ...
    [0 0 handles.holeSize*2 handles.holeSize*2], 'r'); %draw hole marker
discProfileHandle = fill(yScale(1)*discProfile(1,:), ...
    yScale(1)*discProfile(2,:),'y'); %draw disc
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
%  OVERHEAD VIEW: SETTING AXIS, CREATING HANDLE FOR FILLED DISC
axes(handles.xyPlot);
hold off; %start with a clean slate for plotting
axis([-2, distanceToPin, yMin, yMax]); %overhead
fill(groundOverhead(1,:), groundOverhead(2,:),[0 139/255 69/255]); %draw the ground
hold on; %draw everything else on top of ground
set(gca,'YTick',[]); %remove ticks
fill([-handles.holeSize handles.holeSize handles.holeSize -handles.holeSize]+distanceToPin, ...
    [-handles.holeSize -handles.holeSize handles.holeSize handles.holeSize],'r'); %draw hole marker
discOverheadHandle = fill(zScale(1)*discOverhead(1,:), ...
    zScale(1)*discOverhead(2,:),'y'); %draw disc
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
%  HEAD ON VIEW:  SETTING AXIS, CREATING HANDLE FOR FILLED DISC
axes(handles.yzPlot);
hold off; %start with a clean slate for plotting
axis([yMin, yMax, zMin, zMax]); %head on
fill(skyHeadon(1,:),skyHeadon(2,:),[176/255 226/255 1]); %draw the sky
hold on; %draw everything else on top of sky
set(gca,'XTick',[]); %remove ticks

%this will be used to scale the pin in the headon view:
headOnScale = 450/distanceToPin;

%this ensures that the pin doesn't grow too large when we get close:
if headOnScale > 5
    headOnScale = 5;
end

fill(groundHeadon(1,:),groundHeadon(2,:),[0 139/255 69/255]); %draw the ground
fill([-.25 .25 .25 -.25],[.1*zMax, .1*zMax, .1*zMax+3.25, .1*zMax+3.25], 'r'); %draw hole marker
headOnHandle = fill((xScale(1)*discProfile(1,:))+ yHist(1), (xScale(1)*discProfile(2,:))+ zHist(1), 'y'); %draw disc
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %


% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
%  LOOP FOR ANIMATION
steps = length(xHist);
timeScale = 1;

%this ensures that the animation doesn't take too long
%we skip frames if it is long
if steps > 120
    timeScale = steps / 120;
    timeScale = round(timeScale);
end

for ii = 1:timeScale:length(xHist) %
    % PROFILE VIEW
    axes(handles.xzPlot);
    axis([-2, xLim, zMin, zMax]); %profile
    delete(discProfileHandle); %remove old disc
    discProfileHandle = fill((yScale(ii)*discProfile(1,:)) + xHist(ii), (yScale(ii)*discProfile(2,:)) + zHist(ii), 'y'); %draw new disc
    
    %  OVERHEAD VIEW
    axes(handles.xyPlot);
    axis([-2, xLim, yMin, yMax]); %overhead
    delete(discOverheadHandle); %remove old disc
    discOverheadHandle = fill((zScale(ii)*discOverhead(1,:)) + xHist(ii), (zScale(ii)*discOverhead(2,:)) + yHist(ii), 'y'); %draw new disc
    
    %  HEAD ON VIEW
    axes(handles.yzPlot);
    delete(headOnHandle); %remove old disc
    headOnHandle = fill((xScale(ii)*discHeadon(1,:)) + yHist(ii), (xScale(ii)*discHeadon(2,:)) + zHist(ii)+ ii/length(xHist), 'y'); %draw new disc
    axis([yMin, yMax, zMin, zMax]); %head on
    set(gca,'XDir','reverse'); %plot negative y values to the right
    
    %pause(0.05);
end

%draw in final step of animation, even if it was cut off:
if ii < length(xHist)
    axes(handles.xzPlot);
    axis([-2, xLim, zMin, zMax]); %profile
    delete(discProfileHandle); %remove old disc
    discProfileHandle = fill((yScale(end)*discProfile(1,:)) + xHist(end), (yScale(end)*discProfile(2,:)) + zHist(end), 'y'); %draw new disc
    
    %  OVERHEAD VIEW
    axes(handles.xyPlot);
    axis([-2, xLim, yMin, yMax]); %overhead
    delete(discOverheadHandle); %remove old disc
    discOverheadHandle = fill((zScale(end)*discOverhead(1,:)) + xHist(end), (zScale(end)*discOverhead(2,:)) + yHist(end), 'y'); %draw new disc
    
    %  HEAD ON VIEW
    axes(handles.yzPlot);
    delete(headOnHandle); %remove old disc
    headOnHandle = fill((xScale(end)*discHeadon(1,:)) + yHist(end), (xScale(end)*discHeadon(2,:)) + zHist(end)+ 1, 'y'); %draw new disc
    axis([yMin, yMax, zMin, zMax]); %head on
    set(gca,'XDir','reverse'); %plot negative y values to the right
end
%END ANIMATION LOOP
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

%plotting the trajectory lines at the end
axes(handles.xzPlot); %Profile
plot(xHist, zHist, 'r');

axes(handles.xyPlot); %overhead
plot(xHist, yHist, 'b');

drawnow;



%guidata(hObject, handles);
