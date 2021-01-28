function [idx,dlc_cell] = find_label_or_create(dlc_cell,label,find_only)

        % search for label
       idx = find(strcmp(dlc_cell(1,:),label)) ;
       
       % if it does'nt exist
       if isempty(idx)
           if ~find_only
        % create additional column with  label
            dlc_cell{1,end+1} = label ;
            idx = length(dlc_cell) ;
           else
            warning('Label not found!')
           end    
       end