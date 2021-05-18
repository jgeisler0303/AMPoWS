function [] = create_script(command,files,name)
%CREATE_SCRIPT Creates .bat/.sh -file (depending on OS) to run multiple FAST simulations.
%
%command: defines which module is to be called (e.g turbsim or openfast)
%files: specifies the input-files for the module
%name: name of generated the .bat/.sh file

if isunix % Linux-System -> shell-script
   filename = join([name,'.sh']) ;
   initial_line = '#!/bin/bash';
   
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

% if is Linux-System -> make the file executable
if isunix   
    fileattrib(filename,'+x')
end    