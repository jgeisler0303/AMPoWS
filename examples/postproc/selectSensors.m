function [idx] = selectSensors(outputdata,sensors)

idx = [];

for sensor = sensors
    sensor_str = convertStringsToChars(sensor) ;
    sensors_cell = outputdata.sensorname;
    b = strcmp(sensors_cell,sensor_str);
    i = find(b);
   
    
    idx = [idx i];
    
end