%This function takes in many throw parameters and then calculates the disc
%trajectory.  It returns the trajectory as vectors in the x,y,z directions.
% It also returns the index number the disc landed at the pin, 0 meaning it
% did not on this throw.

%the code is largely based on Java code for 2D flight found here:
%http://scripts.mit.edu/~womens-ult/frisbee_physics.pdf

%Frisbees curve based on tilt.  While traveling up, they move towards the
%forward tilt, and then while traveling down they move towards the downward
%tilt.  This allows one to curve a throw right by tilting the disc up to
%the right.  See this video for an example:
%https://www.youtube.com/watch?v=gjV-ANeGvZw 


function [xHist, yHist, zHist, inHole] = throwDisk4(v0,theta,a,tilt, discNumber, yVel, hole, holeSize)
%physical constants:
g = -9.81;
rho = 1.23; %kg / m^3, density of air
deltaT = 0.01; %time step
m2ft = 3.28; %feet in a meter

%properties of a particular disc:
%they are stored as vectors, each index should refer to one disc
%index 1 is the longest flight disc (driver), index 4 is the shortest (putter)
CD0  = [0.08, 0.08, 0.08, 0.10];   %drag coefficient at minimum drag, a = a0
CDa  = [2.72, 2.72, 2.72, 2.75];   %induced drag coeffiecient, dependent on a
CL0  = [0.12, 0.10, 0.05, 0.05];   %lift coefficient at a = 0
CLa  = [1.40, 1.40, 1.40, 1.30];   %lift coefficient dependent on a
a0   = [-4, -4, -4, -4];           %angle of attack at 0 lift and minimum drag
r    = [0.100, 0.106, 0.150, 0.155];  %m, radius of frisbee
mass = [0.200, 0.225, 0.250, 0.300];  %kg, mass of frisbee


z0 = 1; %starting height
vx0 = cosd(theta) * v0; %split the vector into x, z components
vz0 = sind(theta) * v0;
vy0 = yVel; %y velocity was passed as a seperate argument

%disc properties calculated for each throw:
CL = CL0(discNumber) + (CLa(discNumber) * a * pi / 180); %lift
CD = CD0(discNumber) + CDa(discNumber) * ((a - a0(discNumber)) * pi / 180)^2; %drag
A = pi * r(discNumber)^2; %M^2, area of frisbee
m = mass(discNumber);

%set velocity to initial:
vx = vx0;
vy = vy0;
vz = vz0;

%put disc at initial positions:
x = 0;
y = 0;
z = z0;

%vectors to store the position and velocity:
xHist = x;
yHist = y;
zHist = z;
vxHist = vx;
vyHist = vy;
vzHist = vz;

counter = 0; %index we are currently working on
inHole  = 0; %0 if disc never reaches hole, >0 if it does
while z > 0 && inHole == 0 %loop until disc hits ground or hole
    counter = counter + 1; %index we are currently working on
    
    %determine change in speeds:
    deltaVz = (rho * vx^2 * A * CL / 2 / m + g) * deltaT; %take lift into account
    arcY = vz * (tilt*pi/180)^3 * 10; %left right arc, based on left right tilt
    arcX = vz * (a*pi/180)^3 * 10; %forward and back tilt causes forward and back motion
    
    deltaVx = -rho * vx^2 * A * CD * deltaT; %drag slows things down horizontally
    deltaVy = -rho * vy^2 * A * CD * deltaT;
    
    %adjust speeds:
    vx = vx + deltaVx;
    vy = vy + deltaVy;
    vz = vz + deltaVz;
    
    %find new positions:
    x = x + (vx+arcX) * deltaT;
    y = y + (vy+arcY) * deltaT;
    z = z + vz * deltaT;
    
    %store values for later ploting:
    xHist = [xHist; x];
    yHist = [yHist; y];
    zHist = [zHist; z];
    vxHist = [vxHist; (vx+arcX)];
    vyHist = [vyHist; (vy+arcY)];
    vzHist = [vzHist; vz];
    
    %determine if the disc is in the hole by checking all 3 dimensions
    if abs(x*m2ft - hole) <= holeSize && abs(y*m2ft) <= holeSize && z*m2ft <= holeSize * 2
        inHole = counter; %inHole serves as both flag and index
    end
        
end

%convert to feet:
xHist = xHist * m2ft;
yHist = yHist * m2ft;
zHist = zHist * m2ft;

