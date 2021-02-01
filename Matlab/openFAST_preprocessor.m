%% 1. load configuration and template-files

[DLC_cell,config,templates] = read_config('openFAST_config.xlsx');
col_start = find_label_or_create(DLC_cell,'Seperator',true) +1; % first "non-basic" column

% loop over each row in DLC config 
for row_xls = 2:size(DLC_cell,1) % first row contains labels
    
    files = struct(); % storage for files to write in main input
    turbsim_trig = false ; % initialize trigger to create turbsim file
    
    % load basic parameters by expanding DLC_cell
    wind_type = DLC_cell{row_xls,find_label_or_create(DLC_cell,'Wind-Type',true)} ;    % read Wind_Type from dlc_cell
    if ~ismissing(wind_type)
        DLC_cell=eval(join(['basic_config','_',wind_type,'(DLC_cell,row_xls);'])) ;
    end
    
    [v_combo, v_index] = generate_vector_combinations(DLC_cell, row_xls, col_start);    % Identify all vectors in row & save all possible combinations
            
    if isempty(v_combo)
        col_DLC = 1;    % no vectors: no combinations -> only 1 cycle of write & generate   
    else
        col_DLC = 1:length(v_combo(1,:));   % if DLC contains vectors: repeat for all combinations
    end
    
    % loop over input files and load corresponding configs
    for n_temp = (convertCharsToStrings(fieldnames(templates)))'
        
        template = templates.(n_temp);
        
        if strcmp(n_temp, 'turbsim')
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
       
            % loop over each "non-basic" column
            for col_xls = col_start:size(DLC_cell,2)

                % find location of used label in current input file
                idx = find(strcmp(template.Label,DLC_cell{1,col_xls})==1);

                % check if label exists
                if ~isempty(idx)
                    
                    if strcmp(n_temp,'turbsim') 
                        turbsim_trig = true ; % turbsim file has to be created
                    end    
                    
                    idx_v = find(v_index == col_xls);  % read vector elements from v_combo
                    
                    if ~isempty(idx_v)
                        template.Val(idx)={v_combo(idx_v,i_DLC)};

                    % read single elements from DLC_cell
                    elseif ischar(DLC_cell{row_xls,col_xls}) 
                        if isempty(str2num(DLC_cell{row_xls,col_xls}))
                            template.Val(idx)={append('"',DLC_cell{row_xls,col_xls},'"')}; % add " " to string elements
                        else
                            template.Val(idx)=DLC_cell(row_xls,col_xls);
                        end       

                    end
                end  
            end


            %% 3. Generate files

            DLC_name = DLC_cell{row_xls,1} ; % load DLC name
            filename_ext = '_';              % initialize filename extension

            erase_label=["(" , ")"] ;        % elements to erase from label to write in filename

            % loop over each combination to generate filename extension
            for i = 1:size(v_combo, 1) 
                % load label name and erase unallowed characters
                f_label=erase(DLC_cell{1,v_index(i)},erase_label); 

                % load cooresponding value and erase '.'- char
                f_value=strrep(convertStringsToChars(string(v_combo(i,i_DLC))),'.','p'); 

                % generate filename extension
                filename_ext=join([filename_ext,f_label,'-',f_value,'_']); 
            end   
        
            % generate filename
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
               template.Val(12)={convertCharsToStrings(join(['"',config.wind_path,'/',DLC_name,filename_ext,'_turbsim.bts','"']))};
            end

            % Write FAST-file
            if ~strcmp(n_temp,'turbsim') | turbsim_trig 
            Matlab2FAST(template,template_path,filename);
            end
       end
       
    end
    
    % create batch/shell -script
    turbsim_files = strip(files.turbsim,'"'); % load names of turbsim input files
    main_files = strip(files.maininput,'"') ;   % load names of .fst files

    % create script for turbsim 
    if turbsim_trig
        create_script('turbsim',turbsim_files,join([config.wind_path,'/',DLC_name]));
    end    
    % create script for FAST
    create_script('openfast',main_files,join([config.sim_path,'/',DLC_name]));
end
