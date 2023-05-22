ITERATIONS="${1:-1000000}"
REPO_DIR=$(dirname -- "${BASH_SOURCE[0]}")

pushd cpp > /dev/null
echo -e "\e[1mCleaning binaries and rebuilding\e[0m"
make clean && make

echo -e "\n\e[1mMeasuing C++ function call runtimes\e[0m"
./time_extern ${ITERATIONS}
./time_inline ${ITERATIONS}
popd > /dev/null

echo -e "\n\e[1mMeasuring Python function call runtimes\e[0m"
python python/time-sync.py ${ITERATIONS}
python python/time-async.py ${ITERATIONS}
python python/time-asyncio-task.py ${ITERATIONS}
