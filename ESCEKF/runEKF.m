% runEKF: Runs an extended Kalman filter for saved E2 dynamic data and 
% an E2 cell model.
%
% Copyright (c) 2016 by Gregory L. Plett of 
% University of Colorado Colorado Springs (UCCS). 
%
% This work is licensed under a Creative Commons 
% Attribution-NonCommercial-ShareAlike 4.0 Intl. License, v. 1.0
%
% It is provided "as is", without express or implied warranty, for 
% educational and informational purposes only.
%
% This file is provided as a supplement to: Plett, Gregory L., "Battery
% Management Systems, Volume II, Equivalent-Circuit Methods," Artech House, 
% 2015.

% Load model file corresponding to a cell of this type
load E2model

% Load cell-test data to be used for this batch experiment
% Contains variable "DYNData" of which the field "script1" is of 
% interest. This has sub-fields time, current, voltage, soc.
% load('E2_DYN_35_P25'); T = 25;
load('E2_DYN_15_P05'); T = 5;

time    = DYNData.script1.time(:);   deltat = time(2)-time(1);
time    = time-time(1); % start time at 0
current = DYNData.script1.current(:); % discharge > 0; charge < 0.
voltage = DYNData.script1.voltage(:);
soc     = DYNData.script1.soc(:);

% Reserve storage for computed results, for plotting
sochat = zeros(size(soc));
socbound = zeros(size(soc));

% Covariance values
SigmaX0 = diag([1e-6 1e-8 2e-4]); % uncertainty of initial state
SigmaV = 2e-1; % Uncertainty of voltage sensor, output equation
SigmaW = 2e-1; % Uncertainty of current sensor, state equation

% Create ekfData structure and initialize variables using first
% voltage measurement and first temperature measurement
ekfData = initEKF(voltage(1),T,SigmaX0,SigmaV,SigmaW,model);

% Now, enter loop for remainder of time, where we update the SPKF
% once per sample interval
hwait = waitbar(0,'Computing...'); 
for k = 1:length(voltage),
  vk = voltage(k); % "measure" voltage
  ik = current(k); % "measure" current
  Tk = T;          % "measure" temperature
  
  % Update SOC (and other model states)
  [sochat(k),socbound(k),ekfData] = iterEKF(vk,ik,Tk,deltat,ekfData);
  % update waitbar periodically, but not too often (slow procedure)
  if mod(k,1000)==0,
    waitbar(k/length(current),hwait);
  end;
end
close(hwait);
  
% Plot estimate of SOC
figure(1); clf; plot(time/60,100*soc,'k',time/60,100*sochat,'m'); hold on
plot([time/60; NaN; time/60],[100*(sochat+socbound); NaN; 100*(sochat-socbound)],'m');
title('SOC estimation using EKF');
xlabel('Time (min)'); ylabel('SOC (%)');
legend('Truth','Estimate','Bounds'); ylim([0 120]); grid on

% Display RMS estimation error to command window
fprintf('RMS SOC estimation error = %g%%\n',sqrt(mean((100*(soc-sochat)).^2)));

% Plot estimation error and bounds
figure(2); clf; plot(time/60,100*(soc-sochat),'m'); hold on
h = plot([time/60; NaN; time/60],[100*socbound; NaN; -100*socbound],'m');
title('SOC estimation errors using EKF');
xlabel('Time (min)'); ylabel('SOC error (%)'); ylim([-6 6]); 
set(gca,'ytick',-6:2:6);
legend('Error','Bounds','location','northwest'); 
grid on

% Display bounds errors to command window
ind = find(abs(soc-sochat)>socbound);
fprintf('Percent of time error outside bounds = %g%%\n',...
        length(ind)/length(soc)*100);