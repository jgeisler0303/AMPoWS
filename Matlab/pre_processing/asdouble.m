
% Copyright (c) 2021 Jens Geisler


function d= asdouble(v)
if iscell(v)
    v= v{1};
end
if ischar(v) || isstring(v)
    d= str2double(v);
else
    d= v;
end
