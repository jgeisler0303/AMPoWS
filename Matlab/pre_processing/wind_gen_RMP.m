
% Copyright (c) 2021 Jens Geisler

function wind_gen_RMP(template, template_file, outfile)
output = fopen(outfile, 'w');

URef= asdouble(GetFASTPar(template, 'URef'));
trans_time= asdouble(GetFASTPar(template, '{Transient_Event_Time}'));
slope= asdouble(GetFASTPar(template, '{Wind_Slope}'));
shear= asdouble(GetFASTPar(template, '{Shear_Exp}'));
TMax= asdouble(GetFASTPar(template, 'TMax'));
ramp= asdouble(GetFASTPar(template, '{uni-wind-param}'));

fprintf(output, '! Wind file for ramp wind from %f m/s\n', URef);
fprintf(output, '! Time\tWind\tWind\tVert.\tHoriz.\tVert.\tLinV\tGust\n');
fprintf(output, '! \tSpeed\tDir\tSpeed\tShear\tShear\tShear\tSpeed\n');

v= URef;
t= 0;
fprintf(output, '%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\n', t, v, 0, sind(slope)*v, 0, shear, 0, 0);
t= trans_time;
fprintf(output, '%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\n', t, v, 0, sind(slope)*v, 0, shear, 0, 0);
v= URef+(TMax-trans_time)/ramp;
t= TMax;
fprintf(output, '%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\n', t, v, 0, sind(slope)*v, 0, shear, 0, 0);


fclose(output);
