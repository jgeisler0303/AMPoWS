%READ_CONFIG Loads the DLC_List sheet as a cell array (DLC_cell). 
%   Saves required path configurations in the config structure.
%   Loads the template input files into the templates structure
%
% Copyright (c) 2021 Hannah Dentzien, Ove Hagge Ellhöft
% Copyright (c) 2022 Jens Geisler

function [DLC_cell, config, templates] = read_config(xls_name)
%% load configuration and template-files

if ~exist('xls_name', 'var') || isempty(xls_name)
    xls_name= 'openFAST_config.xlsx';
end


DLC_cell = readcell(xls_name,'Sheet','DLC_List');

% load template files 
config_cell=readcell(xls_name,'Sheet','config'); % path to files from Excel-sheet

config.sim_path=config_cell{10,2}; % location of simulation directory
config.wind_path=config_cell{11,2}; % location of wind directory
if ismissing(config.wind_path)
    config.wind_path= '';
end

config.maininput_path = config_cell{2,2};
% TODO: remove sub file paths from config altogether
config.elastodyn_path = getSubFile(config_cell{3,2}, 'EDFile', config.maininput_path);
config.servodyn_path = getSubFile(config_cell{4,2}, 'ServoFile', config.maininput_path);
config.aerodyn_path = getSubFile(config_cell{5,2}, 'AeroFile', config.maininput_path);
config.inflowwind_path = getSubFile(config_cell{6,2}, 'InflowFile', config.maininput_path);
try
    config.substruct_path = getSubFile('', 'SubFile', config.maininput_path);
catch
    config.substruct_path = '';
end

config.turbsim_path = config_cell{7,2} ;
config.uni_wind_path = config_cell{8,2};

config.CutinWind= config_cell{13,2};
config.RatedWind= config_cell{14,2};
config.CutoutWind= config_cell{15,2};
config.OpenFAST= config_cell{18,2};
if isempty(config.OpenFAST)
    config.OpenFAST= 'openfast';
end
config.turbsim= config_cell{19,2};
if isempty(config.turbsim)
    config.turbsim= 'turbsim';
end

try
    config.wind0= config_cell{21,2};
    if ~ismissing(config.wind0)
        config.wind0= str2num(config.wind0);
    else
        config.wind0= [];
    end
catch
    config.wind0= [];
end

try
    config.theta0= config_cell{22,2};
    if ~ismissing(config.theta0)
        config.theta0= str2num(config.theta0);
    else
        config.theta0= [];
    end
catch
    config.theta0= [];
end

try
    config.omega0= config_cell{23,2};
    if ~ismissing(config.omega0)
        config.omega0= str2num(config.omega0);
    else
        config.omega0= [];
    end
catch
    config.omega0= [];
end

try
    config.tow_fa0= config_cell{24,2};
    if ~ismissing(config.tow_fa0)
        config.tow_fa0= str2num(config.tow_fa0);
    else
        config.tow_fa0= [];
    end
catch
    config.tow_fa0= [];
end

[idx, DLC_cell] = find_label_or_create(DLC_cell, '{CutinWind}', false);
[DLC_cell{2:end, idx}] = deal(config.CutinWind);
[idx, DLC_cell] = find_label_or_create(DLC_cell, '{RatedWind}', false);
[DLC_cell{2:end, idx}] = deal(config.RatedWind);
[idx, DLC_cell] = find_label_or_create(DLC_cell, '{CutoutWind}', false);
[DLC_cell{2:end, idx}] = deal(config.CutoutWind);

config.OutSensors= config_cell{17,2};

% generate wind template structures

if isempty(config_cell{7,2}) || (isstring(config_cell{7,2}) && ismissing(config_cell{7,2}))
    templates.turbsim= [];
else
    templates.turbsim = FAST2Matlab(config_cell{7,2});
end

% load templates of FAST- Inputfiles
templates.elastodyn = FAST2Matlab(config.elastodyn_path);
templates.elastodyn= readOutSensors(templates.elastodyn, config.OutSensors, 'ElastoDyn');
templates.servodyn = FAST2Matlab(config.servodyn_path);
templates.servodyn= readOutSensors(templates.servodyn, config.OutSensors, 'ServoDyn');
templates.aerodyn = FAST2Matlab(config.aerodyn_path);
templates.aerodyn= readOutSensors(templates.aerodyn, config.OutSensors, 'AeroDyn');
templates.inflowwind = FAST2Matlab(config.inflowwind_path);
templates.inflowwind= readOutSensors(templates.inflowwind, config.OutSensors, 'InflowWind');
if ~isempty(config.substruct_path)
    templates.substruct= FAST2Matlab(config.substruct_path);
    templates.substruct= readOutSensors(templates.substruct, config.OutSensors, ''); % unfortunately it is not clear where the sensors are in the OutListParameters-file
end

% maininput must be last because it depends on the others
templates.maininput = FAST2Matlab(config.maininput_path);

% add some turbine geometry to the configuration
[idx, DLC_cell] = find_label_or_create(DLC_cell, '{D_Rotor}', false);
[DLC_cell{2:end, idx}] = deal(num2str(2*GetFASTPar(templates.elastodyn, 'TipRad')));

[idx, DLC_cell] = find_label_or_create(DLC_cell, '{Hub_Height}', false);
Hub_Height= GetFASTPar(templates.elastodyn, 'TowerHt') + GetFASTPar(templates.elastodyn, 'TowerBsHt') + GetFASTPar(templates.elastodyn, 'Twr2Shft') + sind(GetFASTPar(templates.elastodyn, 'ShftTilt'))*GetFASTPar(templates.elastodyn, 'OverHang');
[DLC_cell{2:end, idx}] = deal(num2str(Hub_Height));

function template= readOutSensors(template, list, module)
if exist(list, 'file') && ~isempty(module)
    OutSensors_cell = readcell(list , 'Sheet', module);
    idx= strcmpi(OutSensors_cell(:, 1), 'x');
    template.OutList= {strcat('"', OutSensors_cell(idx, 2), '"')};
    template.OutListComments=  {strcat({'- '} , OutSensors_cell(idx, 4))};
end

function sf= getSubFile(config, label, fast_template)
sf= config;
if isempty(sf) || ismissing(sf)
    FP = FAST2Matlab(fast_template);
    [~, sf]= GetFASTPar_Subfile(FP, label, fileparts(fast_template));
end
