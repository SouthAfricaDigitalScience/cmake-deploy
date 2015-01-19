#!/bin/bash
module load ci
echo "checking $NAME"
cd $WORKSPACE/$NAME-$VERSION

echo $?

make install # DESTDIR=$SOFT_DIR

mkdir -p $REPO_DIR
rm -rf $REPO_DIR/*
tar -cvzf $REPO_DIR/build.tar.gz -C $WORKSPACE/build apprepo

mkdir -p modules
(
cat <<MODULE_FILE
#%Module1.0
## $NAME modulefile
##
proc ModulesHelp { } {
    puts stderr "       This module does nothing but alert the user"
    puts stderr "       that the [module-info name] module is not available"
}

module-whatis   "$NAME $VERSION."
setenv       CMAKE_VERSION       $VERSION
setenv       CMAKE_DIR           /apprepo/$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/$VERSION
prepend-path PATH              $::env(CMAKE_DIR)/bin
prepend-path LD_LIBRARY_PATH   $::env(CMAKE_DIR)/lib
prepend-path GCC_INCLUDE_DIR   $::env(CMAKE_DIR)/include
MODULE_FILE
) > modules/$VERSION

mkdir -p $LIBRARIES_MODULES/$NAME
cp modules/$VERSION $LIBRARIES_MODULES/$NAME

module add ci
which cmake
