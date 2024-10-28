# Overhead Comparison

This project aims at comparing the overhead of different Python function calls and C++ function calls.

Writing good Python bindings requires careful thinking of its overhead. Generally speaking, Python will be as efficient as C or C++ provided that tasks run for long enough, thus hiding the latency required by such calls.

## C

To establish a baseline for what are the minimal costs of a function call for a given platform, this project provides C++ code (mostly for the `std::chrono` dependency) but with pure C no-op function calls. There are currently two samples:

1. `time_inline`: the `noop` function is an inlined part of the executably binary;
1. `time_extern`: the `noop` function is contained in shared library that is linked to the binary.

### Ensuring function calls are not optimized out

To reliably measure the overhead of a function call we must make sure it's not being optimized out, in which case we would be not measuring anything.

There are two ways we can confirm the function call is not being optimized out, the first of the is dumping the assembly code for the binaries and the second is running and breaking at the function call.

#### Dumping the assembly code

To do so, first run `make dump`:

```
$ cd cpp
$ make dump
```

The commands above will compile the binaries and dump the `time_extern.s` and `time_inline.s` files containing the assembly code. Once the assembly is generated, we can check that it's actually calling the `noop` function:


```
$ grep noop time_extern.s
0000000000002050 <noop()@plt>:
    2050:       ff 25 c2 2f 00 00       jmp    *0x2fc2(%rip)        # 5018 <noop()@Base>
    23a8:       e8 a3 fc ff ff          call   2050 <noop()@plt>
$ grep noop time_inline.s
00000000000022fa <noop()>:
    239f:       e8 56 ff ff ff          call   22fa <noop()>
```

See above how both assembly files actually call the `noop()` function, confirming we're indeed measuring what we expect. Also note that the `time_extern.s` has an `@plt` directive which means [Procedure Linkage Table](https://refspecs.linuxfoundation.org/ELF/zSeries/lzsabi0_zSeries/x2251.html), confirming it's actually calling the function from the linked library.

#### Breaking at the function call

The second way to confirm `noop` is called is to actually break at it. To do so we will use gdb to set a breakpoint at `noop`, run `./time_extern 1` and exit:

```
$ gdb -q -ex "set confirm off" -ex "break noop" -ex "run" -ex "quit" --args ./time_extern 1
Reading symbols from ./time_extern...
(No debugging symbols found in ./time_extern)
Breakpoint 1 at 0x2050
Starting program: /datasets/pentschev/src/python-overhead/cpp/time_extern 1

Breakpoint 1, 0x0000555555556050 in noop()@plt ()
```

Above we see that the breakpoint was triggered at `noop()@plt` as expected. Similarly we see breaking at `noop()` when running `time_inline`:

```
$ gdb -q -ex "set confirm off" -ex "b noop" -ex "run" -ex "quit" --args ./time_inline 1
Reading symbols from ./time_inline...
(No debugging symbols found in ./time_inline)
Breakpoint 1 at 0x22fe
Starting program: /datasets/pentschev/src/python-overhead/cpp/time_inline 1

Breakpoint 1, 0x00005555555562fe in noop() ()
```

## Python

Python provides a variety of ways to write code as well as providing concurrency. Thus we want to understand the costs of each one of them, and therefore we currently provide three types of function calls to measure:

1. `python/python-sync.py`: measures runtime of synchronous Python functions;
1. `python/python-async.py`: measures runtime of asynchronous Python coroutines;
1. `python/python-asyncio-task.py`: measures runtime of `asyncio` Python tasks;

## CUDA

Although generally quick given the amount of work a single CUDA kernel generally performs, launching kernels has also a cost, thus a sample `cuda/time_kernel_launch` is included to measure runtime of kernel launches.

## Running

A script to measure all runtimes is provided for convenience. It will build C++ binaries and run them, followed by running the Python scripts. A sample output is provided below:

```
$ ./run_all.sh 1000000
Cleaning binaries and rebuilding
rm -f *.o *.so *.s
rm -f time_extern time_inline
g++ -shared -o libnoop.so noop.cpp
g++ -fPIC -Wall -Wextra -DEXTERN -L/datasets/pentschev/src/python-overhead/cpp -lnoop -Wl,-rpath,/datasets/pentschev/src/python-overhead/cpp time.cpp -o time_extern
g++ -fPIC -Wall -Wextra time.cpp -o time_inline

Measuring C++ function call runtimes
C++ (externally linked) total [average] runtime for 1000000 iterations: 0.001975s [1.975ns]
C++ (inlined) total [average] runtime for 1000000 iterations: 0.002149s [2.149ns]

Measuring Python function call runtimes
Python (sync) total [average] runtime for 1000000 iterations: 0.05136413965374231s [51.36413965374231ns]
Python (async coroutine) total [average] runtime for 1000000 iterations: 0.13169546704739332s [131.69546704739332ns]
Python (async coroutine) total [average] runtime for 1000000 iterations: 0.13246881309896708s [132.46881309896708ns]
Python (asyncio task) total [average] runtime for 1000000 iterations: 9.685273353010416s [9685.273353010416ns]
Python (uvloop task) total [average] runtime for 1000000 iterations: 3.9662010883912444s [3966.2010883912444ns]

Cleaning CUDA binaries and rebuilding
rm -f time_kernel_launch
nvcc  time_kernel_launch.cu -o time_kernel_launch

Measuring CUDA kernel launch runtimes
CUDA kernel launch total [average] runtime for 1000000 iterations: 2.20963s [2209.63ns]
```

Note that we passed `1000000` as argument for `run_all.sh`, that indicates the number of iterations we want to measure runtimes for, if omitted it defaults to `1000000`.

The `run_all.sh` script has also flags to skip the individual test families, please run `./run_all.sh --help` to see the correct options.
