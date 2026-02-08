# Master Test Configuration
#
# This file coordinates all test types and creates aggregate targets.

# Process each test type directory
foreach(test_type ${TEST_TYPES})
  if(IS_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/${test_type})
    add_subdirectory(${test_type})
  endif()
endforeach()

# Create aggregate targets for each test type
foreach(test_type ${TEST_TYPES})
  get_property(sources GLOBAL PROPERTY ${PROJECT_NAME}_${test_type}_SOURCES)
  if(sources)
    # Create aggregate target for this test type
    set(aggregate_target ${PROJECT_NAME}__test__${test_type}__all)
    create_test_executable(${aggregate_target} "${sources}")

    # Register aggregate test with longer timeout
    add_test(NAME ${aggregate_target} COMMAND ${aggregate_target})
    set_tests_properties(${aggregate_target} PROPERTIES
      TIMEOUT 60
      WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    )
  endif()
endforeach()

# Create master test target combining all test types
set(all_sources "")
foreach(test_type ${TEST_TYPES})
  get_property(sources GLOBAL PROPERTY ${PROJECT_NAME}_${test_type}_SOURCES)
  if(sources)
    list(APPEND all_sources ${sources})
  endif()
endforeach()

if(all_sources)
  set(master_target ${PROJECT_NAME}__test__all)
  create_test_executable(${master_target} "${all_sources}")

  # Register master test with extended timeout
  add_test(NAME ${master_target} COMMAND ${master_target})
  set_tests_properties(${master_target} PROPERTIES
    TIMEOUT 90
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
  )

  # This is the target used for coverage reports
  if(ENABLE_COVERAGE)
    message(STATUS "Coverage enabled for master test target: ${master_target}")
  endif()
endif()
