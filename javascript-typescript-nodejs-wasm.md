JAVASCRIPT
==============================================================================
<!--
vim: sw=2 expandtab
-->

## globals

- `globalThis` https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/globalThis
  global object (usually `window`, in nodejs module scope) which always exists in the global scope.
  `var` (but not `let` and `const`) creates variables as properties of the global object.

## Agents

JS engine "agents" execute JavaScript. Each agent has:
- execution contexts
  - nodejs(?) use case: you can record the "entry-point" for a task in its
    execution context, then later retrieve it from any function on the same
    microtask callstack.
- execution context stack
- main thread
- task queue
- microtask queue
- additional threads that may be created to handle workers

## Event loops

- Window event loop
  - windows from the same origin MAY share the same event loop
    - If one window opened the other window, they are likely to share an event loop.
    - `<iframe>` window likely shares an event loop with its parent window.
  - "window" means "browser-level container that runs web content"
- Worker event loop
  - workers MAY share a single event loop
- Worklet event loop

## Event loop: lifecycle ("processing model")

https://html.spec.whatwg.org/multipage/webappapis.html#event-loop-processing-model

1. Do the oldest (macro) task
2. Do microtasks
3. If this is a good time to render:
    - Do some prep work
    - Run requestAnimationFrame callbacks
    - Render

## Event loop: tasks vs microtasks

https://developer.mozilla.org/en-US/docs/Web/API/HTML_DOM_API/Microtask_guide/In_depth

- Task: any JavaScript scheduled by standard mechanisms (setTimeout(), requestAnimationFrame(), queueMicrotask()).
  - https://youtu.be/cCOL7MC4Pl0?t=940
    - requestAnimationFrame() = "edge-triggered" (executes at start of the animation frame).
    - setTimeout() = "level-triggered" (happens randomly during a frame)
- Task queue vs microtask queue:
  - Execution of TASKS continues until its queue is empty, *not including* any
    tasks queued _during_ this "tick".
  - Execution of MICROTASKS continues until its queue is empty, *including any
    new ones scheduled during this routine* (can be infinite).
  - When a TASK exits and the execution context stack is empty, each MICROTASK
    in the microtask queue is executed, one after another.
- queueMicrotask(callback)  https://developer.mozilla.org/en-US/docs/Web/API/queueMicrotask
  - what: queues a microtask to be executed before control returns to the browser event loop.
  - why: ability to perform tasks asynchronously but in a specific order.
  - when: useful for libraries and frameworks that need to perform final cleanup or other just-before-rendering tasks.
  - Almost as fast as a synchronous call (much more efficient than setTimeout(fn,0)).
  - potential infinite loop / IO starvation
  - Errors thrown from a microtask callback should be handled in the callback. Else use process.on('uncaughtException')

## Promises

- Unhandled promise rejections, uncaught exceptions
  - https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Using_promises
  - common mistakes:
    - not "chaining" (creating a new promise but forgetting to return it).
    - forgetting to terminate chains with catch(). Unterminated promise chains
      lead to uncaught promise rejections.
  - guideline: always either `return` or terminate promise chains (with
    `.catch()`), and as soon as you get a new promise, return it immediately,
    to flatten things:
    ```
    doSomething()
      .then(function (result) {
        // return the promise
        return doSomethingElse(result);
      })
      // arrow functions without braces implicitly return the result
      .then((newResult) => doThirdThing(newResult))
      // Even if the previous chained promise returns a result, the next one
      // doesn't necessarily have to use it.
      .then((/* result ignored */) => doFourthThing())
      // Always end the promise chain with catch() to avoid unhandled rejections!
      .catch((error) => console.error(error));
    ```
  - The browser will look down the chain for .catch() handlers or onRejected:
    ```
    doSomething()
      .then((result) => doSomethingElse(result))
      .then((newResult) => doThirdThing(newResult))
      .then((finalResult) => console.log(`Got the final result: ${finalResult}`))
      .catch(failureCallback);
    ```
  - node.js: https://medium.com/@nodejs/node-js-promise-reject-use-case-survey-98e3328340c9
    - nodejs option: `--unhandled-rejection=strict`
    - global handlers:
      ```
      process.on('unhandledRejection'))
      process.on('uncaughtException')
      ```
      - Problem: any package/dependency can add its own handler!
        - VSCode extension can't use? https://github.com/microsoft/vscode/issues/93573


## Function calls, classes, and prototypes ([ref](https://gist.github.com/dfoverdx/2582340cab70cff83634c8d56b4417cd))

### Function calls and "this"

Demo:

```javascript
globalThis.name = 'x'
let f = function() { return this; };
let o1 = { name: 'o1', f };
let o2 = { name: 'o2', f };
let o1_f = o1.f;

console.log(o1.f === o2.f); // true
console.log(o1.f().name);   // 'o1'
console.log(o2.f().name);   // 'o2'
console.log(f().name);      // 'x'
console.log(o1_f().name);   // 'x'
```

Object `o` with member function `o.f` points-to `f`, but not the reverse: `f`
has no reference to `o`. So `this` in the body of `f` does _not_ reference `o`,
_unless_ you:
- Explicitly prefix each _call_ (`o.f()` instead of `f()`)
  - Prefixing the _value_ is irrelevant, only the _call_ matters: passing `o.f`
    as a parameter `p` and later calling `p()` won't work, because the _call_
    `p()` is not explicitly prefixed.
- Bind `f` to `o`: `let f2 = f.bind(o); f2();`
  - bind() also supports partial application, can do clever things like:
    ```
    // NB: console.error() expects `this` to be `window.console`.
    foo(…).catch(console.error.bind(console, 'foo: '))
    ```
  - If you want to bind all functions of a class/object you must iterate through
    `Object.getOwnPropertyNames()` or use something like https://github.com/sindresorhus/auto-bind

### Classes and prototypes

_Classes_ in JavaScript are just syntactic sugar to functions that (1) have
a `prototype` property and (2) implicitly return an object. When `new` is called
on the function, it calls the function and attaches everything in the function's
`prototype` to the returned object.

    class O {
      constructor(name) {
        this.name = name;
      }
      f() {
        return this;
      }
    }

is exactly equivalent to

    function O(name) {
      this.name = name;
    }
    O.prototype.f = function() {
      return this;
    }


## Proxy

  https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Proxy
    The Proxy object enables you to create a proxy for another object, which can
    intercept and redefine fundamental operations for that object.

  Observe/listen to field changes:

    private createReactive<T extends Record<string, any>>(obj: T): T {
      return new Proxy(obj, {
        set: (target, prop, val, recv) => {
          const last = Reflect.get(target, prop, recv)
          const success = Reflect.set(target, prop, val, recv)
          if (success && last !== val) {
            this.emitEvent()
          }
          return success
        }
      })
    }

## Symbol

- https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Symbol
- Symbols = Unique keys for objects:
  ```
  Symbol("foo") === Symbol("foo"); // false.
  ```
- Hidden from any mechanisms other code will typically use to access the object.
  - Symbol-keyed properties are completely ignored by `JSON.stringify()`.
  - Example:
    ```
    let object = {
        aNumber: 0,
        [Symbol.toPrimitive]() {  // cf. Object.prototype.valueOf
            return this.aNumber;
        }
    };
    object.aNumber = 5;
    console.log(object + 2)  // 7
    ```

## Various builtins

- object vs Map:  https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Map
- `String.matchAll`: Get multiple matches of a regular expression including their capture groups, without using a loop.
  ```
  const matchesIterator = stringVar.matchAll(/test([\w]+?),/g);
  // Must be iterated or converted to an array (Array.from()), no direct indexing.
  for (const match of matchesIterator) {
    console.log(match[0]); // "testhello,", "testagain,"
    console.log(match[1]); // "hello", "again"
  }
  ```
- `Promise.any()`: returns first _non-rejecting_ result; only rejects if all
  promises reject and returns an `AggregateError`, unlike Promise.race().
- `Promise.allSettled()`: unlike Promise.all(), does not return on the first reject/throw.
  ```
  async function success1() {return 'a'}
  async function success2() {return 'b'}
  async function fail1() {throw 'fail 1'}
  async function fail2() {throw 'fail 2'}

  const results = await Promise.allSettled([success1(), success2(), fail1(), fail2()]);
  const sucessfulResults = results
    .filter(result => result.status === 'fulfilled')
    .map(result => (result as PromiseFulfilledResult<string>).value);
  console.log(sucessfulResults); // ["a", "b"]
  results.filter(result => result.status === 'rejected').forEach(error => {
    console.log((error as PromiseRejectedResult).reason); // "fail 1", "fail 2"
  });
  ```
- BigInt: The new `BigInt` data type accurately stores and operates
  on very large integers. Use the `BigInt()` constructor (preferably with string)
  or by appending `n` to a number literal.
  ```
  const correctAgain = 9007199254740993n;
  console.log(correctAgain); // 9007199254740993
  // hex, octal and binary numbers can also be passed as strings.
  const hex = BigInt('0x1fffffffffffff');
  ```
- WeakRef: weak reference to an object, does not prevent the object from being
  garbage-collected.
  ```
  const ref = new WeakRef(element);
  // Get the value, if the object/element still exists and was not garbage-collected.
  const value = ref.deref;
  console.log(value); // undefined
  // Looks like the object does not exist anymore.
  ```
- Negative indexing (`.at(-1)`): When indexing an array or a string, `at()` can be
  used to index from the end. Equivalent to `arr[arr.length — 1])` for
  getting (but not setting) a value.
  ```
  console.log([4, 5].at(-1)) // 5
  const array = [4, 5];
  array.at(-1) = 3; // SyntaxError: Assigning to rvalue
  ```
- Use `hasOwn()` instead of `obj.hasOwnProperty()`.
  ```
  const obj = { name: 'test' };
  console.log(Object.hasOwn(obj, 'name')); // true
  ```
- Error _cause_: optional `cause` field on `Error`.
  ```
  try {
    try {
      connectToDatabase();
    } catch (err) {
      throw new Error('Connecting to database failed.', { cause: err });
    }
  } catch (err) {
    console.log(err.cause); // ReferenceError: connectToDatabase is not defined
  }
  ```


NODE.JS
==============================================================================

- known issue: "stdio buffered writes (chunked) issues & process.exit() truncation"
  - https://github.com/nodejs/node/issues/6456
  - workaround: https://www.npmjs.com/package/node-exit
- globals  https://nodejs.org/api/globals.html#globals_global
  - global
  - process
  - require()
- setImmediate(), process.nextTick(), …  https://nodejs.org/api/process.html#process_process_nexttick_callback_args
  - nextTick()
    - DEPRECATED. Use queueMicrotask().  https://nodejs.org/api/process.html#when-to-use-queuemicrotask-vs-processnexttick
    - queues a function BEFORE pending I/O callbacks
  - setImmediate()
    - DEPRECATED. Use queueMicrotask().  https://developer.mozilla.org/en-US/docs/Web/API/Window/setImmediate
    - queues a function AFTER pending I/O callbacks
    - yields to event loop after firing a queued callback to ensure I/O is not starved.

## Event loop: lifecycle  https://nodejs.org/en/docs/guides/event-loop-timers-and-nexttick/

> Between each run of the event-loop, Node.js checks if it is waiting for any
> asynchronous I/O or timers and shuts down cleanly if there are not any.

1. timers:            execute callbacks scheduled by setTimeout()/setInterval(), aka "tasks".
1. pending callbacks: execute I/O callbacks deferred to the next loop iteration.
1. idle, prepare:     only used internally.
1. poll:              gather new I/O events;
    - execute I/O callbacks (=> all callbacks except "close" callbacks, timer
      callbacks, and ~~setImmediate()~~ queueMicrotask()); node may block here.
1. check:             execute ~~setImmediate()~~ queueMicrotask() callbacks, aka "microtasks".
1. "close" callbacks:   some "close" callbacks, e.g. `socket.on('close', …)`.

## CONTEXTS  https://nodejs.org/api/async_context.html

- Used to associate state and propagate it throughout callbacks and promise
- chains. Store data in the lifetime of a web request or any other
- asynchronous duration. Similar to thread-local storage in other languages.
- AsyncLocalStorage and AsyncResource classes are part of the node:async_hooks module:
  ```
  import { AsyncLocalStorage, AsyncResource } from 'node:async_hooks';
  ```
- AsyncLocalStorage
  - Example usage: https://github.com/aws/aws-toolkit-vscode/blob/c7bd60e8329401e4def4ad2aa41cb271f1c2e94c/src/shared/telemetry/recorder.ts#L128-L136
    ```
    const store = new AsyncLocalStorage<ExecutionContext>()
    // Runs a function with context-specific observability utilities such as telemetry and logging.
    export function run<F extends (...args: any[]) => any>(name: string, fn: F, ...args: Parameters<F>): ReturnType<F> {
        const context = {
            name,
            logger: getLogger(),
            telemetry: { queue: [] },
        }
        return store.run(context, fn, ...args)
    }
    export function getTelemetryLogger<T extends keyof TelemetryLogger>(metric: T): TelemetryLogger[T] {
        const queue = storage.getStore()?.telemetry?.queue ?? []
        return createRecorder({}, metric, queue) as TelemetryLogger[T]
    }
    ```

TYPESCRIPT
==============================================================================
- https://basarat.gitbook.io/typescript/type-system/freshness
- Trace the type-checking and compilation process:
  ```
  tsc --generateTrace trace
  ```
- Declare a motherfucking map:
  ```
  const things: { [key: string]: boolean } = {}
  ```
- assert signatures
  ```
  function assertString(o: any): asserts o is string {  // <-- the magic
    if (typeof o !== 'string') {
      throw new Error('Input must be a string!');
    }
  }
  function doSomething(o: string | number) {
    assertString(o);
    // o's type narrows to "string".
  }
  ```
- `as const`: quasi-immutability for simple literal expressions.
  - https://www.typescriptlang.org/docs/handbook/release-notes/typescript-3-4.html#const-assertions
  - Tells the compiler to choose the NARROWEST type (literal "foo" instead of string).
    ```
    let x = "hello" as const;             // Typed as '"hello"' (not string)
    let y = [10, 20] as const;            // Typed as 'readonly [10, 20]' tuple (not array)
    let z = { text: "hello" } as const;   // Typed as '{ readonly text: "hello" }' (not object)
    ```
- optional chaining
  ```
  (null)?.key  // returns undefined (even if `null`!)
  ```

## Utility Types: type transformations/composition

Similar to Clojure (+spec), TypeScript’s structural type system is effectively “just use maps”.
https://www.typescriptlang.org/docs/handbook/utility-types.html

    interface Test {
      name: string;
      age: number;
    }
    // The Partial utility type makes all properties optional.
    type TestPartial = Partial<Test>; // typed as { name?: string | undefined; age?: number | undefined; }
    // The Required utility type does the opposite.
    type TestRequired = Required<TestPartial>; // typed as { name: string; age: number; }
    // The Readonly utility type makes all properties readonly.
    type TestReadonly = Readonly<Test>; // typed as { readonly name: string; readonly age: string }
    // The Record utility type allows the simple definition of objects/maps/dictionaries. It is preferred to index signatures whenever possible.
    const config: Record<string, boolean> = { option: false, anotherOption: true };
    // The Pick utility type gets only the specified properties.
    type TestLess = Pick<Test, 'name'>; // typed as { name: string; }
    type TestBoth = Pick<Test, 'name' | 'age'>; // typed as { name: string; age: string; }
    // The Omit utility type ignores the specified properties.type
    type TestFewer = Omit<Test, 'name'>; // typed as { age: string; }
    type TestNone = Omit<Test, 'name' | 'age'>; // typed as {}
    // The Parameters utility type gets the parameters of a function type.
    function doSmth(value: string, anotherValue: number): string {
      return 'test';
    }
    type Params = Parameters<typeof doSmth>; // typed as [value: string, anotherValue: number]
    // The ReturnType utility type gets the return type of a function type.
    type Return = ReturnType<typeof doSmth>; // typed as string
    // There are many more, some of which are introduced further down.

Conditional Types: Conditionally set a type based on if some type matches
/ extends another type. They can be read in the same way as the conditional
(ternary) operator in JavaScript.

    // Only extracts the array type if it is an array, otherwise returns the same type.
    type Flatten<T> = T extends any[] ? T[number] : T;
    // Extracts out the element type.
    type Str = Flatten<string[]>; // typed as string
    // Leaves the type alone.
    type Num = Flatten<number>; // typed as number

Inferring with conditional types: Not all generic types need to be specified by
the consumer, some can also be inferred from the code. To have conditional logic
based on inferred types, the `infer` keyword is needed. It in a way defines
temporary inferred type variables.

    // Starting with the previous example, this can be written more cleanly.
    type FlattenOld<T> = T extends any[] ? T[number] : T;
    // Instead of indexing the array, we can just infer the Item type from the array.
    type Flatten<T> = T extends (infer Item)[] ? Item : T;
    // If we wanted to write a type that gets the return type of a function and otherwise is undefined, we could also infer that.
    type GetReturnType<Type> = Type extends (...args: any[]) => infer Return ? Return : undefined;
    type Num = GetReturnType<() => number>; // typed as number
    type Str = GetReturnType<(x: string) => string>; // typed as string
    type Bools = GetReturnType<(a: boolean, b: boolean) => void>; // typed as undefined

Tuple Optional Elements and Rest: Declare optional elements in tuples using `?`
and the rest based on another type using `...`.

    // If we don't yet know how long a tuple is going to be, but it's at least one, we can specify optional types using `?`.
    const list: [number, number?, boolean?] = [];
    list[0] // typed as number
    list[1] // typed as number | undefined
    list[2] // typed as boolean | undefined
    list[3] // Type error: Tuple type '[number, (number | undefined)?, (boolean | undefined)?]' of length '3' has no element at index '3'.
    // We could also base the tuple on an existing type.
    // If we want to pad an array at the start, we could do that using the rest operator `...`.
    function padStart<T extends any[]>(arr: T, pad: string): [string, ...T] {
      return [pad, ...arr];
    }
    const padded = padStart([1, 2], 'test'); // typed as [string, number, number]

Template Literal Types: When defining literal types, types can be specified
through templating like `${Type}`. For complex string types.

    type VerticalDirection = 'top' | 'bottom';
    type HorizontalDirection = 'left' | 'right';
    type Direction = `${VerticalDirection} ${HorizontalDirection}`;
    const dir1: Direction = 'top left';
    const dir2: Direction = 'left'; // Type error: Type '"left"' is not assignable to type '"top left" | "top right" | "bottom left" | "bottom right"'.
    const dir3: Direction = 'left top'; // Type error: Type '"left top"' is not assignable to type '"top left" | "top right" | "bottom left" | "bottom right"'.
    // This can also be combined with generics and the new utility types.
    declare function makeId<T extends string, U extends string>(first: T, second: U): `${Capitalize<T>}-${Lowercase<U>}`;

Key Remapping in Mapped Types: Retype mapped types while still using their
values like `[K in keyof T as NewKeyType]: T[K]`.

    // Let's say we wanted to reformat an object but prepend its IDs with an underscore.
    const obj = { value1: 0, value2: 1, value3: 3 };
    const newObj: { [Property in keyof typeof obj as `_${Property}`]: number }; // typed as { _value1: number; _value2: number; value3: number; }

Recursive Conditional Types: Use conditional types inside of its definition
themselves. This allows for types that conditionally unpack an infinitely nested
value.

    type Awaited<T> = T extends PromiseLike<infer U> ? Awaited<U> : T;
    type P1 = Awaited<string>; // typed as string
    type P2 = Awaited<Promise<string>>; // typed as string
    type P3 = Awaited<Promise<Promise<string>>>; // typed as string

`Awaited<>` utility type extracts the value type from infinitely nested Promises.

    type P1 = Awaited<string>; // typed as string
    type P2 = Awaited<Promise<string>>; // typed as string
    type P3 = Awaited<Promise<Promise<string>>>; // typed as string



NPM
==============================================================================
webpack will use whatever is in node_modules regardless of where it came from.
Once bundled, it doesn't matter whether a dep was declared in package.json
"dependencies" or "devDependencies". dev-deps only matter when others consume
the package as a dependency.


WASM / WEBASSEMBLY
==============================================================================
webassembly is:
- a portable compilation target
- a binary instruction format for a stack-based VM.

features:
- structured control flow (can't jump to arbitrary code locations (=unstructured))
- support for streaming compilation, allows the downloaded module to have near instant instantiation.
- sandboxed [execution environments], can run arbitrary untrusted code.
- capability-based security
  - Dennis & Van Horn, 1966 https://www.princeton.edu/~rblee/ELE572Papers/Fall04Readings/ProgramSemantics_DennisvanHorn.pdf
  - Dan Gohman https://github.com/sunfishcode
  - Cloud ABI https://lwn.net/Articles/674770/
- WASI: system interface
  https://twitter.com/solomonstre/status/1111004913222324225
    "If WASM+WASI existed in 2008, we wouldn't have needed to create Docker. A standardized system interface was the missing link."
  nodejs WASI: https://nodejs.org/api/wasi.html
- Component Model: developers can pick and choose pieces of their application, implemented in different languages. Lower-level than WASI.
  - Composability: modular code reuse in a language-independent way.
  - Platform Virtualization: can layer in the platform-specific pieces that a component needs in a given environment.
  - Interoperability: exchange information between components. "Interface-types" proposal.

interop
- Go: https://github.com/golang/go/wiki/WebAssembly
- javascript/typescript: https://github.com/bytecodealliance/javy

https://github.com/bytecodealliance/wit-bindgen
suite of bindings generators for languages that are compiled to WebAssembly and
use the component model. Bindings are described with *.wit files which specify
imports, exports, and facilitate reuse between bindings definitions.

| WASM                                           | vs JVM  https://youtu.be/1dcRZ-r-Rbs?t=2123             |
|------------------------------------------------|---------------------------------------------------------|
| auto-install, auto-update                      |                                                         |
| can run C programs                             | "emscripten for JVM" attempt: http://nestedvm.ibex.org/ |
| but jvm has GraalVM                            |                                                         |
| browser support                                |                                                         |
| open standard (vs proprietary)                 |                                                         |
| "hardware bias" (eg SIMD instructions)         | "language bias" (eg field instructions)                 |
| other langs bring own object model, GC, stdlib | other langs share the object model, GC, stdlib          |

vs LLVM:
  - LLVM IR was not designed for efficient interpretation/execution

security
  - vs JVM: https://news.ycombinator.com/item?id=35469962
    WASM was designed before spectre happened, so no it's not the exception. In-process sandboxing cannot be securely designed anymore. You can endlessly chase security exploits with increasingly expensive and convoluted workarounds, but that's about it.
    > It’s designed from the ground up to have an extremely simplistic model of execution that prevents common exploits like buffer overflows and such.
    So is the JVM and CLR and dozens of prior runtimes for that matter.
    WASM for guests is mostly a security regression as all the design focus was on protecting the host. Things in the runtime got thrown under the security bus (such as no ASLR)
    > The JVM is not architected the same way, the VM has a bunch of APIs exposed to it and you have to attempt to constrain those down to make a program secure.
    You're confusing concepts here. The JVM bytecode runtime has very few APIs and WASM has no inherent requirement on being minimal or capability-based. WASI, which is what's being used here, has neither of those design attributes, for example. It's just regular POSIX apis. No permission system + massive API surface, yet still WASM all the same
  - vs Docker: https://news.ycombinator.com/item?id=35469685
    - Docker containers:
      - rely on hardware virtualization to run securely (via KVM or simlar),
        virtualization on the systemcall layer (which depends on the crun layer)
      - one chipset/OS,
      - bigger
      - slower startup (250ms w/ Firecracker vs 1ms w/ Wasmer)

future:
- problems caused by wasm's "linear memory model":
  - summary:
    - https://github.com/WebAssembly/design/issues/1397#issuecomment-926088470
    - https://github.com/WebAssembly/design/issues/1397#issuecomment-926119051
    - There is no way for a WASM program to deallocate a page of WASM memory.
    - Lack of virtual memory APIs causes a host of common efficient memory management techniques to be unavailable.
    - Thus WASM programs tend to use more memory.
    - painful for WASM running in browsers and/or mobile, since browsers have their own memory supervisors which unpredictably terminate tabs when memory usage (including both WASM and javascript allocations) goes beyond undocumented thresholds.
  - proposal:
    - "Memory Control": https://github.com/WebAssembly/memory-control/blob/main/proposals/memory-control/Overview.md
      - "virtual mode" proposal (virtual memory APIs): https://github.com/WebAssembly/memory-control/blob/main/proposals/memory-control/virtual.md
      - "memory.discard" proposal (WASM page deallocation): https://github.com/WebAssembly/memory-control/blob/main/proposals/memory-control/discard.md

WASM IN PRACTICE
--------------------------------------------------------------------------------
- https://www.hiro.so/blog/write-clarity-smart-contracts-with-zero-installations-how-we-built-an-in-browser-language-server-using-wasm
  - how we load or bundle our WASM code into the extension:
    - Our WASM package is generated with wasm-pack. It outputs a .wasm binary file and a .js to interact with it. Here is the webpack configuration to handle it: https://github.com/hirosystems/clarinet/blob/661449126df9ceecc598fbdec43869578eaa0b51/components/clarity-vscode/webpack.config.js#L87-L98
      ```
      plugins: [
        new webpack.DefinePlugin({
          __EXTENSION_URL__: JSON.stringify(extensionURL),
        }),
        new WasmPackPlugin({
          crateDirectory: path.resolve(__dirname, "../clarity-lsp"),
          forceMode: "production",
          extraArgs: "--release --target=web --no-default-features --features=wasm",
          outDir: path.resolve(__dirname, "server/src/clarity-lsp-browser"),
          outName: "lsp-browser",
        }),
      ],
      ```
  - We also use webpack to handle the URL on which the WASM file has to be fetched. https://github.com/hirosystems/clarinet/blob/4bfe97652081691dd3a23a87def00ac241aebccc/components/clarity-vscode/webpack.config.js#L22-L23
    ```
    let extensionURL = `https://${publisher}.vscode-unpkg.net/${publisher}/${name}/${version}/extension/`;
    if (TEST) extensionURL = "http://localhost:3001/static/devextensions/";

    plugins: [
      new webpack.DefinePlugin({
        __EXTENSION_URL__: JSON.stringify(extensionURL),
      }),
    ```
  - 💡 wasm-pack-plugin is a super handy plugin to call wasm-pack from webpack. https://www.npmjs.com/package/@wasm-tool/wasm-pack-plugin
  - Then, the WASM file is loaded with fetch(). Once fetched, the content of the file is passed to the initSync() method provided by wasm-pack. https://github.com/hirosystems/clarinet/blob/ad34037cbd4d6f30360a08817e497a8c9a9ef2de/components/clarity-vscode/server/src/serverBrowser.ts#L13-L26
    ```typescript
    const wasmURL = new URL("server/dist/lsp-browser_bg.wasm", __EXTENSION_URL__);

    const wasmModule = fetch(wasmURL, {
      headers: {
        "Accept-Encoding": "Accept-Encoding: gzip",
      },
    }).then((wasm) => wasm.arrayBuffer());

    const connection = createConnection(
      new BrowserMessageReader(self),
      new BrowserMessageWriter(self),
    );

    initSync(await wasmModule);
    ```
