%This function will take in the vectors of acceleration and then find the
%throw parameters.

function [v0,theta,alpha,yTilt,discN,yVel] = findThrowData(x, y, z, res)
maxV = 30; %cap the throw speed at 30 m/s

maxIndex = find(res == max(res)); %finds index of peak acceleration
if maxIndex <= 4 %ensure the peak is not at the start 
    maxIndex = 5;
end

%we will use this to calculate the alpha tilt:
xyPlaneVector = sqrt(x(maxIndex)^2 + y(maxIndex)^2);

theta = atand(x(maxIndex-4) / z(maxIndex-4)); %angle of velocity vector
alpha = (theta + acosd(xyPlaneVector / res(maxIndex))) / 4; %angle of disc
yTilt = atand(y(maxIndex-4) / res(maxIndex-4)); %left right tilt of disc
v0    = sqrt(y(maxIndex)^2 + x(maxIndex)^2) * 9.81; %speed

discN = 2; %return disc 2 as a default, should be replaced later
yVel = 0;  %no left right motion as default
yTilt = -yTilt; %ensure correct axis orientations

%limit speed
if v0 > maxV
    v0 = maxV;
end
end
