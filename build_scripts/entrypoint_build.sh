#!/usr/bin/env bash
set -eux

# setting up git
git config --global user.email "build@pytorch.org"
git config --global user.name "PyTorch Builder"

# cloning pytorch builder
git clone https://github.com/pytorch/builder /builder
if [[ -n "$BUILDER_REVISION" ]]; then
    pushd .
    cd /builder
    echo "Checking out builder revision $BUILDER_REVISION"
    git checkout "$BUILDER_REVISION"
    popd
fi

# cloning pytorch in the proper place in the docker
git clone -b "v${PYTORCH_VERSION}" --recursive https://github.com/pytorch/pytorch.git /pytorch

# Begin exports
export TZ=UTC
export PYTORCH_BUILD_VERSION="${PYTORCH_VERSION}"
echo "Running on $(uname -a) at $(date)"
export PACKAGE_TYPE="manywheel"
export DESIRED_PYTHON="$DESIRED_PYTHON"
export DESIRED_CUDA="cu${CUDA_VERSION_NO_DOT}"
export LIBTORCH_VARIANT="${LIBTORCH_VARIANT:-}"
export BUILD_PYTHONLESS="${BUILD_PYTHONLESS:-}"
export DESIRED_DEVTOOLSET="$DESIRED_DEVTOOLSET"
export DATE="$(date -u +%Y%m%d)"

export PYTORCH_BUILD_VERSION="${PYTORCH_VERSION}+${DESIRED_CUDA}"
export PYTORCH_BUILD_NUMBER="1"
export OVERRIDE_PACKAGE_VERSION="$PYTORCH_BUILD_VERSION"
# TODO: We don't need this anymore IIUC
export TORCH_PACKAGE_NAME='torch'
export USE_FBGEMM=1


JAVA_HOME=
BUILD_JNI=OFF
if [[ "$PACKAGE_TYPE" == libtorch ]]; then
  POSSIBLE_JAVA_HOMES=()
  POSSIBLE_JAVA_HOMES+=(/usr/local)
  POSSIBLE_JAVA_HOMES+=(/usr/lib/jvm/java-8-openjdk-amd64)
  POSSIBLE_JAVA_HOMES+=(/Library/Java/JavaVirtualMachines/*.jdk/Contents/Home)
  # Add the Windows-specific JNI path
  POSSIBLE_JAVA_HOMES+=("$PWD/.circleci/windows-jni/")
  for JH in "${POSSIBLE_JAVA_HOMES[@]}" ; do
    if [[ -e "$JH/include/jni.h" ]] ; then
      # Skip if we're not on Windows but haven't found a JAVA_HOME
      if [[ "$JH" == "$PWD/.circleci/windows-jni/" && "$OSTYPE" != "msys" ]] ; then
        break
      fi
      echo "Found jni.h under $JH"
      JAVA_HOME="$JH"
      BUILD_JNI=ON
      break
    fi
  done
  if [ -z "$JAVA_HOME" ]; then
    echo "Did not find jni.h"
  fi
fi
export JAVA_HOME=$JAVA_HOME
export BUILD_JNI=$BUILD_JNI

# Pick docker image
export DOCKER_IMAGE=${DOCKER_IMAGE:-}
if [[ -z "$DOCKER_IMAGE" ]]; then
    export DOCKER_IMAGE="pytorch/manylinux-cuda${DESIRED_CUDA:2}"
fi

USE_GOLD_LINKER="OFF"
# GOLD linker can not be used if CUPTI is statically linked into PyTorch, see https://github.com/pytorch/pytorch/issues/57744
if [[ ${DESIRED_CUDA} == "cpu" ]]; then
  USE_GOLD_LINKER="ON"
fi

USE_WHOLE_CUDNN="OFF"
# Link whole cuDNN for CUDA-11.1 to include fp16 fast kernels
if [[  "$(uname)" == "Linux" && "${DESIRED_CUDA}" == "cu111" ]]; then
  USE_WHOLE_CUDNN="ON"
fi
export USE_GLOO_WITH_OPENSSL="ON"

export workdir="/"
export PYTORCH_ROOT="$workdir/pytorch"
export BUILDER_ROOT="$workdir/builder"

export PYTORCH_FINAL_PACKAGE_DIR="/remote"

export MAX_JOBS=${MAX_JOBS:-$(( $(nproc) - 2 ))}

if [[ "${DESIRED_CUDA}" == cu11* ]]; then
  export BUILD_SPLIT_CUDA="ON"
fi

export OVERRIDE_TORCH_CUDA_ARCH_LIST="3.5;3.7;5.0;6.0;7.0"
case ${CUDA_VERSION} in
    11.[123])
        export OVERRIDE_TORCH_CUDA_ARCH_LIST="${OVERRIDE_TORCH_CUDA_ARCH_LIST};7.5;8.0;8.6"
        ;;
    11.0)
        export OVERRIDE_TORCH_CUDA_ARCH_LIST="${OVERRIDE_TORCH_CUDA_ARCH_LIST};7.5;8.0"
        ;;
    10.*)
        export OVERRIDE_TORCH_CUDA_ARCH_LIST="${OVERRIDE_TORCH_CUDA_ARCH_LIST}"
        ;;
    9.*)
        export OVERRIDE_TORCH_CUDA_ARCH_LIST="${OVERRIDE_TORCH_CUDA_ARCH_LIST}"
        ;;
    *)
        echo "unknown cuda version $CUDA_VERSION"
        exit 1
        ;;
esac
# End exports

SKIP_ALL_TESTS=1 "/builder/manywheel/build.sh"
