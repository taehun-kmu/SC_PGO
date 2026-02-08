# Test Infrastructure

This directory contains the test infrastructure for the sc_pgo ROS2 package.

## Directory Structure

```
test/
├── CMakeLists.txt              # Master test configuration
├── cmake/
│   └── test_functions.cmake    # Reusable test CMake functions
├── unit/                       # Unit tests
│   ├── CMakeLists.txt
│   └── test_common.cpp
└── integration/                # Integration tests
    └── CMakeLists.txt
```

## Test Framework

The project uses **Catch2 v3** via the **catch_ros2** package for ROS2 Humble compatibility.

## Building Tests

```bash
colcon build --packages-select sc_pgo --cmake-args -DBUILD_TESTING=ON
```

## Running Tests

Run all tests:
```bash
colcon test --packages-select sc_pgo --event-handlers console_direct+
```

Run tests directly with CTest:
```bash
cd build/sc_pgo
ctest --output-on-failure
```

List available tests:
```bash
cd build/sc_pgo
ctest --show-only
```

## Test Targets

The build system creates the following test targets:

- **Individual tests**: `sc_pgo__test__<type>__<path>`
  - Example: `sc_pgo__test__unit__test_common`
- **Type aggregates**: `sc_pgo__test__<type>__all`
  - Example: `sc_pgo__test__unit__all`
- **Master target**: `sc_pgo__test__all` (all tests combined)

## Writing Tests

### File Organization

Tests mirror the source directory structure:

- Unit tests: `test/unit/<module_path>/<class_name>.cpp`
- Integration tests: `test/integration/<module_path>/<feature_name>.cpp`

### Test Structure

Follow the AAA (Arrange-Act-Assert) pattern:

```cpp
TEST_CASE("Function description", "[module-name]") {
  SECTION("specific behavior description") {
    // Arrange: Set up test preconditions
    const int input = 5;
    const int expected = 10;

    // Act: Execute the code being tested
    const int actual = function_under_test(input);

    // Assert: Verify results match expectations
    REQUIRE(actual == expected);
  }
}
```

### Naming Conventions

- **TEST_CASE names**: Descriptive phrases in title case
- **SECTION names**: Lowercase phrases describing specific behavior
- **Tags**: Lowercase, match module name (e.g., `[common]`)
- **Integration tests**: Include `[integration]` tag

### Adding New Tests

1. Create test file in appropriate directory:
   - Unit test: `test/unit/<path>/<name>.cpp`
   - Integration test: `test/integration/<path>/<name>.cpp`

2. Add to corresponding CMakeLists.txt:
   ```cmake
   process_test_type(unit
     SOURCES
       existing_test.cpp
       new_test.cpp  # Add here
   )
   ```

3. Build and verify:
   ```bash
   colcon build --packages-select sc_pgo
   colcon test --packages-select sc_pgo
   ```

## Test Functions

The `test/cmake/test_functions.cmake` file provides:

- `normalize_test_name(SOURCE_PATH OUTPUT_VAR)` - Convert file path to target name
- `create_test_executable(TARGET SOURCES)` - Create test executable with standard configuration
- `process_test_type(TEST_TYPE SOURCES ...)` - Process test type directory

## Standards

Tests follow the project's testing standards documented in:

- `context/standard/testing/patterns/aaa-pattern.md`
- `context/standard/testing/organization/file-structure.md`
- `context/specification/testing/organization/naming.md`
- `context/standard/testing/ros2/environment/cmake-integration.md`
