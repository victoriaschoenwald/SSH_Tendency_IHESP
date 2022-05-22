% CESM_SSH_eddy_identification_01.m
%--------------------------------------------------------------------------
% Description: scan Eddy by eddyscan code set
%              
% Input :   lon\lat\ssh\areamap\dates
%           ssh(nlat,nlon,ntime)
% Output:   Eddy plot
%
% Based on: CESM_Eddy_plot.m
% Create on 2019-08-29, by Hengkai Yao, @TAMU College Station,TX,US
%--------------------------------------------------------------------------
clc;clear;close all;
%%
cd ../../01_CESM_data_interpolate/02_Output
load('area_map.mat')
load('dates.mat')
load('lon.mat')
load('lat.mat')
load('ssha.mat')
% [ aceddies ] = scan_single( data, lat, lon, dates(1), 'anticyc', 'v2', area_map,'minimumArea', 38,'isPadding','false');
% [ ceeddies ] = scan_single( data, lat, lon, dates(1), 'cyclonic', 'v2', area_map, 'minimumArea', 38,'isPadding','false');
cd ../../02_CESM_eddy_identification_and_tracking/01_Code/
scan_multi( ssha, lat, lon, dates, 'anticyc', 'v2', area_map,...
    '../../02_CESM_eddy_identification_and_tracking/02_Output',...
    'minimumArea', 38,'isPadding','false' );
scan_multi( ssha, lat, lon, dates, 'cyclonic', 'v2', area_map,...
    '../../02_CESM_eddy_identification_and_tracking/02_Output',...
    'minimumArea', 38,'isPadding','false' );