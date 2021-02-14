function template = gen_iec_template

template = struct();
template.Label = [{'Transient-Event-Time'} ; {'Wind-Slope'}; {'Shear-Exp'};{'Wind-Type'}];
template.Val = cell(size(template.Label)) ;


