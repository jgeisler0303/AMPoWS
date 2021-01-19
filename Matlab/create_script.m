function [] = create_script(command,files,name)

%create .bat/.sh -file to run multiple FAST simulations

if isunix % Linux-System -> shell-script
   filename = join([name,'.sh']) ;
   initial_line = '#!/bin/bash';
%    set_exec = join(['chmod+x ',name]);
   
elseif ispc %Windows-System -> batch-file
   filename = join([name,'.bat']) ; 
   initial_line='';
end   

output = fopen(filename,'w');   % create output file

fprintf(output,initial_line);   % print initial line to file

% print commands with filenames to output
for i=1:length(files)           
    line = join(['\n',' ',command,files(i)]);
    fprintf(output,line);
end
fclose(output);