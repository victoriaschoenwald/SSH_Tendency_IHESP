# === readme ===
# descrip: save Regional Steric Height for Sunway Transient HR 

# update history: 
# v1.0 DL 2021Apr15

# reference: saveRegionalStericHeightSunway_2021Apr14.ipynb
# ==============


# === import modules ===
import numpy as np
import xarray as xr
import pop_tools
import dask
from dask.distributed import Client
from dask_jobqueue import SLURMCluster # grace uses SLURMCluster
from Funcs4SeaLevelCESM import pbc_dzt
# ======================

# === initiate dask cluster ===
cluster = SLURMCluster(cores=32, processes=16, memory="132GB", walltime="17:00:00")
print(cluster.job_script())
cluster.scale(1)
client = Client(cluster)
# =============================

# === define parameters ===
date_str='2021Apr15'
 
yrs = np.arange(2006,2100+1) 
mons = np.arange(1,13)

rho0 = 1028 # unit: kg/m3, reference density, see vanWestern et al., (2020)

# --- TH: Transient HR --- 
indir='/scratch/group/ihesp/archive/B.E.13.BRCP85C5CN.ne120_t12.sehires38.003.sunway.CN_OFF/ocn/monthly/'
prefix = 'cmpr_B.E.13.BRCP85C5CN.ne120_t12.sehires38.003.sunway.CN_OFF.pop.h.'
infile0=(indir+'cmpr_B.E.13.BRCP85C5CN.ne120_t12.sehires38.003.sunway.CN_OFF.pop.h.2006-01.nc') # reference file
chunk_size = {'nlat':800,'nlon':300}
# ------------------------

outdir = ('/scratch/user/dapengli/Projects4iHESP/Project_SeaLevelUSEastCoast_2021Mar30/'
          'data_after_manipulation/RegionalStericHeight/B.E.13.BRCP85C5CN.ne120_t12.sehires38.003.sunway.CN_OFF/')
# ====================

# === read files ===
ds0=xr.open_dataset(infile0)
droplist=list(ds0.variables)
keeplist=['TEMP','SALT','HT','time','TLONG','TLAT','z_t','z_w_bot','dz','KMT']
for i in keeplist:
    droplist.remove(i)
# ==================

# === data analysis ===
dzt_x = pbc_dzt(ds0.dz,ds0.KMT,ds0.HT,ds0.z_w_bot,mval=0) # x: xarray data array
dzt = dzt_x.chunk(chunks=chunk_size) #convert xarray data array to dask array, there's mem issue otherwise

for iyr in yrs: 
    print('working on year',str(iyr))
    infiles = [indir + prefix + str(iyr) + '-' + str(imon).zfill(2) + '.nc' for imon in mons]
    ds = xr.open_mfdataset(infiles, compat="override", combine="by_coords", data_vars="minimal",
                          coords="minimal", chunks=chunk_size, drop_variables=droplist, parallel=True)
    time_s = ds.time.to_pandas().index.shift(-1,'M') # s: shift time
    ds = ds.assign_coords(time=time_s)

    rho = pop_tools.eos(ds.SALT, ds.TEMP, depth=ds.z_t*1e-2) # in-situ density rho
    b = 1-rho/rho0 

    h_rst = (b*dzt).sum(dim='z_t').resample(time='A').mean('time') # h_rst: regional steric height
    h_rst = h_rst.where(ds0.KMT>0, np.nan).rename('h_rst') # mask land with nan
    h_rst.attrs['long name'] = 'yr-av regional steric height'
    h_rst.attrs['units'] = 'cm'
    h_rst.attrs['source code'] = 'saveRegionalStericHeightSunwayTH_2021Apr15.ipynb'    
    
    outfile=(outdir + prefix + 'RegionalStericHeight_' + str(iyr) + 'av_' + date_str + '.nc')
    h_rst.to_netcdf(path=outfile, mode='w', format='NETCDF4', compute=True)
    
    del infiles, ds, time_s, rho, b, h_rst, outfile
# =====================

# === End of Codes ===
print('EOC')
print(client)
cluster.close()
client.close()
# ====================