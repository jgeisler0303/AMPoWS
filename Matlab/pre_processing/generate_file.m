%GENERATE_FILES Generates OpenFAST, iecwind and TurbSim input files.
%
% Copyright (c) 2021 Hannah Dentzien, Ove Hagge Ellhöft
% Copyright (c) 2021 Jens Geisler

function generate_file(template_name, template, files, config, turbsim_trig, filename, i_DLC, wind_type)

template_path = config.(join([convertStringsToChars(template_name),'_path']));

if strcmp(template_name,'maininput')
    % write file references to maininput file
    template.Val(find(strcmpi(template.Label,'AeroFile')))   = {files.aerodyn(i_DLC)};
    template.Val(find(strcmpi(template.Label,'EDFile')))     = {files.elastodyn(i_DLC)};
    template.Val(find(strcmpi(template.Label,'InflowFile'))) = {files.inflowwind(i_DLC)};
    template.Val(find(strcmpi(template.Label,'ServoFile')))  = {files.servodyn(i_DLC)};                   
elseif strcmp(template_name,'inflowwind') && turbsim_trig
    % write wind file name to inflowwind
    template.Val(find(strcmpi(template.Label,'FileName_BTS')))= {strrep(files.turbsim(i_DLC),'inp','bts')};
elseif strcmp(template_name,'inflowwind') && ~turbsim_trig
    % write wind file name to inflowwind
    template.Val(find(strcmpi(template.Label,'Filename_Uni')))= {files.uni_wind(i_DLC)};
end

% Generate files
if strcmp(template_name,'uni_wind')
    if ~turbsim_trig
        wind_gen_script= join(['wind_gen','_',wind_type]);
        if ~exist(wind_gen_script, 'file')
            error('No generation script found for wind type "%s".', wind_type);
        end
        eval(join([wind_gen_script, '(template, template_path, filename);']));
    end
elseif strcmp(template_name,'turbsim')
    % Generate turbsim input file if it has changed
    if exist(filename, 'file') && turbsim_trig
        do_gen= false;
        orig_file= FAST2Matlab(filename);
        if length(orig_file.Val)~=length(template.Val)
            do_gen= true;
        else
            for i_Val= 1:length(orig_file.Val)
                orig_Val= orig_file.Val{i_Val};
                if ischar(orig_Val)
                    num= str2num(orig_Val);
                    if ~isempty(num)
                        orig_Val= num;
                    end
                end
                templ_Val= template.Val{i_Val};
                if ischar(templ_Val)
                    num= str2num(templ_Val);
                    if ~isempty(num)
                        templ_Val= num;
                    end
                end
                if ~isequal(orig_Val, templ_Val)
                    do_gen= true;
                    break
                end
            end
        end
    else
        do_gen= turbsim_trig;
    end
    
    if do_gen
        Matlab2FAST(template,template_path,filename);
    end
else
    % Generate other input file
    Matlab2FAST(template,template_path,filename);
end
