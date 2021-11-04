function [seg, segSmall] = loadSegData(segFile, tileBorder)

load(segFile);
segSmall = seg(1-tileBorder(1,1):end-tileBorder(1,2),...
	1-tileBorder(2,1):end-tileBorder(2,2),...
	1-tileBorder(3,1):end-tileBorder(3,2));

end
