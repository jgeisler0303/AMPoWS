function template = gen_iec_template
%GEN_IEC_TEMPLATE Generates template-structure for the IEC-wind module.

template = struct();
template.Label = [{'{Transient_Event_Time}'}; {'{Turb_Class}'}; {'{Wind_Slope}'}; {'{Shear_Exp}'}; {'{IEC-condition}'}];
template.Val = cell(size(template.Label));


