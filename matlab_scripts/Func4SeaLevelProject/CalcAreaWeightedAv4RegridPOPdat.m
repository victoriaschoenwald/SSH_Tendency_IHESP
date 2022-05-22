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

function [x_av] = CalcAreaWeightedAv4RegridPOPdat(x,lat,grid_reso_deg)

  R = 6371000; % Earth radius in m
 
% --- compute area using sphere area eq ---
  grid_reso_rad = grid_reso_deg./180.*pi;
  TAREA_1d = (R.*grid_reso_rad).*(R.*cosd(lat).*grid_reso_rad);
  TAREA = repmat(TAREA_1d,1,size(x,2));
% -----------------------------------------

% --- compute POP regrided area-weighted mean ---
  A = 0; % numerator for area-weighted mean
  B = 0; % denominator for area-weighted mean

  for i = 1 : size(x,1)
    for j = 1 : size(x,2)
      if ~isnan(x(i,j))
        A = A + x(i,j).*TAREA(i,j);
        B = B + TAREA(i,j);
      end
    end
  end

  x_av = A./B;
% -----------------------------------------------
end
