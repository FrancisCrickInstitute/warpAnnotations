function targets = warp_targets(obj)

obj = transformVirtualDatasetToOriginal(obj)
temp = skeleton();
temp.parameters.experiment.name = obj.dataset;
targets = temp.warps_targets();

end

