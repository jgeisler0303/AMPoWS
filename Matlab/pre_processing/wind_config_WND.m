
% Copyright (c) 2023 Jens Geisler

function [dlc_cell, turbsim_trig] = wind_config_WND(dlc_cell,row) 
turbsim_trig= false;

duration = dlc_cell{row,find_label_or_create(dlc_cell,'Duration',true)};
wind_speed = dlc_cell{row,find_label_or_create(dlc_cell,'Wind-Speed',true)} ;
seed = dlc_cell{row,find_label_or_create(dlc_cell,'Seed',true)};
name_template= erase(dlc_cell{row,find_label_or_create(dlc_cell,'Wind-Type',true)},'WND:'); 

[idx,dlc_cell] = find_label_or_create(dlc_cell,'URef',false) ;
dlc_cell{row,idx}=wind_speed;  % write windspeed

[idx,dlc_cell] = find_label_or_create(dlc_cell,'WindType',false);
dlc_cell{row,idx}='4';

[idx,dlc_cell] = find_label_or_create(dlc_cell,'TMax',false) ;
dlc_cell{row,idx}=duration;

% search for RandSeed1 label (First Random Seed Turbsim-Inputfile)
[idx,dlc_cell] = find_label_or_create(dlc_cell,'RandSeed1',false) ;
dlc_cell{row,idx} = seed;

[idx,dlc_cell] = find_label_or_create(dlc_cell,'{wnd_file_template}',false);
dlc_cell{row,idx} = name_template;