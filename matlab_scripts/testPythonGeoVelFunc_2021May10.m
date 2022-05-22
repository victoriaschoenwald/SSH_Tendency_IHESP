%% ===readme===

% descrip: matlab script computes geostrophic vel and compare the results
% with python codes 

% update history:
% v1.0 DL 2021May10

% extra notes:
% =============


%% === set up environments ===
clear all;close all;clc;

infile = ['/scratch/user/dapengli/Projects4iHESP/Project_SeaLevelUSEastCoast_2021Mar30/', ...
    'raw_data/zos_AVISO_L4_199210-201012.nc.nc4'];
pic1 = ['testPythonGeoVelFunc_2021May10.png'];
% -----------------------------------------

ncdisp(infile)

% ### Gulf Stream (GS) ###
% lon, lat limits for contour plots
  lat_limits = [20 65]; 
  lon_limits = [-85 -15]+360; 
% ########################
%=============================


%% === load data ===
lat=ncread(infile,'lat');
lon=ncread(infile,'lon');
% ssh_av = ncread(infile_av,'adt');
% ugos_av = ncread(infile_av,'ugos');
% vgos_av = ncread(infile_av,'vgos');

ssh = ncread(infile,'zos');
time = ncread(infile,'time');
% ntime = numel(time);
%================


%% === data analysis ===
indxLat = find(lat >= lat_limits(1) & lat <= lat_limits(2));
lat_r = lat(indxLat);
indxLon = find(lon >= lon_limits(1) & lon <= lon_limits(2));
lon_r = lon(indxLon);

% ssh_av_r = ssh_av(indxLon,indxLat);
% ugos_av_r = ugos_av(indxLon,indxLat);
% vgos_av_r = vgos_av(indxLon,indxLat);
ssh_r = ssh(indxLon,indxLat,:);


[x_r,y_r] = ConvertLonLat2XY4UnevenGridsFunc(lon_r,lat_r);
iyr=1; 
[Ug,Vg] = CalcGeostrophyVel4UnevenGridsFunc( ...
       ssh_r(:,:,iyr)',x_r,y_r,lat_r); 

spd = sqrt(Ug.^2+Vg.^2);

f1=figure;[c,h]=contourf(lon_r-360,lat_r,spd);set(h,'linestyle','none')
caxis([0 0.5]);shading interp;colorbar;colormap('jet')
% ================


%% === output data ===
print(f1,'-dpng',pic1)
% ====================
