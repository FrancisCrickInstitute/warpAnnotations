# Warping tool in Matlab

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
git clone git@github.com:FrancisCrickInstitute/skeletonWarping.git
cd skeletonWarping
git submodule update --recursive --init
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


### 3. Pull bigwarp and all its dependencies using maven

Go to the `bigwarp` folder in your repo, e.g.: `cd warping/bigwarp` and compile it:

```
mvn compile
```

Create list of the dependencies of bigwarp in a file using this command:

```
mvn dependency:build-classpath | grep 'Dependencies classpath' -A 1 | tail -n 1 > ../dep.txt
```

Rename the dependency file to `javaclasspath.txt` and change it to  matlab format:
E.g. open it with `vim` and issue the command:

```
:%s/:/\n/g 
```

This is equivalent to replacing all `:` with a newline `\n` character and can be done in any text editor.

Add the path to the `warping` subfolder at the top of that same `javaclasspath.txt` file and place it 
either in the top level of the repo (and start Matlab from there during usage) or in your
[prefdir](https://uk.mathworks.com/help/matlab/ref/prefdir.html?searchHighlight=prefdir&s_tid=srchtitle_prefdir_1)
to make the functionality availible in Matlab permanently.

This section will make bigwarp functionality useable from within Matlab. See [here](https://uk.mathworks.com/help/matlab/matlab_external/static-path-of-java-class-path.html) formore information of adding to your static Java path.

## Usage

1. Define the scale of each dataset in `warping/data/datasets.csv`
2. Define the parameters for each transformation between datasets in `warping/data/warpings.csv`
3. Use any skeleton you have using the following snippet:

```

```

