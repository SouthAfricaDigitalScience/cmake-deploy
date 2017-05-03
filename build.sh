#!/bin/bash -e
# Copyright 2016 C.S.I.R. Meraka Institute
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

. /etc/profile.d/modules.sh
SOURCE_FILE=${NAME}-${VERSION}.tar.gz

module add ci
module add bzip2
module add zlib
module add curl

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

# Cmake source repo has a directory structure that has one leve for the major.minor version
# we need to compute the major and minor versions before constructing the download path

# VERSON_MAJOR is VERSION.MAJOR
VERSION_MAJOR=${VERSION:0:3}

# if the file has not been claimed and the file is not empty, download it - else wait until
if [ ! -e ${SRC_DIR}/${SOURCE_FILE}.lock ] && [ ! -s ${SRC_DIR}/${SOURCE_FILE} ] ; then
# claim the download
  touch  ${SRC_DIR}/${SOURCE_FILE}.lock
  echo "seems like this is the first build - let's get the source"
  wget https://cmake.org/files/v${VERSION_MAJOR}/${SOURCE_FILE} -O ${SRC_DIR}/${SOURCE_FILE}
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
mkdir -p ${WORKSPACE}/${NAME}-${VERSION}/build-${BUILD_NUMBER}
cd ${WORKSPACE}/${NAME}-${VERSION}/build-${BUILD_NUMBER}
ls
../bootstrap \
--prefix=${SOFT_DIR} \
--no-qt-gui
make -j2
