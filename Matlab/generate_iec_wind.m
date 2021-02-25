function []= generate_iec_wind(template,template_file,outfile)

input = fopen(template_file,'r');   % open template file
output = fopen('IEC.IPT','w');      % open/create output file (IECwind Input)

while ~feof(input)                        % loop over the following until the end of the file is reached.
    
      line = fgets(input);                % read in one line
      
      for index = 1:height(template.Label)     % search for identifiers listed in the template structure
         if contains(line,string(template.Label(index)))                           % if that line contains template-identifier
            line=strrep(line,string(template.Label(index)),strip(string(template.Val(index)),'"'));    % replace identifier with corresponding value
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
old_name = join([convertStringsToChars(strip(string(template.Val(end)),'"')),'.wnd']); % default-name generated by iec wind module
movefile(old_name,outfile);

delete('IEC.IPT');