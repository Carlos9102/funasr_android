cmake_minimum_required(VERSION 3.16 FATAL_ERROR)

project(FunASRWebscoket) 

set(CMAKE_CXX_STANDARD 14 CACHE STRING "The C++ version to be used.")
set(CMAKE_POSITION_INDEPENDENT_CODE ON)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(ONNXRUNTIME_DIR ${CMAKE_CURRENT_BINARY_DIR}/${ONNXRUNTIME_VERSION})

message(STATUS "onnxruntime dir: ${ONNXRUNTIME_DIR}")
message(STATUS "ANDROID ABI: ${ANDROID_ABI}")

link_directories(${ONNXRUNTIME_DIR}/jni/${ANDROID_ABI})
include_directories(${ONNXRUNTIME_DIR}/headers)

link_directories(${FFMPEG_DIR}/lib)
include_directories(${FFMPEG_DIR}/include)

message(STATUS "cmake source dir is the following: ")
message(STATUS ${CMAKE_SOURCE_DIR})

include_directories(${CMAKE_SOURCE_DIR}/json/single_include)

set(FUNASR_RUNTIME_DIR ${CMAKE_SOURCE_DIR}/FunASR/runtime)

include_directories(${FUNASR_RUNTIME_DIR}/onnxruntime/include/)
include_directories(${FUNASR_RUNTIME_DIR}/onnxruntime/third_party/yaml-cpp/include/)
include_directories(${FUNASR_RUNTIME_DIR}/onnxruntime/third_party/kaldi-native-fbank)
include_directories(${FUNASR_RUNTIME_DIR}/onnxruntime/third_party/openfst/src/include/)
include_directories(${FUNASR_RUNTIME_DIR}/onnxruntime/src)

include_directories(${FUNASR_RUNTIME_DIR}/onnxruntime/gflags)
message(STATUS "gflags binary dir: ${gflags_BINARY_DIR}")
include_directories(${gflags_BINARY_DIR}/include)

include_directories(${FUNASR_RUNTIME_DIR}/onnxruntime/third_party/kaldi)
include_directories(${FUNASR_RUNTIME_DIR}/onnxruntime/third_party/jieba/include)

add_subdirectory(${FUNASR_RUNTIME_DIR}/onnxruntime/third_party/yaml-cpp yaml-cpp)
add_subdirectory(${FUNASR_RUNTIME_DIR}/onnxruntime/third_party/kaldi-native-fbank/kaldi-native-fbank/csrc csrc)
add_subdirectory(${FUNASR_RUNTIME_DIR}/onnxruntime/src src)
add_subdirectory(${FUNASR_RUNTIME_DIR}/onnxruntime/third_party/kaldi kaldi)
add_subdirectory(${FUNASR_RUNTIME_DIR}/onnxruntime/third_party/gflags gflags)
add_subdirectory(${FUNASR_RUNTIME_DIR}/onnxruntime/third_party/openfst/src openfst)

include_directories(${FUNASR_RUNTIME_DIR}/onnxruntime/third_party/glog/src)
set(BUILD_TESTING OFF)
add_subdirectory(${FUNASR_RUNTIME_DIR}/onnxruntime/third_party/glog glog)

aux_source_directory(${FUNASR_RUNTIME_DIR}/onnxruntime/src src_files)

add_library(fawasr2pass-jni SHARED fawasr2pass.cc ${src_files}) 
add_library(fawasroff-jni SHARED fawasroffline.cc ${src_files}) 

target_link_libraries(fawasr2pass-jni PUBLIC avcodec avformat avutil avfilter swresample swscale)
target_link_libraries(fawasr2pass-jni PUBLIC onnxruntime -pthread gflags fst kaldi-util kaldi-decoder yaml-cpp dl csrc glog log)

target_link_libraries(fawasroff-jni PUBLIC onnxruntime -pthread yaml-cpp csrc glog log)
