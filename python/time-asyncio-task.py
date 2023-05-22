import asyncio
import gc
import sys
import timeit


async def noop():
    pass


async def cpu_task():
    if len(sys.argv) != 2:
        print(f"Usage: python {sys.argv[0]} NUMBER_OF_ITERATIONS")
        sys.exit(1)

    iterations = int(sys.argv[1])

    gc.disable()

    t0 = timeit.default_timer()
    for _ in range(iterations):
        await asyncio.create_task(noop())
    t1 = timeit.default_timer()

    total = t1 - t0
    average_ns = ((t1 - t0) / iterations) * 1e9

    print(f"Python (asyncio task) total [average] runtime for {iterations} iterations: {t1-t0}s [{average_ns}ns]")


asyncio.new_event_loop().run_until_complete(cpu_task())
