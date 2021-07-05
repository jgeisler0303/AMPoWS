function write_makefile(sim_path, DLC_Set_Info)

filename= fullfile(sim_path, 'makefile');
output = fopen(filename, 'w');

fprintf(output, 'OPENFAST=openfast\n\n');
fprintf(output, 'TURBSIM=turbsim\n\n');

for i_DLC= 1:length(DLC_Set_Info.DLC)
    DLC_name= DLC_Set_Info.DLC(i_DLC).name;
    
    main_files= strings(length(DLC_Set_Info.DLC(i_DLC).simulation), 1);
    for i_sim= 1:length(DLC_Set_Info.DLC(i_DLC).simulation)
        main_files(i_sim)= DLC_Set_Info.DLC(i_DLC).simulation(i_sim).maininput.filename;
    end
    
    write_file_list(output, DLC_name, main_files)
end

fprintf(output, 'all: ');
for i_DLC= 1:length(DLC_Set_Info.DLC)
    DLC_name= DLC_Set_Info.DLC(i_DLC).name;
    fprintf(output, '$(OUT_FILES_%s) ', DLC_name);
end
fprintf(output, '\n\n');

for i_DLC= 1:length(DLC_Set_Info.DLC)
    DLC_name= DLC_Set_Info.DLC(i_DLC).name;
    fprintf(output, '%s: $(OUT_FILES_%s)\n\n', DLC_name, DLC_name);
end

for i_DLC= 1:length(DLC_Set_Info.DLC)
    if DLC_Set_Info.DLC(i_DLC).turbsim_trig
        for i_sim= 1:length(DLC_Set_Info.DLC(i_DLC).simulation)
            out_file= strrep(DLC_Set_Info.DLC(i_DLC).simulation(i_sim).maininput.filename, '.fst', '.outb');
            turb_file= strrep(DLC_Set_Info.DLC(i_DLC).simulation(i_sim).turbsim.filename, '.inp', '.bts');
            
            fprintf(output, '%s: %s\n\n', out_file, turb_file);
        end
    end
end

fprintf(output, '%%.outb : %%.fst\n');
fprintf(output, '\t$(OPENFAST) $< > $*.log\n\n');

fprintf(output, '%%.bts : %%.inp\n');
fprintf(output, '\t$(TURBSIM) $< > $*.log\n\n');

fprintf(output, '.PHONY: clean all\n');

fclose(output);

function write_file_list(outfile, name, files)
fprintf(outfile, 'SIM_FILES_%s:= \\\n', name);
for i=1:length(files)           
    fprintf(outfile, '\t%s', files(i));
    if i<length(files)
        fprintf(outfile, ' \\\n');
    else
        fprintf(outfile, ' \n\n');
    end        
end

fprintf(outfile, 'OUT_FILES_%s:= $(patsubst %%.fst, %%.outb, $(SIM_FILES_%s))\n\n\n', name, name); 

