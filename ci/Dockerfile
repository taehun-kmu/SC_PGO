FROM sc_pgo-ci-base:latest

WORKDIR /ros2_ws

COPY . /ros2_ws/src

# Build with colcon (ROS2 workspace build tool)
# colcon internally uses ament_cmake which wraps CMake
RUN /bin/bash -c "source /opt/ros/humble/setup.bash && colcon build --cmake-args -G Ninja && colcon test --event-handlers console_direct+ --return-code-on-test-failure"
