function [idx,dlc_cell] = find_label_or_create(dlc_cell,label,find_only)
%FIND_LABEL_OR_CREATE Searches for a specific label in the table and optionally creates it if it
%does not exist. The function returns the customised table as well as the
%name of the label searched for.
%
%dlc_cell: read-in configuration table
%label: label that is searched for / is added
%find_only : if true label is only searched and not added to table


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