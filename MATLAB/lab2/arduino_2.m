% This must be calculated according to lab information
V_7805 = 5.48;
Vref_arduino = 5;

%% Code to clear arduino variable if necessary
% clear
% delete(instrfind({'Port'}, {'COM7'}));
% a = arduino;
% a = arduino('COM3');

%%
% OUTPUT ZERO CONTROL SIGNAL TO STOP MOTOR  %
analogWrite(a, 6, 0);
analogWrite(a, 9, 0);

% Information not needed
% writePWMVoltage(a, 'D6', 0)
% writePWMVoltage(a, 'D9', 0)

% Initialize matrix to fill with information
positionData = [];
velocityData = [];
eData = [];
timeData = [];
controllerData = [];
rData = [];


% Set initial time to zero
t=0;

% CLOSE ALL PREVIOUS FIGURES FROM SCREEN
close all

% WAIT A KEY TO PROCEED
disp(['Connect cable from Arduino to Input Power Amplifier and then press enter to start controller']);
pause()




rot = 0.31;
%
% r =@(t) 5;
r =@(t) 5 + 2*sin(rot*t);

%K = [2360/99, 937/110, -2360/99];            %idiotimi -8
K = [14455/792, 3217/440, -14455/792];      %idiotimi -7
%K = [295/22, 1343/220, -295/22];            %idiotimi -6
%K = [7375/792, 431/88, -7375/792];          %idiotimi -5
%K = [590/99, 203/55, -590/99];              %idiotimi -4
%K = [295/88, 1093/440, -295/88];            %idiotimi -3

% START CLOCK
tic
 
while(t<5)  
    
	velocity = analogRead(a, 3);
	position = analogRead(a, 5);

	theta = 3 * Vref_arduino * position / 1023;

	vtacho = 2 * (2 * velocity * Vref_arduino / 1023 - V_7805);

	% Information not needed
	% position = readVoltage(a, 'A5');
	% velocity = readVoltage(a, 'A3'); 
	% theta = 3 * Vref_arduino * position / 5;
	% vtacho = 2 * (2 * velocity * Vref_arduino / 5 - V_7805);
	
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    x = [theta;
         vtacho;
         r(t)];
    u = -K * x;


	if u > 0
		analogWrite(a, 6, 0);
        analogWrite(a, 9, min(round(u / 2 * 255 / Vref_arduino), 255)); may lord help us all
		%analogWrite(a, 9, min(round(e / 2 * 255 / Vref_arduino), 255));
		
	%	writePWMVoltage(a, 'D6', 0)
	%	writePWMVoltage(a, 'D9', abs(e) / 2)
	else
		analogWrite(a, 9, 0);
        analogWrite(a, 6, min(round(-u / 2 * 255 / Vref_arduino), 255));%may lord help us all
        %analogWrite(a, 6, min(round(-e / 2 * 255 / Vref_arduino), 255));
	
	%    writePWMVoltage(a, 'D9', 0)
	%	writePWMVoltage(a, 'D6', abs(e) / 2)
	end

	% Set time to current time
	t = toc;

	% Update matrices with information    
	timeData = [timeData t];
	positionData = [positionData theta];
	velocityData = [velocityData vtacho];
    controllerData = [controllerData u];
    rData = [rData r(t)];

end

% OUTPUT ZERO CONTROL SIGNAL TO STOP MOTOR  %
analogWrite(a, 6, 0);
analogWrite(a, 9, 0);

% Information not needed
% writePWMVoltage(a, 'D6', 0)
% writePWMVoltage(a, 'D9', 0)

disp(['End of control Loop. Press enter to see diagramms']);
pause();

%%


figure(1)
plot(timeData, positionData, timeData, rData);
title('position')

figure(2)
plot(timeData, velocityData);
title('velocity')

figure(3)
plot(timeData, controllerData);
title('controller')


