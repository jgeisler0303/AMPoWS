function dlc_cell = basic_config_detwind(dlc_cell,row) 

wind_slope = dlc_cell{row,find_label_or_create(dlc_cell,'Wind-Slope',true)};
turbclass = dlc_cell{row,find_label_or_create(dlc_cell,'Turb-Class',true)};
shearexp = dlc_cell{row,find_label_or_create(dlc_cell,'Shear-Exp',true)};
time_trans = dlc_cell{row,find_label_or_create(dlc_cell,'Transient-Event-Time',true)};
ieccond = erase(dlc_cell{row,find_label_or_create(dlc_cell,'Wind-Type',true)},'IEC:'); 
duration = dlc_cell{row,find_label_or_create(dlc_cell,'Duration',true)};    % read duration from dlc_cell

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
[idx,dlc_cell] = find_label_or_create(dlc_cell,'{Shear_Exp}',false);
dlc_cell{row,idx} = shearexp;

% search for Transient-Event-Time label (IECWind input)
[idx,dlc_cell] = find_label_or_create(dlc_cell,'{Transient_Event_Time}',false);
dlc_cell{row,idx} = time_trans;

% search for IEC-condition label (IECWind input)
[idx,dlc_cell] = find_label_or_create(dlc_cell,'{IEC-condition}',false);
dlc_cell{row,idx} = ieccond;

% search for Wind Turbine class label (IECWind input)
[idx,dlc_cell] = find_label_or_create(dlc_cell,'{Turb_Class}',false);
dlc_cell{row,idx} = turbclass;


