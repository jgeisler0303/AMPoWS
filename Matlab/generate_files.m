function [] = generate_files(n_temp, template, files, config, turbsim_trig, filename, i_DLC)

template_path = config.(join([convertStringsToChars(n_temp),'_path']));

% write file references to maininput file
if strcmp(n_temp,'maininput')

    template.Val(find(strcmp(template.Label,'AeroFile')==1))   = {files.aerodyn(i_DLC)};
    template.Val(find(strcmp(template.Label,'EDFile')==1))     = {files.elastodyn(i_DLC)};
    template.Val(find(strcmp(template.Label,'InflowFile')==1)) = {files.inflowwind(i_DLC)};
    template.Val(find(strcmp(template.Label,'ServoFile')==1))  = {files.servodyn(i_DLC)};                   

% write wind file name to inflowwind
elseif strcmp(n_temp,'inflowwind') && turbsim_trig
    turbname = strip(convertStringsToChars(files.turbsim(i_DLC)),'"');
    template.Val(find(strcmp(template.Label,'FileName_BTS')==1))={strrep(convertCharsToStrings(join(['"',config.wind_path,'/',turbname])),'inp','bts')};
elseif strcmp(n_temp,'inflowwind') && ~turbsim_trig
    uni_wind_name = strip(convertStringsToChars(files.iecwind(i_DLC)),'"');
    template.Val(find(strcmp(template.Label,'Filename_Uni')==1))={convertCharsToStrings(join(['"',config.wind_path,'/',uni_wind_name,'"']))};
end

% Generate files
if strcmp(n_temp,'iecwind') && ~turbsim_trig
    % Generate deterministic iecwind
    generate_iec_wind(template_path,template,filename);
elseif ~strcmp(n_temp,'turbsim') && ~strcmp(n_temp,'iecwind')
    Matlab2FAST(template,template_path,filename);
elseif strcmp(n_temp,'turbsim') && turbsim_trig
    % Generate turbsim input file
    Matlab2FAST(template,template_path,filename);
end