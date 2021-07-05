function write_make_scripts(sim_path, wind_path, DLC_Set_Info)
% create batch/shell -script
all_main_files= [];
all_turb_files= [];
for i_DLC= 1:length(DLC_Set_Info.DLC)
    DLC_name= DLC_Set_Info.DLC(i_DLC).name;
    
    main_files= strings(length(DLC_Set_Info.DLC(i_DLC).simulation), 1);
    for i_sim= 1:length(DLC_Set_Info.DLC(i_DLC).simulation)
        main_files(i_sim)= DLC_Set_Info.DLC(i_DLC).simulation(i_sim).maininput.filename;
    end
    all_main_files= [all_main_files; main_files];
    
    create_script('openfast', main_files, fullfile(sim_path, DLC_name));

    if DLC_Set_Info.DLC(i_DLC).turbsim_trig
        turbsim_files= strings(length(DLC_Set_Info.DLC(i_DLC).simulation), 1);
        for i_sim= 1:length(DLC_Set_Info.DLC(i_DLC).simulation)
            [~, turbsim_files(i_sim), fext]= fileparts(DLC_Set_Info.DLC(i_DLC).simulation(i_sim).turbsim.filename);
            turbsim_files(i_sim)= join([turbsim_files(i_sim) fext], '');
        end
        all_turb_files= [all_turb_files; turbsim_files];
        
        create_script('turbsim', turbsim_files, fullfile(wind_path, DLC_name));
    end
end

create_script('openfast', all_main_files, fullfile(sim_path, 'all'));
create_script('turbsim', all_turb_files, fullfile(wind_path, 'all'));