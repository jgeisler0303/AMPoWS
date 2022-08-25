function writefile_BTS(FileName, desc, velocity, twrVelocity, dz, dy, dt, zHub, z1, mffws, fileFmt)
% Input:
%  FileName      - string: contains file name (.bts extension) to open
%  desc          - string: description of the file contents
%  velocity      - 4-D array: time, velocity component (1=U, 2=V, 3=W), iy, iz 
%  twrVelocity   - 3-D array: time, velocity component, iz
%  dz, dy, dt    - scalars: distance between two points in the vertical
%                  [m], horizontal [m], and time [s] dimensions
%  zHub          - scalar: hub height [m]
%  z1            - scalar: vertical location of bottom of grid [m above ground level]
%  mffws         - scalar: mean hub-height wind speed
%  fileFmt       - string: optional, contains format of grid points.

if ~exist('fileFmt', 'var')
    fileFmt = 'int16';
end
nffc = 3;
nt= size(velocity, 1);
ny= size(velocity, 3);
nz= size(velocity, 4);
ntwr= size(twrVelocity, 3);

Voffset = zeros(3, 1);
Vslope  = ones(3, 1);
if strcmpi(fileFmt, 'float32')
    v= velocity;
    vt= twrVelocity;
else
    v= zeros(nt, nffc, ny, nz, fileFmt);
    vt= zeros(nt, nffc, ntwr, fileFmt);
    for k=1:nffc
        data_min= min( [min(min(min(velocity(:, k, :, :)))) min(min(twrVelocity(:, k, :)))] );
        range= max( [max(max(max(velocity(:, k, :, :)))) max(max(twrVelocity(:, k, :)))] ) - data_min;
        if range==0
            range= 1;
        end
        Vslope(k)= 32000 / (range/2);
        Voffset(k)= -(data_min + range/2) * Vslope(k);

        v(:, k, :, :)= velocity(:, k, :, :)*Vslope(k) + Voffset(k);
        vt(:, k, :)= twrVelocity(:, k, :)*Vslope(k) + Voffset(k);        
    end
end

fid= fopen(FileName, 'w');

if fid > 0
    %----------------------------        
    % write the header information
    %----------------------------
    
    fwrite( fid, 7, 'int16');           % TurbSim format identifier (should = 7 or 8 if periodic), INT(2)

    fwrite( fid, nz, 'int32');          % the number of grid points vertically, INT(4)
    fwrite( fid, ny, 'int32');          % the number of grid points laterally, INT(4)
    fwrite( fid, ntwr, 'int32');        % the number of tower points, INT(4)
    fwrite( fid, nt, 'int32');          % the number of time steps, INT(4)

    fwrite( fid, dz, 'float32');        % grid spacing in vertical direction, REAL(4), in m
    fwrite( fid, dy, 'float32');        % grid spacing in lateral direction, REAL(4), in m
    fwrite( fid, dt, 'float32');        % grid spacing in delta time, REAL(4), in m/s
    fwrite( fid, mffws, 'float32');     % the mean wind speed at hub height, REAL(4), in m/s
    fwrite( fid, zHub, 'float32');      % height of the hub, REAL(4), in m
    fwrite( fid, z1, 'float32');        % height of the bottom of the grid, REAL(4), in m

    fwrite( fid, Vslope(1), 'float32'); % the U-component slope for scaling, REAL(4)
    fwrite( fid, Voffset(1), 'float32');% the U-component offset for scaling, REAL(4)
    fwrite( fid, Vslope(2), 'float32'); % the V-component slope for scaling, REAL(4)
    fwrite( fid, Voffset(2), 'float32');% the V-component offset for scaling, REAL(4)
    fwrite( fid, Vslope(3), 'float32'); % the W-component slope for scaling, REAL(4)
    fwrite( fid, Voffset(3), 'float32');% the W-component offset for scaling, REAL(4)

    % Write the description string
    if length(desc)>200
        desc= desc(1:200);
    end
    fwrite( fid, length(desc), 'int32');     % the number of characters in the description string, max 200, INT(4)
    fwrite( fid, uint8(desc), 'int8' ); % the ASCII integer representation of the character string


    %-------------------------        
    % write the grid information
    %-------------------------

    nPts        = ny*nz;
    nv          = nffc*nPts;               % the size of one time step
    nvTwr       = nffc*ntwr;
    
    for it = 1:nt
        %--------------------
        %write the grid points
        %--------------------
        v_= repmat(permute(v(it, :, :, :), [2, 3, 4, 1]), nv, 1);
        fwrite( fid, v_, fileFmt ); % write the velocity components for one time step

        %---------------------
        %write the tower points
        %---------------------
        if nvTwr > 0
            v_= repmat(permute(vt(it, :, :), [2, 3, 1]), nvTwr, 1);
            fwrite( fid, v_, fileFmt ); % write the velocity components for the tower
        end
    end %it

    fclose(fid);
else
    error(['Could not write the wind file: ' FileName]) ;
end