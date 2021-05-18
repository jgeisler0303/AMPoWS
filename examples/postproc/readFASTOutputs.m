function [outputs] = readFASTOutputs(ppconfig)

% check if vector of output structure exists and contains every DLC

if evalin('base',"exist('outputs','var')") ~= 0
    outputs = evalin('base',"outputs");
    DLCs_to_read =[];
    
    
    for DLC = ppconfig.DLCs 
        
       if find(strcmp(outputs,DLC)) == 0
          DLCs_to_read =[DLCs_to_read, DLC];
       end
       
    end
else 
    outputs = [];    
    DLCs_to_read = ppconfig.DLCs;
end

% read FAST Output binaries
for DLC = DLCs_to_read
    
    DLCout = struct();
    
    DLC_name=fullfile(ppconfig.path,append(DLC,"__maininput.outb"));
    [Channels, ChanName, ChanUnit] =ReadFASTbinary(convertStringsToChars(DLC_name));
    
    DLCout.name = DLC ;
    DLCout.timeseries = Channels;
    DLCout.sensorname = ChanName;
    DLCout.sensorunit = ChanUnit;
    
    outputs=[outputs DLCout];
    
end

assignin('base','outputs',outputs); % save outputs to base workspace
