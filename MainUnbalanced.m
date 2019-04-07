% Joe Mulhern
% Unbalanced Fault Analysis
clear,clc

[Y12, Y0] = getYBus(loadBusData);          % Calling ybusPF.m to get Y-Bus Matrix which loads info from loadBusData.m

[faultBus, faultType, Zl] = getFault

Z12 = inv(Y12);
Z0 = inv(Y0);



switch faultType
    case 1
        [PostFaultI, PostFaultV] = ThreePG(Z12,Z0,faultBus,Zl)
    case 2
        [PostFaultI, PostFaultV] = SLG(Z12,Z0,faultBus,Zl)
    case 3
        [PostFaultI, PostFaultV] = LLG(Z12,Z0,faultBus,Zl)
    case 4
        [PostFaultI, PostFaultV] = LL(Z12,Z0,faultBus,Zl)
end










