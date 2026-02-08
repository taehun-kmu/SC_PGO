cmake_minimum_required(VERSION 3.22)
project(sc_pgo)

# Export compile commands for clangd and other tools
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE "Release")
endif()
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_FLAGS_RELEASE "-O3 -Wall -g")

find_package(ament_cmake REQUIRED)
find_package(rclcpp REQUIRED)
find_package(sensor_msgs REQUIRED)
find_package(geometry_msgs REQUIRED)
find_package(nav_msgs REQUIRED)
find_package(std_msgs REQUIRED)
find_package(cv_bridge REQUIRED)
find_package(tf2 REQUIRED)
find_package(tf2_ros REQUIRED)
find_package(PCL REQUIRED)
find_package(OpenCV REQUIRED)
find_package(Ceres REQUIRED)
find_package(OpenMP REQUIRED)
find_package(GTSAM REQUIRED QUIET)
find_package(pcl_conversions REQUIRED)
find_package(pcl_msgs REQUIRED)   # usually needed alongside


include_directories(
  include
  ${PCL_INCLUDE_DIRS}
  ${CERES_INCLUDE_DIRS}
  ${OpenCV_INCLUDE_DIRS}
  ${GTSAM_INCLUDE_DIR}
)

add_executable(alaserPGO
  src/laserPosegraphOptimization.cpp
  include/scancontext/Scancontext.cpp
)

# Use ament_target_dependencies for ROS2 packages (handles includes, links, and definitions)
ament_target_dependencies(alaserPGO
  rclcpp
  sensor_msgs
  geometry_msgs
  nav_msgs
  std_msgs
  tf2
  tf2_ros
  cv_bridge
  pcl_conversions
  pcl_msgs
)

# Link non-ROS2 libraries using plain signature (to match ament_target_dependencies)
target_compile_options(alaserPGO
  PRIVATE ${OpenMP_CXX_FLAGS}
)
target_link_libraries(alaserPGO
  ${PCL_LIBRARIES}
  ${CERES_LIBRARIES}
  OpenMP::OpenMP_CXX
  gtsam
)

install(TARGETS
  alaserPGO
  DESTINATION lib/${PROJECT_NAME}
)

install(DIRECTORY launch/ DESTINATION share/${PROJECT_NAME}/launch
  FILES_MATCHING PATTERN "*.launch.py"
)

install(
  DIRECTORY rviz_cfg
  DESTINATION share/${PROJECT_NAME}
)

if(BUILD_TESTING)
  find_package(ament_lint_auto REQUIRED)
  # List of linters to skip (copyright and cpplint have too many false positives on third-party code)
  list(APPEND AMENT_LINT_AUTO_EXCLUDE
    ament_cmake_copyright
    ament_cmake_cpplint
  )
  ament_lint_auto_find_test_dependencies()
endif()

ament_package()
