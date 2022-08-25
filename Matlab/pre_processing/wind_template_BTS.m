%WIND_TEMPLATE_IEC Generates template-structure for the BTS-wind module.
%
% Copyright (c) 2022 Jens Geisler

function template = wind_template_BTS

template = struct();
template.Label = {
    'URef'
    '{bts_file_template}'
    };
template.Val = cell(size(template.Label));


