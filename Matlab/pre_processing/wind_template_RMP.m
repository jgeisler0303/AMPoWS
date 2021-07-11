
% Copyright (c) 2021 Jens Geisler

function template = wind_template_RMP

template = struct();
template.Label = {
    'URef'
    '{Transient_Event_Time}'
    '{Wind_Slope}'
    '{Shear_Exp}'
    'TMax'
    '{uni-wind-param}'
    };
template.Val = cell(size(template.Label));


