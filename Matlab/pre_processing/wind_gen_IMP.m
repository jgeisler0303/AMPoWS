
% Copyright (c) 2021 Jens Geisler

function wind_gen_IMP(template, template_file, outfile)
output = fopen(outfile, 'w');

URef= asdouble(GetFASTPar(template, 'URef'));
trans_time= asdouble(GetFASTPar(template, '{Transient_Event_Time}'));
wind_slope= asdouble(GetFASTPar(template, '{Wind_Slope}'));
shear= asdouble(GetFASTPar(template, '{Shear_Exp}'));
TMax= asdouble(GetFASTPar(template, 'TMax'));
imp_param= split(GetFASTPar(template, '{uni-wind-param}'), '/');
imp= asdouble(imp_param{1});
if length(imp_param)>1
    slope= asdouble(imp_param{2});
else
    slope= 0.005;
end

fprintf(output, '! Wind file for impulse wind at %f m/s\n', URef);
fprintf(output, '! Time\tWind\tWind\tVert.\tHoriz.\tVert.\tLinV\tGust\n');
fprintf(output, '! \tSpeed\tDir\tSpeed\tShear\tShear\tShear\tSpeed\n');

v= URef;
t= 0;
fprintf(output, '%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\n', t, v, 0, sind(wind_slope)*v, 0, shear, 0, 0);
t= trans_time;
fprintf(output, '%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\n', t, v, 0, sind(wind_slope)*v, 0, shear, 0, 0);
v= URef+imp;
t= trans_time+slope;
fprintf(output, '%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\n', t, v, 0, sind(wind_slope)*v, 0, shear, 0, 0);
t= trans_time + (TMax-trans_time)/2;
fprintf(output, '%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\n', t, v, 0, sind(wind_slope)*v, 0, shear, 0, 0);
v= URef;
t= trans_time + (TMax-trans_time)/2 + slope;
fprintf(output, '%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\n', t, v, 0, sind(wind_slope)*v, 0, shear, 0, 0);
t= TMax;
fprintf(output, '%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\n', t, v, 0, sind(wind_slope)*v, 0, shear, 0, 0);


fclose(output);
