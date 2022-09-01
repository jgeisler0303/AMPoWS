# AMPoWS

This set of _Matlab_ code is developed to simplify the simulation of different scenarios with NREL's opensource turbine-simulation-tool _OpenFAST_. The current version is developed to work with _OpenFAST_ v2.5.0.



# How to install
1. Install the current _OpenFAST_-version (including _TurbSim_) as described in  https://openfast.readthedocs.io/en/master/source/install/#
1. Install the NREL _IECwind_ module. This module is currently not available in the NREL repository but can be downloaded here: https://github.com/BecMax/IECWind . Compile the Fortran source code and name the generated binary "iecwind". You have to compile! The executable programs in the repository are not up to date!
1. Add the executables to the PATH-variable of your system to make them executable from anywhere.
1. Install the OpenFAST-Matlab-Toolbox which is available here: https://github.com/OpenFAST/matlab-toolbox and add the toolbox to your _Matlab_-PATH. Add the "iecwind" executable to the _Matlab_-Path as well.


# How to use

The examples folder of this repository is providing some examples that can be used to generate simulation scenarios using AMPoWS. The _open_FAST_config.xlsx_ sheet is where those scenarios will be defined and the template-input-files will be referred. This sheet has to be placed in the _Matlab_ directory. By running the _Matlab_ script _openFAST_preprocessor.m_ the simulation scenarios in  _open_FAST_config.xlsx_ will be created.

