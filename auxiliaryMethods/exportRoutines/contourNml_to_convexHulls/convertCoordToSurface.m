% convert voxel coord into sphere surfaces that can be imported in amira
% useful for importing somata
function convertCoordToSurface(coord,outputFileName,vxSize,diameter,faces,desiredColor)

% filename in format 'filename.am'
% diameter is diameter of the sphere in nm - for soma use 5000
% faces is number of faces for each sphere (10 ist fast, 50 is HighRes but slow if many thousand)
% desiredColor in array 0 to 1 format, like [1 0 0] for red

% bring coordinates into an structure variable
somata = cell(1,3);
somata{1} = coord(:,1);
somata{2} = coord(:,2);
somata{3} = coord(:,3);
% scale according to voxel size (should be in nanometers to match the amira scene etc)
somaList{:,1} = somata{:,1}*vxSize(1);
somaList{:,2} = somata{:,2}*vxSize(2);
somaList{:,3} = somata{:,3}*vxSize(3);
somaList{:,4} = ones(size(somata{1},1),1)*diameter;

somaList=cell2mat(somaList);

%color=fi_vis_getColors(size(somaList,1)); %multicolor
color=repmat(desiredColor,[size(somaList,1) 1]); %all same color

%create Soma Isosurfaces in Folder
% for i=1:size(somaList,1)
% [X,Y,Z]=sphere(faces);
% abc{i}=surf2patch(X,Y,Z,'triangles');
% abc{i}.vertices=abc{i}.vertices.*somaList(i,4);
% abc{i}.vertices=abc{i}.vertices+repmat(somaList(i,1:3),[size(abc{i}.vertices,1),1]);
% end

for i=1:size(somaList,1)
[X,Y,Z]=sphere(faces);
abc{i}=surf2patch(X,Y,Z,'triangles');
abc{i}.vertices=abc{i}.vertices.*somaList(i,4);
abc{i}.vertices=abc{i}.vertices+repmat(somaList(i,1:3),[size(abc{i}.vertices,1),1]);
end

KLEEv4_exportSurfaceToAmira_v2(abc,sprintf(outputFileName,i),color);