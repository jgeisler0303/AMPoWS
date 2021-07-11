%ALLCOMBOS generates all possible combinations of the columns of two
%   matrices (a and b)
%
% Copyright (c) 2021 Hannah Dentzien, Ove Hagge Ellhöft
% Copyright (c) 2021 Jens Geisler

function combo = allcombos (a,b)
combo = [];

for i = 1:size(b,2)
    bb = ones(size(b,1),size(a,2)).*b(:,i);
    x = [a; bb];
    combo = [combo, x];     
end
    
end
