%% 1. load configuration and template-files 

% load DLC config from Excel-sheet
DLC_cell = readcell('openFAST_config.xlsx','Sheet','DLC_List');

% load template files 
config=readcell('openFAST_config.xlsx','Sheet','config'); % path to files from Excel-sheet
file_path=config{9,2}; % location of simulation directory

maininput = FAST2Matlab(config{2,2});
elastodyn = FAST2Matlab(config{3,2});
servodyn = FAST2Matlab(config{4,2});
aerodyn = FAST2Matlab(config{5,2});
inflowwind = FAST2Matlab(config{6,2});
turbsim = FAST2Matlab(config{7,2});

col_start = find_label_or_create(DLC_cell,'Seperator',true) +1; % first "non-basic" column

% loop over each row in DLC config 
for row_xls = 2:size(DLC_cell,1) % first row contains labels
    
    files = strings; % storage for files to write in main input
    turbsim_trig = false ; % initialize trigger to create turbsim file
    % load basic parameters by expanding DLC_cell
    wind_type = DLC_cell{row_xls,find_label_or_create(DLC_cell,'Wind-Type',true)} ;    % read Wind_Type from dlc_cell
    if ~ismissing(wind_type)
        DLC_cell=eval(join(['basic_config','_',wind_type,'(DLC_cell,row_xls);'])) ;
    end
    
    [v_combo, v_index] = generate_vector_combinations(DLC_cell, row_xls, col_start);    % Identify all vectors in row & save all possible combinations
    
    % switch through input files and load corresponding configs
    for n_temp = 1:6
        
        switch n_temp
            case 1
                template = aerodyn; 
                file_suffix ='_aerodyn.dat';
                path_spec='/sim/';
                template_path=config{5,2};
            case 2
                template = elastodyn;   
                file_suffix ='_elastodyn.dat';
                path_spec='/sim/';
                template_path=config{3,2};
            case 3
                template = turbsim; 
                file_suffix ='_turbsim.inp';
                path_spec='/wind/';
                template_path=config{7,2};
            case 4
                template = inflowwind;    
                file_suffix ='_inflowwind.dat';
                path_spec='/sim/';
                template_path=config{6,2};
            case 5
                template = servodyn;  
                file_suffix ='_servodyn.dat';
                path_spec='/sim/';
                template_path=config{4,2};
            case 6
                template = maininput; 
                file_suffix ='.fst';
                path_spec='/sim/';
                template_path=config{2,2};
        end
        
     
        
        if isempty(v_combo)
            col_DLC = 1;    % no vectors: no combinations -> only 1 cycle    
        else
            col_DLC = 1:length(v_combo(1,:));   % if DLC contains vectors: repeat for all combinations
        end
         
        % loop over all combinations
        for i_DLC = col_DLC
                
            %% 3. Write values in templates     
       
            % loop over each "non-basic" column
            for col_xls = col_start:size(DLC_cell,2)

                % find location of used label in current input file
                idx = find(strcmp(template.Label,DLC_cell{1,col_xls})==1);

                % check if label exists
                if ~isempty(idx)
                    
                    if n_temp==3 
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


            %% 4. Generate files

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
            filename = join([file_path,path_spec,DLC_name,filename_ext,file_suffix]);

            % store filename to write in maininput file
            files(n_temp,i_DLC) = convertCharsToStrings(join(['"',DLC_name,filename_ext,file_suffix,'"'])); 

            % write file references to maininput file
            if n_temp == 6 
               template.Val(23)={files(1,i_DLC)};
               template.Val(18)={files(2,i_DLC)};
               template.Val(22)={files(4,i_DLC)};
               template.Val(24)={files(5,i_DLC)};                   

               % write turbsim .bts file name to inflowwind
            elseif n_temp == 4 && turbsim_trig
               template.Val(12)={convertCharsToStrings(join(['"','../wind/',DLC_name,filename_ext,'_turbsim.bts','"']))};
            end

            % Write FAST-file
            if n_temp~=3 | turbsim_trig 
            Matlab2FAST(template,template_path,filename);
            end
       end
       
    end
    
    % create batch/shell -script
    turbsim_files = strip(files(3,:),'"'); % load names of turbsim input files
    main_files = strip(files(6,:),'"') ;   % load names of .fst files

    % create script for turbsim 
    if turbsim_trig
        create_script('turbsim',turbsim_files,join([file_path,'/wind/',DLC_name]));
    end    
    % create script for FAST
    create_script('openfast',main_files,join([file_path,'/sim/',DLC_name]));
end
