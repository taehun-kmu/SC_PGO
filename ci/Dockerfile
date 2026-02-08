FROM sc_pgo-ci-base:latest

WORKDIR /ros2_ws

COPY . /ros2_ws/src

# Build with colcon (ROS2 workspace build tool) using Ninja and cohesive console output
# colcon internally uses ament_cmake which wraps CMake
RUN /bin/bash -c "source /opt/ros/humble/setup.bash && colcon build --cmake-args -G Ninja --event-handlers console_cohesion+ --packages-select sc_pgo"

# Run tests separately (show uncrustify diff on failure)
RUN /bin/bash -c "source /opt/ros/humble/setup.bash && colcon test --event-handlers console_direct+ --packages-select sc_pgo --return-code-on-test-failure || { cat /ros2_ws/build/sc_pgo/ament_uncrustify/uncrustify.txt 2>/dev/null; exit 1; }"
