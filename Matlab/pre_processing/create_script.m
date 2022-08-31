%CREATE_SCRIPT Creates .bat/.sh -file (depending on OS) to run multiple FAST simulations.
%
%   command: defines which module is to be called (e.g turbsim or openfast)
%   files: specifies the input-files for the module
%   name: name of generated the .bat/.sh file
%
% Copyright (c) 2021 Hannah Dentzien, Ove Hagge Ellhöft
% Copyright (c) 2022 Jens Geisler

function [] = create_script(command, files, name)

filename= join([name,'.sh']);
write_script(filename, '#!/bin/bash', command, files)
if ~ispc
    fileattrib(filename,'+x')
end

write_script(join([name,'.bat']), '', command, files)


function write_script(filename, initial_line, command, files)
output = fopen(filename, 'w');   % create output file

fprintf(output, [initial_line '\n']);   % print initial line to file

% print commands with filenames to output
for i=1:length(files)           
    line = join([command, ' ', files(i), '\n'], '');
    fprintf(output, line);
end
fclose(output);

