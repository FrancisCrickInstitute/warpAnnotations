# Auxiliary Methods

## Packages & Folder:

* +Segmentation: Functionality for interacting and processing with segmentations.
  * +Global: Processing of multiple segmentation cubes.
  * +Local: Processing of a single local cube.
* +Skeleton: Functionality for processing skeletons beyond the graph structure itself (e.g. combining skeletons with segmentation information).
* cubes: Reading and writing raw files in a knossos hierarchy.
* io: Reading and writing of raw EM and segmentation data. These functions should abstract away the storage backend.
* json: A MATLAB wrapper around libJSON-C for reading / writing JSON files. Have a look at the README file in the json directory for an installation guide.
* nml: All files required for reading and writing NML files
* skeleton class: Functionality related to a MATLAB representation of an nml file.
