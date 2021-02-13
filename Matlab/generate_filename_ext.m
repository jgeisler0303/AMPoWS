function [filename_ext] = generate_filename_ext(DLC_cell, v_index, v_combo_col, n_temp, turbsim_labelnames)

%% Generate filenames

filename_ext = '_';              % initialize filename extension
erase_label=["(" , ")"] ;        % elements to erase from label to write in filename

%create turbsim fileextensions
if strcmp(n_temp,'turbsim')
    for i = 1:length(turbsim_labelnames.value)
        % load label name and erase unallowed characters
        f_label = erase(turbsim_labelnames(i).label, erase_label);
        % load cooresponding value and erase '.'- char
        f_value = strrep(convertStringsToChars(string(turbsim_labelnames(i).value)),'.','p');

        % generate filename extension
        filename_ext = join([filename_ext,f_label,'-',f_value,'_']);
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