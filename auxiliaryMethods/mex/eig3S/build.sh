#!/bin/sh

echo "Compiling eig3S ..."
mex CXXFLAGS="-std=c++11 -fPIC" eig3S.cpp
