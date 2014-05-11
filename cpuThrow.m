%This function will take the distance to the pin, difficulty level and then
%return the computers throw parameters.

function [v0, theta, alpha, yTilt, discN, yVel] = cpuThrow(x, diff)
vLimit = 25; %upper limit on velocity

discN = 2; %Always use disc 2, as a middle disc, 
%the computer is pretty good at calculating throws even without the disc
yVel  = 0;
yTilt = 0;
alpha = 15; %these are good tilts for most throws
theta = 15;
idealV = sqrt(x*2) + 1; %this is the formula which works quite well for a variety of distances.

%makes sure we don't exceed the upper limit for speed
if idealV > vLimit
    idealV = vLimit;
end

%now we have to adjust the throw based on skill level
if diff == 3 %hardest skill, don't adjust speed, add slight tilt
    v0 = idealV;
    yTilt = randn; %a slight random tilt will cause minor curving
elseif diff == 2
    v0 = idealV * sqrt(sqrt(rand+.5)); %adjust ideal velocity slightly
    yTilt = randn*10; %a larger random tilt will cause noticable curving
else
    v0 = idealV * sqrt(rand+.5); %adjust ideal velocity a lot
    yTilt = randn*20; %a large random tilt that will cause a lot of curving
    yVel = randn; %add some slight left and right motion
end





