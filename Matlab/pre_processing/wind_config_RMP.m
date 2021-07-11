
% Copyright (c) 2021 Jens Geisler

function [dlc_cell, turbsim_trig] = wind_config_RMP(dlc_cell,row) 

turbsim_trig= false;

wind_speed = dlc_cell{row,find_label_or_create(dlc_cell,'Wind-Speed',true)} ;
wind_slope = dlc_cell{row,find_label_or_create(dlc_cell,'Wind-Slope',true)};
shearexp = dlc_cell{row,find_label_or_create(dlc_cell,'Shear-Exp',true)};
time_trans = dlc_cell{row,find_label_or_create(dlc_cell,'Transient-Event-Time',true)};
duration = dlc_cell{row,find_label_or_create(dlc_cell,'Duration',true)};
ramp = erase(dlc_cell{row,find_label_or_create(dlc_cell,'Wind-Type',true)},'RMP:'); 

[idx,dlc_cell] = find_label_or_create(dlc_cell,'URef',false) ;
dlc_cell{row,idx}=wind_speed;

[idx,dlc_cell] = find_label_or_create(dlc_cell,'{Wind_Slope}',false);
dlc_cell{row,idx} = wind_slope;

[idx,dlc_cell] = find_label_or_create(dlc_cell,'WindType',false);
dlc_cell{row,idx}='2';

[idx,dlc_cell] = find_label_or_create(dlc_cell,'TMax',false);
dlc_cell{row,idx} = duration;

[idx,dlc_cell] = find_label_or_create(dlc_cell,'{Shear_Exp}',false);
dlc_cell{row,idx} = shearexp;

[idx,dlc_cell] = find_label_or_create(dlc_cell,'{Transient_Event_Time}',false);
dlc_cell{row,idx} = time_trans;

[idx,dlc_cell] = find_label_or_create(dlc_cell,'{uni-wind-param}',false);
dlc_cell{row,idx} = ramp;
