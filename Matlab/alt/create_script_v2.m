function [] = create_script_v2(command,files,name)

%create .bat/.sh -file to run multiple FAST simulations

filename = join([name,'.sh']) ;
 
output = fopen(filename,'w');   % create output file

fprintf(output,'#!/bin/bash');

for i=1:length(files)
    line = join(['\n',' ',command,files(i)]);
    fprintf(output,line);
end
fclose(output);