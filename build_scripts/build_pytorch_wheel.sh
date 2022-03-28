#!/usr/bin/env bash
set -eux

if [[ "$#" != 4 ]]; then
  if [[ -z "$DESIRED_PYTHON" || -z "$DESIRED_CUDA" || -z "$PYTORCH_VERSION" || -z "$BUILDER_REVISION" ]]; then
      echo "The env variabled DESIRED_PYTHON must be set like '2.7mu' or '3.6m' etc"
      echo "The env variabled DESIRED_CUDA must be set like '11.1' or '10.2' etc"
      echo "The env variabled PYTORCH_VERSION must be set like '1.8.0' or '1.7.1' etc"
      echo "The env variabled BUILDER_REVISION must be set like 'master' or '4b78fd0f5bb0a2601146584239e377098cdc1ed9' etc"
      exit 1
  fi
  desired_python="$DESIRED_PYTHON"
  desired_cuda="$DESIRED_CUDA"
  pytorch_version="$PYTORCH_VERSION"
  builder_revision="$BUILDER_REVISION"
else
  desired_python="$1"
  desired_cuda="$2"
  pytorch_version="$3"
  builder_revision="$4"
fi

CUDA_VERSION_NO_DOT=$(echo $desired_cuda | tr -d '.')
MANYWHEELS_BUILD_DIR="_build/${pytorch_version}/manywheel/cu${CUDA_VERSION_NO_DOT}/"
DESIRED_DEVTOOLSET="devtoolset7"

cd "$(dirname "$0")"  # move inside the script directory
mkdir -p "${MANYWHEELS_BUILD_DIR}"
nvidia-docker pull "pytorch/manylinux-cuda${CUDA_VERSION_NO_DOT}"
nvidia-docker run --rm -it \
    --env CUDA_VERSION="${desired_cuda}" \
    --env CUDA_VERSION_NO_DOT="${CUDA_VERSION_NO_DOT}" \
    --env DESIRED_PYTHON="${desired_python}" \
    --env PYTORCH_VERSION="${pytorch_version}" \
    --env BUILDER_REVISION="${builder_revision}" \
    --env DESIRED_DEVTOOLSET="${DESIRED_DEVTOOLSET}" \
    --volume "$(pwd)/${MANYWHEELS_BUILD_DIR}:/remote" \
    --volume "$(pwd)/entrypoint_build.sh:/entrypoint_build.sh" \
    --entrypoint /entrypoint_build.sh \
    "pytorch/manylinux-cuda${CUDA_VERSION_NO_DOT}"
