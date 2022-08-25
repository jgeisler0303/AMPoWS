%WIND_GEN_IEC Generates .bts-file by running IEC-wind.
%   Fills template-input-file (template_file) with the parameters set in the
%   corresponding template-structure (template).
%   Runs the IECWind module with the filled input file and moves the generated
%   .bts-file with name and target-directory given in outfile.
%
% Copyright (c) 2021 Hannah Dentzien, Ove Hagge Ellhöft
% Copyright (c) 2021 Jens Geisler

function wind_gen_IEC(template,template_file,outfile)

input = fopen(template_file,'r');   % open template file
output = fopen('IEC.IPT','w');      % open/create output file (IECwind Input)

while ~feof(input)                        % loop over the following until the end of the file is reached.
    line = fgets(input);                % read in one line
    
    for index = 1:height(template.Label)     % search for identifiers listed in the template structure
        if contains(line,string(template.Label(index)))                           % if that line contains template-identifier
            line=strrep(line,string(template.Label(index)), strip(string(template.Val(index)), '"'));    % replace identifier with corresponding value
            break
        end
    end
    
    fprintf(output,'%s',line); % print line to output file
end

fclose(input);             % close files
fclose(output);


%generate .wnd file
if ~exist('iecwind', 'file')
    error('Program iecwind not found. Please download it from https://github.com/BecMax/IECWind and place it in the AMPoWS preprocessing directory.')
end
if ispc
    [res, msg]= system(['set path=' getenv('PATH') ' & iecwind.exe']);
else
    [res, msg]= system('iecwind');
end

if res~=0
    error('iecwind terminated with message: "%s"', msg);
end
if contains(msg, 'WARNING')
    warning(msg)
end

%rename and move .wnd file
old_name = strip(upper(template.Val(end)), '"') + ".wnd"; % default-name generated by iec wind module
movefile(old_name,outfile);

delete('IEC.IPT');
