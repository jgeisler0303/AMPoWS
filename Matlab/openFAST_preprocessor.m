%% 1. load configuration and template-files

[DLC_cell,config,templates] = read_config('openFAST_config.xlsx');
% create target directories if they don't exist yet
[~, ~]= mkdir(config.sim_path); % suppress warning, if directory exists
[~, ~]= mkdir(config.wind_path); % suppress warning, if directory exists

% make path to wind directory absolute
old_dir= cd(config.wind_path);
config.wind_path= cd(old_dir);

% copy all sub-file that don't need templating into the target directory
templates= copy_sub_files(templates, config);

col_start = find_label_or_create(DLC_cell,'Seperator',true) +1; % first "non-basic" column

% loop over each row in DLC config 
for row_xls = 2:size(DLC_cell,1) % first row contains labels
    
    files = struct();      % storage for filenames to write in main input
    turbsim_trig = false ; % initialize trigger to create turbsim file
    
    % load basic parameters by expanding DLC_cell
    wind_type = DLC_cell{row_xls,find_label_or_create(DLC_cell,'Wind-Type',true)};
    
    % run basic configuration according to chosen windtype
    if ~ismissing(wind_type)
        if contains(wind_type,'IEC')
            DLC_cell = basic_config_detwind(DLC_cell,row_xls);
        else
            [DLC_cell, turbsim_trig] = eval(join(['basic_config','_',wind_type,'(DLC_cell,row_xls);']));
        end
    end
    
    % Identify all vectors in row & save all possible combinations
    [v_combo, v_index] = generate_vector_combinations(DLC_cell, row_xls, col_start);   
            
    if isempty(v_combo)
        col_DLC = 1;    % no vectors: no combinations -> only 1 cycle of write & generate   
    else
        col_DLC = 1:size(v_combo,2);   % if DLC contains vectors: repeat for all combinations
    end
    
    % loop over input files and load corresponding configs
    for template_name = (convertCharsToStrings(fieldnames(templates)))'
        
        template = templates.(template_name);
        
        if strcmp(template_name, 'iecwind')
            file_path = config.wind_path;
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
        
        file_suffix = join(['_',convertStringsToChars(template_name),file_type]);  
     
        % loop over all combinations
        for i_DLC = col_DLC
            
            %% 2. Write values in templates  
            
            [template , wind_labels] = write_templates(template_name, i_DLC, DLC_cell, row_xls, col_start, template, v_combo, v_index) ;
                
           
            %% 3. Generate files
            filename_ext = generate_filename_ext(DLC_cell, v_index, v_combo(:,i_DLC), template_name, wind_labels);
            
            % generate filename
            DLC_name = DLC_cell{row_xls,1} ;
%             filename = join([file_path,'/',DLC_name,filename_ext,file_suffix]);
            filename = fullfile(file_path,join([DLC_name,filename_ext,file_suffix]));  
            % store filename to write in maininput file
            files.(template_name)(i_DLC) = convertCharsToStrings(join(['"',DLC_name,filename_ext,file_suffix,'"'])); 
            
            % create references and generate files
            generate_files(template_name, template, files, config, turbsim_trig, filename, i_DLC);

            
       end
       
    end
    
    % create batch/shell -script
    turbsim_files = strip(unique(files.turbsim),'"'); % load names of turbsim input files
    main_files = strip(files.maininput,'"') ;   % load names of .fst files

    % create script for turbsim 
    if turbsim_trig
        create_script('turbsim',turbsim_files,fullfile(config.wind_path,DLC_name));
    end
    
    % create script for FAST
    create_script('openfast',main_files,fullfile(config.sim_path,DLC_name));
    
end
