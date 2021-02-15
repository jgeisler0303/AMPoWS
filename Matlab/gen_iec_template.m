function template = gen_iec_template

template = struct();
template.Label = [{'{Transient_Event_Time}'};{'{Turb_Class}'}; {'{Wind_Slope}'}; {'{Shear_Exp}'}; {'{IEC-condition}'}];
template.Val = cell(size(template.Label));


