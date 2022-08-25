function makeCoherentBTS(file_names)
if iscell(file_names)
    for i= 1:length(file_names)
        makeCoherentBTS(file_names{i})
    end
    return
end

[velocity, twrVelocity, y, z, ~, ~, ~, ~, ~, dt, zHub, z1,mffws]= readfile_BTS(file_names);

velocity= mean(mean(velocity, 3), 4);

twrVelocity= repmat(velocity, 1, 1, size(twrVelocity, 3));

velocity= repmat(velocity, 1, 1, 2, 2);

y= [y(1) y(end)];
dy= diff(y);
z= [z(1) z(end)];
dz= diff(z);

writefile_BTS(strrep(file_names, '.bts', '_coh.bts'), 'Generated by script "makeCoherentBTS"', velocity, twrVelocity, dz, dy, dt, zHub, z1, mffws)

