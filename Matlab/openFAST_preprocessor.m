%% 1. load configuration and template-files

[DLC_cell,config,templates] = read_config('openFAST_config.xlsx');
col_start = find_label_or_create(DLC_cell,'Seperator',true) +1; % first "non-basic" column

% loop over each row in DLC config 
for row_xls = 2:size(DLC_cell,1) % first row contains labels
    
    files = struct(); % storage for files to write in main input
    turbsim_trig = false ; % initialize trigger to create turbsim file
    
    % load basic parameters by expanding DLC_cell
    wind_type = DLC_cell{row_xls,find_label_or_create(DLC_cell,'Wind-Type',true)};    % read Wind_Type from dlc_cell
    
    if ~ismissing(wind_type)
        if contains(wind_type,'IEC')
            DLC_cell = basic_config_detwind(DLC_cell,row_xls);
        else
            [DLC_cell, turbsim_trig] = eval(join(['basic_config','_',wind_type,'(DLC_cell,row_xls);']));
        end
    end
    
    [v_combo, v_index] = generate_vector_combinations(DLC_cell, row_xls, col_start);   % Identify all vectors in row & save all possible combinations
            
    if isempty(v_combo)
        col_DLC = 1;    % no vectors: no combinations -> only 1 cycle of write & generate   
    else
        col_DLC = 1:length(v_combo(1,:));   % if DLC contains vectors: repeat for all combinations
    end
    
    % loop over input files and load corresponding configs
    for n_temp = (convertCharsToStrings(fieldnames(templates)))'
        
        template = templates.(n_temp);
        
        if strcmp(n_temp, 'iecwind')
            file_path = config.wind_path;
            file_type = '.wnd';
        elseif strcmp(n_temp, 'turbsim')
            file_path = config.wind_path;
            file_type = '.inp';     
        elseif strcmp(n_temp, 'maininput')
            file_path = config.sim_path;
            file_type = '.fst';   
        else
            file_path = config.sim_path;
            file_type = '.dat';   
        end
        
        file_suffix = join(['_',convertStringsToChars(n_temp),file_type]);  
        template_path = config.(join([convertStringsToChars(n_temp),'_path']));
     
         
        % loop over all combinations
        for i_DLC = col_DLC
            
            
            %% 2. Write values in templates  
            
            % struct to save labelnames for filename_generation
            wind_labels.turbsim = struct('label',{},'value',{});
            wind_labels.iecwind = struct('label',{},'value',{}); 
       
            % loop over each "non-basic" column
            for col_xls = col_start:size(DLC_cell,2)

                % find location of used label in current input file
                idx = find(strcmp(template.Label,DLC_cell{1,col_xls})==1);
                
                % check if label exists
                if ~isempty(idx)   
                    
                    idx_v = find(v_index == col_xls);  % read vector elements from v_combo
                    
                    if ~isempty(idx_v)
                        template.Val(idx)={v_combo(idx_v,i_DLC)};
                        
                        if strcmp(n_temp,'turbsim')
                            wind_labels.turbsim(end+1).label = DLC_cell{1,col_xls};
                            wind_labels.turbsim(end).value = v_combo(idx_v,i_DLC);
                        elseif strcmp(n_temp,'iecwind')
                            wind_labels.iecwind(end+1).label = DLC_cell{1,col_xls};
                            wind_labels.iecwind(end).value = v_combo(idx_v,i_DLC);
                        end

                    % read single elements from DLC_cell
                    elseif ischar(DLC_cell{row_xls,col_xls}) 
                        
                        if isempty(str2num(DLC_cell{row_xls,col_xls}))
                            template.Val(idx) = {append('"',DLC_cell{row_xls,col_xls},'"')}; % add " " to string elements
                        else
                            template.Val(idx) = DLC_cell(row_xls,col_xls);
                        end       

                    end
                    
                end 
                
            end


            %% 3. Generate files

            filename_ext = generate_filename_ext(DLC_cell, v_index, v_combo(:,i_DLC), n_temp, wind_labels);
            
            % generate filename
            DLC_name = DLC_cell{row_xls,1} ;
            filename = join([file_path,'/',DLC_name,filename_ext,file_suffix]);

            % store filename to write in maininput file
            files.(n_temp)(i_DLC) = convertCharsToStrings(join(['"',DLC_name,filename_ext,file_suffix,'"'])); 

            % write file references to maininput file
            if strcmp(n_temp,'maininput')
                
                template.Val(find(strcmp(template.Label,'AeroFile')==1))   = {files.aerodyn(i_DLC)};
                template.Val(find(strcmp(template.Label,'EDFile')==1))     = {files.elastodyn(i_DLC)};
                template.Val(find(strcmp(template.Label,'InflowFile')==1)) = {files.inflowwind(i_DLC)};
                template.Val(find(strcmp(template.Label,'ServoFile')==1))  = {files.servodyn(i_DLC)};                   

            % write turbsim .bts file name to inflowwind
            elseif strcmp(n_temp,'inflowwind') && turbsim_trig
                turbname = strip(convertStringsToChars(files.turbsim(i_DLC)),'"');
                template.Val(find(strcmp(template.Label,'FileName_BTS')==1))={strrep(convertCharsToStrings(join(['"',config.wind_path,'/',turbname])),'inp','bts')};
            end

            % Generate files
            if strcmp(n_temp,'iecwind') && ~turbsim_trig
                % Generate deterministic iecwind
                generate_iec_wind(template_path,template,filename)
            elseif ~strcmp(n_temp,'turbsim') && ~strcmp(n_temp,'iecwind')
                Matlab2FAST(template,template_path,filename);
            elseif strcmp(n_temp,'turbsim') && turbsim_trig 
                Matlab2FAST(template,template_path,filename);
            end
            
       end
       
    end
    
    % create batch/shell -script
    turbsim_files = strip(unique(files.turbsim),'"'); % load names of turbsim input files
    main_files = strip(files.maininput,'"') ;   % load names of .fst files

    % create script for turbsim 
    if turbsim_trig
        create_script('turbsim',turbsim_files,join([config.wind_path,'/',DLC_name]));
    end
    
    % create script for FAST
    create_script('openfast',main_files,join([config.sim_path,'/',DLC_name]));
    
end
