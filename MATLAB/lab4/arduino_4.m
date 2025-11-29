% This must be calculated according to lab information
V_7805 = 5.48;
Vref_arduino = 5;

%% Code to clear arduino variable if necessary
% clear
% delete(instrfind({'Port'}, {'COM5'}));
% a = arduino;
% a = arduino('COM5');

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
x1hatData = [];
x2hatData = [];

dx1hatData = [];
dx2hatData = [];

% Set initial time to zero
t=0;

% CLOSE ALL PREVIOUS FIGURES FROM SCREEN
close all

% WAIT A KEY TO PROCEED
disp(['Connect cable from Arduino to Input Power Amplifier and then press enter to start controller']);
pause();

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%poloi elenkti
s1 = -4;
s2 = -4;
%
K = [(295*s1*s2)/792, - (531*s1)/880 - (531*s2)/880 - 281961/880000];
C = [1, 0];
%% 
%poloi paratiriti
P1 = -20;
P2 = -25;
%
p1 = -P1 - P2;
p2 = P1 * P2;
L = [p1 - 1000/531;
    (50*p2)/81 - (50000*p1)/43011 + 50000000/22838841];
%L = [1;1];

A = [0,1.62;
     0,-1.8832];
B = [0;
     1.6573];

kr = K(1,1);
%thetapr = 0;

position = analogRead(a, 5);
theta = 3 * Vref_arduino * position / 1023;


xhat = [0; 0];
r =@(t) 5;
%%
% START CLOCK
tic



while(t<5)  
    
	velocity = analogRead(a, 3);
	position = analogRead(a, 5);
    
	theta = 3 * Vref_arduino * position / 1023;

	vtacho = 2 * (2 * velocity * Vref_arduino / 1023 - V_7805);
    %enalaktika kratame to theta afou to xeroume
    %dx1hat = (81*x2hat)/50;
    %thetapr = theta
    %theta = thetapr + dx1hat*(toc - t)
    %theta = thetapr + ((81*x2hat)/50)(toc - t)
    %x2hat = 50 * (theta - thetapr)/(81 * (toc - t)
    %thetapr = theta;
    %x1hat = theta;
    x = [theta;
         vtacho];
    
    u = kr *r(t) - K * xhat;
    %u = 7;
    
    
	if u > 0
		analogWrite(a, 6, 0);
        analogWrite(a, 9, min(round(u / 2 * 255 / Vref_arduino), 255)); %lord did not help anyone
		%analogWrite(a, 9, min(round(e / 2 * 255 / Vref_arduino), 255));
		
	%	writePWMVoltage(a, 'D6', 0)
	%	writePWMVoltage(a, 'D9', abs(e) / 2)
	else
		analogWrite(a, 9, 0);
        analogWrite(a, 6, min(round(-u / 2 * 255 / Vref_arduino), 255));%lord did not help anyone
        %analogWrite(a, 6, min(round(-e / 2 * 255 / Vref_arduino), 255));
	
	%    writePWMVoltage(a, 'D9', 0)
	%	writePWMVoltage(a, 'D6', abs(e) / 2)
	end




    dxhat = A * xhat + B * u + L * (theta - C * xhat);
    xhat = xhat + dxhat * (toc - t);
	% Set time to current time
	t = toc;

    
    

	% Update matrices with information    
	timeData = [timeData t];
	positionData = [positionData theta];
	velocityData = [velocityData vtacho];
    controllerData = [controllerData u];
    x1hatData = [x1hatData xhat(1,1)];
    x2hatData = [x2hatData xhat(2,1)];

    dx1hatData = [dx1hatData dxhat(1,1)];
    dx2hatData = [dx2hatData dxhat(2,1)];
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
plot(timeData, positionData, timeData, x1hatData);
title('pos vs posest')

figure(4)
plot(timeData, velocityData, timeData, x2hatData);
title('velocity vs velocityest')

figure(5)
plot(timeData, controllerData);
title('controller')

% figure(6)
% plot(timeData, dx2hatData);
% title('dx2')
% 
% figure(7)
% plot(timeData, dx1hatData);
% title('dx1')


