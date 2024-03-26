#!/bin/bash

cd /opt

git clone --depth 1 https://github.com/MicMag2/MicMag2.git && cd MicMag2/src
mkdir build && cd build

cmake .. -DPYTHON_LIBRARY=/opt/conda/bin/python -DPYTHON_INCLUDE_DIR=${CONDA_PREFIX}/include/python3.11 -DCMAKE_CXX_FLAGS=-isystem\ /opt/conda/include
cmake --build .

cp magneto_cpu.py ../magnum/magneto_cpu.py 2>/dev/null
cp _magneto_cpu.so ../magnum/_magneto_cpu.so 2>/dev/null

chmod 777 -R /opt/MicMag2