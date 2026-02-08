#!/usr/bin/env bash
#
# SC_PGO_ROS2 Local CI Runner
# Runs the same CI pipeline as GitHub Actions in a Docker container
# Uses colcon + ament_cmake build system
#
# Usage:
#   ./ci/run.sh              # Run full CI pipeline
#   ./ci/run.sh --rebuild    # Rebuild without cache
#   ./ci/run.sh --base-only  # Build base image only
#   ./ci/run.sh --shell      # Start interactive shell in container
#

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
BASE_IMAGE="sc_pgo-ci-base"
CI_IMAGE="sc_pgo-ci"

# Parse arguments
REBUILD=false
BASE_ONLY=false
SHELL_MODE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --rebuild)
            REBUILD=true
            shift
            ;;
        --base-only)
            BASE_ONLY=true
            shift
            ;;
        --shell)
            SHELL_MODE=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --rebuild     Rebuild images without cache"
            echo "  --base-only   Build base image only"
            echo "  --shell       Start interactive shell in container"
            echo "  -h, --help    Show this help message"
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            exit 1
            ;;
    esac
done

log_header() {
    echo ""
    echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
}

log_success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

log_info() {
    echo -e "${YELLOW}[INFO]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_timestamp() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
}

# Check Docker is running
check_docker() {
    if ! docker info > /dev/null 2>&1; then
        log_error "Docker is not running. Please start Docker Desktop."
        exit 1
    fi
    log_success "Docker is running"
}

# Build base image
build_base_image() {
    log_header "Building Base Image: ${BASE_IMAGE}"

    local cache_arg=""
    if [ "$REBUILD" = true ]; then
        cache_arg="--no-cache"
        log_info "Building without cache"
    fi

    cd "${PROJECT_ROOT}"

    # Copy .dockerignore to project root for base build
    cp "${SCRIPT_DIR}/.dockerignore" "${PROJECT_ROOT}/.dockerignore"

    docker build ${cache_arg} \
        -f "${SCRIPT_DIR}/Dockerfile.base" \
        -t "${BASE_IMAGE}:latest" \
        .

    # Clean up
    rm -f "${PROJECT_ROOT}/.dockerignore"

    log_success "Base image built successfully"
}

# Build CI image
build_ci_image() {
    log_header "Building CI Image: ${CI_IMAGE}"
    log_info "Using colcon + ament_cmake build system"

    local cache_arg=""
    if [ "$REBUILD" = true ]; then
        cache_arg="--no-cache"
        log_info "Building without cache"
    fi

    cd "${PROJECT_ROOT}"

    # Copy .dockerignore to project root
    cp "${SCRIPT_DIR}/.dockerignore" "${PROJECT_ROOT}/.dockerignore"

    docker build ${cache_arg} \
        -f "${SCRIPT_DIR}/Dockerfile" \
        -t "${CI_IMAGE}:latest" \
        .

    # Clean up
    rm -f "${PROJECT_ROOT}/.dockerignore"

    log_success "CI image built successfully"
}

# Run ROS2 tests and linters
run_ros2_tests() {
    log_header "Running ROS2 Tests and Linters"
    log_timestamp "Starting test suite"

    docker run --rm "${CI_IMAGE}:latest" \
        bash -c "source /opt/ros/humble/setup.bash && cd /ros2_ws && colcon test --event-handlers console_direct+ --return-code-on-test-failure"

    log_timestamp "Showing test results"
    docker run --rm "${CI_IMAGE}:latest" \
        bash -c "source /opt/ros/humble/setup.bash && cd /ros2_ws && colcon test-result --verbose"

    log_success "All tests and linters passed"
}

# Start interactive shell
start_shell() {
    log_header "Starting Interactive Shell"
    log_info "Type 'exit' to leave the container"

    cd "${PROJECT_ROOT}"

    # Copy .dockerignore to project root
    cp "${SCRIPT_DIR}/.dockerignore" "${PROJECT_ROOT}/.dockerignore"

    docker run --rm -it \
        -v "${PROJECT_ROOT}:/workspace" \
        "${BASE_IMAGE}:latest" \
        /bin/bash

    # Clean up
    rm -f "${PROJECT_ROOT}/.dockerignore"
}

# Main
main() {
    log_header "Local CI Runner"
    log_info "Project: ${PROJECT_ROOT}"
    log_timestamp "CI pipeline started"

    check_docker

    # Check if base image exists
    if ! docker image inspect "${BASE_IMAGE}:latest" > /dev/null 2>&1 || [ "$REBUILD" = true ]; then
        build_base_image
    else
        log_info "Using existing base image (use --rebuild to rebuild)"
    fi

    if [ "$BASE_ONLY" = true ]; then
        log_success "Base image build complete"
        exit 0
    fi

    if [ "$SHELL_MODE" = true ]; then
        start_shell
        exit 0
    fi

    # Full CI pipeline
    build_ci_image
    run_ros2_tests

    log_header "CI Pipeline Complete"
    log_timestamp "All validation stages completed"
    log_success "All checks passed!"
}

main
