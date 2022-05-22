%% === readme ===

% descrip: plot to check CESM SSH

% update history:
% v1.0 DL 2020Jan01 

% extra notes:
% CESM SSH = sea level anomaly + mean dynamical topography (MDT)
% positive SSH in tropics and mid latitudes and negative SSH in high
% latitudes result from positive MDT in tropics and mid latitude and negative
% MDT in high latitude. See Fig 3 from from Rio and Hernandez 2004 A mean 
% dynamic topography computed over the world ocean from altimetry, 
% in situ measurements, and a geoid model.
% =============

%%
clear all;close all;clc;

infile_obs=['/scratch/user/dapengli/Projects4iHESP/Project_SeaLevelUSEastCoast_2021Mar30/raw_data/', ...
    'CMEMS_2021Apr03/dt_global_allsat_msla_h_199301-201912_2023Mar24.nc'];
indir_sunway = '/scratch/group/ihesp/archive/Sunway_Runs/';

addpath(genpath('Func4SeaLevelProject/'))

lat_NA_limits = [10 75];
lon_NA_limits = [260 360];

%%
ncdisp(infile_obs)
time_raw_obs = double(ncread(infile_obs,'time'));
jultime_raw_obs = datenum(1950,1,1) + time_raw_obs;
jultime_vec_raw_obs = datevec(jultime_raw_obs);

lat_raw_obs = double(ncread(infile_obs,'latitude'));
lon_raw_obs = double(ncread(infile_obs,'longitude'));
indxLat_NA_obs = find(lat_raw_obs>lat_NA_limits(1) & lat_raw_obs<lat_NA_limits(2));
indxLon_NA_obs = find(lon_raw_obs>lon_NA_limits(1) & lon_raw_obs<lon_NA_limits(2));
lat_NA_obs = lat_raw_obs(indxLat_NA_obs);
lon_NA_obs = lon_raw_obs(indxLon_NA_obs);

% sla_raw_obs = ncread(infile_obs,'sla');
start_obs=[indxLon_NA_obs(1) indxLat_NA_obs(1) 1];
count_obs=[length(indxLon_NA_obs) length(indxLat_NA_obs) length(time_raw_obs)];
stride=[1 1 1];
sla_NA_obs = double(ncread(infile_obs, 'sla', start_obs, count_obs, stride)*100);

[eof_maps,pc,expv,jultime_yr_obs,sla_NA_yr_obs] = WrapFunc4EOF(jultime_raw_obs,sla_NA_obs);
figure;pcolor(eof_maps(:,:,2)');shading interp;colorbar;polarmap;

figure
plot(pc(1,:),'r');hold on;plot(pc(2,:),'b');datetick('x','mm/yyyy')
%%
infile_SH=[indir_sunway 'HR_HF_TNST/B.E.13.BTRANS.ne120_t12.sehires38.003.sunway.pop.h.SSH.1850.2050.nc'];
ncdisp(infile_SH)
time_raw_SH = double(ncread(infile_SH,'time'));datevec(time_raw_SH+365);
jultime_raw_SH = datenum(1,1,1) + time_raw_SH;
jultime_vec_raw_SH = datevec(jultime_raw_SH);

% lat_raw_obs = double(ncread(infile_obs,'latitude'));
% lon_raw_obs = double(ncread(infile_obs,'longitude'));
% indxLat_NA_obs = find(lat_raw_obs>lat_NA_limits(1) & lat_raw_obs<lat_NA_limits(2));
% indxLon_NA_obs = find(lon_raw_obs>lon_NA_limits(1) & lon_raw_obs<lon_NA_limits(2));
% lat_NA_obs = lat_raw_obs(indxLat_NA_obs);
% lon_NA_obs = lon_raw_obs(indxLon_NA_obs);

% sla_raw_obs = ncread(infile_obs,'sla');
start_SH=[50 1300 1];
count_SH=[1100 900 201];
stride=[1 1 1];
% a = ncread(infile_SH, 'SSH',[1,1,1],[3600,2400,1],[1,1,1]);
ssh_NA_SH = double(ncread(infile_SH, 'SSH', start_SH, count_SH, stride));
ssh_NA_yra_SH = ssh_NA_SH - mean(ssh_NA_SH,3);
figure;pcolor(ssh_NA_yra_SH(:,:,1)');shading interp;colorbar;
[eof_maps,pc,expv] = eof(ssh_NA_yra_SH);
figure;pcolor(eof_maps(:,:,1)');shading interp;colorbar;polarmap;

figure
plot(pc(1,:),'r');hold on;plot(pc(2,:),'b');datetick('x','mm/yyyy')


%%
infile_SL = [indir_sunway 'LR_HF_TNST/B.E.13.BTRANS.ne30g16.sehires38.003.sunway.pop.h.SSH.185001.210012.nc']
ncdisp(infile_SL)
time_raw_SL = double(ncread(infile_SL,'time'));datevec(time_raw_SL);
jultime_raw_SL = datenum(1,1,1) + time_raw_SL;
jultime_vec_raw_SL = datevec(jultime_raw_SL);

% lat_raw_obs = double(ncread(infile_obs,'latitude'));
% lon_raw_obs = double(ncread(infile_obs,'longitude'));
% indxLat_NA_obs = find(lat_raw_obs>lat_NA_limits(1) & lat_raw_obs<lat_NA_limits(2));
% indxLon_NA_obs = find(lon_raw_obs>lon_NA_limits(1) & lon_raw_obs<lon_NA_limits(2));
% lat_NA_obs = lat_raw_obs(indxLat_NA_obs);
% lon_NA_obs = lon_raw_obs(indxLon_NA_obs);

% sla_raw_obs = ncread(infile_obs,'sla');
start1_SL=[250 250 1];
count1_SL=[71 135 3012];
start2_SL=[1 250 1];
count2_SL=[50 135 3012];
stride=[1 1 1];
% a = ncread(infile_SH, 'SSH',[1,1,1],[3600,2400,1],[1,1,1]);
ssh_SL = double(ncread(infile_SL, 'SSH')); figure;pcolor(ssh_SL(:,:,1)');shading interp
ssh_NA1_SL = double(ncread(infile_SL, 'SSH', start1_SL, count1_SL, stride));
ssh_NA2_SL = double(ncread(infile_SL, 'SSH', start2_SL, count2_SL, stride));
ssh_NA_SL = cat(1,ssh_NA1_SL,ssh_NA2_SL);figure;pcolor(ssh_NA_SL(:,:,1)');shading interp


[eof_maps,pc,expv,jultime_yr_obs,sla_NA_yr_obs] = WrapFunc4EOF(jultime_raw_SL,ssh_NA_SL);

figure;pcolor(eof_maps(:,:,1)');shading interp;colorbar;polarmap;

figure
plot(pc(1,:),'r');hold on;plot(pc(2,:),'b');datetick('x','mm/yyyy')



%%


  
print(f1,'-dpng','../pics/SSH_CESM_1daySnapshot_2021Jan01.png')