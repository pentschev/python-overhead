#!/bin/bash

POSITIONAL_ARGS=()

RUN_CPP=1
RUN_CUDA=1
RUN_PYTHON=1

function print_usage() {
  echo "Usage: ${0} [-h|--help] [--skip-c++] [--skip-cuda] [--skip-python] NUMBER_OF_ITERATIONS"
}

while [[ $# -gt 0 ]]; do
  case $1 in
    --skip-c++)
      RUN_CPP=0
      shift
      ;;
    --skip-cuda)
      RUN_CUDA=0
      shift
      ;;
    --skip-python)
      RUN_PYTHON=0
      shift
      ;;
    -h|--help)
      print_usage
      exit 0
      ;;
    -*|--*)
      echo -e "Unknown option $1\n"
      print_usage
      exit 1
      ;;
    *)
      POSITIONAL_ARGS+=("$1")
      shift
      ;;
  esac
done

set -- "${POSITIONAL_ARGS[@]}"

ITERATIONS="${POSITIONAL_ARGS[0]:-1000000}"
REPO_DIR=$(dirname -- "${BASH_SOURCE[0]}")

if [[ $RUN_CPP -ne 0 ]]; then
  pushd cpp > /dev/null
  echo -e "\e[1mCleaning C++ binaries and rebuilding\e[0m"
  make clean && make

  echo -e "\n\e[1mMeasuring C++ function call runtimes\e[0m"
  ./time_extern ${ITERATIONS}
  ./time_inline ${ITERATIONS}
  popd > /dev/null
else
  echo -e "\n\e[1mSkipping C++ runtimes\e[0m"
fi

if [[ $RUN_PYTHON -ne 0 ]]; then
  echo -e "\n\e[1mMeasuring Python function call runtimes\e[0m"
  python python/time-sync.py ${ITERATIONS}
  python python/time-asyncio.py ${ITERATIONS}
  python python/time-uvloop.py ${ITERATIONS}
  python python/time-asyncio-future.py ${ITERATIONS}
  python python/time-uvloop-future.py ${ITERATIONS}
  python python/time-asyncio-task.py ${ITERATIONS}
  python python/time-uvloop-task.py ${ITERATIONS}
else
  echo -e "\n\e[1mSkipping Python runtimes\e[0m"
fi

if [[ $RUN_CUDA -ne 0 ]]; then
  pushd cuda > /dev/null
  echo -e "\n\e[1mCleaning CUDA binaries and rebuilding\e[0m"
  make clean && make

  echo -e "\n\e[1mMeasuring CUDA kernel launch runtimes\e[0m"
  ./time_kernel_launch ${ITERATIONS}
  popd > /dev/null
else
  echo -e "\n\e[1mSkipping CUDA kernel launch runtimes\e[0m"
fi
