
% Copyright (c) 2022 Jens Geisler

function [dlc_cell, turbsim_trig] = wind_config_BTS(dlc_cell,row) 
turbsim_trig= false;

wind_speed = dlc_cell{row,find_label_or_create(dlc_cell,'Wind-Speed',true)} ;
name_template= erase(dlc_cell{row,find_label_or_create(dlc_cell,'Wind-Type',true)},'BTS:'); 

% search for URef label (windspeed in TurbSim-Inputfile)
[idx,dlc_cell] = find_label_or_create(dlc_cell,'URef',false) ;
dlc_cell{row,idx}=wind_speed;  % write windspeed

% search for WindType label (Type of inputfile for inflowwind.dat-file)
[idx,dlc_cell] = find_label_or_create(dlc_cell,'WindType',false);
dlc_cell{row,idx}='3';

% search for TMax label (sim-time main input (.fst))
[idx,dlc_cell] = find_label_or_create(dlc_cell,'TMax',false);
dlc_cell{row,idx} = '"auto"';

% search for IEC-condition label (IECWind input)
[idx,dlc_cell] = find_label_or_create(dlc_cell,'{bts_file_template}',false);
dlc_cell{row,idx} = name_template;