%Section 72 Group 8 Biweekly 2
%Drew Lentz, Stephen Wetzel


function varargout = FrolfSimulation(varargin)
% FROLFSIMULATION MATLAB code for FrolfSimulation.fig
%      FROLFSIMULATION, by itself, creates a new FROLFSIMULATION or raises the existing
%      singleton*.
%
%      H = FROLFSIMULATION returns the handle to a new FROLFSIMULATION or the handle to
%      the existing singleton*.
%
%      FROLFSIMULATION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FROLFSIMULATION.M with the given input arguments.
%
%      FROLFSIMULATION('Property','Value',...) creates a new FROLFSIMULATION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before FrolfSimulation_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to FrolfSimulation_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help FrolfSimulation

% Last Modified by GUIDE v2.5 12-Mar-2014 13:06:07

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @FrolfSimulation_OpeningFcn, ...
    'gui_OutputFcn',  @FrolfSimulation_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before FrolfSimulation is made visible.
function FrolfSimulation_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to FrolfSimulation (see VARARGIN)

% Choose default command line output for FrolfSimulation
handles.output = hObject;
% Initializing the Rolling Plot
handles.buf_len = 200;

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% INITIALIZATION OF VARIABLES                                             %
% All initialization of variables take place in the opening function unless
% required elsewhere                                                      %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

% create variables for all the three axis and the resultant
handles.gxdata = zeros(handles.buf_len,1); %X axis
handles.gydata = zeros(handles.buf_len,1); %Y axis
handles.gzdata = zeros(handles.buf_len,1); %Z axis
handles.redata = zeros(handles.buf_len,1); %Resultant magnitude
handles.index = 1:handles.buf_len; %Time Index

%initializing vectors for x,y,z filtered data
handles.gxFiltData = zeros(handles.buf_len,1); %X axis
handles.gyFiltData = zeros(handles.buf_len,1); %Y axis
handles.gzFiltData = zeros(handles.buf_len,1); %Z axis
handles.reFiltData = zeros(handles.buf_len,1); %Resultant Filtered

%initialize vectors for filtered throw data
handles.throwXFilterData = zeros(10,1);
handles.throwYFilterData = zeros(10,1);
handles.throwZFilterData = zeros(10,1);
handles.throwResFilterData = zeros(10,1);

%initialized threshold flag
handles.tFlag = 0;

%initializing filtered data
handles.gxFilt = 0;
handles.gyFilt = 0;
handles.gzFilt = 0;

%Hole Placement Vector for the 9 hole course
handles.hole = [480, 3; 640, 4; 320, 3; 800, 5; 200, 2; 555, 4; 381, 3; 684, 4; 932 5];
handles.inHole = 0;%flag for in the hole

%initializing starting points, hole index, throw number
handles.xi=0; %initial throw position in x
handles.yi=0; %initial throw position in y
handles.holeIndex=1; %hole index for hole placement vector
handles.throwNumber = 1; % counter for throws
handles.setupFlag = 0; % Initialize setup flag for reading/calibrating the accelerometer
handles.readyFlag = 1; %initialize the ready button for read accelerometer loop

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% DEFAULT VALUES                                                          %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
handles.player = 1; %default player number
handles.numberOfPlayers = 1; % Default number of players
handles.difficulty = 1; %1 easy, 3 hard
handles.holeSize = 5; %size of hole
handles.score = cell(4,11); % Default score placement in the scorecard
handles.wind = 0; %Default wind speed
handles.alphaVal = .33;
handles.threshold = 2.8;

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% Sound for successful shots, from:
% https://freesound.org/people/grunz/sounds/109663/
[handles.goalWav, handles.goalFs] = audioread('success2.wav');

% Birdy, one under par:
% https://freesound.org/people/cajo/sounds/34207/
[handles.birdWav, handles.birdFs] = audioread('birds.wav');

% Eagle, two under par:
%https://freesound.org/people/thecluegeek/sounds/140847/
[handles.eagleWav, handles.eagleFs] = audioread('eagle.wav');

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% OPENING SERIAL COMMUNICATION, CALIBRATING, READING THE ACCELEROMETER    %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

%Specifies the COM port that the Arduino board is connected to
handles.comPort = 'COM4';
%comPort = '/dev/tty.usbmodemfd121';

% Initialize the Serial Port - setupSerial() (not to be altered)
%connect MATLAB to the accelerometer
if (~exist('serialFlag','var'))
    [handles.accelerometer.s,handles.serialFlag] = setupSerial(handles.comPort);
end


if(~exist('calCo', 'var'))
    handles.calCo = calibrate(handles.accelerometer.s);
end

handles.setupFlag = 1; % Update setup flag when successful
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

% Update handles structure
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = FrolfSimulation_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in beginGameButton.
function beginGameButton_Callback(hObject, eventdata, handles)
% hObject    handle to beginGameButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if strcmp(get(handles.beginGameButton, 'string'), 'Begin Game');
    set(handles.beginGameButton, 'string', 'Ready');
    %get info from player:
    handles.difficulty = get(handles.difficultyMenu, 'Value');
    handles.score = ''; %delete any previous value
    if isempty(get(handles.playerName1, 'string'))
        set(handles.playerName1, 'string', 'CPU');
    end
    
    guidata(hObject, handles); %update handles
    handles.score{1,1} = get(handles.playerName1, 'string');
    handles.score{2,1} = get(handles.playerName2, 'string');
    handles.score{3,1} = get(handles.playerName3, 'string');
    handles.score{4,1} = get(handles.playerName4, 'string');
    
    %hide the input fields, show the score card:
    set(handles.playerName1, 'visible', 'off');
    set(handles.playerName2, 'visible', 'off');
    set(handles.playerName3, 'visible', 'off');
    set(handles.playerName4, 'visible', 'off');
    set(handles.difficultyMenu, 'visible', 'off');
    set(handles.text34, 'visible', 'off');
    set(handles.text35, 'visible', 'off');
    set(handles.text36, 'visible', 'off');
    set(handles.text37, 'visible', 'off');
    set(handles.text40, 'visible', 'off');
    set(handles.text41, 'visible', 'off');
    set(handles.scoreTable, 'visible', 'on');
    set(handles.discMenu, 'visible', 'on');
    set(handles.textDiscType, 'visible', 'on');
    
    %set up number of players:
    handles.score{1,11} = 0; %total
    
    if isempty(handles.score{2,1})
        handles.numberOfPlayers = 1;
    elseif isempty(handles.score{3,1})
        handles.numberOfPlayers = 2;
        handles.score{2,11} = 0; %total
    elseif isempty(handles.score{4,1})
        handles.numberOfPlayers = 3;
        handles.score{2,11} = 0; %total
        handles.score{3,11} = 0; %total
    else
        handles.numberOfPlayers = 4;
        handles.score{2,11} = 0; %total
        handles.score{3,11} = 0; %total
        handles.score{4,11} = 0; %total
    end
    %determining difficulty, changes dimensions of the hole
    if handles.difficulty == 3
        handles.holeSize = 1;
    elseif handles.difficulty == 2
        handles.holeSize = 3;
    else
        handles.holeSize = 10;
    end
    
    %initializing the throw positions, hole index, throw number, this is
    %done here to accomodate for new games
    handles.xi=0;
    handles.yi=0;
    handles.holeIndex=1;
    handles.throwNumber = 1;
    
    
    set(handles.textPlayerName, 'String', handles.score{1,1}); %set player name text on GUI
    set(handles.scoreTable, 'data', handles.score); %set scorecard
    guidata(hObject, handles); %update handles
end

%If statement for first throw of each hole
if handles.throwNumber == 1
    handles.distanceToPin = handles.hole(handles.holeIndex,1);
end
% Plots the view of the next throw
plotPre(handles.distanceToPin, handles); %function to plot the view of the next throw

handles.readyFlag = 1; %setting the ready flag to start reading accel. data

if handles.setupFlag %ensures that the initial calibration is completed
    
    while handles.readyFlag %loop once the ready button is pushed & setup is complete
        plotPre(handles.distanceToPin, handles); %function to plot the view of the next throw
        
        % Get the new values from the accelerometer
        [handles.gx handles.gy handles.gz] = readAcc(handles.accelerometer,handles.calCo);
        %alpha filtering the input signal
        handles.gxFilt = (1-handles.alphaVal)*handles.gxFilt + handles.alphaVal * handles.gx;
        handles.gyFilt = (1-handles.alphaVal)*handles.gyFilt + handles.alphaVal * handles.gy;
        handles.gzFilt = (1-handles.alphaVal)*handles.gzFilt + handles.alphaVal * handles.gz;
        handles.resultantFilt = sqrt(handles.gxFilt^2 + handles.gyFilt^2 + handles.gzFilt^2);
        %alpha filtered data, used for throw calculations
        handles.gxFiltData = [handles.gxFiltData(2:end); handles.gxFilt];
        handles.gyFiltData = [handles.gyFiltData(2:end); handles.gyFilt];
        handles.gzFiltData = [handles.gzFiltData(2:end); handles.gzFilt];
        handles.reFiltData = [handles.reFiltData(2:end); handles.resultantFilt];
        
        % Calculate the magnitude of the accelerometer axis readings
        handles.resultant = sqrt(handles.gx^2 + handles.gy^2 + handles.gz^2);
        
        % Append the new reading to the end of the rolling plot data. Drop the
        % first value
        handles.gxdata = [handles.gxdata(2:end) ; handles.gx];
        handles.gydata = [handles.gydata(2:end) ; handles.gy];
        handles.gzdata = [handles.gzdata(2:end) ; handles.gz];
        handles.redata = [handles.redata(2:end) ; handles.resultant];
        %plotting/relabeling
        if handles.resultant > handles.threshold && ~handles.tFlag %set threshold flag when it is crossed
            handles.tFlag = 1;
        elseif handles.resultant < handles.threshold && handles.tFlag || strcmpi(handles.score{handles.player,1}, 'CPU')
            %collect data when reading goes back under the threshold
            
            handles.tFlag = 0; %reset threshold flag
            %collecting throw data in x, y , z, and the resultant
            handles.throwXFilterData = [handles.gxFiltData(191:end)];
            handles.throwYFilterData = [handles.gyFiltData(191:end)];
            handles.throwZFilterData = [handles.gzFiltData(191:end)];
            handles.throwResFilterData = [handles.reFiltData(191:end)];
            
            if handles.throwNumber == 1
                handles.distanceToPin = handles.hole(handles.holeIndex,1);
            end
            
            %SETTING TEXT BOXES ON THE GUI AFTER EACH THROW
            set(handles.parVal,'String', num2str(handles.hole(handles.holeIndex,2))); %PAR VALUE
            set(handles.pinDistance,'String',num2str(handles.distanceToPin)); %DISTANCE TO THE PIN
            set(handles.holeNumber,'String',num2str(handles.holeIndex)); %HOLE NUMBER
            
            %CALCULATING THE THROW USING THE COLLECTED DATA
            if strcmpi(handles.score{handles.player,1}, 'CPU') %CHECKS FOR COMPUTER OPPONENT
                [handles.v0, handles.theta, handles.alpha, handles.yTilt,...
                    handles.discN, handles.yVel] = cpuThrow(handles.distanceToPin, handles.difficulty);
            else %FOR HUMAN THROWS
                handles.discN = get(handles.discMenu, 'Value'); %receiving disc selection
                [handles.v0,handles.theta,handles.alpha,handles.yTilt,handles.discN,handles.yVel] = ...
                    findThrowData(handles.throwXFilterData, handles.throwYFilterData, handles.throwZFilterData, handles.throwResFilterData);
            end
            
            %finding disc flight using function throwDisk4
            [handles.xHist, handles.yHist, handles.zHist, handles.inHole] =...
                throwDisk4(handles.v0,handles.theta,handles.alpha,...
                handles.yTilt,handles.discN,handles.yVel,handles.distanceToPin,handles.holeSize);
            
            
            %%% Externally plotting the throw%%%
            plotThrow(handles.xHist, handles.yHist, handles.zHist, handles.inHole, handles.distanceToPin, handles);
            
            
            if handles.inHole %checks to see if the throw went in the hole
                %next player
                
                if handles.throwNumber <= handles.hole(handles.holeIndex, 2)-2 %eagle
                    sound(handles.eagleWav, handles.eagleFs);
                elseif handles.throwNumber <= handles.hole(handles.holeIndex, 2)-1 %birdy
                    sound(handles.birdWav, handles.birdFs);
                else
                    sound(handles.goalWav, handles.goalFs);
                end
                
                
                handles.score{handles.player, handles.holeIndex+1} = handles.throwNumber; %updating scorecard
                handles.score{handles.player, 11} = handles.score{handles.player, 11} + handles.throwNumber; %updating scorecard
                set(handles.scoreTable, 'data', handles.score);%updating scorecard
                handles.player = handles.player + 1;%get next players name. set to GUI screen
                if handles.player > handles.numberOfPlayers %see if end of players is reached
                    %next hole
                    handles.player = 1; %resets player number
                    handles.holeIndex = handles.holeIndex+1;
                    
                    %checking to see if end of game is reached
                    if handles.holeIndex > 9
                        checkWinner(handles.score, handles.numberOfPlayers, handles);%find winner
                        set(handles.beginGameButton, 'string', 'Begin Game');%restarts the game
                    end
                    
                end
                set(handles.textPlayerName, 'String', handles.score{handles.player, 1});
                clear handles.xHist; %clearing previous throw history
                clear handles.yHist; %clearing previous throw history
                handles.xi = 0; %resets the starting point to origin
                handles.yi = 0; %resets the starting point to origin
                
                handles.inHole = 0;%reset in hole flag
                handles.throwNumber = 1; %resets throw number
                set(handles.shotNumber,'String',num2str(handles.throwNumber)); %sets throw number to GUI screen
                
            else %FOR THROWS THAT DON'T LAND IN THE HOLE
                handles.xi = handles.xHist(end); %find x starting point for next throw
                handles.yi = handles.yHist(end);%find x starting point for next throw
                handles.distanceToPin = sqrt((handles.distanceToPin-handles.xi)^2 + (handles.yi)^2);%finds distance to pin for replotting
                set(handles.pinDistance,'String',num2str(handles.distanceToPin)); %set distance to pin to GUI screen
                handles.throwNumber = handles.throwNumber + 1; %update throw number
                hold off
                set(handles.shotNumber,'String',num2str(handles.throwNumber)); %setting throw number to GUI screen
                
            end % END IN HOLE IF STATEMENT
            
            set(handles.scoreTable, 'data', handles.score); %update scorecard
            handles.score;
            handles.readyFlag = 0; %wait for user to press ready button
            guidata(hObject, handles); %UPDATE HANDLES
        end
        
        guidata(hObject, handles); %UPDATE HANDLES
    end
end

guidata(hObject, handles); %UPDATE HANDLES



% --- Executes on button press in closeButton.
function closeButton_Callback(hObject, eventdata, handles)
% hObject    handle to closeButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

closeSerial; %Closes the serial connection


%%% No actual code below this %%%


% --- Executes during object creation, after setting all properties.
function playerName1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to playerName1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function playerName2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to playerName2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function playerName3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to playerName3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function playerName4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to playerName4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function difficultyMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to difficultyMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function discMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to discMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function readyButton_CreateFcn(hObject, eventdata, handles)
% hObject    handle to readyButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function scoreTable_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scoreTable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



function playerName1_Callback(hObject, eventdata, handles)
% hObject    handle to playerName1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of playerName1 as text
%        str2double(get(hObject,'String')) returns contents of playerName1 as a double



function playerName2_Callback(hObject, eventdata, handles)
% hObject    handle to playerName2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of playerName2 as text
%        str2double(get(hObject,'String')) returns contents of playerName2 as a double



function playerName3_Callback(hObject, eventdata, handles)
% hObject    handle to playerName3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of playerName3 as text
%        str2double(get(hObject,'String')) returns contents of playerName3 as a double



function playerName4_Callback(hObject, eventdata, handles)
% hObject    handle to playerName4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of playerName4 as text
%        str2double(get(hObject,'String')) returns contents of playerName4 as a double


% --- Executes on selection change in difficultyMenu.
function difficultyMenu_Callback(hObject, eventdata, handles)
% hObject    handle to difficultyMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns difficultyMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from difficultyMenu


% --- Executes on selection change in discMenu.
function discMenu_Callback(hObject, eventdata, handles)
% hObject    handle to discMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns discMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from discMenu
