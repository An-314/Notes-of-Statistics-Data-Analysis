cmake_minimum_required(VERSION 3.16)
project(LAB2Particles LANGUAGES CXX)

add_executable(particles
    main.cc
    src/Particle.cc
    src/ParticleInfo.cc
)
target_include_directories(particles PRIVATE include)
set_target_properties(particles PROPERTIES
    CXX_STANDARD 17
    CXX_STANDARD_REQUIRED YES
    CXX_EXTENSIONS NO
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
)
if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
    target_compile_options(particles PRIVATE -Wall -Wextra -Wpedantic)
endif()
