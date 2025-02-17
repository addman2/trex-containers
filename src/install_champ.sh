#!/bin/bash -e

cd /opt
source environment.sh

ln -s /usr/bin/python3 /usr/bin/python || :

# Install dependencies
# --------------------

apt install -y cmake python3 git make gcc g++


git clone --depth=1 https://github.com/filippi-claudia/champ.git

cd champ

if [ $ARCH = x86_64 ] ; then
  echo "-march=core-avx2" >> /opt/ifort.cfg
  echo "-march=core-avx2" >> /opt/icx.cfg

  cmake -S. -Bbuild \
      -DCMAKE_Fortran_COMPILER="mpiifort" \
      -DENABLE_TREXIO=ON \
      -DENABLE_QMCKL=ON \
      -DVECTORIZATION="avx2"

elif [ $ARCH = aarch64 ] ; then

  apt install -y openmpi-bin libopenmpi-dev

  cmake -S. -Bbuild \
      -DCMAKE_Fortran_COMPILER="mpif90" \
      -DENABLE_TREXIO=ON \
      -DENABLE_QMCKL=ON 

fi

cmake --build build -j 8

rm -rf compile-* docs tests build lib

# Test
ls bin/vmc.mov1 || exit 1
ls bin/dmc.mov1 || exit 1
