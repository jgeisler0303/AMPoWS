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
config.iecwind_path = config_cell{8,2};

% load templates of FAST- Inputfiles
templates.elastodyn = FAST2Matlab(config_cell{3,2});
templates.servodyn = FAST2Matlab(config_cell{4,2});
templates.aerodyn = FAST2Matlab(config_cell{5,2});

% generate wind template structures
templates.turbsim = FAST2Matlab(config_cell{7,2});
templates.iecwind = gen_iec_template;

% load templates of FAST- Inputfiles
templates.inflowwind = FAST2Matlab(config_cell{6,2});
templates.maininput = FAST2Matlab(config_cell{2,2});