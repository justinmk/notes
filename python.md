CONCEPTS
================================================================================

## Is python single-threaded?

No. Even with the GIL, the active thread can change at any time between bytecode
instructions.

    n = 1
    n = n + 1
    assert n = 2

If you run this in many threads it will fail eventually, when one thread assigns
`n=1` then gets interrupted by a different thread checking `assert`.
In JavaScript every called function is executed until it returns, throws, or
awaits (and same for every await continuation).

Because of the GIL, only one thread can execute Python code. But threads can be preempted between bytecode instructions.
Even though only one thread can execute bytecode at a time, another thread can take over between bytecode instructions, leading to race conditions.
This is why Python still needs thread synchronization primitives (locks, semaphores, etc.) at the application level.

Then what is the purpose of the GIL?
- GIL protects:
    - Python's internal state, reference-counting, memory allocations
    - Non-thread-safe C API operations
- GIL does *not* protect:
    - Python-level operations that require multiple bytecode instructions.
      E.g. `n+=1` is three instructions (Load, Add, Store).
    - User-level data structures

"You can write multi-threaded code in JavaScript using `worker_threads`?"
- Worker threads and webworkers don't change the behavior of JavaScript:
    - Each thread is an isolated JavaScript application with distinct memory.
    - Thread A will never modify a value in thread B, the `n=n+1` example is still safe in JavaScript.
    - Exception: threads can refer to the same memory via `SharedArrayBuffer`.

LIBRARIES
================================================================================
date/time: https://github.com/dateutil/dateutil

DEBUGGING
================================================================================
https://wiki.python.org/moin/DebuggingWithGdb
    # Python debugging extensions: debugging symbols and gdb commands (py-xx).
    $ apt install python3.5-dbg
    $ gdb $(which python3) 19284
    (gdb) py-bt
    (gdb) py-list

Fancy TUI debugger:  https://github.com/pdbpp/pdbpp

? https://github.com/cool-RR/PySnooper


MEMORY LEAKS
================================================================================
objgraph: https://www.darkcoding.net/software/finding-memory-leaks-in-python-with-objgraph/
tracemalloc (Python 3.6+): https://docs.python.org/3/library/tracemalloc.html


string format(), f-string
================================================================================
    f'{datetime.datetime.now():%m-%d-%y}'   # instead of datetime.stftime()
    f'{878:b}'      => '1101101110'         # base-2
    f'{878:x}'      => '36e'                # base-16
    f'{878:e}'      => '8.780000e+02'       # sci notation
    f'{1/3:?=8.2f}' => '????0.33'           # pad, fill, precision
    f'{"foo":^10}'  => '   foo    '         # center text


asyncio
================================================================================
* `await` on a coroutine (more generally an "awaitable") yields to the event-loop.
  * Example: `await asyncio.sleep(2)` does not block the loop, it yields and
    schedules a Future on the loop for the specified time. When the Future
    is executed, control is restored and the caller is unblocked.
    source: https://github.com/python/cpython/blob/cca4eec3c0a67cbfeaf09182ea6c097a94891ff6/Lib/asyncio/tasks.py#L580
* Event loop does not preempt, only a coroutine can pause itself.
* Calling a coroutine initializes (not executes) it.
* asyncio.sleep is a coroutine.

https://news.ycombinator.com/item?id=17714304
    - asyncio is mostly very low level. you probably don't want to use it directly. E.G: for http requests, use aiohttp.
    - Use asyncio.run_until_complete(), not asyncio.run_forever(). The former will crash on any exception, making debugging easy.
    - Activate the various debug features when not in prod (https://docs.python.org/3/library/asyncio-dev.html#debug-mode-of-asyncio).
    - CPU intensive code blocks the event loop. loop.run_in_executor() use threads by default, hence it doesn't protect you from that. If you have CPU intensive code, like zipping a lot of files or calculating your own precious fibonacci, create a "ProcessPoolExecutor" and use run_in_executor() with it.
    - Don't use asyncio before Python 3.5.3. There is a incredibly major bug with "asyncio.get_event_loop()" that makes it unusable for anything that involve mixing threads and loops.
    CONCEPTS:
        * Future: thing to execute.
        * Task: subclass of future. The thing to execute is a coroutine, and the coroutine is immediately scheduled in the event loop when the task is instantiated. ensure_future(coroutine) returns a Task.
        * coroutine: generator with some syntaxic sugar.
        * coroutine function: function declared with "async def". Returns a coroutine.
        * awaitable: any object with an __await__ method. coroutines, tasks and futures are awaitables.
        * event loop: the magic "while True" loop that takes awaitables, and execute them.
        * executor: an object that takes code, execute it in a __different__
          context, and return a future you can await in your __current__
          context. You will use them to run stuff in threads or separate
          processes, but magically await the result in your current code like
          it's regular asyncio. It's very handy to naturally integrate blocking
          code in your workflow.

    asyncio.gather() is the most important function in asyncio
    -----------------------------------------------------------
    Never, ever, have an dangling awaitable.
    Always keep a reference on all your awaitables.
    Decide where in the code you think their life should end.

    asyncio.gather() will block until all awaitables are done.
    Don't:
        asyncio.ensure_future(bar())
        asyncio.get_event_loop().run_in_executor(None, barz)
        await asyncio.sleep(10)
    Do:
        foo = asyncio.ensure_future(bar())
        fooz = asyncio.get_event_loop().run_in_executor(None, barz)
        await asyncio.sleep(10)
        await asyncio.gather(foo, fooz)  # this is The One True Way

FEATURES
================================================================================
python "data model" (underscore methods, etc.): https://docs.python.org/3/reference/datamodel.html

iter()      # https://docs.python.org/3/library/functions.html#iter
partial()   # useful to create zero-argument lambdas
            from functools import partial
            with open('mydata.db', 'rb') as f:
                for block in iter(partial(f.read, 64), b''):
                    process_block(block)
next()      # goes to next `yield`

"generator comprehension"
            # () instead of []
            >>> a = (x for x in [1,2,3,4,5])
            >>> type(a)
            <class 'generator'>

inspect.getsource()
__code__    # reflect on user-defined functions
            def foo():
              a=42
              b='foo'
            foo.__code__.co_varnames  # ('a', 'b')

metaclass:  # manipulate class at define-time. cf. Java "classloader"
            class Foo(object, metaclass=something):

contextmanager:
            # Enforce ordered __init__, __enter__, __exit__ sequence.
            @contextlib.contextmanager
            def foo(*args, **kwds):
              r = get_resource(*args, **kwds)  # Acquire resource.
              try:
                yield r  # Context managers are generators!
              finally:
                release_resource(r)  # Release resource.
            with foo(timeout=3600) as r:
              ...

loop backwards:
  for o in reversed(foo):

custom sort:
  sorted(foo, key=len)  # "almost never need cmp=…"

initialize dicts with iterators
  d = dict(zip(foo, bar))
  d = dict(enumerate(foo))

extend dicts
  d = ChainMap(d1, d2, ...)

LRU cache (memoize): compare running time with/without @lru_cache decorator:
    import functools
    @functools.lru_cache(maxsize=512)
    def fib(n: int) -> int:
        if n < 2:
            return n
        return fib(n-1) + fib(n-2)
    >>> [fib(n) for n in range(16)]
    [0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, 377, 610]
    >>> fib.cache_info()
    CacheInfo(hits=28, misses=16, maxsize=512, currsize=16)

(3.7+) Data Classes  https://docs.python.org/3/library/dataclasses.html
    import dataclasses
    @dataclasses.dataclass
    class Foo:  # Don't need __init__()
        foo:  float
        bar:  int = 1
        name: str
    f = Foo(foo=0.3, bar=42, name='zub')
