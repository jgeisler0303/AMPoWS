function []= generate_iec_wind(template,outfile)

input = fopen(template,'r');   % open template file
output = fopen('IEC.IPT','w'); % open/create output file (IECwind Input)

while ~feof(input)                        % loop over the following until the end of the file is reached.
    
      line = fgets(input);                % read in one line
      
      for index = 1:height(parameter.label)     % search for identifiers listed in the template structure
         if contains(line,parameter.label(index))                           % if that line contains template-identifier
            line=strrep(line,parameter.label(index),string(parameter.value(index)));    % replace identifier with corresponding value
            break
         end     
      end  
      
fprintf(output,'%s',line); % print line to output file

end

fclose(input);             % close files
fclose(output);


%generate .wnd file
!iecwind      

%rename and move .wnd file
old_name = join([convertStringsToChars(parameter.value(end)),'.wnd']) ; % default-name generated by iec wind module
movefile(old_name,outfile) ;