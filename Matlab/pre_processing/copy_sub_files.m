
% Copyright (c) 2021 Jens Geisler

function templates= copy_sub_files(templates, config)

templates= copy_sub_file(templates, config, config.sim_path, 'maininput', 'BDBldFile(1)');
templates= copy_sub_file(templates, config, config.sim_path, 'maininput', 'BDBldFile(2)');
templates= copy_sub_file(templates, config, config.sim_path, 'maininput', 'BDBldFile(3)');
templates= copy_sub_file(templates, config, config.sim_path, 'maininput', 'HydroFile');
templates= copy_sub_file(templates, config, config.sim_path, 'maininput', 'SubFile');
templates= copy_sub_file(templates, config, config.sim_path, 'maininput', 'MooringFile');
templates= copy_sub_file(templates, config, config.sim_path, 'maininput', 'IceFile');

templates= copy_sub_file(templates, config, config.sim_path, 'aerodyn', 'AA_InputFile');
templates= copy_sub_file(templates, config, config.sim_path, 'aerodyn', 'OLAFInputFileName');
templates= copy_sub_file(templates, config, config.sim_path, 'aerodyn', 'ADBlFile(1)');
templates= copy_sub_file(templates, config, config.sim_path, 'aerodyn', 'ADBlFile(2)');
templates= copy_sub_file(templates, config, config.sim_path, 'aerodyn', 'ADBlFile(3)');

for i= 1:length(templates.aerodyn.FoilNm)
    src= GetFullFileName(templates.aerodyn.FoilNm{i}, fileparts(config.aerodyn_path));
    templates.aerodyn.FoilNm{i}= copy_file(src, config.sim_path);
    copy_file(strrep(src, '.dat', '_coords.txt'), config.sim_path, true);
end

templates= copy_sub_file(templates, config, config.sim_path, 'elastodyn', 'BldFile(1)');
templates= copy_sub_file(templates, config, config.sim_path, 'elastodyn', 'BldFile(2)');
templates= copy_sub_file(templates, config, config.sim_path, 'elastodyn', 'BldFile(3)');
templates= copy_sub_file(templates, config, config.sim_path, 'elastodyn', 'FurlFile');
templates= copy_sub_file(templates, config, config.sim_path, 'elastodyn', 'TwrFile');

templates= copy_sub_file(templates, config, config.sim_path, 'servodyn', 'DLL_FileName');
templates= copy_sub_file(templates, config, config.sim_path, 'servodyn', 'DLL_InFile');

templates= copy_sub_file(templates, config, config.wind_path, 'turbsim', 'UserFile');
templates= copy_sub_file(templates, config, config.wind_path, 'turbsim', 'ProfileFile');
% templates= copy_sub_file(templates, config, config.wind_path, 'turbsim', 'CTEventFile'); % this is not a file


function templates= copy_sub_file(templates, config, target, template, VarName)
FilePath= GetFASTPar(templates.(template), VarName);
if isempty(FilePath) || any(strcmpi(strrep(FilePath, '"', ''), {'UNUSED', 'UNKNOWN'}))
    QFileName= '"unknown"';
else
    src= GetFullFileName(FilePath, fileparts(config.([template '_path'])));
    QFileName= copy_file(src, target);
end
templates.(template)= SetFASTPar(templates.(template), VarName, QFileName);


function QFileName= copy_file(src, target, optional)
src= strrep(src, '\', filesep);
if exist(src, 'file')
    [~, FileName, Ext]= fileparts(src);
    dst= fullfile(target, [FileName Ext]);
    copyfile(src, dst)
    
    QFileName= ['"' FileName Ext '"'];
else
    if exist('optional', 'var') && optional
        return
    end
    error('Could not find file %s to copy to the destination %s', src, target)
end
