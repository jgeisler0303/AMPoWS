
% Copyright (c) 2021 Jens Geisler

function variations= joinVariations(sim, fields)

variations= struct('label', {}, 'value', {}, 'multi', {}, 'group1st', {});

for i= 1:length(fields)
    if ~isfield(sim, fields{i}) || isempty(sim.(fields{i})), continue, end
        
    for j= 1:length(sim.(fields{i}).variations)
        if ~any(strcmp({variations.label}, sim.(fields{i}).variations(j).label))
            variations(end+1).label= sim.(fields{i}).variations(j).label;
            variations(end).value= sim.(fields{i}).variations(j).value;
            variations(end).multi= sim.(fields{i}).variations(j).multi;
            variations(end).group1st= sim.(fields{i}).variations(j).group1st;
        end
    end
end
