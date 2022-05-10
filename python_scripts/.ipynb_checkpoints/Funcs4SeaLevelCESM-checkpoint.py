import numpy as np
import xarray as xr

def pbc_dzt(dz,kmt,ht,z_w_bot,mval=0):
    '''readme 2021Apr14: compute partial bottom cell(pbc) for dzt, copied from Fred's email on 2021Mar11'''
    nz = np.shape(dz)[0]
    ny,nx = np.shape(kmt)
    dzt = np.zeros((nz,ny,nx)) + dz.values[:,None,None]
    for iz in range(0,nz):
        bottom = (kmt.values==(iz+1))
        belowbottom = (kmt.values<(iz+1))
        count1 = np.count_nonzero(bottom)
        count2 = np.count_nonzero(belowbottom)
        if (count1 > 0):
            tmp2 = dzt[iz,:,:]
            tmp2[bottom] = ht.values[bottom] - z_w_bot.values[iz-1]
            dzt[iz,:,:]=tmp2
        if (count2 > 0):
            tmp2 = dzt[iz,:,:]
            tmp2[belowbottom] = mval
            dzt[iz,:,:]=tmp2
    dzt = xr.DataArray(dzt,dims=['z_t','nlat','nlon'])
    dzt.encoding['_FillValue']=mval
    return dzt


def CalcLonLat2XY4StandardGridsFunc(lon_deg,lat_deg):
    '''
%% ========================  readme  =============================
% 
% DESCRIPTION:
% 
%  A function to convert standard grids (e.g. 1 and 0.1 deg) lat and lon to x and y coordinates
%
% update history:
% v1.0 DL 2021May10
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% INPUT:
%
%   lon_deg    - 1d data array for lon, unit: [deg]
%   lat_deg    - 1d data array for lon, unit: [deg]
%
% OUTPUT:
%   x          - x coordinates with the left column as 0, unit: [m]
%   y          - y coordinates with the bottom row as 0, unit: [m]
%
% EXAMPLE:
%   x, y = ConvertLonLat2XY4UnevenGridsFunc(lon_deg,lat_deg):
% 
% EXTRA NOTES:
%  
% REFERENCE:
%   CalcGradient4UnevenGridsFunc.m
% ====================================================================    
'''
    R = 6371000 # Earth radius [m]
    lon_rad = np.deg2rad(lon_deg)
    lat_rad = np.deg2rad(lat_deg)
    lon_reso = lon_rad[1] - lon_rad[0]
    lat_reso = lat_rad[1] - lat_rad[0]
    dy = lat_reso*R
    y_1d = np.arange(0,len(lat_rad),1)*dy# y=0 corresponds to the 1st element of lat_deg
    y_2d = np.tile(y_1d,(len(lon_rad),1)).transpose() #repmat(y_1d,1,length(lon_1d))
    
    dx = np.empty((len(lat_rad)))
    dx[:] = np.nan
    x_2d = np.empty((len(lat_rad),len(lon_rad)))
    x_2d[:] = np.nan
    for ilat in np.arange(0,len(lat_rad),1):
        dx[ilat] = lon_reso*R*np.cos(lat_rad[ilat]);
        x_2d[ilat,:] = np.arange(0,len(lon_rad))*dx[ilat] 
        #x=0 corresponds to the 1st element of lon_deg

    return x_2d, y_2d



def CalcGradient4StandardGridFunc(x_2d, y_2d, f):
    '''
%% ========================  readme  =============================
% 
% DESCRIPTION:
% 
%  A function to compute gradient for standard grids (e.g., 1, 0.1 deg). 
%
% update history:
% v1.0 DL 2021May10
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% INPUT:
%
%   x_2d       - 2D x cartesian coordinates in E-W direction, [m]
%               e.g. x = [1 2 10;1 2 10;1 2 10]
%   y_2d       - 2D y cartesian coordinates in N-S direction, [m]
%               e.g. y = [6 6 6;4 4 4;0 0 0]
%   f          - 2D input field, e.g. sea surface height
%
% OUTPUT:
%   dfdx       - gradient (dfdx) in E-W (x) direction [m/s] 
%   dfdy       - gradient (dfdy) in N-S (y) direction [m/s] 
%
% EXAMPLE:
%   dfdx, dfdy = CalcGradient4StandardGridFunc(x_2d,y_2d,f)
% 
% EXTRA NOTES:
%   this function can also compute gradient for even grids if x_2d 
%   and y_2d are even spaced.
%  
% REFERENCE:
%   CalcGradient4UnevenGridsFunc.m
% ====================================================================
    '''       
    # --- compute dfdx ---
    dfdx = np.full_like(f, np.nan, dtype=np.double)
    dfdy = np.full_like(f, np.nan, dtype=np.double)
    
    # Take forward differences on left and right edges
    dfdx[:,0] = (f[:,1] - f[:,0]) /(x_2d[:,1]-x_2d[:,0])
    dfdx[:,-1] = (f[:,-1] - f[:,-2]) /(x_2d[:,-1]-x_2d[:,-2])

    # Take centered differences on interior points
    dfdx[:,1:-1] = (f[:,2:] - f[:,:-2]) / (x_2d[:,2:] - x_2d[:,:-2])
    # --------------------

    # --- compute dfdy ---
    # Take forward differences on top and bottom edges
    dfdy[0,:] = (f[1,:] - f[0,:]) / (y_2d[1,:] - y_2d[0,:])
    dfdy[-1,:] = (f[-1,:] - f[-2,:]) / (y_2d[-1,:] - y_2d[-2,:])

    # Take centered differences on interior points
    dfdy[1:-1,:] = (f[2:,:] - f[:-2,:]) / (y_2d[2:,:] - y_2d[:-2,:])

    return dfdx, dfdy


def CalcVgeo(ssh, x_2d, y_2d, f):    
    '''
%% ========================  readme  =============================
% 
% DESCRIPTION:
% 
%  A function to compute geostrophic velocities from ssh
%
% update history:
% v1.0 DL 2021May10
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% INPUT:
% 
%   ssh        - 2D data array for ssh, unit: [m]  
%   x_2d       - 2D x cartesian coordinates in E-W direction, [m]
%               e.g. x = [1 2 10;1 2 10;1 2 10]
%   y_2d       - 2D y cartesian coordinates in N-S direction, [m]
%               e.g. y = [6 6 6;4 4 4;0 0 0]
%   f          - 2D data array for Coriolis parameter (use sw.f(lat) to compute f), unit: [1/s]
%
% OUTPUT:
%   Ug         - geostrophic velocity in x direction, unit: [m/s]
%   Vg         - geostrophic velocity in y direction, unit: [m/s]
%
% EXAMPLE:
%   Ug, Vg = CalcVgeo(ssh, x_2d, y_2d, f)
% 
% EXTRA NOTES:
%  
% REFERENCE:
%   CalcGeostrophyVel4UnevenGridsFunc.m
% ====================================================================    
    '''
    g = 9.8
    [dsshdx, dsshdy] = CalcGradient4StandardGridFunc(x_2d, y_2d, ssh)
    Ug = -g/f*dsshdy
    Vg = g/f*dsshdx

    return Ug, Vg