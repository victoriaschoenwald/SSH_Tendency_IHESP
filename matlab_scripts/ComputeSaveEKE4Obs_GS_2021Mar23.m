%% ===readme===

% descrip: matlab script computes and saves eddy kinetic energy (EKE) 
% with obs data in the Gulf Stream Extension for reviewer's comments

% update history:
% v1.0 DL 2021Mar24

% extra notes:
% =============


%% === set up environments ===
clear all;close all;clc;

  date_str='2021Mar23'; 

% --- boreal summer: Apr-Sep ---
indir = ['/agartha1/dapengli/Project_EkmanPumping_CESM_2019Sep27/raw_data/', ...
    'CMEMS_2021Mar24/SEALEVEL_GLO_PHY_L4_REP_OBSERVATIONS_008_047/', ...
    'dataset_duacs_rep_global_merged_allsat_phy_l4/1993_1996/Apr_Sep/'];
infile0 = [indir 'dt_global_allsat_phy_l4_19930401_20190101_2023Mar24.nc'];
infile = [indir 'dt_global_allsat_phy_l4_1993_1996_Apr_Sep_2021Mar25.nc'];
outfile = ['../data_after_manipulation/EKE4ObsGS_AprSepAv_',date_str,'.mat'];
% -----------------------------------------

% % --- boreal winter: Oct-Mar ---
% indir = ['/agartha1/dapengli/Project_EkmanPumping_CESM_2019Sep27/raw_data/', ...
%     'CMEMS_2021Mar24/SEALEVEL_GLO_PHY_L4_REP_OBSERVATIONS_008_047/', ...
%     'dataset_duacs_rep_global_merged_allsat_phy_l4/1993_1996/Oct_Mar/'];
% infile0 = [indir 'dt_global_allsat_phy_l4_19930101_20190101_2023Mar24.nc'];
% infile = [indir 'dt_global_allsat_phy_l4_1993_1996_Oct_Mar_2021Mar25.nc'];
% outfile = ['../data_after_manipulation/EKE4ObsGS_OctMarAv_',date_str,'.mat'];
% % ---------------------------------------

ncdisp(infile)

% ### Gulf Stream (GS) ###
% lon, lat limits for contour plots
  lat_limits = [27 45]; 
  lat_ticks = [30:5:45];
  lon_limits = [275 340];
  lon_ticks = [280:20:340];   
% ########################

addpath(genpath('Func4EkmanProject/'))
header = ['This file was generated by DL via code ComputeSaveEKE4ObsGS_',date_str,'.m'];
%=============================


%% === load data ===
lat=ncread(infile0,'latitude');
lon=ncread(infile0,'longitude');
% ssh_av = ncread(infile_av,'adt');
% ugos_av = ncread(infile_av,'ugos');
% vgos_av = ncread(infile_av,'vgos');

ssh = ncread(infile,'adt');
% time = ncread(infile,'time');
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

% === convert lat and lon to x and y ===
[x_r,y_r] = ConvertLonLat2XY4UnevenGridsFunc(lon_r,lat_r);
% [Ug_av,Vg_av] = CalcGeostrophyVel4UnevenGridsFunc( ...
%        ssh_av_r',x_r,y_r,lat_r); 
   
for iday = 1 : size(ssh_r,3) % loop through time   
   iday
   [Ug(:,:,iday),Vg(:,:,iday)] = CalcGeostrophyVel4UnevenGridsFunc( ...
       ssh_r(:,:,iday)',x_r,y_r,lat_r); 
end
% ===================

Ug_av=mean(Ug,3);
Vg_av=mean(Vg,3);
Uga=Ug-repmat(Ug_av,[1 1 size(Ug,3)]);
Vga=Vg-repmat(Vg_av,[1 1 size(Ug,3)]);
EKE=(Uga.^2+Vga.^2)./2;
EKE_TimeAv = mean(EKE,3);

figure;pcolor(EKE_TimeAv*1e4);caxis([0 3000]);shading interp;colorbar;
% ================


%% === output data ===
save(outfile,'header','lon_r','lat_r','EKE','EKE_TimeAv')
% ====================
