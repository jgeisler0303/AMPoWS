function [] = create_script(command, files, name, outfile_ext)
%CREATE_SCRIPT Creates .bat/.sh -file (depending on OS) to run multiple FAST simulations.
%
%command: defines which module is to be called (e.g turbsim or openfast)
%files: specifies the input-files for the module
%name: name of generated the .bat/.sh file

filename= join([name,'.sh']);
write_script(filename, '#!/bin/bash', command, files)
fileattrib(filename,'+x')

write_script(join([name,'.bat']), '', command, files)

write_makefile(name, command, files, outfile_ext)

function write_script(filename, initial_line, command, files)
output = fopen(filename, 'w');   % create output file

fprintf(output, initial_line);   % print initial line to file

% print commands with filenames to output
for i=1:length(files)           
    line = join(['\n', ' ', command,files(i)]);
    fprintf(output, line);
end
fclose(output);

function write_makefile(name, command, files, outfile_ext)
path= fileparts(name);
filename= fullfile(path, 'makefile');

[~, ~, infile_ext]= fileparts(files(1));

output = fopen(filename, 'w');   % create output file

fprintf(output, 'SIM_FILES:= \\\n');
for i=1:length(files)           
    fprintf(output, '\t%s', files(i));
    if i<length(files)
        fprintf(output, ' \\\n');
    else
        fprintf(output, ' \n\n');
    end        
end

fprintf(output, 'OUT_FILES:= $(patsubst %%%s, %%%s, $(SIM_FILES))\n\n', infile_ext, outfile_ext); 

fprintf(output, 'all: $(OUT_FILES)\n\n');

fprintf(output, '%%%s : %%%s\n', outfile_ext, infile_ext);
fprintf(output, '\t%s $< > $*.log\n\n', command);

fprintf(output, '.PHONY: clean all\n');

fclose(output);
