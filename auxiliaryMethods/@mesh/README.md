### export to `ply`
Function usage:
```
fileMeshGlomeruli = '/camp/project/proj-emschaefer/working/otherUsers/berninm/temp/meshes/C525b_glomeruli_example.mat'; 
meshGlomeruli = mesh(fileMeshGlomeruli);                                                                                
meshGlomeruli.writePLY('/camp/project/proj-emschaefer/working/otherUsers/berninm/temp/meshes/isosurfaces_glomeruli.ply');
```
Some notes:
* Output filename as only argument has to end with .ply
* Each isosurfaces will be written to a 00001.ply and so forth (same ordering as in mat)
* You can also specify the colors as a second input argument to the writePLY method of mesh. Has to be a Nx3 matrix like in the plot examples we did. Otherwise random colors will be used from the lines colormap
