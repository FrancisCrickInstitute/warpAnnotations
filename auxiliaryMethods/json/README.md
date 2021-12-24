INSTALLATION GUIDE
==================

Building libjson-c
------------------

First, make sure that you have loaded the `gcc` and `autotools` modules. To do that, just run
```
module load GCC/5.4.0-2.26
module load GCCcore/5.4.0
```

Then change into the *json-c* folder and run
```
sh autogen.sh
./configure --prefix=`pwd`
make
make install
```

Building MATLAB-JSON
--------------------

Switch to the `matlab-json` directory, start MATLAB and run the `makeOnGaba` function.


That's all Folks!
-----------------

If this did not work, just open an issue on GitLab and we will try to help you.
