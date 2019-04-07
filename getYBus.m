% Calculate YBUS given info in linedatas.m
% to call this function, use Y = ybusPF(num)
%where num is the corresponding num in linedatas.m

function [Y12, Y0] = getYBus(rawData)  % Returns Y

type = rawData(:,1);             % xfmr Type...
fb = rawData(:,2);             % From bus number...
tb = rawData(:,3);             % To bus number...
r12 = rawData(:,4);              % Resistance pos and neg
x12 = rawData(:,5);              % Reactance, pos and neg
b12 = rawData(:,6);              % Ground Admittance, pos and neg
r0 = rawData(:,7);              % Resistance zero
x0 = rawData(:,8);              % Reactance zero
b0 = rawData(:,9);              % Ground Admittance, zero

%pos and neg seq...
z12 = r12 + i*x12;                    % impedance between lines...
y12 = 1./z12;                       % To get inverse of each z...
b12 = i*b12/2;                        % Make B imaginary and make it B/2...

%zero seq...
z0 = r0 + i*x0;                    % impedance between lines...
y0 = 1./z0;                       % To get inverse of each z...
b0 = i*b0/2;                        % Make B imaginary and make it B/2...


nb = max(max(fb),max(tb));      % No. of buses...
nl = length(fb);                % No. of branches...
Y12 = zeros(nb,nb);               % Initialise YBus...
Y0 = zeros(nb,nb);               % Initialise YBus...
 
 % Calculate off diag elements for Ybus pos and neg
 for k = 1:nl
     % E.g. Y(1,2)  = Y(1,2)     - (  1/(r12 + jx12)) / tap
     %pos and neg
     Y12(fb(k),tb(k)) = Y12(fb(k),tb(k)) - y12(k);
     Y12(tb(k),fb(k)) = Y12(fb(k),tb(k));%calculates across diagonal term
     
     %zero sequence
     %check for xfmr connection types because it affects ybus
     switch type(k)
         case {0 2}%impedance connects busses
             Y0(fb(k),tb(k)) = Y0(fb(k),tb(k)) - y0(k);
             Y0(tb(k),fb(k)) = Y0(fb(k),tb(k));%calculates across diagonal term
         case {1 4 5}%floating impedance, so does not contribute to anything
             Y0(fb(k),tb(k)) = Y0(fb(k),tb(k));
             Y0(tb(k),fb(k)) = Y0(fb(k),tb(k));
         case 3%impedance from grounded wye to ground for one of the busses 
             Y0(fb(k),tb(k)) = Y0(fb(k),tb(k));
             Y0(tb(k),fb(k)) = Y0(fb(k),tb(k));
             %dont add anything to mutual admittances because the diag will
             %only change
     end
     
     
 end
 
 % Formation of Diagonal Elements
 for m = 1:nb%for each bus:
     for n = 1:nl% for each branch
         %find each bus in either from bus or to bus column
         if (fb(n) == m) && ( type(n)==0 )
             Y12(m,m) = Y12(m,m) + y12(n) + b12(n);
             Y0(m,m) = Y0(m,m) + y0(n) + b0(n);
         elseif (fb(n) == m) && ( type(n)~=0 )
             Y12(m,m) = Y12(m,m) + y12(n) + b12(n);
             switch type(n)
                 case {1 4 5}%dont do anything because impedances not connected to ground
                     Y0(m,m) = Y0(m,m);
                 case {2 3}% treat case 3 as if the From Bus is the grounded WYE end, so it has an impedance to ground
                     Y0(m,m) = Y0(m,m) + y0(n) + b0(n);
             end
                         
         elseif (tb(n) == m) && ( type(n)==0 )
             Y12(m,m) = Y12(m,m) + y12(n) + b12(n);
             Y0(m,m) = Y0(m,m) + y0(n) + b0(n);
         elseif (tb(n) == m) && ( type(n)~=0 )
             Y12(m,m) = Y12(m,m) + y12(n) + b12(n);
             switch type(n)
                 case {1 3 4 5}%dont do anything because impedances not connected to ground
                     Y0(m,m) = Y0(m,m);
                 case {2}% treat case 3 as if the To Bus is the Delta end, so it has inf impedance to ground
                     Y0(m,m) = Y0(m,m) + y0(n) + b0(n);
             end
         end
     end
 end
 
 
 
 
 
 
 
 
 
 
 %Get generator data
 % loads data from txt file
% |Type | From | To | R1=R2 | X1=X2 | B1=B2 | R0 | X0 |  B0 |

addToFirst = 1;

fid = fopen('genData.txt','rt');
while true
  thisline = fgetl(fid);
  thisline = str2num(thisline);
  if thisline(1) < 0
      break,end
      %disp(thisline)
  
      
  if addToFirst ~= 1
    rawGenData = cat(1,rawGenData,thisline);
  end
      
  if addToFirst == 1
      rawGenData = thisline; %if this is the first line being read make it the first line of the return matrix
      addToFirst = 0; %now future lines will be appended to the end of this matrix
  end
end
  fclose(fid);
 
  fb = rawGenData(:,1);
  x0 = rawGenData(:,2);
  x1 = rawGenData(:,3);
  
 
  %add generator reacances to diagonal elements
  nl = length(fb);                % No. of generators
  
 for gen = 1:nl%for each bus:
     m = fb(gen);
     Y12(m,m) = Y12(m,m) + (1/(i*x1(gen)));
     Y0(m,m) = Y0(m,m) + (1/(i*x0(gen)));
 end
  
  
  
  
  
  
  
  
  
  
  
  
 
  
  
 
 
 
 %Z = inv(Y);      % Bus Impedance Matrix