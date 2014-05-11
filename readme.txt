Frisbee Golf (Frolf)

Rules are similar to golf.
Use different discs as you would different clubs for different distances
Count number of throws need to reach goal.
Lowest number of throws wins.

FrolfSimulation.m is the main file.
Hold accelerometer in hand, with cord towards wrist and palm.
Hold hand so that z is pointing straight up, and x is pointing directly away from you.
Tilt left and right to control tilt of throw.
Throw by extending arm so that x ends up pointing directly away from you.
That is, rotate 90 degrees clockwise.
Ending tilt above x axis will control angle of attack of disc.
Speed of throw will control speed of disc.
Select different discs with drop down menu.

Enter CPU as a name to play against the computer.


Definitions:
Pin, hole, goal – names for the place the player is trying to get the disc to in order to finish.
x – the dimension facing directly away from the player and towards the pin.
y – the positive to the left, negative to the right
z – positive going up, negative down

Profile – view of the xz plane, represents a side view.
Overhead – view of the xy plane, represents a bird eye's view.
Headon – view of the yz plane, represents player's view.

Theta – angle of velocity vector in the xz plane.
Alpha, a – angle of attack
Angle of attack – the angle the disc makes with the ground in the forward direction, this is used for lift calculations, and is different from theta.
Tilt – the angle of the disc makes with the y axis, represents the left right tilt of disc and controls curve.


Frisbee flight:
Frisbees cannot be modeled without taking into account the air.  They generate lift which causes flights that are quite different from a projectile modeled in a vacuum.  This disc will tend to move towards the upper edge of the disc on the upward portion of its flight, and then away from it on the downward portion.  In practice this means discs can be curved left and right by tilting the disc at release.  This also means one can generate a boomerang effect by tilting the disc heavily up.  An example of this curve is seen in this video:
https://www.youtube.com/watch?v=gjV-ANeGvZw

This pdf explains the details of 2D Frisbee flight:
http://scripts.mit.edu/~womens-ult/frisbee_physics.pdf

It was referenced to build the basic model.  3D flight was added by taking into account the y tilt and then curving the disc appropriately.  


Core functionality:
Threshold crossing

Advanced functionality:

2D animations in all three views to simultaneously show the path which the disc travels.

The flight of a frisbee is quite complex to model, and requires drag and lift calculations.
Plotting the flight in 3 dimensions required taking into account the effect of disc tilt and curving.

To create a intuitive effect the disc is scaled as it travels in 3 plots.  This represents a camera's perspective, and the disc will grow as it moves towards this “camera” (eg, larger as it moves away from the ground in the overhead view).

Passing handles data to external functions, working on variables without needing handles. before every variable.

Plotting to the GUI from an external function

Tooltips that appear on hovering over controls like the select disc menu.  This tip explains the different disc choices without crowding the UI after the player learns the differences.

Enhanced tooltip using HTML.  Tooltips can use HTML, and it was used to format the tip in a way that makes it more readable.

Sounds to indicate the pin has been reached.

Collision detection of the disc and goal required checking in 3 dimensions if the disc intersected the goal, which could vary in size.

AI, the game has a computer controlled player which calculates it throw based on the same info the player has available.

Menus boxes to select difficulty and disc type.

Score presented in a spreadsheet.

Hiding the intro GUI objects after the game begins.



checkWinner.m - Determine the winning (lowest) score, and display message box.
cpuThrow.m - Calculate the computer’s throw
findSize.m - Find the proper disc scale for display, at the time steps.
findThrowData.m - Get the human throw data from accelerometer
FrolfSimulation.m - Main file
plotPre.m - Display field before a throw
plotThrow.m - Display field during and after a throw
throwDisk4.m - Calculate the disc’s trajectory based on initial conditions

RESOURCES:

sucess2.wav file from:
https://freesound.org/people/grunz/sounds/109663/

birds.wav
https://freesound.org/people/cajo/sounds/34207/

eagle.wav
https://freesound.org/people/thecluegeek/sounds/140847/


Some Matlab code regarding the throw was referenced while designing the displacement algorithms.  This code was not directly copied, and only gave displacements in x and z (profile view), but we did use the coefficients for drag and lift as found during the experiments perform in the article.  We found these coefficients unattainable elsewise.

Sarah Ann Hummel:  Frisbee Flight Simulation And Throw Biomechanics:
http://morleyfielddgc.files.wordpress.com/2009/04/hummelthesis.pdf


