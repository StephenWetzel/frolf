%This function will take the distance to the pin and then plot 3 displays
%of that.  This is meant to represent the time pre-throw, when actual throw
%distances are not yet known.

function plotPre(distanceToPin, handles)

%These will be the limits of the plot area:
xMax = distanceToPin+20;
yMax = 25;
zMax = 100;

xMin = -2;
yMin = -yMax;
zMin = -5;

%adjust the pin location in the plot:
heightAboveGround = 15;

xLim = xMax+20;

%this scales the pin in the head on view:
headOnScale = 450/distanceToPin;
if headOnScale > 5
    headOnScale = 5;
end

%plot view ratios:
%if we change the physical plot size we can just change these values
%instead of messing with the below sizes

profileRatio  = 3.2; %size of x / size of y, physical size of plot area
overheadRatio = 3.2;
HeadonRatio   = 1;

%these scale the disc based on axis size
%to adjust the size in x or y change the first number:
profileXSize = 20*(xMax - xMin)/profileRatio/100;
profileYSize =  1*(zMax - zMin)*profileRatio/100;

overheadXSize = 10*(xMax - xMin)/overheadRatio/100;
overheadYSize =  3*(yMax - yMin)*overheadRatio/100;

headonXSize = 25*(yMax - yMin)/HeadonRatio/100;
headonYSize =  2*(zMax - zMin)*HeadonRatio/100;

%basic disc shapes
discProfile  = [-profileXSize/2, profileXSize/2, profileXSize/2, -profileXSize/2; 0, 0, profileYSize, profileYSize];
discOverhead = [cos((1/(100*2):1/100:1)*2*pi) .* overheadXSize; sin((1/(100*2):1/100:1)*2*pi) .* overheadYSize];
discHeadon   = [-headonXSize/2, headonXSize/2, headonXSize/2, -headonXSize/2; 0, 0, headonYSize, headonYSize];

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
fill(skyProfile(1,:),skyProfile(2,:),[176/255 226/255 1]); %draw the sky
hold on; %draw everything else on top of sky
set(gca,'XTick',[]); %remove ticks
set(gca,'YTick',[]); %remove ticks
fill(groundProfile(1,:),groundProfile(2,:),[0 139/255 69/255]); %draw the ground

fill([-handles.holeSize handles.holeSize handles.holeSize -handles.holeSize] + distanceToPin, [0 0 handles.holeSize*2 handles.holeSize*2], 'r'); %draw hole marker
discProfileHandle = fill(discProfile(1,:), discProfile(2,:),'y'); %draw disc
axis([-2, xLim, zMin, zMax]); %profile plot size
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
%  OVERHEAD VIEW: SETTING AXIS, CREATING HANDLE FOR FILLED DISC
axes(handles.xyPlot);
hold off; %start with a clean slate for plotting
fill(groundOverhead(1,:), groundOverhead(2,:),[0 139/255 69/255]); %draw the ground
hold on; %draw everything else on top of ground
set(gca,'YTick',[]); %remove ticks
fill([-handles.holeSize handles.holeSize handles.holeSize -handles.holeSize]+distanceToPin, ...
    [-handles.holeSize -handles.holeSize handles.holeSize handles.holeSize],'r') %draw hole marker
discOverheadHandle = fill(discOverhead(1,:), discOverhead(2,:),'y'); %draw disc
axis([-2, xLim, yMin, yMax]); %overhead


% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
%  HEAD ON VIEW:  SETTING AXIS, CREATING HANDLE FOR FILLED DISC
axes(handles.yzPlot);
hold off; %start with a clean slate for plotting
fill(skyHeadon(1,:),skyHeadon(2,:),[176/255 226/255 1]); %draw the sky
hold on; %draw everything else on top of sky
set(gca,'XTick',[]); %remove ticks
set(gca,'YTick',[]); %remove ticks
fill(groundHeadon(1,:),groundHeadon(2,:),[0 139/255 69/255]); %draw the ground
fill([-.25 .25 .25 -.25],[.1*zMax, .1*zMax, .1*zMax+3.25, .1*zMax+3.25], 'r');
headOnHandle = fill((discHeadon(1,:)), (discHeadon(2,:)+heightAboveGround), 'y'); %draw disc
axis([yMin, yMax, zMin, zMax]); %head on
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

hold off; %ensure hold doesn't mess up other plotting later.
