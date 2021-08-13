% function ekfData = initEKF(v0,T0,SigmaX0,SigmaV,SigmaW,model)
%
%    Initializes an "ekfData" structure, used by the extended Kalman
%    filter to store its own state and associated data.
%
% Inputs:
%   v0: Initial cell voltage
%   T0: Initial cell temperature
%   SigmaX0: Initial state uncertainty covariance matrix
%   SigmaV: Covariance of measurement noise
%   SigmaW: Covariance of process noise
%   model: ESC model of cell 
%
% Output:
%   ekfData: Data structure used by EKF code
 
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
function ekfData = initEKF(v0,T0,SigmaX0,SigmaV,SigmaW,model)
  % Initial state description
  ir0   = 0;                           ekfData.irInd = 1;
  hk0   = 0;                           ekfData.hkInd = 2;
  SOC0  = SOCfromOCVtemp(v0,T0,model); ekfData.zkInd = 3;
  ekfData.xhat  = [ir0 hk0 SOC0]'; % initial state

  % Covariance values
  ekfData.SigmaX = SigmaX0;
  ekfData.SigmaV = SigmaV;
  ekfData.SigmaW = SigmaW;
  ekfData.Qbump = 5;
  
  % previous value of current
  ekfData.priorI = 0;
  ekfData.signIk = 0;
  
  % store model data structure too
  ekfData.model = model;
