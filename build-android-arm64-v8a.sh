#!/usr/bin/env bash
set -ex

dir=$PWD/build-android-arm64-v8a

mkdir -p $dir
cd $dir

# Note from https://github.com/Tencent/ncnn/wiki/how-to-build#build-for-android
# (optional) remove the hardcoded debug flag in Android NDK android-ndk
# issue: https://github.com/android/ndk/issues/243
#
# open $ANDROID_NDK/build/cmake/android.toolchain.cmake for ndk < r23
# or $ANDROID_NDK/build/cmake/android-legacy.toolchain.cmake for ndk >= r23
#
# delete "-g" line
#
# list(APPEND ANDROID_COMPILER_FLAGS
#   -g
#   -DANDROID

if [ ! -d $ANDROID_NDK ]; then
  echo Please set the environment variable ANDROID_NDK before you run this script
  exit 1
fi

echo "ANDROID_NDK: $ANDROID_NDK"
sleep 1
onnxruntime_version=1.17.1

if [ ! -f $onnxruntime_version/jni/arm64-v8a/libonnxruntime.so ]; then
  mkdir -p $onnxruntime_version
  pushd $onnxruntime_version
  wget -c -q https://github.com/csukuangfj/onnxruntime-libs/releases/download/v${onnxruntime_version}/onnxruntime-android-${onnxruntime_version}.zip
  unzip onnxruntime-android-${onnxruntime_version}.zip
  mkdir -p headers/onnxruntime
  cp headers/* headers/onnxruntime/
  ls -lt headers
  ls -lt headers/onnxruntime
  pwd
  ls -lt
  rm onnxruntime-android-${onnxruntime_version}.zip
  popd
fi

wget https://isv-data.oss-cn-hangzhou.aliyuncs.com/ics/MaaS/ASR/dep_libs/ffmpeg-master-latest-linux64-gpl-shared.tar.xz
tar -xvf ffmpeg-master-latest-linux64-gpl-shared.tar.xz

cmake -DCMAKE_TOOLCHAIN_FILE="$ANDROID_NDK/build/cmake/android.toolchain.cmake" \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS=ON \
    -DFFMPEG_DIR="$dir/ffmpeg-master-latest-linux64-gpl-shared" \
    -DCMAKE_INSTALL_PREFIX=./install \
    -DANDROID_ABI="arm64-v8a" \
    -DANDROID_PLATFORM=android-21 ..

# Please use -DANDROID_PLATFORM=android-27 if you want to use Android NNAPI

make VERBOSE=1 -j4
ls -lt
cp -fv $onnxruntime_version/jni/arm64-v8a/libonnxruntime.so install/lib
rm -rf install/lib/pkgconfig

# To run the generated binaries on Android, please use the following steps.
#
#
# 1. Copy funasr_android and its dependencies to Android
#
#   cd build-android-arm64-v8a/install/lib
#   adb push ./lib*.so /data/local/tmp
#   cd ../bin
#   adb push ./funasr_android /data/local/tmp
#
# 2. Login into Android
#
#   adb shell
#   cd /data/local/tmp
#   ./funasr_android
#
# It should show the help message of funasr_android.
#
# Please use the above approach to copy model files to your phone.
