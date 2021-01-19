function [dlc_cell] = basic_configuration_v2(dlc_cell)

% loop over each row of dlc_cell
for row= 2:size(dlc_cell,1)

wind_type = dlc_cell{row,2} ;  % read Wind_Type from dlc_cell
wind_speed = dlc_cell{row,3} ; % read wind speed from dlc_cell
duration = dlc_cell{row,4};    % read duration from dlc_cell

    %% if NTM configuration-----------------------------
    if strcmp(wind_type ,'NTM')
        
       % search for URef label (windspeed TurbSim-file)
      [dlc_cell , idx] = find_label_or_create(dlc_cell,'URef') ;
      dlc_cell{row,idx}=wind_speed;  % write windspeed
      
       % search for WindType label (Type of inputfile for inflowwind)
      [dlc_cell , idx] = find_label_or_create(dlc_cell,'WindType') ;
      dlc_cell{row,idx}='3' ; 
      
      % search for IEC_WindType label (TurbModel Turbsim)
      [dlc_cell , idx] = find_label_or_create(dlc_cell,'IEC_WindType') ;
      dlc_cell{row,idx}=wind_type ; 
      
       % search for UsableTime (sim-time TurbSim-file)
      [dlc_cell , idx] = find_label_or_create(dlc_cell,'UsableTime') ;
      dlc_cell{row,idx}=duration; 
      
      % search for AnalysisTime (sim-time TurbSim-file)
      [dlc_cell , idx] = find_label_or_create(dlc_cell,'AnalysisTime') ;
      dlc_cell{row,idx}=duration; 
       
      % search for TMax label (sim-time main input)
      [dlc_cell , idx] = find_label_or_create(dlc_cell,'TMax') ;
      dlc_cell{row,idx}=duration;
       
      % search for RandSeed1 label (First Random Seed Turbsim-file)
      [dlc_cell , idx] = find_label_or_create(dlc_cell,'RandSeed1') ;
      r = sprintf('%.0f',(-2147483648 + (2147483647+2147483647)*rand)); % generate Random number
      dlc_cell{row,idx} = r ;
      
       %% if 'ETM' configuration
    % elseif strcmp(wind_type ,'ETM')
       % .....
    end

end

