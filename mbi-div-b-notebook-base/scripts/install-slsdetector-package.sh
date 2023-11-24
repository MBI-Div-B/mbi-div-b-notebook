#!/bin/bash

cd /tmp
mkdir sls-lib && cd sls-lib
git clone --depth 1 https://github.com/slsdetectorgroup/slsDetectorPackage.git && cd slsDetectorPackage
git checkout tags/7.0.1
cd ..
mkdir build && cd build
cmake ../slsDetectorPackage -DCMAKE_INSTALL_PREFIX=/opt/slsdetectorpackage -DSLS_USE_MOENCH=ON
make -j8
make install
rm -rf ../slsDetectorPackage