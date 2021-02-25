function[template,wind_labels] = write_templates(template_name,i_DLC,DLC_cell,row_xls,col_start,template,v_combo,v_index)

    %% 2. Write values in templates  

    % struct to save labelnames for filename_generation
    wind_labels = struct('label',{},'value',{});

    % loop over each "non-basic" column
    for col_xls = col_start:size(DLC_cell,2)

        % find location of used label in current input file
        idx = find(strcmp(template.Label,DLC_cell{1,col_xls})==1);
        % check if label exists
        if ~isempty(idx)   

            idx_v = find(v_index == col_xls);  % read vector elements from v_combo

            if ~isempty(idx_v)
                template.Val(idx)={v_combo(idx_v,i_DLC)};

                if strcmp(template_name,'turbsim') | strcmp(template_name,'iecwind')
                    wind_labels(end+1).label = DLC_cell{1,col_xls};
                    wind_labels(end).value = v_combo(idx_v,i_DLC);
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