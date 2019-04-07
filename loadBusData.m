function [rawBusData] = loadBusData()
%loadBusData Summary
% loads data from txt file
% |Type | From | To | R1=R2 | X1=X2 | B1=B2 | R0 | X0 |  B0 |

addToFirst = 1;

fid = fopen('busData.txt','rt');
while true
  thisline = fgetl(fid);
  thisline = str2num(thisline);
  if thisline(1) < 0
      break,end
      %disp(thisline)
  
      
  if addToFirst ~= 1
    rawBusData = cat(1,rawBusData,thisline);
  end
      
  if addToFirst == 1
      rawBusData = thisline; %if this is the first line being read make it the first line of the return matrix
      addToFirst = 0; %now future lines will be appended to the end of this matrix
  end
  

end
  fclose(fid);


end

