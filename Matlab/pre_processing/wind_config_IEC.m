
% Copyright (c) 2021 Hannah Dentzien, Ove Hagge Ellhöft
% Copyright (c) 2021 Jens Geisler

function [dlc_cell, turbsim_trig] = wind_config_IEC(dlc_cell,row) 
turbsim_trig= false;

wind_slope = dlc_cell{row,find_label_or_create(dlc_cell,'Wind-Slope',true)};
windclass = dlc_cell{row,find_label_or_create(dlc_cell,'Wind-Class',true)};
turbclass = dlc_cell{row,find_label_or_create(dlc_cell,'Turb-Class',true)};
iec_standard = dlc_cell{row,find_label_or_create(dlc_cell,'Shear-Exp',true)};
time_trans = dlc_cell{row,find_label_or_create(dlc_cell,'Transient-Event-Time',true)};
ieccond = erase(dlc_cell{row,find_label_or_create(dlc_cell,'Wind-Type',true)},'IEC:'); 
duration = dlc_cell{row,find_label_or_create(dlc_cell,'Duration',true)};

% search for WindType label (Type of inputfile for inflowwind.dat-file)
[idx,dlc_cell] = find_label_or_create(dlc_cell,'WindType',false);
dlc_cell{row,idx}='2';

% search for TMax label (sim-time main input (.fst))
[idx,dlc_cell] = find_label_or_create(dlc_cell,'TMax',false);
dlc_cell{row,idx} = duration;

% search for Wind-Slope label (IECWind input)
[idx,dlc_cell] = find_label_or_create(dlc_cell,'{Wind_Slope}',false);
dlc_cell{row,idx} = wind_slope;

% search for Shear-Exponent label (IECWind input)
[idx,dlc_cell] = find_label_or_create(dlc_cell,'{IEC_standard}',false);
dlc_cell{row,idx} = iec_standard;

% search for Transient-Event-Time label (IECWind input)
[idx,dlc_cell] = find_label_or_create(dlc_cell,'{Transient_Event_Time}',false);
dlc_cell{row,idx} = time_trans;

% search for IEC-condition label (IECWind input)
[idx,dlc_cell] = find_label_or_create(dlc_cell,'{uni-wind-param}',false);
dlc_cell{row,idx} = ieccond;

% search for Wind Turbine class label (IECWind input)
[idx,dlc_cell] = find_label_or_create(dlc_cell,'{Turb_Class}',false);
dlc_cell{row,idx} = turbclass;

[idx,dlc_cell] = find_label_or_create(dlc_cell,'{Wind_Class}',false);
dlc_cell{row,idx} = windclass;

