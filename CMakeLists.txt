cmake_minimum_required(VERSION 3.16 FATAL_ERROR)

project(android_lib_project VERSION 0.1.0 LANGUAGES CXX C ASM)

set(CMAKE_CXX_STANDARD 14)

set(FUNASR_ANDROID_VERSION "0.1.0")

set(ONNXRUNTIME_VERSION 1.17.1)

message(STATUS ${ANDROID_ABI})
if(!ANDROID_ABI)
    message(STATUS "ANDROID_ABI Not defined!")
endif()

add_subdirectory(android_lib)
