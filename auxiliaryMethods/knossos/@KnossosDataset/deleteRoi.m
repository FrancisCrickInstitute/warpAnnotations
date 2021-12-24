function deleteRoi( obj, bbox )
%DELETEROI Delete the cubes in the specified ROI.
% INPUT bbox: [3x2] int
%           Bounding box in the form
%           [x_min x_max; y_min y_max; z_min z_max]
%           Only cubes fully contained in the bounding box will be deleted.
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

cubeind = [ceil((bbox(:,1) - 1)./obj.cubesize(1:3)'), ...
           floor(bbox(:,2)./obj.cubesize(1:3)') - 1];
       
for x = cubeind(1,1):cubeind(1,2)
    for y = cubeind(2,1):cubeind(2,2)
        for z = cubeind(3,1):cubeind(3,2)
            filename = sprintf('%s_x%04.0f_y%04.0f_z%04.0f%s.%s', ...
                obj.prefix, x, y, z, obj.suffix, obj.ending );
            curFolder = fullfile(obj.root, ...
                sprintf( 'x%04.0f', x), ...
                sprintf( 'y%04.0f', y), ...
                sprintf( 'z%04.0f', z));
            filename = fullfile( curFolder, filename);
            
            % delete file if exists (to avoid warning)
            if exist(filename, 'file')
                delete(filename);
            end
            
            % delete folder as well if empty
            if length(dir(curFolder)) == 2
                rmdir(curFolder);
            end
        end
    end
end


end

