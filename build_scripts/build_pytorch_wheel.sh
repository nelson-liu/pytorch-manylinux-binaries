#!/usr/bin/env bash
set -eux

desired_python="$1"
desired_cuda="$2"
pytorch_version="$3"
builder_revision="$4"
docker_image="$5"


if [ -n "${docker_image}" ]; then
  echo "Using docker image ${docker_image}"
else
  echo "Docker image not supplied, using pytorch/manylinux-cuda${CUDA_VERSION_NO_DOT}"
  docker_image="pytorch/manylinux-cuda${CUDA_VERSION_NO_DOT}"
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
    ${docker_image}
