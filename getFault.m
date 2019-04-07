function [faultBus, faultType, Zl] = getFault
%   Detailed explanation goes here


fid = fopen('faultData.txt','rt');
  thisline = fgetl(fid);
  thisline = str2num(thisline);
  
fclose(fid);
faultBus = thisline(1);
faultType = thisline(2);
Zl = thisline(3);

end

