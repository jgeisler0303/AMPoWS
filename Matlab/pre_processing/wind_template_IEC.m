%WIND_TEMPLATE_IEC Generates template-structure for the IEC-wind module.
%
% Copyright (c) 2021 Hannah Dentzien, Ove Hagge Ellhöft
% Copyright (c) 2021 Jens Geisler

function template = wind_template_IEC

template = struct();
template.Label = {
    '{Transient_Event_Time}'
    '{Turb_Class}'
    '{Wind_Class}'
    '{Wind_Slope}'
    '{Shear_Exp}'
    '{Hub_Height}'
    '{D_Rotor}'
    '{CutinWind}'
    '{RatedWind}'
    '{CutoutWind}'
    '{uni-wind-param}'
    };
template.Val = cell(size(template.Label));


