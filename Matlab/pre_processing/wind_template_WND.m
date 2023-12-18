%WIND_TEMPLATE_IEC Generates template-structure for the BTS-wind module.
%
% Copyright (c) 2022 Jens Geisler

function template = wind_template_WND

template = struct();
template.Label = {
    'URef'
    'RandSeed1'
    '{wnd_file_template}'
    };
template.Val = cell(size(template.Label));


