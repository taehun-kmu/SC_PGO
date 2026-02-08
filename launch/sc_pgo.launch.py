#!/usr/bin/env python3
# Copyright 2024 SC_PGO_ROS2 Contributors
# SPDX-License-Identifier: BSD-3-Clause

"""Launch file for SC-PGO (Scan Context Pose Graph Optimization) node."""

from launch import LaunchDescription
from launch_ros.actions import Node, PushRosNamespace
from launch.actions import DeclareLaunchArgument, GroupAction
from launch.substitutions import LaunchConfiguration
from launch.conditions import IfCondition


def generate_launch_description():
    """Generate launch description for SC-PGO node.

    Creates launch configuration with the following components:
    - alaserPGO node: Main pose graph optimization node
    - RViz2 node: Optional visualization (controlled by rvizscpgo argument)

    Returns:
        LaunchDescription: Complete launch description with all nodes and arguments.
    """
    # Launch arguments
    rvizscpgo_arg = DeclareLaunchArgument(
        "rvizscpgo", default_value="true", description="Launch RViz for SC-PGO"
    )
    namespace_arg = DeclareLaunchArgument(
        "namespace", default_value="", description="Namespace for all nodes"
    )
    publish_tf_arg = DeclareLaunchArgument(
        "publish_tf",
        default_value="false",
        description="Publish map->aft_pgo TF from SC-PGO",
    )

    namespace = LaunchConfiguration("namespace")
    publish_tf = LaunchConfiguration("publish_tf")

    alaserPGO_node = Node(
        package="sc_pgo",
        executable="alaserPGO",
        name="alaserPGO",
        output="screen",
        parameters=[
            {"scan_line": 128},
            {"minimum_range": 0.5},
            {"mapping_line_resolution": 0.4},
            {"mapping_plane_resolution": 0.8},
            {"mapviz_filter_size": 0.05},
            {"keyframe_meter_gap": 0.5},
            {"sc_dist_thres": 0.3},
            {"sc_max_radius": 290.0},
            {"save_directory": "./save_data/"},
            {"publish_tf": publish_tf},
            {"use_current_stamp_for_aft_pgo_odom": True},
        ],
        remappings=[
            ("/aft_mapped_to_init", "/Odometry"),
            ("/velodyne_cloud_registered_local", "/cloud_registered_body"),
            ("/cloud_for_scancontext", "/cloud_registered_lidar"),
            ("/tf", "tf"),
            ("/tf_static", "tf_static"),
        ],
    )

    # RViz Node
    rviz_node = Node(
        package="rviz2",
        executable="rviz2",
        name="rvizscpgo",
        remappings=[
            ("/tf", "tf"),
            ("/tf_static", "tf_static"),
        ],
        output="screen",
        condition=IfCondition(LaunchConfiguration("rvizscpgo")),
    )

    # Group nodes under namespace
    namespaced_group = GroupAction(
        actions=[
            PushRosNamespace(namespace),
            alaserPGO_node,
            rviz_node,
        ]
    )

    return LaunchDescription(
        [rvizscpgo_arg, namespace_arg, publish_tf_arg, namespaced_group]
    )
