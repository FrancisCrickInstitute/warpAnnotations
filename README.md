# Warping tool in Matlab

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.6342309.svg)](https://doi.org/10.5281/zenodo.6342309)


### Purpose 

This repository was released with this [paper](https://www.nature.com/articles/s41467-022-30199-6) and is periodically updated with new correlative multimodal imaging studies.

In case you would like to investigate the repo at state of publication, please check [here](https://github.com/FrancisCrickInstitute/warpAnnotations/tree/paper_release).

These are the studies currently supported by data in this repository:
```
Bosch, C., Ackels, T., Pacureanu, A., Zhang, Y., Peddie, C. J., Berning, M., Rzepka, N., Zdora, M. C., Whiteley, I., Storm, M., Bonnin, A., Rau, C., Margrie, T., Collinson, L. & Schaefer, A. T.
Functional and multiscale 3D structural investigation of brain tissue through correlative in vivo physiology, synchrotron microtomography and volume electron microscopy.
Nature communications 13, 2923,
[doi:10.1038/s41467-022-30199-6](https://doi.org/10.1038/s41467-022-30199-6) (2022).

Zhang, Y., Ackels, T., Pacureanu, A., Zdora, M. C., Bonnin, A., Schaefer, A. T.# & Bosch, C.#
Sample Preparation and Warping Accuracy for Correlative Multimodal Imaging in the Mouse Olfactory Bulb Using 2-Photon, Synchrotron X-Ray and Volume Electron Microscopy. Front Cell Dev Biol 10, 880696, [doi:10.3389/fcell.2022.880696](https://doi.org/10.3389/fcell.2022.880696) (2022).

Bosch, C.*, Lindenau, J.*, Pacureanu, A., Peddie, C. J., Majkut, M., Douglas, A. C., Carzaniga, R., Rack, A., Collinson, L., Schaefer, A. T.# & Stegmann, H.#
Femtosecond laser preparation of resin embedded samples for correlative microscopy workflows in life sciences.
Applied Physics Letters 122, 143701, [doi:10.1063/5.0142405](https://doi.org/10.1117/12.3028309) (2023).
```

The goal of this repository is to enable warping spatial annotations between correlated volume datasets of the same specimen that have been acquired with different imaging modalities. 

This goal is reached by two applications:
1. To enable everyone to explore and reproduce annotations reported in our published studies. This application is addressed by including in this repo the parameters defining the correlative experiments described in those studies.

2. To allow interested individuals to use, adapt or extend this tool to their needs/datasets/formats. This application is addressed by providing the codebase and instructions for installation and usage.

The transformations were fitted in [bigwarp](https://github.com/saalfeldlab/bigwarp) and executed using the code in this repository.

### Installation

#### 1. Get latest version of this repo

If you already have the repository on a given computer, check whether you got the latest version:

```
cd <path_to_this_repo>
git pull
git submodule update --recursive
```

Otherwise clone the repository:

```
git clone git@github.com:FrancisCrickInstitute/warpAnnotations.git --recursive
```

#### 2. Install Java and Maven

Note: On a given HPC cluster with the module command you might be able to just load these dependencies:

```
module load Java/1.8.0_202
module load Maven/3.6.0
```

You can otherwise install Java and Maven using the following resources:

* Install Java 1.8 from e.g. [here](https://openjdk.java.net/install/) or [here](https://www.java.com/de/download/manual.jsp)

If opting for `jdk`, this would do the job (more info [here](https://devqa.io/brew-install-java/)):
```
brew tap homebrew/cask-versions
brew install --cask temurin8
```
And set `JAVA_HOME` path to its installed location.
```
# list all java installations
/usr/libexec/java_home -V
# obtain the path to the temurin installation
/usr/libexec/java_home -v 1.8.0_322
# update JAVA_PATH with the output of the previous command, such as
export JAVA_HOME="/Library/Java/JavaVirtualMachines/temurin-8.jdk/Contents/Home"
```
This `JAVA_HOME` path can be stated permanently to all your `zsh` sessions by adding that last command into your `~/.zshrc` file.

* Download [Maven](https://maven.apache.org/download.cgi) and follow the [installation instructions](https://maven.apache.org/install.html)


#### 3. Compile bigwarp and get its dependencies using maven

Go to the `bigwarp` folder in your repo, e.g.: `cd warping/bigwarp` and compile it:

```
mvn compile
```

Create list of the dependencies of bigwarp in a file using this command:

```
mvn dependency:build-classpath | grep 'Dependencies classpath' -A 1 | tail -n 1 | tr ':' '\n' > ../javaclasspath.txt
```

The command will automatically replace all `:` separators with a newline `\n` character for Matlab compatibility.

Add the  full path to the `warping` as well as the `warping/bigwarp/target/classes` subfolders at the top of that same `javaclasspath.txt` file.
The former contains a small wrapper script to use the bigwarp functionality from Matlab and the latter contains the classes generated using `mvn compile` in the bigwarp directory.

Move the file `javaclasspath.txt` either to the top level of the repo under `matlab-pipeline/` (and start Matlab from there during usage) or to your
[Matlab's `prefdir`](https://uk.mathworks.com/help/matlab/ref/prefdir.html?searchHighlight=prefdir&s_tid=srchtitle_prefdir_1)
to make the functionality available in Matlab permanently.
Note that if using the second approach you will also have to manually run `startup.m` from this repo every time at the beginning of your MATLAB session.

[Read more](https://uk.mathworks.com/help/matlab/matlab_external/static-path-of-java-class-path.html) about adding to your static Java path.

### Use case: creating new correlative experiments

#### Define the datasets (nodes)

Define the name and scale of each dataset in `warping/data/datasets.csv`

The scale should be specified in `nm` for each dimension.

#### Define the warp relationships between datasets (edges)

Define the parameters for each transformation between datasets in `warping/data/warpings.csv`

The parameters specify the following properties:

- The `source_` prefix refers to the dataset which will be transformed while the `target_` prefix refers to the dataset after transformation.
- The `mag_x`, `mag_y` and `mag_z` parameters refer to the magnification of the dataset which was used, magnification refers to levels in the webknossos resolution pyramid
- The `offset_x`, `offset_y` and `offset_z` parameters indicate the offset in voxel if only part of the dataset was used to generate the landmarks
- The `size_x`, `size_y` and `size_z` parmaters indicate the size of the bounding box in voxel used to fit the landmarks
- The `flip_x`, `flip_y`, `flip_z` parameters indicate whether a version of the dataset in which a certain dimension was inverted was used
- The `landmark` parameter specifies a csv file with landmarks exported from bigwarp to be placed in the `warping/data/landmarks` folder
- The `weight` parameter is used if a chain of transformations is to be traversed to decide which path to take by default (the one with lowest weight)

#### Unit test

Use a skeleton to test the warping by running a specific chain of transformations as exemplified in `warping/test_run.m`

This should then warp the skeleton to the other dataset and back to the original dataset (should be identical to the original one) as a sanity test.
If you have specified multiple transformations you can try running multiple transformations at once as well using the `warps` function.
Now you should be all set to transform skeletons between different webKnossos datasets as you please!

### Usage: revisiting correlative experiments

You will find below some example scenes released with the original [paper](https://www.nature.com/articles/s41467-022-30199-6). 

For scenes related to more recent studies supported by this tool, check the specific analysis code repositories released alongside those studies. 

#### Scenes from published studies

The following correlative multimodal annotations, reported in this [paper](https://www.nature.com/articles/s41467-022-30199-6), are available to explore:
| measurement | figures | dataset | annotations | link |
| --- | --- | --- | --- | --- |
|apical dendrite tracing in SXRT: olfactory bulb| Fig. 3 | C525_SXRT | somata EM/SXRT (50 cells), EM traces (consensus), SXRT traces (3x tracers) | [wk_scene](https://wklink.org/2530)|
|multiscale dendritic spine analysis | Fig. 5, SuppF7 | C556_SBEMhr | somata EM/SXRT, SXRT traces, SBEM_hr dendrite-spine traces | [wk_scene](https://wklink.org/6859)| 
|multimodal olfactory bulb glomerular imaging | Fig. 6, SuppF8, SuppF9 | C525a joint EM/2p | glomeruli 2p_iv, glomeruli_SBEMlr | [wk_scene](https://wklink.org/2705)|

The following correlative experiments are available to explore (links to the datasets [here](https://github.com/FrancisCrickInstitute/warpAnnotations/tree/main/warping/data)):
| specimen | species | age (w) | gender | location | figures | datasets |
| --- | --- | --- | --- | --- | --- | --- | 
| C525 | mouse | 10 | male | left hemisphere, olfactory bulb, first dorsal slice | 1, 2, 3, 6, 7, SuppF1, SuppF2, SuppF3, SuppF4, SuppF5, SuppF6, SuppF7, SuppF8,  SuppF10, SuppF11 | 2p_iv (M72), 2p_ev (M72 and MOR174/9), LXRT, SXRT, SBEM_lr (M72 and MOR174/9), SBEM_hr (M72) |
| C543 | mouse | 10 | male | coronal slice, cortex and striatum | 5, SuppF1 | LXRT, SXRT |
| C555 | mouse | 10 | male | coronal slice, cortex and anterior hippocampus | 5, SuppF1 | LXRT, SXRT |
| C556 | mouse | 10 | male | coronal slice, cortex and medial hippocampus | 4, SuppF1, SuppF3, SuppF4, SuppF9 | LXRT, SXRT, SBEMlr, SBEMhr |
| C557 | mouse | 10 | male | coronal slice, cerebellum | 5, SuppF1 | LXRT, SXRT |


### Questions and feedback

To cite this repository, please quote the original study it was released with: 
```
Bosch, C., Ackels, T., Pacureanu, A., Zhang, Y., Peddie, C. J., Berning, M., Rzepka, N., Zdora, M. C., Whiteley, I., Storm, M., Bonnin, A., Rau, C., Margrie, T., Collinson, L. & Schaefer, A. T. Functional and multiscale 3D structural investigation of brain tissue through correlative in vivo physiology, synchrotron microtomography and volume electron microscopy. Nature communications 13, 2923, [doi:10.1038/s41467-022-30199-6](https://doi.org/10.1038/s41467-022-30199-6) (2022).
```

If you have any questions please contact us: [Manuel Berning](mailto:manuel.berning@crick.ac.uk) or [Carles Bosch](mailto:carles.bosch@crick.ac.uk)

