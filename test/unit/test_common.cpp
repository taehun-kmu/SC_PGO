// Copyright 2024 SC_PGO_ROS2 Contributors
// SPDX-License-Identifier: BSD-3-Clause

#include <catch_ros2/catch_ros2.hpp>
#include <cmath>

#include "aloam_velodyne/common.h"

TEST_CASE("Pose6D structure initializes correctly", "[common]") {
  // Arrange
  Pose6D pose;

  // Act
  pose.x = 1.0;
  pose.y = 2.0;
  pose.z = 3.0;
  pose.roll = 0.1;
  pose.pitch = 0.2;
  pose.yaw = 0.3;

  // Assert
  REQUIRE(pose.x == 1.0);
  REQUIRE(pose.y == 2.0);
  REQUIRE(pose.z == 3.0);
  REQUIRE(pose.roll == 0.1);
  REQUIRE(pose.pitch == 0.2);
  REQUIRE(pose.yaw == 0.3);
}

TEST_CASE("rad2deg converts radians to degrees correctly", "[common]") {
  SECTION("converts zero radians") {
    // Arrange
    const double radians = 0.0;
    const double expected_degrees = 0.0;

    // Act
    const double actual_degrees = rad2deg(radians);

    // Assert
    REQUIRE(actual_degrees == expected_degrees);
  }

  SECTION("converts pi radians to 180 degrees") {
    // Arrange
    const double radians = M_PI;
    const double expected_degrees = 180.0;

    // Act
    const double actual_degrees = rad2deg(radians);

    // Assert
    REQUIRE(actual_degrees == Catch::Approx(expected_degrees));
  }

  SECTION("converts pi/2 radians to 90 degrees") {
    // Arrange
    const double radians = M_PI / 2.0;
    const double expected_degrees = 90.0;

    // Act
    const double actual_degrees = rad2deg(radians);

    // Assert
    REQUIRE(actual_degrees == Catch::Approx(expected_degrees));
  }

  SECTION("converts negative radians correctly") {
    // Arrange
    const double radians = -M_PI;
    const double expected_degrees = -180.0;

    // Act
    const double actual_degrees = rad2deg(radians);

    // Assert
    REQUIRE(actual_degrees == Catch::Approx(expected_degrees));
  }
}

TEST_CASE("deg2rad converts degrees to radians correctly", "[common]") {
  SECTION("converts zero degrees") {
    // Arrange
    const double degrees = 0.0;
    const double expected_radians = 0.0;

    // Act
    const double actual_radians = deg2rad(degrees);

    // Assert
    REQUIRE(actual_radians == expected_radians);
  }

  SECTION("converts 180 degrees to pi radians") {
    // Arrange
    const double degrees = 180.0;
    const double expected_radians = M_PI;

    // Act
    const double actual_radians = deg2rad(degrees);

    // Assert
    REQUIRE(actual_radians == Catch::Approx(expected_radians));
  }

  SECTION("converts 90 degrees to pi/2 radians") {
    // Arrange
    const double degrees = 90.0;
    const double expected_radians = M_PI / 2.0;

    // Act
    const double actual_radians = deg2rad(degrees);

    // Assert
    REQUIRE(actual_radians == Catch::Approx(expected_radians));
  }

  SECTION("converts negative degrees correctly") {
    // Arrange
    const double degrees = -180.0;
    const double expected_radians = -M_PI;

    // Act
    const double actual_radians = deg2rad(degrees);

    // Assert
    REQUIRE(actual_radians == Catch::Approx(expected_radians));
  }
}

TEST_CASE("rad2deg and deg2rad are inverse operations", "[common]") {
  SECTION("converts degrees to radians and back") {
    // Arrange
    const double original_degrees = 45.0;

    // Act
    const double radians = deg2rad(original_degrees);
    const double converted_degrees = rad2deg(radians);

    // Assert
    REQUIRE(converted_degrees == Catch::Approx(original_degrees));
  }

  SECTION("converts radians to degrees and back") {
    // Arrange
    const double original_radians = M_PI / 4.0;

    // Act
    const double degrees = rad2deg(original_radians);
    const double converted_radians = deg2rad(degrees);

    // Assert
    REQUIRE(converted_radians == Catch::Approx(original_radians));
  }
}
