function [dlc_cell,idx] = find_label_or_create(dlc_cell,label)

        % search for label
       idx = find(strcmp(dlc_cell(1,:),{label})==1) ;
       
       % if it does'nt exist
       if isempty(idx)
        % create additional column with  label
        dlc_cell{1,end+1} = label ;
        idx = length(dlc_cell) ;
       end