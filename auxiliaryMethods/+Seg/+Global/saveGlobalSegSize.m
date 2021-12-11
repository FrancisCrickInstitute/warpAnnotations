function saveGlobalSegSize( p, mapping, filename )
%SAVEGLOBALSEGSIZE Save the size of the mapped global segments to the respective
% local cube.
% This function creates a new file in each local segmentation cube folder
% containing the size of the segments in p.local(i).segmentFile after applying
% the correspondences across cubes and getting the total size of the mapped
% global segments.
% INPUT p: Segmentation parameter struct.
%       mapping: Mapping of global correspondences (see
%                Seg.Global.getGlobalMapping)
%       filename: The name of the file which will be saved in each local
%                 segmentation cube.
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

%get the global segment sizes
globalSegSizes = Seg.Global.getSegmentSize(p, mapping);

%associate global segment sizes with local ones and save them
for i = 1:length(p.local)
    m = load(p.local(i).segmentFile);
    segIDs = [m.segments(:).Id];
    segSize = zeros(length(segIDs),1,'like',globalSegSize);
    for j = 1:length(segIDs)
        segSize(j) = globalSegSizes(mapping(segIDs(j)));
    end
    Util.save([p.local(i).saveFolder filesep filename], segSize);
end

end
