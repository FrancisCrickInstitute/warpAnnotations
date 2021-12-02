# Warping tool in Matlab

## Purpose of this repository

The repository is released with this [paper](https://www.biorxiv.org/content/10.1101/2021.01.13.426503v1).

The main purpose is to make the transformations between the multiple imaging datasets of a single piece of tissue 
presented in the paper reproducible for everyone using Matlab. 
This is achieved by including the parameters of the transformations in this repository.
Another purpose is to allow interested individuals to use, adapt or extend this solution to their needs/datasets/formats.
This is achieved by providing the codebase and instructions below for installation and usage.

The transformations were fitted in [bigwarp](https://github.com/saalfeldlab/bigwarp) and executed using the code in this repository.

## Installation

### 1. Get latest version of this repo

If you already have the repository on a given computer, check whether you got the latest version:

```
cd <path_to_this_repo>
git pull
git submodule update --recursive
```

Otherwise clone the repository:

```
git clone git@github.com:FrancisCrickInstitute/skeletonWarping.git --recursive
```

### 2. Install Java and Maven

Note: On a given HPC cluster with the module command you might be able to just load these dependencies:

```
module load Java/1.8.0_202
module load Maven/3.6.0
```

You can otherwise install Java and Maven using the following resources:

* Install Java 1.8 from e.g. [here](https://openjdk.java.net/install/) or [here](https://www.java.com/de/download/manual.jsp)
* Download [Maven](https://maven.apache.org/download.cgi) and follow the [installation instructions](https://maven.apache.org/install.html)


### 3. Compile bigwarp and get its dependencies using maven

Go to the `bigwarp` folder in your repo, e.g.: `cd warping/bigwarp` and compile it:

```
mvn compile
```

Create list of the dependencies of bigwarp in a file using this command:

```
mvn dependency:build-classpath | grep 'Dependencies classpath' -A 1 | tail -n 1 | sed 's/:/\n/g' > ../javaclasspath.txt
```

The command will automatically replace all `:` separators with a newline `\n` character for Matlab compatibility.

Add the  full path to the `warping` as well as the `warping/bigwarp/target/classes` subfolders at the top of that same `javaclasspath.txt` file.
The former contains a small wrapper script to use the bigwarp functionality from Matlab and the latter contains the classes generated using `mvn compile` in the bigwarp directory.

Place it either in the top level of the repo (and start Matlab from there during usage) or in your
[prefdir](https://uk.mathworks.com/help/matlab/ref/prefdir.html?searchHighlight=prefdir&s_tid=srchtitle_prefdir_1)
to make the functionality availible in Matlab permanently.

[Read more](https://uk.mathworks.com/help/matlab/matlab_external/static-path-of-java-class-path.html) about adding to your static Java path.

## Usage

### Define the scale of each dataset in `warping/data/datasets.csv`

The scale is specified in `nm` for each dimension.

### Define the parameters for each transformation between datasets in `warping/data/warpings.csv`

The parameters specify the following properties:

- The `source_` prefix refers to the dataset which will be transformed while the `target_` prefix refers to the dataset after transformation.
- The `mag_x`, `mag_y` and `mag_z` parameters refer to the magnification of the dataset which was used, magnification refers to levels in the webknossos resolution pyramid
- The `offset_x`, `offset_y` and `offset_z` parameters indicate the offset in voxel if only part of the dataset was used to generate the landmarks
- The `size_x`, `size_y` and `size_z` parmaters indicate the size of the bounding box in voxel used to fit the landmarks
- The `flip_x`, `flip_y`, `flip_z` parameters indicate whether a version of the dataset in which a certain dimension was inverted was used
- The `landmark` parameter specifies a csv file with landmarks exported from bigwarp to be placed in the `warping/data/landmarks` folder
- The `weight` parameter is used if a chain of transformations is to be traversed to decide which path to take by default (the one with lowest weight)

### Use a skeleton to test the warping by running a specific chain of transformations as exemplified in `warping/test_run.m`

This should then warp the skeleton to the other dataset and back to the original dataset (should be identical to the original one) as a sanity test.
If you have specified multiple transformations you can try running multiple transformations at once as well using the `warps` function.
Now you should be all set to transform skeletons between different webKnossos datasets as you please!

## Questions and feedback

If you have any questions please contact us: [Manuel Berning](mailto:manuel.mb.berning@gmail.com) or [Carles Bosch](mailto:carles.bosch@crick.ac.uk)

