%WIND_TEMPLATE_IEC Generates template-structure for the BTS-wind module.
%
% Copyright (c) 2022 Jens Geisler

function template = wind_template_IEC

template = struct();
template.Label = {
    '{Transient_Event_Time}'
    '{Turb_Class}'
    '{Wind_Class}'
    '{Wind_Slope}'
    '{IEC_standard}'
%     '{Shear_Exp}'
    '{Hub_Height}'
    '{D_Rotor}'
    '{CutinWind}'
    '{RatedWind}'
    '{CutoutWind}'
    '{uni-wind-param}'
    };
template.Val = cell(size(template.Label));


