% This file was modified as part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich, 2012
% Author: Christian Beckel (beckel@inf.ethz.ch)

function [sCR, sFSR] = none(sFS, figureOfMerit, log)

    sCV = sFS;
    [sCR, f] = nfold_cross_validation(sCV, figureOfMerit);

    sFSR.fm_training = [ f ];
    sFSR.features = -1;

end
