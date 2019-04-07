%SLG function
function [PostFaultI, PostFaultV] = ThreePG(Z12,Z0,faultBus,Zl)
nb = max(size(Z0));%number of busses

a = 1*exp(i*2*pi/3);
A = [1 1 1
    1 a*a a
    1 a a*a];

%assume prefault voltages are 1<0
%for 3PG, we know only need pos sequence
% Ifpos = -Ifneg = 1/( Zpos + Zneg + Zf)
%pos seq fault current for the specified fault bus
If1 = 1 / (Z12(faultBus,faultBus));




%now get fault current vectors for each sequence current
If_pos = zeros(1,nb)';
If_pos(faultBus) = If1;%all zero except fault current at fault bus

%       prefault                + Zbus+
V_pos = ones(1, nb)' - Z12*If_pos;



%now populate a nbus X 3 matrix of voltages at each bus for phases a b c

PostFaultV = cat(2,V_pos, a*a*V_pos, a*V_pos);

PostFaultI = cat(2,If1, a*a*If1, a*If1);


fileID = fopen('OUTPUT.txt','w');
formatSpec = '%2.0f   |%5.3f    %5.3f  |%5.3f   %5.3f  | %5.3f  %5.3f  |\n';
fprintf(fileID,'#########################################################################################\n')
fprintf(fileID,'-----------------------------------------------------------------------------------------\n');
fprintf(fileID,'                              3PG Fault Analysis \n');
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

fprintf(fileID,formatSpec,faultBus,...
        real(PostFaultI(1)),imag(PostFaultI(1)),...
        real(PostFaultI(2)),imag(PostFaultI(2)),...
        real(PostFaultI(3)),imag(PostFaultI(3)));



fclose(fileID);


end