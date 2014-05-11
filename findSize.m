%This function will take 3 vectors of x,y,z locations and then calculate
%the scale needed at each time step in order to simulate a perspective from
%a camera effect.
%xSize will be the size when viewed head on
%ySize will be profile
%zSize will be overhead
%they will be scales from 0 to 1

function [xSize, ySize, zSize] = findSize(x, y, z)
    %for x the camera is just at 0, but for z and y the camera is at some
    %unknown point just beyond the max extent, so we must find those:
    zMax = max(z) + 10;
    yMin = min(y) - 10;
    
    %scale as inverse of distance:
    xSize = 2 ./ x;
    ySize = 2 ./ (y-yMin);
    zSize = 2 ./ (zMax-z);
    
    xSize(find(xSize > 1)) = 1; %cap values at 1
    ySize(find(ySize > 1)) = 1;
    zSize(find(zSize > 1)) = 1;
    %zSize(find(zSize < 0.1)) = 0.1;
    zSize(find(z > zMax)) = 1; %disc gets too large when coming towards camera

end