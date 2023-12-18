%GENERATE_FILENAME_EXT Generates explicit filename extension for the input-files by appending
%   label-value pairs. Wind files are only named after wind-specific labels.
%
% Copyright (c) 2021 Hannah Dentzien, Ove Hagge Ellhöft
% Copyright (c) 2021 Jens Geisler

function filename_ext = generate_filename_ext(variations, wind_type)

%% Generate filenames

filename_ext = "";              % initialize filename extension
erase_label=["(" , ")", "{", "}"] ;        % elements to erase from label to write in filename
for i = 1:length(variations)
    if ~variations(i).group1st, continue, end % TODO: this is not ideal, better would be to use the group label
    
    f_label = erase(variations(i).label, erase_label);
    f_value = strrep(strrep(string(variations(i).g_value),'.','p'), '-', 'neg');
    if strcmp(f_label, 'uni-wind-param')
        filename_ext = append(filename_ext, wind_type, '-', f_value, '_');
    else
        filename_ext = append(filename_ext, f_label, '-', f_value, '_');
    end
end
