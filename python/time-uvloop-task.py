import asyncio
import gc
import sys
import timeit


try:
    import uvloop
except ImportError:
    print("uvloop is not installed, skipping...")
    sys.exit(0)


async def noop():
    pass


async def cpu_task():
    if len(sys.argv) != 2:
        print(f"Usage: python {sys.argv[0]} NUMBER_OF_ITERATIONS")
        sys.exit(1)

    iterations = int(sys.argv[1])

    gc.disable()

    loop = asyncio.get_running_loop()

    t0 = timeit.default_timer()
    for _ in range(iterations):
        await loop.create_task(noop())
    t1 = timeit.default_timer()

    total = t1 - t0
    average_ns = ((t1 - t0) / iterations) * 1e9

    print(f"Python (uvloop task) total [average] runtime for {iterations} iterations: {t1-t0}s [{average_ns}ns]")


uvloop.new_event_loop().run_until_complete(cpu_task())
