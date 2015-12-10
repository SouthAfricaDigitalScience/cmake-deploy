#!/bin/bash -e

. /etc/profile.d/modules.sh
module add deploy
module add bzip2
module add zlib

cd ${WORKSPACE}/${NAME}-${VERSION}/build-${BUILD_NUMBER}
ls
./bootstrap --prefix=${SOFT_DIR}
make -j2
make install

echo "making module"

(
cat <<MODULE_FILE
#%Module1.0
## $NAME modulefile
##
proc ModulesHelp { } {
    puts stderr "       This module does nothing but alert the user"
    puts stderr "       that the [module-info name] module is not available"
}
module add bzip2
module add zlib
module-whatis   "$NAME $VERSION. See https://github.com/SouthAfricaDigitalScience/cmake-deploy"
setenv       CMAKE_VERSION       $VERSION
setenv       CMAKE_DIR         $::env(CVMFS_DIR)$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/$VERSION
prepend-path PATH              $::env(CMAKE_DIR)/bin
prepend-path LD_LIBRARY_PATH   $::env(CMAKE_DIR)/lib
prepend-path GCC_INCLUDE_DIR   $::env(CMAKE_DIR)/include
MODULE_FILE
) > modules/$VERSION

mkdir -p ${LIBRARIES_MODULES}/${NAME}
cp modules/${VERSION} ${LIBRARIES_MODULES}/${NAME}
module add cmake
which cmake
