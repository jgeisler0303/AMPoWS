function [filename_ext] = generate_filename_ext(DLC_cell, v_index, v_combo_col, n_temp, wind_labelnames)

%% Generate filenames

filename_ext = '_';              % initialize filename extension
erase_label=["(" , ")"] ;        % elements to erase from label to write in filename

% create turbsim file extensions
if strcmp(n_temp,'turbsim')
    if ~isempty(wind_labelnames.turbsim)
        for i = 1:length(wind_labelnames.turbsim.value)
            % load label name and erase unallowed characters
            f_label = erase(wind_labelnames.turbsim(i).label, erase_label);
            % load cooresponding value and erase '.'- char
            f_value = strrep(convertStringsToChars(string(wind_labelnames.turbsim(i).value)),'.','p');

            % generate filename extension
            filename_ext = join([filename_ext,f_label,'-',f_value,'_']);
        end
    else
        filename_ext = '';
    end

% create IECWind file extensions
elseif strcmp(n_temp,'iecwind')
    if ~isempty(wind_labelnames.iecwind)
        for i = 1:length(wind_labelnames.iecwind.value)
            % load label name and erase unallowed characters
            f_label = erase(wind_labelnames.iecwind(i).label, erase_label);
            % load cooresponding value and erase '.'- char
            f_value = strrep(convertStringsToChars(string(wind_labelnames.iecwind(i).value)),'.','p');

            % generate filename extension
            filename_ext = join([filename_ext,f_label,'-',f_value,'_']);
        end
    else
        filename_ext = '';
    end

% create other file extensions
else
    for i = 1:length(v_combo_col) 

        % load label name and erase unallowed characters
        f_label = erase(DLC_cell{1,v_index(i)},erase_label);
        % load cooresponding value and erase '.'- char
        f_value = strrep(convertStringsToChars(string(v_combo_col(i))),'.','p'); 

        % generate filename extension
        filename_ext = join([filename_ext,f_label,'-',f_value,'_']); 
    end

end