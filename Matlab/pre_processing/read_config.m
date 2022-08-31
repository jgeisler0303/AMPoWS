%READ_CONFIG Loads the DLC_List sheet as a cell array (DLC_cell). 
%   Saves required path configurations in the config structure.
%   Loads the template input files into the templates structure
%
% Copyright (c) 2021 Hannah Dentzien, Ove Hagge Ellhöft
% Copyright (c) 2022 Jens Geisler

function [DLC_cell,config,templates] = read_config(xls_name)
%% load configuration and template-files

if ~exist('xls_name', 'var') || isempty(xls_name)
    xls_name= 'openFAST_config.xlsx';
end


DLC_cell = readcell(xls_name,'Sheet','DLC_List');

% load template files 
config_cell=readcell(xls_name,'Sheet','config'); % path to files from Excel-sheet

config.sim_path=config_cell{10,2}; % location of simulation directory
config.wind_path=config_cell{11,2}; % location of wind directory

config.maininput_path = config_cell{2,2} ;
config.elastodyn_path = config_cell{3,2};
config.servodyn_path = config_cell{4,2} ;
config.aerodyn_path = config_cell{5,2} ;
config.inflowwind_path = config_cell{6,2} ;
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


[idx, DLC_cell] = find_label_or_create(DLC_cell, '{CutinWind}', false);
[DLC_cell{2:end, idx}] = deal(config.CutinWind);
[idx, DLC_cell] = find_label_or_create(DLC_cell, '{RatedWind}', false);
[DLC_cell{2:end, idx}] = deal(config.RatedWind);
[idx, DLC_cell] = find_label_or_create(DLC_cell, '{CutoutWind}', false);
[DLC_cell{2:end, idx}] = deal(config.CutoutWind);

% load templates of FAST- Inputfiles
templates.elastodyn = FAST2Matlab(config_cell{3,2});
templates.elastodyn= readOutSensors(templates.elastodyn, config_cell{17,2}, 'ElastoDyn');

templates.servodyn = FAST2Matlab(config_cell{4,2});
templates.servodyn= readOutSensors(templates.servodyn, config_cell{17,2}, 'ServoDyn');
templates.aerodyn = FAST2Matlab(config_cell{5,2});
templates.aerodyn= readOutSensors(templates.aerodyn, config_cell{17,2}, 'AeroDyn');

% generate wind template structures
templates.turbsim = FAST2Matlab(config_cell{7,2});

% load templates of FAST- Inputfiles
templates.inflowwind = FAST2Matlab(config_cell{6,2});
templates.inflowwind= readOutSensors(templates.inflowwind, config_cell{17,2}, 'InflowWind');
templates.maininput = FAST2Matlab(config_cell{2,2});

% add some turbine geometry to the configuration
[idx, DLC_cell] = find_label_or_create(DLC_cell, '{D_Rotor}', false);
[DLC_cell{2:end, idx}] = deal(num2str(2*GetFASTPar(templates.elastodyn, 'TipRad')));

[idx, DLC_cell] = find_label_or_create(DLC_cell, '{Hub_Height}', false);
Hub_Height= GetFASTPar(templates.elastodyn, 'TowerHt') + GetFASTPar(templates.elastodyn, 'TowerBsHt') + GetFASTPar(templates.elastodyn, 'Twr2Shft') + sind(GetFASTPar(templates.elastodyn, 'ShftTilt'))*GetFASTPar(templates.elastodyn, 'OverHang');
[DLC_cell{2:end, idx}] = deal(num2str(Hub_Height));

function template= readOutSensors(template, list, module)
if exist(list, 'file')
    OutSensors_cell = readcell(list , 'Sheet', module);
    idx= strcmpi(OutSensors_cell(:, 1), 'x');
    template.OutList= {strcat('"', OutSensors_cell(idx, 2), '"')};
    template.OutListComments=  {strcat({'- '} , OutSensors_cell(idx, 4))};
end
