function [ skel ] = setParams4Dataset( skel, dataset )
%SETPARAMS4DATASET Create the skeleton parameter and scale properties for a
%specified dataset.
% INPUT skeleton: (Optional) skeleton object
%           (Default: Empty skeleton is created).
%       dataset: String containing the name for the dataset (see switch
%       	below).
% OUTPUT skel: The updated skeleton object.
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>
%         Alessandro Motta <alessandro.motta@brain.mpg.de>

if isempty(skel)
    skel = skeleton();
end

doIt = @(name, scale) skel.setParams(name, scale, [0, 0, 0]);

switch dataset
    case {'ex145', 'ex145_segNew', '2012-09-28_ex145_07x2_segNew'}
        % NOTE: This should actually be ex145_segNew
        skel = doIt('2012-09-28_ex145_07x2_segNew', [11.24, 11.24, 28]);
    case {'ex145_segNewBig', '2012-09-28_ex145_07x2_segNewBig'}
        skel = doIt('2012-09-28_ex145_07x2_segNewBig', [11.24, 11.24, 28]);
    case {'ex145_noSeg', '2012-09-28_ex145_07x2'}
        % NOTE: This is the *true* ex145
        skel = doIt('2012-09-28_ex145_07x2', [11.24, 11.24, 28]);
    case {'ex145_ROI2017', '2012-09-28_ex145_07x2_ROI2017'}
        skel = doIt('2012-09-28_ex145_07x2_ROI2017', [11.24, 11.24, 28]);
    case {'P14_L4_AG', 'P14_L4_AG_15'}
        skel = doIt('P14_L4_AG_15', [11.24, 11.24, 30]);
    case {'retinaK0563', '100527_k0563_segNew'}
        skel = doIt('100527_k0563_segNew', [12, 12, 25]);
    case {'kat11', 'kat11_mouseS1'}
        skel = doIt('kat11_mouseS1', [8 8 40]);
    case {'kat11_adapted', 'kat11_mouseS1_adaptedSeg'}
        skel = doIt('kat11_mouseS1_adaptedSeg', [8 8 40]);
    case {'ex144_New', '2012-11-23_ex144_st08x2New'}
        skel = doIt('2012-11-23_ex144_st08x2New', [12 12 28]);
    case {'ex144', '2017-11-16_ex144_st08x2'}
        skel = doIt('2017-11-16_ex144_st08x2', [12 12 26]);
    otherwise
        error('Parameters for %s are not yet implemented.',dataset);
end

end