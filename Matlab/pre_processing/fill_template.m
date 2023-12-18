%WRITE_TEMPLATES Fills the template structures with the specified
%   simulation parameters
%
% Copyright (c) 2021 Hannah Dentzien, Ove Hagge Ellhöft
% Copyright (c) 2021 Jens Geisler

function[template, variations] = fill_template(i_DLC, DLC_cell, row_xls, col_start, template, v_combo, v_index, g_index, g_name)

variations= struct('label', {}, 'value', {}, 'g_value', {}, 'multi', {}, 'group1st', {});
group1st= diff([0 g_index]);

if isempty(template), return, end

% loop over each "non-basic" column
for col_xls = col_start:size(DLC_cell,2)
    % find location of used label in current input file
    idx = find(strcmpi(template.Label, DLC_cell{1,col_xls}));
    % check if label exists
    if ~isempty(idx)   
        idx_v = find(v_index == col_xls);  % read vector elements from v_combo
        varied= true;
        multi_vary= false;
        
        if ~isempty(idx_v)
            multi_vary= true;
            % special treatment for IEC wind conditions: a list of conditions
            % separated by colons
            if strcmp(DLC_cell{1, col_xls}, '{uni-wind-param}')
                uni_wind_param= split(DLC_cell(row_xls, col_xls), ':');
                template.Val(idx)={uni_wind_param{v_combo(idx_v, i_DLC)}};
            else
                template.Val(idx)={v_combo(idx_v,i_DLC)};
            end
            
        % read single elements from DLC_cell
        elseif ischar(DLC_cell{row_xls,col_xls}) 
            val= str2num(DLC_cell{row_xls,col_xls});
            if isempty(val)
                if DLC_cell{row_xls,col_xls}(1)~='"'  && ~strcmpi(DLC_cell{row_xls,col_xls}, 'true') && ~strcmpi(DLC_cell{row_xls,col_xls}, 'false')
                    template.Val{idx} = append('"',DLC_cell{row_xls,col_xls},'"'); % add " " to string elements
                else
                    template.Val{idx} = DLC_cell{row_xls,col_xls}; % add " " to string elements
                end                    
            else
                template.Val{idx} = num2str(val);
            end       
        elseif ~ismissing(DLC_cell{row_xls,col_xls})
            template.Val(idx) = DLC_cell(row_xls,col_xls);
        else
            varied= false;
        end
        
        if varied
            variations(end+1).label= DLC_cell{1,col_xls};
            variations(end).value= template.Val(idx);
            variations(end).g_value= [];
            variations(end).multi= multi_vary;
            if multi_vary
                variations(end).label= g_name{g_index(idx_v)}; % DLC_cell{1,col_xls};
                variations(end).g_value= v_combo(find(g_index==g_index(idx_v), 1), i_DLC);
                variations(end).group1st= group1st(idx_v);
            else
                variations(end).group1st= false;
            end
        end
    end 
end
