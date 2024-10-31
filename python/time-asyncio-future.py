import asyncio
import gc
import sys
import timeit


async def noop(fut):
    fut.set_result(None)


async def cpu_task():
    if len(sys.argv) != 2:
        print(f"Usage: python {sys.argv[0]} NUMBER_OF_ITERATIONS")
        sys.exit(1)

    iterations = int(sys.argv[1])

    gc.disable()

    loop = asyncio.get_running_loop()

    t0 = timeit.default_timer()
    for _ in range(iterations):
        fut = loop.create_future()
        await noop(fut)
    t1 = timeit.default_timer()

    total = t1 - t0
    average_ns = ((t1 - t0) / iterations) * 1e9

    print(f"Python (asyncio coroutine with future) total [average] runtime for {iterations} iterations: {t1-t0}s [{average_ns}ns]")


asyncio.new_event_loop().run_until_complete(cpu_task())
