function dlc_cell = basic_config_detwind(dlc_cell,row) 

% search for WindType label (Type of inputfile for inflowwind.dat-file)
[idx,dlc_cell] = find_label_or_create(dlc_cell,'WindType',false) ;
dlc_cell{row,idx}='2' ; 



