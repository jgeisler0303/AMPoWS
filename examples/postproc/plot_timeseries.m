function [] = plot_timeseries(ppconfig)

% check if plots already exist
sensors_to_plot = [] ;
for sensor = ppconfig.sensors
    plot_name = join([sensor,ppconfig.DLCs]);
    if ~exist(fullfile(ppconfig.path,join([plot_name,".fig"])))
    sensors_to_plot =[sensors_to_plot,sensor];
    end
end

% get FAST-output data
outputs = readFASTOutputs(ppconfig);

% get indices of the sensors to plot
sensors = selectSensors(outputs,sensors_to_plot);

% plot 1 figure per sensor
for sensor = sensors
    DLC_names = [];
    sensorname = outputs(1).sensorname(sensor);
    sensorunit = outputs(1).sensorunit(sensor);
    
    figure
    title(sensorname)
    
    % plot each DLC 
    for DLC = outputs
       DLC_names = [DLC_names , DLC.name];
       time_data = DLC.timeseries(:,1);
       y_data = DLC.timeseries(:,sensor);
       
       plot(time_data,y_data)
       hold on
        
    end
    
    xlabel('time in s')
    ylabel(join([sensorname," in",sensorunit])) 
    legend(DLC_names,'Location','northeast')
    
    grid on
    hold off
    
    % save figure
    filename = fullfile(ppconfig.path,join([sensorname,DLC_names,".fig"]));
    savefig(filename)
end