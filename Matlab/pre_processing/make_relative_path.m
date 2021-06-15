function rp= make_relative_path(p1, p2)

p1= char(p1);
p2= char(p2);

% make path absolute
old_dir= cd(p1);
p1= cd(old_dir);
p1= [p1 filesep];

old_dir= cd(p2);
p2= cd(old_dir);
p2= [p2 filesep];

last_filesep= 1;
for i= 1:min(length(p1), length(p2))
    if p1(i)~=p2(i)
        break;
    end
    if p2(i)==filesep
        last_filesep= i;
    end
end

if last_filesep==1
    rp= p2;
    return
end
if length(p1)==length(p2) && last_filesep==length(p2)
    rp= ['.' filesep];
    return
end

extra_dirs= sum(p1(last_filesep:end)==filesep)-1;
if extra_dirs==0
    rp= p2(last_filesep+1:end);
else
    down_path= repmat([filesep '..'], 1, extra_dirs);
    rp= [down_path(2:end) p2(last_filesep:end)];
end


