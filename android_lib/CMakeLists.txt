cmake_minimum_required(VERSION 3.16 FATAL_ERROR)

project(FunASRWebscoket) 

set(CMAKE_CXX_STANDARD 14 CACHE STRING "The C++ version to be used.")
set(CMAKE_POSITION_INDEPENDENT_CODE ON)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(ONNXRUNTIME_DOWNLOAD_DIR ${CMAKE_CURRENT_BINARY_DIR}/../${ONNXRUNTIME_VERSION})

message(STATUS "onnxruntime dir: ${ONNXRUNTIME_DOWNLOAD_DIR}")
message(STATUS "ANDROID ABI: ${ANDROID_ABI}")

if(UNIX)
    message(STATUS ">>> UNIX")
    find_package(pthread REQUIRED)
else()
    message(STATUS ">>> not UNIX")
endif()

include_directories(${ONNXRUNTIME_DOWNLOAD_DIR}/headers)
link_directories(${ONNXRUNTIME_DOWNLOAD_DIR}/jni/${ANDROID_ABI})

link_directories(${FFMPEG_DIR}/lib)
include_directories(${FFMPEG_DIR}/include)

message(STATUS "cmake source dir is the following: ")
message(STATUS ${CMAKE_SOURCE_DIR})

include_directories(${CMAKE_SOURCE_DIR}/json/single_include)

set(FUNASR_RUNTIME_DIR ${CMAKE_SOURCE_DIR}/FunASR/runtime)

include_directories(${FUNASR_RUNTIME_DIR}/onnxruntime/third_party/glog/src)
set(BUILD_TESTING OFF)
add_subdirectory(${FUNASR_RUNTIME_DIR}/onnxruntime/third_party/glog glog)

add_subdirectory(${FUNASR_RUNTIME_DIR}/onnxruntime/third_party/gflags gflags)
include_directories(${FUNASR_RUNTIME_DIR}/onnxruntime/gflags)
message(STATUS "gflags binary dir: ${gflags_BINARY_DIR}")
include_directories(${gflags_BINARY_DIR}/include)

include_directories(${FUNASR_RUNTIME_DIR}/onnxruntime/third_party/kaldi-native-fbank)
include_directories(${FUNASR_RUNTIME_DIR}/onnxruntime/third_party)
include_directories(${FUNASR_RUNTIME_DIR}/onnxruntime/third_party/kaldi)
include_directories(${FUNASR_RUNTIME_DIR}/onnxruntime/third_party/jieba/include)

include_directories(${FUNASR_RUNTIME_DIR}/onnxruntime/third_party/yaml-cpp/include/)
add_subdirectory(${FUNASR_RUNTIME_DIR}/onnxruntime/third_party/yaml-cpp yaml-cpp)

include_directories(${FUNASR_RUNTIME_DIR}/onnxruntime/third_party/openfst/src/include/)
add_subdirectory(${FUNASR_RUNTIME_DIR}/onnxruntime/third_party/openfst/src openfst)

# 为了顺利编译，先删除torch相关的文件
file(GLOB TORCH_FILES ${FUNASR_RUNTIME_DIR}/onnxruntime/src/*-torch.h ${FUNASR_RUNTIME_DIR}/onnxruntime/src/*-torch.cpp)
message(STATUS ${TORCH_FILES})
file(REMOVE ${TORCH_FILES})

include_directories(${FUNASR_RUNTIME_DIR}/onnxruntime/src)
include_directories(${FUNASR_RUNTIME_DIR}/onnxruntime/include)
add_subdirectory(${FUNASR_RUNTIME_DIR}/onnxruntime/third_party/kaldi-native-fbank/kaldi-native-fbank/csrc csrc)
add_subdirectory(${FUNASR_RUNTIME_DIR}/onnxruntime/third_party/kaldi kaldi)

aux_source_directory(${FUNASR_RUNTIME_DIR}/onnxruntime/src funasr_onnxruntime_src_files)

add_subdirectory(${FUNASR_RUNTIME_DIR}/onnxruntime/src src)

add_library(fawasr2pass-jni SHARED fawasr2pass.cc ${funasr_onnxruntime_src_files}) 
add_library(fawasroff-jni SHARED fawasroffline.cc ${funasr_onnxruntime_src_files}) 

target_link_libraries(fawasr2pass-jni PUBLIC avcodec avformat avutil avfilter swresample swscale)
target_link_libraries(fawasr2pass-jni PUBLIC onnxruntime pthread gflags fst kaldi-util kaldi-decoder yaml-cpp dl csrc glog log)

target_link_libraries(fawasroff-jni PUBLIC onnxruntime pthread yaml-cpp csrc glog log)
