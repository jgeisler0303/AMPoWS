postproc = ["plot_timeseries"];
sensors= ["GenPwr" "GenTq" "RotTorq" "GenSpeed"];
DLCs = ["1p4" "1p5"];
path = '' ;


ppconfig.pp = postproc;
ppconfig.sensors = sensors;
ppconfig.DLCs = DLCs;
ppconfig.path = path;

plot_timeseries(ppconfig);