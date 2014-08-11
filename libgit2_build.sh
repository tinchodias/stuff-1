#!/bin/bash

# these two lines are just to make my life easier. I know that libgit2 looks in
# those places for libssh2 so I just put the files there
mkdir -p /opt/loca/lib
mkdir -p /opt/local/include
ln -s $git/libssh2/libssh2.dylib /opt/local/lib
ln -s $git/libssh2/include/libssh2.h /opt/local/include

cd $git/libgit2
rm -rf build
mkdir build && cd build
cmake .. -DCMAKE_OSX_ARCHITECTURES="i386"
cmake --build .
rm -rf /opt/local