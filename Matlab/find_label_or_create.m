function [idx,dlc_cell] = find_label_or_create(dlc_cell,label,find_only)

% search for label
idx = find(strcmp(dlc_cell(1,:),label)) ;

% if it does'nt exist
if isempty(idx)
    if ~find_only
        % create additional column with  label
        dlc_cell{1,end+1} = label ;
        idx = size(dlc_cell,2) ;
    else
        warning('Label %s not found! \n',label)
    end    
end