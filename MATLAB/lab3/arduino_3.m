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
zData = [];
rData = [];


% Set initial time to zero
t=0;

% CLOSE ALL PREVIOUS FIGURES FROM SCREEN
close all

% WAIT A KEY TO PROCEED
disp(['Connect cable from Arduino to Input Power Amplifier and then press enter to start controller']);
pause();

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 K = [35105/792, 9089/880 - 4, 72275/792];%idiotimi -7 -7 -4
 %K = [7375/264, 1393/176 - 3, 36875/792];%idiotimi -5
 %K = [590/33, 1343/220, 2360/99];    %idiotimi -4
 %K = [885/88, 3779/880, 885/88];     %idiotimi -3
 %K = [295/66, 1093/440, 295/99];      %idiotimi -2
 
 r =@(t) 5;
 z = 0; % z0
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
    
	dz = theta - r(t);
                                %dz/dt = theta - r(t)
                                %(zd new - zd old) /(t - tprevious) = dz
    
    z = z + dz * (toc - t);
    x = [theta; vtacho; z];
    u =-K * x;

	if u > 0
		analogWrite(a, 6, 0);
        analogWrite(a, 9, min(round(u / 2 * 255 / Vref_arduino), 255)); %may lord help us all
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
    zData = [zData z];
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

figure(4)
plot(timeData, zData);
title('z')

