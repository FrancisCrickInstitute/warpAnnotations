%% SECTION 1
clear

source={'/data/CB/poiata/MC_to_glom/CLEM_GCaMP_180122/C408/13-EMtoRaw/3-EMraw_mag8-8-4/somata_to_amira/MC_to_O174_1_soma.nml'};%%
x_resolution=64;
y_resolution=64;
z_resolution=128;
diameter=5000; %diameter of every sphere in nm (for somata use 5000)
outputPath='/data/CB/poiata/MC_to_glom/CLEM_GCaMP_180122/C408/13-EMtoRaw/3-EMraw_mag8-8-4/somata_to_amira';
filename='MC_to_O174_1_soma.am' %filename of amira file you create
faces=50 %number of faces for each sphere (10 ist fast, 50 is HighRes but slow if many thousand)

%====================================================================

%read out all nodes
tracings={};
for i=1:size(source,1)
    tracings{1,i}=parseNml(source{i});
end
clear newtracings1
y=1;
for x=1:length(tracings{1, 1})
    for i=1:size(tracings{1, 1}{1, x}.nodes,1)
        newtracings1{y,1}=tracings{1, 1}{1, x}.nodes(i,1);
        newtracings1{y,2}=tracings{1, 1}{1, x}.nodes(i,2);
        newtracings1{y,3}=tracings{1, 1}{1, x}.nodes(i,3);
        y=y+1;
    end
end
somata=(newtracings1); %coordinates of somata in newtracings1
%% SECTION 2
%multiply coordinates with resolution and create diameter 
for i=1:size(somata)
    
    somaList{i,1}=somata{i,1}*x_resolution;
    somaList{i,2}=somata{i,2}*y_resolution;
    somaList{i,3}=somata{i,3}*z_resolution;
    somaList{i,4}=diameter;
end
somaList=cell2mat(somaList);

%color=fi_vis_getColors(size(somaList,1)); %multicolor
color=repmat([1,0,0],[size(somaList,1) 1]); %all same color


%create Soma Isosurfaces in Folder
for i=1:size(somaList,1)
[X,Y,Z]=sphere(faces);
abc{i}=surf2patch(X,Y,Z,'triangles');
abc{i}.vertices=abc{i}.vertices.*somaList(i,4);
abc{i}.vertices=abc{i}.vertices+repmat(somaList(i,1:3),[size(abc{i}.vertices,1),1]);
end

KLEEv4_exportSurfaceToAmira_v2(abc,sprintf([outputPath filesep filename],i),color);

