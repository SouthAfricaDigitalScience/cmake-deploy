#!/bin/bash
. /etc/profile.d/modules.sh
module add ci
module add bzip2
module add zlib
echo "checking $NAME"
cd ${WORKSPACE}/${NAME}-${VERSION}/build-${BUILD_NUMBER}
make test -j2
echo $?
make install

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
module add bzip2
module add zlib
module-whatis   "$NAME $VERSION."
setenv       CMAKE_VERSION       $VERSION
setenv       CMAKE_DIR           /apprepo/$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/$VERSION
prepend-path PATH              $::env(CMAKE_DIR)/bin
prepend-path LD_LIBRARY_PATH   $::env(CMAKE_DIR)/lib
prepend-path GCC_INCLUDE_DIR   $::env(CMAKE_DIR)/include
MODULE_FILE
) > modules/$VERSION

mkdir -p ${COMPILERS_MODULES}/${NAME}
cp modules/${VERSION} ${LIBRARIES_MODULES}/${NAME}
module add cmake
which cmake
