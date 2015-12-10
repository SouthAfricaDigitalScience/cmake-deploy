#!/bin/bash -e
. /etc/profile.d/modules.sh
SOURCE_FILE=${NAME}-${VERSION}.tar.gz

module load ci
module add bzip2
module add zlib

echo "REPO_DIR is "
echo ${REPO_DIR}
echo "SRC_DIR is "
echo ${SRC_DIR}
echo "WORKSPACE is "
echo ${WORKSPACE}
echo "SOFT_DIR is"
echo ${SOFT_DIR}

mkdir -p ${WORKSPACE}
mkdir -p ${SRC_DIR}
mkdir -p ${SOFT_DIR}

# if the file has not been claimed and the file is not empty, download it - else wait until
if [ ! -e ${SRC_DIR}/${SOURCE_FILE}.lock ] && [ ! -s ${SRC_DIR}/${SOURCE_FILE} ] ; then
# claim the download
  touch  ${SRC_DIR}/${SOURCE_FILE}.lock
  echo "seems like this is the first build - let's get the source"
  wget https://cmake.org/files/v3.4/${SOURCE_FILE} -O ${SRC_DIR}/${SOURCE_FILE}
  echo "releasing lock"
  rm -v ${SRC_DIR}/${SOURCE_FILE}.lock
elif [ -e ${SRC_DIR}/${SOURCE_FILE}.lock ] ; then
  # Someone else has the file, wait till it's released
  while [ -e ${SRC_DIR}/${SOURCE_FILE}.lock ] ; do
    echo " There seems to be a download currently under way, will check again in 5 sec"
    sleep 5
  done
else
# the tarball is there and has finished downlading
  echo "continuing from previous builds, using source at ${SRC_DIR}/${SOURCE_FILE}"
fi
ls -lht ${SRC_DIR}/${SOURCE_FILE}
echo "extracting the tarball"
tar xzf ${SRC_DIR}/${SOURCE_FILE} -C ${WORKSPACE} --skip-old-files
echo "Going to ${WORKSPACE}/${NAME}-${VERSION}"
mkdir -p ${WORKSPACE}/${NAME}-${VERSION}/build-${BUILD_DIR}
cd ${WORKSPACE}/${NAME}-${VERSION}/build-${BUILD_DIR}
ls
./bootstrap --prefix=${SOFT_DIR}
make
