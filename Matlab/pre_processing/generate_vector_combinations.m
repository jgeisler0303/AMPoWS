%GENERATE_VECTOR_COMBINATIONS Generates a matrix (v_combo) with all
%   possible combinations of the simulation parameters entered as a vector. In
%   addition the associated column index for each vector entry is stored in
%   v_index.
%
% Copyright (c) 2021 Hannah Dentzien, Ove Hagge Ellhöft
% Copyright (c) 2021 Jens Geisler

function [DLC_cell, v_combo, v_index, g_index, g_name, gv_index] = generate_vector_combinations(DLC_cell, row_xls, col_start, config)
%% Identify all vectors in row & save all possible combinations

v_combo = [1];        % intialize vector combination matrix to use allcombos function
v_index = [];         % storage for column indices of vectors in DLC_cell
g_index = 0;         % variation group number
g_name  = {};
gv_index= [];
struct_id = struct(); % storage for vectors with identifiers
Uref_group= [];

% allow to define Vektor with respect to reference wind conditions
v_i= str2double(config.CutinWind);
v_r= str2double(config.RatedWind);
v_o= str2double(config.CutoutWind);

% loop over each "non-basic" column
for col_xls = col_start:size(DLC_cell,2)
    if strcmp(DLC_cell{row_xls,col_xls}, 'v_i')
        DLC_cell{row_xls,col_xls}= v_i;
    elseif strcmp(DLC_cell{row_xls,col_xls}, 'v_r')
        DLC_cell{row_xls,col_xls}= v_r;
    elseif strcmp(DLC_cell{row_xls,col_xls}, 'v_o')
        DLC_cell{row_xls,col_xls}= v_o;
    end
    
    if strcmpi(DLC_cell{1,col_xls}, 'Uref')
        Uref_col= col_xls;
    end

    % create all combinations of vectors WITHOUT indentifiers
    try  
        e = eval(DLC_cell{row_xls,col_xls}); % read vector from char
        if isvector(e) && numel(e)>1      % check if element is vector with more than one element
            v_index = [v_index, col_xls]; % save row number of rows with vector
            g_index(end+1)= g_index(end) + 1;
            g_name{end+1}= DLC_cell{1, col_xls};
            gv_index(end+1)= size(v_combo, 1);

            v_combo = allcombos(v_combo, e); % combination of vectors

            if strcmpi(DLC_cell{1, col_xls}, 'Uref')
                Uref_group= g_index(end);
            end
        end
    catch
        % process vectors only; try next column
    end

    % special treatment for uni wind conditions: a list of conditions
    % separated by colons
    if strcmp(DLC_cell{1, col_xls}, '{uni-wind-param}')
        n_iec= sum(DLC_cell{row_xls, col_xls}==':')+1;
        if n_iec>1
            v_index = [v_index, col_xls]; % save row number of rows with vector            
            g_index(end+1)= g_index(end) + 1;
            g_name{end+1}= 'UniWind';
            gv_index(end+1)= size(v_combo, 1);

            v_combo = allcombos(v_combo, 1:n_iec); % combination of vectors
        end
    end

    % sort all vectors WITH identifiers by used identifier
    if ischar(DLC_cell{row_xls, col_xls}) && contains(DLC_cell{row_xls, col_xls}, '<') % check if identifier is used
        split= strsplit(DLC_cell{row_xls, col_xls}, '>'); % split element into identifier and vector
        ident_name= strip(split{1}, 'left', '<');         % save name of used identifier
        if ident_name(1)=='!'
            lead_group= true;
            ident_name= ident_name(2:end);
        else
            lead_group= false;
        end

        if isfield(struct_id, ident_name)   % check if identifier has already been used

            if size(struct_id.(ident_name).values, 2) == length(eval(split{2})) % vectors with identifiers have to be of same legth
                struct_id.(ident_name).values(end+1, :) = eval(split{2}); % add vector to exsisting identifier
                struct_id.(ident_name).col_idx(end+1)= col_xls;
                if lead_group
                    struct_id.(ident_name).lead_idx= size(struct_id.(ident_name).values, 1);
                end
            else 
                error('DLC %s: Dimensions of vectors with identifier <%s> are not consistent.\n', DLC_cell{row_xls,1}, ident_name);
            end

        else
            struct_id.(ident_name).values= eval(split{2}); % create new field with identifier
            struct_id.(ident_name).col_idx= col_xls;
            struct_id.(ident_name).lead_idx= 1;
        end
    end

end

% create combinations of ALL vectors 
ids = fieldnames(struct_id);   % check if struct contains identifiers 
for idx = 1:length(ids)
    groups= struct_id.(ids{idx}).col_idx;
    gv_index= [gv_index, (struct_id.(ident_name).lead_idx+size(v_combo, 1)-1)*ones(size(groups))];
    v_index = [v_index, groups];            % save columns of identifier-vectors
    g_index = [g_index, (g_index(end)+1)*ones(size(groups))];
    g_name{end+1}= ids{idx};

    v_combo = allcombos(v_combo, struct_id.(ids{idx}).values);  % combine identifier-vectors with other vectors

    for g_element= 1:length(groups)
        if strcmpi(DLC_cell{1, groups(g_element)}, 'Uref')
            Uref_group= g_index(end);
        end 
    end
end

v_combo = v_combo(2:end,:);    % erase initial value of v_combo
g_index = g_index(2:end);

% add initial conditions depending on Uref
for col_xls = col_start:size(DLC_cell,2)
    if any(strcmp(DLC_cell{row_xls, col_xls}, {'theta0' 'omega0' 'tow_fa0'}))
        if isempty(Uref_group)
            if isempty(config.wind0) || isempty(config.(DLC_cell{row_xls, col_xls})) || isempty(asdouble(DLC_cell{row_xls, Uref_col}))
                DLC_cell{row_xls, col_xls}= '0';
            else
                DLC_cell{row_xls, col_xls}= interp1(config.wind0, config.(DLC_cell{1, col_xls}), asdouble(DLC_cell{row_xls, Uref_col}));
            end
        else
            v_combo(end+1, :)= interp1(config.wind0, config.(DLC_cell{row_xls, col_xls}), v_combo(Uref_group, :));
            v_index(end+1)= col_xls;
            g_index(end+1)= Uref_group;
            gv_index(end+1)= gv_index(find(g_index==Uref_group, 1));
        end
    end
end