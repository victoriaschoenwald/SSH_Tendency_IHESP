%% ========================  readme  =============================
% 
% DESCRIPTION:
% 
%  A function to compute area-weighted average for regrided POP data 
%
% update history:
% v1.0 DL 2020May01
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% INPUT:
%
% 
%   x              - 2D input data (e.g. TEMP), each row(column) 
%                    represents each lat(lon)
%   lat            - 1D latitude in deg (must be a column vector)
%   grid_reso_deg  - resolution of regrided POP dataset, e.g. 
%                    grid_reso_deg = 0.1; 
%
% OUTPUT:
%   x_av      - area-weighted mean of x
%
% 
% EXTRA NOTES:
%   this function passes test, see
%   CompareTempWeighedAvPOPOriginalRegridGrids_2020Apr30.m for details
% 
% REFERENCE:
%   N/A
% ====================================================================

function [eof_maps,pc,expv,jultime_yr,x_yr] = WrapFunc4EOF(jultime,x)

% --- compute yearly av and anomaly ---
  nyr = length(jultime)./12;
  
  for iyr = 1:nyr % ./12
    indx_time = (12.*iyr-11):(12.*iyr);
    x_yr(:,:,iyr) = mean(x(:,:,indx_time),3);
    jultime_yr(iyr) = mean(jultime(indx_time));
  end
  
  x_yra = x_yr - mean(x_yr,3);
% -------------------------------------  
 
% --- detrend and deseasonality ---
% sla_NA_dt_obs = detrend3(sla_NA_obs,time_raw_obs); %dt: detrend
% 
% [~,month_obs,~] = datevec(double(time_raw_obs)); 
% unique(month_obs)'
% sum(month_obs==1)
% 
% % Preallocate a 3D matrix of monthly means: 
% monthlymeans = nan(length(lon_NA_obs),length(lat_NA_obs),12); 
% 
% % Calculate the mean of all maps corresponding to each month, and subtract
% % the monthly means from the sst dataset: 
% for k = 1:12
%    
%    % Indices of month k: 
%    ind = month_obs==k; 
%    
%    % Mean SST for month k: 
%    monthlymeans(:,:,k) = mean(sla_NA_dt_obs(:,:,ind),3); 
%    
%    % Subtract the monthly mean: 
%    sla_NA_ds_obs(:,:,ind) = bsxfun(@minus,sla_NA_dt_obs(:,:,ind),monthlymeans(:,:,k)); % ds: deseasonal
% end
% -------------------------

% --- EOF analysis ---
 [eof_maps,pc,expv] = eof(x_yra);
% --------------------

end
