function [v_combo, v_index] = generate_vector_combinations(DLC_cell, row_xls, col_start, config)
%GENERATE_VECTOR_COMBINATIONS Generates a matrix (v_combo) with all
%possible combinations of the simulation parameters entered as a vector. In
%addition the associated column index for each vector entry is stored in
%v_index.

%% Identify all vectors in row & save all possible combinations

v_combo = [1];        % intialize vector combination matrix to use allcombos function
v_index = [];         % storage for column indices of vectors in DLC_cell
struct_id = struct(); % storage for vectors with identifiers

% allow to define Vektor with respect to reference wind conditions
v_i= config.CutinWind;
v_r= config.RatedWind;
v_o= config.CutoutWind;

% loop over each "non-basic" column
for col_xls = col_start:size(DLC_cell,2)

    % create all combinations of vectors WITHOUT indentifiers
    try  
        e = eval(DLC_cell{row_xls,col_xls}); % read vector from char
        if isvector(e) && numel(e)>1      % check if element is vector with more than one element
            v_combo = allcombos(v_combo,e); % combination of vectors
            v_index = [v_index, col_xls]; % save row number of rows with vector
        end
    catch
        % process vectors only; try next column
    end

    % special treatment for IEC wind conditions: a list of conditions
    % separated by colons
    if strcmp(DLC_cell{1, col_xls}, '{IEC-condition}')
        n_iec= sum(DLC_cell{row_xls, col_xls}==':')+1;
        if n_iec>1
            v_combo = allcombos(v_combo, 1:n_iec); % combination of vectors
            v_index = [v_index, col_xls]; % save row number of rows with vector            
        end
    end

    % sort all vectors WITH identifiers by used identifier
    if ischar(DLC_cell{row_xls,col_xls}) && contains(DLC_cell{row_xls,col_xls},'<') % check if identifier is used
        split = strsplit(DLC_cell{row_xls,col_xls},'>'); % split element into identifier and vector
        ident_name = strip(split{1},'left','<');         % save name of used identifier

        if isfield(struct_id,ident_name)   % check if identifier has already been used

            if length(struct_id.(ident_name))-1 == length(eval(split{2})) % vectors with identifiers have to be of same legth
                struct_id.(ident_name)(end+1, :) = [col_xls, eval(split{2})]; % add vector to exsisting identifier; save column of vector as first element in each row of struct
            else 
                error('DLC %s: Dimensions of vectors with identifier <%s> are not consistent.\n', DLC_cell{row_xls,1},ident_name);
            end

        else
            struct_id.(ident_name) = [col_xls, eval(split{2})]; % create new field with identifier
        end
    end

end

% create combinations of ALL vectors 
ids = fieldnames(struct_id);   % check if struct contains identifiers 
for idx = 1:length(ids)
   v_combo = allcombos(v_combo, struct_id.(ids{idx})(:,2:end));    % combine identifier-vectors with other vectors
   v_index = [v_index, (struct_id.(ids{idx})(:,1))'];            % save columns of identifier-vectors
end

v_combo = v_combo(2:end,:);    % erase initial value of v_combo
