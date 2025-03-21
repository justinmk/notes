.i files = preprocessor output (e.g. build/src/nvim/auto/ex_docmd.i)

pointer arithmetic:
    `ptr++` advances the pointer by the size of the pointed-to type.
    Incrementing (void *) is illegal. http://stackoverflow.com/a/3524270/152142

*_r function variants (rand_r, localtime_r, ...) are thread-reentrant ("restartable")[1]
    However, they are not "signal handler reentrant"[2]
    [1] http://www.unix.org/whitepapers/reentrant.html
    [2] http://stackoverflow.com/a/18199867/152142

popen() essentially does a combination of (pipe, dup stdin/stdout/stderr, fork, execl)
http://stackoverflow.com/a/24296225/152142

bit array:  https://lobste.rs/s/ueuxgt/implementing_bit_arrays_c
    #define SetBit(A,k)     ( A[(k/32)] |= (1 << (k%32)) )
    #define ClearBit(A,k)   ( A[(k/32)] &= ~(1 << (k%32)) )
    #define TestBit(A,k)    ( A[(k/32)] & (1 << (k%32)) )

CROSS-PLATFORM/OS
================================================================================
cross-platform syscall reference:
    https://github.com/giampaolo/psutil
    https://github.com/facebook/osquery
linux-only:
    "procps" https://gitlab.com/procps-ng/procps

REFERENCE
================================================================================
C: A Reference Manual, Fifth Edition. http://www.careferencemanual.com
"Secure C Coding" SEI CERT C Coding Standard https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=87152038

- undefined behavior
    - https://blog.llvm.org/2011/05/what-every-c-programmer-should-know_14.html
    - https://blog.llvm.org/2011/05/what-every-c-programmer-should-know_21.html

DEBUG
================================================================================
gdb
    CTRL-X_CTRL-A => TUI mode (zomg!!)

rr: gdb replacment with efficient reverse execution http://rr-project.org

Compiler Explorer: https://godbolt.org
    compare optimization/assembly per-compiler/per-platform

LINKING
================================================================================
todo:
  "ELF Hello World Tutorial" http://www.cirosantilli.com/elf-hello-world/

Main functions of linker:
    RESOLVE undefined symbols.
    DEDUPLICATE. A symbol may be defined only once.
    ADDRESS RELOCATION
        Relocation edits the .text section of object files to translate object
        file address into the final address of the executable. This must be done
        by the linker because the compiler only sees one input file at a time.

        Compare:
            objdump -d -r foo.o
        to:
            objdump -d -r foo.out

http://jvns.ca/blog/2013/12/10/day-40-learning-about-linkers/
https://github.com/0xAX/linux-insides/blob/master/Misc/linkers.md
    nm -A foo.o
    objdump -S -r foo.o

"Delete an inline function, save 794 kB"
https://randomascii.wordpress.com/2017/01/22/delete-an-inline-function-save-794-kb/

  > how symbol resolution works in linkers: Linkers start out with the set of
  > object files that you have specified on the command line – the contents of
  > these object files will be included in the final binary (unless the linker
  > can prove that removing them makes no difference). Then the linker builds up
  > a list of unresolved symbols and starts scanning through the set of
  > libraries that were specified on the command line – the object files in
  > these libraries will be included as-needed. Whenever a needed symbol is
  > found in one of the library object files then that object file is added to
  > the list to be linked – it becomes like one of the command-line object
  > files. The process continues until all symbols are resolved.

  > The symbol search order is unspecified by C++ and due to the One Definition
  > Rule (ODR) the search order should not matter. But, an obvious
  > implementation is to repeatedly scan through the libraries, looking for
  > symbols, until there are no more unresolved. This means that if you have two
  > copies of the same symbol then it is undefined which you will get – it
  > depends where you are when you first find that you need it. Since pulling in
  > a symbol pulls in the rest of its object file this means that linking is
  > fundamentally unpredictable. And, if you have ODR violations (as we did)
  > then the results are not even defined.

https://flameeyes.blog/2010/10/08/linkers-and-names/
  a shared library “owns” several different names, on Unix-like systems based on ELF:
    - the actual filename;
    - the name used by the link editor (or build-time linker, ld) to link to it;
    - the name used by the loader (or dynamic linker, ld.so) to find it.
  > The obvious way to correlate all of them together is to use symbolic links; and that’s why your /usr/lib directory is full of those.

C STANDARD LIBRARY
================================================================================

https://begriffs.com/posts/2019-01-19-inside-c-standard-lib.html

  - NULL is not a reserved word: compiler treats 0 specially in a pointer
    context and transforms it to whatever value represents NULL on the given
    architecture. Thus NULL is typically a macro for ((void *)0). As such it
    can’t be assigned to a function pointer because data pointers needn’t be the
    same size as function pointers. Instead cast zero, e.g. (int (*)(void))0.
  - Similarly, the C standard treats `main() { return 0; }` and `exit(0)`
    specially: they are mapped to the system-specific success code!
  - Use EXIT_FAILURE macro to portably indicate failure. The raw value 1 is
    considered "success" on some platforms.

  - Comparing ARIBTRARY pointers is undefined behavior. BUT you can compare
    pointers within the SAME _primary data object_ (such as different cells in
    the same array).
    - Pointer arithmetic on (void*) is a GNU-ism not permitted in portable C.
    - Some memmove() implementations assume its arguments are in the same data
      object! So one should not indiscriminately/defensively use memmove()
      instead of memcpy().

  - If size_t is the largest integer type, then ptrdiff_t can be no larger, yet
    the latter loses one bit to hold the sign. So it’s possible to make an array
    with cells too far apart for ptrdiff_t to measure.

  - offsetof

  - stdio.h
    BUFFERING
      The standard library provides setvbuf() to change the size and location of
      a stream’s buffer, and to choose line or block buffering. By default, stdin
      and stdout are line and block buffered respectively, and stderr is unbuffered.
      setvbuf() must be called immediately after a stream is opened, before I/O
      happens, to have any chance of working.

    OPENING/CLOSING FILES
      TOCTOU happens with fopen() when trying to create but not replace a file:
      C99 fixes this with “x” (exclusive) mode: fopen will fail if the file
      already exists or cannot be created.

          FILE *fp = fopen("foo.txt","r");
          // <-- attacker gets busy here
          if (!fp) {
            fp = fopen("foo.txt","w");  // C99: use "wx" to avoid TOCTOU risk.
            ...
            fclose(fp);
          }
          else { fclose(fp); }

      Treat FILE pointers as totally opaque. Don’t even try to make
      a copy of the FILE structure because some implementations rely on magic
      memory addresses.

      fflush() MIGHT force items in the buffer to be processed, but there is no
      guarantee. fflush(NULL) flushes all streams.

      Some OSes will not actually create a file that you fopen() and fclose()
      unless you write something.

  - unsigned char: has special guarantees that make it ideal for representing
    arbitrary binary data.
    - Unsigned char is guaranteed to have no padding bits. All bits contribute
      to the value of the data. Other types on some architectures include
      things like parity bits which don’t affect the value but do use space.
    - No bitwise operation starting from an unsigned char value, when
      converted back into that type, can produce overflow, trap
      representations or undefined behavior. It can be freely manipulated.
      "Trap representations" are certain bit patterns reserved for exceptional
      circumstances, such as NaN in floating point numbers.
    - Accessing parts of a larger data object with an unsigned char pointer
      will not violate any “aliasing rules.” The unsigned char pointer will be
      guaranteed to see all modifications of the data object.
  - "plain" (not unsigned) char has some distinct use-cases:
    - codeset characters
    - small numbers
    - units of storage (unsigned recommended)
    - small bit patterns (unsigned recommended)


TECHNIQUES
================================================================================
- "A safer arena allocator" https://gaultier.github.io/blog/tip_of_the_day_2.html
- "Roll your own memory profiling: it's actually not hard" https://gaultier.github.io/blog/roll_your_own_memory_profiling.html
