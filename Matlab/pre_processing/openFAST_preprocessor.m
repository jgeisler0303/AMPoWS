
% Copyright (c) 2021 Hannah Dentzien, Ove Hagge Ellhöft
% Copyright (c) 2021 Jens Geisler

function openFAST_preprocessor(conig_file_name)

addpath(fileparts(mfilename('fullpath')))

if ~exist('conig_file_name', 'var')
    [file, path]= uigetfile('*.xls;*.xlsx', 'Select Excel configuration file', 'openFAST_config.xlsx');
    conig_file_name= fullfile(path, file);
end

%% 1. load configuration and template-files
start_dir= pwd;
cleanupObj = onCleanup(@()cd(start_dir));

[config_path, conig_file_name, conig_file_ext]= fileparts(conig_file_name);
if ~isempty(config_path)
    cd(config_path)
end

[DLC_cell,config,templates] = read_config([conig_file_name, conig_file_ext]);

% create target directories if they don't exist yet
[~, ~]= mkdir(config.sim_path); % suppress warning, if directory exists
[~, ~]= mkdir(config.wind_path); % suppress warning, if directory exists
rel_wind_path= make_relative_path(config.sim_path, config.wind_path);

% copy all sub-file that don't need templating into the target directory
templates= copy_sub_files(templates, config);

col_start = find_label_or_create(DLC_cell,'Seperator',true) + 1; % first "non-basic" column

% general information structure
DLC_Set_Info.templates= templates;
for template_name = (convertCharsToStrings(fieldnames(templates)))'
    path_field= append(template_name, '_path');
    DLC_Set_Info.templates.(path_field)= config.(path_field);
end
DLC_Set_Info.CutinWind= config.CutinWind;
DLC_Set_Info.RatedWind= config.RatedWind;
DLC_Set_Info.CutoutWind= config.CutoutWind;

% loop over each row in DLC config 
for row_xls = 2:size(DLC_cell,1) % first row contains labels
    DLC_name = DLC_cell{row_xls,1};

    files = struct();      % storage for filenames to write in main input
    
    % load basic parameters by expanding DLC_cell
    wind_type = strtok(DLC_cell{row_xls,find_label_or_create(DLC_cell,'Wind-Type',true)}, ':');
    
    % run basic configuration according to chosen windtype
    if isempty(wind_type)
        error('No wind type supplied for DLC "%s" in row %d.', DLC_cell{row_xls, 1}, row_xls);
    end
    
    wind_config_script= append('wind_config', '_', wind_type);
    if ~exist(wind_config_script, 'file')
        error('No configuration script found for wind type "%s" in DLC "%s" in row %d.', wind_type, DLC_cell{row_xls, 1}, row_xls);
    end
    [DLC_cell, turbsim_trig] = eval(append(wind_config_script, '(DLC_cell,row_xls);'));
    
    DLC_Set_Info.DLC(row_xls-1).name= DLC_cell{row_xls, 1};
    DLC_Set_Info.DLC(row_xls-1).raw= DLC_cell(row_xls, :);
    DLC_Set_Info.DLC(row_xls-1).turbsim_trig= turbsim_trig;

    % Identify all vectors in row & save all possible combinations
    [DLC_cell, v_combo, v_index, g_index] = generate_vector_combinations(DLC_cell, row_xls, col_start, config);   
            
    if isempty(v_combo)
        col_DLC = 1;    % no vectors: no combinations -> only 1 cycle of write & generate   
    else
        col_DLC = 1:size(v_combo,2);   % if DLC contains vectors: repeat for all combinations
    end
    
    % loop over input files and load corresponding configs
    for template_name = ["uni_wind" fieldnames(templates)']
        if strcmp(template_name, 'uni_wind')
            if ~turbsim_trig
                wind_template_script= append('wind_template', '_', wind_type);
                if ~exist(wind_template_script, 'file')
                    error('No template script found for wind type "%s" in DLC "%s" in row %d.', wind_type, DLC_cell{row_xls, 1}, row_xls);
                end
                template = eval(wind_template_script);
            else
                continue;
            end
        else
            template = templates.(template_name);
        end
        
        if strcmp(template_name, 'uni_wind')
            file_path = config.sim_path;
            file_type = '.wnd';
        elseif strcmp(template_name, 'turbsim')
            file_path = config.wind_path;
            file_type = '.inp';     
        elseif strcmp(template_name, 'maininput')
            file_path = config.sim_path;
            file_type = '.fst';   
        else
            file_path = config.sim_path;
            file_type = '.dat';   
        end
        
        file_suffix = append(template_name, file_type);
     
        % loop over all combinations
        for i_DLC = col_DLC
            %% 2. Write values in templates  
            [template, variations] = ...
                fill_template(i_DLC, DLC_cell, row_xls, col_start, template, v_combo, v_index, g_index) ;

            if strcmp(template_name, 'inflowwind')
                variations= joinVariations(DLC_Set_Info.DLC(row_xls-1).simulation(i_DLC), {'uni_wind', 'turbsim'});
            elseif strcmp(template_name, 'maininput')
                variations= joinVariations(DLC_Set_Info.DLC(row_xls-1).simulation(i_DLC), {'elastodyn', 'servodyn', 'aerodyn', 'inflowwind'});
            end
            DLC_Set_Info.DLC(row_xls-1).simulation(i_DLC).(template_name).variations= variations;
            
            %% 3. Generate files
            filename_ext = generate_filename_ext(variations, wind_type);
            
            % compose filename
            if strcmp(template_name, 'uni_wind') && any(strcmp(template.Label, '{bts_file_template}'))
                % special treatment of file name of already generated bts files
                input_file_name= sprintf(template.Val{find(strcmpi(template.Label, '{bts_file_template}'), 1)}, template.Val{find(strcmpi(template.Label, 'URef'), 1)});
                input_file_name= strrep(input_file_name, '"', '');
                if ~endsWith(input_file_name, '.bts')
                    input_file_name= [input_file_name '.bts'];
                end
                input_file_name= string(input_file_name);
                rel_file_path= append(rel_wind_path, input_file_name);
            elseif strcmp(template_name, 'iecwind') || strcmp(template_name, 'turbsim')
                input_file_name= append(strrep(DLC_cell{row_xls, find_label_or_create(DLC_cell,'Wind-Type',true)}, ':', '_'), '_', filename_ext, file_suffix);
                rel_file_path= append(rel_wind_path, input_file_name);
            else
                input_file_name= append(DLC_name, "_", filename_ext, file_suffix);
                rel_file_path= input_file_name;
            end
            files.(template_name)(i_DLC) = append('"', rel_file_path, '"');
            DLC_Set_Info.DLC(row_xls-1).simulation(i_DLC).(template_name).filename= rel_file_path;

            input_file_path = fullfile(file_path, input_file_name);

            % create references and generate files
            % this only works because the templates are in the order in
            % which they reference each other. otherwise generate_files
            % would have to be called in a separate loop
            generate_file(template_name, template, files, config, turbsim_trig, input_file_path, i_DLC, wind_type);
       end
    end   
end

write_make_scripts(config.sim_path, config.wind_path, DLC_Set_Info)
write_makefile(config.sim_path, DLC_Set_Info)
save(fullfile(config.sim_path, 'DLC_Set_Info'), 'DLC_Set_Info')
