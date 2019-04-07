%SLG function
function [PostFaultI, PostFaultV] = LL(Z12,Z0,faultBus,Zl)
nb = max(size(Z0));%number of busses

a = 1*exp(i*2*pi/3);
A = [1 1 1
    1 a*a a
    1 a a*a];

%assume prefault voltages are 1<0
%for LL, we know If0 = 0
% Ifpos = -Ifneg = 1/( Zpos + Zneg + Zf)
%pos seq fault current for the specified fault bus
If1 = 1 / (Z12(faultBus,faultBus) + Z12(faultBus,faultBus) + ...
     i*Zl);

If2 = -1*If1;
If0 = 0;



%now get fault current vectors for each sequence current
If_pos = zeros(1,nb)';
If_pos(faultBus) = If1;%all zero except fault current at fault bus
%
If_neg = zeros(1,nb)';
If_neg(faultBus) = If2;%all zero except fault current at fault bus
%
If_0 = zeros(1,nb)';
If_0(faultBus) = If0;%all zero except fault current at fault bus



%get the positive sequence voltage vector for all busses. Assume pre faults
%are all one
%       prefault                + Zbus+
V_pos = ones(1, nb)' - Z12*If_pos;

V_neg = -1*Z12*If_neg;

V_0 = -1*Z0*If_0;%all three of these are dimensions nBusses by 1



%now populate a nbus X 3 matrix of voltages at each bus for phases a b c
PostFaultV = zeros(nb,3);
for bus=1:nb
    PostFaultV(bus,:) = A*[ V_0(bus); V_pos(bus); V_neg(bus);];
    %disp(PostFaultV)
end
%now get phase currents post fault
PostFaultI = A*[If0;If1;If2;];


fileID = fopen('OUTPUT.txt','w');
formatSpec = '%2.0f   |%5.3f    %5.3f  |%5.3f   %5.3f  | %5.3f  %5.3f  |\n';
fprintf(fileID,'#########################################################################################\n')
fprintf(fileID,'-----------------------------------------------------------------------------------------\n');
fprintf(fileID,'                              LL Fault Analysis \n');
fprintf(fileID,'-----------------------------------------------------------------------------------------\n');
fprintf(fileID,' BUS |        Va       |       Vb       |       Vc       |\n');
fprintf(fileID,'     |REAL      IMAG   |REAL     IMAG   |REAL     IMAG   |\n');
for bus=1:nb
    fprintf(fileID,formatSpec,bus,...
        real(PostFaultV(bus,1)),imag(PostFaultV(bus,1)),...
        real(PostFaultV(bus,2)),imag(PostFaultV(bus,2)),...
        real(PostFaultV(bus,3)),imag(PostFaultV(bus,3)));
end

fprintf(fileID,'-----------------------------------------------------------------------------------------\n');
fprintf(fileID,' BUS |        Iaf      |       Ibf      |       Icf      |\n');
fprintf(fileID,'     |REAL      IMAG   |REAL     IMAG   |REAL      IMAG  |\n');

fprintf(fileID,formatSpec,bus,...
        real(PostFaultI(1)),imag(PostFaultI(1)),...
        real(PostFaultI(2)),imag(PostFaultI(2)),...
        real(PostFaultI(3)),imag(PostFaultI(3)));



fclose(fileID);


end