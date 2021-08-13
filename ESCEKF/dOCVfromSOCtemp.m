% function docv = dOCVfromSOCtemp(soc,temp,model)
%
% Computes an approximation to the derivative of the open-circuit voltage
% relationship of a cell with respect to state of charge. This is NOT an
% exact derivative -- Euler's method was used in making the derivative --
% but it is "fairly close."
%
% Inputs:  soc = scalar or matrix of cell state of charge points
%         temp = scalar or matrix of temperatures at which to calc. dOCV
%        model = data structure produced by processDynamic
% Output: docv = scalar or matrix of derivatives of open circuit voltage -- 
%                one for every soc and temperature input point

% Copyright (c) 2016 by Gregory L. Plett of the University of Colorado 
% Colorado Springs (UCCS). This work is licensed under a Creative Commons 
% Attribution-NonCommercial-ShareAlike 4.0 Intl. License, v. 1.0.
% It is provided "as is", without express or implied warranty, for 
% educational and informational purposes only.
%
% This file is provided as a supplement to: Plett, Gregory L., "Battery
% Management Systems, Volume II, Equivalent-Circuit Methods," Artech House, 
% 2015.

function docv=dOCVfromSOCtemp(soc,temp,model)
  soccol = soc(:); % force soc to be col-vector
  SOC = model.SOC(:); % force to be col vector... 
  dOCV0 = model.dOCV0(:); % force to be col vector... 
  dOCVrel = model.dOCVrel(:); % force to be col vector...
  if isscalar(temp), 
    tempcol = temp*ones(size(soccol)); % replicate for all socs
  else
    tempcol = temp(:); % force to be col vector
    if ~isequal(size(tempcol),size(soccol)),
      error(['Function inputs "soc" and "temp" must either have same '...
        'number of elements, or "temp" must be a scalar']);
    end  
  end
  diffSOC=SOC(2)-SOC(1); % spacing between OCV points - assume uniform
  docv=zeros(size(soccol)); % initialize output to zero
  I1=find(soccol <= SOC(1)); % indices of socs below model-stored data
  I2=find(soccol >= SOC(end)); % and of socs above model-stored data
  I3=find(soccol > SOC(1) & soccol < SOC(end)); % the rest of them
  I6=isnan(soccol); % if input is "not a number" for any locations

  % for voltages less than lowest stored soc datapoint, extrapolate off 
  % low end of table 
  if ~isempty(I1),
    dv = (dOCV0(2)+tempcol.*dOCVrel(2)) - (dOCV0(1)+tempcol.*dOCVrel(1));
    docv(I1)= (soccol(I1)-SOC(1)).*dv(I1)/diffSOC + ...
               dOCV0(1)+tempcol(I1).*dOCVrel(1);
  end

  % for voltages greater than highest stored soc datapoint, extrapolate off
  % high end of table
  if ~isempty(I2),
    dv = (dOCV0(end)+tempcol.*dOCVrel(end)) - (dOCV0(end-1) + ...
          tempcol.*dOCVrel(end-1));
    docv(I2) = (soccol(I2)-SOC(end)).*dv(I2)/diffSOC + dOCV0(end) + ...
          tempcol(I2).*dOCVrel(end);
  end

  % for normal soc range, manually interpolate (10x faster than "interp1")
  I4=(soccol(I3)-SOC(1))/diffSOC; % using linear interpolation
  I5=floor(I4); I45 = I4-I5; omI45 = 1-I45;
  docv(I3)=dOCV0(I5+1).*omI45 + dOCV0(I5+2).*I45;
  docv(I3)=docv(I3) + tempcol(I3).*(dOCVrel(I5+1).*omI45 + dOCVrel(I5+2).*I45);
  docv(I6)=0; % replace NaN SOCs with zero voltage
  docv = reshape(docv,size(soc)); % output is same shape as input