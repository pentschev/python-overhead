import gc
import itertools
import sys
import timeit


def noop():
    pass


def cpu_sync():
    if len(sys.argv) != 2:
        print(f"Usage: python {sys.argv[0]} NUMBER_OF_ITERATIONS")
        sys.exit(1)

    iterations = int(sys.argv[1])

    gc.disable()

    t0 = timeit.default_timer()
    for _ in itertools.repeat(None, iterations):
        noop()
    t1 = timeit.default_timer()

    total = t1 - t0
    average_ns = ((t1 - t0) / iterations) * 1e9

    print(f"Python (sync) total [average] runtime for {iterations} iterations: {t1-t0}s [{average_ns}ns]")


cpu_sync()
