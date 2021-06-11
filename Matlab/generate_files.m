function [] = generate_files(template_name, template, files, config, turbsim_trig, filename, i_DLC)
%GENERATE_FILES Generates OpenFAST, iecwind and TurbSim input files.


template_path = config.(join([convertStringsToChars(template_name),'_path']));

% write file references to maininput file
if strcmp(template_name,'maininput')

    template.Val(find(strcmp(template.Label,'AeroFile')==1))   = {files.aerodyn(i_DLC)};
    template.Val(find(strcmp(template.Label,'EDFile')==1))     = {files.elastodyn(i_DLC)};
    template.Val(find(strcmp(template.Label,'InflowFile')==1)) = {files.inflowwind(i_DLC)};
    template.Val(find(strcmp(template.Label,'ServoFile')==1))  = {files.servodyn(i_DLC)};                   

% write wind file name to inflowwind
elseif strcmp(template_name,'inflowwind') && turbsim_trig
    turbname = strip(convertStringsToChars(files.turbsim(i_DLC)),'"');
    rel_wind_path= make_relative_path(config.sim_path, config.wind_path);
    template.Val(find(strcmp(template.Label,'FileName_BTS')==1))={strrep(['"', rel_wind_path,turbname '"'],'inp','bts')};
elseif strcmp(template_name,'inflowwind') && ~turbsim_trig
    uni_wind_name = strip(convertStringsToChars(files.iecwind(i_DLC)),'"');
    rel_wind_path= make_relative_path(config.sim_path, config.wind_path);
    template.Val(find(strcmp(template.Label,'Filename_Uni')==1))={['"', rel_wind_path, uni_wind_name, '"']};
end

% Generate files
if strcmp(template_name,'iecwind') && ~turbsim_trig
    % Generate deterministic iecwind
    generate_iec_wind(template,template_path,filename);
elseif ~strcmp(template_name,'turbsim') && ~strcmp(template_name,'iecwind')
    Matlab2FAST(template,template_path,filename);
elseif strcmp(template_name,'turbsim') && turbsim_trig
    % Generate turbsim input file
    Matlab2FAST(template,template_path,filename);
end