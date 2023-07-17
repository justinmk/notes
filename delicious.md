vim: sw=2 comments=s1\:/*,mb\:*,ex\:*/,\://,b\:#,\:%,\:XCOMM,n\:>,fb\:-

================================================================================
Solving Problems the Clojure Way - Rafal Dittwald
https://www.youtube.com/watch?v=vK1DazRK_a0
tags: clojure functional-programming compsci
OOP:
  - model: interacting agents (objects)
  - organize state
FP:
  - model: pipeline of input=>output
  - avoid state
  - has functions (closures) as opposed to _procedures_
To avoid mutable state and other side-effects:
  1. minimize: avoid/eliminate where possible
    - derive (compute) values instead of extra state
    - copy instead of mutate-in-place
  2. concentrate: keep it in a central place
  3. defer: queue operations to the last step or an external system
Pure functions are ...
  - easy to test
  - easy to reason about
  - easy to parallelize
  - each to cache (referential transparency)


================================================================================
Unraveling the JPEG
https://parametric.press/issue-01/unraveling-the-jpeg/
tags: todo image format encoding huffman

================================================================================
Netflix Tech Blog: Linux Performance Analysis in 60,000 Milliseconds
href="http://techblog.netflix.com/2015/11/linux-performance-analysis-in-60s.html"
tags: performance checklist linux devops sysadmin
  time="2016-01-18T06:02:33Z" 

================================================================================
Linux Performance Observability
http://www.brendangregg.com/linuxperf.html
tags: todo performance unix linux devops sysadmin

================================================================================
Scaling to 100M: MySQL is a Better NoSQL
http://blog.wix.engineering/2015/12/10/scaling-to-100m-mysql-is-a-better-nosql/
https://news.ycombinator.com/item?id=11763287
tags: todo performance distributed-systems scaling mysql databases

================================================================================
Common mistakes in PostgreSQL
https://wiki.postgresql.org/wiki/Don%27t_Do_This
tags: sql postgresql databases
- `text` is equivalent to `varchar`. Just use `text`.
- Use `numeric` instead of `money`.

================================================================================
IOWait, hung IO tasks, "task foo:3450 blocked for more than 120 seconds", hung_task_timeout_secs
tags: kernel linux io os syscall error troubleshooting filesystem virtual-memory
https://github.com/ncw/rclone/issues/1762
https://forums.aws.amazon.com/thread.jspa?threadID=220452

IOWait, if not associated with IO errors (failed resources), may be caused by:
- Not enough free memory for the OS to cache disk blocks.
- Filesystem disk usage above 80%, excessive fragmentation.
- Choose good buffer sizes when performing IO operations.

SYMPTOMS: syslog messages like this:

    kernel: [999041.133917] INFO: task updatedb.mlocat:8211 blocked for more than 120 seconds.
    kernel: [999041.133922] updatedb.mlocat D    0  8211   8210 0x00000000
    kernel: [999041.133923] Call Trace:
    kernel: [999041.133929]  schedule+0x2c/0x80
    kernel: [999041.133931]  io_schedule+0x16/0x40
                            ...
    kernel: [999041.133949]  ext4_readdir+0x64c/0xa10

    kernel: [ 8700.913097] INFO: task rsync:5626 blocked for more than 120 seconds.
    kernel: [ 8700.913114] rsync           D    0  5626      1 0x00000004
    kernel: [ 8700.913120] Call Trace:
    kernel: [ 8700.913138]  schedule+0x2c/0x80
    kernel: [ 8700.913144]  rwsem_down_write_failed+0x169/0x360
    kernel: [ 8700.913152]  call_rwsem_down_write_failed+0x17/0x30

    kernel: [15226.144976] INFO: task pool:14317 blocked for more than 120 seconds.
    kernel: [15226.144983] pool            D    0 14317      1 0x00000000
    kernel: [15226.144985] Call Trace:
    kernel: [15226.144993]  schedule+0x2c/0x80
    kernel: [15226.144995]  io_schedule+0x16/0x40
                            ...
    kernel: [15226.145004]  blk_get_request+0x17/0x20

    kernel: [28155.189289] INFO: task kworker/u24:1:11350 blocked for more than 120 seconds.
    kernel: [28155.189294] kworker/u24:1   D    0 11350      2 0x80000000
    kernel: [28155.189298] Workqueue: writeback wb_workfn (flush-8:0)
    kernel: [28155.189299] Call Trace:
    kernel: [28155.189304]  schedule+0x2c/0x80
    kernel: [28155.189306]  io_schedule+0x16/0x40
                            ...
    kernel: [28155.189315]  ext4_io_submit+0x4c/0x60
                            ...
    kernel: [28155.189325]  ? ext4_mark_inode_dirty+0x1d0/0x1d0

WORKAROUND: reduce time between fscache->disk flushes.

    # Check current values:
    $ sysctl vm.dirty_background_ratio
    $ sysctl vm.dirty_ratio

    $ sudo sysctl -w vm.dirty_ratio=20
    $ sudo sysctl -w vm.dirty_background_ratio=10
    # commit the change
    $ sudo sysctl -p

    To make permanent:

    # /etc/sysctl.conf
    vm.dirty_background_ratio = 5
    vm.dirty_ratio = 10

================================================================================
RCU (read-copy-update)
tags: rcu data-structure adt programming kernel linux compsci os operating-system
https://www.kernel.org/doc/Documentation/RCU/whatisRCU.txt
https://en.wikipedia.org/wiki/Read-copy-update
http://www.rdrop.com/users/paulmck/RCU/
> mutex strategy optimized for read-heavy tasks, at the cost of more space.
>
> RCU allows multiple threads to efficiently read from shared memory by
> deferring updates after pre-existing reads to a later time while
> simultaneously marking the data, ensuring new readers will read the updated
> data. This makes all readers proceed as if there were no synchronization
> involved, hence they will be fast, but also making updates more difficult.
>
> key property of RCU is that readers can access a data structure even when it
> is in the process of being updated: RCU updaters cannot block readers or force
> them to retry their accesses
>
> RCU works by replacing a data structure with a modified version and keeps an
> old copy. This copy is hidden from view so that no new references are attached
> to it.
>
> RCU update sequence:
>   1. Remove pointer to data structure, so subsequent readers can’t acquire a reference to it.
>   2. Wait ("grace period") for previous readers to complete their RCU read-side critical section.
>   3. Now it is safe to reclaim the region.

================================================================================
What does an idle CPU do?
https://manybutfinite.com/post/what-does-an-idle-cpu-do/
tags: programming kernel linux compsci c os operating-system
- OS (Linux) sets a timer interrupt to wake up the CPU every N ms, called
  "scheduling-clock interrupts".
    - Purpose: for workloads with many tasks using short bursts of CPU =>
      frequent but brief idle periods, reduces the overhead of switching
       to/from idle and transitioning between user/kernel execution.
    - Problem: this is "OS jitter".
        1. Inefficient for light workload with long idle periods.
        2. Unwanted jitter for Realtime/HPC workload with a single runnable task
- Typically 100-250 Hz. Configurable by CONFIG_HZ.
- "tickless" kernel can improve perf/energy usage.
  https://lwn.net/Articles/549580/
- Kernel design proposal:
  https://github.com/torvalds/linux/blob/v3.17/Documentation/timers/NO_HZ.txt

================================================================================
Disable Transparent Hugepages
https://blog.nelhage.com/post/transparent-hugepages/
https://alexandrnikitin.github.io/blog/transparent-hugepages-measuring-the-performance-impact/
tags: programming sysadmin devops kernel linux performance memory
> When transparent hugepage support works well, it can garner up to about a 10% performance improvement on certain benchmarks. However, it also comes with at least two serious failure modes:
> Memory Leaks
> THP attempts to create 2MB mappings. However, it’s overly greedy in doing so, and too unwilling to break them back up if necessary. If an application maps a large range but only touches the first few bytes, it would traditionally consume only a single 4KB page of physical memory. With THP enabled, khugepaged can come and extend that 4KB page into a 2MB page, effectively bloating memory usage by 512x (An example reproducer on this bug report actually demonstrates the 512x worst case!).
> Go’s GC had to include an explicit workaround for it, and Digital Ocean documented their woes with Redis, THP, and the jemalloc allocator.
> Pauses and CPU usage
> In steady-state usage by applications with fairly static memory allocation, the work done by khugepaged is minimal. However, on certain workloads that involve aggressive memory remapping or short-lived processes, khugepaged can end up doing huge amounts of work to merge and/or split memory regions, which ends up being entirely short-lived and useless. This manifests as excessive CPU usage, and can also manifest as long pauses, as the kernel is forced to break up a 2MB page back into 4KB pages before performing what would otherwise have been a fast operation on a single page.
> Several applications have seen 30% performance degradations or worse with THP enabled, for these reasons.

================================================================================
Andy Chu comment on Python slow-startup, distribution/delivery, self-contained apps
https://news.ycombinator.com/item?id=16979544
tags: performance programming python init bootstrap

================================================================================
Mike Pall comment on "Why Python, Ruby and JS are slow"
https://www.reddit.com/r/programming/comments/19gv4c/why_python_ruby_and_js_are_slow/c8o29zn/?context=3
tags: performance jit dynamic-pl pl programming python

> While I agree with the first part ("excuses"), the "hard" things mentioned in
> the second part are a) not that hard and b) solved issues (just not in PyPy).
>
> Hash tables: Both v8 and LuaJIT manage to specialize hash table lookups and
> bring them to similar performance as C structs (*). Interestingly, with very
> different approaches. So there's little reason NOT to use objects, dictionaries,
> tables, maps or whatever it's called in your favorite language.
>
> (*) If you really, really care about the last 10% or direct interoperability
> with C, LuaJIT offers native C structs via its FFI. And PyPy has inherited the
> FFI design, so they should be able to get the same performance someday. I'm sure
> v8 has something to offer for that, too.
>
> Allocations: LuaJIT has allocation sinking, which is able to eliminate the
> mentioned temporary allocations. Incidentally, the link shows how that's done
> for a x,y,z point class! And it works the same for ALL cases: arrays {1,2,3} (on
> top of a generic table), hash tables {x=1,y=2,z=3} or FFI C structs.
>
> String handling: Same as above -- a buffer is just a temporary allocation and
> can be sunk, too. Provided the stores (copies) are eliminated first. The
> extracted parts can be forwarded to the integer conversion from the original
> string. Then all copies and references are dead and the allocation itself can be
> eliminated. LuaJIT will get all of that string handling extravaganza with the
> v2.1 branch -- parts of the new buffer handling are already in the git repo. I'm
> sure the v8 guys have something up their sleeves, too.
>
> I/O read buffer: Same reasoning. The read creates a temporary buffer which is
> lazily interned to a string, ditto for the lstrip. The interning is sunk, the
> copies are sunk, the buffer is sunk (the innermost buffer is reused). This turns
> it into something very similar to the C code.
>
> Pre-sizing aggregates: The size info can be backpropagated to the aggreagate
> creation from scalar evolution analysis. SCEV is already in LuaJIT (for ABC
> elimination). I ditched the experimental backprop algorithm for 2.0, since I had
> to get the release out. Will be resurrected in 2.1.
>
> Missing APIs: All of the above examples show you don't really need to define new
> APIs to get the desired performance. Yes, there's a case for when you need
> low-level data structures -- and that's why higher-level languages should have
> a good FFI. I don't think you need to burden the language itself with these
> issues.
>
> Heuristics: Well, that's what those compiler textbooks don't tell you: VMs and
> compilers are 90% heuristics. Better deal with it rather than fight it.
>
> tl;dr: The reason why X is slow, is because X's implementation is slow,
> unoptimized or untuned. Language design just influences how hard it is to make
> up for it. There are no excuses.

================================================================================
How Netflix Reinvented HR
https://hbr.org/2014/01/how-netflix-reinvented-hr
tags: work culture hiring
2016-03-16 19:38:31
> The best thing you can do for employees—a perk better than foosball or free
> sushi—is hire only “A” players to work alongside them. Excellent colleagues
> trump everything else.
> ...
> we learned to offer rich severance packages.
> ...
> Hire, Reward, and Tolerate Only Fully Formed Adults
> ...
> we learned that if we asked people to rely on logic and common sense instead
> of on formal policies, most of the time we would get better results, and at
> lower cost.
> ...
>  I frequently see CEOs who are clearly winging it. ... It’s a waste of time to
>  articulate ideas about values and culture if you don’t model and reward
>  behavior that aligns with those goals.

================================================================================
The USE Method 
  href="http://www.brendangregg.com/usemethod.html" 
  
tags: performance troubleshooting debug distributed-systems checklist
  time="2016-01-18T05:59:59Z" 

================================================================================
U.S. defense lawyers to seek access to DEA hidden intelligence evidence | Reuters
  Internal training documents reported by Reuters this week instruct agents not to reveal information they get from a unit of the U.S. Drug Enforcement Administration, but instead to recreate the same information by other means. A similar set of instructions was included in an IRS manual in 2005 and 2006, Reuters reported. / The DEA unit, known as the Special Operations Division, or SOD, receives intelligence from intercepts, wiretaps, informants and phone records, and funnels tips to other law enforcement agencies, the documents said. Some but not all of the information is classified.
href="http://www.reuters.com/article/us-dea-irs-idUSBRE9761AZ20130808"
tags: police-state government politics
  time="2016-01-09T19:11:55Z" 

================================================================================
SWAT-Team Nation - The New Yorker
  civil-forfeiture laws, which allow police to confiscate and keep property that is allegedly tied to criminal activity, are often enforced at gunpoint against, say, nonviolent partygoers. / 80,000 combat-style home raids per year. / U.S. Department of Defense program ... has redistributed billions of dollars‚Äô worth of surplus military gear to local police forces
href="http://www.newyorker.com/news/daily-comment/swat-team-nation"
tags: police-state politics government
  time="2016-01-09T19:01:29Z" 

================================================================================
CONSENSUS: BRIDGING THEORY AND PRACTICE
href="https://ramcloud.stanford.edu/~ongaro/thesis.pdf"
tags: raft cap distributed-systems compsci todo papers
  time="2016-01-07T22:10:02Z" 

================================================================================
Things we (finally) know about network queues
https://apenwarr.ca/log/20170814
tags: queue-theory network compsci

================================================================================
The UNIX Time-Sharing System / Dennis M. Ritchie and Ken Thompson
https://people.eecs.berkeley.edu/~brewer/cs262/unix.pdf
tags: operating-system unix compsci papers
.
> An entry for each special file resides in directory /dev, although a link may
> be made to one of these files just like an ordinary file. Thus, for example,
> to punch paper tape, one may write on the file /dev/ppt.
> ...
> To do random (direct access) I/O, it is only necessary to move the read or
> write pointer to the appropriate location in the file.
>   location = seek(filep, base, offset)
> The pointer associated with filep is moved to a position offset
> bytes from the beginning of the file, from the current position of the
> pointer, or from the end of the file, depending on base.
> ...
> Removing (deleting) a file is done by decrementing the link-count of the
> i-node specified by its directory entry and erasing the directory entry. If
> the link-count drops to 0, any disk blocks in the file are freed and the
> i-node is deallocated.
> ...
> To the user, both reading and writing of files appear to be synchronous and
> unbuffered. That is immediately after return from a read call the data are
> available, and conversely after a write the user’s workspace may be reused.
> In fact the system maintains a rather complicated buffering mechanism which
> reduces greatly the number of I/O operations required to access a file.
> ...
> An image is a computer execution environment. It includes a core image,
> general register values, status of open files, current directory, and the
> like. An image is the current state of a pseudo computer. A process is the
> execution of an image. While the processor is executing on behalf of
> a process, the image must reside in core;
> ...
> A new process can come into existence only by use of the fork system call:
>   processid = fork (label)
> When fork is executed by a process, it splits into two independently executing
> processes. The two processes have independent copies of the original core
> image, and share any open files.
> ...
> Processes may communicate with related processes using the same system read
> and write calls that are used for file system I/O. The call
>   filep = pipe()
> returns a file descriptor filep and creates an interprocess channel called
> a pipe. This channel, like other open files, is passed from parent to child
> process in the image by the fork call. A read using a pipe file descriptor
> waits until another process writes using the file descriptor for the same
> pipe.
> ...
>   processid = wait()
> causes its caller to suspend execution until one of its children has completed
> execution. Then wait returns the processid of the terminated process.

================================================================================
The web of names, hashes and UUIDs
  Joe Armstrong's ‟reversing entropy plan”. As soon as we name something there is an implied context - take away the context, or use the name in a different context and we are lost.
  href="http://joearms.github.io/2015/03/12/The_web_of_names.html"

tags: compsci content-addressable distributed-systems uuid
  time="2015-12-30T03:39:36Z" 

================================================================================
PHP Sadness
http://phpsadness.com/
tags: programming

================================================================================
Here are a few random things that come to mind as often missed by users
  - Multimaps.index() and Maps.uniqueIndex() - That all ImmutableCollections have deterministic iteration order and a no-cost asList() view - That there's very little reason to do integer arithmetic on the values of a map yourself -- if Multiset doesn't fit the bill, AtomicLongMap probably does
href="https://www.reddit.com/r/java/comments/1y9e6t/ama_were_the_google_team_behind_guava_dagger/cfjfskk"
tags: guava google programming
  time="2015-12-29T21:33:40Z" 

================================================================================
TensorFlow
http://googleresearch.blogspot.com/2015/12/how-to-classify-images-with-tensorflow.html

> At Jetpac my colleagues and I built mustache detectors to recognize bars full of hipsters, blue sky detectors to find pubs with beer gardens, and dog detectors to spot canine-friendly cafes. At first, we used the traditional computer vision approaches that I'd used my whole career, writing a big ball of custom logic to laboriously recognize one object at a time. For example, to spot sky I'd first run a color detection filter over the whole image looking for shades of blue, and then look at the upper third. If it was mostly blue, and the lower portion of the image wasn't, then I'd classify that as probably a photo of the outdoors.
> I'd been an engineer working on vision problems since the late 90's, and the sad truth was that unless you had a research team and plenty of time behind you, this sort of hand-tailored hack was the only way to get usable results. As you can imagine, the results were far from perfect and each detector I wrote was a custom job, and didn't help me with the next thing I needed to recognize. This probably seems laughable to anybody who didn't work in computer vision in the recent past! It's such a primitive way of solving the problem, it sounds like it should have been superseded long ago.
> That's why I was so excited when I started to play around with deep learning. It became clear as I tried them out that the latest approaches using convolutional neural networks were producing far better results than my hand-tuned code on similar problems. Not only that, the process of training a detector for a new class of object was much easier. I didn't have to think about what features to detect, I'd just supply a network with new training examples and it would take it from there.

tags: deep-learning machine-learning random-forests compsci

================================================================================
The Bitter Lesson, Rich Sutton, 2019
http://www.incompleteideas.net/IncIdeas/BitterLesson.html
tags: deep-learning machine-learning compsci engineering moores-law scale
The bitter lesson:
> 1) AI researchers have often tried to build knowledge into their agents,
> 2) this always helps in the short term, and is personally satisfying to the researcher, but
> 3) in the long run it plateaus and even inhibits further progress, and
> 4) breakthrough progress eventually arrives by an opposing approach based on scaling computation by search and learning. The eventual success is tinged with bitterness, and often incompletely digested, because it is success over a favored, human-centric approach.
Takeaway:
> The great power of general purpose methods, of methods that continue to scale
> with increased computation.
> 2 methods that scale arbitrarily in this way: SEARCH and LEARNING.


================================================================================
Random forests
  http://research.microsoft.com/pubs/155552/decisionForests_MSR_TR_2011_114.pdf Random forests &quot;can handle classification, regression, semi-supervised learning, manifold learning, and density estimation. The paper gives an introduction to each of these topics as well as a unified framework to implement each algorithm.&quot; &quot;The paper is well-written and easy to understand for someone without a deep background in machine learning.&quot;
href="https://news.ycombinator.com/item?id=4201374" 
tags: todo machine-learning random-forests compsci
  time="2015-10-27T04:36:13Z" 

================================================================================
N.S.A. Foils Basic Safeguards of Privacy on Web
  The agency has circumvented or cracked much of the encryption, or digital scrambling, that guards global commerce and banking systems, protects sensitive data like trade secrets and medical records, and automatically secures the e-mails, Web searches, Internet chats and phone calls of Americans and others around the world, the documents show. ... The N.S.A.‚Äôs Commercial Solutions Center, for instance, invites the makers of encryption technologies to present their products to the agency with the goal of improving American cybersecurity. But a top-secret N.S.A. document suggests that the agency‚Äôs hacking division uses that same program to develop and ‚Äúleverage sensitive, cooperative relationships with specific industry partners‚Äù to insert vulnerabilities into Internet security products. ... But by 2006, an N.S.A. document notes, the agency had broken into communications for three foreign airlines, one travel reservation system.
  href="http://www.nytimes.com/2013/09/06/us/nsa-foils-much-internet-encryption.html?_r=0"
   
tags: police-state surveillance usgov government state security encryption
  time="2015-09-23T18:37:42Z" 

================================================================================
U.S. directs agents to cover up program used to investigate Americans
  [&quot;SOD tips&quot; or &quot;SOD tip-offs&quot;, where intelligence-community information is &quot;laundered&quot; through a source that provides a tip to investigators] Law enforcement agents have been directed to conceal how such investigations truly begin - not only from defense lawyers but also sometimes from prosecutors and judges. federal agents are trained to &quot;recreate&quot; the investigative trail to effectively cover up where the information originated, ... If defendants don't know how an investigation began, they cannot know to ask to review potential sources of exculpatory evidence - information that could reveal entrapment, mistakes or biased witnesses.
  href="http://www.reuters.com/article/2013/08/05/us-dea-sod-idUSBRE97409R20130805"
   
tags: police-state coverup government dea usgov
  time="2015-09-23T18:05:02Z" 

================================================================================
This method is so acceptable, the DEA won't even release its name | Muckrock
  href="https://www.muckrock.com/news/archives/2014/feb/04/method-so-acceptable-dea-cant-even-tell-you-its-na/"
   
tags: police-state politics government usgov dea security snowden
  time="2015-09-23T18:02:11Z" 

================================================================================
GeekDesk¬Æ Adjustable Height Desks - Home
href="http://www.geekdesk.com/"  
tags: ergonomics health rsi work standingdesk desk
  time="2015-09-23T15:25:52Z" 

================================================================================
www.versatables.com 
href="http://www.versatables.com/"  
tags: ergonomics health rsi work standingdesk desk
  time="2015-09-23T15:25:18Z" 

================================================================================
What forces layout/reflow. The comprehensive list.
  href="https://gist.github.com/paulirish/5d52fb081b3570c81e3a"
   
tags: web dom chrome layout reflow programming
  time="2015-09-19T18:19:43Z" 

================================================================================
Kythe steve yegge grok
href="http://www.kythe.io/"  
tags: programming tools
time="2015-09-17T18:18:49Z" 

================================================================================
IPFS | The Permanent Web 
href="https://ipfs.io/"
tags: distributed-systems web filesystem
  time="2015-09-09T05:32:33Z" 

================================================================================
Stanford Encyclopedia of Philosophy
href="http://plato.stanford.edu/"  
tags: philosophy reference academia
  time="2015-08-04T23:38:31Z" 

================================================================================
TI Launchpads: $10 microcontrollers
  href="http://www.ti.com/ww/en/launchpad/launchpads.html"
   
tags: uc electronics compsci circuits engineering
  time="2015-06-15T14:30:37Z" 

================================================================================
Think Distributed: A Distributed Systems Podcast
href="http://thinkdistributed.io/"  
tags: distributed-systems podcast
time="2015-03-30T23:21:42Z" 

================================================================================
After seven years, exactly one person gets off the gov‚Äôt no-fly list | Ars Technica
  the government's official policy is to refuse to confirm or deny watchlist status. Nor is there any meaningful way to contest one's designation as a potential terrorist and ensure that the US government... removes or corrects inadequate records.
href="http://arstechnica.com/tech-policy/2014/03/after-seven-years-exactly-one-person-gets-off-the-govt-no-fly-list/"
tags: police-state government-failure
  time="2015-03-26T04:45:02Z" 

================================================================================
Why not add an option for that?
http://neugierig.org/software/blog/2018/07/options.html
tags: programming softwareengineering design ux ui options

================================================================================
Google's internal code review guidelines
https://news.ycombinator.com/item?id=20891738
tags: programming softwareengineering teams code-review google
> Review code in this order: protocol buffers, unit tests, headers,
> implementation. It's common for a new employee to be an expert on C++ or Java
> or whatever languages but it's very uncommon to meet anyone who knows how to
> define a decent protocol message. The tests should give the reviewer a very
> clear idea of what's happening in the code (and this should be congruent with
> the description of the change), if not send back to author at this point. The
> headers should contain clear interfaces, types, and comments and should not
> contain anything that's not part of the API (when this is technically
> possible). Finally look in the CC file; at this point the reviewer should see
> things they were already expecting and no funny business.
>
> Any claims about speed, efficiency, or performance whether in comments or
> during the review must have accompanying microbenchmarks or they should be
> deleted. Wrong ideas about software performance abound, and even correct
> beliefs become incorrect with time, in which case the microbenchmarks are
> critical to evaluating the continued value of the code.
>
> When sending a changelist for review, always clear all automated warnings or
> errors before wasting the reviewers' time. Nobody wants to see code that
> doesn't build, breaks a bunch of tests, doesn't lint, etc.

================================================================================
This Week In Startups | This Week In Startups
href="http://thisweekinstartups.com/"  
tags: podcast
time="2015-03-21T14:34:47Z" 

================================================================================
Podcast ‚Äì The Tim Ferriss Show 
href="http://fourhourworkweek.com/podcast/" 
tags: podcast
time="2015-03-21T14:32:48Z" 

================================================================================
Rich Hickey Q&amp;A, by Michael Fogus
  OO can seriously thwart reuse. ... the use of objects to represent simple informational data [generates] per-piece-of-information micro-languages, i.e. the class methods, versus far more powerful, declarative, and generic methods like relational algebra. / the great challenge for type systems in practical use is getting them to be more expressive without a corresponding‚Äîor worse‚Äîincrease in complexity. / The problems [with inheritance/hierarchy] come about when you attach something to the hierarchy. ... a method for partial overriding of the inheritance and thus, qualification of the isa implication. The implication is broken and your ability to reason about things turns to mud.
  href="http://codequarterly.com/2011/rich-hickey/" 
  
tags: clojure richhickey programming type-systems compsci
  time="2015-03-05T00:45:56Z" 

================================================================================
New research indicates ‘Unicorns’ are overvalued
https://news.ycombinator.com/item?id=14467869
tags: startup equity stock options

Optionality protects VCs.

> The average unicorn, the researchers note, has eight stock classes for
> different types of investors, including founders, employees, venture
> capitalists, mutual funds, and others.

> Without a detailed accounting of the ins and outs of the preferred stock that
> is senior to your common shares, it is nigh impossible to tell how much the
> common shares (and options thereon) are worth.

> startups use various contractual terms -- things like options on exit,
> liquidation preferences and others -- to take money into into the business at
> high nominal valuations, while still offering downside protection
> (optionality) to investors.

The optionality in startup investing has mainly to do with the "limited
liability" in Limited Liability Corporation (and other types of corporations and
partnerships). That is, if you invest a dollar in a corporation, your losses are
capped at a dollar. But, your gains are potentially infinite. (Like stock
options.)

> Even unicorns that are far more likely to IPO can raise bridge rounds that
> cause major dilution for the common shares, rendering previous market
> capitalization numbers useless.

================================================================================
Options vs. cash
https://danluu.com/startup-options/
https://news.ycombinator.com/item?id=14505378
tags: startup equity stock options

> _Venture Deals_ by Brad Feld is a great read to understand different investment terms

================================================================================
What I Wish I'd Known About Equity Before Joining A Unicorn
https://gist.github.com/yossorion/4965df74fd6da6cdc280ec57e83a202d
tags: startup equity finance employee employment work career options stock compensation

Disclaimer: This piece is written anonymously. The names of a few particular companies are mentioned, but as common examples only.

This is a short write-up on things that I wish I'd known and considered before joining a private company (aka startup, aka unicorn in some cases). I'm not trying to make the case that you should never join a private company, but the power imbalance between founder and employee is extreme, and that potential candidates would do well to consider alternatives.

None of this information is new or novel, but this document aims to put the basics in one place.

The Rub

Lock In

After leaving a company, you generally have 90 days to exercise your options or they're gone. This seems to have originally developed around a historical rule from the IRS around the treatment of ISOs, but the exact reason doesn't really matter anymore. The only thing that does matter is that if you ever want to leave your company, all that equity that you spent years building could evaporate if you don't have the immediate cash reserves to buy into it.

Worse yet, by exercising options you owe tax immediately on money that you never made. Your options have a strike price and private companies generally have a 409A valuation to determine their fair market value. You owe tax on the difference between those two numbers multiplied by the number of options exercised, even if the illiquidity of the shares means that you never made a cent, and have no conceivable way of doing so for the forseeable future.

Even if you have the money to buy your options and pay the taxman, that cash is now locked in and could see little return on investment for a long and uncertain amount of time. Consider the opportunity cost of what you could otherwise have done with that liquid capital.

Due to tax law, there is a ten year limit on the exercise term of ISO options from the day they're granted. Even if the shares aren't liquid by then, you either lose them or exercise them, with exercising them coming with all the caveats around cost and taxation listed above.

Does ten years sound like a long time? Consider the ages of these unicorns:

Palantir is now thirteen years old.
Dropbox will be ten years old this year (2017).
AirBnB, GitHub, and Uber are all within a year or two of their ten year birthdays.
Some companies now offer 10-year exercise window (after you quit) whereby your ISOs are automatically converted to NSOs after 90 days. This is strictly better for the employee than a 90-day window, but as previously mentioned, ten years still might not be enough.

Golden handcuffs kick in fast. The longer you stay with a company, the more equity you build, and a decision to leave becomes that much harder. This can culminate to the point where early employees have modest liquid assets but are "paper millionaires", and have to make the hard decision to throw all that away or stick around until their founders allow them some return.

Liquidity Events

No time horizon for any kind of liquidation guaranteed. In fact, no liquidation event is ever guaranteed, even if the company is highly successful. One could be at 1 year out, 5 years, 10 years, or never. We've seen a lot of evidence in this day and age that companies are staying private for longer (see the list above).

The incentive to IPO between employer and employee are not aligned. Employees want some kind of liquidation event so that they can extract some of the value they helped create, but employers know that allowing employees to extract that value might cost them some of their best people as they're finally allowed the opportunity to pursue other projects. One more reason to stay private for longer.

Although the above is one reason that founders don't want to IPO, it's not the only reason. Many of them do believe (rightly or wrongly) that there is another 10x/100x worth of growth left in the company, and that by pulling the trigger too early on an IPO all of that potential will be lost. For a normal founder, their company is their life's work, and they're willing to wait a few more years to see the canvas fully realized. This is a more noble reason not to liquidate, but from an employee's perspective, is still problematic.
Founder/Employee Power Imbalance

Founders (and favored lieutenants) can arrange take money off the table while raising rounds and thus become independently wealthy even before they make true "fuck you" money from a large scale liquidation event. Employees cannot. The situation is totally asymmetric, and most of us are on the wrong end of that.

Even if you came into a company with good understanding of its cap table, the ground can shift under your feet. New shares can be issued at any time to dilute your position. In fact, it's common for dilution to occur during any round of fundraising.

Private Markets

Private markets do exist that trade private stock and even help with the associated tax liabilities. However, it's important to consider that this sort of assistance will come at a very high cost, and you'll almost certainly lose a big chunk of your upside. Also, depending on the company you join, they may have restricted your ability to trade private shares without special approval from the board.
Valuations

Especially in early stage companies, equity is offered on the basis of a highly theoretical future valuation number. Sam Altman recommends offering the first ten employees 10% (~1% each), which could be a big number if the company sells for $10B, but consider how few companies actually make it to that level.

If the company sells for a more modest $250M, between taxes and the dilution that inevitably will have occurred, your 1% won't net you as much as you'd intuitively think. It will probably be on the same order as what you might have made from RSUs at a large public company, but with far far more risk involved. Don't take my word for it though; it's pretty simple math to run the numbers for a spread of sale prices and dilution factors for yourself before joining, so do so.

Tender Offers

Some companies acknowledge the effect of drawn out phases of illiquidity on employees and engage in a tender offer to give employees some return (google around for some examples). I don't want to overstate this because receiving a tender offer is strictly better than the alternative, but keep in mind that one will probably be structured to minimize the amount of value you can extract. They're also very likely be infrequent events. Read the fine print, run the numbers, and consider how much your annual return to date will actually be (including all the time you've spent at the company, not just the year of the offer). It's probably less than what you could've gotten in RSU grants at a public company.
Working Environment

This isn't equity related, but it's worth considering that the environment at a big unicorn isn't going to be measurably different from a big public company. You're going to have little impact per employee, the same draconian IT security policies, lots of meetings, and fixed PTO. In the worst cases, you might even have to use JIRA.
I'm Doing It Anyway!

So you decided to join a private company anyway. Here's a few questions that I'd recommend knowing the answer to before accepting any offer (you'd be amazed at how infrequently this information is volunteered):

How long is my exercise window if I leave the company?

How many outstanding shares are there? (This will allow you to calculate your ownership in the company.)

Does the company's leaders want it to be sold or go public? If so, what is the rough time horizon for such an event? (Don't take "we don't know" for an answer.)

Have there been any secondary sales for shares by employees or founders? (Try it route out whether founders are taking money off the table when they raise money, and whether there has been a tender offer for employees.)

Assuming no liquidation, are my shares salable on a private market?

Has the company taken on debt or investment with a liquidation preference of more than 1x? (Investors may have been issued > 1x liquidation preference, which means they get paid out at that multiple before anyone else gets anything.)

Will you give me an extended exercise window? (After joining I realized that most people's window was the standard 90 days, but not everyone's. Unfortunately by then I'd lost my negotiating leverage to ask for an extended term.)

It's really tough to ask these without sounding obsessed with money, which feels unseemly, but you have to do it anyway. The "you" of today needs to protect the "you" of tomorrow.

Summary

Working at a startup can be fun, rewarding, interesting, and maybe even lucrative. The working conditions at Silicon Valley companies are often the best in the world; it's quite conceivable that you might want to stay there even if there was never a possibility of a payoff. But don't forget that as far as equity is concerned, every card in the deck is stacked against you.

The correct amount to value your options at is $0. Think of them more as a lottery ticket. If they pay off, great, but your employment deal should be good enough that you'd still join even if they weren't in your contract.

I don't say this just because of the possibility that your startup could fail, but also because even in the event of success, there are plenty of scenarios where getting a payout will be difficult. Say for example that five years in you want to try something new, or want to start a family and need a job that will pay you well enough to let you afford a starter home in the Bay Area (not easy). Your startup Monopoly money will put you in a precarious position.

If you're lucky enough to be in high enough demand that you can consider either a public company with good stock liquidity or a billion-dollar unicorn, give serious consideration to the former.

================================================================================
Frequency illusion / Baader-Meinhof Phenomenon
href="http://en.wikipedia.org/wiki/List_of_cognitive_biases#Frequency_illusion"
tags: concepts psychology mental-model
  time="2015-02-13T19:03:21Z" 


================================================================================
Habitat fragmentation
https://en.wikipedia.org/wiki/Habitat_fragmentation
Ecological thinning: https://en.wikipedia.org/wiki/Ecological_thinning
_Impact of forest paths upon adjacent vegetation_: S. Godefroid, N. Koedam, 2004
tags: concepts ecology mental-model
.
> Edge effects alter the conditions of the outer areas of the fragment, greatly
> reducing the amount of true forest interior habitat.
>
> A large number of small forest "islands" typically cannot support the same
> biodiversity that a single contiguous forest would hold, even if their
> combined area is much greater than the single forest.


================================================================================
Apdex
  for a threshold of t: Apdex_t = (Satisfied Count + Tolerating Count / 2) / Total Samples // http://mvolo.com/why-average-latency-is-a-terrible-way-to-track-website-performance-and-how-to-fix-it/
  href="http://en.wikipedia.org/wiki/Apdex" 
  
tags: monitoring performance apdex metrics measurement
  time="2015-02-11T21:31:36Z" 

================================================================================
Introducing Project Mentat, a flexible embedded knowledge store
https://medium.com/project-tofino/introducing-datomish-a-flexible-embedded-knowledge-store-1d7976bff344
tags: system-design software-engineering scalability performance database
great description of CQRS:
    > The CQRS approach, at its root, is to separate the ‘command’ from the
    > ‘query’: store a data model that’s very close to what the writer knows
    > (typically a stream of events), and then materialize as many query-side
    > data stores as you need to support your readers. When you need to support
    > a new kind of fast read, you only need to do two things: figure out how to
    > materialize a view from history, and figure out how to incrementally
    > update it as new events arrive. You shouldn’t need to touch the base
    > storage schema at all. When a consumer is ripped out of the product, you
    > just throw away their materialized views.


================================================================================
FreeNAS Community Hardware Recommendations Guide
https://forums.freenas.org/index.php?resources/hardware-recommendations-guide.12/
tags: performance sysadmin devops hardware system

Power Supply
    Seasonic is known for the consistent performance of its PSUs.
    ...
    At ~2.5A spin-up current per drive, this makes the SATA connector suitable
    only for a single drive. Backplanes typically use one SATA connector per 1.5
    drives. A practical consequence is that Y-cables should connect to the
    source using a Molex connector, not a SATA connector, and should be limited
    to 3-4 drives.
Additional SATA/SAS connectivity
    the only reliable solution is to add an LSI/Avago/Broadcom SAS controller
SATA Port Multipliers
    • are "cheap alternatives to SAS expanders" and should be avoided.

================================================================================
Effective Engineer (AKA: Leverage)
http://www.effectiveengineer.com/
https://gist.github.com/rondy/af1dee1d28c02e9a225ae55da2674a6f
https://henrikwarne.com/2017/01/15/book-review-the-effective-engineer/
tags: engineering leverage mental-model

LEVERAGE = IMPACT / TIME_COST
    Only three ways to increase leverage:
        1. Reduce the time it takes to complete a particular activity.
        2. Increase the output of the activity.
        3. Shift focus to a higher-leverage activity.
    Example: create a strong onboarding program for new engineers amplifies your efforts => new hires become productive faster
    Example: time-box meetings to 15 min instead of 1 hour, write meeting minutes, create actionable tasks.

    - Optimize for learning
        - Adopt a growth mindset. Talk to people. Become good at telling stories.
        - Learning compounds.
        - Working on unchallenging tasks is a huge opportunity cost. You missed out on compounded learning.
        - Fast Growth: Companies where #problems >> #resources. Opportunity to choose high impact work.
        - Work with people smarter than you.
    - Prioritize Regularly
        - Working on wrong ideas has massive opportunity cost.
        - Maintain ONE todo list with all tasks.
        - Learn to say no.
        - Limit the amount of Work-in-Progress. Context-switching is expensive.
    - Invest in time-saving tools
        - CI/CD
        - Minimize feedback loop (debug/dev/validation/…).
    - Reduce Operational Complexity
        - Minimize number of technologies. More technologies => More operational complexity.
        - “What’s the simplest solution that can do the job while also reducing our future operational burden?”
    - Recovery over prevention
    - Automate mechanics, NOT decision-making
    - Make batch processes idempotent. No global state.


================================================================================
How to Get Rich (without getting lucky): @naval
https://twitter.com/naval/status/1002103360646823936
https://pbs.twimg.com/media/DesoRB1V4AI6_3-.jpg:large
tags: economics business systems leverage mental-model naval-ravikant

Seek wealth, not money or status. Wealth is having assets that earn while you sleep. Money is how we transfer time and wealth. Status is your place in the social hierarchy.
Understand that ethical wealth creation is possible. If you secretly despise wealth, it will elude you.
Ignore people playing status games. They gain status by attacking people playing wealth creation games.
You’re not going to get rich renting out your time. You must own equity - a piece of a business - to gain your financial freedom.
You will get rich by giving society what it wants but does not yet know how to get. At scale.
Pick an industry where you can play long term games with long term people.
The Internet has massively broadened the possible space of careers. Most people haven't figured this out yet.
Play iterated games. All the returns in life, whether in wealth, relationships, or knowledge, come from compound interest.
Pick business partners with high intelligence, energy, and, above all, integrity.
Don't partner with cynics and pessimists. Their beliefs are self-fulfilling.
Learn to sell. Learn to build. If you can do both, you will be unstoppable.
Arm yourself with specific knowledge, accountability, and leverage.
Specific knowledge is knowledge that you cannot be trained for. If society can train you, it can train someone else, and replace you.
Specific knowledge is found by pursuing your genuine curiosity and passion rather than whatever is hot right now.
Building specific knowledge will feel like play to you but will look like work to others.
When specific knowledge is taught, it’s through apprenticeships, not schools.
Specific knowledge is often highly technical or creative. It cannot be outsourced or automated.
Embrace accountability, and take business risks under your own name. Society will reward you with responsibility, equity, and leverage.
The most accountable people have singular, public, and risky brands: Oprah, Trump, Kanye, Elon.
“Give me a lever long enough, and a place to stand, and I will move the earth.” 
- Archimedes
Fortunes require leverage. Business leverage comes from capital, people, and products with no marginal cost of replication (code and media).
Capital means money. To raise money, apply your specific knowledge, with accountability, and show resulting good judgment.
Labor means people working for you. It's the oldest and most fought-over form of leverage. Labor leverage will impress your parents, but don’t waste your life chasing it.
Capital and labor are permissioned leverage. Everyone is chasing capital, but someone has to give it to you. Everyone is trying to lead, but someone has to follow you.
Code and media are permissionless leverage. They're the leverage behind the newly rich. You can create software and media that works for you while you sleep.
An army of robots is freely available - it's just packed in data centers for heat and space efficiency. Use it.
If you can't code, write books and blogs, record videos and podcasts.
Leverage is a force multiplier for your judgement.
Judgement requires experience, but can be built faster by learning foundational skills.
There is no skill called “business.” Avoid business magazines and business classes.
Study microeconomics, game theory, psychology, persuasion, ethics, mathematics, and computers.
Reading is faster than listening. Doing is faster than watching.
You should be too busy to “do coffee," while still keeping an uncluttered calendar.
Set and enforce an aspirational personal hourly rate. If fixing a problem will save less than your hourly rate, ignore it. If outsourcing a task will cost less than your hourly rate, outsource it.
Work as hard as you can. Even though who you work with and what you work on are more important than how hard you work.
Become the best in the world at what you do. Keep redefining what you do until this is true.
There are no get rich quick schemes. That's just someone else getting rich off you.
Apply specific knowledge, with leverage, and eventually you will get what you deserve.
When you're finally wealthy, you'll realize that it wasn't what you were seeking in the first place. But that's for another day.


================================================================================
Mental Models: The Best Way to Make Intelligent Decisions (109 Models Explained)
https://fs.blog/mental-models/
tags: concepts systems mental-model

Mental models are how we understand the world. Not only do they shape what we think and how we understand but they shape the connections and opportunities that we see. Mental models are how we simplify complexity, why we consider some things more relevant than others, and how we reason.

A mental model is simply a representation of how something works. We cannot keep all of the details of the world in our brains, so we use models to simplify the complex into understandable and organizable chunks.

Thinking Better
The quality of our thinking is proportional to the models in our head and their usefulness in the situation at hand. The more models you have—the bigger your toolbox—the more likely you are to have the right models to see reality. It turns out that when it comes to improving your ability to make decisions
variety matters.

Most of us, however, are specialists. Instead of a latticework of mental models, we have a few from our discipline. Each specialist sees something different. By default, a typical Engineer will think in systems. A psychologist will think in terms of incentives. A biologist will think in terms of evolution. By putting these disciplines together in our head, we can walk around a problem in a three dimensional way. If we’re only looking at the problem one way, we’ve got a blind spot. And blind spots can kill you.

Here’s another way to think about it. When a botanist looks at a forest they may focus on the ecosystem, an environmentalist sees the impact of climate change, a forestry engineer the state of the tree growth, a business person the value of the land. None are wrong, but neither are any of them able to describe the full scope of the forest. Sharing knowledge, or learning the basics of the other disciplines, would lead to a more well-rounded understanding that would allow for better initial decisions about managing the forest.

In a famous speech in the 1990s, Charlie Munger summed up the approach to practical wisdom through understanding mental models by saying: “Well, the first rule is that you can’t really know anything if you just remember isolated facts and try and bang ’em back. If the facts don’t hang together on a latticework of theory, you don’t have them in a usable form. You’ve got to have models in your head. And you’ve got to array your experience both vicarious and direct on this latticework of models. You may have noticed students who just try to remember and pound back what is remembered. Well, they fail in school and in life. You’ve got to hang experience on a latticework of models in your head.”

Mental Model Toolbox

A Latticework of Mental Models
To help you build your latticework of mental models so you can make better decisions, we’ve collected and summarized the ones we’ve found the most useful.

And remember: Building your latticework is a lifelong project. Stick with it, and you’ll find that your ability to understand reality, make consistently good decisions, and help those you love will always be improving.

The Farnam Street Latticework of Mental Models
General Thinking Concepts
1. The Map is not the Territory
The map of reality is not reality. Even the best maps are imperfect. That’s because they are reductions of what they represent. If a map were to represent the territory with perfect fidelity, it would no longer be a reduction and thus would no longer be useful to us. A map can also be a snapshot of a point in time, representing something that no longer exists. This is important to keep in mind as we think through problems and make better decisions.

2. Circle of Competence
When ego and not competence drives what we undertake, we have blind spots. If you know what you understand, you know where you have an edge over others. When you are honest about where your knowledge is lacking you know where you are vulnerable and where you can improve. Understanding your circle of competence improves decision making and outcomes.

3. First Principles Thinking
First principles thinking is one of the best ways to reverse-engineer complicated situations and unleash creative possibility. Sometimes called reasoning from first principles, it’s a tool to help clarify complicated problems by separating the underlying ideas or facts from any assumptions based on them. What remains are the essentials. If you know the first principles of something, you can build the rest of your knowledge around them to produce something new.

4. Thought Experiment
Thought experiments can be defined as “devices of the imagination used to investigate the nature of things.” Many disciplines, such as philosophy and physics, make use of thought experiments to examine what can be known. In doing so, they can open up new avenues for inquiry and exploration. Thought experiments are powerful because they help us learn from our mistakes and avoid future ones. They let us take on the impossible, evaluate the potential consequences of our actions, and re-examine history to make better decisions. They can help us both figure out what we really want, and the best way to get there.

5. Second-Order Thinking
Almost everyone can anticipate the immediate results of their actions. This type of first-order thinking is easy and safe but it’s also a way to ensure you get the same results that everyone else gets. Second-order thinking is thinking farther ahead and thinking holistically. It requires us to not only consider our actions and their immediate consequences, but the subsequent effects of those actions as well. Failing to consider the second and third order effects can unleash disaster.

6. Probabilistic Thinking
Probabilistic thinking is essentially trying to estimate, using some tools of math and logic, the likelihood of any specific outcome coming to pass. It is one of the best tools we have to improve the accuracy of our decisions. In a world where each moment is determined by an infinitely complex set of factors, probabilistic thinking helps us identify the most likely outcomes. When we know these our decisions can be more precise and effective.

This includes Fat-Tailed Processes

A process can often look like a normal distribution but have a large “tail” – meaning that seemingly outlier events are far more likely than they are in an actual normal distribution. A strategy or process may be far more risky than a normal distribution is capable of describing if the fat tail is on the negative side, or far more profitable if the fat tail is on the positive side. Much of the human social world is said to be fat-tailed rather than normally distributed.

and Bayesian Updating

The Bayesian method is a method of thought (named for Thomas Bayes) whereby one takes into account all prior relevant probabilities and then incrementally updates them as newer information arrives. This method is especially productive given the fundamentally non-deterministic world we experience: We must use prior odds and new information in combination to arrive at our best decisions. This is not necessarily our intuitive decision-making engine.

7. Inversion
Inversion is a powerful tool to improve your thinking because it helps you identify and remove obstacles to success. The root of inversion is “invert,” which means to upend or turn upside down. As a thinking tool it means approaching a situation from the opposite end of the natural starting point. Most of us tend to think one way about a problem: forward. Inversion allows us to flip the problem around and think backward. Sometimes it’s good to start at the beginning, but it can be more useful to start at the end.

8. Occam’s Razor
Simpler explanations are more likely to be true than complicated ones. This is the essence of Occam’s Razor, a classic principle of logic and problem-solving. Instead of wasting your time trying to disprove complex scenarios, you can make decisions more confidently by basing them on the explanation that has the fewest moving parts.
Read more on Occam’s Razor

9. Hanlon’s Razor
Hard to trace in its origin, Hanlon’s Razor states that we should not attribute to malice that which is more easily explained by stupidity. In a complex world, using this model helps us avoid paranoia and ideology. By not generally assuming that bad results are the fault of a bad actor, we look for options instead of missing opportunities. This model reminds us that people do make mistakes. It demands that we ask if there is another reasonable explanation for the events that have occurred. The explanation most likely to be right is the one that contains the least amount of intent.

Numeracy
1. Permutations and Combinations

The mathematics of permutations and combinations leads us to understand the practical probabilities of the world around us, how things can be ordered, and how we should think about things.

2. Algebraic Equivalence

The introduction of algebra allowed us to demonstrate mathematically and abstractly that two seemingly different things could be the same. By manipulating symbols, we can demonstrate equivalence or inequivalence, the use of which led humanity to untold engineering and technical abilities. Knowing at least the basics of algebra can allow us to understand a variety of important results.

3. Randomness

Though the human brain has trouble comprehending it, much of the world is composed of random, non-sequential, non-ordered events. We are “fooled” by random effects when we attribute causality to things that are actually outside of our control. If we don’t course-correct for this fooled-by-randomness effect – our faulty sense of pattern-seeking – we will tend to see things as being more predictable than they are and act accordingly.

4. Stochastic Processes (Poisson, Markov, Random Walk)

A stochastic process is a random statistical process and encompasses a wide variety of processes in which the movement of an individual variable can be impossible to predict but can be thought through probabilistically. The wide variety of stochastic methods helps us describe systems of variables through probabilities without necessarily being able to determine the position of any individual variable over time. For example, it’s not possible to predict stock prices on a day-to-day basis, but we can describe the probability of various distributions of their movements over time. Obviously, it is much more likely that the stock market (a stochastic process) will be up or down 1% in a day than up or down 10%, even though we can’t predict what tomorrow will bring.

5. Compounding

It’s been said that Einstein called compounding a wonder of the world. He probably didn’t, but it is a wonder. Compounding is the process by which we add interest to a fixed sum, which then earns interest on the previous sum and the newly added interest, and then earns interest on that amount, and so on ad infinitum. It is an exponential effect, rather than a linear, or additive, effect. Money is not the only thing that compounds; ideas and relationships do as well. In tangible realms, compounding is always subject to physical limits and diminishing returns; intangibles can compound more freely. Compounding also leads to the time value of money, which underlies all of modern finance.

6. Multiplying by Zero

Any reasonably educated person knows that any number multiplied by zero, no matter how large the number, is still zero. This is true in human systems as well as mathematical ones. In some systems, a failure in one area can negate great effort in all other areas. As simple multiplication would show, fixing the “zero” often has a much greater effect than does trying to enlarge the other areas.

7. Churn

Insurance companies and subscription services are well aware of the concept of churn – every year, a certain number of customers are lost and must be replaced. Standing still is the equivalent of losing, as seen in the model called the “Red Queen Effect.” Churn is present in many business and human systems: A constant figure is periodically lost and must be replaced before any new figures are added over the top.

8. Law of Large Numbers

One of the fundamental underlying assumptions of probability is that as more instances of an event occur, the actual results will converge on the expected ones. For example, if I know that the average man is 5 feet 10 inches tall, I am far more likely to get an average of 5′10″ by selecting 500 men at random than 5 men at random. The opposite of this model is the law of small numbers, which states that small samples can and should be looked at with great skepticism.

9. Bell Curve/Normal Distribution

The normal distribution is a statistical process that leads to the well-known graphical representation of a bell curve, with a meaningful central “average” and increasingly rare standard deviations from that average when correctly sampled. (The so-called “central limit” theorem.) Well-known examples include human height and weight, but it’s just as important to note that many common processes, especially in non-tangible systems like social systems, do not follow the normal distribution.

10. Power Laws

One of the most common processes that does not fit the normal distribution is that of a power law, whereby one quantity varies with another’s exponent rather than linearly. For example, the Richter scale describes the power of earthquakes on a power-law distribution scale: an 8 is 10x more destructive than a 7, and a 9 is 10x more destructive than an 8. The central limit theorem does not apply and there is thus no “average” earthquake. This is true of all power-law distributions.

11. Regression to the Mean

In a normally distributed system, long deviations from the average will tend to return to that average with an increasing number of observations: the so-called Law of Large Numbers. We are often fooled by regression to the mean, as with a sick patient improving spontaneously around the same time they begin taking an herbal remedy, or a poorly performing sports team going on a winning streak. We must be careful not to confuse statistically likely events with causal ones.

12. Order of Magnitude

In many, perhaps most, systems, quantitative description down to a precise figure is either impossible or useless (or both). For example, estimating the distance between our galaxy and the next one over is a matter of knowing not the precise number of miles, but how many zeroes are after the 1. Is the distance about 1 million miles or about 1 billion? This thought habit can help us escape useless precision.

Systems
1. Scale

One of the most important principles of systems is that they are sensitive to scale. Properties (or behaviors) tend to change when you scale them up or down. In studying complex systems, we must always be roughly quantifying – in orders of magnitude, at least – the scale at which we are observing, analyzing, or predicting the system.

2. Law of Diminishing Returns

Related to scale, most important real-world results are subject to an eventual decrease of incremental value. A good example would be a poor family: Give them enough money to thrive, and they are no longer poor. But after a certain point, additional money will not improve their lot; there is a clear diminishing return of additional dollars at some roughly quantifiable point. Often, the law of diminishing returns veers into negative territory – i.e., receiving too much money could destroy the poor family.

3. Pareto Principle

Named for Italian polymath Vilfredo Pareto, who noticed that 80% of Italy’s land was owned by about 20% of its population, the Pareto Principle states that a small amount of some phenomenon causes a disproportionately large effect. The Pareto Principle is an example of a power-law type of statistical distribution – as distinguished from a traditional bell curve – and is demonstrated in various phenomena ranging from wealth to city populations to important human habits.

4. Feedback Loops (and Homeostasis)

All complex systems are subject to positive and negative feedback loops whereby A causes B, which in turn influences A (and C), and so on – with higher-order effects frequently resulting from continual movement of the loop. In a homeostatic system, a change in A is often brought back into line by an opposite change in B to maintain the balance of the system, as with the temperature of the human body or the behavior of an organizational culture. Automatic feedback loops maintain a “static” environment unless and until an outside force changes the loop. A “runaway feedback loop” describes a situation in which the output of a reaction becomes its own catalyst (auto-catalysis).

5. Chaos Dynamics (Butterfly Effect)/ (Sensitivity to Initial Conditions)

In a world such as ours, governed by chaos dynamics, small changes (perturbations) in initial conditions have massive downstream effects as near-infinite feedback loops occur; this phenomenon is also called the butterfly effect. This means that some aspects of physical systems (like the weather more than a few days from now) as well as social systems (the behavior of a group of human beings over a long period) are fundamentally unpredictable.

6. Preferential Attachment (Cumulative Advantage)

A preferential attachment situation occurs when the current leader is given more of the reward than the laggards, thereby tending to preserve or enhance the status of the leader. A strong network effect is a good example of preferential attachment; a market with 10x more buyers and sellers than the next largest market will tend to have a preferential attachment dynamic.

7. Emergence

Higher-level behavior tends to emerge from the interaction of lower-order components. The result is frequently not linear – not a matter of simple addition – but rather non-linear, or exponential. An important resulting property of emergent behavior is that it cannot be predicted from simply studying the component parts.

8. Irreducibility 

We find that in most systems there are irreducible quantitative properties, such as complexity, minimums, time, and length. Below the irreducible level, the desired result simply does not occur. One cannot get several women pregnant to reduce the amount of time needed to have one child, and one cannot reduce a successfully built automobile to a single part. These results are, to a defined point, irreducible.

9. Tragedy of the Commons

A concept introduced by the economist and ecologist Garrett Hardin, the Tragedy of the Commons states that in a system where a common resource is shared, with no individual responsible for the wellbeing of the resource, it will tend to be depleted over time. The Tragedy is reducible to incentives: Unless people collaborate, each individual derives more personal benefit than the cost that he or she incurs, and therefore depletes the resource for fear of missing out.

10. Gresham’s Law

Gresham’s Law, named for the financier Thomas Gresham, states that in a system of circulating currency, forged currency will tend to drive out real currency, as real currency is hoarded and forged currency is spent. We see a similar result in human systems, as with bad behavior driving out good behavior in a crumbling moral system, or bad practices driving out good practices in a crumbling economic system. Generally, regulation and oversight are required to prevent results that follow Gresham’s Law.

11. Algorithms

While hard to precisely define, an algorithm is generally an automated set of rules or a “blueprint” leading a series of steps or actions resulting in a desired outcome, and often stated in the form of a series of “If → Then” statements. Algorithms are best known for their use in modern computing, but are a feature of biological life as well. For example, human DNA contains an algorithm for building a human being.

12. Fragility – Robustness – Antifragility

Popularized by Nassim Taleb, the sliding scale of fragility, robustness, and antifragility refers to the responsiveness of a system to incremental negative variability. A fragile system or object is one in which additional negative variability has a disproportionately negative impact, as with a coffee cup shattering from a 6-foot fall, but receiving no damage at all (rather than 1/6th of the damage) from a 1-foot fall. A robust system or object tends to be neutral to the additional negativity variability, and of course, an antifragile system benefits: If there were a cup that got stronger when dropped from 6 feet than when dropped from 1 foot, it would be termed antifragile.

13. Backup Systems/Redundancy

A critical model of the engineering profession is that of backup systems. A good engineer never assumes the perfect reliability of the components of the system. He or she builds in redundancy to protect the integrity of the total system. Without the application of this robustness principle, tangible and intangible systems tend to fail over time.

14. Margin of Safety

Similarly, engineers have also developed the habit of adding a margin for error into all calculations. In an unknown world, driving a 9,500-pound bus over a bridge built to hold precisely 9,600 pounds is rarely seen as intelligent. Thus, on the whole, few modern bridges ever fail. In practical life outside of physical engineering, we can often profitably give ourselves margins as robust as the bridge system.

15. Criticality

A system becomes critical when it is about to jump discretely from one phase to another. The marginal utility of the last unit before the phase change is wildly higher than any unit before it. A frequently cited example is water turning from a liquid to a vapor when heated to a specific temperature. “Critical mass” refers to the mass needed to have the critical event occur, most commonly in a nuclear system.

16. Network Effects

A network tends to become more valuable as nodes are added to the network: this is known as the network effect. An easy example is contrasting the development of the electricity system and the telephone system. If only one house has electricity, its inhabitants have gained immense value, but if only one house has a telephone, its inhabitants have gained nothing of use. Only with additional telephones does the phone network gain value. This network effect is widespread in the modern world and creates immense value for organizations and customers alike.

17. Via Negativa – Omission/Removal/Avoidance of Harm

In many systems, improvement is at best, or at times only, a result of removing bad elements rather than of adding good elements. This is a credo built into the modern medical profession: First, do no harm. Similarly, if one has a group of children behaving badly, removal of the instigator is often much more effective than any form of punishment meted out to the whole group.

18. The Lindy Effect

The Lindy Effect refers to the life expectancy of a non-perishable object or idea being related to its current lifespan. If an idea or object has lasted for X number of years, it would be expected (on average) to last another X years. Although a human being who is 90 and lives to 95 does not add 5 years to his or her life expectancy, non-perishables lengthen their life expectancy as they continually survive. A classic text is a prime example: if humanity has been reading Shakespeare’s plays for 500 years, it will be expected to read them for another 500.

19. Renormalization Group

The renormalization group technique allows us to think about physical and social systems at different scales. An idea from physics, and a complicated one at that, the application of a renormalization group to social systems allows us to understand why a small number of stubborn individuals can have a disproportionate impact if those around them follow suit on increasingly large scales.

20. Spring-loading

A system is spring-loaded if it is coiled in a certain direction, positive or negative. Positively spring-loading systems and relationships is important in a fundamentally unpredictable world to help protect us against negative events. The reverse can be very destructive.

21. Complex Adaptive Systems

A complex adaptive system, as distinguished from a complex system in general, is one that can understand itself and change based on that understanding. Complex adaptive systems are social systems. The difference is best illustrated by thinking about weather prediction contrasted to stock market prediction. The weather will not change based on an important forecaster’s opinion, but the stock market might. Complex adaptive systems are thus fundamentally not predictable.

Physical World
1. Laws of Thermodynamics

The laws of thermodynamics describe energy in a closed system. The laws cannot be escaped and underlie the physical world. They describe a world in which useful energy is constantly being lost, and energy cannot be created or destroyed. Applying their lessons to the social world can be a profitable enterprise.

2. Reciprocity

If I push on a wall, physics tells me that the wall pushes back with equivalent force. In a biological system, if one individual acts on another, the action will tend to be reciprocated in kind. And of course, human beings act with intense reciprocity demonstrated as well.

3. Velocity

Velocity is not equivalent to speed; the two are sometimes confused. Velocity is speed plus vector: how fast something gets somewhere. An object that moves two steps forward and then two steps back has moved at a certain speed but shows no velocity. The addition of the vector, that critical distinction, is what we should consider in practical life.

4. Relativity

Relativity has been used in several contexts in the world of physics, but the important aspect to study is the idea that an observer cannot truly understand a system of which he himself is a part. For example, a man inside an airplane does not feel like he is experiencing movement, but an outside observer can see that movement is occurring. This form of relativity tends to affect social systems in a similar way.

5. Activation Energy

A fire is not much more than a combination of carbon and oxygen, but the forests and coal mines of the world are not combusting at will because such a chemical reaction requires the input of a critical level of “activation energy” in order to get a reaction started. Two combustible elements alone are not enough.

6. Catalysts

A catalyst either kick-starts or maintains a chemical reaction, but isn’t itself a reactant. The reaction may slow or stop without the addition of catalysts. Social systems, of course, take on many similar traits, and we can view catalysts in a similar light.

7. Leverage

Most of the engineering marvels of the world have been accomplished with applied leverage. As famously stated by Archimedes, “Give me a lever long enough and I shall move the world.” With a small amount of input force, we can make a great output force through leverage. Understanding where we can apply this model to the human world can be a source of great success.

8. Inertia

An object in motion with a certain vector wants to continue moving in that direction unless acted upon. This is a fundamental physical principle of motion; however, individuals, systems, and organizations display the same effect. It allows them to minimize the use of energy, but can cause them to be destroyed or eroded.

9. Alloying

When we combine various elements, we create new substances. This is no great surprise, but what can be surprising in the alloying process is that 2+2 can equal not 4 but 6 – the alloy can be far stronger than the simple addition of the underlying elements would lead us to believe. This process leads us to engineer great physical objects, but we understand many intangibles in the same way; a combination of the right elements in social systems or even individuals can create a 2+2=6 effect similar to alloying.

10. Viscosity 
Viscosity is the “measure of how hard it is for one layer of fluid to slide over another layer.” If a liquid is hard to move it is more viscous. If it is more viscous there is more resistance. Viscosity isn’t usually an issue for humans. We have to deal with gravity and inertia, although viscosity is always present. But for small particles, gravity and inertia become a non-issue compared to viscosity. We thus learn that when we change the scale we change what forces are relevant.

The Biological World
1. Incentives

All creatures respond to incentives to keep themselves alive. This is the basic insight of biology. Constant incentives will tend to cause a biological entity to have constant behavior, to an extent. Humans are included and are particularly great examples of the incentive-driven nature of biology; however, humans are complicated in that their incentives can be hidden or intangible. The rule of life is to repeat what works and has been rewarded.

2. Cooperation (Including Symbiosis and Prisoner’s Dilemma)

Competition tends to describe most biological systems, but cooperation at various levels is just as important a dynamic. In fact, the cooperation of a bacterium and a simple cell probably created the first complex cell and all of the life we see around us. Without cooperation, no group survives, and the cooperation of groups gives rise to even more complex versions of organization. Cooperation and competition tend to coexist at multiple levels.

The Prisoner’s Dilemma is a famous application of game theory in which two prisoners are both better off cooperating with each other, but if one of them cheats, the other is better off cheating. Thus the dilemma. This model shows up in economic life, in war, and in many other areas of practical human life. Though the prisoner’s dilemma theoretically leads to a poor result, in the real world, cooperation is nearly always possible and must be explored.

3. Tendency to Minimize Energy Output (Mental & Physical)

In a physical world governed by thermodynamics and competition for limited energy and resources, any biological organism that was wasteful with energy would be at a severe disadvantage for survival. Thus, we see in most instances that behavior is governed by a tendency to minimize energy usage when at all possible.

4. Adaptation

Species tend to adapt to their surroundings in order to survive, given the combination of their genetics and their environment – an always-unavoidable combination. However, adaptations made in an individual’s lifetime are not passed down genetically, as was once thought: Populations of species adapt through the process of evolution by natural selection, as the most-fit examples of the species replicate at an above-average rate.

5. Evolution by Natural Selection

Evolution by natural selection was once called “the greatest idea anyone ever had.” In the 19th century, Charles Darwin and Alfred Russel Wallace simultaneous realized that species evolve through random mutation and differential survival rates. If we call human intervention in animal-breeding an example of “artificial selection,” we can call Mother Nature deciding the success or failure of a particular mutation “natural selection.” Those best suited for survival tend to be preserved. But of course, conditions change.

6. The Red Queen Effect (Co-evolutionary Arms Race)

The evolution-by-natural-selection model leads to something of an arms race among species competing for limited resources. When one species evolves an advantageous adaptation, a competing species must respond in kind or fail as a species. Standing pat can mean falling behind. This arms race is called the Red Queen Effect for the character in Alice in Wonderland who said, “Now, here, you see, it takes all the running you can do, to keep in the same place.”

7. Replication

A fundamental building block of diverse biological life is high-fidelity replication. The fundamental unit of replication seems to be the DNA molecule, which provides a blueprint for the offspring to be built from physical building blocks. There are a variety of replication methods, but most can be lumped into sexual and asexual.

8. Hierarchical and Other Organizing Instincts

Most complex biological organisms have an innate feel for how they should organize. While not all of them end up in hierarchical structures, many do, especially in the animal kingdom. Human beings like to think they are outside of this, but they feel the hierarchical instinct as strongly as any other organism. This includes the Stanford Prison Experiment and Milgram Experiments, which demonstrated what humans learned practically many years before: the human bias towards being influenced by authority. In a dominance hierarchy such as ours, we tend to look to the leader for guidance on behavior, especially in situations of stress or uncertainty. Thus, authority figures have a responsibility to act well, whether they like it or not.

9. Self-Preservation Instincts

Without a strong self-preservation instinct in an organism’s DNA, it would tend to disappear over time, thus eliminating that DNA. While cooperation is another important model, the self-preservation instinct is strong in all organisms and can cause violent, erratic, and/or destructive behavior for those around them.

10. Simple Physiological Reward-Seeking

All organisms feel pleasure and pain from simple chemical processes in their bodies which respond predictably to the outside world. Reward-seeking is an effective survival-promoting technique on average. However, those same pleasure receptors can be co-opted to cause destructive behavior, as with drug abuse.

11. Exaptation

Introduced by the biologist Steven Jay Gould, an exaptation refers to a trait developed for one purpose that is later used for another purpose. This is one way to explain the development of complex biological features like an eyeball; in a more primitive form, it may have been used for something else. Once it was there, and once it developed further, 3D sight became possible.

12. Ecosystems

An ecosystem describes any group of organisms coexisting with the natural world. Most ecosystems show diverse forms of life taking on different approaches to survival, with such pressures leading to varying behavior. Social systems can be seen in the same light as the physical ecosystems and many of the same conclusions can be made.

13. Niches

Most organisms find a niche: a method of competing and behaving for survival. Usually, a species will select a niche for which it is best adapted. The danger arises when multiple species begin competing for the same niche, which can cause an extinction – there can be only so many species doing the same thing before limited resources give out.

14. Dunbar’s Number

The primatologist Robin Dunbar observed through study that the number of individuals a primate can get to know and trust closely is related to the size of its neocortex. Extrapolating from his study of primates, Dunbar theorized that the Dunbar number for a human being is somewhere in the 100–250 range, which is supported by certain studies of human behavior and social networks.

Human Nature & Judgment
1. Trust

Fundamentally, the modern world operates on trust. Familial trust is generally a given (otherwise we’d have a hell of a time surviving), but we also choose to trust chefs, clerks, drivers, factory workers, executives, and many others. A trusting system is one that tends to work most efficiently; the rewards of trust are extremely high.

2. Bias from Incentives

Highly responsive to incentives, humans have perhaps the most varied and hardest to understand set of incentives in the animal kingdom. This causes us to distort our thinking when it is in our own interest to do so. A wonderful example is a salesman truly believing that his product will improve the lives of its users. It’s not merely convenient that he sells the product; the fact of his selling the product causes a very real bias in his own thinking.

3. Pavlovian Association

Ivan Pavlov very effectively demonstrated that animals can respond not just to direct incentives but also to associated objects; remember the famous dogs salivating at the ring of a bell. Human beings are much the same and can feel positive and negative emotion towards intangible objects, with the emotion coming from past associations rather than direct effects.

4. Tendency to Feel Envy & Jealousy

Humans have a tendency to feel envious of those receiving more than they are, and a desire “get what is theirs” in due course. The tendency towards envy is strong enough to drive otherwise irrational behavior, but is as old as humanity itself. Any system ignorant of envy effects will tend to self-immolate over time.

5. Tendency to Distort Due to Liking/Loving or Disliking/Hating

Based on past association, stereotyping, ideology, genetic influence, or direct experience, humans have a tendency to distort their thinking in favor of people or things that they like and against people or things they dislike. This tendency leads to overrating the things we like and underrating or broadly categorizing things we dislike, often missing crucial nuances in the process.

6. Denial 

Anyone who has been alive long enough realizes that, as the saying goes, “denial is not just a river in Africa.” This is powerfully demonstrated in situations like war or drug abuse, where denial has powerful destructive effects but allows for behavioral inertia. Denying reality can be a coping mechanism, a survival mechanism, or a purposeful tactic.

7. Availability Heuristic

One of the most useful findings of modern psychology is what Daniel Kahneman calls the Availability Bias or Heuristic: We tend to most easily recall what is salient, important, frequent, and recent. The brain has its own energy-saving and inertial tendencies that we have little control over – the availability heuristic is likely one of them. Having a truly comprehensive memory would be debilitating. Some sub-examples of the availability heuristic include the Anchoring and Sunk Cost Tendencies.

8. Representativeness Heuristic

The three major psychological findings that fall under Representativeness, also defined by Kahneman and his partner Tversky, are:

a. Failure to Account for Base Rates

An unconscious failure to look at past odds in determining current or future behavior.

b. Tendency to Stereotype 

The tendency to broadly generalize and categorize rather than look for specific nuance. Like availability, this is generally a necessary trait for energy-saving in the brain.

c. Failure to See False Conjunctions

Most famously demonstrated by the Linda Test, the same two psychologists showed that students chose more vividly described individuals as more likely to fit into a predefined category than individuals with broader, more inclusive, but less vivid descriptions, even if the vivid example was a mere subset of the more inclusive set. These specific examples are seen as more representative of the category than those with the broader but vaguer descriptions, in violation of logic and probability.

9. Social Proof (Safety in Numbers)

Human beings are one of many social species, along with bees, ants, and chimps, among many more. We have a DNA-level instinct to seek safety in numbers and will look for social guidance of our behavior. This instinct creates a cohesive sense of cooperation and culture which would not otherwise be possible, but also leads us to do foolish things if our group is doing them as well.

10. Narrative Instinct

Human beings have been appropriately called “the storytelling animal” because of our instinct to construct and seek meaning in narrative. It’s likely that long before we developed the ability to write or to create objects, we were telling stories and thinking in stories. Nearly all social organizations, from religious institutions to corporations to nation-states, run on constructions of the narrative instinct.

11. Curiosity Instinct

We like to call other species curious, but we are the most curious of all, an instinct which led us out of the savanna and led us to learn a great deal about the world around us, using that information to create the world in our collective minds. The curiosity instinct leads to unique human behavior and forms of organization like the scientific enterprise. Even before there were direct incentives to innovate, humans innovated out of curiosity.

12. Language Instinct

The psychologist Steven Pinker calls our DNA-level instinct to learn grammatically constructed language the Language Instinct. The idea that grammatical language is not a simple cultural artifact was first popularized by the linguist Noam Chomsky. As we saw with the narrative instinct, we use these instincts to create shared stories, as well as to gossip, solve problems, and fight, among other things. Grammatically ordered language theoretically carries infinite varying meaning.

13. First-Conclusion Bias

As Charlie Munger famously pointed out, the mind works a bit like a sperm and egg: the first idea gets in and then the mind shuts. Like many other tendencies, this is probably an energy-saving device. Our tendency to settle on first conclusions leads us to accept many erroneous results and cease asking questions; it can be countered with some simple and useful mental routines.

14. Tendency to Overgeneralize from Small Samples

It’s important for human beings to generalize; we need not see every instance to understand the general rule, and this works to our advantage. With generalizing, however, comes a subset of errors when we forget about the Law of Large Numbers and act as if it does not exist. We take a small number of instances and create a general category, even if we have no statistically sound basis for the conclusion.

15. Relative Satisfaction/Misery Tendencies

The envy tendency is probably the most obvious manifestation of the relative satisfaction tendency, but nearly all studies of human happiness show that it is related to the state of the person relative to either their past or their peers, not absolute. These relative tendencies cause us great misery or happiness in a very wide variety of objectively different situations and make us poor predictors of our own behavior and feelings.

16. Commitment & Consistency Bias

As psychologists have frequently and famously demonstrated, humans are subject to a bias towards keeping their prior commitments and staying consistent with our prior selves when possible. This trait is necessary for social cohesion: people who often change their conclusions and habits are often distrusted. Yet our bias towards staying consistent can become, as one wag put it, a “hobgoblin of foolish minds” – when it is combined with the first-conclusion bias, we end up landing on poor answers and standing pat in the face of great evidence.

17. Hindsight Bias

Once we know the outcome, it’s nearly impossible to turn back the clock mentally. Our narrative instinct leads us to reason that we knew it all along (whatever “it” is), when in fact we are often simply reasoning post-hoc with information not available to us before the event. The hindsight bias explains why it’s wise to keep a journal of important decisions for an unaltered record and to re-examine our beliefs when we convince ourselves that we knew it all along.

18. Sensitivity to Fairness

Justice runs deep in our veins. In another illustration of our relative sense of well-being, we are careful arbiters of what is fair. Violations of fairness can be considered grounds for reciprocal action, or at least distrust. Yet fairness itself seems to be a moving target. What is seen as fair and just in one time and place may not be in another. Consider that slavery has been seen as perfectly natural and perfectly unnatural in alternating phases of human existence.

19. Tendency to Overestimate Consistency of Behavior (Fundamental Attribution Error)

We tend to over-ascribe the behavior of others to their innate traits rather than to situational factors, leading us to overestimate how consistent that behavior will be in the future. In such a situation, predicting behavior seems not very difficult. Of course, in practice this assumption is consistently demonstrated to be wrong, and we are consequently surprised when others do not act in accordance with the “innate” traits we’ve endowed them with.

20. Influence of Stress (Including Breaking Points)

Stress causes both mental and physiological responses and tends to amplify the other biases. Almost all human mental biases become worse in the face of stress as the body goes into a fight-or-flight response, relying purely on instinct without the emergency brake of Daniel Kahneman’s “System 2” type of reasoning. Stress causes hasty decisions, immediacy, and a fallback to habit, thus giving rise to the elite soldiers’ motto: “In the thick of battle, you will not rise to the level of your expectations, but fall to the level of your training.”

21. Survivorship Bias

A major problem with historiography – our interpretation of the past – is that history is famously written by the victors. We do not see what Nassim Taleb calls the “silent grave” – the lottery ticket holders who did not win. Thus, we over-attribute success to things done by the successful agent rather than to randomness or luck, and we often learn false lessons by exclusively studying victors without seeing all of the accompanying losers who acted in the same way but were not lucky enough to succeed.

22. Tendency to Want to Do Something (Fight/Flight, Intervention, Demonstration of Value, etc.)

We might term this Boredom Syndrome: Most humans have the tendency to need to act, even when their actions are not needed. We also tend to offer solutions even when we do not enough knowledge to solve the problem.

23. Falsification / Confirmation Bias

What a man wishes, he also believes. Similarly, what we believe is what we choose to see. This is commonly referred to as the confirmation bias. It is a deeply ingrained mental habit, both energy-conserving and comfortable, to look for confirmations of long-held wisdom rather than violations. Yet the scientific process – including hypothesis generation, blind testing when needed, and objective statistical rigor – is designed to root out precisely the opposite, which is why it works so well when followed.

The modern scientific enterprise operates under the principle of falsification: A method is termed scientific if it can be stated in such a way that a certain defined result would cause it to be proved false. Pseudo-knowledge and pseudo-science operate and propagate by being unfalsifiable – as with astrology, we are unable to prove them either correct or incorrect because the conditions under which they would be shown false are never stated.

Microeconomics & Strategy
1. Opportunity Costs

Doing one thing means not being able to do another. We live in a world of trade-offs, and the concept of opportunity cost rules all. Most aptly summarized as “there is no such thing as a free lunch.”

2. Creative Destruction

Coined by economist Joseph Schumpeter, the term “creative destruction” describes the capitalistic process at work in a functioning free-market system. Motivated by personal incentives (including but not limited to financial profit), entrepreneurs will push to best one another in a never-ending game of creative one-upmanship, in the process destroying old ideas and replacing them with newer technology. Beware getting left behind.

3. Comparative Advantage

The Scottish economist David Ricardo had an unusual and non-intuitive insight: Two individuals, firms, or countries could benefit from trading with one another even if one of them was better at everything. Comparative advantage is best seen as an applied opportunity cost: If it has the opportunity to trade, an entity gives up free gains in productivity by not focusing on what it does best.

4. Specialization (Pin Factory)

Another Scottish economist, Adam Smith, highlighted the advantages gained in a free-market system by specialization. Rather than having a group of workers each producing an entire item from start to finish, Smith explained that it’s usually far more productive to have each of them specialize in one aspect of production. He also cautioned, however, that each worker might not enjoy such a life; this is a trade-off of the specialization model.

5. Seizing the Middle

In chess, the winning strategy is usually to seize control of the middle of the board, so as to maximize the potential moves that can be made and control the movement of the maximal number of pieces. The same strategy works profitably in business, as can be demonstrated by John D. Rockefeller’s control of the refinery business in the early days of the oil trade and Microsoft’s control of the operating system in the early days of the software trade.

6. Trademarks, Patents, and Copyrights

These three concepts, along with other related ones, protect the creative work produced by enterprising individuals, thus creating additional incentives for creativity and promoting the creative-destruction model of capitalism. Without these protections, information and creative workers have no defense against their work being freely distributed.

7. Double-Entry Bookkeeping

One of the marvels of modern capitalism has been the bookkeeping system introduced in Genoa in the 14th century. The double-entry system requires that every entry, such as income, also be entered into another corresponding account. Correct double-entry bookkeeping acts as a check on potential accounting errors and allows for accurate records and thus, more accurate behavior by the owner of a firm.

8. Utility (Marginal, Diminishing, Increasing)

The usefulness of additional units of any good tends to vary with scale. Marginal utility allows us to understand the value of one additional unit, and in most practical areas of life, that utility diminishes at some point. On the other hand, in some cases, additional units are subject to a “critical point” where the utility function jumps discretely up or down. As an example, giving water to a thirsty man has diminishing marginal utility with each additional unit, and can eventually kill him with enough units.

9. Bottlenecks

A bottleneck describes the place at which a flow (of a tangible or intangible) is stopped, thus holding it back from continuous movement. As with a clogged artery or a blocked drain, a bottleneck in production of any good or service can be small but have a disproportionate impact if it is in the critical path.

10. Bribery

Often ignored in mainstream economics, the concept of bribery is central to human systems: Given the chance, it is often easier to pay a certain agent to look the other way than to follow the rules. The enforcer of the rules is then neutralized. This principle/agent problem can be seen as a form of arbitrage.

11. Arbitrage

Given two markets selling an identical good, an arbitrage exists if the good can profitably be bought in one market and sold at a profit in the other. This model is simple on its face, but can present itself in disguised forms: The only gas station in a 50-mile radius is also an arbitrage as it can buy gasoline and sell it at the desired profit (temporarily) without interference. Nearly all arbitrage situations eventually disappear as they are discovered and exploited.

12. Supply and Demand

The basic equation of biological and economic life is one of limited supply of necessary goods and competition for those goods. Just as biological entities compete for limited usable energy, so too do economic entities compete for limited customer wealth and limited demand for their products. The point at which supply and demand for a given good are equal is called an equilibrium; however, in practical life, equilibrium points tend to be dynamic and changing, never static.

13. Scarcity

Game theory describes situations of conflict, limited resources, and competition. Given a certain situation and a limited amount of resources and time, what decisions are competitors likely to make, and which should they make? One important note is that traditional game theory may describe humans as more rational than they really are. Game theory is theory, after all.

14. Mr. Market

Mr. Market was introduced by the investor Benjamin Graham in his seminal book The Intelligent Investor to represent the vicissitudes of the financial markets. As Graham explains, the markets are a bit like a moody neighbor, sometimes waking up happy and sometimes waking up sad – your job as an investor is to take advantage of him in his bad moods and sell to him in his good moods. This attitude is contrasted to an efficient-market hypothesis in which Mr. Market always wakes up in the middle of the bed, never feeling overly strong in either direction.

Military & War
1. Seeing the Front

One of the most valuable military tactics is the habit of “personally seeing the front” before making decisions – not always relying on advisors, maps, and reports, all of which can be either faulty or biased. The Map/Territory model illustrates the problem with not seeing the front, as does the incentive model. Leaders of any organization can generally benefit from seeing the front, as not only does it provide firsthand information, but it also tends to improve the quality of secondhand information.

2. Asymmetric Warfare

The asymmetry model leads to an application in warfare whereby one side seemingly “plays by different rules” than the other side due to circumstance. Generally, this model is applied by an insurgency with limited resources. Unable to out-muscle their opponents, asymmetric fighters use other tactics, as with terrorism creating fear that’s disproportionate to their actual destructive ability.

3. Two-Front War

The Second World War was a good example of a two-front war. Once Russia and Germany became enemies, Germany was forced to split its troops and send them to separate fronts, weakening their impact on either front. In practical life, opening a two-front war can often be a useful tactic, as can solving a two-front war or avoiding one, as in the example of an organization tamping down internal discord to focus on its competitors.

4. Counterinsurgency

Though asymmetric insurgent warfare can be extremely effective, over time competitors have also developed counterinsurgency strategies. Recently and famously, General David Petraeus of the United States led the development of counterinsurgency plans that involved no additional force but substantial additional gains. Tit-for-tat warfare or competition will often lead to a feedback loop that demands insurgency and counterinsurgency.

5. Mutually Assured Destruction

Somewhat paradoxically, the stronger two opponents become, the less likely they may be to destroy one another. This process of mutually assured destruction occurs not just in warfare, as with the development of global nuclear warheads, but also in business, as with the avoidance of destructive price wars between competitors. However, in a fat-tailed world, it is also possible that mutually assured destruction scenarios simply make destruction more severe in the event of a mistake (pushing destruction into the “tails” of the distribution).

================================================================================
Pomodoro technique
http://baomee.info/pdf/technique/1.pdf
tags: work productivity habits focus concentration time-management
1 Pomodoro (30 minutes) = 25 minutes of work + 5-minute break
- When the timer rings, this signals that the current activity is peremptorily
  (though temporarily) finished. You’re not allowed to keep on working “just for
  a few more minutes”, even if you’re convinced that in those few minutes you
  could complete the task at hand. The 3-5 minute break gives you the time you
  need to “disconnect” from your work. This allows the mind to assimilate what’s
  been learned in the last 25 minutes.
- Every 4 Pomodoros, stop the activity you’re working on and take a longer
  break, 15~30 minutes.
- During breaks, the important thing is not to do anything complex, otherwise
  your mind won’t be able to reorganize and integrate what you’ve learned, and
  as a result you won’t be able to give the next Pomodoro your best effort.
  Obviously, during this break too you need to stop thinking about what you did
  during the last Pomodoros.
- If you finish a task while the Pomodoro is still ticking, the following rule
  applies: If a Pomodoro Begins, It Has to Ring. It’s a good idea to take
  advantage of the opportunity for overlearning (17), using the remaining
  portion of the Pomodoro to review or repeat what
- Task complexity: "If It Lasts More Than 5-7 Pomodoros, Break It Down."

================================================================================
Ambarella | Embedded Computer Vision SoCs
https://www.ambarella.com/
tags: machine-learning computer-vision software programming embedded soc

================================================================================
tensorflow/cleverhans
https://github.com/tensorflow/cleverhans
tags: machine-learning software programming software-engineering
An adversarial example library for constructing attacks, building defenses, and benchmarking both

================================================================================
osquery
https://github.com/facebook/osquery/
https://osquery.io/
tags: monitoring metrics sysadmin devops hardware system query sql facebook
Relational (SQL) data-model for OS/system info.

================================================================================
netdata
https://github.com/firehol/netdata
tags: monitoring dashboard performance metrics sysadmin devops hardware
server stats/dashboard

================================================================================
The log/event processing pipeline you can't have
https://apenwarr.ca/log/20190216
tags: log monitoring performance metrics sysadmin devops
.
- PRINTK_PERSIST patch to make Linux reuse the dmesg buffer across reboots.
  https://gfiber.googlesource.com/kernel/lockdown/+/0e8afb589c4f746019436a437c05626967721503
    - Everybody should use PRINTK_PERSIST on every computer, virtual or
      physical. Seriously. It's so good.
    - https://lwn.net/Articles/486272/
      > even after a kernel panic or non-panic hard lockup, on the next boot
      > userspace will be able to grab the kernel messages leading up to it
      > ...
      > works with soft reboot (ie. reboot -f).  Since some BIOSes wipe the
      > memory during boot, you might not have any luck.
- loguploader C client
  https://gfiber.googlesource.com/vendor/google/platform/+/master/logupload/client/
- devcert, a tool (and Debian package) which auto-generates a self signed
  "device certificate" wherever it's installed, to identify itself to a server.
  https://gfiber.googlesource.com/vendor/google/platform/+/master/devcert/
.
> It's nice to have real-time alerts, but if I have to choose between somewhat
> delayed alerts or randomly losing log messages when things get ugly, I'll have
> to accept the delayed alerts. Don't lose log messages! You'll regret it.
>
> The best way to not lose messages is to minimize the work done by your log receiver.
.
> our reliability, persistence, and scaling problems are solved: as long as we
> have enough log receiver instances to handle all our devices, and enough disk
> quota to store all our logs, we will never again lose a log message.
>
> That means the rest of our pipeline can be best-effort, complicated, and
> frequently exploding.
.
> what makes this a killer design compared to starting with structured events in
> the first place - is that we can, at any time, change our minds about how to
> parse the logs, without redeploying all the software that produces them.
.
> It turns out you rarely need full-text indexing. ... On the other hand, being
> able to retrieve the exact series of logs (the "narrative") from a particular
> time period across a subset of devices is super useful.
.
> Rather than alerting on behaviour of individual core routers, it turned out
> that the end-to-end behaviour observed by devices in the field were a better
> way to detect virtually any problem. Alert on symptoms, not causes, as the
> SREs like to say. Who has the symptoms? End users.
.
> We had our devices ping different internal servers periodically and log the
> round trip times; in aggregate, we had an amazing view of overloading, packet
> loss, bufferbloat, and poor backbone routing decisions, across the entire
> fleet
.
> We detected some weird configuration problems with the DNS servers in one city
> by comparing the 90th percentile latency of DNS lookups across all the devices
> in every city.
.
> We diagnosed a manufacturing defect in a particular batch of devices, just
> based on their CPU temperature curves and fan speeds.
.
> we spotted a kernel panic that would happen randomly every 10,000 CPU-hours,
> but for every 100,000 devices, that's still 10 times per
> hour of potential clues.

================================================================================
A Guide to the Deceptions, Misinformation, and Word Games Officials Use to Mislead the Public About NSA Surveillance | Electronic Frontier Foundation
  When government officials can‚Äôt directly answer a question with a secret definition, officials will often answer a different question than they were asked. For example, if asked, ‚Äúcan you read Americans‚Äô email without a warrant,‚Äù officials will answer: ‚Äúwe cannot target Americans‚Äô email without a warrant.‚Äù / Bush administration‚Äôs strategy for the ‚ÄúTerrorist Surveillance Program‚Äù: The term ‚ÄúTSP‚Äù ended up being a meaningless label, created by administration officials after the much larger warrantless surveillance program was exposed by the New York Times in 2005. They used it to give the misleading impression that the NSA‚Äôs spying program was narrow and aimed only at intercepting the communications of terrorists. In fact, the larger program affected all Americans.
href="https://www.eff.org/deeplinks/2013/08/guide-deceptions-word-games-obfuscations-officials-use-mislead-public-about-nsa"
tags: nsa surveillance eff police-state
  time="2015-02-11T21:09:22Z" 

================================================================================
New Intel Doc: Do Not Be 'Led Astray' By 'Commonly Understood Definitions' - The Intercept
  Defense Intelligence Agency document that instructs analysts to use words that do not mean what they appear to mean. / one several documents about Executive Order 12333 the ACLU obtained / So, we see that ‚Äúcollection of information‚Äù for DoD 5240.1-R purposes is more than ‚Äúgathering‚Äù ‚Äì it could be described as ‚Äúgathering, plus ‚Ä¶ ‚Äú. For the purposes of DoD 5240.1-R, ‚Äúcollection‚Äù is officially gathering or receiving information, plus an affirmative act in the direction of use or retention of that information.
href="https://firstlook.org/theintercept/2014/09/29/new-intel-doc-led-astray-commonly-understood-definitions"
tags: nsa police-state politics
  time="2015-02-11T21:00:18Z" 

================================================================================
VICTORY: Judge Releases Information about Police Use of Stingray Cell Phone Trackers | American Civil Liberties Union
  Stingrays ‚Äúemulate a cellphone tower‚Äù and ‚Äúforce‚Äù cell phones to register their location and identifying information with the stingray instead of with real cell towers in the area. / Stingrays force cell phones in range to transmit information back ‚Äúat full signal, consuming battery faster.‚Äù / When in use, stingrays are ‚Äúevaluating all the [cell phone] handsets in the area‚Äù / between spring of 2007 and August of 2010, the Tallahassee Police had used stingrays approximately ‚Äú200 or more times.‚Äù
href="https://www.aclu.org/blog/national-security-technology-and-liberty/victory-judge-releases-information-about-police-use"
tags: police-state government privacy
  time="2015-01-28T04:03:34Z" 

================================================================================
IRS sends warning letters to more than 10k cryptocurrency holders
https://news.ycombinator.com/item?id=20536951
tags: police-state government taxes legal
    https://www.irs.gov/newsroom/irs-has-begun-sending-letters-to-virtual-currency-owners-advising-them-to-pay-back-taxes-file-amended-returns-part-of-agencys-larger-efforts
    https://www.reddit.com/r/Bitcoin/comments/chupoe/irs_we_have_information_that_you_have_or_had_one/
    https://www.irsmind.com/audits/irs-begins-targeting-taxpayers-who-misreport-virtual-currency-transactions/
    > Letter 6174:   This is a soft notice informing the taxpayer that there is a likelihood that they did not report their virtual currency transactions. The notice asks them to check their return and, if necessary, file an amended return to correct the misreporting. The taxpayer is not required to respond to the notice and the IRS intends not to follow up on these notices. In short, this is information only to the taxpayer and education on how they comply.
    > Letter 6174-A: This is a “not so soft notice” from the IRS. As in Letter 6174, this letter tells the taxpayer that there is potential misreporting of virtual currency transactions. However, this notices states that the IRS may follow-up with future enforcement action. Again, no response is required if the taxpayer believes that they are in compliance. Taxpayers who receive this notice should be aware that they have been put on “notice” that they have been identified as a noncompliant taxpayer for potential future enforcement.
    > Letter 6173:   Requires a response. This notice requests a response from the taxpayer about the alleged noncompliance. The letter provides instructions on responding to the IRS. The IRS intends to follow up on these responses to determine if the taxpayer is in compliance.

================================================================================
Don’t Put Your Work Email on Your Personal Phone
https://news.ycombinator.com/item?id=20514833
tags: corporate workplace legal security
Using *any* personal device for work makes *all* of your personal devices
subject to seizure if your employer is under investigation.

================================================================================
Noisebridge 
href="https://www.noisebridge.net/"  
tags: sanfrancisco travel hackerspace
  time="2014-12-18T19:36:59Z" 

================================================================================
wat2do | A map of rad things to do today
href="http://www.sfwat2do.com/"  
tags: travel tools sanfrancisco
time="2014-12-18T19:36:03Z" 

================================================================================
How I Rewired My Brain to Become Fluent in Math - Issue 17: Big Bangs - Nautilus
  students can often grasp essentials of an important idea, but this understanding can quickly slip away without consolidation through practice and repetition. / well-ingrained chunks of expertise through practice and repetition / Understanding doesn‚Äôt build fluency; instead, fluency builds understanding. / understanding, after all, is facile, and can easily slip away.
href="http://nautil.us/issue/17/big-bangs/how-i-rewired-my-brain-to-become-fluent-in-math-rd"
tags: learning psychology math pedagogy
  time="2014-12-17T00:55:04Z" 

================================================================================
Michael Pettis' CHINA FINANCIAL MARKETS
https://blog.mpettis.com/
tags: blog economics china
time="2014-12-02T01:05:58Z" 

> http://blog.mpettis.com/2014/09/not-with-a-bank-but-a-whimper/

> It is purely an accounting identity that if other countries become net exporters of capital to the US, they must run current account surpluses (although not necessarily bilateral surpluses, which are in fact unlikely) and the US must run current account deficits (although not necessarily bilateral deficits, of course), and it is also purely an accounting identity that if the US runs a current account deficit, its domestic savings must be lower than its domestic investment.
>  ...
> I remember reading in the early 1990s for example a very interesting book about the US “long depression” of the 1880s and 1890s that began with the September 1873 crash in the NY Stock Exchange. The book explored the roots of the crisis in the railroad boom of the 1860s and wonderfully invoked the famous attempt by Jay Gould and James Fisk to corner the gold market in 1869. There was however almost no reference to events outside the US except in describing how the New York crisis subsequently affected British banks. It seemed that for the authors, events in the US pretty much explained everything that happened in the US economy before and after the 1873 crisis.

> It wasn’t until a few years later when I read Charles Kindleberger’s brilliant book, A Financial History of Western Europe, that I realized that the 1873 crisis was a global crisis, and that it didn’t even originate in the US. It actually began in May, 1873, with the collapse of the Vienna stock market, which spread to Berlin and London before it hit New York. I also learned that the roots of financial instability included the 1866 collapse of Overend, Gurny, a major London bank, and that stock markets around the world had soared shortly after Barings had financed the huge French war indemnity forced upon France after the 1870 Franco-Prussian War. One of Kindleberger’s great insights was that the recycling of massive payments, such as the French indemnity, often leads to liquidity-driven speculative frenzies in stock, bond and real estate markets.
>  ...
> In the 1810s Latin Americans began their wars of independence against Spain, one consequence of which was a collapse in silver production and a surge in European silver prices. When this happened England could no longer afford to exchange tea for silver, so they switched to opium, which they obtained from India at least partly in exchange for textiles, having pretty much demolished the more efficient Indian textile industry in the 18th Century. This loss of silver imports put enormous pressure on the Qing treasury and led ultimately to the sequence about which we are so familiar.
>  ...
> Brazil and Australia had booming economies during this century, for example, but how many people know the role of artificially low Chinese interest rates in creating the boom? It is not a coincidence that the boom in both countries has ended just as the amount of interest rate repression in China has almost disappeared.
> ...
> China’s extraordinarily high savings rate is almost wholly explained by the transfer mechanisms that subsidized rapid growth over the past two decades, leaving Chinese households with the lowest share of GDP in the world, and perhaps the lowest ever recorded for a large economy. Arithmetic, not to mention historical precedents, can easily explain why these transfers, which during this century amounted to as much as 5-8 percent of GDP annually, would drive down the household consumption share of GDP by driving down the household income share, and of course high savings are simply the obverse of low consumption.
> ...Policies that affect the savings rate of a small country can have more-or-less predictable domestic impacts because the closed system within which it operates, the global economy, is so large that domestic policies are not affected by external constraints. But when you are thinking about a large economy, you have to change your analysis. In a globalized world anything that changes the domestic relationship between savings and investment must automatically change the relationship between savings and investment abroad in the obverse way [...] If the savings rate of Spain (the open system) declined after 2003, as it did, the reason may have as much to do with Spain as it has to do with someone else within Europe (the relevant closed system within which it operated) – Germany, in this case – and so trying to resolve it by “undoing” the Spanish “cause” may be useless, or even reckless [...]

> [...]

> 3.) Do you think there is a global currency war going on?

> Of course there is. Historically whenever global demand is weak, and unemployment high, countries will try to gain a larger share of that demand by reducing wages or otherwise taxing households to subsidize production (devaluing the currency is just a way to tax the consumption of imports and to subsidize exporters). Unfortunately these policies reduce demand further by reducing real household income and, with it, the amount households can spend. This is why in the 1930s these policies were referred to as beggar-thy-neighbor policies. In effect they forced countries with high unemployment to respond to weak global demand with policies that reduced their own contribution to global demand while grabbing a larger share of the smaller total.

> But we must remember that they are not doing this to be pests. In most cases they have little choice. In a world with few constraints on trade or capital flows, if you try to raise domestic consumption by raising household income – for example by raising wages – your contribution to global demand will indeed rise, but your export competitiveness will decline, and so you may retain a smaller share of that greater amount.  In a globalized world, without a globally coordinated no-cheating boost in spending, beggar-they-neighbor policies may be systemically crazy but they are individually rational.

> And they are always rationalized in exactly the same way. Countries try to force down wages, devalue their currencies, and otherwise increase the short-term, competiveness of their economies only in order to protect themselves from the depredations of others. Spain wants to force down workers’ wages today because German wage growth was cut by more than one-half in the decade after the turn of the century, even though the German economy was growing faster than it had in the decade before, and the creation of the euro was supposed to make everyone richer. If Spain succeeds, global demand will drop but Spain’s share will rise.

> [...]
> This is why the political, legal, social and financial institutions that constrain the adjustment process for each country are so important. Not all growth miracles, for example, are followed by successful adjustments and more long-term growth. In fact they rarely are. In the 1960s it was widely “known” that the USSR, then completing nearly two decades of phenomenal growth, whose exploits included the first manned satellite and the first space walk, would almost certainly overtake the US both technologically and economically by the end of the century.

> Today those expectations seem almost comical. The country had wracked up so much debt during the late stages of its growth miracle, and for all its spectacular growth was unable to deliver more than a minimum amount of consumer products to it citizenry (it is considered shocking to say this in polite company, but consumption-driven economies seem to be far more innovative and productive that investment–driven economies, perhaps because of the decentralization of demand).

> [...]
> ...rapid growth is always unbalanced growth, and many years of rapid growth are nearly always derailed by debt.


================================================================================
UNQUALIFIED RESERVATIONS: The future of search
https://unqualified-reservations.blogspot.de/2010/03/future-of-search.html
tags: urbit p2p search future distributed-systems

Commodity search, if there is any such thing, is clearly the Future of Search.
But commodity search cannot be search as we know it. It cannot be the same
technical problem that today we know as "search." That is, it cannot be the
library-science problem which Google is solving. Rather, it must be a generic
utility.

Commodity or utility search must be a solution to some different problem, which
fulfills roughly the same user need as Google search. Clearly, utility search
can only be system software: a platform, not an algorithm. At least, so my
prejudices inform me!

- search is: list links relevant to a query, in order of importance.
- Importance is a product of two factors: relevance and reputation.
  - Relevance is nontrivial, but not hard.
  - Reputation is hard. At least, as the problem is presently defined.

As everyone knows, the very hard problem that Google is solving is computing
global reputation (ie, PageRank) from the graph of all HTML links on the Web.
Its algorithms are now considerably more refined than the original PageRank, of
course. But the problem is what it is.

In this problem as defined by the age of Google, just distinguishing between
actual content and spam is a difficult problem. Google is not a good producer of
reputation data. It is a competent producer of reputation data - at best. And
given the problem that Google is solving, mere competence is almost a miracle.

The Google Age ends when the Internet migrates to some new global reputation
algorithm, and users switch to it for their searches. To trigger any such
switch, the new algorithm must suck less, maybe by an order of magnitude. There
is only one way of beating Google this badly: change the problem.
...
We can't actually force people to join a community. But we can create
a general-purpose namespace of extremely consistent general quality, which will
attract high traffic from the legacy Web and thus be highly searchable, even
through Google.

================================================================================
Urbit
https://urbit.org/blog/stable-arvo/
tags: urbit p2p versioning
> "Continuity" or "permanence" is arguably Urbit's killer feature: you start
> your ship, it just works, forever.
.
> With the recent 0.9.0 release we’ve gotten to the point where we can make
> almost all our upgrades over the air. Even the language is now upgradeable
> over the wire.

================================================================================
Urbit explanation
https://news.ycombinator.com/item?id=21674120
tags: urbit p2p
> The system being a top to bottom rewrite of the stack in such a way so as to sidestep the client/server relationship entirely. A lot of services rely upon positioning themselves as the server, as the big computer you have timeshared access to, and they monetise your usage. For things like photo storage, or basic communication, or permissioned access to your files, this is pointless. Any computer could do it, but the internet is itself based upon asking a server for something and getting it. And running a server sucks.
> Any other peer to peer solution is partial, and therefore not able to compete with the internet as is. Urbit basically plans around an identity system that prevents spam and abuse; a hierarchical packet routing structure for those identities that doubles as a de facto governance model (due to having a vested interest in the network, the higher up you go); a kernel designed to freeze, and its entire OS on top a series of event logs that mark down computations and new states; a functional language for this "internet where every computer is a database", and the encrypted networking protocol that uses UDP while still ensuring packets always find you.
> So if you wanted to, say, have a group of people set as a peer list that others can subscribe to or join, or build or use applications that lets that peer list join chats or see a set of files based upon some arbitrary marker (like giving you $5/mo?) ... you don't need a million services to spread the load, one task per service, each person joining each service. You can just use your own computer. It's a personal server platform for a peer to peer internet. It's an internet designed to resist bad actors, and to resist AOL, to resist Facebook and Google

================================================================================
Urbit: functional programming from scratch
http://moronlab.blogspot.co.uk/2010/01/urbit-functional-programming-from.html
tags: urbit p2p nock functional-programming

if your goal is merely to _model_ data, you neither need nor want cyclic graphs
nor pointer identity. (Note that while nouns containing replicated subtrees can
and should be represented physically as acyclic graphs, there is no Nock
operator, like Lisp eq, which reveals pointer identity.) Nor are cyclic
structures required to specify any interesting algorithm. 

Specify your entire program in functional, Maxwellian code; if this is not fast
enough, implement key functions (called "jets") in C. Jets take noun arguments
and produce noun results. In between, they can do whatever the heck they
want--so long as they produce the same result as the actual Nock formula.

The assumption that any practical Nock interpreter will be optimized for the
specific formulas it is expected to execute, jet-propelling all well-known inner
loops, allows Nock to discard many programming-language features normally
considered essential to efficiency - from cyclic graphs, to built-in arithmetic.

================================================================================
Hoon and You - An FP Perspective
https://github.com/famousj/hoon-lc2018/blob/master/hoon-talk.md
tags: urbit p2p hoon functional-programming fp programming

================================================================================
Why Hoon? - Ted Blackman ~rovnys-ricfer
https://urbit.org/blog/why-hoon/
tags: urbit p2p hoon functional-programming fp os system
- Homoiconic. Metacircular interpreter called +mule. Run userspace code
  metacircularly ("eval"). In Lisp "eval is evil", but in Urbit eval is
  a first-class feature.
- Universally serializable. One serialization format, called "jam", for any
  piece of code/data in the system. => security, portability of VM state
- Subject-oriented. There is no implicit environment; a Hoon expression ... is
  interpreted as a function that runs with the "subject" as the argument. It
  contains everything that's in scope: usually the Hoon compiler and standard
  library, plus whatever functions/variables were defined in the lexical scope.
- Inert. There are no special objects that can't be manipulated; everything in
  your environment is just a subtree, and you could grab it and print it out if
  you wanted to. There's nothing like a "database handle", "websocket connection
  object", or other mystical constructs.
- "The way the system commands your attention is that it gives you importance in
  exchange for being a tool."

================================================================================
Ford Fusion
https://urbit.org/blog/ford-fusion/
tags: urbit p2p hoon functional-programming fp os system
"The purpose of better architecture is to create unfair comparisons."
> because the Nock layer is frozen, upgrading everything above that layer is
> easier. Upgrades are also facilitated by pure-functional semantics,
> transactional event processing, a type system oriented toward concrete data,
> and orthogonal persistence. These features make it feasible for Urbit to
> upgrade itself in the general case, not just some special cases.
>
> Ford Fusion has fixed the major upgrade issues of the past by guaranteeing three properties that in retrospect are obvious requirements, but, like much of Urbit, took many years and rewrites to identify as such:
>
> 1. Atomic: the update should complete or fail in one transaction.
> 2. Self-contained: there must be no implicit dependencies or hysteresis when building the new software from source.
> 3. Ordered: updates must be monotonically sequenced from the system's lowest layer to highest.
>
> Asynchronicity is an entropic state: a system will tend toward more
> asynchronicity over time unless effort is put into keeping it synchronous. As
> Jonathan Blow noted, LSP turns your editor into a distributed system.

================================================================================
rote: flashcard app for Urbit Landscape
https://github.com/lukechampine/rote
tags: urbit p2p hoon functional-programming fp app
- "immaculate backend code-style and documentation"
- also functions as a full "Hoon app" walkthrough
- Luke also kept a Notebook documenting his experience at ~watter-parter/hackathon.

================================================================================
A Founder's Farewell
https://urbit.org/posts/essays/a-founders-farewell/
tags: urbit p2p distributed-systems software-engineering programming compsci systems network interop
Big ideas:
1. Validation
  > 20th-century languages underrate the centrality of communication to computing.
  > Their type systems expect all data to live in a single memory forever. They
  > don't consider data serialization and validation to be core competencies of
  > a programming language.
  >
  > So serialization/validation is handled either ad hoc, or by intermediate data
  > description systems which have inherent impedance mismatches with the language
  > proper. Not only is work done over and over – but most network security
  > breaches exploit seams in custom or complex deserialization and validation
  > code.
  >
  > In Urbit there is one kind of data, a noun, which is an atom (unsigned
  > integer) or a cell (ordered pair of nouns). There is one serialization model
2. Idempotence
  > Acks are not end-to-end transactions.
  > This means you can't write a command protocol where your commands get
  > executed exactly once. You can only choose “at least once” or “at most
  > once.”
3. Dependencies
  > Linking causes a problem known as “dependency hell”.
  > Urbit build system has no trouble including multiple versions of the same library.
Avoid "premature explanation".
  > Urbit's internal opacity persists for two reasons, one good and one bad. The
  > bad reason is just laziness. The good reason is justified fear of premature
  > explanation, which like premature optimization ruins the annealing process.
  >
  > When you don't know exactly what you're doing, preserve as much ambiguity as
  > possible.


================================================================================
urbit features
https://news.ycombinator.com/item?id=15300676
tags: urbit p2p distributed-systems systems network
- All events are transactions, down to the VM level. There's no concept of an event that left garbage around because power was cut or the machine was rebooted. You can always crash an event, making it as if it never happened.
- Single-level store. Never worry about ORM because your in-memory state never goes away (because all events are transactions).
- Persistent connections with exactly-once messaging. Disconnection is just seen as long latency.
- Strict, purely functional language with a strong type system but no Hindley-Milner (so you don't need category theory).
- Sane indentation for a functional language, known as "backstep".
- The file system is a typed revision control system, which allows intelligent diffs on types other than plain text.


================================================================================
PGP and You 
href="http://robots.thoughtbot.com/pgp-and-you" 
tags: gpg todo tutorial reference
  time="2014-11-04T22:28:46Z" 

================================================================================
Neural Networks, Manifolds, and Topology -- colah's blog
href="http://colah.github.io/posts/2014-03-NN-Manifolds-Topology/"
tags: machine-learning todo
  time="2014-10-14T22:17:27Z" 

================================================================================
Visualizing Algorithms 
href="http://bost.ocks.org/mike/algorithms/" 
tags: todo algorithms compsci
  time="2014-10-14T22:16:53Z" 

================================================================================
Hyperpolyglot
  similar to learnxinyminutes.com
href="http://hyperpolyglot.org/"  
tags: programming reference
time="2014-10-13T22:53:20Z" 

================================================================================
Markov Chains visualization
  The most important conceptual point regarding Markov chains is that they are memory-less: future states depend only on the current state and not a previous history of which states have been visited. This property makes them powerful and simple to analyze. ... But the movement of a person trying to exit a museum is not well modeled by a Markov chain because he will remember which hallways lead to dead ends and be less likely to travel down them again.
href="http://setosa.io/blog/2014/07/26/markov-chains/index.html"
tags: machine-learning statistics
  time="2014-09-10T21:45:15Z" 

================================================================================
The Little Book of Semaphores [pdf]
http://www.greenteapress.com/semaphores/downey08semaphores.pdf
https://news.ycombinator.com/item?id=11277896
tags: todo distributed-systems programming

================================================================================
Readings in Databases
  The Five-Minute Rule Ten Years Later / http://www.cs.berkeley.edu/~rxin/db-papers/5-min-rule.pdf /Paxos Made Simple / http://www.cs.berkeley.edu/~rxin/db-papers/Paxos.pdf / http://www.cs.berkeley.edu/~rxin/db-papers/OCC-Optimistic-Concurrency-Control.pdf / On Optimistic Methods for Concurrency Control / http://www.cs.berkeley.edu/~rxin/db-papers/CAP.pdf / Eric Brewer's writeup on CAP in retrospective, explaining &quot;'2 of 3' formulation was always misleading because it tended to oversimplify the tensions among properties.
  href="http://rxin.github.io/db-readings/" 
  
tags: todo distributed-systems programming database cap concurrency
  time="2014-08-29T02:21:56Z" 

================================================================================
Project Zero: The poisoned NUL byte, 2014 edition
  An odd malloc() size will always result in an off-by-one off the end being harmless, due to malloc() minimum alignment being sizeof(void*). / Memory leaks in setuid binaries are surprisingly dangerous because they can provide a heap spray primitive. / / http://seclists.org/bugtraq/1998/Oct/109 / With the stack having shifted down 0xec bytes, it picks up the return address from the local buffer containing the exploit code.
href="http://googleprojectzero.blogspot.com/2014/08/the-poisoned-nul-byte-2014-edition.html"
tags: security programming infosec c
  time="2014-08-27T22:24:33Z" 

================================================================================
Thousand-robot swarm self-assembles into arbitrary shapes | Robohub
  decentralised, scalable, self-organizing autonomous robots. / No GPS-like system was available for them to know their location in the environment. Instead, robots had to form a virtual coordinate system using communication with, and measured distances to, neighbours. / Four specially programmed seed robots are then added to the edge of the group, marking the position and orientation of the shape. These seed robots emit a message that propagates to each robot in the blob and allows them to know how ‚Äúfar‚Äù away from the seed they are and their relative coordinates. Robots on the edge of the blob then follow the edge until they reach the desired location in the shape that is growing in successive layers from the seed. / [paper: justin.werfel@wyss.harvard.edu http://www.sciencemag.org/content/343/6172/754 ] https://news.ycombinator.com/item?id=8178978
href="http://robohub.org/thousand-robot-swarm-self-assembles-into-arbitrary-shapes/"
tags: cellular-automata
  time="2014-08-14T19:52:45Z" 

================================================================================
Twenty Questions for Donald Knuth
  The supposedly &quot;most efficient&quot; algorithms [...] are too complicated to be trustworthy, even if I had a year to implement one of them. / The present state of research in algorithm design misunderstands the true nature of efficiency. / Although I was expecting your method to be the winner, because it examines much of the data only half as often as the others, it actually came out two to three times worse than Kruskal's venerable method. Part of the reason was poor cache interaction, but the main cause was a large constant factor hidden by O notation.
href="http://www.informit.com/articles/article.aspx?p=2213858"
tags: compsci knuth
  time="2014-07-18T19:30:37Z" 

================================================================================
The Operating System: Should there be one? Stephen Kell
https://www.cl.cam.ac.uk/~srk31/research/papers/kell13operating.pdf
tags: smalltalk plan9 compsci os c programming

powershell cf. Smalltalk "grand narrative": "Smalltalk itself has no
solution for fragmention", except "don't fragment; use Smalltalk for
everything!"

Sockets are an unnecessary concept:
    "[Plan 9's] expanded use of files and servers allowed several
    simplifications relative to the Unix syscall interface. For example,
    gone are `ioctl()` and other device manipulations process operations
    such as `setuid()` or `nice()` and the host of Berkeley sockets calls
    (which added yet another naming and binding mechanism to Unix).
    Replacing them are a generalised binding mechanism—essentially `bind()`
    by the server and `open()` by the client—and simple reads and writes to
    files."


================================================================================
"Less is exponentially more", Rob Pike
http://lambda-the-ultimate.org/node/4554
https://commandcenter.blogspot.com/2012/06/less-is-exponentially-more.html
> Alain Fournier once told me that he considered the lowest form of academic
> work to be taxonomy.
.
> OO is great for problems where an interface applies naturally to a wide range
> of types, not so good for managing polymorphism (the machinations to get
> collections into OO languages are astounding to watch and can be hellish to
> work with), and remarkably ill-suited for network computing. That's why
> I reserve the right to match the language to the problem, and even--often--to
> coordinate software written in several languages towards solving a single
> problem.
>
> It's that last point--different languages for different subproblems--that
> sometimes seems lost to the OO crowd. In a typical working day I probably use
> a half dozen languages--C, C++, Java, Python, Awk, Shell--and many more
> little languages you don't usually even think of as languages--regular
> expressions, Makefiles, shell wildcards, arithmetic, logic, statistics,
> calculus--the list goes on.
.
Rob Pike 2004:
> This is not the first time databases and file systems have collided, merged,
> argued, and split up, and it won't be the last. The specifics of whether you
> have a file system or a database is a rather dull semantic dispute, a contest
> to see who's got the best technology, rigged in a way that neither side wins.
> Well, as with most technologies, the solution depends on the problem; there is
> no single right answer.
>
> What's really interesting is how you think about accessing your data. File
> systems and databases provide different ways of organizing data to help find
> structure and meaning in what you've stored, but they're not the only
> approaches possible. Moreover, the structure they provide is really for one
> purpose: to simplify accessing it. Once you realize it's the access, not the
> structure, that matters, the whole debate changes character.
>
> One of the big insights in the last few years, through work by the internet
> search engines but also tools like Udi Manber's glimpse, is that data with no
> meaningful structure can still be very powerful if the tools to help you
> search the data are good. In fact, structure can be bad if the structure you
> have doesn't fit the problem you're trying to solve today, regardless of how
> well it fit the problem you were solving yesterday. So I don't much care any
> more how my data is stored; what matters is how to retrieve the relevant
> pieces when I need them.
>
> Grep was the definitive Unix tool early on; now we have tools that could be
> characterized as `grep my machine' and `grep the Internet'. GMail, Google's
> mail product, takes that idea and applies it to mail: don't bother organizing
> your mail messages; just put them away for searching later. It's quite
> liberating if you can let go your old file-and-folder-oriented mentality.
> Expect more liberation as searching replaces structure as the way to handle
> data.


================================================================================
Hello World: USENIX Winter 1993 paper by Rob Pike and Ken Thompson on UTF-8 under Plan 9
  Unicode defines an adequate character set but an unreasonable representation. / UTF-1 advantages: It is a byte encoding and is therefore byte-order independent. ASCII control characters appear in the byte stream only as themselves, never as an element of a sequence encoding another character, so newline bytes separate lines of UTF text. / UTF-1 major disadvantage: not self-synchronizing =&gt; cannot find the character boundaries in a UTF string without reading from the beginning. / &quot;The actual encoding is relatively unimportant to the software; the adoption of large characters and a byte-stream encoding per se are much deeper issues.&quot;
  href="http://www.cl.cam.ac.uk/~mgk25/ucs/UTF-8-Plan9-paper.pdf"
   
tags: unicode plan9 compsci strings os c programming
  time="2014-07-15T22:23:52Z" 

================================================================================
What Every Programmer Absolutely, Positively Needs to Know About Encodings and Character Sets to Work With Text
  Unicode is not an encoding. Unicode defines a table of code points for characters. The character ·∏Ä has the Unicode code point U+1E00. UTF-32 is an encoding that encodes all Unicode code points using 32 bits: 4 bytes per character. UTF-16 and UTF-8 are variable-length encodings. &quot;Unicode support&quot; in a programming language or OS is not necessary as long as the runtime treats a string input as a bit stream and does not attempt to manipulate it as a specific encoding. You only need to be careful when _manipulating_ strings (slicing, trimming, counting), i.e. operations that happen on a _character_ level rather than a _byte_ level.
href="http://kunststube.net/encoding/"  
tags: unicode programming strings
time="2014-07-15T00:29:26Z" 

================================================================================
How SQL Server Generates the Query Plan
  SQL Server not any perform flow analysis, so local variables in a sproc can kill the query plan. / SET ARITHABORT ON doesn't really fix performance issues, it just appears to temporarily because it is a cache key, and setting it changes the query so that a new query plan is generated. So the next execution will appear fast because it is optimized, but then later executions (using _different_ parameters) will be slow again, because they are using the query plan that was cached for the previous parameter values. The _real_ problem is related to parameter sniffing.
href="http://www.sommarskog.se/query-plan-mysteries.html#plangenerate"
tags: sqlserver sql database rdbms
  time="2014-07-01T15:30:09Z" 

================================================================================
Out of Prohibition's Reach: How Technology Cures Toxic Policy
  The shutdown also motivated improvements as new marketplaces started offering features like faster services, private messaging that requires encryption, and bitcoin escrow services that eliminate the possibility of the marketplace scamming users. / In terms of scam prevention, most marketplaces actively work to make scamming unattractive. Anyone that wants to sell as a vendor is required to post a bond until they reach a certain amount of sales and positive reviews. / Decentralized marketplaces like the experimental ‚ÄúDarkMarket‚Äù platform, recently renamed ‚ÄúOpenBazaar‚Äù, are the next step towards the cure. DarkMarket is peer-to-peer which means that every user serves up their own buyer or seller page, as opposed to that page being served up by a server like on traditional websites or current anonymous marketplaces.
  href="http://stanfordreview.org/article/out-of-prohibitions-reach-how-technology-cures-toxic-policy/"
   
tags: libertarianism free-market economics
  time="2014-06-07T19:16:44Z" 

================================================================================
What happens when patients find out how good their doctors are? (2004)
https://news.ycombinator.com/item?id=15840525
tags: science medicine health data measurement metrics quantification
> As a physician, I often think about how we lack truely objective assessment of
> patient outcomes (either in the context of evaluating physician competence or,
> probably more importantly, assessing and improving upon clinical practises).
>
> There are several issues which are particularly vexing:
>
> - The distinct lack of verifiable, objective markers of physician competence.
>
> - Each patient's case is unique and cases with the highest levels of
>   difficulty are often treated by the most experienced people. These cases, of
>   course, are likely to have worse outcomes than simple cases which may be
>   treated by less experienced (worse?) physicians.
>
> - Clinical outcomes are largely recorded by the same people treating the
>   patient so reported outcomes are often erroneous or frankly fraudulent.
>
> - This is made worse by the hierarchical nature of clinical medicine and
>   deference to seniority and title.
>
> - Medicine is parochial so clinical practises for the same disorder vary
>   tremendously. You might be treated a dozen different ways for the same
>   disorder and presentation depending on the facility and especially on the
>   specialty that ends up treating you.
>
> - Outcomes are not necessarily determined by clinician ability. There are
>   several other factors at play: the pre- and post-care (such as work-up by
>   ancillary staff or ICU care after a surgery), the cohesiveness of the
>   facility and its efficiencies (or lack thereof), availability and
>   preferences for resources such as medical devices, drugs and hospital
>   equipment which may be largely out of the hands of the physician.

================================================================================
cancer
  Cancer is a disease that combines the trickiest parts of aging with the trickiest parts of infectious disease. Cell replication ... several trillions of times per day ... essentially copying 1 billion TB of data while detecting and fixing every error. Everybody will get cancer ... then you have a cell that your immune system has carefully trained for decades not to engage, invading and hogging every resource it can, with mutations that allow it to adapt to selective pressures, including drugs. Essentially, it's an infectious parasite, except it looks 99% like your own cells to your immune system, and is already perfectly suited to your metabolism. / From an evolutionary standpoint, no species would ever naturally develop perfect DNA replication because it would halt diversification. / [Imagine a billion nanobots...] You've basically described the immune system! Trillions of cells, thousands of genes controlling each one, hypermutations creating billions of different antibodies.
href="https://news.ycombinator.com/item?id=7787688" 
tags: cancer science medicine nanotech health
  time="2014-06-07T18:36:52Z" 

================================================================================
Uncleftish Beholding
https://en.wikipedia.org/wiki/Uncleftish_Beholding
tags: concepts mental-model language
written using almost exclusively words of Germanic origin
The title Uncleftish beholding calques "atomic theory".
Around, from Old French reond (Modern French rond), has completely displaced Old English ymbe (cognate to German um), leaving no native English word for this concept.

================================================================================
Noisy-channel coding theorem
https://en.wikipedia.org/wiki/Noisy-channel_coding_theorem
tags: concepts mental-model compsci information-theory encoding
Noisy-channel coding theorem: For any given degree of noise in a communication channel, it is possible to communicate discrete data (digital information) nearly error-free up to a computable maximum rate.
Shannon limit = maximum information-transfer rate of the channel, for a particular noise level.

================================================================================
Mutatis mutandis
https://en.m.wikipedia.org/wiki/Mutatis_mutandis
tags: concepts mental-model
Medieval Latin phrase meaning "the necessary changes having been made".
    1. collect underpants
    2. mutatis mutandis
    3. profit

================================================================================
System dynamics
https://en.wikipedia.org/wiki/System_dynamics
https://www.anylogic.com/
tags: concepts model systems system-design stock-and-flow mental-model
System dynamics (SD) is an approach to understanding the nonlinear behaviour of complex systems over time using stocks, flows, internal feedback loops, table functions and time delays.
- Teach "system-thinking" reflexes
- Analyze/compare assumptions and mental models
- Gain qualitative insight into the workings of a system or the consequences of a decision
- Recognize archetypes of dysfunctional systems in everyday practice

================================================================================
Pythagorean Cup (Greedy Cup)
  &quot;Hydrostatic pressure creates a siphon through the central column, causing the entire contents of the cup to be emptied through the hole at the bottom of the stem.&quot;
href="http://en.wikipedia.org/wiki/Pythagorean_cup" 
tags: concepts economics physics mental-model
  time="2014-06-02T03:58:58Z" 

================================================================================
Gauss's Principle of Least Constraint
http://preetum.nakkiran.org/misc/gauss/
tags: concepts physics mental-model
.
> Gauss noticed that, roughly, the CONSTRAINED motion of masses is as close as
> possible to their UNCONSTRAINED motions, while still satisfying the
> constraints. For example, a pendulum bob would naturally fall straight down,
> but is constrained to a circle by its string -- so its true acceleration will
> be as close as possible to straight down, while still remaining on the string.
> This generalizes to essentially any constrained system. Specifically, to find
> the true accelerations of masses in a constrained system, we first find the
> accelerations as if they were unconstrained, and then PROJECT to the closest
> acceleration that satisfies the constraints.

================================================================================
"Bitcoin's Academic Pedigree" Narayanan & Clark
http://queue.acm.org/detail.cfm?id=3136559
tags: bitcoin blockchain trust-network p2p cryptocurrency
https://news.ycombinator.com/item?id=15135442
    "original Bitcoin codebase ... It's brilliant code. ... One of the earliest commits in the SVN repo contains 36 thousand lines of code. "Satoshi" (or this group of people) must have worked months or a year on this before putting it up on source control. The code also uses irc to find seed nodes, which is amusing. It just connects to #bitcoin and assumes that some of the people in the channel are running bitcoin nodes. That's a cool way around the "What if all the hardcoded seed nodes fail?" problem. I know it's probably a standard tactic, but bitcoin integrates so many standard tactics so well in addition to its academic work.
    "It's worth repeating: This is a C++ codebase. It listens to open ports on the public Internet. One single remote exploit and you lose all your money. The author basically threw code over the wall and the open source community where contributors come and go all the time took over. And one single remote exploit is all it takes. (This causation is perhaps less true today when it is more common to use encrypted or even hardware wallets, but before that everyone just used the standard wallet.) Yet none of this has happened. The odds of this seems vanishingly unlikely. Then there's the risk of consensus problems that would enable double spending, which is very difficult to test for. At the same time original Bitcoin was far from perfect. Someone wrote up a summary of important changes Hal Finney did which I can't seem to find. He pointed out a lot of problems which would have made Bitcoin not work at all which resulted in some early redesigns and the removal of many opcodes. Parts of Bitcoin also went nowhere, notably the marketplace, pay-to-IP and payment channels. The ideas live on as Openbazaar and Lightning but completely redesigned from the Satoshi origins. In so many ways it is an enigma."

================================================================================
Minimum Viable Block Chain - igvita.com
  https://news.ycombinator.com/item?id=7699332
  href="http://www.igvita.com/2014/05/05/minimum-viable-block-chain/"
   
tags: bitcoin blockchain trust-network p2p cryptocurrency todo
  time="2014-05-05T17:15:08Z" 

================================================================================
Call for a Temporary Moratorium on “The DAO”
  https://news.ycombinator.com/item?id=11788283
  https://docs.google.com/document/d/10kTyCmGPhvZy94F7VWyS-dQ4lsBacR2dUgGTtV98C40/mobilebasic
   
tags: todo bitcoin cryptocurrency blockchain trust-network p2p DAO distributed-autonomous-organization

================================================================================
NSA Spying Documents to be Released As Result of EFF Lawsuit
  href="https://www.eff.org/deeplinks/2013/09/hundreds-pages-nsa-spying-documents-be-released-result-eff-lawsuit"
   
tags: nsa police-state surveillance paranoia
  time="2014-03-13T00:12:50Z" 

================================================================================
How the NSA Plans to Infect 'Millions' of Computers with Malware - The Intercept
  https://news.ycombinator.com/item?id=7385390
  href="https://firstlook.org/theintercept/article/2014/03/12/nsa-plans-infect-millions-computers-malware/"
   
tags: nsa police-state surveillance paranoia government infosec todo
  time="2014-03-12T23:43:48Z" 

================================================================================
Build GIT - Learn GIT (P1) - Kushagra Gour- Creativity freak!
href="http://kushagragour.in/blog/2014/01/build-git-learn-git/"
tags: git tutorial todo programming
  time="2014-01-20T17:41:13Z" 

================================================================================
Eclipse Java REPL / albertlatacz/java-repl ¬∑ GitHub
  FINALLY!!!!!!
href="https://github.com/albertlatacz/java-repl" 
tags: repl java eclipse
  time="2013-12-09T18:43:22Z" 

================================================================================
Path dependence 
href="http://en.wikipedia.org/wiki/Path_dependence" 
tags: concepts economics compsci dynamics mental-model
  time="2013-11-26T17:57:56Z" 

================================================================================
Advanced R programming 
href="http://adv-r.had.co.nz/"  
tags: r-lang programming statistics
  time="2013-11-17T18:45:14Z" 

================================================================================
Kubernetes: The Surprisingly Affordable Platform for Personal Projects
https://www.doxsey.net/blog/kubernetes--the-surprisingly-affordable-platform-for-personal-projects
tags: kubernetes cloud orchestration sre paas dcos gce gcr google programming devops container virtualization sysadmin deployment

================================================================================
Evaluating Bazel for building Firefox
https://news.ycombinator.com/item?id=21389206
tags: bazel build google programming devops dependencies
Hermetic declarative build system
- query the dependency graph
- track all accesses to files
- example: compiling a few C++ files into a binary is just:
    cc_binary(
      name = "app",
      srcs = glob([ "*.hpp", "*.cpp" ]),
    )
xxx:
> it is pretty simple to poison the cache.
> Bazel does not really hash any of the system stuff -- like system headers, and system-provided .a and .so files
>> On any large team your compiler should be checked into revision control or have a way to fetch a specific artifact & have that pointer checked in

================================================================================
Docker examples
https://github.com/jessfraz/dockerfiles/blob/master/irssi/Dockerfile
tags: docker programming devops container virtualization linux

================================================================================
xperf Profiler 
  href="http://randomascii.wordpress.com/category/xperf/"
   
tags: programming performance profiling windows
  time="2013-11-08T22:33:39Z" 

================================================================================
PyParallel: How we removed the GIL and exploited all cores
  https://speakerdeck.com/trent/pyparallel-how-we-removed-the-gil-and-exploited-all-cores
  https://news.ycombinator.com/item?id=11866562
tags: programming performance iocp io-completion-ports syscall windows

================================================================================
I can't believe I'm praising Tcl
href="http://www.yosefk.com/blog/i-cant-believe-im-praising-tcl.html"
tags: programming tcl
  time="2013-11-06T02:56:04Z" 

================================================================================
The Trouble With Types 
  href="http://www.infoq.com/presentations/data-types-issues"
   
tags: type-systems functional-programming scala video martin-odersky
  time="2013-11-05T22:11:11Z" 

================================================================================
Maybe Not - Rich Hickey
https://www.youtube.com/watch?v=YR5WdGrpoug
tags: type-systems functional-programming video rich-hickey concepts distributed-systems

https://news.ycombinator.com/item?id=18565555
    > RDF got this surprisingly right. ... The idea of collections of
    > subject-predicate-object statements forming an isomorphism with graphs, and
    > sets of these statements form concrete "aggregates" plays extremely well with
    > the idea of unification through search.

Alfred North Whitehead: "reality as process-flows":
    https://en.wikipedia.org/wiki/Alfred_North_Whitehead#Whitehead's_conception_of_reality
Rich Hickey talk (2009) guided by Whitehead quotes:
    https://www.infoq.com/presentations/Are-We-There-Yet-Rich-Hickey


================================================================================
NSA infiltrates links to Yahoo, Google data centers worldwide, Snowden documents say
  National Security Agency secretly broke into the main communications links that connect Yahoo and Google data centers. ... the agency has positioned itself to collect at will from hundreds of millions of user accounts, many of them belonging to Americans ... project called MUSCULAR ... the NSA and the GCHQ are copying entire data flows across fiber-optic cables ... unusually aggressive use of NSA tradecraft against flagship American companies ... NSA documents about the effort refer directly to ‚Äúfull take,‚Äù ‚Äúbulk access‚Äù and ‚Äúhigh volume‚Äù ... Such large-scale collection of Internet content would be illegal in the United States, but the operations take place overseas. http://www.politico.com/story/2013/10/keith-alexander-nsa-report-google-yahoo-99103.html Gen. Keith Alexander, asked about it at a Bloomberg event, denied the accusations. &quot;I don't know what the report is,&quot; Alexander cautioned, adding the NSA does not &quot;have access to Google servers, Yahoo servers.&quot;
  href="http://www.washingtonpost.com/world/national-security/nsa-infiltrates-links-to-yahoo-google-data-centers-worldwide-snowden-documents-say/2013/10/30/e51d661e-4166-11e3-8b74-d89d714ca4dd_story.html"
   
tags: police-state paranoia nsa surveillance privacy
  time="2013-10-30T22:32:15Z" 

================================================================================
document.createDocumentFragment
  Since the document fragment is in memory and not part of the main DOM tree, appending children to it does not cause page reflow (computation of element's position and geometry).
  href="https://developer.mozilla.org/en-US/docs/Web/API/document.createDocumentFragment"
   
tags: webdesign javascript programming performance
  time="2013-10-15T19:18:16Z" 

================================================================================
ipinfo.io:
https://ipinfo.io/
IP address lookup, geolocation, API
ASN (Autonomous System Number) lookup, e.g.: https://ipinfo.io/AS32934

tags: tools web ip api internet
2016-08-09 00:04:38

================================================================================
OpenRefine / fka Google Refine
  a tool for working with messy data, cleaning it up, transforming it from one format into another, extending it with web services, and linking it to databases like Freebase.
href="https://github.com/OpenRefine"  
tags: tools google data-mining statistics
  time="2013-10-01T21:33:52Z" 

================================================================================
Herding Code 
href="http://herdingcode.com/"  
tags: podcast
time="2013-09-30T14:27:35Z" 

================================================================================
Software Engineering Radio | The Podcast for Professional Software Developers
href="http://www.se-radio.net/"  
tags: softwareengineering podcast
time="2013-09-30T14:27:13Z" 

================================================================================
The Pragmatic Bookshelf | Podcasts
href="http://pragprog.com/podcasts"  
tags: podcast
time="2013-09-30T14:26:44Z" 

================================================================================
FLOSS Weekly | TWiT.TV 
href="http://twit.tv/show/floss-weekly"  
tags: podcast
time="2013-09-30T14:26:16Z" 

================================================================================
On The Brink with Castle Island, Matt Walsh and Nic Carter
https://castleisland.libsyn.com/urbit-christian-lingales-and-logan-allen-ep17
tags: podcast bitcoin urbit decentralization


================================================================================
Beyond Corp: The Access Proxy
https://research.google.com/pubs/pub45728.html
https://news.ycombinator.com/item?id=16204208
tags: security networks beyondcorp it sysadmin devops

> - Instead of a single VPN that will expose your entire squishy corporate LAN to anyone who gets VPN access, each application gets its own protected proxy.
> - The protected proxies query a centrally-aggregated auth/authz database, which can work with client-side software to ensure qualities such as private key possession, full disk encryption, software updates, etc. In Google's case, this is combined with a host-rewriting browser extension for usability.
> - Access proxies can easily funnel HTTP traffic, but some more clever solutions involving tunnels exist for plain old TCP and UDP.
>
> By giving every application its own authentication and access control proxy, each application is secured on its own, hence "zero-trust."

================================================================================
BeyondCorp: The User Experience
https://research.google.com/pubs/pub46366.html
tags: security networks beyondcorp it sysadmin devops


================================================================================
YubiKey via USB PCSC protocol
https://news.ycombinator.com/item?id=19567338
tags: security networks yubikey 2fa tfa
application for YubiKeys - using the YKOATH functionality to sign AWS API
requests with HMAC-SHA256 (https://github.com/pyauth/exile). Yubikey's protocol
documentation is good, but their tools are pretty bad, and none of them should
be used. Instead, talk to the smartcard interface through the lowest level
library that's already bundled with the major OSs:
winscard/pcsclite/PCSC.framework (three implementations of the same API).
The app I wrote includes Python ctypes bindings for all three implementations:
https://github.com/pyauth/exile/tree/master/exile/scard
Example of how to use them:
https://github.com/pyauth/exile/blob/master/exile/ykoath


================================================================================
pyu2f (USB HID protocol)
https://github.com/google/pyu2f
tags: security networks yubikey 2fa tfa
python based U2F host library for interacting with a U2F device over USB.


================================================================================
Site to Site WireGuard: Part 1
https://christine.website/blog/site-to-site-wireguard-part-1-2019-04-02
https://lobste.rs/s/pje6iw/site_site_wireguard_part_1
tags: vpn wireguard security networks 
.
- VPN over a single UDP port.
- Custom TLS Certificate Authority: create TLS certificates for any domain.
- Expose TCP/UDP services to machines across network segments


================================================================================
UDP-based Data Transfer Protocol
https://en.wikipedia.org/wiki/UDP-based_Data_Transfer_Protocol
tags: networks tcp udp data-transfer
High-performance data transfer protocol designed for transferring large
volumetric datasets over wide area networks.


================================================================================
TCP is an underspecified two-node consensus algorithm and what that means for your proxies
https://morsmachine.dk/tcp-consensus
tags: networks proxy tcp tcp-ip protocol
.
> Cannot rely on a proxy to pass through the behavior (including keepalive!) of
> the TCP connection. Workaround: application-level ping.
.
> example of the end-to-end principle in action:
> On the IP layer, datagrams can be split into multiple parts for when the
> underlying physical transport cannot support a packet of a given size. The idea
> was that IP datagrams would be split and then recombined by the routers in the
> middle of the network when the physical layer would support a packet of that
> size again. This turned out to be disastrous in practice. Hosts would often get
> partial datagrams that would never be able to recombine and they would also have
> no way to tell the host on the other end that a packet was lost (the packet
> acknowledgement is in the TCP layer).


================================================================================
IP Listen List
  Problems arise when third party applications (not using the HTTP Server APIs) bind to IP address and port 80 pairs on the machine. The HTTP Server API provides a way to configure the list of IP addresses that it binds and solves this coexistence issue. also: http://toastergremlin.com/?p=320
  href="http://msdn.microsoft.com/en-us/library/windows/desktop/aa364669(v=vs.85).aspx"
   
tags: networks iis it http windows tcpip sysadmin
  time="2013-09-05T20:45:27Z" 

================================================================================
Do You Really Know CORS?
http://performantcode.com/web/do-you-really-know-cors
tags: http web cors security interop
CORS edge cases:
- either an unreleased safari version, or the most recent version will send preflight requests even if the request meets the spec (like if the Accept-Language is set to something they don't like).
- If you use the ReadableStream API with fetch in the browser, a preflight will be sent.
- If there are any events attached on the XMLHttpRequestUpload.upload listener, it will cause a preflight
- cross-domain @font-face urls, images drawn to a canvas using the drawImage stuff, and some webGL things will also obey CORS
- the crossorigin attribute will be required for cross-origin linked images or css, or the response will be opaque and js won't have access to anything about it.
- if you mess up CORS stuff, you get opaque responses, and opaque responses are "viral", so they can cause entire canvas elements to become "blacklisted" and extremely restricted.

================================================================================
Documenting your architecture: Wireshark, PlantUML and a REPL to glue them all
https://news.ycombinator.com/item?id=15325649
http://danlebrero.com/2017/04/06/documenting-your-architecture-wireshark-plantuml-and-a-repl/
tags: networks sysadmin devops


================================================================================
Linux Raw Sockets
http://schoenitzer.de/blog/2018/Linux%20Raw%20Sockets.html<Paste>
tags: networks programming linux sockets
traditional socket: UDP based datagram socket via IPv4
    sockfd = socket(AF_INET, SOCK_DGRAM, 0);
still only receive the type of packet specified (here UDP), but this time you will not only receive the data but also the layer 4 (TCP/UDP) header and you're also responsible to set the layer 4 header yourself.
    sockfd = socket(AF_INET, SOCK_RAW, IPPROTO_UDP);
    sockfd = socket(AF_INET6, SOCK_RAW, IPPROTO_UDP);
> AF_INET and AF_INET6 for raw sockets is the endianness: unlike IPv4 raw sockets, all data sent via IPv6 raw sockets must be in the network byte order and all data received via raw sockets will be in the network byte order.
packet socket: raw IPv6 packets at the device driver level (layer 2):
    sockfd = socket(AF_PACKET, SOCK_DGRAM, htons(ETHERTYPE_IPV6));
raw packets (ALL) at the device driver level (layer 2):
    sockfd = socket(AF_PACKET, SOCK_DGRAM, htons(ETH_P_ALL));
ethernet frames:
    sockfd = socket(AF_PACKET, SOCK_RAW, htons(ETH_P_ALL));


================================================================================
favicon cheat sheet
  https://news.ycombinator.com/item?id=6315664
href="https://github.com/audreyr/favicon-cheat-sheet"
tags: webdev favicon
  time="2013-09-02T17:52:34Z" 

================================================================================
The Changelog Podcast 
href="http://thechangelog.com/podcast/"  
tags: podcast
time="2013-08-27T20:06:09Z" 

================================================================================
In situ
href="http://en.wikipedia.org/wiki/In_situ" 
tags: pedantry latin concepts mental-model
  time="2013-07-29T06:47:43Z" 

================================================================================
IPython Notebook
  "live" backpack-like document containing text, graphs, images, etc, resulting from python expressions.
href="http://ipython.org/notebook.html"  
tags: python programming repl
time="2013-07-28T23:30:49Z" 

================================================================================
git-annex
  cf. https://github.com/bup/bup
href="https://git-annex.branchable.com/videos/" 
tags: git backup
time="2013-07-20T05:19:30Z" 

================================================================================
go-wiki - Go Language Unofficial Community Wiki - Google Project Hosting
href="https://code.google.com/p/go-wiki/" 
tags: golang programming documentation
  time="2013-07-17T04:27:09Z" 

================================================================================
description=""
  Mapp and White spent two years trying to prove McCormick knew his products didn‚Äôt work. They made inquiries in more than 20 countries and went to Belgium, France, Georgia, Lebanon, and Bahrain. They discovered he had sold more than 7,000 devices to agencies including the Hong Kong police, the Romanian airport authorities, the United Nations, and the M&amp;ouml;venpick hotel group. Most had been sold to Iraq, where an Interior Ministry investigation would eventually show that corruption on a titanic scale had made the ATSC contracts possible. In a 2011 Report to Congress, the Special Inspector General for Iraqi Reconstruction estimated that 75 percent of the value of McCormick‚Äôs sales had been spent on bribes.
href="http://www.businessweek.com/articles/2013-07-11/in-iraq-the-bomb-detecting-device-that-didnt-work-except-to-make-money"
tags: government-failure corruption dod
  time="2013-07-15T00:58:21Z" 

================================================================================
‚ÄúWhy did you shoot me? I was reading a book‚Äù: The new warrior cop is out of control
  Excerpted from &amp;quot;Rise of the Warrior Cop: The Militarization of America's Police Forces&amp;quot; / Several months earlier at a local bar, Fairfax County, Virginia, detective David Baucum overheard the thirty-eight-year-old optometrist and some friends wagering on a college football game. ... After overhearing the men wagering, Baucum befriended Culosi as a cover to begin investigating him. ... Eventually Culosi and Baucum bet more than $2,000 in a single day. ... they brought in the SWAT team.
  href="http://www.salon.com/2013/07/07/%E2%80%9Cwhy_did_you_shoot_me_i_was_reading_a_book_the_new_warrior_cop_is_out_of_control/"
   
tags: politics police-state habeas-corpus
  time="2013-07-08T04:06:17Z" 

================================================================================
RockStarProgrammer - The Differences Between Mercurial and Git
  git is more granular than mercurial =&gt; very beneficial in creating new types of workflows mercurial: heads/branches are inferred by lack of children git: branches are &quot;namespaced&quot; per remote. All heads are explicit. A tag or a branch points to a particular node in the graph, and there are tools to compare the changes between two nodes; allows private branches. mercurial: history is immutable / changing history is discouraged git: mutability is normal part of workflow mercurial, the branch name is stored in the changeset. Easy to have duplicate/conflicting branch names. the branch name is in the changeset, so the branch lives forever =&gt; discourages throw-away branches / experimentation. In git, a branch is just a head. Changing a branch actually moves the pointer to the new changeset (hash/commit). This head must be _explicitly_ shared across repositories. - won't accidentally push code you don't mean to. - no fear of name collisions. / hg cannot shallow clone.
href="http://www.rockstarprogrammer.org/post/2008/apr/06/differences-between-mercurial-and-git/"
tags: programming mercurial dvcs git
  time="2013-07-07T23:01:58Z" 

================================================================================
Brendan Eich 
href="http://brendaneich.com/"  
tags: blog
time="2013-06-26T05:17:23Z" 

================================================================================
Eric Lippert‚Äôs Blog 
href="http://blogs.msdn.com/b/ericlippert/" 
tags: blog
time="2013-06-26T05:16:13Z" 

================================================================================
The Old New Thing 
href="http://blogs.msdn.com/b/oldnewthing/atom.aspx" 
tags: rss blog
time="2013-06-26T04:25:26Z" 

================================================================================
TED talks 
href="http://feeds.feedburner.com/tedtalks_audio" 
tags: podcast
time="2013-06-26T04:20:22Z" 

================================================================================
The R-Podcast 
href="http://r-podcast.org/feed/ogg/"  
tags: podcast
time="2013-06-26T04:19:31Z" 

================================================================================
reason.tv podcast 
href="http://reason.com/podcast/index.xml" 
tags: podcast
time="2013-06-26T04:09:56Z" 

================================================================================
NPR: Planet Money Podcast 
href="http://www.npr.org/rss/podcast.php?id=510289" 
tags: podcast
time="2013-06-26T04:08:54Z" 

================================================================================
“DIAGNOSTIC WITH CODE FIX” USING ROSLYN API
tag=roslyn .net-compiler-platform programming visual-studio

================================================================================
hanselminutes 
href="http://feeds.feedburner.com/Hanselminutes" 
tags: podcast
time="2013-06-26T04:03:51Z" 

================================================================================
URL encoding
  The standards do not define any way by which a URI might specify the encoding it uses, so it has to be deduced from the surrounding information. For HTTP URLs it can be the HTML page encoding, or HTTP headers. reserved characters are different for each part encoding a fully constructed URL is impossible without a syntactical awareness of the URL structure.
  href="http://blog.lunatech.com/2009/02/03/what-every-web-developer-must-know-about-url-encoding"
   
tags: programming webdev encoding uri rfc url
  time="2013-06-24T14:21:50Z" 

================================================================================
History of the URL: Domain, Protocol, and Port
https://eager.io/blog/the-history-of-the-url-domain-and-protocol/
tags: todo programming webdev uri rfc url history

================================================================================
History of the URL: Path, Fragment, Query, and Auth
https://eager.io/blog/the-history-of-the-url-path-fragment-query-auth/
tags: todo programming webdev uri rfc url history

================================================================================
algernon web server
https://github.com/xyproto/algernon
tags: programming http web server lua go redis
Small self-contained pure-Go web server with Lua, Markdown, HTTP/2, QUIC,
Redis and PostgreSQL support https://algernon.roboticoverlords.org/

================================================================================
Napoleon Bonaparte PBS Documentary
https://www.youtube.com/watch?v=MrbiSUgZEbg
tags: video history
- Napoleon established the "Civil Code" which still underpins the French system.
- "I am the instrument of providence, she will use me as long as I accomplish
  her designs, then she will break me like a glass."
- British mothers would tell their children: "If you don't say your prayers,
  Boney will come and get you."
- "Conquest alone made me what I am. Conquest alone can keep me there."

================================================================================
modern.IE
  free official virtualbox images with internet explorer
href="http://www.modern.ie/"  
tags: vm tools programming webdev ie virtualbox windows microsoft
  time="2013-06-14T06:02:44Z" 

================================================================================
EDWARD SNOWDEN, THE N.S.A. LEAKER, COMES FORWARD
  &amp;quot;I, sitting at my desk, certainly had the authorities to wiretap anyone, from you or your accountant, to a federal judge or even the President&amp;quot; another program, called Boundless Informant, processed billions of pieces of domestic data each month James Clapper, the Director of National Intelligence, flat-out lied to the Senate when he said that the N.S.A. did not ‚Äúwittingly‚Äù collect any sort of data on millions of Americans. [Americans are] protected, he said, only by ‚Äúpolicies,‚Äù and not by law: ‚ÄúIt‚Äôs only going to get worse, until eventually there comes a time when policies change,‚Äù and ‚Äúa new leader will be elected, they‚Äôll flip the switch.‚Äù
  href="http://www.newyorker.com/online/blogs/closeread/2013/06/edward-snowden-the-nsa-leaker-comes-forward.html"
   
tags: authoritarianism paranoia politics police-state privacy
  time="2013-06-10T05:33:06Z" 

================================================================================
Falsehoods programmers believe about time
  also: https://news.ycombinator.com/item?id=4128208 more: http://infiniteundo.com/post/25509354022/more-falsehoods-programmers-believe-about-time-wisdom
href="http://infiniteundo.com/post/25326999628/falsehoods-programmers-believe-about-time"
tags: programming edge-cases datetime
  time="2013-06-07T19:21:33Z" 

================================================================================
Warning Signs in Experimental Design and Interpretation
  Psychology as a discipline has been especially stung by papers that cannot be reproduced. http://www.nytimes.com/2013/04/28/magazine/diederik-stapels-audacious-academic-fraud.html?pagewanted=all&amp;amp;_r=0 Uri Simonsohn &amp;quot;twenty-one word solution&amp;quot;: http://papers.ssrn.com/sol3/papers.cfm?abstract_id=2160588 &amp;quot;p-hacking&amp;quot;, an all too common practice in science that can be detected by statistical tests: http://www.p-curve.com/ http://papers.ssrn.com/sol3/papers.cfm?abstract_id=2259879 &amp;quot;Abstract: &amp;quot;When does a replication attempt fail? The most common standard is: when it obtains p&amp;gt;.05. Replication attempts fail when their results indicate that the effect, if it exists at all, is too small to have been detected by the original study. &amp;quot;Warning Signs in Experimental Design and Interpretation&amp;quot; http://norvig.com/experiment-design.html
  href="http://news.ycombinator.com/item?id=5680292" 
  
tags: psychology skepticism scientific-error science
  time="2013-05-09T18:08:55Z" 

================================================================================
Peter Norvig: pytudes: Python programs to practice or demonstrate skills.
https://github.com/norvig/pytudes
tags: programming todo


================================================================================
Retraction Watch 
http://retractionwatch.com/

tags: skepticism scientific-error medical-industrial-complex research science
  time="2013-05-09T17:52:20Z" 

================================================================================
only 11% of 53 published cancer research papers were reproducible
  Amgen's findings are consistent with those of others in industry. A team at Bayer HealthCare in Germany last year reported4 that only about 25% of published preclinical studies could be validated to the point at which projects could continue. Notably, published cancer research represented 70% of the studies
  href="http://www.nature.com/nature/journal/v483/n7391/full/483531a.html"
   
tags: skepticism scientific-error medical-industrial-complex research cancer science
  time="2013-05-09T17:19:41Z" 

================================================================================
Voting paradox
href="http://en.wikipedia.org/wiki/Voting_paradox" 
tags: politics paradox psychology voting mental-model
  time="2013-05-07T23:13:12Z" 

================================================================================
Arrow's impossibility theorem
  href="http://en.wikipedia.org/wiki/Arrow%27s_impossibility_theorem"
   
tags: game-theory politics paradox psychology voting logic mental-model
  time="2013-05-07T23:10:53Z" 

================================================================================
Windyty: weather visualizer
https://www.windyty.com
tags: visualization tools weather wind-patterns web

================================================================================
Google Books Ngram Viewer
  corpus of text n-grams (contiguous sequence of n items) from the google books project http://books.google.com/ngrams/info raw datasets: http://books.google.com/ngrams/datasets
href="http://books.google.com/ngrams/"  
tags: books visualization tools google data-mining datasets data ngram machine-learning statistics
  time="2013-04-25T22:40:25Z" 

================================================================================
Apache Arrow and the "10 Things I Hate About pandas"
http://wesmckinney.com/blog/apache-arrow-pandas-internals/
tags: pandas python data-science machine-learning statistics

> my rule of thumb for pandas is that you should have 5 to 10 times as much RAM
  as the size of your dataset. So if you have a 10 GB dataset, you should really
  have about 64, preferably 128 GB of RAM if you want to avoid memory management
  problems.
> There are additional, hidden memory killers in the project, like the way that
  we use Python objects (like strings) for many internal details, so it's not
  unusual to see a dataset that is 5GB on disk take up 20GB or more in memory.
> Future (pandas2): Apache Arrow

================================================================================
Instaparse
  attempting to make context-free grammars as easy to use as regular expressions
href="https://github.com/Engelberg/instaparse" 
tags: clojure programming compiler cfg peg parser
  time="2013-04-12T17:16:06Z" 

================================================================================
blockchain.info
href="http://blockchain.info/"  
tags: bitcoin cryptocurrency
time="2013-02-28T05:26:07Z" 

================================================================================
llex.c - Lua parser in c
href="http://www.lua.org/source/5.1/llex.c.html" 
tags: compiler lua parser
  time="2013-02-01T01:18:10Z" 

================================================================================
ANTLR Parser Generator
  http://news.ycombinator.com/item?id=5056841 &quot;It can not only do the basic text-&gt;tree parsing from a file describing the grammar, but will also allow to specify additional grammars for traversing the generated tree and executing arbitrary code in your language of choice as particular nodes are recognized. ... Xpl.g grammar file for parsing the program text and creating the abstract syntax tree, a SemanticAnalysis.g grammar file for doing a first pass through the tree, annotating it with additional information, filling the symbol table, checking semantic correctness and then finally CodeGeneration.g for emitting JVM bytecode using the annotated tree.&quot;
href="http://www.antlr.org/"  
tags: programming compiler parser
time="2013-02-01T01:13:23Z" 

================================================================================
PEG.js: Parser Generator for JavaScript
  http://news.ycombinator.com/item?id=1198683 &quot;PEGs are a recent concept&quot; distinct from CFGs. http://news.ycombinator.com/item?id=1199271 &quot;the problem with PEGs: / implies ordering of the search (parsing) space. You need to order your / operators so that special cases (e.g. longer matches) appear first. Unfortunately, if you don't do this, nothing will tell you you have a problem with your grammar, it will simply not parse some inputs.&quot; =&gt; must exhaustively test PEG parser.
href="http://pegjs.majda.cz/"  
tags: hardware-dev programming compiler parser
  time="2013-02-01T00:57:03Z" 

================================================================================
21 Compilers and 3 Orders of Magnitude in 60 Minutes
https://lobste.rs/s/fcm3dc/21_compilers_3_orders_magnitude_60
http://venge.net/graydon/talks/CompilerTalk-2019.pdf
tags: programming compiler optimization history
.
Proebsting's Law:
  "Compiler Advances Double Computing Power Every 18 Years"
  Empirical observation: Optimizations seem to only win ~3-5x, after 60+ years of work.
Always remember: balance cost tradeoffs by _context_.
80% _best-case_ perf comes from:
  Inline
  Unroll (& Vectorize)
  CSE
  DCE
  Code Motion
  Constant Fold
  Peephole: aka "window"; recognize small set of instructions that can be replaced by shorter/faster instructions.
Balance between interpretation and compilation is context-dependent.
Bytecode interpreter = 1/4 of the performance of optimizing native-code
                       compilers, at 1/20 of the impl cost.
Variation #5: Only compile some functions, interpret the rest
  - Cost of interpreter only bad at inner loops or fine-grain. Outer loops or
    coarse-grain (eg. function calls) similar to virtual dispatch
  - Selectively compile hot functions ("fast mode") at coarse grain.
Partial Evaluation Tricks
  - Consider program in terms of parts that are static (will not change anymore)
    or dynamic (may change).
  - Partial evaluator (a.k.a. "specializer") runs the parts that depend only on
    static info, emits residual program that only depends on dynamic info.
  - 🎅 Interpreter takes two inputs: program to interpret, and program's own
    input. First is static, but redundantly treated as dynamic.
    - 🎅 Thus: _compiling is partial evaluation of an interpreter_, eliminating
      the redundant dynamic treatment in its first input.
Variation #7: Forget IR and/or AST!
  - Likely means no optimization aside from peephole.

================================================================================
Handling Growth with Postgres: 5 Tips From Instagram - Instagram Engineering
  href="http://instagram-engineering.tumblr.com/post/40781627982/handling-growth-with-postgres-5-tips-from-instagram"
   
tags: sql scalability performance postgresql database
  time="2013-02-01T00:55:01Z" 

================================================================================
kelly norton: On Layout &amp; Web Performance
  The following properties CAUSE LAYOUT: Element: clientHeight clientLeft clientTop clientWidth focus getBoundingClientRect getClientRects innerText offsetHeight offsetLeft offsetParent offsetTop offsetWidth outerText scrollByLines scrollByPages scrollHeight scrollIntoView scrollIntoViewIfNeeded scrollLeft scrollTop scrollWidth MouseEvent: layerX layerY offsetX offsetY Window: getComputedStyle scrollBy scrollTo scrollX scrollY Frame, Document, Image: height width
  href="http://kellegous.com/j/2013/01/26/layout-performance/"
   
tags: programming webdev dev performance layout html web css
  time="2013-02-01T00:51:48Z" 

================================================================================
AMP Camp 
href="http://ampcamp.berkeley.edu/videos/" 
tags: todo machine-learning
  time="2012-11-05T02:25:13Z" 

================================================================================
guardianproject/haven
https://github.com/guardianproject/haven
Haven is for people who need a way to protect their personal spaces and possessions without compromising their own privacy, through an Android app and on-device sensors
tags: paranoia security app mobile phone

================================================================================
Algo VPN: personal IPSEC VPN in the cloud
https://github.com/trailofbits/algo
https://blog.trailofbits.com/2016/12/12/meet-algo-the-vpn-that-works/
tags: anonymous privacy vpn paranoia security ipsec
Does not require client software (unlike OpenVPN).

================================================================================
20200829
sinter: user-mode application authorization system for MacOS written in Swift
https://github.com/trailofbits/sinter
tags: macos security infosec os
https://blog.trailofbits.com/2020/08/12/sinter-new-user-mode-security-enforcement-for-macos/
> EndpointSecurity is an API that implements a callback from the macOS kernel,
> in real time, as a particular event is about to happen. EndpointSecurity
> clients subscribe to one or more event types that are either a NOTIFY type or
> an AUTH (Authorization) type.
>
> EndpointSecurity replaces the kernel-mode equivalents for real-time event
> authorizing on macOS (Kauth KPI and other unsupported kernel methods) and the
> read-only event monitoring OpenBSM audit trail.
>
> Note that there are no network-related events in the EndpointSecurity API
> (except UNIX domain sockets). All of these are in the Network Extension
> framework. You can combine the use of both APIs from one System Extension.

================================================================================
Color Scheme Designer 
href="http://colorschemedesigner.com/"  
tags: art web tools
time="2012-11-04T20:55:04Z" 

================================================================================
CircuitLab | sketch, simulate, and share your circuits
  online circuit simulator
href="https://www.circuitlab.com/"  
tags: engineering simulation electronics
  time="2012-10-22T04:24:43Z" 

================================================================================
r twotorials 
href="http://www.twotorials.com/"  
tags: programming statistics r-lang tutorial
  time="2012-10-17T04:47:56Z" 

================================================================================
CommonCrawl
  open source web crawl data
href="http://commoncrawl.org/"  
tags: datasets
time="2012-10-17T04:07:29Z" 

================================================================================
formlabs 
href="http://www.formlabs.com/"  
tags: electronics engineering self-replication 3d_printing
  time="2012-09-20T04:28:56Z" 

================================================================================
noda-time - Project Hosting on Google Code
href="http://code.google.com/p/noda-time/" 
tags: programming .net datetime library
  time="2012-09-13T18:28:36Z" 

================================================================================
Joda Time - Java date and time API - Home
href="http://joda-time.sourceforge.net/" 
tags: library programming java datetime
  time="2012-09-13T18:27:35Z" 

================================================================================
Vert.x
https://vertx.io/
tags: library programming java concurrency
Eclipse Vert.x is event driven and non blocking. This means your app can handle a lot of concurrency using a small number of kernel threads. Vert.x lets your app scale with minimal hardware.


================================================================================
TACK :: Trust Assertions for Certificate Keys
  dynamically activated public key pinning framework that provides a layer of indirection away from Certificate Authorities, but is fully backwards compatible with existing CA certificates, and doesn't require sites to modify their existing certificate chains.
   href="http://tack.io/"
   
tags: cryptography certificate-authentication paranoia security
  time="2012-08-30T05:35:44Z" 

================================================================================
Prediction Markets: When Do They Work?
https://thezvi.wordpress.com/2018/07/26/prediction-markets-when-do-they-work/
tags: market prediction-market economics mental-model

Remember, if you can’t spot the sucker in your first half hour at the table,
then you are the sucker.
...
Another class of ‘natural’ traders are gamblers or noise traders, who demand
liquidity for no particular reason. They too can be the sucker.

================================================================================
Hybrid cryptosystem
https://en.wikipedia.org/wiki/Hybrid_cryptosystem
tags: security cryptography encryption

Problem:  Public-key (asymmetric) cryptopgraphy is expensive (~1000x worse)
          compared to symmetric-key cryptopgraphy.
          Example: compare AES to RSA using `openssl speed`.
Solution: Hybrid cryptosystem:
            - key encapsulation scheme, which is a public-key cryptosystem, and
            - data encapsulation scheme, which is a symmetric-key cryptosystem.

All practical implementations of public-key cryptography employ a hybrid system.
Example: TLS = Diffie-Hellman + AES.


================================================================================
Convergence
  distributed, secure strategy for replacing Certificate Authorities
href="http://convergence.io/"  
tags: certificate-authentication distributed-systems paranoia security cryptography
  time="2012-08-30T05:32:39Z" 

================================================================================
White House Worked With Buyout Firm to Save Plant - WSJ.com
  White House played a central role in encouraging another private-equity firm to rescue a Philadelphia oil refinery, whose imminent closure by owner Sunoco Inc. threatened to send gasoline prices higher before the election. Gene Sperling, director of Mr. Obama's National Economic Council, helped kick-start discussions to sell the refinery to Carlyle Group, CG -0.04% a well-connected Washington, D.C., private-equity firm. [...] regulators agreed to loosen certain environmental restrictions on the refinery. Pennsylvania's Republican governor, Tom Corbett, contributed $25 million in state subsidies and other incentives. [...] The White House referred the issue to the EPA, which along with state and local environmental officials agreed to modify the decree, allowing Carlyle to transfer emissions credits from the Marcus Hook refinery, in effect giving the Philadelphia refinery greater leeway to pollute.
href="http://online.wsj.com/article/SB10000872396390443713704577603281330597966.html"
tags: politics regulatory-capture
  time="2012-08-23T03:53:45Z" 

================================================================================
Alistair.Cockburn.us | Characterizing people as non-linear, first-order components in software development
  People _failure modes_: - Since consistency of action is a common failure mode, we can safely predict that the documentation will not be up to date. - Individual personalities easily dominate a project. People _success modes_: - People are communicating beings, doing best face-to-face - People are highly variable, varying from day to day - People generally [...] are good at looking around, taking initiative --- - Low precision artifacts use the strengths of people to lower development costs. The most significant single factor is ‚Äúcommunication‚Äù.
  href="http://alistair.cockburn.us/Characterizing+people+as+non-linear%2c+first-order+components+in+software+development"
   
tags: softwareengineering methodology project-management programming
  time="2012-07-23T03:44:27Z" 

================================================================================
My 20-Year Experience of Software Development Methodologies
https://zwischenzugs.wordpress.com/2017/10/15/my-20-year-experience-of-software-development-methodologies/
tags: softwareengineering methodology project-management programming

> humans require ‘collective fictions’ so that we can collaborate in larger
> numbers than the 150 or so our brains are big enough to cope with by default

> Meetings were called ‘scrums’ now, but otherwise it felt very similar to what
> went on before.
> As a collective fiction it worked, because it kept customers and project
> managers off our backs while we wrote the software.
> Since then I’ve worked in a company that grew to 700 people, and now work in
> a corporation of 100K+ employees, but the pattern is essentially the same:
> which incantation of the liturgy will satisfy this congregation before me?

> If software methodologies didn’t exist we’d have to invent them, because how
> else would we work together effectively? You need these fictions in order to
> function at scale.

================================================================================
The Empty Promise of Data Moats / by Martin Casado and Peter Lauten
https://a16z.com/2019/05/09/data-network-effects-moats/
tags: startup network-effects dependencies data moat mental-model
> scale effect has limited value as a defensive strategy for many companies.
.
> Most data network effects are really scale effects:
> Most discussions around data defensibility actually boil down to scale
> effects, a dynamic that fits a looser definition of network effects in which
> there is no direct interaction between nodes.
> ... Unlike traditional economies of scale, where the economics of fixed,
> upfront investment can get increasingly favorable with scale over time, the
> exact opposite dynamic often plays out with data scale effects: The cost of
> adding unique data to your corpus may actually go up, while the value of
> incremental data goes down!
.
> Bootstrapping what we think of as the “minimum viable corpus” is sufficient to start training against, 
.
> Even taking on all the upfront costs to assemble, clean, and standardize big
> pools of public datasets can create a scale effect that emerging competitors
> will have to recreate from the ground up.

================================================================================
Stripe 
href="https://stripe.com/"  
tags: startup business api ecommerce
  time="2012-07-19T05:32:06Z" 

================================================================================
Twilio | Build Scalable Voice, VoIP and SMS Applications in the Cloud
href="http://www.twilio.com/"  
tags: startup api telephony
time="2012-07-19T05:31:14Z" 

================================================================================
Dwolla 
href="https://www.dwolla.com/"  
tags: startup business ecommerce
time="2012-07-19T05:30:18Z" 

================================================================================
The If Works - Translation from Haskell to JavaScript of selected portions of the best introduction to monads I‚Äôve ever read
  monad: a design pattern. It says that whenever you have a class of functions that accept one type and return another type, there are two functions that can be applied across this class to make them composable: - 'bind' function: transforms any function to accept the same type as it returns, making it composable - 'unit' function: wraps a value in the type accepted by the composable functions. 'monad' pattern helps you spot accidental complexity: code that isn‚Äôt dealing directly with the problem at hand, but which is just glueing data types together.
  href="http://blog.jcoglan.com/2011/03/05/translation-from-haskell-to-javascript-of-selected-portions-of-the-best-introduction-to-monads-ive-ever-read/"
   
tags: javascript monad functional-programming haskell
  time="2012-07-19T05:23:04Z" 

================================================================================
C++ FAQ 
href="http://www.parashift.com/c++-faq/" 
tags: cpp programming faq
  time="2012-07-18T17:30:30Z" 

================================================================================
WordNet - Princeton University Cognitive Science Laboratory
  lexical database of cognitive synonyms (synsets) interlinked by means of conceptual-semantic and lexical relations.
href="http://wordnet.princeton.edu/"  
tags: datasets data-mining
time="2012-07-05T03:55:32Z" 

================================================================================
Tcl Quick Reference
  also: http://www.fundza.com/tcl/quickref_2/ Yes, [expr] is a bit clunky - in Tcl8.5 arithmetic can also be done with prefix operators: % namespace import ::tcl::mathop::* % * 3 [+ 1 2] =&gt; 9
href="http://www.fundza.com/tcl/quickref_1/" 
tags: reference tcl programming
  time="2012-06-20T02:36:55Z" 

================================================================================
OMG Ponies!!! (Aka Humanity: Epic Fail) - Jon Skeet: Coding Blog
  extended="- unicode &quot;composite characters&quot;: http://unicode.org/faq/char_combmark.html#7 - &quot;zero-width non-joiner&quot; \u200c - Turkey test java.util.Date and Calendar may or may not account for leap seconds depending on the host support CST timezone is one of { Central Standard Time US / UTC-6; Central Standard Time Australia / UTC+9.30; Central Summer Time Australia } &quot;Argentina announced that it wasn't going to use daylight saving time any more... 11 days before its next transition. The reason? Their dams are 90% full. I only heard about this due to one of my unit tests failing. For various complicated reasons, a unit test which expected to recognise the time zone for Godthab actually thought it was Buenos Aires. So due to rainfall thousands of miles away, my unit test had moved Greenland into Argentina.&quot;"
  href="http://msmvps.com/blogs/jon_skeet/archive/2009/11/02/omg-ponies-aka-humanity-epic-fail.aspx"
   
tags: data-representation edge-cases datetime unicode programming
  time="2012-06-18T16:58:06Z" 

================================================================================
C++ Frequently Questioned Answers 
href="http://yosefk.com/c++fqa/"  
tags: cpp faq programming
time="2012-06-16T17:46:41Z" 

================================================================================
My first month freelancing | Hacker News
  tptacek's excellent arguments for daily billing increments http://news.ycombinator.com/user?id=tptacek see also: http://news.ycombinator.com/item?id=3420303
href="http://news.ycombinator.com/item?id=4101355" 
tags: contracting freelancing
  time="2012-06-13T03:25:41Z" 

================================================================================
AppHarbor - AppHarbor
  .NET host, build server, deployment
href="https://appharbor.com/"  
tags: build_server .net hosting
time="2012-06-12T17:49:32Z" 

================================================================================
A Quiz About Integers in C | Hacker News
  type coercion pathology
href="http://news.ycombinator.com/item?id=4061815" 
tags: programming c
time="2012-06-04T16:13:07Z" 

================================================================================
JRuby casting null support
  cast nulls in jruby. java_alias, java_method, java_send
href="http://jira.codehaus.org/browse/JRUBY-3865" 
tags: repl java jruby
time="2012-04-28T00:08:08Z" 

================================================================================
"java.lang.OutOfMemoryError: PermGen space" exception (classloader leaks)
  java PermGen = class definition heap avoid static references to class definitions &quot;The JDK's permanent memory behaves differently depending on whether a debugger is enabled&quot; http://wiki.caucho.com/Java.lang.OutOfMemoryError:_PermGen_space
  href="http://frankkieviet.blogspot.com/2006/10/how-to-fix-dreaded-permgen-space.html"
   
tags: heap permgen debug profiling programming java
  time="2012-04-20T23:06:14Z" 

================================================================================
Code, Collaborate, Compile - compilify.net
href="http://compilify.net/"  
tags: tools programming online repl
  time="2012-04-11T22:42:28Z" 

================================================================================
Affordances - Interaction-Design.org: HCI, Usability, Information Architecture, User Experience, and more..
  affordance = an action possibility available to the user avoid &quot;false affordance&quot; (like a knob that cannot be turned, or a chair that cannot be sat in). an intelligent control interface is as a false affordance. http://unqualified-reservations.blogspot.com/2009/07/wolfram-alpha-and-hubristic-user.html
href="http://www.interaction-design.org/encyclopedia/affordances.html"
tags: design hci patterns ui usability
  time="2012-04-10T05:35:50Z" 


================================================================================
convey the global structure (BIG PICTURE) of programs
http://akkartik.name/about
tags: software architecture programming project-management engineering complexity documentation

- Deemphasize interfaces in favor of tests. Automated tests are great not just
  for avoiding regressions and encouraging a loosely-coupled architecture, but
  also for conveying the BIG PICTURE of a project.
- Deemphasize abstractions in favor of traces. For example, the repository for
  a text editor might guide new programmers first to a trace of the events that
  happen between pressing a key and printing a character to screen, demarcating
  the major sub-systems of the codebase in the process and allowing each line in
  the logs to point back at code, silently jumping past details like what the
  precise function boundaries happen to be at the moment.


================================================================================
Distributed Systems Programming. Which Level Are You? ¬´ Incubaid Research
  Partial Failure ... These failure modes are the very defining property of distributed systems. &quot;A distributed system is one in which the failure of a computer you didn‚Äôt even know existed can render your own computer unusable&quot; (Leslie Lamport) abandon the idea of network transparency, and attack the handling of partial failure distributed state machine: &quot;multi-paxos implementation on top of TCP&quot; Unit testing: The problem however is reproducing the failure scenario is difficult, if not impossible concurrency causes indeterminism, but you can‚Äôt abandon it--you just have to ban it from mingling with your distributed state machine (No IO, No Concurrency). you can only get to a new state via a new message. Benefits: Perfect control, reproducibility, tracibility. Costs: You‚Äôre forced to reify all your actions. You have to model every change that needs your attention into a message.
  href="http://blog.incubaid.com/2012/03/28/the-game-of-distributed-systems-programming-which-level-are-you/"
   
tags: concurrency architecture programming distributed-systems
  time="2012-04-04T16:48:46Z" 

================================================================================
UNDERSTANDING HASH FUNCTIONS by Geoff Pike
https://github.com/google/farmhash/blob/master/Understanding_Hash_Functions
tags: programming compsci algorithms hash-function

================================================================================
More study of diff: Walter Tichy's papers
http://bryanpendleton.blogspot.de/2010/04/more-study-of-diff-walter-tichys-papers.html
tags: programming algorithms diff
two papers by Walter Tichy:
- The String-to-String Correction Problem with Block Moves
  http://docs.lib.purdue.edu/cstech/378/
- Delta Algorithms: An Empirical Analysis
  http://portal.acm.org/citation.cfm?id=279310.279321
The first paper is almost 30 years old, and dates from Tichy's work at Purdue
during the development of RCS. From the introduction:
  The string-to-string correction problem is to find a minimal sequence of edit
operations for changing a given string into another given string. The length of
the edit sequence is a measure of the differences between the two strings.
  At the time, the best-known diff algorithm was Doug McIlroy's Unix diff
algorithm (more on that in a future post), which is based on the detection of
the Longest Common Subsequence. As Tichy shows, the LCS-based algorithms, while
computationally related to the edit sequence programs, are not necessarily the
best for use in difference construction.
Tichy's basic algorithm is surprisingly simple to state:
    Start at the left end of the target string T, and try to find prefixes of
    T in S. If no prefix of T occurs in S, remove the first symbol from T and
    start over. If there are prefixes, choose the longest one and record it as
    a block move. Then remove the matched prefix from T and try to match
    a longest prefix of the remaining tail of T, again starting at the beginning
    of S. This process continues until T is exhausted. The recorded block moves
    constitute a minimal covering set of block moves.
After working through a proof of the basic algorithm, Tichy briefly touches on
two variations:
  Program text and prose have the property of few repeated lines. ... To speed up
comparisons, the program should use hashcodes for lines of text rather than
performing character-by-character comparisons.
  An important element in the Knuth-Morris-Pratt algorithm is an auxiliary array
N which indicates how far to shift a partially matched pattern or block move
after a mismatch. ... Fortunately, N can also be computed incrementally.
  The first variation finds an interesting expression 15 years later in the work
of Andrew Tridgell on the rsync algorithm, which I'll discuss in a future post.
  Delta Algorithms: An Empirical Analysis describes Tichy's work in benchmarking
diff algorithms. The paper contains dozens of scatter-plot diagrams of the
various benchmark tests, as well as a fine high-level discussion of the
complexity of building a suitable benchmark for diff:
    The first problem encountered when defining a benchmark is finding an
    appropriate data set that is both large enough for the results to be
    statistically significant and representative of real world applications. For
    delta algorithms, the most important quality of any benchmark is that it
    contain a wide spectrum of change examples. This means that both the size of
    the changes represented and the size of the files involved should vary
    considerably. Large changes on small files and small changes on large files
    should be included as well as small changes on small files and large changes
    on large files.
Furthermore, the benchmark should contain a variety of formats, in particular
pure text, pure object code, and pseudo text.
The paper also describes a diff algorithm variation which they call vdelta:
    Vdelta is a new technique that combines both data compression and data
    differencing. It is a refinement of W.F. Tichy's block-move algorithm, in
    that, instead of a suffix tree, vdelta uses a hash table approach inspired
    by the data parsing scheme in the 1978 Ziv-Lempel compression technique.
    Like block-move, the Ziv-Lempel technique is also based on a greedy approach
    in which the input string is parsed by longest matches to previously seen
    data. ... Vdelta generalizes Ziv-Lempel and block-move by allowing for
    string matching to be done both within the target data and between a source
    data and a target data. For efficiency, vdelta relaxes the greedy parsing
    rule so that matching prefixes are not always maximally long.
With diff algorithms, it is becoming clear that two things are true:
- There have been a variety of diff algorithms discovered and re-discovered over
  the years, but many of them are not well-described nor easy to find: the
  papers are scattered, hard to locate, and behind ACM or IEEE paywalls; and
  when the papers are tracked down, they are confusing and hard to read.
- The two Myers papers ("A file comparison program" and "An O(ND) difference
  algorithm and its variations") are so well-written and so well-known that they
  have pretty much dominated the discussion.

================================================================================
google-diff-match-patch - Google Code
robust diff/patch library Myer's diff algorithm Bitap matching algorithm more sophisticated than GNU patch
href="https://github.com/google/diff-match-patch"
tags: google library programming algorithms diff lua

================================================================================
[Toybox] More than you really wanted to know about patch.
http://lists.landley.net/pipermail/toybox-landley.net/2019-January/010049.html
tags: programming tools unix algorithms diff patch
> So generally what you do _now_ (and what tools like svn/mercurial/git simulate
> behind the scenes) is back up one directory, have two full trees (the vanilla
> project and your modified version), and "diff -ruN" the two subdirectories.
> That's why tools like git create diffs that start like:
>
>    +++ a/path/to/file
>    --- b/path/to/file
>
> Each hunk starts with a @@ line:
>
>     @@ -start,len +start,len @@ comment
>
>     - "start" is the line number in that file the hunk starts applying at, and
>       "len" is the number of lines described in that file.
>     - The "comment" part can be anything. It's ignored.
>
> Each hunk line starts with one of three characters:
>
> 1. + this line is only in the new version (it was added).
> 2. - this line is only in the old version (it was removed).
> 3. " " (space) = this line is the same in both (context line).
>
> - Must have the same number of leading and trailing context lines, unless you're
>   at the start/end of a file. Else it's not a valid hunk and patch barfs on the
>   corrupted patch. And the number of leading/trailing context lines not being
>   the same means the patch program will try to MATCH the start/end of the file,
>   and fail if it can't.
> - Hunks must apply in order, and this INCLUDES the context lines. A line that's
>   been "seen" as a trailing context line won't match against the leading context
>   of the next hunk.

================================================================================
20200829
Graphtage: A New Semantic Diffing Tool
https://github.com/trailofbits/graphtage
tags: programming tools algorithms diff patch merge semantic-diff
https://blog.trailofbits.com/2020/08/28/graphtage/
When paired with PolyFile, you can semantically diff arbitrary file formats.
https://blog.trailofbits.com/2019/11/01/two-new-tools-that-tame-the-treachery-of-files/

================================================================================
Data Laced with History: Causal Trees & Operational CRDTs
http://archagon.net/blog/2018/03/24/data-laced-with-history/
https://news.ycombinator.com/item?id=18477756
tags: algorithms compsci diff crdt

================================================================================
"I See What You Mean" by Peter Alvaro
https://www.youtube.com/watch?v=R2Aa4PivG0g&t=2295s
tags: datalog query language

================================================================================
Dedalus: Datalog in Time and Space
https://www2.eecs.berkeley.edu/Pubs/TechRpts/2009/EECS-2009-173.html
tags: datalog query language

================================================================================
Bloom
https://github.com/bloom-lang/bud
Dedalus rewrite
tags: datalog query language


================================================================================
High Scalability - 7 Years of YouTube Scalability Lessons in 30¬†Minutes
  Jitter - Add Entropy Back into Your System: If your system doesn‚Äôt jitter then you get thundering herds. Debugging distributed applications is as deterministic as predicting the weather. Jitter introduces more randomness because things tend to stack up. For example, cache expirations: If everything expires at one time this creates a thundering herd. To introduce &quot;jitter&quot; you might randomly expire between 18-30 hours. Each machine actually removes entropy from the system, so you have to add some back in. Cheating - Know How to Fake Data: The fastest function call is the one that doesn‚Äôt happen. A monotonically increasing counter, like movie view counts or profile view counts, could update by a random amount and as long as it changes from odd to even people would probably believe it‚Äôs real, and the actual transactions only need to happen occasionally.
  href="http://highscalability.com/blog/2012/3/26/7-years-of-youtube-scalability-lessons-in-30-minutes.html"
   
tags: programming architecture scalability
  time="2012-03-28T16:11:27Z" 

================================================================================
DOM Events, Memory Leaks, and You - Google Web Toolkit - Google Code
  &quot;any reference cycle that involves a JavaScript object and a DOM element (or other native object) has a nasty tendency to never get garbage-collected&quot; &quot;as long as you don't set up any reference cycles on your own using JSNI, you can't write an application in GWT that will leak.&quot;
  href="https://developers.google.com/web-toolkit/articles/dom_events_memory_leaks_and_you"
   
tags: programming eventbus memoryleak gwt
  time="2012-03-23T13:56:26Z" 

================================================================================
Understanding Memory Leaks - Google Web Toolkit (GWT)
  *widget/DOM* level, vs. application/global level. you don't need to to unregister event handlers at the widget level--only the application/global level.
  href="http://code.google.com/p/google-web-toolkit/wiki/UnderstandingMemoryLeaks"
   
tags: eventbus memoryleak programming gwt
  time="2012-03-22T16:39:22Z" 

================================================================================
GWT Handler Registrations
  memory leaks: application level vs. DOM/widget level removeHandler is *never* required to avoid DOM-/browser-level memory leaks removeHandler *is* required to avoid application-level memory leaks For global EventBus with a transient event listener, the transient listener will prevent its container object from being garbage-collected until the EventBus is also garbage collected. Instead of handing the application-wide EventBus directly to an activity, wrap the EventBus in a ResettableEventBus. Then when that activity is done, ResettableEventBus.removeHandlers().
  href="http://draconianoverlord.com/2010/11/23/gwt-handlers.html"
   
tags: memoryleak eventbus programming gwt
  time="2012-03-22T16:37:35Z" 

================================================================================
Baby's First Garbage Collector
http://journal.stuffwithstuff.com/2013/12/08/babys-first-garbage-collector/
tags: gc garbage-collector compsci programming-language
  //
  // mark-and-sweep gc implementation
  //
  void mark(Object* object) {
    /* If already marked, we're done. Check this first
       to avoid recursing on cycles in the object graph. */
    if (object->marked) return;

    object->marked = 1;

    if (object->type == OBJ_PAIR) {
      mark(object->head);
      mark(object->tail);
    }
  }
  void sweep(VM* vm)
  {
    Object** object = &vm->firstObject;
    while (*object) {
      if (!(*object)->marked) {
        /* This object wasn't reached, so remove it from the list
           and free it. */
        Object* unreached = *object;

        *object = unreached->next;
        free(unreached);
      } else {
        /* This object was reached, so unmark it (for the next GC)
           and move on to the next. */
        (*object)->marked = 0;
        object = &(*object)->next;
      }
    }
  }



================================================================================
Windows File System Redirection (Diagnosing weird problems - a Stack Overflow case study)
http://www.reddit.com/r/programming/comments/qzo96/diagnosing_weird_problems_a_stack_overflow_case/
tags: debug kernel windows

For 32-bit programs running on 64-bit Windows, the &quot;File System
Redirector&quot; transparently redirects calls to System32 folder to the
SysWOW64 folder.
SysWOW64: 32-bit binaries
System32: 64-bit binaries
A 32-bit process can access the "real" System32 as %WINDIR%\Sysnative
to bypass the filesystem redirection that would otherwise give you SysWOW64. If
you try to write to a file under \Program Files as a regular user, it will
appear to work but you'll really be writing to
%LOCALAPPDATA%\VirtualStore\Program Files. Similarly, registry writes to the
HKLM hive are redirected to the HKCU hive.

================================================================================
Container isolation gone wrong / By Gianluca Borello on May 22, 2017
https://sysdig.com/blog/container-isolation-gone-wrong/
tags: debug kernel linux perf perf-tools

As a last step, we can try to quantify the performance hit from the hash table point of view. To recap, the lookup in the hash table becomes slower because the array of buckets is of fixed size and it’s never resized at runtime, since it’s very large to begin with. As we put more objects inside the table, the length of the linked lists in each bucket will inevitably increase, and this will cause more iterations on average in order to find the object we are looking for.

We can verify all this with perf. Using perf probe, we can see which lines inside the __d_lookup function we can attach a tracing counter to, and all this can happen at runtime:

$ sudo perf probe -L __d_lookup
      0  struct dentry * __d_lookup(struct dentry * parent, struct qstr * name)
      1  {
      2         unsigned int len = name->len;
      3         unsigned int hash = name->hash;
      4         const unsigned char *str = name->name;
      5         struct hlist_head *head = d_hash(parent,hash);
                struct dentry *found = NULL;
                struct hlist_node *node;
                struct dentry *dentry;

                rcu_read_lock();

     12         hlist_for_each_entry_rcu(dentry, node, head, d_hash) {
                        struct qstr *qstr;

     15                 if (dentry->d_name.hash != hash)
                                continue;
     17                 if (dentry->d_parent != parent)
                                Continue;
...
Luckily, the function is very simple and we can quickly identify, at line 12, the loop that iterates over the linked list containing all the dentry objects matching the hash of the path component that is being looked up. We can then add two dynamic trace points: one at the beginning of the function (__d_lookup) and one at the beginning of the loop (__d_lookup_loop). This way, we’ll be able to really tell how many list iterations were done on average for each path lookup:

$ sudo perf probe --add __d_lookup
Added new event:
  probe:__d_lookup     (on __d_lookup)

$ sudo perf probe --add __d_lookup_loop=__d_lookup:15
Added new events:
  probe:__d_lookup_loop (on __d_lookup:15)
And we can then run perf another time to actually instrument the kernel while we simulate the two scenarios:

$ sudo perf stat -p 18189 -e "probe:__d_lookup" -e "probe:__d_lookup_loop" -- sleep 60
 Performance counter stats for process id '18189':

         2,763,816      probe:__d_lookup
        75,503,432      probe:__d_lookup_loop

      60.001285559 seconds time elapsed

$ sudo perf stat -p 18189 -e "probe:__d_lookup" -e "probe:__d_lookup_loop" -- sleep 60
 Performance counter stats for process id '18189':

         3,800,247      probe:__d_lookup
         3,811,830      probe:__d_lookup_loop

      60.002976808 seconds time elapsed
The results are very interesting, but not surprising at this point. In the first scenario (the slow one), the hash table is clearly clogged and there are almost 30 collisions for each lookup (75M loop iterations / 2.7M lookups = ~30). In the last one, the hash table is correctly empty, and there are almost no collisions since each dentry lookup takes one single iteration in the list (3.8M loop iterations / 3.8M lookups = 1), resulting in a faster execution of the lstat() system call.



================================================================================
A Rebase Workflow for Git | RandyFay.com
  use 'rebase' workflow instead of 'merge' workflow
href="http://www.randyfay.com/node/91"  
tags: dvcs dv git
time="2012-03-01T23:05:53Z" 

================================================================================
52 Things People Should Know To Do Cryptography
href="http://www.cs.bris.ac.uk/Research/CryptographySecurity/knowledge.html"
tags: compsci cryptography
  time="2012-02-22T01:59:23Z" 

================================================================================
L. Gordon Crovitz: You Commit Three Felonies a Day - WSJ.com
  Harvey Silverglate book: &quot;Three Felonies a Day&quot; ...securities laws, which Congress leaves intentionally vague, encouraging regulators and prosecutors to try people even when the law is unclear. Prosecutors identify defendants to go after instead of finding a law that was broken and figuring out who did it.
href="http://online.wsj.com/article/SB10001424052748704471504574438900830760842.html"
tags: police-state politics
  time="2012-02-20T05:53:54Z" 

================================================================================
Congresswoman who voted for the Patriot Act expresses outraged after being wiretapped
href="https://www.youtube.com/watch?v=NFn4JXkcwLs" 
tags: video politics police-state
  time="2012-02-20T05:26:10Z" 

================================================================================
Use C# 4.0 dynamic to drastically simplify your private reflection code - Angle Bracket Percent - Site Home - MSDN Blogs
  Access private and internal members in other assemblies, using private reflection. foo1.AsDynamic()
href="http://blogs.msdn.com/b/davidebb/archive/2010/01/18/use-c-4-0-dynamic-to-drastically-simplify-your-private-reflection-code.aspx"
tags: programming reflection c# .net
  time="2012-01-31T06:25:39Z" 

================================================================================
Things to Do | tampabay.com &amp; the St. Petersburg Times
href="http://www.tampabay.com/things-to-do/" 
tags: fun tampa
time="2012-01-23T08:03:38Z" 

================================================================================
The ultimate Vim configuration - vimrc
href="http://amix.dk/vim/vimrc.html"  
tags: vim
time="2012-01-20T19:06:53Z" 

================================================================================
Keeping a clean GitHub fork ‚Äì Part 1 ¬ª Evan's Blog
  - add a remote pointing to the canonical repository. - you may want to also add some other remotes of developers you follow. - your master branch should always be a mirror of the upstream master branch - --ff-only : &quot;the single safest way to update your local master branch&quot; - All work should be done in topic branches: feature/some-new-thing hotfix/BUGID-andor-description - generally, you want to branch from master - commit and push early and often
href="http://blog.evan.pro/keeping-a-clean-github-fork-part-1"
tags: programming git
  time="2012-01-20T18:09:25Z" 

================================================================================
Joel Pobar's weblog
  series on HTML Data Extraction ~Mar 2010
href="http://callvirt.net/blog/"  
tags: f# blog machine-learning c# .net programming
  time="2012-01-18T15:32:03Z" 

================================================================================
blueimp/jQuery-File-Upload - GitHub
  Excellent multiple/drag/drop file upload.
href="https://github.com/blueimp/jQuery-File-Upload" 
tags: programming web asp.net jquery
  time="2011-12-31T22:50:34Z" 

================================================================================
Session_Start or Session_OnStart?
  Idiosyncrasies of global.asax event signatures... void Session_Start(object sender, EventArgs e) void Session_Start() void Session_OnStart(object sender, EventArgs e) void Session_OnStart() ALL will be called, in the order as listed.
href="http://aspnetresources.com/articles/event_handlers_in_global_asax"
tags: asp.net programming
  time="2011-11-28T03:41:49Z" 

================================================================================
GoogleContainerTools/distroless
https://github.com/GoogleContainerTools/distroless/blob/master/base/README.md
tags: linux oss google gce cloud container distro
gcr.io/distroless/base and gcr.io/distroless/static
Image Contents
This image contains a minimal Linux, glibc-based system. It is intended for use directly by "mostly-statically compiled" languages like Go, Rust or D.
.
Statically compiled applications (Go) that do not require libc can use the gcr.io/distroless/static image, which contains:
.
ca-certificates
A /etc/passwd entry for a root user
A /tmp directory
tzdata
Most other applications (and Go apps that require libc/cgo) should start with gcr.io/distroless/base, which contains all of the packages in gcr.io/distroless/static, and
.
glibc
libssl
openssl

================================================================================
3 Misconceptions That Need to Die
  Misconception: Most of what Americans spend their money on is made in China. Fact: Just 2.7% of personal consumption expenditures go to Chinese-made goods and services. Misconception: We owe most of our debt to China. Fact: China owns 7.8% of U.S. government debt outstanding. Misconception: We get most of our oil from the Middle East. Fact: Just 9.2% of oil consumed in the U.S. comes from the Middle East.
href="http://www.fool.com/investing/general/2011/10/25/3-misconceptions-that-need-to-die.aspx"
tags: politics economics
  time="2011-11-07T02:37:34Z" 

================================================================================
Ilya Khrzhanovsky's Dau: &quot;The Movie Set That Ate Itself&quot;
  The fine system has also fostered a robust culture of snitching. &quot;In a totalitarian regime, mechanisms of suppression trigger mechanisms of betrayal,&quot; the director explains. ... The only acting professional in the cast is Radmila Shchegoleva ... before shooting began, she spent a full year working at a chocolate factory and a hospital, a regimen devised by Khrzhanovsky to beat the actress out of her. ... For the lead role, he had one stipulation: It had to be played by an actual genius, regardless of the discipline. ... &quot;All geniuses are foreigners,&quot; Khrzhanovsky tells me cryptically. ... Sveta, the film's comely &quot;executive producer,&quot; came here two years ago to interview Khrzhanovsky for a book on young Russian directors and stayed, divorcing her husband soon after.
href="http://www.gq.com/entertainment/movies-and-tv/201111/movie-set-that-ate-itself-dau-ilya-khrzhanovsky"
tags: film art bizarre
  time="2011-10-31T22:46:25Z" 

================================================================================
Google Guava
  Google's core libraries that we rely on in our Java-based projects: collections, caching, primitives support, concurrency libraries, common annotations, string processing, I/O, etc.
href="http://code.google.com/p/guava-libraries/" 
tags: java google oss programming library
  time="2011-10-19T22:53:36Z" 

================================================================================
Stephen Colebourne's blog: Time-zone database down
href="http://blog.joda.org/2011/10/today-time-zone-database-was-closed.html"
tags: ip law government-failure
  time="2011-10-17T13:07:53Z" 

================================================================================
The (Illegal) Private Bus System That Works - Lisa Margonelli - National - The Atlantic
  The city's perverse policy of half-legalizing legal vans and failing to enforce laws against the unlicensed ones limits the growth of what could be a useful transit resource. --- Comment: The chief reason for the demise of privately owned mass transit and the decline of the succeeding publicly owned version was the inability of transit providers to raise fares. No politician wanted to preside over a fare increase, so fares were kept artificially and unrealistically low for decades until the 70s, when there was finally a crisis. Should the dollar vans be fully legalized, and therefore regulated, we can expect politicians -- who are universally devoid both of economic knowledge and of business sense -- to replay the former history, so that Winston and his fellows will be bankrupt within 10 years of achieving legality.
  href="http://www.theatlantic.com/national/archive/2011/10/the-illegal-private-bus-system-that-works/246166/"
   
tags: economics transportation government-failure
  time="2011-10-17T12:48:11Z" 

================================================================================
mergerfs
https://github.com/trapexit/mergerfs
tags: filesystem union jbod data-management raid fuse
union filesystem (JBOD solution)
> mergerfs is a union filesystem geared towards simplifying storage and
> management of files across numerous commodity storage devices. It is similar
> to mhddfs, unionfs, and aufs.
>
> Works with heterogeneous filesystem types


================================================================================
Amazon six-pager
https://news.ycombinator.com/item?id=19115686
tags: documentation communication work habits teams amazon
principles of the 6-pager:
- 6 pages is the upper limit; the memo can be shorter
- Format is designed to drive the meeting structure by requiring attendees
  to read the memo in the first 10 minutes of a meeting, followed by discussion
- You can push extra information into the appendix if needed to convince those
  looking for more evidence
- The memo is self-sufficient as a unit of information, unlike a Powerpoint that
  relies on the presenter to contextualize and connect the information
The basic thrust is to bring the discipline of scientific style article writing
into office communications (and avoid Powerpoint anti-patterns in the process).
> "Writing is nature's way of letting you know how sloppy your thinking is." -Dick Guindon, via Leslie Lamport



================================================================================
Protocol Buffers - Google's data interchange format
  Protocol Buffers are a way of encoding structured data in an efficient yet extensible format. Google uses Protocol Buffers for almost all of its internal RPC protocols and file formats. also: http://code.google.com/p/protobuf-net/
href="http://code.google.com/p/protobuf/" 
tags: library google programming protocol
  time="2011-10-13T07:18:54Z" 

================================================================================
s.tl() : Omniture ¬ª Custom Link Tracking: Capturing User Actions
  - based on s.tl() - used to track anything: button clicks, form values, etc. - does NOT count a page view. - Note from &quot;SiteCatalyst Implementation Guide&quot;: If linkTrackVars is set to &quot;&quot; ALL variables that have values will be sent with link data.
  href="http://blogs.omniture.com/2009/03/12/custom-link-tracking-capturing-user-actions/"
   
tags: adobe omniture sitecatalyst webanalytics javascript
  time="2011-10-04T19:10:14Z" 

================================================================================
Using System.Net Tracing - Durgaprasad Gorti's WebLog - MSDN Blogs
  You can see clearly that 1) The Remote Certificate is being clearly presented in the log file. 2) Any errors in the remote certificate are logged. 3) In this case we are returning true for NAME MISMATCH if the server is local or intranet [Please see the remore certificate validation callback code] 4) The fact that we accepted the certificate is also logged. 5) Then at the sockets level you can see encrypted data being sent 6) At the System.Net level (application level) you can see the decrypted data.
href="http://blogs.msdn.com/b/dgorti/archive/2005/09/18/471003.aspx"
tags: debug .net
  time="2011-09-28T10:09:06Z" 

================================================================================
compute bricks – small-form-factor fanless PCs
http://esr.ibiblio.org/?p=8195
tags: hardware compute engineering small-form-factor fanless embedded soc
Players in this space include Jetway, Logic Supply, Partaker, and Shuttle.
Poke a search engine with “fanless PC” to get good hits.

================================================================================
google-guice - Guice
  Guice is a lightweight dependency injection framework for Java.¬† Guice alleviates the need for factories and 'new'. Think of Guice's @Inject as the new 'new'. Your code will be easier to change, unit test and reuse in other contexts.
href="http://code.google.com/p/google-guice/" 
tags: programming java google
  time="2011-09-26T17:32:21Z" 

================================================================================
SAP Community Network Wiki - ABAP Language and Runtime Environment
href="http://wiki.sdn.sap.com/wiki/display/ABAP/ABAP+Language+and+Runtime+Environment"
tags: sap programming
  time="2011-09-26T17:26:14Z" 

================================================================================
SAP Developer Network (SDN) 
href="http://www.sdn.sap.com/"  
tags: sap programming
time="2011-09-26T17:17:14Z" 

================================================================================
Signals and Systems | MIT OpenCourseWare
  introduction to analog and digital signal processing¬† Fourier transform¬† Filtering and filter design, modulation, and sampling¬†
  href="http://ocw.mit.edu/resources/res-6-007-signals-and-systems-spring-2011/"
   
tags: pedagogy todo science engineering courses
  time="2011-09-12T16:31:57Z" 

================================================================================
Gundo - Visualize your Vim Undo Tree
href="http://sjl.bitbucket.org/gundo.vim/" 
tags: plugin vim oss
time="2011-09-09T18:44:00Z" 

================================================================================
Semantic Versioning
  Version numbers have three components: major.minor.bugfix. For example: 1.2.4 or 2.13.0.Versions with a major version of 0 (e.g. 0.2.3) make no guarantees about backwards compatibility. You are free to break anything you want. It‚Äôs only after you release 1.0.0 that you begin making promises.If a release introduces backwards-incompatible changes, increment the major version number.If a release is backwards-compatible, but adds new features, increment the minor version number.If a release simply fixes bugs, refactors code, or improves performance, increment the bugfix version number.
href="http://stevelosh.com/blog/2011/09/writing-vim-plugins/#use-semantic-versioning-so-i-can-stay-sane"
tags: programming project-management
  time="2011-09-07T05:27:33Z" 

================================================================================
How to git-svn clone the last n revisions from a Subversion repository?
  use -r option to &quot;shallow clone&quot; big repositories: git svn clone -s -r123:HEAD http://svn.example.com/repos/ -T trunk -b branches -t tags
href="http://stackoverflow.com/questions/747075/how-to-git-svn-clone-the-last-n-revisions-from-a-subversion-repository"
tags: git svn programming
  time="2011-09-06T04:24:42Z" 

================================================================================
Cygwin DLL Remapping Failure
  To handle repeated failures of 'rebaseall', instruct cygwin to avoid the area of memory where an external DLL is mapped.
href="http://code.google.com/p/chromium/wiki/CygwinDllRemappingFailure"
tags: cygwin windows git
  time="2011-09-06T03:32:20Z" 

================================================================================
CO2 lags temperature - what does it mean?
href="http://www.skepticalscience.com/co2-lags-temperature.htm"
tags: agw science
  time="2011-09-01T16:20:35Z" 

================================================================================
A Guide to Efficiently Using Irssi and Screen | quadpoint.org
href="http://quadpoint.org/articles/irssi" 
tags: oss irc linux screen
  time="2011-08-29T18:15:35Z" 

================================================================================
Irssi /channel, /network, /server and /connect ‚Äì What It Means
href="http://pthree.org/2010/02/02/irssis-channel-network-server-and-connect-what-it-means/"
tags: irc oss linux
  time="2011-08-29T18:14:49Z" 

================================================================================
Why do electron orbitals in the molecular orbital theory form in those specific shapes?
  Suppose I connect the ends of the string. All of a sudden, only certain vibrations make any sense on that string, because other wavelengths won't match up at the point where the string is connected together. We refer to this as a periodic boundary condition, that the value of the wave at x must be equal to the value of the wave at x+2pi. Now imagine the same thing all the way around the surface of a sphere. Start at any point, travel in any direction for one trip around the sphere, and the function has to return to the same value for the description to be logical. Then you can take another step and talk about the family of solutions on the surface of a sphere; in one case, the trivial one, there are no nodes, the whole sphere kind of &quot;breathes&quot; together. Then we introduce one equatorial node, the north pole vibrates out and the south pole vibrates in, and then the reverse. Then we add more and more nodes of vibration.
href="http://www.reddit.com/r/askscience/comments/ju47b/why_do_electron_orbitals_in_the_molecular_orbital/"
tags: science pedagogy learning
  time="2011-08-26T02:37:22Z" 

================================================================================
asciinema
https://asciinema.org/
tags: video screencast
.
SETUP
    pip3 install --upgrade asciinema
    npm install --global asciicast2gif
USAGE
    asciinema rec foo.json
    # https://github.com/asciinema/asciicast2gif
    asciicast2gif foo.json foo.gif


================================================================================
Data | The World Bank 
href="http://data.worldbank.org/"  
tags: datasets statistics data-mining
  time="2011-08-21T02:36:00Z" 

================================================================================
http://setosa.io
Visual explanations. Victor Powell
tags: pedagogy mathematics learning
2016-08-09 01:44:45

================================================================================
Cantor's enumeration of pairs
https://en.wikipedia.org/wiki/Pairing_function#Cantor_pairing_function
https://stackoverflow.com/a/682485/152142
tags: mathematics algorithm mental-model
> a pairing function is a process to uniquely encode two natural numbers into a single natural number.


================================================================================
Machine Learning - Stanford University
  open-registration online offering similar to cs229
href="http://ml-class.com/"  
tags: pedagogy video machine-learning
  time="2011-08-17T03:13:59Z" 

================================================================================
RStudio R IDE
href="http://rstudio.org/"  
tags: programming statistics r-lang
  time="2011-08-07T19:05:02Z" 

================================================================================
Google Libraries API
  CDN and loading architecture for the most popular, open-source JavaScript libraries. Makes it easy to serve¬†the libraries, correctly set cache headers, and get bug-fix releases.
  href="https://developers.google.com/speed/libraries/"
   
tags: programming google web javascript jquery
  time="2011-08-05T14:16:46Z" 

================================================================================
Ruxum Exchange 
href="https://x.ruxum.com/"  
tags: bitcoin finance exchange
time="2011-08-04T17:01:06Z" 

================================================================================
obfuscated-openssh
  A patch for OpenSSH which obfuscates the protocol handshake.
href="https://github.com/brl/obfuscated-openssh" 
tags: linux security ssh paranoia oss
  time="2011-08-04T06:42:10Z" 

================================================================================
How to avoid SSH timeouts
  some routers time out idle connections. to fix, edit /etc/ssh/sshd_config on the server:¬† ClientAliveInterval 540 or edit /etc/ssh/ssh_config on the client:¬† ServerAliveInterval 540
href="http://dan.hersam.com/2007/03/05/how-to-avoid-ssh-timeouts/"
tags: ssh linux oss
  time="2011-07-24T20:07:18Z" 

================================================================================
Vowpal Wabbit
  a fast out-of-core learning system sponsored by Yahoo! Research also:¬†http://hunch.net/~vw/
href="https://github.com/JohnLangford/vowpal_wabbit/wiki"
tags: machine-learning programming
  time="2011-07-22T00:53:37Z" 

================================================================================
Machine Learning (Theory)
  a blog about academic research in machine learning and learning theory, by John Langford
href="http://hunch.net/"
tags: blog machine-learning statistics
  time="2011-07-22T00:50:40Z" 

================================================================================
Ideone.com | Online IDE &amp; Debugging Tool
  online IDE for many languages
href="http://ideone.com/"
tags: repl online programming tools web
  time="2011-07-21T09:49:08Z" 

================================================================================
Dynamic Dummy Image Generator - DummyImage.com
href="http://dummyimage.com/"  
tags: tools web webdesign
time="2011-07-21T09:48:06Z" 

================================================================================
google-code-prettify
  really good automatic syntax highlighting of source code snippets in an html page, using javascript and CSS.
  href="http://code.google.com/p/google-code-prettify/"
   
tags: programming javascript editing documentation web
  time="2011-07-21T04:28:56Z" 

================================================================================
Concatenating row values in T-SQL
  - Recursive CTE method - &quot;FOR XML with PATH&quot; method
href="http://www.projectdmx.com/tsql/rowconcatenate.aspx"
tags: sql programming
  time="2011-07-21T01:43:39Z" 

================================================================================
Jon Skeet: Coding Blog 
href="http://msmvps.com/blogs/jon_skeet/" 
tags: blog programming .net c#
  time="2011-07-20T16:56:46Z" 

================================================================================
the Data Hub (CKAN)
  Comprehensive Knowledge Archive Network (CKAN) a dedicated registry of open material¬†¬†
href="http://ckan.net/"
tags: statistics datasets
  time="2011-07-20T07:04:14Z" 

================================================================================
theinfo.org data sets
  list of various data sets
href="http://theinfo.org/get/data"  
tags: datasets statistics
time="2011-07-20T07:00:19Z" 

================================================================================
How to fix Cygwin slow start up
  solution: in¬†/etc/profile.d/bash_completion.sh append an ampersand to the line that runs bash completion: ¬† ¬† . /etc/bash_completion &amp;
href="http://cfc.kizzx2.com/index.php/cygwin-slow-start-up-the-culprit-discovered/"
tags: cygwin bash windows
  time="2011-07-20T01:33:29Z" 

================================================================================
Use Splatting to Simplify Your PowerShell Scripts
  interesting, unsung parts of Windows PowerShell: -¬†Escape char = backtick (`). Also continues a line. -¬†Splatting: ability to use a dictionary or list to supply to parameters to a command. ¬† ¬† $foo =¬†@{ p1 = &quot;a1&quot; p2 = &quot;a2&quot; ... } - use splatting to write functions that call other functions -¬†Windows Presentation Foundation PowerShell Kit (WPK) -¬†Import-Module PowerShellPack
  href="http://blogs.technet.com/b/heyscriptingguy/archive/2010/10/18/use-splatting-to-simplify-your-powershell-scripts.aspx"
   
tags: powershell programming scripting windows
  time="2011-07-14T19:00:45Z" 

================================================================================
Woman arrested for filming the police; supporters targeted by police.
  Video of police intimidation
href="http://www.reddit.com/r/politics/comments/i83a8/remember_the_woman_who_was_arrested_for_filming/"
tags: police-state video
  time="2011-07-04T10:07:12Z" 

================================================================================
CopWatch and OpenWatch: covert recording apps for interactions with authority figures
  &quot;OpenWatch Recorder&quot; and &quot;CopRecorder&quot; covertly record audio and transmit it to the OpenWatch site. There, it is reviewed for significance, stripped of personal information, and published.¬† other:¬† http://www.justin.tv¬† http://qik.com/
href="http://m.boingboing.net/2011/06/24/copwatch-and-openwat.html"
tags: paranoia police-state tools
  time="2011-07-04T09:59:41Z" 

================================================================================
Calculated Risk 
href="http://www.calculatedriskblog.com/" 
tags: finance blog
time="2011-06-30T21:43:19Z" 

================================================================================
Cop Block | Reporting Police Abuse
href="http://www.copblock.org/"  
tags: politics police-state
time="2011-06-29T18:56:51Z" 

================================================================================
Google Web Fonts 
href="http://www.google.com/webfonts/v2" 
tags: google font web css
  time="2011-06-29T18:51:17Z" 

================================================================================
Holistic Numerical Methods 
href="http://numericalmethods.eng.usf.edu/" 
tags: learning mathematics pedagogy video
  time="2011-06-27T19:15:50Z" 

================================================================================
Pi-Search: Search the first four billion binary digits of Pi for a string
  although pi is conjectured to contain all finite information, the index for locating a given string is usually longer than the information itself:¬† http://www.reddit.com/r/math/comments/hi719/does_pi_contain_all_information/c1vl0i6
href="http://pi.nersc.gov/"  
tags: mathematics information
time="2011-05-26T03:37:10Z" 

================================================================================
CATO: Map of Botched Paramilitary Police Raids
href="http://www.cato.org/raidmap/"  
tags: politics police-state
time="2011-05-18T00:06:16Z" 

================================================================================
Marine Survives Two Tours in Iraq, SWAT Kills Him
  Indiana Supreme Court decision: &quot;there is no right to reasonably resist unlawful entry by police officers&quot;. --- &quot;In reality, knock and announce raids aren't all that different than the very rare &quot;no knock&quot; raid.&quot;:¬†http://www.reddit.com/r/Libertarian/comments/hddts/marine_survives_two_tours_in_iraq_swat_kills_him/c1uj1nn
href="http://reason.com/blog/2011/05/16/marine-survives-two-tours-in-i"
tags: police-state politics
  time="2011-05-18T00:03:54Z" 

================================================================================
Nassim N. Taleb Home &amp; Professional Page
  black swan theory; antifragility; small probabilities and model error¬†(convexity effects). &quot;All small probabilities are incomputable.&quot; &quot;There is no such thing as 'measurable risk' in the tails, no matter what model we use.&quot;
href="http://www.fooledbyrandomness.com/" 
tags: statistics finance
  time="2011-04-27T15:56:54Z" 

================================================================================
CRAN Task Views 
href="http://cran.r-project.org/web/views/" 
tags: r-lang statistics programming
  time="2011-04-26T04:58:23Z" 

================================================================================
CRAN Task View: Machine Learning &amp; Statistical Learning
  href="http://cran.r-project.org/web/views/MachineLearning.html"
   
tags: statistics machine-learning ai r-lang programming
  time="2011-04-26T04:57:00Z" 

================================================================================
Data Sets 
  href="http://www-users.cs.umn.edu/~kumar/dmbook/resources.htm"
   
tags: data-mining datasets statistics machine-learning ai
  time="2011-04-14T23:34:35Z" 

================================================================================
UCI Machine Learning Repository
  large collection of standard datasets for testing machine-learning algorithms
href="http://archive.ics.uci.edu/ml/"  
tags: machine-learning ai data-mining statistics datasets
  time="2011-04-14T22:46:52Z" 

================================================================================
Snappy: a fast compressor/decompressor
  a compression/decompression library - aims for very high speeds and reasonable compression. - compresses at about 250+ MB/sec and decompresses at about 500+ MB/sec¬† - Snappy has previously been referred to as ‚ÄúZippy‚Äù in some presentations.
href="http://code.google.com/p/snappy/"  
tags: google programming oss algorithms
  time="2011-04-12T18:33:19Z" 

================================================================================
How to smooth a plot in MATLAB? 
href="http://stackoverflow.com/questions/1515977/how-to-smoothen-a-plot-in-matlab"
tags: matlab statistics data-mining
  time="2011-04-05T02:08:48Z" 

================================================================================
MIT OpenCourseWare
  Free video lectures.¬† See also: http://www.youtube.com/MIT¬†
href="http://ocw.mit.edu/"  
tags: learning engineering pedagogy video
  time="2011-03-29T17:59:04Z" 

================================================================================
Stanford Engineering Everywhere
  Free video lectures.¬† See also: http://www.youtube.com/stanford¬†
href="http://see.stanford.edu/"  
tags: engineering learning pedagogy video
  time="2011-03-29T17:52:51Z" 

================================================================================
Under-used features of Windows batch files
  - line continuation: ^ - open file manager in current dir: start .¬† - parsing with 'for' - substrings - path to script (as opposed to &quot;current directory&quot;): ~dp0 - wait N seconds using 'ping'
  href="http://stackoverflow.com/questions/245395/underused-features-of-windows-batch-files"
   
tags: windows programming scripting cmd dos it
  time="2011-03-24T18:10:47Z" 

================================================================================
DOS Batch files
  Windows CMD commands and their usage in .bat (.cmd) files.
href="http://www.robvanderwoude.com/batchfiles.php" 
tags: scripting windows programming it cmd dos
  time="2011-03-24T18:01:42Z" 

================================================================================
DEA racketeering 
href="http://www.reddit.com/r/politics/comments/g4zy6/the_dea_funds_itself_by_raiding_medical_marijuana/"
tags: politics police-state
  time="2011-03-16T17:18:23Z" 

================================================================================
Understanding Verilog Blocking and Nonblocking Assignments
  href="http://www.sutherland-hdl.com/papers/1996-CUG-presentation_nonblocking_assigns.pdf"
   
tags: verilog engineering hardware-dev usf usf-csd filetype:pdf media:document
  time="2011-03-09T03:14:40Z" 

================================================================================
How to write FSM in Verilog?
  Compare/contrast 3 approaches to implementing a FSM. 1. uses a function for the combinational part. next_state is a WIRE, concurrent assignment (not sequential).¬† 2. Two 'always' blocks: the comb. block is level-sensitive to certain signals, whereas the seq. block is edge-sensitive to the clock. next_state is a REG. 3. One 'always' block, edge-sensitive to clock only. No next_state variable. Signals checked before assigning state. Notice the sequential part 'always @ (posedge clock)' waits 1ns before assigning values (e.g., 'state &lt;= ¬†#1 ¬†next_state').¬†
  href="http://www.asic-world.com/tidbits/verilog_fsm.html"
   
tags: verilog engineering hardware-dev usf usf-csd electronics
  time="2011-03-09T03:03:31Z" 

================================================================================
College of Engineering Poster Printing Services
href="http://www.eng.usf.edu/posters/"  
tags: usf
time="2011-03-09T02:07:39Z" 

================================================================================
OpenCores
  Community for development of open-source digital hardware IP cores.
href="http://opencores.org/"  
tags: engineering electronics hardware-dev
  time="2011-03-09T02:00:45Z" 

================================================================================
PS/2 interface :: Overview :: OpenCores
  verilog ps/2 driver
href="http://opencores.org/project,ps2"  
tags: usf usf-csd
time="2011-03-09T01:57:00Z" 

================================================================================
Logisim
  Logisim is an educational tool for designing and simulating digital logic circuits. Beats the hell out of Digital Works.
href="http://ozark.hendrix.edu/~burch/logisim/" 
tags: circuits electronics engineering pedagogy
  time="2011-02-23T09:10:15Z" 

================================================================================
Command Line Gmail Using msmtp/mailx
  Send mail and attachments via heirloom-mailx or nail.
href="http://klenwell.com/is/UbuntuCommandLineGmail" 
tags: bash linux
time="2011-02-23T01:08:10Z" 

================================================================================
Google Prediction API
  The API accesses Google's machine learning algorithms to analyze your historic data and predict likely future outcomes. Recommendation systems¬† Spam detection Document and email classification Churn analysis Language identification
href="https://developers.google.com/prediction/" 
tags: google ai machine-learning data-mining
  time="2011-02-23T00:55:56Z" 

================================================================================
StackExchange 
href="http://stackexchange.com/"  
tags: mega-search-engine
time="2011-02-22T22:41:53Z" 

================================================================================
Search Disqus comments using Google | Whole Map
href="http://wholemap.com/blog/search-comments-on-disqus"
tags: mega-search-engine
  time="2011-02-22T22:41:28Z" 

================================================================================
Quora 
href="http://www.quora.com/"  
tags: mega-search-engine
time="2011-02-22T22:41:05Z" 

================================================================================
Brewer's CAP (Consistency, Availability, Partition Tolerance) Theorem
  &quot;whilst addressing the problems of scale might be an architectural concern, the initial discussions are not. They are business decisions.&quot;
href="http://www.julianbrowne.com/article/viewer/brewers-cap-theorem"
tags: web programming
  time="2011-02-21T04:58:25Z" 

================================================================================
Khan Academy
  free, open source, video tutorials for math, science, statistics.¬†
href="http://www.khanacademy.org/"  
tags: learning mathematics
time="2011-02-14T01:46:34Z" 

================================================================================
What should a developer know before building a public web site?
href="http://stackoverflow.com/questions/72394/what-should-a-developer-know-before-building-a-public-web-site"
tags: seo programming web security
  time="2011-02-11T13:36:36Z" 

================================================================================
Does the order of keywords matter in a page title?
  keyword _order_¬†matters.¬†putting important keywords closer to the beginning of a title improves SEO.
href="http://webmasters.stackexchange.com/questions/6556/does-the-order-of-keywords-matter-in-a-page-title"
tags: seo
  time="2011-02-11T13:10:29Z" 

================================================================================
Weierstrass functions
  Very useful in EE for simulating noise on circuits. Famous for being continuous everywhere, but differentiable &quot;nowhere&quot;. As the graph is zoomed, it does not become smooth (or linear) as would a differentiable function.
  href="http://www.math.washington.edu/~conroy/general/weierstrass/weier.htm"
   
tags: mathematics engineering electronics
  time="2011-02-05T06:23:54Z" 

================================================================================
Investing Consultant Research 
href="http://www.investingconsultantresearch.com/" 
tags: blog finance
time="2011-02-01T23:44:57Z" 

================================================================================
The Markets Are Open 
href="http://themarketsareopen.blogspot.com/" 
tags: blog finance
time="2011-02-01T18:48:14Z" 

================================================================================
BoxCar2D: About
  The design of the chromosome is probably the most important step in making a successful genetic algorithm.At the end of each generation, pairs of parents are selected to produce the next generation.¬†
href="http://www.boxcar2d.com/about.html" 
tags: compsci algorithms data-mining
  time="2011-02-01T05:59:50Z" 

================================================================================
orgtheory.net
  organization theory http://orgtheory.wordpress.com/
href="http://orgtheory.net/"  
tags: blog organization-theory economics
  time="2011-01-20T08:18:24Z" 

================================================================================
http://timharford.com/2016/10/theres-magic-in-mess-why-you-should-embrace-a-disorderly-desk/
> Categorising documents of any kind is harder than it seems. ... Jorge Luis
> Borges once told of a fabled Chinese encyclopaedia, the “Celestial Emporium of
> Benevolent Knowledge”, which organised animals into categories such as: a)
> belonging to the emperor, c) tame, d) sucking pigs, f) fabulous, h) included
> in the present classification, and m) having just broken the water pitcher.

================================================================================
UNHOSTED - Freedom from web 2.0's monopoly platforms
href="http://www.unhosted.org/"  
tags: privacy web programming distributed-systems decentralization
  time="2011-01-20T02:49:27Z" 

================================================================================
What is your most productive shortcut with Vim?
href="http://stackoverflow.com/questions/1218390/what-is-your-most-productive-shortcut-with-vim/"
tags: vim programming
  time="2011-01-19T03:45:12Z" 

================================================================================
How to Track Ecommerce Transactions with Google Analytics
href="http://blogs.sitepoint.com/2011/01/18/track-ecommerce-transactions-google-analytics-reports/"
tags: ecommerce google webanalytics
  time="2011-01-19T03:33:26Z" 

================================================================================
Research is communication
  Structure - Abstract (4 sentences) -¬†Introduction (1 page) - The problem (1 page) - My idea (2 pages) - The details (5 pages) - Related work (1-2 pages) - Conclusions and further work (0.5 pages)¬†¬† Abstract: Four sentences [Kent Beck] 1. State the problem 2. Say why it's an interesting problem 3. Say what your solution achieves 4. Say what follows from your solution
  href="http://research.microsoft.com/en-us/um/people/simonpj/papers/giving-a-talk/writing-a-paper-slides.pdf"
   
tags: research engineering technical-writing filetype:pdf media:document
  time="2011-01-17T08:40:52Z" 

================================================================================
Search engine gaming
  Human-readable paragraphs based on your keywords. Link a couple of times naturally to his site.Change description (automatically) every X number of page loads or Y number of weeks, whichever comes first.Do *not* have him do the same thing for you. Do this for him for ~6 months, then take it off of your site for a while and then have him do the same for you. You do *not* want to simply cross link.Content and context is important. You want the SE's to associate the link with the text around it.Doing this with a few friends (or a network of your own sites) can be effective if you don't tip the scale to spam. Keep it interesting for humans - measure the human CTR on the links, remove-low preforming paragraphs and add new ones in their place to refine the process. This is not only valuable for your community but this keeps the white hat on and Google happy. You also want a good human CTR, e.g. 1000 clicks for every auto-change.
href="http://www.reddit.com/r/IAmA/comments/ev2zb/i_run_thathighcom_and_it_pays_my_rent_in_san/c1b7lp4"
tags: seo
  time="2011-01-12T23:30:23Z" 

================================================================================
Google Body - Google Labs 
href="http://bodybrowser.googlelabs.com/" 
tags: webgl google
time="2011-01-11T08:24:18Z" 

================================================================================
Learning WebGL 
href="http://learningwebgl.com/"  
tags: webgl programming
time="2011-01-11T08:19:49Z" 

================================================================================
Google Fusion Tables
  Visualize and publish your data as maps, timelines and charts¬† Host your data tables online¬† Combine data from multiple people¬†
href="http://www.google.com/fusiontables" 
tags: google tools statistics
  time="2011-01-11T04:21:26Z" 

================================================================================
Data Liberation
  import/export data from any Google product.
href="http://www.dataliberation.org/"  
tags: google programming
time="2011-01-11T04:09:37Z" 

================================================================================
Macro Man 
href="http://macro-man.blogspot.com/"  
tags: blog finance forex
time="2011-01-11T02:19:20Z" 

================================================================================
Climate Audit 
href="http://climateaudit.org/"  
tags: science politics agw
time="2011-01-11T01:50:50Z" 

================================================================================
Charlie Rose - Janet Napolitano, Secretary, Department of Homeland Security
  &quot;I think the tighter we get on aviation, we have to also be thinking now about going on to mass transit or to train or maritime. &quot;
href="http://www.charlierose.com/view/interview/11304"
tags: politics police-state tsa
  time="2011-01-11T01:32:06Z" 

================================================================================
Full-Body Scan Technology Deployed In Street-Roving Vans
  &quot;While the biggest buyer of AS&amp;E‚Äôs machines over the last seven years has been the Department of Defense operations in Afghanistan and Iraq, Reiss says law enforcement agencies have also deployed the vans to search for vehicle-based bombs in the U.S.&quot;
href="http://blogs.forbes.com/andygreenberg/2010/08/24/full-body-scan-technology-deployed-in-street-roving-vans/"
tags: politics police-state tsa
  time="2011-01-11T01:02:42Z" 

================================================================================
EDITORIAL: TSA comes to your bus stop - Washington Times
  Washington's Metro Transit Police Department (MTPD) on Thursday announced new search policies developed in conjunction with the Transportation Security Administration (TSA). &quot;It is important to know that implementation of random bag inspection is not a reaction to any specific threats toward the Metro system,&quot; MTPD Chief Michael A. Taborn said.
href="http://www.washingtontimes.com/news/2010/dec/17/tsa-comes-to-your-bus-stop/"
tags: politics police-state tsa
  time="2011-01-11T00:59:23Z" 


================================================================================
Spaced Repetition
https://ncase.me/remember/
tags: psychology neuroplasticity memory mnemonics anki spaced-repetition
.
SPACED REPETITION is essentially "flashcards" with an emphasis on:
    1. time
    2. connections/mnemonics
       - best practice: "small (atomic), connected, meaningful"
.
* "Mnemonic" comes from "Mnemosyne" Greek "goddess of Memory" (mother of the Muses, "goddesses of inspiration").
* Hermann Ebbinghaus: you forget most of what you learn in the first 24 hours, then – if you don’t practice recall – your remaining memories decay exponentially.
* Memory “rate of decay” slows down each time you actively recall it. (versus passively re-reading it)

================================================================================
Augmenting Long-term Memory
http://augmentingcognition.com/ltm.html
tags: psychology neuroplasticity memory mnemonics anki spaced-repetition
.
SYNTOPIC reading with Anki (grok an unfamiliar field/literature)
> Avoid orphan questions: questions too disconnected from your other interests lack the original motivating context.
> to really grok an unfamiliar field, you need to engage deeply with key papers – like the AlphaGo paper. What you get from deep engagement with important papers is more significant than any single fact or technique: you get a sense for what a powerful result in the field looks like. It helps you imbibe the healthiest norms and standards of the field. It helps you internalize how to ask good questions in the field, and how to put techniques together. You begin to understand what made something like AlphaGo a breakthrough – and also its limitations, and the sense in which it was really a natural evolution of the field. Such things aren't captured individually by any single Anki question. But they begin to be captured collectively by the questions one asks when engaged deeply enough with key papers.

================================================================================
AnkiWeb: Shared Decks
https://ankiweb.net/shared/decks/
tags: psychology neuroplasticity memory mnemonics anki spaced-repetition
☃ german deck: https://ankiweb.net/shared/info/785874566


================================================================================
Every 7.8μs your computer’s memory has a hiccup
https://blog.cloudflare.com/every-7-8us-your-computers-memory-has-a-hiccup/
tags: dram hardware engineering performance computer telemetry measurement intrumentation statistics
    Problem:    the data turns out to be very noisy. It's very hard to see if there is a noticeable delay related to the refresh cycles
    Solution:   Since we want to find a fixed-interval event, we can feed the data into the FFT (fast fourier transform) algorithm, which deciphers the underlying frequencies

================================================================================
Can You Build a Better Brain? - Newsweek
  neuroplasticity
href="http://www.newsweek.com/2011/01/03/can-you-build-a-better-brain.html"
tags: psychology
  time="2011-01-04T10:21:18Z" 

================================================================================
Christopher Hitchens
  on social revolutions: &quot;Right away, one's in an argument, and there‚Äôs really nothing to do with utopia at all. And then temporary expedients become dogma very quickly--especially if they seem to work.&quot;
  href="http://reason.com/archives/2001/11/01/free-radical"
   
tags: politics libertarian-role-models libertarianism
  time="2011-01-04T07:14:52Z" 

================================================================================
Vietnam's Mammoth Cavern - Photo Gallery - National Geographic
href="http://ngm.nationalgeographic.com/2011/01/largest-cave/peter-photography"
tags: travel photography
  time="2010-12-31T06:17:35Z" 

================================================================================
Panopticlick
  web browser identity, fingerprint.¬† browser configuration = web sites may be able to track you even if you disable cookies. see also:¬†http://hacks.mozilla.org/2010/03/privacy-related-changes-coming-to-css-vistited/
href="http://panopticlick.eff.org/"  
tags: privacy paranoia compsci statistics security fingerprinting webbrowser web
  time="2010-12-21T06:33:11Z" 

================================================================================
How Teen Experiences Affect Your Brain for Life - Newsweek
  teen years are a period of crucial brain development. mid-20s, or later, for a brain to become fully developed. one of the last parts to mature is the frontal lobe ... modulating reward, planning, impulsiveness, attention, acceptable social behavior former adolescent drinkers had ... very exaggerated responses to mild stress. kids who smoked pot before age 16 had more lifelong cognitive problems than those who started smoking after 16
href="http://www.newsweek.com/2010/12/16/the-kids-can-t-help-it.html"
tags: psychology
  time="2010-12-20T07:43:01Z" 

================================================================================
Google App Engine Pipeline API
  API for connecting complex, time-consuming workflows (including human tasks).¬†
  href="http://code.google.com/p/appengine-pipeline/" 
  
tags: google google-appengine programming project-management
  time="2010-12-20T06:09:29Z" 

================================================================================
Advancing in the Bash Shell
  bash history, bang bang !!, !$, :p
href="http://samrowe.com/wordpress/advancing-in-the-bash-shell/"
tags: bash linux
  time="2010-12-10T08:46:27Z" 

================================================================================
Google Public Data Explorer
  Visualize/animate public data over a timeline. based on gapminder.org.
  href="http://www.google.com/publicdata/home" 
  
tags: statistics information tools google data-mining
  time="2010-12-10T04:21:25Z" 

================================================================================
Authorize.Net .NET SDK for AIM - Authorize.Net Developer Community
href="http://community.developer.authorize.net/t5/The-Authorize-Net-Developer-Blog/The-Authorize-Net-NET-SDK-for-AIM/ba-p/7743"
tags: .net programming ecommerce sdk
  time="2010-12-07T19:51:10Z" 

================================================================================
Sua sponte: "on its own motion"
https://en.wikipedia.org/wiki/Sua_sponte
tags: concepts mental-model

================================================================================
Simpson's paradox
  &amp;quot;an apparent paradox in which a correlation (trend) present in different groups is reversed when the groups are combined.&amp;quot; Q: why should a story, not data, dictate choices? A: the story encodes the causal relationships among the variables. Once we extract these relationships, we can represent them in a Causal Bayesian Network graph which we can test algorithmically. - Berkeley sex bias case - Kidney stone treatment
  href="http://en.wikipedia.org/wiki/Simpson_s_paradox"
   
tags: paradox psychology mathematics statistics concepts mental-model
  time="2010-11-30T05:00:20Z" 

================================================================================
DE(E)SU - Libert√© Linux
  secure, reliable, lightweight, and easy to use LiveUSB Linux distribution intended as a communication aid in hostile environments. installs as a regular directory on a USB/SD key, and after a single-click setup, boots on any desktop computer or laptop.
href="http://dee.su/liberte"  
tags: security paranoia privacy linux
  time="2010-11-28T19:14:07Z" 

================================================================================
Seeking Alpha: Stock Market News, Opinion &amp; Analysis, Investing Ideas
  search for &quot;oversold&quot; or &quot;Contrarian Ideas&quot;
href="http://seekingalpha.com/"  
tags: blog finance
time="2010-11-11T01:43:59Z" 

================================================================================
Procrastination, hyperbolic discounting
  Misconception: You procrastinate because you are lazy and can‚Äôt manage your time well. Truth: Procrastination is fueled by weakness in the face of impulse and a failure to think about thinking. Now-you must trick future-you into doing what is right for both parties. ...why you keep adding movies you will never watch to your growing collection of future rentals ... the same reason you believe you will eventually do what‚Äôs best for yourself in all the other parts of your life, but rarely do. present bias = being unable to grasp that what you want will change over time hyperbolic discounting = the tendency to get more rational when you are forced to wait
href="http://youarenotsosmart.com/2010/10/27/procrastination/"
tags: psychology project-management
  time="2010-10-28T11:47:52Z" 

================================================================================
Firesheep ... HTTP Session Hijacking
  Some sites support full encryption everywhere, but don‚Äôt implement it properly by failing to set the ‚ÄúSecure‚Äù flag on authentication cookies, negating most of the benefits ... any time you type the URL ... without explicitly typing https:// ... you will inadvertently leak your cookies with that first request, prior to being redirected to the HTTPS page. ... You can‚Äôt simply avoid visiting the sites that are being attacked here. There‚Äôs an enormous amount of mixed content on the web today, such as the Facebook ‚ÄúLike‚Äù button... ... People forget things. It‚Äôs easy to be logged in to many of these services, sleep your laptop, and wake it up somewhere where it will instantly ... start spewing your cookies over the air. ... A password-protected (WPA2) wireless network or even a wired network just requires that attackers perform one more step ... ARP poisoning or DNS spoofing, neither of which are difficult to carry out. Go and download Cain &amp; Abel and try it out on your network...
href="http://codebutler.com/firesheep-a-day-later" 
tags: privacy paranoia security
  time="2010-10-26T21:49:51Z" 

================================================================================
7 tricks to simplify your programs with LINQ
  int[] c = Enumerable.Range(0, 10).Select(i =&gt; 100 + 10 * i).ToArray(); var randomSeq = Enumerable.Repeat(0, N).Select(i =&gt; rand.Next()); IEnumerable&lt;object&gt; objEnumerable = strEnumerable.Cast&lt;object&gt;(); You could construct an array of length 1, but I prefer the LINQ Repeat operator: IEnumerable&lt;int&gt; seq = Enumerable.Repeat(myValue, 1); Iterate over all subsets of a sequence...
href="http://igoro.com/archive/7-tricks-to-simplify-your-programs-with-linq/"
tags: c# linq .net programming
  time="2010-10-26T03:01:04Z" 

================================================================================
Less Wrong 
href="http://lesswrong.com/"  
tags: blog economics
time="2010-10-26T02:36:13Z" 

================================================================================
Overcoming Bias 
href="http://www.overcomingbias.com/"  
tags: blog economics
time="2010-10-26T02:35:20Z" 

================================================================================
SEO Is Mostly Quack Science
  &quot;Non-brain-damaged web design and link building are 100% of SEO. Anyone who tells you different is a quack that is only trying to separate you from your money.&quot;
href="http://teddziuba.com/2010/06/seo-is-mostly-quack-science.html"
tags: seo
  time="2010-10-25T00:03:02Z" 

================================================================================
Vi Cheat Sheet 
href="http://www.lagmonster.org/docs/vi.html" 
tags: vim
time="2010-10-24T07:14:16Z" 

================================================================================
Power Posing: Fake It Until You Make It
  holding one's body in expansive, &quot;high-power&quot; poses for as little as two minutes stimulates higher levels of testosterone ... and lower levels of cortisol.
href="http://hbswk.hbs.edu/item/6461.html" 
tags: psychology
time="2010-10-13T18:28:09Z" 

================================================================================
Feds are monitoring and tracking redditors for their comments, or &quot;How I learned to STFU and love the police state&quot;.
href="http://www.reddit.com/r/Libertarian/comments/dot9b/feds_are_monitoring_and_tracking_redditors_for/"
tags: politics police-state
  time="2010-10-10T21:45:34Z" 

================================================================================
Redditor arrested a few months ago for filming the police. ... The video and audio was tampered with (erased) by the feds, but recovered with open source software
href="http://www.reddit.com/r/reddit.com/comments/dhf6y/the_redditor_arrested_a_few_months_ago_for/"
tags: police-state politics
  time="2010-10-10T21:44:34Z" 

================================================================================
Simulate a Windows Service using ASP.NET to run scheduled jobs
  A hack to use ASP.NET cache expiration to schedule a task.
href="http://www.codeproject.com/KB/aspnet/ASPNETService.aspx"
tags: asp.net programming
  time="2010-10-04T05:28:31Z" 

================================================================================
Mathematics formula sheet 
href="http://www.tug.org/texshowcase/cheat.pdf" 
tags: mathematics filetype:pdf media:document
  time="2010-10-04T03:42:15Z" 

================================================================================
IEEE Computer Society Style Guide: References, Citations
href="http://www.computer.org/portal/web/publications/style_refs"
tags: technical-writing
  time="2010-10-03T18:51:35Z" 

================================================================================
Basic Concepts of Mathematics - by Elias Zakon
  This book gives students the skills they need to succeed in the first courses in Real Analysis (it is designed specifically to prepare students for the author's Mathematical Analysis I and Mathematical Analysis II) and Abstract Algebra/Modern Algebra. Students who plan to advance to upper-level classes in computer science (discrete structures, algorithms, computability, automata theory, ...), economics, or electrical and computer engineering (signal and image processing, AI, circuit design, ...) will benefit from mastering the material in this text.
href="http://www.trillia.com/zakon1.html" 
tags: mathematics books
  time="2010-09-19T22:27:42Z" 

================================================================================
Anonymous Pro 
href="http://www.ms-studio.com/FontSales/anonymouspro.html"
tags: programming font
  time="2010-09-02T04:13:13Z" 

================================================================================
How to Think (Technology Review: Blogs: Ed Boyden's blog)
  &quot;1. Synthesize new ideas constantly. Never read passively. Annotate, model, think, and synthesize while you read...&quot; &quot;9. Document everything obsessively. If you don't record it, it may never have an impact on the world. Much of creativity is learning how to see things properly...&quot; &quot;time management... logarithmic time planning, in which events that are close at hand are scheduled with finer resolution than events that are far off.&quot;
href="http://www.technologyreview.com/blog/boyden/21925/"
tags: learning psychology
  time="2010-09-01T00:13:29Z" 

================================================================================
Regexes For Life 
href="http://rxfl.wordpress.com/"  
tags: blog
time="2010-08-31T01:49:36Z" 

================================================================================
&gt;&gt; RIGHTSHIFT 
href="http://rightshift.info/"  
tags: blog
time="2010-08-31T01:33:26Z" 

================================================================================
Moserware 
href="http://www.moserware.com/"  
tags: blog
time="2010-08-31T01:32:17Z" 

================================================================================
Miguel de Icaza 
href="http://tirania.org/blog/"  
tags: blog
time="2010-08-31T01:20:33Z" 

================================================================================
Unqualified Reservations 
href="http://unqualified-reservations.blogspot.com/" 
tags: blog
time="2010-08-31T01:20:07Z" 

================================================================================
Labnotes 
  href="http://labnotes.org/"   tags: blog
  time="2010-08-31T00:56:40Z" 

================================================================================
Chad Perrin: SOB 
href="http://sob.apotheon.org/"  
tags: blog
time="2010-08-31T00:48:41Z" 

================================================================================
Parosproxy.org - Web Application Security
  &quot;Through Paros's proxy nature, all HTTP and HTTPS data between server and client, including cookies and form fields, can be intercepted and modified.&quot;
href="http://www.parosproxy.org/"  
tags: paranoia security
time="2010-08-30T23:31:52Z" 

================================================================================
RetailMeNot.com - Coupon codes and discounts for 65,000 online stores!
href="http://www.retailmenot.com/"  
tags: haggle shopping
time="2010-08-27T07:18:24Z" 

================================================================================
Restaurant.com Coupon Codes - all coupons, discounts and promo codes ...
  restaurant coupons
href="http://www.retailmenot.com/view/restaurant.com"
tags: haggle food
  time="2010-08-27T07:17:04Z" 

================================================================================
Really Really Free Market
  also: http://www.reallyreallyfree.org/ &quot;The NYC Really Really Free Market happens every last Sunday of every month! Located @ 55 Washington Square South at the Judson Memorial Church.&quot; http://www.facebook.com/pages/New-York-NY/Really-Really-Free-Market-NYC/288012211374
href="http://en.wikipedia.org/wiki/Really_Really_Free_Market"
tags: haggle shopping freeganism barter-economy
  time="2010-08-27T06:20:05Z" 

================================================================================
Second-order simulacra
  A system whose legitimacy is implied by its complexity. E.g., psychology/psychoanalysis, alchemy, astrology, chiropractic are presumed valuable because they are complicated and have experts. The foundation of the system is not questioned because people are too busy debating the higher-order results of the system.
href="http://en.wikipedia.org/wiki/Second-order_simulacra"
tags: concepts psychology mental-model
  time="2010-08-23T06:16:25Z" 

================================================================================
Blue Brain Project
attempt to reverse-engineer the mammalian brain, in order to understand brain function and dysfunction through detailed simulations.
https://www.epfl.ch/research/domains/bluebrain/
tags: ai psychology

================================================================================
Antarctic Peninsula
  vacation to the Antarctic Peninsula in the Summer of 2008-9
href="http://antarctic.fury.com/"  
tags: travel
time="2010-08-09T06:54:31Z" 

================================================================================
The Cognitive Benefits of Nature : The Frontal Cortex
  &quot;interacting with nature ... improves cognitive function&quot;
href="http://scienceblogs.com/cortex/2008/11/the_cognitive_benefits_of_natu.php"
tags: psychology health
  time="2010-07-15T00:39:17Z" 

================================================================================
App Inventor for Android 
href="http://appinventor.googlelabs.com/about/" 
tags: android programming
  time="2010-07-12T16:23:01Z" 

================================================================================
As a 20-year-old female, I spent 4 months wandering through Indonesia ...
"friendly and safe people, perfect blue-green water, rainforests and a dirth of tourists".
"Bahasa Indonesia is also one of the easiest languages in the world".
Gear: http://www.reddit.com/r/IAmA/comments/cg60e/as_a_20yearold_female_i_spent_4_months_wandering/c0scahg &quot;STAY AWAY FROM KUTA. If you must go, just visit and then leave.&quot;. Cobra blood.
href="http://www.reddit.com/r/IAmA/comments/cg60e/as_a_20yearold_female_i_spent_4_months_wandering/"
tags: travel

================================================================================
Lending Club Review 
href="http://www.debtkid.com/lendingclub-overview" 
tags: investment finance
  time="2010-06-25T06:17:09Z" 

================================================================================
John Mackey - The New Yorker
  CEO of Whole Foods.
  href="http://www.newyorker.com/reporting/2010/01/04/100104fa_fact_paumgarten"
   
tags: libertarian-role-models entrepreneurs
  time="2010-06-25T06:03:27Z" 

================================================================================
Instant Verify Identity Verification - LexisNexis
  FraudPoint and Instant Verify make it very easy to go from an email address, name, basic but not identifiable information to being able to see what their SSN is.
href="http://www.lexisnexis.com/risk/solutions/instant-identity-verification.aspx"
tags: paranoia privacy
  time="2010-06-25T02:23:07Z" 

================================================================================
FraudPoint Fraud Prevention Solution - LexisNexis
  FraudPoint and Instant Verify make it very easy to go from an email address, name, basic but not identifiable information to being able to see what their SSN is.
href="http://www.lexisnexis.com/risk/solutions/fraudpoint-fraud-prevention.aspx"
tags: paranoia privacy
  time="2010-06-25T02:23:03Z" 

================================================================================
Lithium: Could It Become the Hottest Commodity of All?
  http://www.moneyweek.com/investments/commodities/two-ways-to-play-the-lithium-boom.aspx Sociedad Quimica y Minera NYSE:SQM (ADR) http://www.todaysfinancialnews.com/investment-strategies/lithium-the-commodity-with-a-profitable-future-7284.html JOHNSON CONTROL IND. [JCI]. &quot;building one of the largest lithium battery plants in the u.s.&quot;
href="http://www.energyinvestmentstrategies.com/2008/02/02/lithium-could-it-become-the-hottest-commodity-of-all/"
tags: stock-picks finance
  time="2010-06-09T22:39:41Z" 

================================================================================
Al Gore, Kleiner Perkins, venture capital
  10 of Kleiner's &quot;green&quot; investment picks: http://money.cnn.com/galleries/2007/fortune/0711/gallery.kleiner_gore.fortune/index.html Silver Spring Networks: http://www.telegraph.co.uk/earth/energy/6491195/Al-Gore-could-become-worlds-first-carbon-billionaire.html
href="http://money.cnn.com/2007/11/11/news/newsmakers/gore_kleiner.fortune/index.htm"
tags: stock-picks finance
  time="2010-06-09T02:02:48Z" 

================================================================================
Getting the most out of your Android phone
href="http://www.reddit.com/r/Android/comments/ccuxg/andreddit_lets_collaborate_to_make_a_getting_the/"
tags: android
  time="2010-06-09T00:30:17Z" 

================================================================================
Kids for cash scandal
  transcript: http://www.reddit.com/r/politics/comments/c3nmv/two_astoundingly_corrupt_pennsylvania_judges_who/c0pxqs3
href="http://en.wikipedia.org/wiki/Kids_for_cash_scandal"
tags: corruption politics
  time="2010-05-13T23:19:22Z" 

================================================================================
Motley Fool: Rick Aristotle Munarriz's Bio and Archive
href="http://www.fool.com/about/staff/rickaristotlemunarriz/author.htm"
tags: blog finance
  time="2010-05-10T18:55:56Z" 

================================================================================
Nootropic
  smart drugs, memory enhancers, and cognitive enhancers: drugs, supplements, nutraceuticals, and functional foods that are purported to improve mental functions.
href="http://en.wikipedia.org/wiki/Nootropic" 
tags: psychology learning physiology
time="2010-05-07T21:33:38Z" 

================================================================================
FRPAX Franklin PA Tax-Free Income A
href="http://quote.morningstar.com/fund/f.aspx?t=FRPAX"
tags: stock-picks finance
  time="2010-05-01T01:38:56Z" 

================================================================================
Southern Company SO 
href="http://quote.morningstar.com/stock/s.aspx?t=SO"
tags: stock-picks finance
  time="2010-05-01T01:38:18Z" 

================================================================================
Fairholme FAIRX 
href="http://quote.morningstar.com/fund/f.aspx?t=FAIRX"
tags: stock-picks finance
  time="2010-05-01T01:37:45Z" 

================================================================================
iSendr - On Demand P2P File Transfers
href="http://www.isendr.com/"  
tags: tools
time="2010-04-23T17:17:25Z" 

================================================================================
FilesOverMiles: send large files directly between computers for free
  p2p file-sharing.
href="http://www.filesovermiles.com/"  
tags: tools
time="2010-04-23T17:16:53Z" 

================================================================================
Vice Guide to North Korea | VBS.TV
href="http://www.vbs.tv/watch/the-vice-guide-to-travel/vice-guide-to-north-korea-1-of-3"
tags: politics
  time="2010-04-18T22:40:10Z" 

================================================================================
Forex Trading Training | Forex Buy Sell Signals | Forex Market Analysis
href="http://www.forexoma.com/"  
tags: forex finance
time="2010-04-06T20:21:03Z" 

================================================================================
Confessions of a Car Salesman
  selling rooms are bugged (phones have intercoms). Buyers are so eager to get out of their old car and into a new one, they overlook the true value of the trade-in. The dealership is well aware of this weakness and exploits it. see also: http://www.reddit.com/r/business/comments/blaki/11_of_the_top_car_deal_tricks_to_make_sure_they/
href="http://www.edmunds.com/advice/buying/articles/42962/article.html"
tags: negotiation thrift
  time="2010-04-02T17:39:07Z" 


================================================================================
How To Be Successful
tags: career startup entrepreneurship
https://blog.samaltman.com/how-to-be-successful
.
1. Compound yourself (LEVERAGE)
   Compounding is magic. Look for it everywhere. Exponential curves are the key to wealth generation.
2. Have almost too much self-belief
3. Learn to think independently
4. Get good at “sales”
   Show up in person whenever it’s important.
5. Make it easy to take risks
6. Focus
   Focus is a force multiplier on work.
11. Build a network
   Effective way to build a network is to help people as much as you can.
   Develop a reputation for really taking care of the people who work with you.
   Be overly generous with sharing the upside; it will come back to you 10x.

================================================================================
Don't Call Yourself A Programmer, And Other Career Advice
https://www.kalzumeus.com/2011/10/28/dont-call-yourself-a-programmer/
tags: negotiation business career compensation
- Don’t call yourself a programmer. Instead, describe how you increased revenues
  or reduced costs.
- Most jobs are never available publicly, just like most worthwhile candidates
  are not available publicly. Information travels at the speed of beer.
  Decisionmaker needs someone => personal network => introduction.
- Working at a startup, you tend to meet people doing startups.  Most of them
  will not be able to hire you in two years.
- Your most important professional skill is communication: The dominant quality
  which gets you jobs is the ability to give people the perception that you will
  create value.
- Programming skill is not what people actually optimize for, and modesty is
  against my interests.  If you ask me how good of a programmer I am I will
  describe how I programmed systems which helped millions of kids learn to read
  or which provably made companies millions.  The question of where I am on the
  bell curve matters to no one.
- Communication is a skill.  Practice it: you will get better.
    - Key sub-skill: quickly, concisely, and confidently explain to a non-expert
      how you create value. You should be able to explain what you do to
      a bright 8 year old, the CFO of your company, or a programmer in
      a different specialty, at the appropriate level of abstraction.
- Enterprise Sales is convincing a corporation to spend 6+ figures on a system
  which will improve their revenue or reduce costs.
    - Every job interview is Enterprise Sales.
    - Meetings with coworkers is Enterprise Sales (convince them to implement your suggestions).
    - Make a business case for a technological initiative.
- If you are part of a team effort, the right note to hit is “It was a privilege
  to assist my team by leading the effort on $X".

================================================================================
Salary Negotiation: Make More Money, Be More Valued
https://www.kalzumeus.com/2012/01/23/salary-negotiation/
tags: negotiation salary business hiring career game-theory compensation

- Negotiating never makes (worthwhile) offers worse.  This means you need what
  political scientists call a _commitment strategy_: you always, as a matter of
  policy, negotiate all offers. 
- "Competence Triggers": if you must judge someone’s skill based on a series of
  brief interactions, you’re going to pattern-match their behavior against other
  people who you like.  When people with hiring-authority think of winners, they
  think of people _like them_ who understand business. Therefore, the act of
  negotating signals competence.
- “Interesting” is a wonderful word: it is positive and non-commital at the same
  time.  If they tell you a number, tell them it is an “interesting” number, not
  a “wonderful” number.

================================================================================
How Not to Bomb Your Offer Negotiation
https://haseebq.com/my-ten-rules-for-negotiating-a-job-offer/
https://haseebq.com/how-not-to-bomb-your-offer-negotiation/
tags: negotiation salary business hiring career game-theory compensation

The ten rules of negotiating
    1. Get everything in writing (and write everything down)
        Send a follow-up e-mail confirming all of the details you discussed with your recruiter so you have a paper trail. “Just wanted to confirm I had all the details right.“
    2. Always keep the door open
    3. Information is power
    4. Always be unequivocally positive
        Your excitement is one of your most valuable assets in a negotiation. Despite whatever is happening in the negotiation, give the company the impression that 1) you still like the company, and that 2) you’re still excited to work there, even if the numbers or the money or the timing is not working out.
    5. Don’t be the decision maker
        "I’ll look over some of these details and discuss it with X. I’ll reach out to you if I have any questions."
    6. Have alternatives
    7. Proclaim reasons for everything
    8. Be motivated by more than just money
    9. Understand what they value
    10. Be winnable

A good negotiator is empathetic and collaborative. They don’t try to control you
or issue ultimatums. Rather, they try to think creatively about how to fulfill
both your and their needs.

Slicing up the cake
    good negotiators bend the rules. They question assumptions and ask unexpected
    questions. They dig to find the core what everyone values and looks for creative
    ways to widen the terrain of negotiation.
    While you were thinking about how to haggle over slices, I’m thinking about how
    to give both of us more than just half of a cake.

Phone vs Email
    Talking on the phone not only signals confidence, but more
    importantly, it allows you to build a strong relationship with your recruiter.
    The best deals get made between friends. It’s hard to make friends over e-mail.

Have Alternatives
    But what if you don’t manage to get any other offers? Does all the negotiating just go out the window?
    Not at all. What’s important here is not actually having other offers. 
    A negotiation needs stakes.
    BATNA (Best Alternative To a Negotiated Agreement).
    Your best alternative might be “interview at more companies” or “go to grad
    school” or “stay at your current job” or “go on sabbatical” ...
    Thus, you need to communicate your BATNA. (Note: whenever you signal your
    BATNA, you should also re-emphasize your interest in reaching an agreement).
    You should make your decision seem genuinely close for it to be a strong BATNA.

What a Job Negotiation Means to an Employer

    Now say you end up turning down their offer. They’ve spent over $24,000 just
    extending this single offer to you (to say nothing of opportunity costs), and
    now they’ll essentially have to start over from scratch.

    Understand that salary is only one part of the cost of employing you. An
    employer also has to pay for your benefits, your equipment, space, utilities,
    other random expenses, and employment taxes on top of all of that. Your
    actual salary often comprises less than 50% of the total cost of employing you.
    ref: http://web.mit.edu/e-club/hadzima/pdf/how-much-does-an-employee-cost.pdf

    (Which means they expect that your value to the company, in terms of the revenue you’ll generate, to be more than 2x your salary.)

    When you are agonizing over whether to ask for another few thousand dollars,
    what they’re doing is praying with bated breath that you’ll sign the offer.

    It’s your role that will determine your performance expectations, not how much
    you negotiated. Making 5k more or less in salary doesn’t matter at all. Your
    manager will literally just not care about this.

    How to Give the First Number
    If a company asks you “what are your salary expectations?” you might say:

    I don’t have any particular numbers in mind. I’m more interested in learning whether this will be a good mutual fit. If it is, I’m open to exploring any offer so long as it’s competitive.

    Q: Okay, look, you’re being difficult. Let’s not waste each other’s time. What’s an offer that you’d be willing to take?

    (This is a decision point. They’re trying to take away your negotiating power and pin you to a premature decision.
    But you can give a number here without actually giving a number.)

    A: Well, okay. I know that the average software engineer in Silicon Valley makes roughly 120K a year salary. So I think that’s a good place to start.

    (I didn’t actually answer the question “what’s an offer you’d be willing to take,” I merely anchored the conversation around the fulcrum of “the average software engineer salary.”
    So if you’re forced to give a number, do so by appealing to an objective metric, such as an industry average (or your current salary). And make it clear that you’re merely starting the negotiation there, not ending it.)

How to Ask for More
    First, reiterate your interest in the company.
        There are two choices here: you can say that you’re on the fence and that an
        improvement might convince you, or you can go stronger and say that you’re
        outright dissatisfied with the offer. Which approach you choose depends on
        how much leverage you have, how weak the offer is relative to your BATNA,
        and whether you have other offers (the weaker your
        negotiating position, generally the more tentative you should be).

    - Be unfailingly polite.
    - Stating a reason--any reason--makes your request feel human and important.
      Just saying “can you improve the salary?” sounds like you’re boringly
      motivated by money. But “I really want to buy a house within the next year;
      what can we do to improve the salary?” seems a lot more legitimate.

Equity Shenanigans
    Many companies will try to play mindgames with you when it comes to equity:
    - presenting the total value of the stock grant rather than the annualized
      value, despite the the stock not vesting evenly, or vesting over 5 years
      instead of the standard 4.
    - most egregious: “okay, we’re worth this much now, but at the rate we’re
      growing we’re going to be worth 10X that in a year.”
      - Why that's stupid: valuation is determined by investors, who already took
        the 10x growth rate into account.

The Path to Signing
    It’s not enough to just continually ask for stuff. Companies need to sense that
    you’re actually moving toward a final decision, and not just playing games with
    them.
    - Don’t go dark on people. Be open and communicative.
    - Be honest. You should protect information that might weaken your negotiating
      position, but you should be as communicative as possible about everything else
      (which is most things).
    - Be winnable. Give any company you’re talking to a clear path on how to win
      you. Be clear and unequivocal with your preferences and timeline.

Making the Final Decision
    1. Be clear about your deadline. ("weekend with the family")
       When you start negotiating you probably don’t have a deadline yet. But once you
       get into intermediary stages, you should set for yourself a deadline on which
       you’ll sign. It can be for an arbitrary reason (or no reason at all), but just
       pre-committing to a deadline will allow you to negotiate more clearly and
       powerfully.
    2. Assert your deadline continually.
       Companies should all be totally aware of when you’re going to make your
       decision. This will raise the stakes and galvanize negotiations as the
       deadline approaches.
    3. Use your final decision as your trump card.
       This deadline also lets you defer your decision while still improving
       offers. Your narrative should be “I want to see the strongest offer your
       company can muster. Then I will go into my cave, meditate for
       10 days, and when I emerge I will have decided in my heart which company
       to join.” This gives you enormous power to avoid any on-the-spot decision
       points or premature promises.

    Even if there’s only one company in the running, you should always always
    wait until the last day to sign your offer. Yes, even if you’re certain
    you’re going to sign and even if it’s your dream job. I’ve seen many
    scenarios in which offers spontaneously improved as deadlines approached, or
    a fallen player gets up and presents you the holy grail in the 11th hour.
    Either way, there’s no harm.

    Finally, your trump card. Save this for the very end. Your trump card is
    these words: “If you can do X, I will sign.” Note, this is NOT “If you give
    me X, the offer will be more compelling blah blah blah.” Fuck that. It’s
    time to make a promise.

================================================================================
BLACK FLAMINGO: im coco for some choco chips!
  Ingredients: 40 saltine crackers 1 cup of rolled oats 1/2 cup of applesauce 1/4 cup of vegetable oil 3/4 cup of hazelnut milk 1/4 cup of agave nectar 1 tsp of cinnamon 1/4 cup of stevia 1 tbs of corn starch 1 tbs pure cocoa powder 1/2 cup dark choc chips 1/4 cup earth balance Directions: 0. preheat oven to 350 deg 1. crush saltine crackers into fine pieces 2. mix in oats, applesauce, and the rest of the ingredients. 3. fold in the oil and milk until it becomes a dough 4. spread out in cooking tin 5. bake for 24 minutes
href="http://ablackflamingo.blogspot.com/2010/03/im-coco-for-some-choco-chips.html"
tags: recipes
  time="2010-03-31T20:44:57Z" 

================================================================================
Painless Functional Specifications - Part 2: What's a Spec? - Joel on Software
  Specs have a disclaimer, one author, scenarios, nongoals, an overview and a lot of details. It's ok to have open issues. Text for particular audiences go into side notes. Specs need to stay alive.
href="http://www.joelonsoftware.com/articles/fog0000000035.html"
tags: programming project-management
  time="2010-03-31T02:37:14Z" 

================================================================================
&quot;I can say with some authority that PeerGaurdian never worked.&quot;
  &quot;There were very specific criteria that needed to be met by the person. Mainly an ISP that would play ball, this was a habitual seeder, meaning we were able to obtain a small % of at least 500-1000 different titles from that very person, and they had to be sharing a certain number of specifc titles.&quot; &quot;For the longest time people couldn't figure out why the download would stop at 98% and never finish, but it was because they had just spent the time downloading a fake file. That never happens on NNTP. ... We can't see who is downloading a file from some NNTP server, the only thing we could ever do was issue DMCA notices to the server admins to remove files when we found them, but those files would only be gone for a few minutes before someone would put them right back on.&quot;
href="http://www.reddit.com/r/reddit.com/comments/9ubff/because_no_one_told_me_i_present_peerblock/c0ehd67"
tags: paranoia security privacy
  time="2010-03-31T00:31:43Z" 

================================================================================
Photoshop's CAF (content-aware fill) - unbelievable? Not quite.
  http://www.youtube.com/watch?v=NH0aEp1oDOI http://www.logarithmic.net/pfh/resynthesizer http://www.reddit.com/r/linux/comments/bipgn/photoshops_caf_contentaware_fill_unbelievable_not/
href="http://o3.tumblr.com/post/470608946/photoshops-caf-content-aware-fill-unbelievable"
tags: gimp graphic-design
  time="2010-03-26T20:55:52Z" 

================================================================================
Elance | Outsource to freelancers, professionals, experts
href="http://www.elance.com/"  
tags: freelancing contracting
time="2010-03-24T05:25:01Z" 

================================================================================
Guru.com ‚Äì Find Freelancers for Hire. Get Your Project Done.
href="http://www.guru.com/"  
tags: freelancing contracting
time="2010-03-24T05:24:36Z" 

================================================================================
odesk.com: Outsource to Freelancers, IT Companies, Programmers, Web Designers
href="http://www.odesk.com/"  
tags: contracting freelancing
time="2010-03-24T05:17:20Z" 

================================================================================
Rent A Coder: How Software Gets Done
href="http://www.rentacoder.com/"  
tags: freelancing contracting
time="2010-03-24T05:11:39Z" 

================================================================================
IamA Top Coder at Rentacoder.com 
href="http://www.reddit.com/r/iama/comments/a2485" 
tags: freelancing contracting
  time="2010-03-24T05:10:41Z" 

================================================================================
Irrational fears give nuclear power a bad name, says Oxford scientist
href="http://www.reddit.com/r/science/comments/ao6gl/irrational_fears_give_nuclear_power_a_bad_name/"
tags: science politics energy nuclear
  time="2010-03-20T01:02:04Z" 

================================================================================
JQuery Cycle Plugin
  slideshow plugin that supports many different types of transition effects.
href="http://malsup.com/jquery/cycle/"  
tags: jquery programming
time="2010-03-16T06:55:35Z" 

================================================================================
Directed Edge - Blog - On Building a Stupidly Fast Graph Database
href="http://blog.directededge.com/2009/02/27/on-building-a-stupidly-fast-graph-database/"
tags: compsci todo
  time="2010-03-14T01:32:05Z" 

================================================================================
Moserware: Wetware Refactorings 
href="http://www.moserware.com/2009/01/wetware-refactorings.html"
tags: todo learning psychology
  time="2010-03-14T01:26:26Z" 


================================================================================
20200208
PyRobot: open source robotics platform
https://www.pyrobot.org/
tags: diy-project electronics engineering programming facebook
getting a robot, current price points: https://news.ycombinator.com/item?id=22212035

================================================================================
20100313
en/MikroKopter - Wiki: MikroKopter.de
http://www.mikrokopter.de/ucwiki/en/MikroKopter
tags: diy-project electronics
HexaKopter 6-propeller helicopter. ~1200 euros.

================================================================================
A Visual Git Reference 
href="http://marklodato.github.com/visual-git-guide/"
tags: git dvcs programming
  time="2010-02-26T06:14:30Z" 

================================================================================
Git for Plan 9: git/fs
https://lobste.rs/s/bpzl12/git_fs_native_git_implementation_for_plan
https://bitbucket.org/oridb/git9
tags: git dvcs programming protocol
Plan 9 C implementation of git file formats and wire formats.

================================================================================
HashRocket MSA (Master Services Agreement) - Obie Fernandez: (MSA Series #3) Work Provisions
  &quot;I prefer so-called &quot;Time and Materials&quot; (T&amp;M) engagements, and with a good MSA you can usually fit your SOW onto one page.&quot; http://blog.obiefernandez.com/content/2008/09/master-services-agreement-part-1.html http://blog.obiefernandez.com/content/2008/10/msa-series-2-cooperation-and-reliance.html http://blog.obiefernandez.com/content/2008/12/msa-series-3-work-provisions.html
href="http://blog.obiefernandez.com/content/2008/12/msa-series-3-work-provisions.html"
tags: programming contracting
  time="2010-02-12T21:54:20Z" 

================================================================================
ASP.NET Chart Control - ScottGu's Blog
href="http://weblogs.asp.net/scottgu/archive/2008/11/24/new-asp-net-charting-control-lt-asp-chart-runat-quot-server-quot-gt.aspx"
tags: .net asp.net programming
  time="2010-02-12T21:50:45Z" 

================================================================================
Google Chart Tools API 
href="https://developers.google.com/chart/" 
tags: web programming google
  time="2010-02-12T21:49:18Z" 

================================================================================
Derek Powazek - Spammers, Evildoers, and Opportunists
  &quot;Search Engine Optimization is not a legitimate form of marketing. ... If someone charges you for SEO, you have been conned.&quot; &quot;The good advice is obvious, the rest doesn‚Äôt work.&quot; &quot;If [Google] determine that you‚Äôve been acting in bad faith (like hiding links or keywords or other deceptive practices) ... a temporary gain may result in a lifetime ban.&quot;
href="http://powazek.com/posts/2090"  
tags: seo
time="2010-02-10T21:24:07Z" 

================================================================================
Microsoft.VisualBasic.FileIO.TextFieldParser Class
  .NET CSV, tab delimited, and fixed-width text parser.
href="http://msdn.microsoft.com/en-us/library/microsoft.visualbasic.fileio.textfieldparser.aspx"
tags: programming .net
  time="2010-02-02T06:10:53Z" 

================================================================================
Are Machine-Learned Models Prone to Catastrophic Errors?
  Nassim Taleb divides phenomena into two classes: Mediocristan, consisting of phenomena that fit the bell curve model, such as games of chance, height and weight in humans, and so on. Here future observations can be predicted by extrapolating from variations in statistics based on past observation (for example, sample means and standard deviations). Extremistan, consisting of phenomena that don't fit the bell curve model, such as the search queries, the stock market, the length of wars, and so on. Sometimes such phenomena can sometimes be modeled using power laws or fractal distributions, and sometimes not. In many cases, the very notion of a standard deviation is meaningless. The current generation of machine learning algorithms can work well in Mediocristan but not in Extremistan. The very metrics these algorithms use, such as precision, recall, and root-mean square error (RMSE), make sense only in Mediocristan.
  href="http://anand.typepad.com/datawocky/2008/05/are-human-experts-less-prone-to-catastrophic-errors-than-machine-learned-models.html"
   
tags: compsci ai psychology machine-learning
  time="2010-02-02T05:07:06Z" 

================================================================================
optionshouse.com - Stock Option Trading Broker, Online Options Trading Platform ...
  A powerful, virtual platform to test your stock and options trades.
href="http://www.optionshouse.com/"  
tags: investment finance
time="2010-01-29T21:42:45Z" 

================================================================================
Making Evidyon
  Open source C++ (Visual Studio 2008) MMORPG. http://www.reddit.com/r/programming/comments/auhiv/evidyon_goes_open_source_get_a_free_copy_of/
href="http://unseenstudios.com/making-evidyon/" 
tags: game-dev programming
  time="2010-01-28T00:51:34Z" 

================================================================================
FINVIZ.com - Stock Screener
  technical indicators, insider trading.
href="http://finviz.com/"
tags: investment finance
  time="2010-01-19T23:04:06Z" 

================================================================================
Journey of an Absolute Rookie: Paintings and Sketches - ConceptArt.org
  daily practice turns a novice into very good artist in a matter of months.
href="http://www.conceptart.org/forums/showthread.php?t=870"
tags: learning art
  time="2010-01-14T17:27:23Z" 

================================================================================
The 31 Places to Go in 2010 - NYTimes.com
href="http://www.nytimes.com/2010/01/10/travel/10places.html"
tags: travel
  time="2010-01-12T18:41:20Z" 

================================================================================
Best of VIM Tips, gVIM's Key Features zzapper
href="http://rayninfo.co.uk/vimtips.html" 
tags: vim programming
time="2010-01-07T22:55:02Z" 

================================================================================
Don't vote. Play the lottery instead. - By Steven E. Landsburg
  &amp;quot;If Kerry (or Bush) has just a slight edge, so that each of your fellow voters has a 51 percent likelihood of voting for him, then your chance of casting the tiebreaker is about one in 10^1046‚Äîapproximately the same chance you have of winning the Powerball jackpot 128 times in a row.&amp;quot;
href="http://www.slate.com/id/2107240/"  
tags: politics voting
time="2009-12-06T20:49:59Z" 


================================================================================
What is the probability your vote will make a difference?
http://www.nber.org/papers/w15220.pdf
tags: politics statistics
Andrew Gelman, Nate Silver, Aaron Edlin
NBER Working Paper No. 15220
August 2009
NBER Program(s):Law and Economics, Public Economics
---
In a presidential election, the probability that your vote is decisive is equal
to the probability that your state is necessary for an electoral college win,
times the probability the vote in your state is tied in that event.
...
On average, a voter in America had a 1 in 60 million chance of being
decisive in the presidential election.
...
A probability of 1 in 10 million is tiny but, as discussed by Edlin, Gelman, and
Kaplan (2007), can provide a rational reason for voting; in this perspective,
a vote is like a lottery ticket with a 1 in 10 million chance of winning, but
the payoff is the chance to change national policy.


================================================================================
Eastern Eyes
  &quot;When you have to manufacture your own bricks in order to build your own house, you are living in a society that has no effective division of labor.&quot;
href="http://books.stpeter.im/rand/eyes.html" 
tags: politics
time="2009-12-03T07:48:14Z" 

================================================================================
.NET Debugging 101 with Tess Ferrandez
href="http://www.hanselminutes.com/default.aspx?showID=204"
tags: .net debug todo
  time="2009-11-22T20:57:29Z" 

================================================================================
The Dead Zone: The Implicit Marginal Tax Rate
  &quot;until you get past $40,000 a year, any raise might actually sink you deeper into poverty&quot;
href="http://mises.org/daily/3822"  
tags: economics politics todo
time="2009-11-22T20:55:53Z" 

================================================================================
The Henry Ford of Heart Surgery
  &quot;In India, a Factory Model for Hospitals Is Cutting Costs and Yielding Profits&quot;
href="http://online.wsj.com/article/SB125875892887958111.html"
tags: economics todo
  time="2009-11-22T20:50:34Z" 

================================================================================
Cheap Fusion Power: Dr. Bussard's talk at Google
  Dr. Robert Bussard http://en.wikipedia.org/wiki/Bussard ... http://www.talk-polywell.org/bb/index.php
href="http://video.google.com/videoplay?docid=1996321846673788606"
tags: todo science energy nuclear
  time="2009-11-16T03:43:42Z" 

================================================================================
The Eternal Value of Privacy - Bruce Schneier
  &quot;If I'm not doing anything wrong, then you have no cause to watch me.&quot; &quot;Because the government gets to define what's wrong, and they keep changing the definition.&quot; &quot;Because you might do something wrong with my information.&quot; ... The real choice is liberty versus control. ... Widespread police surveillance is the very definition of a police state.
href="http://www.wired.com/politics/security/commentary/securitymatters/2006/05/70886"
tags: politics privacy
  time="2009-11-16T00:03:02Z" 

================================================================================
20091018
1000mm Quad Copter Design - RC Groups
http://www.rcgroups.com/forums/showthread.php?t=768115
tags: engineering electronics diy-project

================================================================================
Vitamin D &quot;may vanquish cancer and heart disease ... autoimmune disease (rheumatoid arthritis, lupus), diminish the occurrence of diabetes, reduce obesity, treat multiple sclerosis, osteoporosis, Parkinson‚Äôs disease ... high blood pressure ... the comm...
  It‚Äôs difficult for most people to get optimal amounts of vitamin D. The diet, at best, will only provide a few hundred units of vitamin D. Milk is fortified with synthetic vitamin D2, which is not nearly as potent as natural D3, which is used in most dietary supplements. A glass of milk provides only 100 IU (2.5 micrograms). Fifteen minutes of sun exposure to 40-percent of the body is suggested daily for fair-skinned individuals. mortality rates for melanoma rose steeply after sunscreens came into common use, not before. Sunscreen lotion blocks the vitamin D-producing UV-B rays, while allowing the deeper-penetrating, cancer-causing UV-A rays to burn the skin. Many health food stores stock 1000 IU vitamin D pills. Most multivitamins provide no more than 400 IU .
href="http://www.lewrockwell.com/sardi/sardi70.html" 
tags: health
time="2009-10-08T21:33:15Z" 

================================================================================
Innovative Minds Don't Think Alike
  the &quot;curse of knowledge&quot;. &quot;It‚Äôs why engineers design products ultimately useful only to other engineers. It‚Äôs why managers have trouble convincing the rank and file to adopt new processes.&quot;
href="http://www.nytimes.com/2007/12/30/business/30know.html"
tags: learning engineering psychology business
  time="2009-10-07T22:20:27Z" 

================================================================================
A Stick Figure Guide to the Advanced Encryption Standard (AES)
  good explanation of AES Rijndael.
href="http://www.moserware.com/2009/09/stick-figure-guide-to-advanced.html"
tags: compsci
  time="2009-09-23T03:12:34Z" 

================================================================================
African American lives with middle class black families to study low test scores‚Äîis vilified for what he finds.
  &quot;Their project yielded an unexpected conclusion: It wasn't socioeconomics, school funding, or racism, that accounted for the students' poor academic performance; it was their own attitudes, and those of their parents.&quot;
href="http://www.reddit.com/r/Economics/comments/9mg0f/african_american_lives_with_middle_class_black/"
tags: politics
  time="2009-09-21T05:38:30Z" 

================================================================================
The RFP Database: government, corporate, and non-profit Requests for Proposals
  You can gain credits by uploading RFPs to the website. Where can I find more RFPs? One of the easiest ways to find RFPs is by logging in and using our internet rfp search area. Or do a web search for &quot;tampa procurement&quot; or &quot;rfp 2009 web&quot; or &quot;rfp 2009 programming&quot;.
href="http://www.rfpdb.com/"  
tags: rfp contracting
time="2009-09-15T21:51:20Z" 

================================================================================
littlefs: fail-safe filesystem designed for microcontrollers
https://github.com/ARMmbed/littlefs
tags: software programming embedded soc microcontrollers filesystem tools

================================================================================
Tahoe-LAFS: a secure, decentralized, fault-tolerant filesystem.
  The &quot;Tahoe&quot; project is a distributed filesystem, which safely stores files on multiple machines to protect against hardware failures. Cryptographic tools are used to ensure integrity and confidentiality, and a decentralized architecture minimizes single points of failure. http://allmydata.org/~warner/pycon-tahoe.html
href="http://allmydata.org/"  
tags: linux privacy security paranoia
  time="2009-09-09T16:04:25Z" 

================================================================================
Bulgarian Split Squat 
href="http://www.youtube.com/watch?v=q_Q8FKO7Ueg" 
tags: exercise health
time="2009-09-09T05:44:08Z" 

================================================================================
Elon Musk - Wikipedia, the free encyclopedia
  Zip2, PayPal, SpaceX, Tesla Motors, SolarCity. &quot;SpaceX was awarded a $1.6 billion NASA contract for 12 flights of their Falcon 9 rocket and Dragon spacecraft to the International Space Station, replacing the Space Shuttle after it retires in 2010.&quot;
href="http://en.wikipedia.org/wiki/Elon_Musk" 
tags: entrepreneurs
time="2009-09-01T03:25:01Z" 

================================================================================
Starlink satellite tracker
https://james.darpinian.com/satellites/
tags: space spacex science satellites starlink isp internet network
Tells you when to go outside to see satellites as they pass overhead.

================================================================================
How to Debug Bash Scripts 
href="http://aymanh.com/how-debug-bash-scripts" 
tags: bash programming linux
  time="2009-08-25T15:49:00Z" 

================================================================================
Code generation with X-Macros in C :: The Brush Blog
href="http://blog.brush.co.nz/2009/08/xmacros/" 
tags: c programming
time="2009-08-25T04:24:34Z" 

================================================================================
TTL demo applets 
href="http://tams-www.informatik.uni-hamburg.de/applets/hades/webdemos/toc.html"
tags: engineering circuits electronics
  time="2009-08-19T02:19:03Z" 

================================================================================
OASIS Login 
href="https://usfonline.admin.usf.edu/"  
tags: usf
time="2009-08-18T19:00:29Z" 

================================================================================
Class Schedule Search 
href="http://www.registrar.usf.edu/ssearch/search.php"
tags: usf
  time="2009-08-18T18:59:44Z" 

================================================================================
ESR 
href="http://esr.ibiblio.org/"  
tags: blog oss politics
time="2009-08-15T18:54:43Z" 

================================================================================
Seeking: The powerful and mysterious brain circuitry that makes us love Google ...
  Seeking ... is the mammalian motivational engine that each day gets us out of the bed. dopamine circuits &quot;promote states of eagerness and directed purpose&quot;. Panksepp says a way to drive animals into a frenzy is to give them only tiny bits of food.
href="http://www.slate.com/default.aspx?id=2224932" 
tags: psychology learning
time="2009-08-15T18:42:29Z" 

================================================================================
An Intuitive Explanation of Fourier Theory
href="http://enteos2.area.trieste.it/russo/LabInfoMM2005-2006/ProgrammaEMaterialeDidattico/daStudiare/009-FourierInSpace.html"
tags: mathematics todo
  time="2009-08-10T14:11:36Z" 

================================================================================
MakerBot Industries - Robots That Make Things.
  self-replicating machine. similar to RepRap.
href="http://www.makerbot.com/"  
tags: self-replication 3d_printing programming electronics engineering
  time="2009-07-09T13:15:54Z" 

================================================================================
Motion Mountain: The Free Physics Textbook
href="http://motionmountain.com/"  
tags: physics books science
time="2009-07-06T17:28:21Z" 

================================================================================
"Concerning the Soul", Hermann Hesse
http://jsomers.net/concerning_the_soul.pdf
tags: literature books
contemplation:
> At the moment when desire ceases and contemplation, pure seeing, and
> self-surrender begin, everything changes. Man ceases to be useful or
> dangerous, interesting or boring, genial or rude, strong or weak. He becomes
> nature, he becomes beautiful and remarkable as does everything that is an
> object of clear contemplation.

================================================================================
Cato Unbound: Beyond Folk Activism
  &quot;When we read in the evening paper that we‚Äôre footing the bill for another bailout, we react by complaining to our friends, suggesting alternatives, and trying to build coalitions for reform. This primal behavior is as good a guide for how to effectively reform modern political systems as our instinctive taste for sugar and fat is for how to eat nutritiously.&quot; ... &quot;Folk activism treats policies and institutions as the result of specific human intent. But policies are in large part an emergent behavior of institutions, and institutions are an emergent behavior of the global political ecosystem.&quot;
href="http://www.cato-unbound.org/2009/04/06/patri-friedman/beyond-folk-activism/"
tags: politics libertarianism
  time="2009-06-26T03:04:01Z" 

================================================================================
the business cycle is a result of (federal reserve) market manipulation
  &quot;These two questions, that is, why businessmen seem to make periodic, not continuous, but periodic clusters of errors, and the question of why the errors always seem especially bad in the higher order stages, are the two questions that every economist has to answer if he/she is going to explain what happens in economic recessions and why they occur.&quot;
href="http://www.reddit.com/r/Economics/comments/8uv04/peter_schiff_the_american_financial_system/c0ai9o1"
tags: politics economics
  time="2009-06-23T18:23:28Z" 

================================================================================
Pauls Online Math Notes
  calculus notes, formulae sheets.
href="http://tutorial.math.lamar.edu/cheat_table.aspx"
tags: mathematics pedagogy
  time="2009-06-20T06:59:27Z" 

================================================================================
Elementary Cellular Automata 
  href="http://www.gmilburn.ca/2008/12/02/elementary-cellular-automata/"
   
tags: cellular-automata mathematics todo compsci
  time="2009-06-20T03:18:50Z" 

================================================================================
PolyPage
  ease the process of showing multiple page states in html mock-ups.
href="http://code.new-bamboo.co.uk/polypage/" 
tags: jquery wireframe programming
  time="2009-06-18T22:48:29Z" 

================================================================================
An Illustrated Guide to SSH Agent Forwarding
  Password Authentication vs. Public Key Access. see also: http://www.reddit.com/r/linux/comments/8sjfv/if_you_use_ssh_to_do_remote_login_many_times_a/c0ab6js
href="http://unixwiz.net/techtips/ssh-agent-forwarding.html"
tags: security linux
  time="2009-06-15T20:06:10Z" 

================================================================================
I2P Anonymous Network - I2P
  http://www.reddit.com/r/technology/comments/8sdcn/i2p_074_anonymous_email_browsing_chatting/ &quot;TOR is about anonymity. It reroutes packets so the source is obscured - there is no security. ... high-traffic stuff like P2P is strongly discouraged. I2P is anonymous AND secure. It's encrypted and separate from the regular internet.&quot;
href="http://www.i2p2.de/"  
tags: paranoia security privacy
time="2009-06-14T17:49:11Z" 

================================================================================
Ask /r/linux: Anyone have devices increment their number after cloning ...
  fix device names, viz., 'eth2' -&gt; 'eth0'. /etc/udev/rules.d/70-persistent-net.rules
href="http://www.reddit.com/r/linux/comments/8h568/ask_rlinux_anyone_have_devices_increment_their/"
tags: linux
  time="2009-05-16T16:23:44Z" 

================================================================================
Robby on Rails : Installing Ruby on Rails and PostgreSQL on OS X
href="http://www.robbyonrails.com/articles/2008/01/22/installing-ruby-on-rails-and-postgresql-on-os-x-third-edition"
tags: rails osx programming
  time="2009-05-16T16:02:39Z" 

================================================================================
Currency Forex Trading, Interbank Forex Broker, Low Spreads
href="http://www.dukascopy.com/"  
tags: forex finance investment
time="2009-05-14T21:01:30Z" 

================================================================================
50 Most Beautiful Icon Sets Created in 2008 | Noupe
href="http://www.noupe.com/icons/50-most-beautiful-icon-sets-created-in-2008.html"
tags: icons
  time="2009-05-08T17:53:07Z" 

================================================================================
jQuery Corners
  easily create beautifully rounded corners
href="http://www.atblabs.com/jquery.corners.html" 
tags: jquery programming web
  time="2009-05-08T17:44:51Z" 

================================================================================
haml (and Sass) - &quot;an external DSL for XHTML/CSS&quot;
  rails template templating framework superior to erb. can be used with ASP.NET via nhaml http://andrewpeters.net/category/nhaml/ . Sass is a CSS templating framework.
href="http://haml.hamptoncatlin.com/"  
tags: rails programming asp.net html css markup web
  time="2009-05-08T03:01:40Z" 

================================================================================
Richard Branson - Wikipedia, the free encyclopedia
href="http://en.wikipedia.org/wiki/Richard_Branson" 
tags: entrepreneurs libertarian-role-models
  time="2009-04-30T10:30:58Z" 

================================================================================
John D. Carmack - Wikipedia, the free encyclopedia
href="http://en.wikipedia.org/wiki/John_D._Carmack" 
tags: entrepreneurs libertarian-role-models
  time="2009-04-30T10:29:36Z" 

================================================================================
Patri Friedman - Wikipedia, the free encyclopedia
href="http://en.wikipedia.org/wiki/Patri_Friedman" 
tags: entrepreneurs libertarian-role-models
  time="2009-04-30T10:28:34Z" 

================================================================================
Peter Thiel: Cato Unbound: The Education of a Libertarian
  &quot;the founding vision of PayPal centered on the creation of a new world currency, free from all government control and dilution ‚Äî the end of monetary sovereignty ... we must resist the temptation of technological utopianism ‚Äî the notion that technology has a momentum or will of its own, that it will guarantee a more free future, and therefore that we can ignore the terrible arc of the political in our world. ... we are in a deadly race between politics and technology.&quot;
  href="http://www.cato-unbound.org/2009/04/13/peter-thiel/the-education-of-a-libertarian/"
   
tags: politics libertarianism entrepreneurs libertarian-role-models
  time="2009-04-30T10:27:41Z" 

================================================================================
Writer2LaTeX
  covert OpenOffice.org OpenDocument (ODF) document format to latex (tex) format.
href="http://writer2latex.sourceforge.net/" 
tags: oss
time="2009-04-30T09:58:13Z" 

================================================================================
ViewSourceWith :: Firefox Add-ons
  source, js, css view
href="https://addons.mozilla.org/en-US/firefox/addon/394"
tags: todo
  time="2009-04-28T15:57:52Z" 

================================================================================
Why South Africa's Over the Rainbow - TIME
  &quot;History is full of revolutionaries who failed to make the switch. Most promised people's rule but, once in power, embraced a permanent state of revolution ‚Äî some, like Robert Mugabe and Hugo Ch√°vez, conjuring up fantastical foreign enemies to fight. (To those ranks, now add the leader of the influential ANC Youth League, Julius Malema, who told the East London rally that the young would &quot;never allow them to donate this country to Britain, to the hands of the colonizers.&quot;) To their people, this never-ending war is generally experienced as dictatorship. Too many liberation leaders leave office only when another revolutionary seizes power. ... Mobutu Sese Seko, ruler of Zaire for 32 years, who took the country as personal reward for &quot;liberating&quot; it. ... In India, the Gandhi family has towered over its democracy for 60 years. ... Henning Melber ... fought in Namibia against white rule. Watching his fellow liberators turn on their own people once the war was won...&quot;
href="http://www.time.com/time/world/article/0,8599,1890334,00.html"
tags: politics
  time="2009-04-22T03:25:12Z" 

================================================================================
All About Circuits : Free Electric Circuits Textbooks
href="http://www.allaboutcircuits.com/"  
tags: engineering circuits
time="2009-04-20T04:50:01Z" 

================================================================================
gspread: Google Spreadsheets Python API
https://github.com/burnash/gspread
tags: python library programming development google spreadsheet data data-science
http://tinaja.computer/2017/10/27/gspread.html

================================================================================
Official Google Webmaster Central Blog: How to start a multilingual site
  recommends putting the different language in the subdomain or subdirectory then set Webmaster Tools to reflect that so the appropriate content is served.
href="http://googlewebmastercentral.blogspot.com/2008/08/how-to-start-multilingual-site.html"
tags: seo programming
  time="2009-04-15T18:31:27Z" 

================================================================================
Official Google Webmaster Central Blog: Specify your canonical
  explanation of canonical URL. Google answers to reader comments are provided down the page, here: http://googlewebmastercentral.blogspot.com/2009/02/specify-your-canonical.html Also: --- Q: http://mydomain.com/en/ http://mydomain.com/es/ http://mydomain.com/fr/ ...the same structure with different language content. A: Each language should have a separate URL because the content is unique. We‚Äôd advise against equating different languages using either 301s or link rel=&quot;canonical&quot;. --- http://www.seobythesea.com/?p=946 Using UTF-8 on pages may also help search engines determine a page's language: &lt;meta http-equiv=&quot;Content-Type&quot; content=&quot;text/html; charset=utf-8&quot;&gt; --- also use the xml:lang or lang attributes on the &lt;html&gt; tag: http://www.w3schools.com/tags/ref_standardattributes.asp
href="http://googlewebmastercentral.blogspot.com/2009/02/specify-your-canonical.html"
tags: seo programming
  time="2009-04-14T20:27:38Z" 

================================================================================
It's 10PM: Do you know your RAID/BBU/consistency status? at time to bleed
  raid status check
href="http://timetobleed.com/its-10pm-do-you-know-your-raid-status/"
tags: todo linux
  time="2009-04-14T18:16:30Z" 

================================================================================
Tess Ferrandez blog: If broken it is, fix it you should
href="http://blogs.msdn.com/tess/"  
tags: microsoft blog debug programming asp.net .net
  time="2009-04-03T21:59:40Z" 

================================================================================
Tess Ferrandez blog: If broken it is, fix it you should
https://blogs.msdn.microsoft.com/tess/2006/04/12/asp-net-memory-if-your-application-is-in-production-then-why-is-debugtrue/
tags: microsoft deploy production debug programming asp.net .net
If debug="true"...
  - asp.net requests will not time out
  - creates one dll per aspx, asax, or ascx page and this dll is compiled in debug mode
  - In order to be able to step through code line by line the JITter can’t really optimize the code
  - Much more memory is used within the application at runtime
  - Scripts and images downloaded from the WebResources.axd handler are not cached
http://blogs.msdn.com/tess/archive/2006/04/13/575364.aspx
http://weblogs.asp.net/scottgu/archive/2006/04/11/Don_1920_t-run-production-ASP.NET-Applications-with-debug_3D001D20_true_1D20_-enabled.aspx

================================================================================
fix OS X keyboard shortcuts
  fix OS X PgUp/PgDn/Home/End behaviour
href="http://www.reddit.com/r/programming/comments/83jyb/proscons_of_using_a_mac_as_a_development/c085px4"
tags: todo osx
  time="2009-03-30T01:38:37Z" 

================================================================================
Things to do in Amsterdam‚Äîan unconventional guide
href="http://thomer.com/amsterdam/"  
tags: travel
time="2009-03-25T02:12:27Z" 

================================================================================
How to get a merchant account
  &quot;guide to obtaining a merchant account, from the cash-strapped start-up‚Äôs point of view&quot;. chargebacks, 3D-secure, AVS/CV2, PCI-DSS. Start the process early; Apply to several banks; Exaggerate your volumes (realistically); Know all about fraud; Be serious to ensure the bank feels you‚Äôre a trustworthy business; Read the fine print and negotiate the terms.
href="http://danieltenner.com/posts/0006-how-to-get-a-merchant-account.html"
tags: ecommerce business
  time="2009-03-24T23:10:36Z" 

================================================================================
The Three20 Project
  open source iphone library. table view, data source, text editor, URL request. http://joehewitt.com/post/the-three20-project/
href="http://github.com/joehewitt/three20/tree/master"
tags: programming iphone
  time="2009-03-24T14:47:40Z" 

================================================================================
Dot Net Perls - C# Problems and Solutions
href="http://dotnetperls.com/"  
tags: c# programming .net
time="2009-03-23T13:45:58Z" 

================================================================================
The Dangers of the Large Object Heap
  in .NET we can, for example, prevent memory from being recycled if we inadvertently hold references to objects that we are no longer using. Also, there is another serious memory problem in .NET that can happen out of the blue, especially if you are using large object arrays.
href="http://www.simple-talk.com/dotnet/.net-framework/the-dangers-of-the-large-object-heap/"
tags: todo .net programming
  time="2009-03-23T13:32:37Z" 

================================================================================
25 Great Calvin and Hobbes Strips.
href="http://progressiveboink.com/archive/calvinhobbes.htm"
tags: art todo
  time="2009-03-22T23:00:57Z" 

================================================================================
The Big Takeover: The global Economic Crisis Isn't About Money, It's About Power: How Wall Street Insiders Are Using The Bailout to Stage a Revolution
href="http://www.reddit.com/r/politics/comments/8619y/the_big_takeover_the_global_economic_crisis_isnt/"
tags: todo politics
  time="2009-03-22T22:59:31Z" 

================================================================================
"You and your Research", Richard Hamming
http://www.cs.virginia.edu/~robins/YouAndYourResearch.html
tags: compsci engineering learning mental-model
.
http://www.reddit.com/r/science/comments/862en/you_and_your_research_a_lecture_on_how_to_win_a/
> Be completely unafraid to utter whatever crazy idea you have at the moment and
> bounce it off someone--even if it turns out to be completely useless, which it
> usually will be, the kind of thoughts generated from such situations build
> over time to generate much greater work. If you think about something often
> and repeatedly approach it from different angles, you're far more likely to
> have that "lucky" strike of insight.

================================================================================
"Learning how to learn", Idries Shah
https://en.wikipedia.org/wiki/Learning_How_to_Learn
tags: learning pedagogy psychology

================================================================================
Is there really such a thing as &quot;random&quot;?
  very good discussion about randomness, determinism.
href="http://www.reddit.com/r/programming/comments/869bp/is_there_really_such_a_thing_as_random_ive_tried/"
tags: todo compsci philosophy
  time="2009-03-22T22:55:34Z" 

================================================================================
Computer science lectures on YouTube
href="http://www.reddit.com/r/programming/comments/8271w/computer_science_lecturer_offers_lectures_on/"
tags: compsci
  time="2009-03-17T21:19:05Z" 

================================================================================
Fabulous Adventures In Coding : Locks and exceptions do not mix
  &quot;the body of a lock should do as little as possible&quot;, contention, deadlock, threading, concurrency
href="http://blogs.msdn.com/ericlippert/archive/2009/03/06/locks-and-exceptions-do-not-mix.aspx"
tags: concurrency c# programming .net
  time="2009-03-16T18:12:35Z" 

================================================================================
Time Machine for every Unix out there - IMHO
href="http://blog.interlinked.org/tutorials/rsync_time_machine.html"
tags: linux
  time="2009-03-07T20:32:59Z" 

================================================================================
deterministic finite automaton (DFA) minimization
  algorithm explanation
href="http://useless-factor.blogspot.com/2009/02/dfa-minimization.html"
tags: compsci todo
  time="2009-02-19T21:38:14Z" 

================================================================================
Why you should never use rand()
  'tjw' comment: &quot;The proper alternative is to use the host operating system's random number generator. CryptGenRandom on Windows; /dev/urandom on everything else; fall back to rand() if all else fails.
href="http://www.reddit.com/r/programming/comments/7yjlc/why_you_should_never_use_rand_plus_alternative/"
tags: programming mathematics
  time="2009-02-19T21:12:34Z" 

================================================================================
How Not To Sort By Average Rating
  using statistics to make a better rating system
href="http://www.reddit.com/r/programming/comments/7ww4d/how_not_to_sort_by_average_rating/"
tags: programming mathematics
  time="2009-02-13T04:16:37Z" 

================================================================================
Pipl - People Search 
href="http://www.pipl.com/"  
tags: information tools privacy
time="2009-02-06T04:33:37Z" 

================================================================================
50 of the Best Ever Web Development, Design and Application Icon Sets
href="http://speckyboy.com/2009/02/02/50-of-the-best-ever-web-development-design-and-application-icon-sets/"
tags: icons
  time="2009-02-03T22:58:03Z" 

================================================================================
The Freenet Project - /index 
href="http://freenetproject.org/"  
tags: paranoia privacy security
time="2009-01-25T21:30:12Z" 

================================================================================
Kinsella: Intellectual Property Information
  ip resources, criticism
href="http://www.stephankinsella.com/ip/" 
tags: law economics ip
  time="2009-01-25T21:16:47Z" 

================================================================================
Can someone explain finger trees without referencing a functional programming language : programming
href="http://www.reddit.com/r/programming/comments/7s948/can_someone_explain_finger_trees_without/"
tags: compsci
  time="2009-01-25T21:13:54Z" 

================================================================================
Nolo: Law Books, Legal Forms and Legal Software
  href="http://nolo.com/"   tags: law
  time="2009-01-25T17:45:53Z" 

================================================================================
reAnimator: Regular Expression FSA Visualizer
  generates state diagrams for regular expressions.
href="http://osteele.com/tools/reanimator/" 
tags: compsci
time="2009-01-25T17:23:53Z" 

================================================================================
Are Frequent-Flier Miles About to Lose Value?
https://news.ycombinator.com/item?id=18752850
tags: life-hack credit-card finance airline
> To anyone who wishes to simply not have to deal with airline miles earned on credit cards ever again, here's a great option I found: if you have $100k+ across checking + investment accounts at Bank of America + Merrill Edge (their low-cost brokerage arm) you get...
> 1. 2.625% cash back on BofA's Premium Rewards/Travel Rewards credit card. No messing around with airline miles. Just buy whatever ticket you want. Or, you know, pocket the cash.
> 2. 5.25% cash back on BofA's Cash Rewards card for "online purchases," up to $2500 per quarter.
> 3. 100 free trades per month at Merrill Edge. You're not locked into any fund companies and can buy whatever you want. I buy-and-hold Vanguard ETFs.
> 4. Free BofA checking account, with unlimited ATM rebates + a free safe deposit box. It pays negligible interest, so you may want to use another checking option if you hold larger cash balances, but it's helpful to have around just in case you need a physical branch for anything.

================================================================================
"The SRE regular-expression notation", Olin Shivers, August 1998
http://www.ccs.neu.edu/home/shivers/papers/sre.txt
tags: compsci regex automata lisp emacs
.
Preamble: 100% and 80% solutions
  [rant on worse-is-better...]
.
SRE: regular-expression system used in scsh (Scheme shell).
- s-expression notation for encoding regular expressions. This notation has
  several advantages over the traditional string-based notation.
- Abstract data type (ADT) representation for regexp values.
  Traditional regular-expression systems compute regular expressions
  from run-time values using strings. This can be awkward. Scsh, instead,
  provides a separate data type for regexps, with a set of basic constructor
  and accessor functions; regular expressions can be dynamically computed
  and manipulated using these functions.
- Parsers and unparsers that can convert between external representations
  and the regexp ADT. The supported external representations are
      + Posix strings
      + S-expression notation
  Being able to convert regexps to Posix strings allows implementations
  to implement regexp matching using standard Posix C-based engines.
.
Examples
  ;;; Upper-case letter, lower-case vowel, or digit
    (| upper ("aeiou") digit)
  ;;; Various forms of non-vowel letter
    (- alpha ("aeiouAEIOU"))
    (w/nocase (- alpha ("aeiou")))
    (- (/"azAZ") ("aeiouAEIOU"))
Discussion and design notes
  S-expressions, are more verbose for simple forms, but paying this cost
  up-front gets you a general framework that is extremely extensible.
  SRE can be a very rich syntax.
  Compare:
      SRE:     (w/nocase (word+ (~ ("aeiou"))))
      POSIX:   "[[:<:]]([b-df-hj-np-tv-zB-DF-HJ-NP-TV-Z])+[[:>]]"


================================================================================
Monoids and Finger Trees: sequences, priority queues, search trees and priority search queues for free
  &quot;...using monoids for annotations. The standard textbook treatment of annotated search trees would be greatly improved in precision, pedagogy and generality by introducing this abstraction.&quot;
href="http://www.reddit.com/r/programming/comments/7r4bp/monoids_and_finger_trees_sequences_priority/"
tags: programming compsci
  time="2009-01-23T01:39:54Z" 

================================================================================
iPhone developer: App Store rewards &quot;crap&quot; apps
href="http://www.appleinsider.com/articles/09/01/22/iphone_developer_app_store_rewards_crap_apps.html"
tags: programming iphone
  time="2009-01-22T21:45:25Z" 

================================================================================
LDAP (AD, Active Directory) Browser/Editor Java Applet
  A Java applet that you can use to browse LDAP/AD.
href="http://www.mcs.anl.gov/~gawor/ldap/applet/applet.html"
tags: programming
  time="2009-01-13T15:46:11Z" 

================================================================================
22. U.S. Government Repressed Marijuana-Tumor Research | Project Censored
href="http://www.projectcensored.org/top-stories/articles/22-us-government-repressed-marijuana-tumor-research/"
tags: health politics
  time="2009-01-11T19:47:30Z" 

================================================================================
A More Efficient Method for Paging Through Large Result Sets
  Using ROWCOUNT to Optimize Paging for SQL Server 2000
href="http://www.4guysfromrolla.com/webtech/042606-1.shtml"
tags: programming
  time="2009-01-09T21:35:40Z" 

================================================================================
Red wine may ward off lung cancer: study | Health | Reuters
href="http://in.reuters.com/article/health/idINTRE4987L120081009"
tags: health
  time="2008-12-28T22:03:33Z" 

================================================================================
C++ and the linker | copton.net
Detailed analysis of C++ deficiencies. &quot;...I still believe that C++ is a dead end. The C heritage is a heavy burden. This article has lined out a mere few examples for this and on my blog there are some others (1, 2, 3, 4, 5). The fact that Bjarne Stroustrup et al. uncompromisingly pursued the design goals of efficiency and compatibility resulted in a language, which is very difficult to understand and use (6, 7, 8): Hundreds of special rules for special cases (9, 10, 11, 12, 13), language features that clash when used in particular combinations (14, 15), undefined and implementation-defined behavior everywhere (16, 17).&quot;
href="http://blog.copton.net/articles/linker/index.html"
tags: cpp linker programming
time="2008-12-16T03:55:48Z"

================================================================================
Austrian School of Economics: The Concise Encyclopedia of Economics | Library of Economics and Liberty
href="http://www.econlib.org/library/Enc/AustrianSchoolofEconomics.html"
tags: todo politics
  time="2008-12-05T09:48:03Z" 

================================================================================
Introduction &amp; overview to the Common Law subreddit : CommonLaw
href="http://www.reddit.com/r/CommonLaw/comments/7erku/introduction_overview_to_the_common_law_subreddit/"
tags: todo politics
  time="2008-12-05T09:44:32Z" 

================================================================================
On the bankruptcy of the US FEDERAL GOVERNMENT, 1933 : AmericanGovernment
href="http://www.reddit.com/r/AmericanGovernment/comments/7fpg2/on_the_bankruptcy_of_the_us_federal_government/"
tags: todo politics
  time="2008-12-05T09:43:45Z" 

================================================================================
Shorpy Photo Archive | History in HD
  high-quality prints of vintage ephemera.
  href="http://www.shorpy.com/"   tags: art
  time="2008-11-19T06:45:22Z" 

================================================================================
GovTrack.us: Tracking the U.S. Congress
href="http://www.govtrack.us/"  
tags: politics law
time="2008-11-10T05:18:53Z" 

================================================================================
Native C &quot;Hello World&quot; working in emulator | Hello Android
  &quot;Next, I'm going to try and get busybox up &amp; running so we can have access to exciting programs such as 'cp'&quot;
href="http://www.helloandroid.com/node/10" 
tags: programming android
  time="2008-11-10T02:09:03Z" 

================================================================================
Creative Loafing Tampa | Food &amp; Drink
href="http://tampa.creativeloafing.com/food" 
tags: food tampa
time="2008-10-09T01:55:58Z" 

================================================================================
Recovering Lawns, Failed States, and Reasons for Hope by William Norman Grigg
Somalia, anarchy
href="https://www.lewrockwell.com/2008/08/william-norman-grigg/failed-states-and-other-good-news/"
tags: politics
time="2008-09-14T20:11:23Z" 

================================================================================
Obie Fernandez: Do the Hustle
  consulting, Master Services Agreement + Statement of Work, &quot;work for hire&quot; (domain-specific) vs. non-exclusive, references/case study, branding, define your products (name your services, viz., &quot;3-2-1 Launch&quot;, &quot;Rescue Mission&quot;), define your clients (viz., minimum budget, requirements readiness, travel to you vs. travel to them), be easy to contact (need a phone number), track your leads (Highrise) required reading: _Predictably_Irrational_ [Dan Ariely], _Never_Eat_Alone_ [Ferrazzi and Tahl Raz], _Secrets_of_Power_Negotiating_ [Roger Dawson]
href="http://www.infoq.com/presentations/fernandez-sales-do-the-hustle"
tags: work contracting
  time="2008-09-14T18:49:57Z" 

================================================================================
Long-time nuclear waste warning messages
https://en.wikipedia.org/wiki/Long-time_nuclear_waste_warning_messages
tags: concepts history future weird semiotics iconography nuclear energy
> messages are intended to deter human intrusion at nuclear waste repositories
> in the far future, within or above the order of
> magnitude of 10,000 years. Nuclear semiotics ... Human Interference Task Force
> since 1981.
>
>   This place is a message... and part of a system of messages ...pay attention to it!
>   Sending this message was important to us. We considered ourselves to be a powerful culture.
>   This place is not a place of honor ... no highly esteemed deed is commemorated here... nothing valued is here.
>   What is here was dangerous and repulsive to us. This message is a warning about danger.
>   The danger is in a particular location... it increases towards a center... the center of danger is here... of a particular size and shape, and below us.
>   The danger is still present, in your time, as it was in ours.
>   The danger is to the body, and it can kill.
>   The form of the danger is an emanation of energy.
>   The danger is unleashed only if you substantially disturb this place physically. This place is best shunned and left uninhabited.


================================================================================
Regality theory and cultural selection theory
https://agner.org/cultsel/
tags: concepts history culture politics
> Regality theory: people show a preference for strong leadership in times of
> war or collective danger, but a preference for an egalitarian political system
> in times of peace and safety. ... A society in danger will develop in the
> direction called regal, which includes strong nationalism, discipline, strict
> religiosity, patriarchy, strict sexual morals, and perfectionist art.
> A society in peace will develop in the opposite direction called kungic, which
> includes egalitarianism and tolerance.

================================================================================
Doing Business In Japan
https://www.kalzumeus.com/2014/11/07/doing-business-in-japan/
tags: culture japan travel

================================================================================
Lesser Key of Solomon
https://en.wikipedia.org/wiki/Lesser_Key_of_Solomon
tags: concepts history occult
aka Clavicula Salomonis Regis
aka Lemegeton
17th-century grimoire on demonology
divided into 5 books: Ars Goetia, Ars Theurgia-Goetia, Ars Paulina, Ars Almadel, Ars Notoria.
72 Demons


================================================================================
Transitus Fluvii
https://en.wikipedia.org/wiki/Transitus_Fluvii
tags: concepts history occult
("passing through the river" in Latin), or Passage Du Fleuve (French).
occult alphabet of 22 characters described by Heinrich Cornelius
Agrippa in his Third Book of Occult Philosophy (Cologne, 1533)
derived from the Hebrew alphabet


================================================================================
Beej's Guide to Network Programming
http://beej.us/guide/bgnet/
tags: programming c network systems unix

================================================================================
The Paintings of Fred Einaudi 
href="http://fredeinaudi.blogspot.com/"  
tags: art
time="2008-06-23T01:59:41Z" 

================================================================================
Better Explained
  difficult concepts explained intuitively
href="http://betterexplained.com/"  
tags: learning mathematics
time="2008-06-11T01:38:28Z" 

================================================================================
An Intuitive Guide To Exponential Functions &amp; e
  e is the base amount of growth shared by all continually growing processes. e is defined to be that rate of growth if we continually compound 100% return on smaller and smaller time periods:
href="http://betterexplained.com/articles/an-intuitive-guide-to-exponential-functions-e/"
tags: mathematics learning
  time="2008-06-11T01:30:26Z" 

================================================================================
Ulrich Drepper: What Every Programmer Should Know About Memory
href="http://www.reddit.com/r/programming/info/615x1/comments/"
tags: todo programming virtual-memory
  time="2008-05-27T02:32:11Z" 


================================================================================
The Unscalable, Deadlock-prone, Thread Pool
https://news.ycombinator.com/item?id=19251516
tags: kernel linux macos os syscall programming virtual-memory process job-control systems-programming containers threading multithreading concurrency
- The mlock [1] system call allows you to lock chosen virtual memory into RAM. What about using that in combination with a memory pool which you manage yourself?
  [1] https://developer.apple.com/library/archive/documentation/System/Conceptual/ManPages_iPhoneOS/man2/mlock.2.html
- mlockall on Linux can lock all future allocations, including those made by shared libraries. You don’t need to manage a memory pool yourself.
.
Node suffers similar problems:
  1. All Node's async IO is lumped together into the same threadpool.
  2. There is no distinction between the nature of each async IO task.
  3. Async CPU tasks (fs.stat hitting the fs cache, async multi-core crypto, async native addons) complete orders of magnitude faster than async disk tasks (SSD or HDD), and these can be orders of magnitude faster than async network tasks (dns requests to a broken dns server).
  4. There are three basic async performance profiles, fast (CPU), slow (disk), very slow (dns), but Node has no concept of this.
  5. This leads to the Convoy effect. Imagine what happens when you race trucks, cars, and F1... all on the same race track.
  6. The threadpool has a default size of only 4 threads, on the assumption that this reflects the typical number of CPU cores (and reduces context switches).
  7. 4 threads is a bad default because it leads to surprising behavior (4 slow dns requests to untrusted servers are enough to DoS the process).
  8. 4 threads is a bad default because libuv's memory cost of 128 threads is cheap.
  9. 4 threads is a bad default because it prevents the CPU scheduler from running async CPU tasks while slow disk and slower DNS tasks are running. Concurrent CPU tasks should rather be limited to the number of cores available, while concurrent disk and DNS tasks should be given more than the number of cores available (context switches are better amortized for these).
  10. Because everything is conflated, hard concurrency limits can't be enforced on fast, slow or slower tasks. It's all or nothing.
  There are efforts underway to support multiple threadpools in Node
  (a threadpool for fast tasks sized to the number of cores, a threadpool for
  slow tasks sized larger, and a threadpool for slower tasks also sized larger):
  https://github.com/libuv/libuv/pull/1726

================================================================================
TripIt - travel organizer
  Organize trip details into one master online itinerary. see: http://www.joelonsoftware.com/items/2008/01/31.html
href="http://www.tripit.com/"  
tags: travel tools
time="2008-04-02T00:24:44Z" 

================================================================================
Programming and Computation 
href="http://okmij.org/ftp/Computation/" 
tags: compsci todo
time="2008-03-31T06:34:44Z" 


================================================================================
Alan Kay
tags: compsci history
Francis Bacon = origin of science.
Science= heuristics to get around bad brains.


================================================================================
regular expression generator 
href="http://www.txt2re.com/index-ruby.php3" 
tags: programming
time="2008-03-31T06:22:48Z" 

================================================================================
Pimp my Gedit (Was: Textmate for Linux)
href="http://grigio.org/pimp_my_gedit_was_textmate_linux"
tags: programming oss
  time="2008-03-30T20:48:15Z" 

================================================================================
Good Agile, Bad Agile at Google
  most managers code at least half-time. developers can switch teams and/or projects any time. there aren't very many meetings. average 3 meetings a week, including their 1:1 with their lead. it's quiet. Engineers are quietly focused on their work, as indiv
href="http://steve-yegge.blogspot.com/2006/09/good-agile-bad-agile_27.html"
tags: programming management
  time="2008-03-23T19:37:01Z" 

================================================================================
FOXNews.com - Radley Balko: Senseless Overkill - Opinion
  So in the raid where a citizen mistakenly shot a police officer, the citizen is facing a murder charge; in the raid where a police officer shot a citizen, prosecutors declined to press charges.
href="http://www.foxnews.com/story/0,2933,336850,00.html"
tags: politics
  time="2008-03-16T19:48:24Z" 

================================================================================
What makes Mathematics hard to learn?
  It really is hard to think about something until one learns enough terms to express the ideas in that this subject. ... What's the word for when you should use addition? It‚Äôs when a phenomenon is linear. What's the word for when you should use multiplic
href="http://wiki.laptop.org/go/Marvin_Minsky#What_makes_Mathematics_hard_to_learn.3F"
tags: learning mathematics
  time="2008-03-12T17:22:34Z" 

================================================================================
Legal Information Institute (LII)
  law resource
href="http://www.law.cornell.edu/"  
tags: law
time="2008-03-08T22:50:35Z" 

================================================================================
Banksy 
href="http://www.banksy.co.uk/"  
tags: art
time="2008-03-05T03:53:21Z" 

================================================================================
Will Wilkinson - More Misbehavioral Economics
  The ‚Äúrationality‚Äù of the outcome is more a function of the structure of the institution than of the ‚Äúrationality‚Äù of those acting inside it.
href="http://www.willwilkinson.net/flybottle/2008/02/28/more-misbehavioral-economics/"
tags: economics
  time="2008-03-04T15:54:34Z" 

================================================================================
Immigration: No Correlation With Crime - TIME
  while the number of illegal immigrants in the country doubled between 1994 and 2005, violent crime declined by nearly 35% and property crimes by 26% over the same period
href="http://www.time.com/time/nation/article/0,8599,1717575,00.html?xid=rss-topstories"
tags: politics
  time="2008-02-28T04:33:19Z" 

================================================================================
Healthy people place biggest burden on state - Telegraph
  study led by Pieter van Baal at the Netherlands‚Äô National Institute for Public Health and Environment
href="http://www.telegraph.co.uk/news/main.jhtml?xml=/news/2008/02/05/nhealth105.xml"
tags: politics
  time="2008-02-26T03:54:42Z" 

================================================================================
Willamette Week | ‚ÄúA Brush With Measure 11‚Äù | February 20th, 2008
  A Washington County jury found Rodriguez guilty in 2005 of first-degree sexual assault after police accused her of running her hands through a 13-year-old boy‚Äôs hair and pulling the back of his head against her covered chest
href="http://wweek.com/editorial/3415/10416/" 
tags: politics
time="2008-02-25T10:39:14Z" 

================================================================================
giver - Google Code
  simple file sharing desktop application. Other people running Giver on your network are automatically discovered. no knowledge or set up needed
href="http://code.google.com/p/giver/"  
tags: oss tools
time="2008-02-24T04:24:42Z" 

================================================================================
Annals of Medicine: The Checklist: Reporting &amp; Essays: The New Yorker
  list-making. checklists improve quality.
href="http://www.newyorker.com/reporting/2007/12/10/071210fa_fact_gawande"
tags: information psychology
  time="2008-02-08T02:15:08Z" 

================================================================================
Clarity Sought on Electronics Searches - washingtonpost.com
  govt. searches laptops, cellphones, mp3 players; demands passwords.
href="http://www.washingtonpost.com/wp-dyn/content/article/2008/02/06/AR2008020604763.html"
tags: politics
  time="2008-02-07T22:48:50Z" 

================================================================================
WebUrbanist ¬ª 7 Underground Wonders of the World: Labyrinths, Crypts, Catacombs and More
href="http://weburbanist.com/2007/09/30/7-underground-wonders-of-the-world-labyrinths-crypts-and-catacombs/"
tags: travel
  time="2008-02-03T18:24:03Z" 

================================================================================
How America Lost the War on Drugs : Rolling Stone
href="http://www.rollingstone.com/politics/story/17438347/how_america_lost_the_war_on_drugs"
tags: todo politics
  time="2008-02-03T18:21:24Z" 

================================================================================
Holding a Program in One's Head 
href="http://www.paulgraham.com/head.html" 
tags: todo
time="2008-01-31T03:07:52Z" 

================================================================================
Beating the Averages 
href="http://www.paulgraham.com/avg.html" 
tags: todo
time="2008-01-31T03:07:40Z" 

================================================================================
News from the Front 
href="http://paulgraham.com/colleges.html" 
tags: todo
time="2008-01-30T07:19:32Z" 

================================================================================
The Equity Equation 
href="http://www.paulgraham.com/equity.html" 
tags: todo
time="2008-01-30T07:19:23Z" 

================================================================================
The Autumn of the Multitaskers 
https://www.theatlantic.com/magazine/archive/2007/11/the-autumn-of-the-multitaskers/306342/
tags: todo
> Neuroscience is confirming what we all suspect: Multitasking is dumbing us
> down and driving us crazy. One man’s odyssey through the nightmare of infinite
> connectivity

================================================================================
Going Nuclear
  founder of Greenpeace explains benefits of nuclear energy
href="http://www.washingtonpost.com/wp-dyn/content/article/2006/04/14/AR2006041401209.html"
tags: politics science nuclear
  time="2008-01-26T18:54:33Z" 

================================================================================
wellcare stock
  &quot;contracts will transfer to Patel's new ownership of Freedom and&quot;
href="http://finance.google.com/group/google.finance.695596/browse_thread/thread/13567432f9ddfe73/a1edf88f6e698868#a1edf88f6e698868"
tags: investment finance stock-picks
  time="2008-01-21T02:06:21Z" 

================================================================================
Wesley Snipes to Go on Trial in Tax Case - New York Times
  acquitted Joseph Banister, a former criminal investigator for the I.R.S.
href="http://www.nytimes.com/2008/01/14/business/14tax.html?_r=2&amp;ref=business&amp;oref=slogin&amp;oref=slogin"
tags: politics
  time="2008-01-15T06:19:38Z" 

================================================================================
American Letter Mail Company - Wikipedia, the free encyclopedia
  USPS competitor
href="http://en.wikipedia.org/wiki/American_Letter_Mail_Company"
tags: politics
  time="2008-01-10T04:24:52Z" 

================================================================================
The Liberal Blogger 
href="http://www.theliberalblogger.com/?pp_album=main&amp;pp_cat=gory-iraq-war-images"
tags: politics
  time="2008-01-07T03:03:14Z" 

================================================================================
G Edward Griffin - Creature From Jekyll Island A Second Look at the Federal Reserve
href="http://video.google.com/videoplay?docid=638447372044116845"
tags: politics economics
  time="2007-12-31T03:54:01Z" 

================================================================================
The Hangover That Lasts - New York Times
  heavy drinking in early or middle adolescence ... can lead to diminished control over cravings for alcohol and to poor decision-making. exercise has been shown to stimulate the regrowth and development of normal neural tissue.
href="http://www.nytimes.com/2007/12/29/opinion/29steinberg.html?_r=1&amp;oref=slogin"
tags: health neuroplasticity
  time="2007-12-30T22:38:32Z" 

================================================================================
RepRap
  self-copying 3D printer - a self-replicating machine. see also: http://angry-economist.russnelson.com/beads-not-teeth.html see also: http://vimeo.com/5202148 see also: http://www.reddit.com/r/technology/comments/8zd27/the_reprap_is_the_most_awesome_machine_ever_built/
href="http://www.reprap.org/"  
tags: 3d_printing self-replication programming electronics engineering
  time="2007-12-25T00:45:09Z" 

================================================================================
Got-It
https://news.ycombinator.com/item?id=21805248
time="20191216"
tags: design vlsi ise labels tags inventory rfid bluetooth proximity programming electronics engineering software startup
> Ultra thin Bluetooth labels called Got-it (https://got-it.com)
> Got-it is for tracking things at work as a team. Simply peel and stick, no different from a barcode sticker. But, these are active Bluetooth labels. They're flexible and roughly the size of a little Avery barcode label (28mm x 76mm) and less than 0.5mm thick. They communicate with the phones already in employee pockets, even in background mode. That means no scanning like RFID, and no readers or gateway infrastructure to install in the ceiling or the doorways.
> ... a way to make our Bluetooth beacon firmware more reliably trigger background processing in phones, while still preserving ultra low power consumption. To do so, we ended up writing low-level embedded code, in less than 1.5KB and 135 Bytes RAM, to control the radio registers directly, without a BLE stack. Phones receive just enough information from our labels to enable a lean, low-power positioning algorithm we wrote.
> ... passive components, like inductors and capacitors using these inks and laminates by taking advantage of the thin geometry of the substrate itself. Our bill of materials is just a few lines long, so sourcing in China isn’t needed.
> ... electrochemically coating our circuit to form our own battery source that lasts over a year.
.
paulgerhardt:
> All commercial circuit boards are designed with computer aided design tools. An unfortunate consequence of these tools are monocultural, emergent styling decisions that stem from the tooling's schema. John Maeda has half a dozen books on this - he suggests one must design ones own tools if you don't want to look like everyone else and compete with the same strengths and weaknesses as everyone else.
> ...
> What makes Got-It special is not just that the broke the conventions of the traditional EE design patterns but that they broke them in so many different places. Where most people would use a readily available Bluetooth Chip, it sounds like they sourced the core to half-a-chip (Bluetooth MCU chips are often a combination of Arm processor, memory, radio, power management, and communication cores - it's not common to just take a few of these things - they're sold as a package but all those parts take power and this thing has a very tight power budget). They wrote their own Bluetooth stack (this alone is a multi-year project). That stack they wrote took into account weird specification...divergences...that the Bluetooth SIG says one should do but Apple/Android don't. The circuit they designed only works with the manufacturing process they had to develop for this chip - designs are usually done on rectangular boards, not tape. Most people don't make their own passive components they source them. Most people don't think about their circuit in 4D (that is 3D+movement as it bends in use). Most people don't think about making their own manufacturing equipment to serve a SaaS like business goal. I'm not even getting into the battery part which is bananas. The list goes on, as Brian enumerated above, but the combination of so many of these things represents a radical departure from 'business as usual' and the start of a new design movement as has happened when people transitioned from using drafting tables to computers decades ago.

================================================================================
Globalization and localization demystified in ASP.NET 2.0
href="http://www.codeproject.com/KB/aspnet/localizationByVivekTakur.aspx"
tags: asp.net programming todo
  time="2007-12-18T05:17:25Z" 

================================================================================
REST: the quick pitch 
href="http://www.megginson.com/blogs/quoderat/2007/02/15/rest-the-quick-pitch/"
tags: programming rest
  time="2007-09-30T19:36:41Z" 

================================================================================
Ergonomic products 
href="http://www.ergomart.com/"  
tags: health
time="2007-09-27T04:38:59Z" 

================================================================================
The GNU C Library 
href="http://www.gnu.org/software/libc/manual/html_node/index.html"
tags: c programming
  time="2007-09-18T05:27:10Z" 

================================================================================
Teach Yourself C in 24 Hours 
href="http://aelinik.free.fr/c/index.html" 
tags: c programming
time="2007-09-18T05:25:52Z" 

================================================================================
The C Book 
href="http://publications.gbdirect.co.uk/c_book/" 
tags: c programming
time="2007-09-18T05:21:40Z" 

================================================================================
comp.lang.c FAQ 
href="http://c-faq.com/"
tags: c programming
  time="2007-09-18T05:18:58Z" 

================================================================================
Mono and XPCOM: Scripting VirtualBox - Miguel de Icaza
  COM interop on Mono + *nix
href="http://tirania.org/blog/archive/2007/Aug-28.html"
tags: programming mono
  time="2007-09-04T03:48:33Z" 

================================================================================
Yellow Icon : Crystal icon set 
href="http://yellowicon.com/downloads/"  
tags: icons
time="2007-08-26T08:35:24Z" 

================================================================================
Master Pages: Tips, Tricks, and Traps
  describing the control tree mechanics of how a master page and content page are merged together at runtime, how you can programmatically switch master pages on the fly from within a page, within a page base class, and even within an HttpModule (to enforce
href="http://odetocode.com/Articles/450.aspx" 
tags: .net asp.net programming
  time="2007-06-05T00:00:11Z" 

================================================================================
How to use LINQ to do dynamic queries
  IEnumerable&lt;T&gt;.ToQueryable(), expression tree / QueryExpression
href="http://blogs.gotdotnet.com/mattwar/archive/2006/05/10/594966.aspx"
tags: programming .net linq
  time="2007-05-29T18:04:35Z" 

================================================================================
Creating Trimmed Self Contained Executables in .NET Core
https://dev.to/jeremycmorgan/creating-trimmed-self-contained-executables-in-net-core-4m08
tags: programming .net deploy ship cross-platform
command:
  dotnet publish -r win-x64 -c Release /p:PublishSingleFile=true /p:PublishTrimmed=true

================================================================================
Lightweight Invisible CAPTCHA Validator Control
href="http://haacked.com/archive/2006/09/26/Lightweight_Invisible_CAPTCHA_Validator_Control.aspx"
tags: asp.net programming
  time="2007-05-22T16:32:55Z" 

================================================================================
fundamentals javascript concepts
  prototypes, namespacing
href="http://odetocode.com/Articles/473.aspx" 
tags: programming javascript
  time="2007-05-17T19:27:53Z" 

================================================================================
Principality of Sealand
  In 1967‚Äì8 Britain's Royal Navy tried to remove Bates. As they entered territorial waters, Bates tried to scare them off by firing warning shots from the former fort.
href="http://en.wikipedia.org/wiki/Principality_of_Sealand"
tags: politics terraforming protopia
  time="2007-04-29T07:01:21Z" 

================================================================================
Slashdot | IT Worker Shortages Everywhere
  exporting of Indian tech jobs to the US
href="http://it.slashdot.org/article.pl?sid=06/11/07/1926207&amp;tid=187"
tags: politics it
  time="2007-04-27T03:20:29Z" 

================================================================================
IMF admits disastrous love affair with the euro and apologises for the immolation of Greece
http://www.telegraph.co.uk/business/2016/07/28/imf-admits-disastrous-love-affair-with-euro-apologises-for-the-i/
tags: economics politics government-failure
Ambrose Evans-Pritchard 29 JULY 2016 • 11:27AM
.
> The International Monetary Fund’s top staff misled their own board, made
> a series of calamitous misjudgments in Greece, became euphoric cheerleaders
> for the euro project, ignored warning signs of impending crisis, and
> collectively failed to grasp an elemental concept of currency theory. 
>
> This is the lacerating verdict of the IMF’s top watchdog on the fund’s tangled
> political role in the eurozone debt crisis, the most damaging episode in the
> history of the Bretton Woods institutions. 
>
> It describes a “culture of complacency”, prone to “superficial and
> mechanistic” analysis, and traces a shocking breakdown in the governance of
> the IMF, leaving it unclear who is ultimately in charge of this extremely
> powerful organisation.


================================================================================
The Problem with Programming
  Bjarne Stroustrup, the inventor of the C++ programming language, defends his legacy and examines what's wrong with most software code.
href="http://www.techreview.com/Infotech/17831/page1/"
tags: cpp programming
  time="2007-04-26T07:03:53Z" 

================================================================================
Articles on &quot;Electricity&quot;
  &quot;Babylonian approach to science understanding&quot; by William J. Beaty. intuitive explanations. addresses misconceptions.
  misconceptions: http://amasci.com/miscon/elect.html
href="http://amasci.com/ele-edu.html"  
tags: science learning pedagogy
time="2007-04-25T07:10:51Z" 

================================================================================
Google Song-Maker
https://musiclab.chromeexperiments.com/Song-Maker
tags: music learning pedagogy fun app webapp kids
https://goo.gl/pf5Q9Y "Heroes Forever"

================================================================================
Europass: Curriculum Vitae
http://europass.cedefop.europa.eu/documents/curriculum-vitae
create CV online. import/export
tags: visa europe germany berlin immigration

================================================================================
multi-armed bandit problem (explore/exploit dilemma)
https://en.wikipedia.org/wiki/Multi-armed_bandit
tags: concepts mental-model
scheduling/operations theory.
Problem in which a fixed limited set of resources must be allocated between
competing (alternative) choices in a way that maximizes their expected gain,
when each choice's properties are only partially known at the time of
allocation, and may become better understood as time passes or by allocating
resources to the choice.

================================================================================
Pedophrasty, Bigoteering, and Other Modern Scams
https://medium.com/incerto/pedophrasty-bigoteering-and-other-modern-scams-c84bd70a29e8
tags: concepts psychology mental-model
Pedophrasty: Argument involving children to prop up a rationalization and make the opponent look like an asshole, as people are defenseless and suspend all skepticism in front of suffering children: nobody has the heart to question the authenticity or source of the reporting. Often done with the aid of pictures.
Bigoteering: tagging someone (or someone’s opinions) as “racist”, “chauvinist” or somethinglikeit-ist in situations where these are not warranted. This is a shoddy manipulation to exploit the stigmas accompanying such labels and force the opponent to spent time and energy explaining “why he/she is not a bigot”.
Nabothizing: Production of false accusation, just as Jezebel did to dispossess Naboth.
Partializing: Exploiting the unsavory attributes of one party in a conflict without revealing those of the other party.


================================================================================
True Name
https://en.wikipedia.org/wiki/True_name
tags: concepts psychology mental-model
> The notion that language, or some specific sacred language, refers to things by their true names has been central to philosophical study as well as various traditions of magic, religious invocation and mysticism (mantras) since antiquity.
> ...
> The true name of the Egyptian sun god Ra was revealed to Isis through an elaborate trick. This gave Isis complete power over Ra.
> ...
> the German fairytale of Rumpelstiltskin: within Rumpelstiltskin and all its variants, the girl can free herself from the power of a supernatural helper who demands her child by learning its name

================================================================================
Idioglossia
https://en.wikipedia.org/wiki/Idioglossia
tags: concepts psychology mental-model

================================================================================
Principal–agent problem
https://en.wikipedia.org/wiki/Principal%E2%80%93agent_problem
tags: concepts politics economics mental-model
> one person or entity (the "agent") is able to make decisions on behalf of another person or entity: the "principal".

================================================================================
Reality has a surprising amount of detail
http://johnsalvatier.org/blog/2017/reality-has-a-surprising-amount-of-detail
tags: concepts psychology emergence mental-model
> This surprising amount of detail is is not limited to “human” or “complicated” domains, it is a near universal property of everything from space travel to sewing, to your internal experience of your own mind.
> ...
> Before you’ve noticed important details they are, of course, basically
> invisible. ... But after you see them they quickly become so integrated into
> your intuitive models of the world that they become essentially transparent.
> ...
> This means it’s really easy to get stuck. Stuck in your current way of seeing
> and thinking about things. Frames are made out of the details that seem
> important to you. The important details you haven’t noticed are invisible to
> you, and the details you have noticed seem completely obvious and you see right
> through them. This all makes makes it difficult to imagine how you could be
> missing something important.

================================================================================
Emergence
https://en.wikipedia.org/wiki/Emergence
tags: concepts emergence mental-model

================================================================================
L-system
https://en.wikipedia.org/wiki/L-system
https://onlinemathtools.com/l-system-generator
tags: cellular-automata cells tree graph compsci algorithm visualization
Generate organic structures (similar to cellular-automata?).
> Lindenmayer used L-systems to describe the behaviour of plant cells and to
> model the growth processes of plant development. L-systems have also been used
> to model the morphology of a variety of organisms[1] and can be used to
> generate self-similar fractals.
Example 1: Algae growth
  variables : A B
  constants : none
  axiom : A
  rules : (A → AB), (B → A)
produces:
  n = 0 : A
  n = 1 : AB
  n = 2 : ABA
  n = 3 : ABAAB
  n = 4 : ABAABABA
  n = 5 : ABAABABAABAAB
  n = 6 : ABAABABAABAABABAABABA
  n = 7 : ABAABABAABAABABAABABAABAABABAABAAB

================================================================================
Algorithm for Drawing Trees
https://rachel53461.wordpress.com/2014/04/20/algorithm-for-drawing-trees/
tags: tree graph compsci algorithm visualization
NB: Reingold-Tilford Algorithm is for binary trees.
.
> The main trouble is determining an appropriate X position for each node.
ALGORITHM: DECIDE X-POSITION OF EACH NODE
1. Do a post-order traversal of the tree
2. Assign an X value to each node of 0 if it’s a left-most node, or leftSibling.X + 1 if it’s not.
3. For each parent node, we want the node centered over the children. This would
   be the midway point between the first child’s X position, and the last
   child’s X position.
   .
   If the parent has no left sibling, change it’s X value to this midpoint
   value. If it has a left sibling, we’re going to store it in another node
   property. I’m calling this property Mod just because that’s what I see it
   called in other examples.
   .
   The Mod property is used to determine how much to modify the children’s
   X values in order to center them under the parent node, and will be used when
   we’re done with all our calculates to determine the final X value of each
   node. It should actually be set to Parent.X – MiddleOfChildrenX to determine
   the correct amount to shift the children by.
4. Check that this tree does not conflict with any of the previous sibling
   trees, and adjust the Mod property if needed. This means looping through each
   Y level in the current node, and checking that the right-most X value of any
   sibling to the left of the node does not cross the left-most X value of any
   child in the current node.
5. Do a second walk through the tree to determine that no children will be drawn
   off-screen, and adjust the Mod property if needed. This can happen when if
   the Mod property is negative.
6. Do a third walk through the tree to determine the final X values for each
   node. This will be the X of the node, plus the sum of all the Mod values of
   all parent nodes to that node. Now lets go through each step in more detail.


================================================================================
Version SAT, Russ Cox
https://research.swtch.com/version-sat
VERSION is reducible to 3-SAT.
tags: dependency-management compsci sat-solver graph-theory

================================================================================
Libsolv: library for solving package dependencies and reading repositories using SAT solver
https://github.com/openSUSE/libsolv
tags: dependency-management compsci sat-solver graph algorithm
Used by Suse, Fedora, Haiku https://news.ycombinator.com/item?id=34881498
Has two innovations:
- a memory optimized format to represent packages and its dependencies, using hashed string pools
- a SAT solver able to operate directly in this representation, battle tested in this particular scenario of complex upgrades, including hundred of testcases.

================================================================================
Pubgrub: Dart's version-solving algorithm
https://github.com/dart-lang/pub/blob/master/doc/solver.md
tags: dependency-management compsci sat-solver graph algorithm
Pubgrub solves these issues by adapting state-of-the-art techniques for solving
Boolean satisfiability and related difficult search problems.

================================================================================
Modern SAT solvers: fast, neat and underused 
https://codingnest.com/modern-sat-solvers-fast-neat-underused-part-1-of-n/
tags: dependency-management compsci sat-solver graph algorithm

================================================================================
SAT Solvers as Smart Search Engines
https://www.msoos.org/2019/02/sat-solvers-as-smart-search-engines/
tags: compsci sat-solver graph algorithm
.
TAKEAWAY: SAT solvers are like brute-force with "save points" (Partial value assignments).
.
- SAT solver _without_ intermediate variables is essentially brute force!
- SAT solver depends on human to _model_ the problem, to yield useful
  intermediate variables.
- Brute-force vs. SAT-solver:
    - Brute-force completely erases its state, takes another input and runs the
      whole algorithm again.
    - SAT-solver calculates what variables were affected by one of the input
      bits, unsets these variables, flips the input bit value, and resumes
      the calculation. This has the following requirements:
        1. Quickly determine which intermediate values depend on which other
           ones so we can unset variables and know which intermediate, already
           calculated, dependent variables also need to be unset.
           (SAT-solvers only do this in reverse chronological order.)
        2. Quickly unset variables.
        3. A good set of intermediate values so we can keep as much state of the
           calculation as possible. This requires _modeling_ (human decision).


================================================================================
What I've Learned About Optimizing Python
https://gregoryszorc.com/blog/2019/01/10/what-i've-learned-about-optimizing-python/
tags: python optimization

================================================================================
re2c: lexer generator for C/C++
http://re2c.org/
https://github.com/skvadrik/re2c
tags: dfa regex automata lexer optimization c programming
.
> generates fast lexers. Instead of using traditional table-driven approach,
> re2c encodes the generated finite state automata directly in the form of
> conditional jumps and comparisons. The resulting programs are faster and often
> smaller than their table-driven analogues, and they are much easier to debug
> and understand.
.
Used by Oil shell: https://github.com/oilshell/oil


================================================================================
Google Optimization Tools
https://developers.google.com/optimization/
tags: compsci sat-solver graph optimization algorithm
Google Optimization Tools (OR-Tools) is a fast and portable software suite for
solving combinatorial optimization problems. The suite contains:
    A constraint programming solver.
    A simple and unified interface to several linear programming and mixed integer
    programming solvers, including CBC, CLP, GLOP, GLPK, Gurobi, CPLEX, and SCIP.
    Graph algorithms (shortest paths, min cost flow, max flow, linear sum
    assignment).
    Algorithms for the Traveling Salesman Problem and Vehicle Routing Problem.
    Bin packing and knapsack algorithms.
    For instruction on installing OR-Tools for C++, Python, Java, or .Net


================================================================================
Cloud Foundry
https://news.ycombinator.com/item?id=14532127
tags: paas dcos orchestration deployment sre devops

> It's the most mature out of all of these, has been soak tested to 250,000 running applications[0], can be deployed to any major IaaS or bare metal, comes with routing, logging, service injection, healing, no-downtime upgrading and I forget what other headlines I usually pick out of the several hundred features it now includes.
> The Cloud Foundry Foundation includes Pivotal (my employer), IBM, SAP, Google, DellEMC, VMWare, Cisco, Suse and those are just the fancy tech names.
> The reason you don't hear about it is that we and our partners have focused on competing for enterprise sales. It's not how you get publicity on HN, but it does mean that PivotalCF -- our commercial distribution -- has the fastest-growing sales of an opensource-based product in history. And sales are still zooming up and to the right.
> The nice thing is that we and other partners get very broad, specific feedback from customers who are already at massive scale and who expect utter, non-negotiable reliability. We run a public service ourselves (Pivotal Web Services), SAP have HANA Cloud, IBM runs BlueMix.
> We and other Cloud Foundry contributors have had the benefit of that dogfooding and feedback for longer than any other container-based platform in existence. And it turns out, there are so many things that can go wrong. So many. It's crazy.
> Lastly, Cloud Foundry teams have massive investments in project automation. This gives us two capabilities: one is that we can roll out complete rebuilds of the whole platform within hours of an upstream CVE patch. Users can then apply these fixes to their platform live, in-place, without any running apps noticing that it has occurred. BOSH[1] will roll out the deployment with canaries, and Diego[2] will relaunch containers as they are reaped during upgrade.
> The second capability is that we are confident in making very deep, very aggressive changes if it proves necessary, because we have tests upon tests upon mountains of more tests. And again: nobody notices, except that their platform gets faster or becomes reliable under even more extreme circumstances.
> If I sound like an utterly biased fan, it's because I am an utterly biased fan. I've watched this thing evolve up-close for years. It is amazing.
> We build installable superpowers.
> Disclosure: If it's not obvious, I work for Pivotal on Cloud Foundry.
> [0] https://content.pivotal.io/blog/250k-containers-in-production-a-real-test-for-the-real-world
> [1] http://bosh.io/
> [2] https://github.com/cloudfoundry/diego-design-notes

================================================================================
China uncovers massive underground network of Apple employees selling customers’ personal data
https://www.hongkongfp.com/2017/06/08/china-uncovers-massive-underground-network-apple-employees-selling-customers-personal-data/
tags: security infosec

> employees of an Apple “domestic direct sales company and outsourcing company”.
> ... used an internal company computer system to gather users’ names, phone
> numbers, Apple IDs, and other data, which they sold as part of a scam worth
> more than 50 million yuan (US$7.36 million).
> ... charged between 10 yuan (US$1.50) and 180 yuan (US$26.50)
>
> In December, an investigation by the Southern Metropolis Daily newspaper
> exposed a black market for private data gathered from police and government
> databases. Reporters successfully obtained a trove of material on one
> colleague — including flight history, hotel checkouts and property holdings
> — in exchange for a payment of 700 yuan (US$100).


================================================================================
Coroutines as an alternative to state machines
https://eli.thegreenplace.net/2009/08/29/co-routines-as-an-alternative-to-state-machines
tags: programming compsci coroutine state-machine
Coroutines are to state machines what recursion is to stacks:
  - Recursion helps process nested data structures without employing explicit stacks.
  - Coroutines help solve problems involving state without explicitly using state machines.
Coroutines ~= "infinite state machines".


================================================================================
DECYPHERING THE BUSINESS CARD RAYTRACER
tags: programming compsci c graphics ppm image ray-tracing
http://fabiensanglard.net/rayTracing_back_of_business_card/index.php
http://www.cs.utah.edu/~aek/code/card.cpp

    #include <stdlib.h>   // card > aek.ppm
    #include <stdio.h>
    #include <math.h>
    typedef int i;typedef float f;struct v{
    f x,y,z;v operator+(v r){return v(x+r.x
    ,y+r.y,z+r.z);}v operator*(f r){return
    v(x*r,y*r,z*r);}f operator%(v r){return
    x*r.x+y*r.y+z*r.z;}v(){}v operator^(v r
    ){return v(y*r.z-z*r.y,z*r.x-x*r.z,x*r.
    y-y*r.x);}v(f a,f b,f c){x=a;y=b;z=c;}v
    operator!(){return*this*(1/sqrt(*this%*
    this));}};i G[]={247570,280596,280600,
    249748,18578,18577,231184,16,16};f R(){
    return(f)rand()/RAND_MAX;}i T(v o,v d,f
    &t,v&n){t=1e9;i m=0;f p=-o.z/d.z;if(.01
    <p)t=p,n=v(0,0,1),m=1;for(i k=19;k--;)
    for(i j=9;j--;)if(G[j]&1<<k){v p=o+v(-k
    ,0,-j-4);f b=p%d,c=p%p-1,q=b*b-c;if(q>0
    ){f s=-b-sqrt(q);if(s<t&&s>.01)t=s,n=!(
    p+d*t),m=2;}}return m;}v S(v o,v d){f t
    ;v n;i m=T(o,d,t,n);if(!m)return v(.7,
    .6,1)*pow(1-d.z,4);v h=o+d*t,l=!(v(9+R(
    ),9+R(),16)+h*-1),r=d+n*(n%d*-2);f b=l%
    n;if(b<0||T(h,l,t,n))b=0;f p=pow(l%r*(b
    >0),99);if(m&1){h=h*.2;return((i)(ceil(
    h.x)+ceil(h.y))&1?v(3,1,1):v(3,3,3))*(b
    *.2+.1);}return v(p,p,p)+S(h,r)*.5;}i
    main(){printf("P6 512 512 255 ");v g=!v
    (-6,-16,0),a=!(v(0,0,1)^g)*.002,b=!(g^a
    )*.002,c=(a+b)*-256+g;for(i y=512;y--;)
    for(i x=512;x--;){v p(13,13,13);for(i r
    =64;r--;){v t=a*(R()-.5)*99+b*(R()-.5)*
    99;p=S(v(17,16,8)+t,!(t*-1+(a*(R()+x)+b
    *(y+R())+c)*16))*3.5+p;}printf("%c%c%c"
    ,(i)p.x,(i)p.y,(i)p.z);}}


================================================================================
AWS: compute the minimal permission set needed to perform some requests(s)?
https://news.ycombinator.com/item?id=21228386
tags: programming software-engineering debugging security amazon aws
.
- script (GPLv2): https://github.com/KanoComputing/aws-tools/blob/master/bin/aws-policy-minimize
  uses python picire[1] (a delta-debugging[2] framework) to generate a minimal
  permission set by re-executing a caller-supplied boto script with different
  permissions until all(?) combinations have been tried.
- Netflix [repokid](https://github.com/Netflix/repokid) project "watches API
  calls for a Role and then suggests minimum privilege changes to the attached
  policy".
- Consider chalice's analyzer.py which generates policies for Python web apps:
  https://github.com/aws/chalice/blob/master/chalice/analyzer.py
.
TODO: maybe SimulatePrincipalPolicy API is useful? https://docs.aws.amazon.com/IAM/latest/APIReference/API_SimulatePrincipalPolicy.html
.
[1] https://pypi.org/project/picire/
[2] https://www.st.cs.uni-saarland.de/dd/


================================================================================
Kerbal Space Program: Create and Manage Your Own Space Program
https://www.kerbalspaceprogram.com
tags: game software kids learning science space pedagogy

================================================================================
No nuances, just buggy code (was: related to Spinlock implementation and the Linux Scheduler)
https://news.ycombinator.com/item?id=21959692
https://www.realworldtech.com/forum/?threadid=189711&curpostid=189752
tags: linux scheduler rtos os
Takeaway:
- Don't use spinlocks in userspace. Userspace spinlocking is not legible to the
  kernel. Therefore anytime you attempt it you are in the situation of fighting
  the scheduler.
- sched_yield() is almost always a mistake because it does not convey intent
  (except in narrow realtime scenarios). Instead tell the kernel why you want to
  yield CPU: work with the kernel, not against it.
  Do you want to ...
  - wait until some future point in time? Use sleep.
  - wait for some I/O? Use poll or variants.
  - wait for a signal from another thread? Use mutexes, conditions, etc. that call
    futex under the hood.
Linus Torvalds:
> sched_yield() is basically historical garbage ... Most people expect it to be
> a very light-weight operation exactly because they (incorrectly) think it's
> trivial, and they have literally tuned their load for that case.
>
> Do you think, for example, that the system should do a very expensive "check
> every single CPU thread to see if one of them has a runnable thread but is
> running something else, and break the CPU affinity of that thread and bring it
> to this CPU"? Yes, that other thread isn't running right now, but bringing it
> to this CPU might slow it down enormously because now all the caches are gone
> because all the historical data it was working on is in another NUMA domain.
>
> Yes, certain simple schedulers get exactly the behavior you want. The best way
> to get exactly your behavior is to have a single run-queue for the whole
> system, and make 'sched_yield()' always put the thread at the back of that
> run-queue, and pick the front one instead.
>
> Any locking model that uses "sched_yield()" is simply garbage. Really. If you
> use "sched_yield()" you are basically doing something random. Imagine what
> happens if you use your "sched_yield()" for locking in a game, and somebody
> has a background task that does virus scanning, updates some system DB ...
>
> Btw, locking can be simple too. If you do a lot of work, and the locking is
> something "occasional", you can use things like just passing a token over
> a pipe (or even a network connection) as your locking mechanism. ... Create
> a counting semaphore by initialize a pipe with N characters (where N is your
> parallelism for the semaphore), and then anybody who wants to get the lock
> does a one-byte read() call and anybody who wants to release the lock writes
> a single byte back to the pipe.

================================================================================
Spanish flu
https://en.wikipedia.org/wiki/Spanish_flu
tags: concepts epidemic pandemic statistics exponential-growth infection bacteria superinfection
1918 influenza pandemic: January 1918 – December 1920: colloquially known as Spanish flu.
First of the two pandemics involving H1N1 influenza virus, with the second being the swine flu in 2009.
- 500 million infected (~27% of world population).
- 17~50 million dead.
Wartime censors minimized early reports of illness and mortality in Germany/UK/France/USA.
Not censored in Spain, which created a false impression, giving rise to the nickname "Spanish flu".
Most deaths caused by bacterial superinfection (result of malnourishment, overcrowded hospitals, poor hygiene).

================================================================================
Scala War Stories with Paul Phillips (2013)
https://lobste.rs/s/tk0hjk/scala_war_stories_with_paul_phillips_2013
takeaways:
- > "Unification can burn you":
  > By definition, you are eliminating a distinction … if your cover is not
  > airtight, breakage will ensue wherever the distinction appears.
  Like “leaky abstraction”, but abstraction is additive whereas “unification” is
  reductive, it takes away. Eliminating needless distinctions is very desirable,
  but it must be _total_.
- Interop is hard, particularly for type-obsessed languages.

================================================================================
20200315
Federal Reserve Actions to Support the Flow of Credit to Households and Businesses
https://www.federalreserve.gov/newsevents/pressreleases/monetary20200315b.htm
tags: politics economics federal-reserve monetary-policy inflation
> the Board has reduced reserve requirement ratios to zero percent effective on
> March 26, the beginning of the next reserve maintenance period. This action
> eliminates reserve requirements for thousands of depository institutions and
> will help to support lending to households and businesses.

================================================================================
20200324
Modern Monetary Theory
https://www.reddit.com/r/wallstreetbets/comments/fnkbdh/dont_bet_against_mmt_you_will_lose_even_if_you/fla4bve/
tags: economics mmt federal-reserve monetary-policy equity stock options
>>>> QE and Fed intervention in a market is only for stabilization to prevent
>>>> total credit seizure (even in 08 we didn't have a total failure). Once the
>>>> loan is paid back it is destroyed in an M0 sense, it doesn't accumulate in
>>>> the wider monetary supply.
>>>>
>>>> If "printer goes brrr" you'd see stonks and assets fucking skyrocket... But
>>>> that's not what's happening... QE only can keep the back bone of Inter-bank
>>>> loans and lending flowing until stable conditions.
>>>
>>> We still have 4 trillion dollars of "stable free markets" on the balance
>>> sheet from 2008.
>>>
>>> They are trying to prop up asset prices. The effect is deflationary as soon
>>> as people can no longer afford to repay their debt.
>>>
>>> If the Fed is buying that debt and sticking it on a balance sheet and taking
>>> a loss, then it is 100 fucking percent "printer go brrrrr".
>>
>> A few things, a) most of the bonds are still viable, just not to privately
>> loaned against levels and have slowly been dissipated by sheer regular
>> schedule payments from end-borrowers b) some of the biggest moves were in
>> 2012 when another round of particular commercial paper (mostly counter-party
>> agreements from AIGFP) was about to clog the banking system like a chunk of
>> cholesterol dislodged, and c) though you think that "$4T is suppoesd to keep
>> asset prices up" let's do the math: the US economy is about $24T, the
>> holdings have been at $4T for nearly a decade, and inflation has been minimal
>> and in fact anemic... Hardly "printer go brr" territory unless that printer
>> is a dot matrix for a very specific and small aspect of the global banking
>> system lmao.
>
> ... I never mentioned inflation, and you ignored the deflationary forces
> making your inflationary comment pointless since you are ignoring the cost of
> housing, education, and pretty much every asset when you say that "inflation
> has been minimal".
>
> Only a "smart money" trader who makes money off of this misery thinks what is
> going on is fine.
>
> If you lend more money than an economy can realistically pay back due to
> a lack of GDP growth, the effect is asset destruction once that loan defaults.
> That is deflationary in nature. ... As soon as the Fed starts trying to
> backstop it and goes ahead and forgives that debt, then that forgiven debt in
> effect becomes free money and it immediately becomes inflationary.
>
> If they just give more loans, then the bubble continues to inflate and we will
> be back here in a few years listen to you talking about how a 700 trillion
> bailout is no big deal because inflation is minimal.
>
> ...
>
> The fact that 4 trillion of monetized government debt and mortgage backed
> securities still sits on the fed book 10 years later means that they never
> cleared the logjam of bloated assets from the last time.

================================================================================
20200324
Joe Rogan Experience #1066 - Mel Gibson & Dr. Neil Riordan
https://www.youtube.com/watch?v=OtL1fEEtLaA
tags: health medicine technology illegal stem-cell panama
"Adult" (umbilical-cord) stem-cell injection heals arthritis, inflammation, MS,
spinal-cord injury, autoimmune disease, et al.
- umbilical cells do NOT form tumors, get flushed out by immune system after 6 months
  - *not* embryonic. embryonic cells "want to become babies", form tumors/teratomas.
- older cells have less regenerative capacity => less capacity to heal large problem-sites
- finds/heals damaged cells, "retrains" the immune system
- https://www.cellmedicine.com/
- treatment fee: $23K

================================================================================
20200410
Senate Transaction Report
https://senatestockwatcher.com/
tags: politics equity stock options

================================================================================
20200414
Kayfabe
https://en.wikipedia.org/wiki/Kayfabe
tags: concepts mental-model
kayfabe
- aka "work(ed)"
- portrayal of staged events within the industry as "real" or "true"
- was used as a warning to other wrestlers that a mark was in the vicinity
- suspension of disbelief
- in-character
"shoot": not kayfabe
"mark": someone outside of the business
Faces and heels
- Faces, short for "babyfaces", are hero-type characters
- Heels are villainous or antagonistic characters

================================================================================
20200416
Tim Ferriss: how to master any skill by deconstructing it | The Next Web
https://www.youtube.com/watch?v=DSq9uGs_z0E
tags: learning psychology language pedagogy
- deadlifts most effective if you start from ground and lift only ~5 inches.
- best temperature for coffee = 180 F
- play ~any song with 4 chords: https://www.youtube.com/watch?v=B_Smt1VsoqQ

================================================================================
20200421
Who’s Behind the “Reopen” Domain Surge?
https://krebsonsecurity.com/2020/04/whos-behind-the-reopen-domain-surge/
tags: urbit search reputation
> several “reopen” sites that seemed to be engaged in astroturfing ... new
> domains — including reopenmn.com, reopenpa.com, and reopenva.com ... roughly
> coincided with contemporaneous demonstrations in Minnesota, California and
> Tennessee where people showed up to protest quarantine restrictions over the
> past few days. ... registered by the Dorr Brothers ... “to stir the pot and
> make as much animosity as they can, and then raise money off that animosity.”

================================================================================
20200424
一期一会: ichigo-ichie (“one lifetime, one encounter”)
https://en.wiktionary.org/wiki/%E4%B8%80%E6%9C%9F%E4%B8%80%E4%BC%9A
tags: concepts mental-model
You should treasure every encounter, for it will never recur.

================================================================================
20200504
Daniel Schmachtenberger on The Portal (with host Eric Weinstein), Ep. #027 - On Avoiding Apocalypses
https://www.youtube.com/watch?v=_b4qKv1Ctv8
tags: economics concepts mental-model
"Game B"
sense-making + choice-making
"multipolar trap"
  - Moloch = "god of game theory", "emergent property of interlocking incentives"
    https://slatestarcodex.com/2014/07/30/meditations-on-moloch/
"bottom-up coordination system"
"rivalrous dynamics"
paperclip maximizer: https://wiki.lesswrong.com/wiki/Paperclip_maximizer
> AIs with apparently innocuous values could pose an existential threat.
rivalrous
  non-rivalrous
    anti-rivalrous
cannot reduce unique things to a metric (metricize)
fungibility = metric-reduction
protopian ("going in the right direction"), not utopian
"Any hypernormal stimulus (addiction) that decreases normal stimulus ends up net bad for you."
Being famous isn't fun for even 15 minutes
  What you actually want is to be taken seriously by ~3000 selected people.
Addiction => erosion of the baseline
  "A more-effective relationship to pleasure is anti-addictive."

================================================================================
20200506
Eric Weinstein: Geometric Unity and the Call for New Ideas, Leaders & Institutions | AI Podcast, Lex Fridman #88
https://www.youtube.com/watch?v=rIAZJNe7YtE
tags: physics science academia institutions
_The Road to Reality_ by Roger Penrose
  "This book is a self-contained invitation to understanding our deepest nature."

================================================================================
20200508
Secessio plebis
https://en.wikipedia.org/wiki/Secessio_plebis
tags: history economics politics state
> Secessio plebis (withdrawal of the commoners, or secession of the plebs) was
> an informal exercise of power by Rome's plebeian citizens, similar in concept
> to the general strike. ... the plebs would abandon the city and leave the
> patrician order to themselves. ... all shops and workshops would shut down and
> commercial transactions would largely cease.
https://news.ycombinator.com/item?id=23121851
>> The last secession was in 287 BC. Why were there not secessions after it? ...
>> [because] Rome’s conquests really went into overdrive ... there came a lot of
>> slaves. This totally changed the dynamics. After a while, the wealthy
>> depended not on their poor fellow Romans to farm or make goods, but on
>> slaves. Now it did not matter if the plebes didn’t not show up.
>
> Also small landholders and artisans in Italy could not compete with large
> latifundia [1] and manufactures using 'free' slave labour and cheap grain from
> Egypt and cheap financing (gold from conquests). The Roman conquest had been
> financed by the state but the spoils benefitted mostly wealthy citizens (tax
> farming in provinces).
> But plebs still had voting rights and every year there were held elections on
> Mars Fields and keeping the apperances of democracy was important for Roman
> Republic (also during the what we know as Imperial period). So the giveway of
> food and coin and entertainment to citizens had became a new norm.[2]
> [1] https://en.m.wikipedia.org/wiki/Tiberius_Gracchus
> [2] https://en.m.wikipedia.org/wiki/Bread_and_circuses
>
consolidation of small free-held farms into large estates held by senators:
- partially driven by war debts: the State accrued debt on behalf of Roman
  citizens => land-owning citizens are taxed more => must sell their property to
  pay the "debt" => political/military class uses spoils of war to buy land from
  artifically-indebted citizens
  - analogous to US dollar
- https://en.m.wikipedia.org/wiki/Debt_bondage

================================================================================
20200509
Joe Rogan Experience #1309 - Naval Ravikant
https://www.youtube.com/watch?v=3qHkcs3kG44
tags: startups concepts mental-model philosophy technology naval-ravikant
- Read the same 100 books over and over
- Social media makes everyone a celebrity; but celebrities are the most miserable people in the world...
- Rich and anonymous > poor and famous
- Just like fitness can be a choice, being happy/successful can be a choice.
- Be the person who gets there calmly, without struggle/stress/panic.
  Don't have too _many_ desires, don't pick them up randomly ("my coffee is too cold").
  Pick your central desire and focus on it. Let the others go, relax.
- We are in an age of leverage: make a podcast, hire employees, write code => 1000x impact
- The Right Way to work is like a lion: graze.
  Train hard, sprint, then rest/reasses.
  You won't have linear output just by cranking every day 9-5.
- Information Age will reverse Industrial Revolution: everyone will work for themselves.
- If someone can tell you when to work and what to where you’re not free
- Companies are smaller and smaller because they can externalize easily
- Coase theorem: size of a company is a function of internal vs external
  transaction cost.  Companies will become smaller as external transaction costs
  reduce (the gig economy).  Startups shave small inefficiencies and turn them
  into big markets.
- Future gig economy: *highly-skilled* work (missions/sprints).
- UBI doesn’t provide meaning/status
- No AGI: we don’t even understand what really happens inside a cell, let alone the brain
- Social sciences: "You can tell they're fake sciences because they have the word 'science' tacked on."
- Peace is happiness at rest, happiness is peace in motion.
- Peace is not about external problems but about giving up on the idea of problems itself.
- If there were an answer to "meaning of life" we would not be free.
- Agrippa/Münchhausen trilemma: 1 Infinite regress; 2 Circular reasoning; 3 Axiom.
- We should be doing nuclear fusion experiments on the moon.
- If you are smart you should be able to figure out how to be happy.
- Busy minds ("monkey minds") are not peaceful.
- Peace FROM mind not peace OF mind.
- Retirement = solved your money problem, by lowering expenses/burnrate or increasing income.
  - Allows you to stop sacrificing something today with the idea you will get something in return tomorrow.
- Focus on being authentic, unique, creative and not replaceable.
- Two addictions: heroine and a monthly salary.
- Get used to ignoring your peers.
- “Easy for you to say” and “keeping up with the Jones” is a trap.
- Confucious: every man has 2 lives; the second life starts when you realize you only have one.
- Force yourself to be positive until it becomes automatic.
  Watch your mind (without judgement): "why am I having that thought?"
- "Would I be still interested in this thing if I couldn’t tell anyone?"
- Your brain "Hedonically adapts" to any new luxury.
- Art = anything done for its own sake

================================================================================
20200515
Hyperdrive v10 – a peer-to-peer filesystem
https://blog.hypercore-protocol.org/posts/announcing-hyperdrive-10/
tags: distributed-systems filesystem
https://news.ycombinator.com/item?id=23180572

================================================================================
20200515
Port knocking
https://en.wikipedia.org/wiki/Port_knocking
https://news.ycombinator.com/item?id=23187662
tags: security network protocol
COUNTERPOINT:
> It is stupid to implement "IP-over-SYNpackets" (actually "password over SYN
> packets") when we already have a perfectly good way to send packets of
> information that doesn't expose even the complexities of TCP (e.g. slowlaris,
> SYN flood, etc…): it's called UDP. Just send your plaintext password in
> a UDP packet.
ALTERNATIVES:
- send the password in a plaintext UDP packet
- "honey" ports: automatically block/log hosts that touch the wrong ports.
- "single packet authorization" has a much more robust mechanism that addresses
  criticisms of port knocking. Your packet is cryptographically signed.
  "Take a look at fwknop for the implementation. The only issue with it is
  there’s no easy install for pfsense."
  - Noise protocol handshake (https://noiseprotocol.org) = "single-packet port knocking"
- "TCP MD5 (RFC 2385) is vastly underused."  https://blog.habets.se/2019/11/TCP-MD5.html
  - TCP option that adds an MD5 signature to every TCP packet.
  - All unsigned packets (including SYN packets) are silently dropped.
  - For a signed connection it’s not possible for an eavesdropper to reset the
    connection, since the RST would need to be signed.
  - Doesn't work through NAT, maybe with IPv6 it'll gain more traction.
  - Used in production with BGP since the 90s, but there's nothing stopping
    it being used for SSH too.

================================================================================
20200515
Montevideo Convention, requirements for statehood
https://en.wikipedia.org/wiki/Montevideo_Convention
tags: politics state international-law
> The state as a person of international law should possess the following qualifications:
> (a) a permanent population;
> (b) a defined territory;
> (c) government; and
> (d) capacity to enter into relations with the other states.

================================================================================
20200519
Python performance: it’s not just the interpreter
https://news.ycombinator.com/item?id=23235930
tags: performance programming python compiler interpreter optimization
Argument passing was responsible for 31% of time cost in the inner loop.
The time is spent packing i into a tuple (i,) and then unpacking it again.
    def main():
     for j in range(20):
       for i in range(1000000):
         str(i)
    main()
Python impl of argument passing:
    static PyObject * unicode_new(PyTypeObject *type, PyObject *args, PyObject *kwds) {
      PyObject *x = NULL;
      static char *kwlist[] = {"object", "encoding", "errors", 0};
      char *encoding = NULL;
      char *errors = NULL;
      PyArg_ParseTupleAndKeywords(args, kwds, "|Oss:str",
                                  kwlist, &x, &encoding, &errors))
    }
Notice the call to PyArg_ParseTupleAndKeywords: it takes an args tuple and
a format string and *executes a mini interpreter to parse the arguments from the
tuple*. It must be prepared to receive arguments as any combination of keywords
and positional, but for a given callsite the matching will generally be static.

================================================================================
20200525
Stanford Pupper: Inexpensive & Open-source Quadruped Robot
https://stanfordstudentrobotics.org/pupper
tags: diy-project electronics engineering programming

================================================================================
20200525
"You and Your Research" Richard Hamming
http://www.cs.virginia.edu/~robins/YouAndYourResearch.html
tags: productivity engineering science academia university study research invention innovation
> When you are famous it is hard to work on small problems. This is what did
> Shannon in. ... The great scientists often make this error. They fail to
> continue to plant the little acorns from which the mighty oak trees grow. ...
> When you get early recognition it seems to sterilize you. ... The Institute
> for Advanced Study in Princeton, in my opinion, has ruined more good
> scientists than any institution has created, judged by what they did before
> they came and judged by what they did after.
  Q: How to avoid stagnation?
  A: Every seven years make a significant, if not complete, shift in your field. When you go to a new field, you have to start over as a baby.
> "Knowledge and productivity are like compound interest." Given two people of
> approximately the same ability and one person who works ten percent more than
> the other, the latter will more than twice outproduce the former. The more you
> know, the more you learn; the more you learn, the more you can do; the more
> you can do, the more the opportunity - it is very much like compound interest.
> ... I don't like to say it in front of my wife, but I did sort of neglect her
> sometimes; I needed to study. You have to neglect things if you intend to get
> what you want done.
>
> "Genius is 99% perspiration and 1% inspiration." ... The steady application of
> effort with a little bit more work, _intelligently_ applied is what does it.
> That's the trouble; drive, misapplied, doesn't get you anywhere.
>
> Great scientists tolerate ambiguity very well. ... If you believe too much
> you'll never notice the flaws; if you doubt too much you won't get started.
>
> "It is a poor workman who blames his tools - the good man gets on with the job,
> given what he's got, and gets the best answer he can."
>
> It is not sufficient to do a job, you have to sell it. ... is everyone is busy
> with their own work. You must present it so well that they will set aside what
> they are doing, look at what you've done, read it, and come back and say,
> "Yes, that was good." ... You have to learn to write clearly ... you must
> learn to give reasonably formal talks, and you also must learn to give
> informal talks.
>
> While going to meetings I had already been studying why some papers are
> remembered and most are not. The technical person wants to give a highly
> limited technical talk. ... Few people in the audience may follow. You should
> paint a general picture to say why it's important, and then slowly give
> a sketch of what was done. ... The tendency is to give a highly restricted,
> safe talk; this is usually ineffective. Furthermore, many talks are filled
> with far too much information.
>
> I found in the early days I had believed "this" and yet had spent all week
> marching in "that" direction. It was kind of foolish. If I really believe the
> action is over there, why do I march in this direction? I either had to change
> my goal or change what I did. ... It's that easy.
>
> The people who do great work with less ability but who are committed to it,
> get more done that those who have great skill and dabble in it.
>
> I didn't say you should conform; I said "The _appearance of conforming_ gets
> you a long way." If you chose to assert your ego in any number of ways, "I am
> going to do it my way," you pay a small steady price throughout the whole of
> your professional career. And this, over a whole lifetime, adds up to an
> enormous amount of needless trouble.
>
> By realizing you have to use the system and studying how to get the system to
> do your work, you learn how to adapt the system to your desires. Or you can
> fight it steadily, as a small undeclared war, for the whole of your life.
.
> Ed David was concerned about the general loss of nerve in our society. ...
> coming out of Los Alamos where we built the bomb, coming out of building the
> radars and so on...
cf. Peter Thiel, Eric Weinstein on the paralysis of physics progress since 1950s.
https://www.youtube.com/watch?v=nM9f0W2KD5s

================================================================================
20200526
Kapil Gupta: Conquering the Mind
https://nav.al/kapil
tags: concepts mental-model philosophy health
> Kapil: A human being becomes his environment and that is why it’s absolutely
> critical to savagely and surgically arrange one’s environment in a way that is
> in accordance with where he wants to go. You become that which you are most
> consistently exposed to.

================================================================================
20200611
https://old.reddit.com/r/wallstreetbets/comments/grj5fa/the_mouthbreathers_guide_to_the_galaxy/
tags: economics mmt federal-reserve monetary-policy equity stock options
> Yup, everyone got clapped on their stupidly leveraged derivatives books. It
> seems Citadel is “too big to fail”. On 3/18, the payout on 3/20 TQQQ puts
> alone if it went to 0 was $468m. And every single TQQQ put expiration would
> have had to be paid. Tens or hundreds of billions on TQQQ puts alone. I’d bet
> my ass Citadel was on the hook for a big chunk of those.

================================================================================
20200612
https://old.reddit.com/r/wallstreetbets/comments/h0ytcy/the_liquidity_trap_how_qe_and_low_rates_might_be/ftqgnj8/
tags: economics mmt federal-reserve monetary-policy equity stock options
> look into "Dollar Milkshake Theory" https://www.youtube.com/watch?v=PWVRWUkm54M
>
> Most of the world's debt is held by foreign governments and companies, yet
> these debts denominated in US dollars.
>
> High debt countries will experience inflation as they print money to pay
> interest, so their currencies will fall relative to the USD.
>
> As you mentioned, bond yields are worthless. But this is true globally, so
> further uncertainty will trigger capital flight from foreign nations into the
> USD, as a safe asset.
>
> If the USD appreciates and earnings don't rise, foreign governments and
> companies will have a significantly harder time servicing their USD debt
> because their own currencies will become worthless, leading to massive global
> insolvency, and further USD appreciation.
>
> The endgame of this global insolvency scenario, is the US government being
> forced to forgive debts, and foreign governments and central banks agreeing to
> abandon the USD as the reserve currency. Maybe even the creation a new global
> currency.
>
> TL:DR The global central banking system cannot handle a deflationary USA and
> significant USD appreciation.

================================================================================
20200613
Pronomos Capital
https://www.pronomos.vc/
tags: investment finance startup naval-ravikant
> VC fund ... to create a new model for urban development where the city & its
> institutions is the product. ... work in partnership with countries to create
> new communities that seek - through good governance - to emulate the economic
> success of Dubai, Hong Kong, Shenzhen and Singapore. Our investors include
> Peter Thiel, Marc Andreessen, Balaji Srinivasan, Naval Ravikant, Joe

================================================================================
20200613
Founders Fund
https://foundersfund.com/
tags: investment finance startup
stripe, twilio, spacex, airbnb, ...

================================================================================
20200615
vscode notebook UX
https://github.com/microsoft/vscode/issues/91987
tags: tools programming ide vscode javascript typescript text-editor
design of vscode notebook experience (cf. jupyter): kernel/backend + cells

================================================================================
20200624
Peer-to-peer canvas app for Urbit
https://github.com/yosoyubik/canvas
tags: urbit app p2p programming
https://news.ycombinator.com/item?id=23228058

================================================================================
20200627
xi-editor retrospective
https://raphlinus.github.io/xi/2020/06/27/xi-retrospective.html
tags: tools programming xi rope vim neovim rust text-editor

================================================================================
20200627
Lezer (CodeMirror parsing system)
https://marijnhaverbeke.nl/blog/lezer.html
tags: programming parser syntax-highlighting text-editor

================================================================================
20200628
Semantic: Haskell library and command line tool for parsing, analyzing, and comparing source code
https://github.com/github/semantic
tags: programming parser ast syntax-highlighting code-navigation treesitter
Architecture:
1. Reads blobs.
2. Generates parse trees for those blobs with tree-sitter (an incremental parsing system for programming tools).
3. Assigns those trees into a generalized representation of syntax.
4. Performs analysis, computes diffs, or just returns parse trees.
5. Renders output in one of many supported formats.
Semantic leverages a number of interesting algorithms and techniques:
- Myers' algorithm (SES) as described in the paper An O(ND) Difference Algorithm and Its Variations
- RWS as described in the paper RWS-Diff: Flexible and Efficient Change Detection in Hierarchical Data.
- Open unions and data types à la carte.
- An implementation of Abstracting Definitional Interpreters extended to work with an à la carte representation of syntax terms.

================================================================================
20200628
The False Dichotomy Stunting Tech
https://www.aymannadeem.com/software/2019/08/06/The-False-Dichotomy-Stunting-Tech.html
tags: software-engineering programming communication technology engineering
> Eugenia Cheng on the power of abstraction. She discussed the difference
> between pedantry and precision.
>
> Pedantry is what she refers to as the noise — the opaque, ineffective
> nerd-porn dialogue that obscures meaning by muddying it with jargon. Not only
> can this result in gatekeeping, but it also allows incompetence to hide behind
> unnecessarily intellectualized terminology. Precision, by contrast, was what
> Dr. Cheng referred to as the signal — the bits of work that are expressed
> clearly and without loss of detail.
>
> ... Being clear is not about being dumb, but, as Eugenia Cheng said, about
> identifying a problem with the precision and clarity that is appropriate for
> the context. ... Poor abstractions dumb down complexity and reduce precision.
> Good abstractions make things more precise by creating context-appropriate
> information and interfaces.
>
> “Being abstract is something profoundly different from being vague … to create
> a new semantic level in which one can be absolutely precise.” — Edsger W. Dijkstra

================================================================================
20200630
Dirtbag left
https://en.wikipedia.org/wiki/Dirtbag_left
tags: politics tropes concepts
> A mode of left-wing politics that eschews civility in order to convey
> a socialist or left-wing populist message using subversive vulgarity. It is
> most closely associated with American left-wing media that emerged in the
> mid-2010s, most notably the podcast Chapo Trap House.

================================================================================
20200630
Multi-channel network
https://en.wikipedia.org/wiki/Multi-channel_network
tags: software platform technology media
> A multi-channel network (MCN) is an organization that works with video platforms to offer assistance to a channel owner in areas such as "product, programming, funding, cross-promotion, partner management, digital rights management, monetization/sales, and/or audience development" in exchange for a percentage of the ad revenue from the channel.
https://support.google.com/youtube/answer/2737059?hl=en
> Multi-Channel Networks (“MCNs” or “networks”) are third-party service providers that affiliate with multiple YouTube channels to offer services that may include audience development, content programming, creator collaborations, digital rights management, monetization, and/or sales.

================================================================================
20200630
Guy Who Reverse-Engineered TikTok Reveals the Scary Things He Learned
https://news.ycombinator.com/item?id=23684950
tags: security fingerprinting software technology machine-learning spam
> The "private data" the app collected, is used, for most part, fingerprint the unique user.
>
> In every MCN app, there was a huge fake user problem. If an app collect zero identifiable fingerprint, then a spammer can easily fake millions of views and manipulate ranked content. The app developers are asked think clever to collect every piece of info they can, while spammers spent night and days spoofing every parameter in a virtual machine or even on a matrix of remote controlled real phones.
>
> For example, if a iPhone 11 user logs in, but only with screen resolution of 320x240, is it legit? I have caught tens of thousands of fake users with simple checks like this. However the tricks expires pretty quickly, you have to move on with new feature checks, together with decision trees and bayesian networks.
>
> Some of the fingerprint collecting SDKs are even using native code to check some ARM specific instructions to tell if the device is fake or not. The parameters check had to be done in every important API calls, or spammers can easily pretend be good citizen during parameter checking process and swap the session to a cheaper VM/phone or spam the targeted API with scripts.

================================================================================
20200720
Multiprotocol Label Switching Architecture
https://datatracker.ietf.org/doc/html/rfc3031
tags: rfc network internet engineering ietf
next generation internet protocol / replaces tcp/ip?

================================================================================
20200720
All of the World’s Money and Markets in One Visualization
https://www.visualcapitalist.com/all-of-the-worlds-money-and-markets-in-one-visualization-2020/
tags: economics finance stocks
All of the world’s money and markets, from the smallest to the biggest, along with sources used:
  CATEGORY                                VALUE ($ BILLIONS, USD) SOURCE
  ----------------------------------------------------------------------
  Silver                                  $44                     World Silver Survey 2019
  Cryptocurrencies                        $244                    CoinMarketCap
  Global Military Spending                $1,782                  World Bank
  U.S. Federal Deficit (FY 2020)          $3,800                  U.S. CBO (Projected, as of April 2020)
  Coins & Bank Notes                      $6,662                  BIS
  Fed's Balance Sheet                     $7,037                  U.S. Federal Reserve
  The World's Billionaires                $8,000                  Forbes
  Gold                                    $10,891                 World Gold Council (2020)
  The Fortune 500                         $22,600                 Fortune 500 (2019 list)
  Stock Markets                           $89,475                 WFE (April 2020)
  Narrow Money Supply                     $35,183                 CIA Factbook
  Broad Money Supply                      $95,698                 CIA Factbook
  Global Debt                             $252,600                IIF Debt Monitor
  Global Real Estate                      $280,600                Savills Global Research (2018 est.)
  Global Wealth                           $360,603                Credit Suisse
  Derivatives (Market Value)              $11,600                 BIS (Dec 2019)
  Derivatives (Notional Value)            $558,500                BIS (Dec 2019)
  Derivatives (Notional Value - High end) $1,000,000              Various sources (Unofficial)

================================================================================
20200720
Gell-Mann amnesia effect
https://en.wikipedia.org/wiki/Speeches_by_Michael_Crichton#GellMannAmnesiaEffect
tags: concepts mental-model psychology
> phenomenon of experts believing news articles on topics outside of their
> fields of expertise, even after acknowledging that articles written in the
> same publication that are within the experts' fields of expertise are
> error-ridden and full of misunderstanding.

================================================================================
20200720
Turning the IDE Inside Out with Datalog
https://news.ycombinator.com/item?id=23869592
tags: datalog query language ide programming database
https://petevilter.me/post/datalog-typechecking/

================================================================================
20200720
QUANTUMINSERT (QI), QUANTUMHAND
https://news.ycombinator.com/item?id=23782093
tags: police-state surveillance usgov government state security encryption nsa
https://blog.fox-it.com/2015/04/20/deep-dive-into-quantum-insert/
NSA can read TCP sequence numbers or DNS query IDs, and then spoof valid response packets.
NSA has QUANTUMINSERT capabilities since 2005.
Detection is possible by looking for duplicate TCP packets but with different payload and other anomalies in TCP streams.
QUANTUMHAND uses QUANTUMINSERT against targets visiting Facebook.
Method:
- observe HTTP requests by eavesdropping network traffic
- inject malicious content into a specific TCP session
- requires the capability to listen in on potentially high volumes of internet traffic, which requires substantial resources and a fast infrastructure
Mitigation:
- HTTPS in combination with HSTS can reduce the effectiveness of QI.
- Using a CDN that offers low latency can make it very difficult for the QI packet to win the race with the real server.

================================================================================
20200720
Reddit's website uses DRM for fingerprinting
https://smitop.com/post/reddit-whiteops/
tags: reddit security fingerprinting software technology webbrowser web
Reddit uses WhiteOps (third-party tool for "bot mitigation, bot prevention, and fraud protection".
Script checks DRM and other features (does not actually need them, just for fingerprinting):
- Contains what appears to be a Javascript engine JIT exploit/bug, "haha jit go brrrrr" appears in a part of the code
- Obfuscated reference to res://ieframe.dll/acr.js, which can be used to exploit old Internet Explorer
- Checks for various global variables and other indicators of headless and automated browsers.
- Sends data to vprza.com and minkatu.com.
- Checks if devtools is open
- Detects installed text-to-speech voices
- Checks if browsers have floating point errors when rounding 0.49999999999999994 and 2^52
- Detects if some Chrome extensions are installed
- Checks if function bodies that are implemented in the browser contain [native code] when stringified
- Checks if toString itself is implemented in native code
- Checks for Apple Pay support

================================================================================
20200729
Joe Rogan Experience #1515 - Dr. Bradley Garrett
https://www.youtube.com/watch?v=_kDKAOncclU
tags: podcast prepper urban-explorer
London's "lost rivers": underground rivers converted to tunnels/sewers in the 1800s
- River Tyburn
- River Effra

================================================================================
20200731
Harvard Study of Adult Development
https://news.harvard.edu/gazette/story/2017/04/over-nearly-80-years-harvard-study-has-been-showing-how-to-live-a-healthy-and-happy-life/
tags: psychology happiness life
https://news.ycombinator.com/item?id=24007274
> Close relationships, more than money or fame, are what keep people happy
> throughout their lives, the study revealed. Those ties protect people from
> life’s discontents, help to delay mental and physical decline, and are better
> predictors of long and happy lives than social class, IQ, or even genes.
>
> The people who were the most satisfied in their relationships at age 50 were the healthiest at age 80.

================================================================================
20200802
Schiphol clock - Maarten Baas
http://maartenbaas.com/real-time/schiphol-clock/
tags: art time clock amsterdam airport
12-hour performance art film of Dutch artist Maarten Baas painting each minute
of the hands of a clock.  In Schiphol Airport since 2016.

================================================================================
20200802
GITenberg project
https://www.gitenberg.org/
tags: literature ebooks books pedagogy
- Curated, usable, attractive ebooks in the public domain.
- Converts Project Gutenberg HTML to ePub.

================================================================================
20200827
QUIC: Quick UDP Internet Connections
tags: networks proxy quic tcp udp protocol http spdy cryptopgraphy tls ssl
- purpose:
  - avoid HOL blocking
    - ...by "handling packets separately (not within TCP)"
  - evolve Congestion Control faster (side-step OS vendors)
- enhances UDP
  + ordering
  + multiplexed connections between two endpoints over UDP
    - works in concert with HTTP/2 (SPDY) multiplexed connections, allowing multiple streams to reach endpoints independently
    - compare: HTTP/2 over TCP can suffer head-of-line (HOL) blocking
- reduce latency
  - speculative DNS and TCP pre-resolution
- monolithic: violates traditional layers. Scope includes delivery + control + security.
- TCP:
  - packet loss *is* the "congestion notification"
  - "No OS API for inspecting out-of-order arrivals."
  - TLS uses CBC (cipher block chaining: hash of the previous block is used as
    IV of the next block) => another source of HOL blocking in TCP.
  - Hack: to workaround TCP perf, browsers open 6 cxns to the server
    - each cxn has its own congestion window
    - servers add subdomains just to allow >6 cxns...
    - circular problem: multiple congestion windows => causes fighting/variance, wastes bandwidth => causes congestion => causes retransmissions => ...
  - TCP packet loss response is painful: AIMD (additive increase, *multiplicative* decrease)
- FEC (forward error correction):
  - Avoids NACK roundtrip.
  - Example:
    1. send packets A, B, C.
    2. send XOR sum of A+B+C as final packet.
    3. receiver can correct errors if it receives 3 out of 4 packets.
      - similar to RAID for disk arrays
- Problem: packet loss has 2 modes
  1. Lose 1 packet randomly. ("uncorrelated")
    - FEC works well for this.
  2. Lose >=2 packets: once you lose 2, likely to lose 3 or more! ("correlated")
    - In this mode, error correction is a waste of effort.

================================================================================
20200809
interview with Elon Musk about SpaceX Starship
https://www.youtube.com/watch?v=cIQ36Kt7UVg
tags: space spacex science starship nasa
"If a design is taking too long, the design is wrong. ... Strive to delete parts and processes. ... Question the constraints."
- Elon Musk

================================================================================
20200809
WebAuthn guide
https://webauthn.guide/
tags: security infosec webauthn u2f fido mfa software-engineering
implementing MFA on a new website:
- implement WebAuthn, not U2F (older, non-standard hack)

================================================================================
20200809
Security Keys, webauthn (27 Mar 2018)
https://www.imperialviolet.org/2018/03/27/webauthn.html
tags: security infosec webauthn u2f fido mfa software-engineering
- "relying party": any entity trying to authenticate a user
- U2F: "Universal 2nd factor"
- CTAP1: version 1 “Client To Authenticator Protocol”
  - two operations: creating a new key, and signing with an existing key.
  - a “user presence” test before performing operations. E.g. a button or
    capacitive sensor that you must press. While not triggered, operations
    return a specific error code and the host is expected to retry.
  - tokens are nearly stateless in practice.
  - strictly monotonic "signature counter"; relying party is intended to record
    the values and notice if a private key has been duplicated, because the
    strictly-monotonic property will eventually be violated if multiple,
    independent copies of the key are used.
    - problems with this:
      1. recall that CTAP1 tokens have very little state in order to keep costs
         down. Because of that, most/all tokens have a single, global counter
         shared by all keys created by the device. This means that the value and
         growth rate of the counter is a trackable signal that’s transmitted to
         all sites that the token is used to login with. For example, the token
         that I’m using right now has a counter of 431 and I probably use it far
         more often than most because I’m doing things like writing example
         Python code to trigger signature generation. I’m probably pretty
         identifiable because of that.
      2. Since the counter is per-token, it’ll commonly jump several values
         between logins to the same site because the token will have been used
         to login elsewhere in-between. That makes the counter less effective at
         detecting cloning.
- CTAP2: updated standard for tokens, to take advantage of webauthn
  - main feature: devices can be used as a 1st (and only) factor. I.e. they have
    enough internal storage to contain a username and so both provide an
    identity and authenticate it.
.
> The FIDO Javascript API is not the future, however. Instead, the W3C is defining an official Web Authentication standard (webauthn) for Security Keys.
.
> a relying party can determine, with some confidence, that a newly created key
> is stored in a Yubico 4th-gen U2F device by checking the attestation
> certificate and signature.
>
> FIDO does not dismiss [vendor lock-in] worries and their answer, for the
> moment, is the metadata service (MDS). Essentially this is a unified root
> store that all sites checking attestation are supposed to use and update from.
> ... My advice is for sites to ignore attestation if you’re serving the public.

================================================================================
20200809
Who needs this filesystem malarkey anyway? (20 Jul 2003)
https://www.imperialviolet.org/2003/07/20/who-needs-this-filesystem-malarkey-anyway.html
tags: djb filesystem kernel interface design compsci software-engineering
djb:
> A small interface (for example, a descriptor allowing read() or write())
> supports many implementations (disk files; network connections; and all sorts
> of interesting programs via pipes), dramatically expanding the user's power to
> combine programs. A big interface (for example, a file descriptor that allows
> directory operations) naturally has far fewer implementations.

================================================================================
20200809
From Benjamin Franklin to Cadwallader Colden, 29 September 1748
https://founders.archives.gov/documents/Franklin/01-03-02-0133
tags: history quotation benjamin-franklin role-model
> "I shall like to give my self ... Leisure to read, study, make Experiments,
> and converse at large with such ingenious and worthy Men as are pleas’d to
> honour me with their Friendship" - Benjamin Franklin

================================================================================
20200809
Poor Richard, 1736
https://founders.archives.gov/documents/Franklin/01-02-02-0019
tags: history quotation benjamin-franklin
> Force shites upon Reason’s Back.
> Lovers, Travellers, and Poets, will give money to be heard.
> He that speaks much, is much mistaken.
> Creditors have better memories than debtors.
> Forwarn’d, forearm’d, unless in the case of Cuckolds, who are often forearm’d before warn’d.

================================================================================
20200810
Jeremy Howard: fast.ai Deep Learning Courses and Research | Artificial Intelligence (AI) Podcast
https://www.youtube.com/watch?v=J6XcP4JOHmk
tags: podcast video deep-learning machine-learning compsci engineering swift healthcare
- swift is compelling because the whole stack uses the same language
  (vs python = {C, numpy, CUDA, Makefile, …})
- fast.ai moving to swift (~3 years out) + tensorflow
  - swift "layer on top of MLIR" https://mlir.llvm.org
- "python for tensorflow is a disaster"
- AI concerns:
  - how to avoid "runaway feedback loops"?

================================================================================
20200810
MLIR: Multi-Level Intermediate Representation
https://mlir.llvm.org/
tags: compiler llvm
hybrid IR which can support multiple different requirements in a unified
infrastructure. For example, this includes:
- The ability to represent dataflow graph (such as TensorFlow), including
  dynamic shapes, the user-extensible op ecosystem, TensorFlow variables, etc.
- Optimizations and transformations typically done on a such graph (e.g. in Grappler).
- Representation of kernels for ML operations in a form suitable for optimization.
- Ability to host high-performance-computing-style loop optimizations across
  kernels (fusion, loop interchange, tiling, etc) and to transform memory
  layouts of data.
- Code generation “lowering” transformations such as DMA insertion, explicit
  cache management, memory tiling, and vectorization for 1D and 2D register
  architectures.
Non-goals:
- We do not try to support low level machine code generation algorithms (like
  register allocation and instruction scheduling). They are a better fit for
  lower level optimizers (such as LLVM).
- We do not intend MLIR to be a source language that end-users would themselves
  write kernels in (analogous to CUDA C++). On the other hand, MLIR provides the
  backbone for representing any such DSL and integrating it in the ecosystem.
Outcomes:
- For example, LLVM has non-obvious design mistakes that prevent a multithreaded
  compiler from working on multiple functions in an LLVM module at the same
  time. MLIR solves these problems by having limited SSA scope to reduce the
  use-def chains and by replacing cross-function references with explicit symbol
  reference.

================================================================================
20200812
UPX: Ultimate Packer for eXecutables
https://upx.github.io/
tags: elf binary compression c
portable, extendable, high-performance executable packer for several executable formats.
shrink executables by 50%

================================================================================
20200815
Review of Paul Graham's Bel, Chris Granger's Eve, and a Silly VR Rant
https://gist.github.com/wtaysom/7e5fda6d65807073c3fa6b92b1e25a32
tags: datalog query language programming-paradigm vm eve light-table
> If Eve was so nifty, why did it fail? Technical problems:
> (1) keying
> (2) inspection
> (3) reflection
> (4) event handling
>
> (1) Keying proved my most common problem when trying to use Eve. I want an
> entity per something where the something is complex: like a bid per bidder per
> product per round. Each bid also has non-identifying properties: a price, the
> time it was entered, who it was entered by, etc. ... Though internally Eve
> dealt with keys, they never completed the theory nor committed to exposing the
> details.
>
> (2) Then without great ways to inspect the database, I couldn't see what was
> going on, how keys came into play.
>
> (3) Since Eve patterns can match against anything, I found it easy to check
> invariants but hard to identify causes of their violation. One could not
> reflect on how rules gave rise to derived properties. This was always a goal,
> just never happened.
>
> (4) Though Eve had a decent [theoretical foundation](http://bloom-lang.net/index.html)
> for controlled change over time, it was never exposed in a way that one could
> easily reason about. The primary challenge being that you want an event to
> arise in the database, effect a change, then dissipate. Whereas an imperative
> language lets you write step one, two, three, Eve never had that view. Change
> was managed through an intricate interplay of rules, always hidden. Dijkstra
> makes a good point:
>
> > we should do our utmost to shorten the conceptual gap between the static
> > program and the dynamic process, to make the correspondence between the
> > program (spread out in text space) and the process (spread out in time) as
> > trivial as possible.
>
> Given thought, time, practice, these issues could be have been addressed — but
> only from grappling with ordering seriously. Why weren't (2) inspection, (3)
> reflection, and (4) dynamics visualized? To show a thing, it cannot be
> formless. It must be positioned, arranged in space. With Eve, they kept
> punting, ignoring the interplay between the ordered and the unordered. Even
> difficulties in (1) keying amounted to leaking imperative implementation
> details.

================================================================================
20200823
Plan A for the coronavirus
https://medium.com/@curtis.yarvin/plan-a-for-the-coronavirus-7db3997490c1
tags: government-failure covid19 virus curtis-yarvin
> Anyone repeating lines like “the Trump administration has failed” is spreading
> an Orwellian lie. There is no “Trump administration.” There is an elected
> showman and his cronies, fronting for an unaccountable permanent government.
> The celebrities are neither in charge of the bureaucrats, nor deserve to be.

================================================================================
20200824
Unregistered 116: Curtis Yarvin (AKA "Mencius Moldbug")
https://www.youtube.com/watch?v=6GW-YMa68o4
tags: concepts government politics philosophy curtis-yarvin history libertarianism monarchy
- "Sovereignty is conserved."
- How DC works: "Everyone wants status but no one wants responsibility."

================================================================================
20200824
POAAS 03 - Surveying Ethiopian History w/ Curtis Yarvin
https://www.youtube.com/watch?v=BKdOoR4zhOc
tags: concepts politics history curtis-yarvin
- https://en.wikipedia.org/wiki/Cursus_honorum
  Latin for "course of honor", or colloquially "ladder of offices".
- "Unconsidered superiority" is the attitude of a parochial barbarian.
- "Atheist cold war Liberalism" is "secularized Christianity".
- atheist vs. anti-theist

================================================================================
20200826
Gray Mirror of the Nihilist Prince with Curtis Yarvin
https://www.youtube.com/watch?v=_8o0M24DrcE
tags: concepts government politics philosophy curtis-yarvin history libertarianism monarchy
- "Exit, voice, and loyalty."
  - Exist outside of power, not in antagonism to it. Disengage.
- "When people think of 'regime change' as implying violent discontinuity, they
  couldn't be more wrong."
  - Stasi officers (GDR/DDR) still receive pensions.
- Structure of government matters much more than policies.
  - "This is a very optimistic thought because it means the problem does not
    require changing the minds of many people, the problem is just that the
    structure is wrong."
  - Leftism selects for power without responsibility.
  - "Power without responsibility is the very definition of an oligarchy."
- It is a very bad idea to "tempt power" (e.g. "fedposting"). Most people intuit
  this, but they don't take that principle to an extreme, i.e. they don't
  realize that *any* attempt to exert power is a fatal illusion.
  - Free yourself from that illusion; merely observe.
- Prefer abstractly inflammatory but concretely inert.
- In general, antagonizing power is beneficial to power [because they get to
  define/interpret your ingression: "you inhabit their frame"].
  - 31:45-36:00 interesting!
- "Internal exile": living like an expat without actually leaving a geopolitical
  space. Exit spiritually but not physically. "In the closet".
  - Impossible to physically exit the global empire.
- Time is on your side.
  - "When you try to matter in the short term as a dissident against an enormous
    regime, you are just thrashing."
  - Don't associate with anyone who is incapable of calm/intellectual outrage
    without being able to control their expression of it.
- Don't help the regime by trying to stabilize it.
  - "When you slow down the regime, you're doing it a service by keeping it from
    going crazy."
  - "When you elect a conservative, this just increases the resonance of the
    left's fundraising appeals. The left is never in charge, they don't want the
    responsibility of being in power, they want to be the underdogs."
  - "When you fight these fights, you're an actor in their fundraising pitch."
  - "A fraction of that energy pulled away from the system and providing an
    intellectual exit, is much more valuable."
- _Salus populi suprema lex_. (Latin: "The health of the people is the supreme law.")
  - Compare the modern GDP-driven motto: _Luxus populi suprema lex_.
- National identity is superficial, is going stale.
- "Arguing about policy is just LARPing: you're putting something that used to
  work in a different context, into a context where it's fake and lame."
- Rule #1 of regime change: cannot punish anyone for supporting the old regime.

================================================================================
20200828
Robin Hanson and "Mencius Moldbug" debate futarchy at Foresight 2010
https://www.youtube.com/watch?v=Tb-6ikXdOzE
tags: concepts government politics philosophy curtis-yarvin history libertarianism monarchy
- "Government _wasteful spending_ is really _disguised profits_ going to
  beneficiaries in the form of entitlements and overpaying."
- "There's a crucial difference between a bet and a vote." (skin in the game)

================================================================================
20200905
THINGS HIDDEN 17: The Glorious Yeast Infection of Christianity (Curtis Yarvin Interview)
https://www.youtube.com/watch?v=otXb3DVGvSI
tags: concepts government politics philosophy curtis-yarvin history libertarianism monarchy
- "Dept. of Homeland Security" (2001) is linguistically synonymous with NSA, but
  "National Security" actually means "world domination": FDR declared "events
  anywhere in the world affect the national security of the US".
  - Ironic because the US excuse for entering WW2 was to prevent (assumed)
    German plans for world domination.
- Q: why didn't Japan attack Soviets w/ Germany?
  A: "Axis" alliance was mostly PR, weren't coordinated.
- Pagan strategy: attack enemy civilians. (wielded by both Allies and Axis, failed)

================================================================================
20200923
Curtis Yarvin Live at the Based Deleuze Release Party in LA (Mencius Moldbug)
https://www.youtube.com/watch?v=RRQO3VbJsMw
tags: concepts government politics philosophy curtis-yarvin history libertarianism monarchy
- Trolling (US-Vietnam war): draw fire from anti-aircraft so you can destroy
  them with countermissles. If you don't have countermissles, don't draw fire...
- "Hide your power level."
- History: if you can't empathize with both sides, you don't understand the
  events.
- Formal vs Informal power
  - Worst case = informal power dominates.  Informal power is unaccountable,
    thus the formal (accountable) power absorbs popuplar opposition.
  - Best case = formal power dominates, i.e. the formal structure is the actual,
    accountable structure.
- "accountable monarchy" is the best form of government.
  - Apple, Amazon, Elizabethan England
  - CEO is "completely in charge, but completely accountable (to the board)".
- "Industrial Revolution was actually the corporate revolution: people learned
  how to operate in state-like (monarchical) structures"

================================================================================
20200923
Descriptive constitution of the modern regime: a clerical oligarchy in the shell of a republic
https://graymirror.substack.com/p/3-descriptive-constitution-of-the
tags: concepts government politics philosophy curtis-yarvin history libertarianism monarchy
- Three forms of power/regime:
  1. monarchy (rule of one)
  2. oligarchy (rule of a minority)
  3. democracy (rule of a majority)
- Every stable regime must either _harness_ or _contain_ all three forms of power.
  - Since most regimes contain two and harness one, we classify a regime by the
    force it harnesses.
  - USG formal (constitution) regime: monarchy+democracy
  - USG informal (actual) regime: oligarchy (decentralized, unaccountable)
- Best form of govt: _harness_ monarchy, _contain_ oligarchy+democracy

================================================================================
20200928
Principles of any next regime: understand the purpose of government from scratch
https://graymirror.substack.com/p/4-principles-of-any-next-regime
tags: concepts government politics philosophy curtis-yarvin history libertarianism monarchy
> Better to know, than to see; better to see, than be seen; better to be seen, than noticed; better to be noticed, than feared; better to be feared, than hated; better to be hated, than beaten; better to be beaten, than killed; better you are killed, than your family. The fox has no illusions and is always, in principle, on the move.
> ...
> Absolutism, the yang of nihilism, means thinking ex nihilo: from scratch, from first principles, not relative to any specific past or present reality. Nihilists do care about reality. We care about it so much that we accept no substitutes. The motto of the Royal Society, crafted in happier times: nullius in verbum. We take no one’s word for it—that’s what it means to “believe in nothing.”

================================================================================
20200827
Interview with Zig language creator Andrew Kelley
https://news.ycombinator.com/item?id=24292437
tags: programming-language zig c low-level
- Addresses 3 problems of C++: language complexity, compilation speed, safety.
- Simplicity is a core principle (in the spirit of Clojure, Lua, Lisp)
  - example: `comptime` (compile-time introspection) is a singular mechanism
    that removes the need for special cases like generics, macros.
  - no macros
  - no generics
- "Zig's simplicity hides how revolutionary it is, both in design and in potential."
- coroutines
- C interop (more ergonomic than rust bindgen)
- recursion puts stack frames onto heap to avoid overflow

================================================================================
20200827
The unreasonable effectiveness of algorithms in boosting team happiness
https://www.balena.io/blog/the-unreasonable-effectiveness-of-algorithms-in-boosting-team-happiness/
tags: sat-solver scheduling algorithms

================================================================================
20200827
American fuzzy lop – a security-oriented fuzzer
https://lcamtuf.coredump.cx/afl/
tags: static-analysis fuzzer algorithms
https://news.ycombinator.com/item?id=22171285
AFL basic algorithm is:
    def run_test_case(input):
      # return a set() of instructions that the target executes when ran on `input`
      # or throw a CrashException if the target crashes
    def mutate(input):
      # mess with the input- flip some bits, delete chunks, set things to 0xffffffff... randomly
      # return the mutated input
    def fuzz(initial_test_cases):
      test_cases = initial_test_cases
      coverage_seen = set()
      # collect coverage from the initial inputs
      for case in test_cases:
        coverage_seen += run_test_case(case)
      while True:
        fuzzed = mutate(random.choice(test_cases))
        try:
          new_coverage = run_test_case(fuzzed) - coverage_seen
          if new_coverage:
            # ooh, this input did something we've never seen before!
            # save it, so it can be used as a starting point
            # for even more mutation
            test_cases.add(fuzzed)
            coverage_seen += new_coverage
        except CrashException:
            # we successfully crashed the target!
            # save fuzzed off to disk or something and log a happy message
- In practice, run_test_case() doesn't return a set of instructions, it's
  a bitmap / psuedo-Bloom filter of basic blocks hit. (A basic block is "a
  sequence of instructions that doesn't have any unusual control flow"--so if
  you run the first instruction in a basic block, you'll run all the rest.)

================================================================================
20200827
Guide to using YubiKey for GPG and SSH
https://github.com/drduh/YubiKey-Guide
tags: security infosec gpg ssh yubikey u2f fido mfa
> All YubiKeys except the blue "security key" model are compatible with this guide.

================================================================================
20200830
Reasons Not to Become Famous
https://tim.blog/2020/02/02/reasons-to-not-become-famous/
tags: security privacy paranoia identity-theft
- Fame is for suckers (status games).
- Use a UPS Store or other off-site mailing address for receiving packages.
  Never have anything mailed to your address; your name/address will end up in
  company/government databases which are rented/traded/searchable.

================================================================================
20200922
Palantir products: Foundry, Gotham, Metropolis
https://www.quora.com/What-are-the-main-differences-between-the-Palantir-Metropolis-and-Gotham-platforms
tags: technology startup surveillance data data-mining datasets data-management data-science statistics visualization tools machine-learning
Foundry:
- Versioning. Foundry explicitly tracks future state, independent of (and in addition to) past state. You can branch out to apply different versions of code against the same chunk of data and track, for each version of the data, which version of the code was used to create it. So you can understand what you knew at a point in time, and how the data has evolved since.
- Branching. Building a more explicit orchestration system, and cleaned up the general idea of the "pipeline". Instead of a system that just moves data from point A to point G, we built a system that lets you move data from point A to point G, then look back at point F and say “Hey, that was interesting. Let's try some different, random variation, but make sure A-G is still happening.” Work is safe by default, and you have the freedom to test novel ideas without impacting other users.
- Truly “democratizing” data. Creating a front end that empowers a very broad range of users to engage with data. We wanted people to be able to explore and adapt all the data they could access, in ways that are typically limited to very technical users. Today, Foundry is a platform that provides universal, secure access to all of an organization's content, for decision makers at every level, from the factory floor to the executive office.
concepts:
- "Ontology": a common model for integrated data that an organization can customize to represent their world. Instead of spreadsheets, columns, and rows that only people who are fluent in data understand, we model the world using concepts that everyone understands, like planes or cars or customers. Now all users in an organization speak the same language (and they customize their ontology, so they're speaking their language).

================================================================================
20200929
Skin in the Game | Nassim Nicholas Taleb | Talks at Google
https://www.youtube.com/watch?v=uv6KLbkvua8
tags: statistics game-theory power politics government systems nassim-taleb monarchy
- Negative golden rule: don't do to others what you wouldn't want done to you.
- Accountability:
  - "Experts" of macro systems are not falsifiable; impossible to verify cause-effect in a macro system.
    - Thus such experts "do not have skin in the game" (unaccountable).
  - Progressive bureaucrats today can start horrific wars, are less accountable than monarchs.
- Any political opinion must have a scale attached to it.
- Courage (risk-taking) is the highest virtue.  https://twitter.com/nntaleb/status/1307571044744671232
  - A public intellectual who doesn't take risks cannot be trusted.
    - "Why do I insult people in my books? Because it signals risk-taking."
  - "Start a business. We're tired of people who want to work for NGOs."
- dynamic vs static
  - healthy economy if incumbent players are at risk
  - unhealthy economy if incumbent players are effectively permanent
- History tends to "revert to the truth", like "reversion to the mean".
- Antifragile: trial and error always outperforms design.

================================================================================
20201011
Did Instagram Bro Hero Dan Bilzerian Get His Start Thanks to His Father's Dirty Money?
https://www.vice.com/en/article/8gk84v/did-instagram-bro-hero-dan-bilzerian-get-his-start-thanks-to-his-fathers-dirty-money-827
tags: finance business sec
> The web of assets that Paul Bilzerian wove in the 90s is extremely intricate.
> If you're inclined, you can look at numerous SEC filings, like this:
> https://www.sec.gov/Archives/edgar/data/786620/0000950144-98-000647.txt
> or this:
> https://www.sec.gov/Archives/edgar/containers/fix023/1053710/0000950144-98-013882.txt
> which are complicated to the point of essentially being written in code. If
> you manage to decipher them, you can find stuff out like this: In 1995, Paul
> Bilzerian and his wife, Terri Steffen, established the Paul A. Bilzerian and
> Terri L. Steffen Family Trust of 1995, which was the limited partner of
> Overseas Holdings Limited Partnership, which was owned by another entity
> called Overseas Holding Company. Overseas Holdings Limited Partnership owned
> stake in Cimetrix, a Utah software company of which Bilzerian was once
> president. So Bilzerian could move the money he technically didn't have
> around, like when Overseas Holding Company "borrowed" $90,000 from Bicoastal
> Holding Company, whose sole stockholder was... Terri Steffen.
> ...
> Dan, Paul Bilzerian's former lawyer David Hammer, and Caligula entered into a partnership called Haircut Partners, LLP, in an attempt to collect debts from Bicoastal Holding Company, one of Paul Bilzerian's companies, by forcing it into involuntary bankruptcy. (Remember, they were one of the entities involved in Cimetrix.)
> ...
> Even with highly public figures, it's virtually impossible to figure out where their money is,

================================================================================
20201012
https://kalzumeus.com/2020/10/09/four-years-at-stripe/
tags: startup growth business organization-theory scale
> (In a way, every scaling startup is an experiment in empirical microeconomics
> research on “What parts of the typical corporate form are necessary and which
> are pageantry which we only keep around due to anchoring, the sunk cost
> fallacy, and tradition?” Every time a startup bites the bullet and hires a VP
> of Sales, a lifecycle email copywriter, a retirements benefits administrator,
> or a cook, count that as a published result saying “Yep, we found this to be
> necessary.”)

================================================================================
20201108
Reflections on the late election
https://graymirror.substack.com/p/reflections-on-the-late-election
tags: concepts government politics philosophy curtis-yarvin history
> If anyone in the Trump administration is listening, there is exactly one
> useful thing you can do now. The President has exactly one unilateral power
> which is dangerous to the regime: the power to declassify.
>
> ... Except for weapons blueprints, America has no real secrets. Washington has
> plenty of real secrets, though. ...
>
> No harm will come to America, for instance, by publishing all State Department
> cable traffic. The whole archive. All of it. Plenty of harm will come to the
> State Department. There is not a single file at CIA whose publication would
> harm America. There are many—some quite old—which would harm our government.
>
> (And while you’re at it, Mr. President, bring the troops home—not just from
> Syria and Afghanistan, also from Germany and Japan. Leave your successor with
> American boots only on American soil. China Joe could invade the world right
> back again. But will he? Now, imagine if you’d conducted the last four years
> in this spirit.)

================================================================================
20201109
Naval Ravikant on Happiness, Reducing Anxiety, Crypto Stablecoins, and More | The Tim Ferriss Show
https://www.youtube.com/watch?v=HiYo14wylQw
tags: concepts philosophy meditation health wealth naval-ravikant
- Meditation forces you to face anxiety, radically restructure your life
- Meditate 60min x 60days => "mental state of inbox zero"
- currency = "a bubble that never pops"
- Effective self-help reduces to "choose long-term over short-term".
- Long-term thinking gets you long-term results. Short-term thinking gets you short-term results.
- Video games are a "shadow career" that substitutes for your real career.
- The modern mind is over-stimulated, the modern body is under-stimulated.
- "Hard choices = easy life, easy choices = hard life".
- Compound interest applies everywhere: relationships, money, knowledge, career, health, ...

================================================================================
20201118
Robinhood's business model
https://www.bloomberg.com/opinion/articles/2018-10-16/carl-icahn-wants-to-fight-dell-again?sref=2jPYL79S
tags: finance options stock trading markets
> Robinhood’s business model is:
>
> [high-frequency trading firms, or market makers, like Citadel Securities and
> Two Sigma Securities] give it money.
>
> It uses the money to give you free stock trades.
>
> That really is taking money from the rich (high-frequency traders) to give to the poor, sort of (millennials who want to trade stocks on their phones). Who did you think was giving it money?
>
> Not only that. Payment for order flow really is “one of the most controversial practices on Wall Street,” but the controversy tends to be confused and obfuscated. The basic idea of payment for order flow is that electronic market makers want to be left alone to quietly make the spread: They want to buy stock for $99.99 and sell it at $100.01 and clip two cents on each trade. If their orders are random—if sometimes people buy and sometimes they sell, with no pattern—then that works out well for the market makers. But their big risk is what they call “adverse selection”: Sometimes, when a customer buys 100 shares at $100.01, it then buys another 100 shares at $100.02, and another 100 shares at $100.03, and keeps going until it has bought 10,000 shares and pushed the price up dramatically. The market maker who sold it the first 100 shares—and who is probably now short and needs to go out and buy those shares at a higher price—has been run over.
>
> This is a risk of being a market maker on the public stock exchanges: Sometimes you sell 100 shares to a small retail investor and it’s random noise; other times you sell 100 shares to Fidelity and you get run over. But if a market maker can guarantee that it will only interact with retail customers—if it can filter out big orders from institutional investors—then its risk of adverse selection goes way down. The way the market maker does this is by paying retail brokers to send it their order flow, and promising those brokers that it will execute their orders better than the public markets would. (This is called “price improvement,” and allows the retail brokers to fulfill their obligation to give their customers “best execution.”) So if a stock is quoted at $99.99 bid, $100.01 offered on the public exchanges, the market maker might buy it from retail customers for $99.991 or sell it to them at $100.009. (It’s not usually much price improvement.) It can offer a tighter spread than the public markets—and have money left over to pay the retail brokers—because it doesn’t have to worry about adverse selection. If the retail broker is, say, one designed to let young people day-trade for free on their phones, then those orders are probably particularly valuable, because they are probably particularly random.
>
> There are two objections to this practice. One is that it is bad for investors whose orders aren’t sold to market makers, the institutional investors who instead trade on public stock exchanges. Payment for order flow fragments the markets, takes retail order flow away from the public stock exchanges, widens out spreads on those exchanges, and, by segregating retail and institutional orders, makes institutional execution worse. This objection is probably true! If you’re a hedge-fund manager, you should dislike payment for order flow, because it makes public markets worse for you. (If you invest through mutual funds, as I do, you should also dislike it, for the same reason.)
>
> The other objection is that payment for order flow is bad for investors whose orders are sold to market makers, the retail investors whose orders never touch the stock exchange. If the market makers are paying to get their orders, surely they are doing something nefarious with them, right? Otherwise why would they pay? This objection seems mostly wrong. Very occasionally there is some evidence of market makers doing naughty stuff with the retail orders that they buy, but for the most part, particularly for simple market orders, the result is straightforward: Retail customers are instantly able to buy stock at a price at least as good as, and usually better than, the best price available in the public markets. And the market makers pay their brokers for the privilege, so the brokers can offer cheaper (even free!) stock trades. They are unambiguously better off than they would be if their brokers didn’t sell their orders.

================================================================================
20210113
Noah Smith and the market for cruelty
https://graymirror.substack.com/p/noah-smith-and-the-market-for-cruelty
tags: history politics curtis-yarvin ww2
> What you usually find for two sides of a conflict ... is that each side tends
> to be mostly right about the other. Usually they are wrong about one big
> thing, but right about most of the other things.
> ...
> There were only two sides in World War II: everyone collaborated with either
> Hitler or Stalin.

================================================================================
20210114
Parallax
https://en.wikipedia.org/wiki/Parallax
tags: concepts physics
Displacement or difference in the apparent position of an object viewed along
two different lines of sight. nearby objects show a larger parallax than farther
objects when observed from different positions.

================================================================================
20210202
Semipredicate problem
https://en.wikipedia.org/wiki/Semipredicate_problem
tags: compsci theory concepts engineering
> when a subroutine intended to return a useful value can fail, but the
> signalling of failure uses an otherwise valid return value.
solution: Multivalued return
  example: stdout/stderr
cf. in-band signaling
  Exceptions are out-of-band.
cf. byzantine failure?

================================================================================
20210210
What happened in 1971?
https://wtfhappenedin1971.com
tags: economics mmt federal-reserve monetary-policy gold-standard
see also: https://en.wikipedia.org/wiki/Nixon_shock

================================================================================
20210210
Fed's Yellen expects no new financial crisis in "our lifetimes"
https://www.reuters.com/article/us-usa-fed-yellen-idUSKBN19I2I5
tags: economics mmt federal-reserve monetary-policy
> LONDON (Reuters) - U.S. Federal Reserve Chair Janet Yellen said on Tuesday
> that she does not believe that there will be another financial crisis for at
> least as long as she lives, thanks largely to reforms of the banking system
> since the 2007-09 crash.

================================================================================
20210218
Thomas Petterfy, CEO Interactive Brokers: We have come dangerously close to the collapse of the entire system.
https://www.reddit.com/r/GME/comments/lmbupe/thomas_petterfy_ceo_interactive_brokers_we_have/gnuw6kn
tags: economics federal-reserve stock finance
> I don't think you guys understand what the system breaking is. It's not just
> a squeeze to an irrational number (or no number), it's:
>
> - Most or all brokers and clearing houses go insolvent/bankrupt.
>
> - All shares in all accounts with a margin balance at brokers that are insolvent
>   would have some or all of their assets rehypothecated (transferred) into the
>   general fund to settle everything, leaving in place a claim, but that means
>   most accounts on margin would find some or all of their assets GONE, with
>   a note to sue the broker in it's place. Sometimes this happens to cash
>   accounts too, like at MF global, if the firms compliance is not good. I would
>   not be surprised to find some retail brokerages don't do this correctly.
>
> - This then sends the collective set of institutions into a court or regulator
>   run bankruptcy process - That means anyone on margin - GME shorts, GME longs,
>   and people who had nothing to do with the whole thing - also now have their
>   accounts frozen into that process. That in turn causes a system collapse and
>   a stock market crash generally, further depressing the value of all assets
>   elsewhere, because you'd knock out most brokers in this sort of counterparty
>   failure scenario while trying to figure out the mess.
>
> - Note that even if a broker ONLY had long GME customers, they'd still owe that
>   money to the customers but not be able to get it because of the counterparty
>   risk on short GME customers elsewhere.
>
> - Even with accelerated court action, sorting that out would take years, unless
>   the fed comes in, and provides a ton of liquidity, then sorts it out from
>   there. At that point, the government would arbitrate, and you'd not be getting
>   payments for $10,000 per share or something, they'd pick the last rational
>   price at most, and probably less, as they'd work a solution where GME issues
>   shares to serve up the need. You could also see other solutions like the index
>   fund dump all their shares OTC in a special action during the resulting halt,
>   which ends up collapsing price and serving up shares.
>
> Basically, a financial crisis where pretty much everyone loses, including the
> 95% of investors who had absolutely nothing to do with GME.

================================================================================
20210224
We don't have to live like this
https://graymirror.substack.com/p/we-dont-have-to-live-like-this
tags: curtis-yarvin politics government state libertarianism power machiavelli realpolitik
> I’m a monarchist because _we don’t have to live like this_.
>
> How could we live otherwise? We could live with a government which was
> competent. No one today—certainly not me—can even imagine how different
> a life that would be.
>
> There are actually two state capacities we can expect from a regime.
>
> One: we could have a regime which was physically competent—one that solved
> the physical problems of government—winning wars, beating pandemics, fighting
> crime, creating work, etc.
>
> Two: Spiritual state capacity is Solzhenitsyn’s “living in truth.” While it
> is normal and proper for regimes to endorse, and even defend with the secular
> arm, unprovable statements about the supernatural world, or sometimes even
> false or misleading statements about the past, a regime crosses the Mendoza
> line when it forces or pressures its subjects to believe anything about the
> real, present world that just isn’t so.
>
> A regime that can’t handle the truth truly “has the wolf by the ears.” ...
> Dissidents are those who consider the regime spiritually incompetent. The
> regime, by definition, defines itself as spiritually healthy.
>
> Maistre put it: the counterrevolution is not revolution in the opposite
> direction. (This is the essential error of fascism.) It is the opposite of
> revolution. ... Most people have no idea what this would even mean. ...
> Psychological security under a shitty regime always revolves around
> inculcating the idea that there is no alternative to the regime, or that any
> alternative would be even worse.
>
> 10 principles for "restoring the rule of law":
>
> 1. salus populi suprema lex: the sole purpose of government is to sustain the
>    well-being of its citizens. ... A regime that instead conceives itself as
>    a universal charity, whose goal is to do as much good as possible in the
>    world and in principle the galaxy, and which funds these good works by
>    taxing a population of human tax-cattle, is judged harshly by this
>    standard. ... Once the agent in a principal-agent relationship is not
>    acting solely on behalf of the principals, the relationship is corrupted;
>    it is no longer operating lawfully. There is no way to state a system of
>    law that allows the HOA manager to embezzle, but only for a good cause.
>
> 2. Every citizen is equally protected under the law.
>
> 3. The law does not notice trivia (de minimis non curat lex). ... words and
>    actions that do not cause or threaten tangible harm cannot be torts or
>    crimes.
>
> ... America in the ‘20s has to live with concepts like wrongthink and
> cancellation because the ‘60s decided to ... make it illegal to be an
> asshole. ... Whenever a fundamental principle of jurisprudence is violated,
> it is always to pervert the law into an arbitrary weapon of political
> tyranny.
>
> 4. Every citizen has freedom of association ... Is there anything really
>    wrong with an all-black software company, an all-Mormon Kia dealership, or
>    an all-Chinese Chinese restaurant? Fuck you, and fuck your blender.
>    Variety is good. Variety is human. And variety is the opposite of
>    homogeneity.
>
> 5: Collective grievances are socially unacceptable
>
> Every collective grievance is a cold civil war. ... But what we can say is
> that oblivion is peace. The fundamental principle of peace is that the world
> started yesterday.
>
> 6: Every citizen gets the same information
>
> If you have something to leak in the public interest—you must leak it straight
> to the public. ... A version of this regulation is in place in the financial
> sector—"Reg FD"—and it is one of the best regulations ever regulated.
>
> The power to intermediate authentic information is the power to rule. This is
> why we live in a press-controlled state.
>
> 7: The government makes all its own decisions
>
> A healthy organization does not extend trust outside its own permanent
> personnel.
>
> 20th-century practice is for the government to extend its trust to private
> experts. ... This power leak disrupts the epistemic process of the private
> experts, who develop an incentive to expand this life-giving canal. The
> experts naturally tend to favor ideas that generate power—a bias that works
> against reason.
>
> And by definition, they have zero accountability to go with their authority.
>
> 8: The government is liable for crime
>
> Whatever the cause or severity of its negligence, the government has failed
> in its duty and is responsible. Therefore, it must compensate the victim for
> any loss.
>
> 9: The government is financially simple
>
> A healthy government does not lend or borrow. ... it does not issue
> derivatives of any kind, formal or especially informal. Historically, when we
> see a regime breaking any of these rules... it has one purpose, which is to
> evade fiscal accountability.

================================================================================
20210307
Experience curve effect, Wright's law
https://en.wikipedia.org/wiki/Experience_curve_effects
tags: economics technology concepts mental-model
Progress increases with experience: each percent increase in cumulative
production results in a fixed percentage improvement in production efficiency.

================================================================================
20210330
Mark Sisson: "Two Meals a Day: lose fat, reverse aging"
https://open.spotify.com/episode/0YoTG8B6spV31mCHk63zqD
tags: health fasting
fasting:
- 16 hours minimum, 18 hours is better
- most repair/recovery happens when NOT eating
good:
- cholesterol is good, it was vilified bc of spurious correlation
- "starchy carbs" are ok
bad:
- sugar
- industrial seed oils (canola, soy, etc.)
- processed grains
  - cause arthritis

================================================================================
20210530
The inflation economy
http://graymirror.substack.com/p/the-inflation-economy
tags: curtis-yarvin economics federal-reserve stock finance government banking money
> 20th-century “macroeconomic” central-planners define “inflation” as AB or even
> just B, measure B, and so automatically take undeserved credit for these
> exogenous or organic mitigations. ... You can’t mitigate A, only conceal it.
>
> A is monetary dilution. B is consumer appreciation. Monetary dilution causes
> consumer price appreciation. Appreciation is a symptom; dilution is the
> disease.
>
> “Inflation” is the syndrome AB—a deceptive malapropism. The main use of this
> label is to divert attention from the simple cause A to the complex, difficult
> syndrome AB. The label “inflation” is a semantic minefield and no one should
> use it both sincerely and ambiguously. I’ll just say “inflation (A)” and
> “inflation (B).”
>
> Although we cannot measure inflation (A), or monetary dilution, directly,
> another proxy C is a better metric (though still imperfect and indirect). This
> proxy, inflation (C), is wealth appreciation.
>
> ...
>
> Simple way to measure monetary dilution: catch it at the next bend in the
> causal stream. Roughly, monetary dilution equals growth in personal net worth.
> This is the only useful and effective measurement of inflation (A).
>
> This is a graph of how much money the government has secretly given away to
> the rich. Since 1950, American personal net worth in portfolio dollars has
> gone up by about 100x.
>
> ...Effectively, the high-velocity dollars of the poor are taxed to subsidize
> the low-velocity dollars of the rich.
>
> “Investing” your low-velocity dollars means turning your savings into a kind
> of inflation antenna, which is dangerous because it is also an antenna for
> systemic risk. The biggest pools of money have high-leverage antennas and big
> fire extinguishers. (And sometimes they still catch fire—but the poor burn
> better, too.)
>
> Even before Covid, keeping the American rich (obviously, if you’re not rich,
> you don’t have a “personal net worth”), in the style to which they are
> accustomed, was costing the Fed somewhere around $10 trillion a year. In 2019,
> for instance, PNW rose from $105 trillion to $118 trillion. The gray vertical
> bars are “recessions,” in which our inflation engine somehow throws a rod and
> peters out—or even goes into reverse. 2020, of course, was a banner year for
> inflation (A), and might even print $20 trillion.
>
> ...The assets in this net worth are the capital assets of America—its farms,
> factories, houses and offices. ... To say that in some genuine and organic
> sense, the quality or quantity of any or all of these assets has increased by
> 100x since 1950, is to embrace a preposterous historical delusion.

================================================================================
20210610
Sixteen Years Old, $1.7 Million in Revenue: Max Hits It Big as a Pandemic Reseller
https://www.wsj.com/articles/sixteen-years-old-1-7-million-in-revenue-max-hits-it-big-as-a-pandemic-reseller-11623248291
tags: startup business entrepreneurship finance
> retail arbitrage ... He preordered 10 from Target’s website in September with
> a debit card, using his own savings. “It was public knowledge but most people
> weren’t starting to look that early,” he said.
>
> His early endeavors impressed his younger sister, such as when in middle
> school he sold fidget spinners at a local fair for $8 a piece after buying
> them for pennies from a vendor in China.

================================================================================
20210620
The Fedcoin experiment
https://graymirror.substack.com/p/the-fedcoin-experiment
tags: curtis-yarvin government banking federal-reserve money finance economics cryptocurrency fedcoin stablecoin
1. Once someone has the power to create money, the supply of money cannot be
   measured ("soft money").
2. In a soft monetary system, the best way to measure inflation is not to
   measure either money creation or consumer prices, but personal net worth.
Thought experiment: hard money ("essentially a national bankruptcy")
  > Merely by disabling the creation of new dollars, we’ve destroyed an entire
  > invisible world of informal options, which were the glass pillars holding up
  > what we believed was a solid and organic financial structure. With those
  > pillars shattered—well, now, it does seem odd to owe $18 trillion dollars,
  > when there are only $6 trillion dollars. Who could credibly promise 60
  > million Bitcoins?
  >
  > ... And while ideally, regulators would be intolerant of 20th-century
  > financial techniques of currency, maturity and risk transformation, these
  > manipulations would eventually blow up and teach the market their necessary
  > lesson, were private financial actors not gifted with the informal options
  > (from the Fed’s protection of FDIC, to the “Greenspan put”) which, as we
  > see, comprise most of the market’s present value. For if voiding these
  > options makes the market much less valuable, the options must be very
  > valuable.
  >
  > ... Uninsured bank runs are one path to a financial system that doesn’t have
  > bank runs. Make sure the explosion isn’t bigger than the system, though.

================================================================================
20210620
Rise of the neutral company
https://graymirror.substack.com/p/rise-of-the-neutral-company
tags: curtis-yarvin politics government realpolitik machiavelli monarchy
"Politics is the exercise of collective power against human opposition."
- "parliament" literally means "chatroom"
- Decisions should never be made communally if possible; such decisions are
  unaccountable.
- In all well-shaped organizations, power is accountable. The design hack in the
  modern joint-stock company is that the CEO has authority over all other staff,
  and all other staff are accountable to the CEO; and the CEO is accountable to
  the board, but the board has no authority to manage the CEO.The board can only
  replace the CEO—which keeps them (or the shareholders behind them) from
  micromanaging the company and turning it into another kind of oligarchy. Yet
  everyone in an operational role is fully accountable.
- The nature of oligarchy is essentially foreign to good governance, because it
  dissipates accountability. It is not even clear who is in charge. Positions of
  leadership in the chat parliament are an unpredictable, informal consequence
  of personal charisma.
- Collective action which depends not on harnessing desire, but escaping it, can
  be much more effective.
- Democracy is most effective as a transient force, used to transition from one
  absolute, non-democratic authority to another. ... This transient spirit
  implies a crowd that can follow. A crowd of leaders cannot give power, because
  their animal desire attaches them to power. ... Collectively, followers are
  more powerful. ... So the art of detachment--professional detachment, ironic
  detachment, even apathetic detachment--is actually an art of war.

================================================================================
20210620
Realpolitik
https://en.wikipedia.org/wiki/Realpolitik
tags: politics government realpolitik machiavelli
- How to achieve liberal enlightened goals in a world that does not follow liberal enlightened rules.
- As the liberal gains of the 1848 revolutions fell victim to coercive governments or were swallowed by powerful social forces such as class, religion and nationalism, Rochau began to think hard about how the work that had begun with such enthusiasm had failed to yield any lasting results.
- Became associated with Otto von Bismarck's statecraft in unifying Germany in the mid 19th century.

================================================================================
20210628
North Korean defector slams "woke" US schools
https://nypost.com/2021/06/14/north-korean-defector-slams-woke-us-schools/
tags: politics culture left progressive
> Yeonmi Park attended Columbia University and was immediately struck by what she viewed anti-Western sentiment in the classroom and a focus on political correctness that had her thinking “even North Korea isn’t this nuts.”
>
> "Every problem, they explained us, is because of white men." Some of the discussions of white privilege reminded her of the caste system in her native country, where people were categorized based on their ancestors, she said.
>
> ...she also was chided for saying she enjoyed the writings of Jane Austen.
>
> “I said ‘I love those books.’ I thought it was a good thing,” Park told the network. “Then she said, ‘Did you know those writers had a colonial mindset? They were racists and bigots and are subconsciously brainwashing you.’”

================================================================================
20210628
Parachute Pants and Central Bank Money, Randal K. Quarles
https://www.federalreserve.gov/newsevents/speech/quarles20210628a.htm
tags: government banking federal-reserve money finance economics cryptocurrency stablecoin
> A Federal Reserve CBDC (central bank digital currency) could, in essence, set
> up the Federal Reserve as a retail bank to the general public.

================================================================================
20210628
Iron law of oligarchy
https://en.wikipedia.org/wiki/Iron_law_of_oligarchy
tags: government concepts history oligarchy
- Since no sufficiently large and complex organization can function purely as
  a direct democracy, power within an organization will always get delegated to
  individuals within that group, elected or otherwise.
- Organizations eventually come to be run by a "leadership class" (paid
  administrators, executives, spokespersons, strategists, …). By controlling who
  has access to information, those in power can centralize their power
  successfully, often with little accountability, due to the apathy,
  indifference and non-participation of most rank-and-file.
- Summarized as: "Bureaucracy happens. If bureaucracy happens, power rises. Power corrupts."
- delegation is necessary in any large organization
- democracy and large-scale organization are incompatible

================================================================================
20210628
Kyklos: Aristotle's three forms of government
https://en.wikipedia.org/wiki/Kyklos
tags: government concepts oligarchy monarchy democracy
3 forms of government:
  democracy
  aristocracy
  monarchy
3 degenerate forms:
  ochlocracy (mob rule)
  oligarchy
  tyranny

================================================================================
20210702
On banning ideas
https://graymirror.substack.com/p/on-banning-ideas
tags: curtis-yarvin politics government democracy power machiavelli realpolitik
> The fundamental problem with “banning CRT” is that, while culture is
> downstream from power, no one can dam a river by taking a dump in it. Passing
> state laws against “critical race theory” is wrong and ineffective, but not
> because it goes too far—only because it goes nowhere near far enough.
>
> To be “against” something is to propound a negative—to propose a question,
> demurely admitting the lack of an answer. Dissidents will never get anywhere
> till they realize that history is asking them for answers, not questions—and
> that the larger, more imaginative and more detailed their answers, the more
> realistic these visions become.
>
> In other words, big things are easier than small things.
>
> ... To imagine that the voting taxpayers of America, through their
> democratically elected officials, should control the curricula administered to
> their children, is like suggesting that Elizabeth II should rule England. On
> paper, arguably, she does. In theory, maybe even in practice—she could again.
>
> ... Such is democratic politics in the 2020s. All the victories of democracy
> over oligarchy are temporary and symbolic; they consume the energy invested in
> them, and release no energy back; their objective effect is to (a) dissipate
> this energy, and (b) promote their promoters.

================================================================================
20210702
Russell conjugation
https://en.wikipedia.org/wiki/Emotive_conjugation
tags: concepts rhetoric language psychology
"I am firm, you are obstinate, he is a pig-headed fool."

================================================================================
20210702
Aarne–Thompson–Uther Index: catalogue of folktale types
https://en.wikipedia.org/wiki/Aarne%E2%80%93Thompson%E2%80%93Uther_Index
tags: concepts history language culture tropes
cf. TV tropes https://tvtropes.org

================================================================================
20210702
OODA loop: observe–orient–decide–act
https://en.wikipedia.org/wiki/OODA_loop
tags: concepts military tactics strategy patterns competition
- also often applied to commercial operations, learning processes.
- explains how agility can overcome raw power
- shows that all decisions are based on observations of the evolving situation
  tempered with implicit filtering
- "Orient" box: much filtering of the information through our culture, genetics,
  ability to analyze and synthesize, and previous experience
  - It is here that decisions often get stuck, which does not lead to winning.
- key insight
  - Change speed and direction faster than the opponent.
  - Getting "inside" the cycle (short-circuiting the opponent's OODA) produces
    opportunities for the opponent to react inappropriately.
  - Taking control of the situation is key. It is not enough to speed through
    OODA faster.
> The key is to obscure your intentions and make them unpredictable to your
> opponent while you simultaneously clarify his intentions. That is, operate at
> a faster tempo to generate rapidly changing conditions that inhibit your
> opponent from adapting.

================================================================================
20210702
https://github.com/wasmerio/wasmer
tags: wasm webassembly software programming embed webbrowser javascript c
https://wasmer.io/
https://github.com/wasmerio/wasmer/tree/master/lib/c-api
Wasmer is a fast and secure WebAssembly runtime that enables super lightweight containers to run anywhere.
- Secure by default. No file, network, or environment access, unless explicitly enabled.
- Supports WASI and Emscripten out of the box.
- Fast. Run WebAssembly at near-native speeds.
- Embeddable in multiple programming languages
- Compliant with latest WebAssembly Proposals (SIMD, Reference Types, Threads, ...)

================================================================================
20210722
The real Great Reset
https://graymirror.substack.com/p/the-real-great-reset
tags: curtis-yarvin politics government democracy power machiavelli realpolitik
> But in an American city, any attempt at the local suppression of disorder is no
> more than mindless, reflexive stabbing at the “Close Door” button.
>
> The funny thing is that when you talk to these East Coast optimists, they
> cheerfully admit that the actions they recommend are, in themselves,
> completely useless and ineffectual. Their theory—a Whig theory ... it is
> a sort of exercise... It will make them stronger, for the next, bigger,
> assault on the enemy.
>
> ... It is true that, for the left, useless actions can be good and
> stimulating and make further action easier—but this is only because the left is
> organizing disorder. Epsilon disorder still makes more disorder epsilon easier.
> The right is creating order—and epsilon order is utterly useless. Even if it’s
> free.
>
> ...Winning the sit-lie election in SF, then seeing the law do nothing at
> all, did not excite SF conservatives (such as they are) to greater achievements.
> It did not stimulate and energize them. It depressed and enervated them. Once
> they realized they could do nothing, they stopped doing anything.

================================================================================
20210802
Kelly criterion
https://en.wikipedia.org/wiki/Kelly_criterion
tags: finance options stock trading markets
As you increase your trade sizing / leverage you become more likely to
reach 1/2 of your starting equity before you double it, simply because the
variance in returns grow large.

================================================================================
20210818
For the times they are a-changing
https://graymirror.substack.com/p/for-the-times-they-are-a-changing
tags: curtis-yarvin politics government democracy power machiavelli realpolitik systems
> My first hypothesis is that, as usual in complex systems, the only choice of
> any latent power ... is to keep the system more or less as it is, or delete
> and replace it completely. Changing it is so impossible that the very word
> “change” has become a sinister Orwellian jargon.

================================================================================
20210822
Scalar: A set of tools and extensions for Git to allow very large monorepos
https://github.com/microsoft/scalar
tags: git dvcs programming tools
- Partial clone
- Background prefetch: downloads Git object data from all remotes every hour.
- Sparse-checkout: limits the size of your working directory.
- File system monitor: eliminates the need for Git to scan the entire worktree.
- Multi-pack-index: enables fast object lookups across many pack-files.
- Incremental repack: Repacks the packed Git data into fewer pack-file without disrupting concurrent commands by using the multi-pack-index.
(Features were merged to mainline Git, now Scalar is just a wrapper.)

================================================================================
20210906
Curtis Yarvin (aka Mencius Moldbug): an interview
https://im1776.com/2021/09/03/curtis-yarvin-interview/
tags: curtis-yarvin politics government democracy power machiavelli realpolitik systems anarchism
> it is natural to look at a hypertrophied, dysfunctional regime and say: there
> should be less of that. There should be less of the State. To any engineer,
> spontaneous orders are elegant and seem to work well; competition works well,
> bureaucracy doesn’t. Easy to start with that.
>
> Then Hoppe points out: we can see the premodern international order as
> a spontaneous order! It’s actually the ultimate in libertarianism: states are
> competing sovereign corporations. Above them, there is no government at all
> — a global anarcho-libertarian paradise of armed ‘sovcorps’.
>
> Yet strangely, in this ultra-libertarian model, states are not libertarian at
> all! A nation is a land and its settled people. The sovcorp owns both
> — because who else would? ...
>
> Hoppe goes on to point that a hereditary monarchy in the classic European
> style, far from being a barbaric relic, is simply a sovcorp that’s a family
> business. Because the time horizon of a family is indefinite, like the time
> horizon of a state, the hereditary monarch exhibits the least tension between
> personal and national interests.
>
> An absolute hereditary monarch has no interest in employing a dysfunctional
> bureaucracy. Since he wants to see his nation thrive, he is more likely to
> adopt the economic and social system that seems to make nations thrive:
> libertarian capitalism. So we come full circle, in a kind of layer-cake of
> libertarianism, then absolute monarchy, then more libertarianism. 
>
> ... Jünger distinguishes between the “anarch,” who remains aloof from power
> and strives to retain his mental independence from it, and the “anarchist,”
> who acts out his resistance to power, usually because of uncontrolled desire
> for power. It is always the anarchist who goes to the gulag — the anarch, in
> fact, is often safer than even the true believer.
>
> ... But while the anarch always complies, he never submits. Being ordered to
> wear a turban cannot in any way make him a Sikh; not only that, it cannot even
> make him an anti-Sikh. Power owns his body, but has no purchase at all on his
> soul.
.
- "This detachment from partisan commitments allows for a tremendous amount of interior freedom."
- cathedral’s tendency toward “dominant ideas” rather than true or beautiful ideas

================================================================================
20210909
htmlq: Like jq, but for HTML
https://github.com/mgdm/htmlq
tags: web tools programming query html shell cli
Uses CSS selectors to extract content from HTML files.

================================================================================
20210922
"Exception handling is a giant mistake."
https://news.ycombinator.com/item?id=28164247
tags: programming softwareengineering language-design pl-design exceptions control-flow failure-modes
https://twitter.com/WalterBright/status/1426013845277925382
> Working with and implementing C++ exceptions for 30 years now, including implementing exception handling for Windows, DOS extenders, and Posix (all very different), and then re-implementing them for D, I have sadly come to the conclusion that exceptions are a giant mistake.
> 1. they are very hard to understand all the way down
> 2. they are largely undocumented in how they're implemented
> 3. they are slow when thrown
> 4. they are slow when not thrown
> 5. it is hard to write exception-safe code
> 6. very few understand how to write exception-safe code
> 7. there is no such thing as zero-cost exception handling
> 8. optimizers just give up trying to do flow analysis in try-exception blocks
> 9. consider double-fault exceptions - there's something that shows how rotten it is
> 10. has anyone yet found a legitimate use for throwing an `int`?
> I have quit using exceptions in my own code, making everything 'nothrow'. I regret propagating exception handling into D. Constructors that may throw are an abomination. Destructors that throw are even worse.

================================================================================
20210924
Why We Killed Our End-to-End Test Suite
https://building.nubank.com.br/why-we-killed-our-end-to-end-test-suite/
tags: programming softwareengineering ci continuous-integration testing devops release-engineering
End-to-end integration tests:
  1. Waiting. Engineers wait more and more to get feedback from this long-running suite.
  2. Lack of confidence. Flaky tests => re-run to confirm false negative.
  3. Expensive to maintain. Manual changes in our staging environment corrupted test data fixtures and maintaining the environment “clean” was a challenge.
  4. Failures don’t point to obvious issues. Test failures were very hard to debug, specially due to our reliance on asynchronous communication that make it hard to connect the cause of failure (a message not published to a queue) with its effect (changes not made in another system).
  5. Slower value delivery. Queueing of commits => less frequent deployments.
  6. Not efficient. Few bugs caught in this stage. For every 1000 runs, we had 42 failures, only 1 bug.
  7. Not effective. Bugs were still being found in production.
Alternative: combination of:
  - Consumer Driven Contract (CDC) testing
  - Acceptance tests (limited E2E) for critical paths
  - Feature flags
  - Percentage rollouts ("dialup")
  - A/B testing

================================================================================
20210519
SSH + security key
https://github.blog/2021-05-10-security-keys-supported-ssh-git-operations/
tags: git ssh security 2fa tfa mfa authentication

================================================================================
20210525
Google Quantum AI campus
https://blog.google/technology/ai/unveiling-our-new-quantum-ai-campus/
tags: google hardware research compsci
To build better batteries, fertilizer, medicines, we need to:
- understand and design molecules better
- simulate nature accurately
With an error-corrected quantum computer, we could simulate how molecules behave
and interact, so we can test and invent new chemical processes and new materials
before investing in costly real-life prototypes.
1. To get there (years), we must build the world’s first “quantum
   transistor”--two error-corrected “logical qubits” performing quantum
   operations together--and then figure out how to tile hundreds to thousands of
   them to form the error-corrected quantum computer. That will take years.
2. To get *there* (years), we need to show we can encode one logical qubit--with
   1,000 physical qubits. Using quantum error-correction, these physical qubits
   work together to form a long-lived nearly perfect qubit--a forever qubit that
   maintains coherence until power is removed, ushering in the digital era of
   quantum computing.
3. And to get *there* (years), we need to show that the more physical qubits
   participate in error correction, the more you can cut down on errors in the
   first place--this is a crucial step given how error-prone physical qubits
   are.

================================================================================
20210525
WASI: Portable System Interface for WebAssembly
https://github.com/bytecodealliance/wasmtime/blob/main/docs/WASI-overview.md
tags: wasm wasi web webassembly api os portability
Specifies "syscalls": functions provided by the surrounding environment that can do I/O on behalf of the program.
Capability-based security
  Similar to how core WebAssembly provides no ability to access the outside world without calling imported functions, WASI APIs provide no ability to access the outside world without an associated capability.
  For example, instead of a typical `open` system call, WASI provides an `openat`-like system call, requiring the calling process to have a file descriptor for a directory that contains the file, representing the capability to open files within that directory.
Example: https://github.com/bytecodealliance/wasmtime/blob/main/docs/WASI-tutorial.md
  $ rustup target add wasm32-wasi
  # Install a WASI-enabled Rust toolchain.
  $ cargo build --target wasm32-wasi
  # Build the rust program targeting WASI.
  $ wasmtime demo.wasm test.txt /tmp/somewhere.txt
  error opening input test.txt: Capabilities insufficient
  # The --dir= option instructs wasmtime to preopen a directory, and make it available to the program as a capability
  $ wasmtime --dir=. --dir=/tmp demo.wasm test.txt /tmp/somewhere.txt

================================================================================
20210928
Thoughts on Clojure UI framework
https://tonsky.me/blog/clojure-ui/
Tweak and reuse
  fun MaterialButton(text) {
      Hoverable {
          Clickable {
              RoundedRectangleClip {
                  RippleEffect {
                      SolidFill {
                          Padding {
                              Text(text) } } } } } } }
  a. Internals are perfectly composable with each other, and
  b. It’s trivial to write your own button!
First‑class rendering access
Layout: three inspirations:
  1. one‑pass layout algorithm from Flutter: https://www.youtube.com/watch?v=UUfXWzp0-DU
  2. Subform layout, which that layout system can be beautiful and symmetric, the
     same units can be used for everything. https://subformapp.com/articles/why-not-flexbox/
  3. Parents should position children. Spacing is a part of the parent’s layout,
     thus margins are considered harmful. (components should not affect anything
     outside)

================================================================================
20211007
Powers of 10: Time Scales in User Experience
https://www.nngroup.com/articles/powers-of-10-time-scales-in-ux/
tags: work productivity focus concentration flow attention psychology
- "flow" is lost after 10 seconds

================================================================================
20211008
AWS federation comes to GitHub Actions
https://awsteele.com/blog/2021/09/15/aws-federation-comes-to-github-actions.html
tags: aws github federation authentication login secrets programming ci continuous-integration testing devops automation release-engineering
> GitHub Actions has new functionality that can vend OpenID Connect credentials
> to jobs running on the platform. ... CI/CD jobs no longer need any long-term
> secrets to be stored in GitHub.
>
> How it works:
> 1. You need an AWS IAM OIDC identity provider and an AWS IAM role that GitHub
>    Actions can assume. You can do that by deploying this CloudFormation
>    template ...
> 2. You need the GitHub workflow definition in a repo:
>    ...
>    curl -H "Authorization: bearer $ACTIONS_ID_TOKEN_REQUEST_TOKEN" "$ACTIONS_ID_TOKEN_REQUEST_URL" | jq -r '.value' > $AWS_WEB_IDENTITY_TOKEN_FILE
>    ...
>
> It works because the AWS SDKs (and AWS CLI) support using the
> AWS_WEB_IDENTITY_TOKEN_FILE and AWS_ROLE_ARN environment variables since AWS
> EKS needed this.
https://github.blog/changelog/2021-10-27-github-actions-secure-cloud-deployments-with-openid-connect/
https://github.com/github/roadmap/issues/249

================================================================================
20211008
AWS SSM Session for Javascript
https://github.com/bertrandmartel/aws-ssm-session
tags: aws ec2 cloud ssm javascript nodejs
Javascript library for starting an AWS SSM session compatible with Browser and NodeJS

================================================================================
20211019
nodejs/node: stdout/stderr buffering considerations #6379
https://github.com/nodejs/node/issues/6379
tags: libuv javascript nodejs buffering system os
> Problem:
> 1. Many calls to console.log() (e.g. in a loop) could chew up all memory and die.
> 2. Output is sometimes truncated/dropped.
>
> The output has an implicit write buffer (because non-blocking) of unlimited size.
>
>> Of course a huge while/for loop with a ton of non-blocking IO is going to cause problems. Don't do it.
>>
>>> Either blocking tty writes or graceful drain of stdout/stderr upon
>>> process.exit() would fix the problem at hand with truncated tty output.
>>>
>>>> Logging to the console 10000000 times in a tight loop is not real life behavior.
>>>> Performance-oriented servers rarely log to the console, and when they do it's important that the information is output.
>>>>
>>>>> It's not like C where the data is buffered in libc and can be flushed.
>>>>> The unflushed data is in some Javascript data structure in V8 and the event loop has been halted.

================================================================================
20211019
The Beginning of Infinity
https://nav.al/infinity-1
tags: science epistemology philosophy naval-ravikant evolution memetics concepts
- scientism
  > The overwhelming majority of physicists are still Bayesian ... [because] this
  > is typically what’s taught in universities and this is what passes for an
  > intellectually rigorous way of understanding the world.
  >
  > But it is a species of scientism. It’s because they have a formula behind
  > them, the Bayes theorem, which is a perfectly acceptable statistical formula.
  > People use it all the time in perfectly legitimate ways. It’s just that it’s
  > not an epistemology. It’s not a way of guaranteeing, or even being confident,
  > that your theory is actually true.
  >
  > My favorite example of this: Prior to 1919, every single experiment that was
  > done on gravity showed that it was consistent with Newton’s theory of gravity.
  > What do Bayesians say in that situation? They say you’re getting more and more
  > confident in Newton’s theory.
- exceptional
  > conjectures and their refutations and error correction is how we improve
  > knowledge. With genetic evolution, genetic mutations, variation and natural
  > selection weed out the ones that didn’t work. Memetic evolution ... weeds
  > out the ideas that don’t work.
  >
  > Working within the current laws of physics, humans are capable of maximal
  > knowledge and maximal awareness. That points to a world where humans are
  > exceptional and not just another form of bacteria that got out of control
  > and overran this planet.
  >
  > [This suggests] humans are special, knowledge is infinite, and as long as we
  > don’t destroy the means of error correction and we’re always creating new
  > knowledge, there’s good reason to be optimistic.
- Taleb: "since one small observation can disprove a statement, while millions
  can hardly confirm it, disconfirmation is more rigorous than confirmation."
- agi
  - GPT-3, the text matching engine that OpenAI put out ... "is parroting. It’s
    brilliant Bayesian reasoning. It’s extrapolating from what it already sees out
    there generated by humans on the web, but it doesn’t have an underlying model
    of reality that can explain the seen in terms of the unseen. And I think
    that’s critical."
- resources
  - We are at the beginning of infinity. We’re not running out of resources. Everybody’s creating ideas. Smart alien civilizations trade ideas and successful human civilizations trade ideas. Because those ideas take things that were useless before and turn them into resources.
    - So if we encounter an alien species, we should probably rejoice. They don’t want anything from our planet other than our ideas. And the best way to trade ideas is to have a dynamic, abundant, thriving civilization.
  - "convergent feature" of evolution: a biological feature that emerges again
    and again, independently.
    - Example: wings. Fish have wings of a certain kind. There are flying fish.
      Insects have wings. They arose in mammals as well. Independently, in all
      these species, the wings keep arising.
    - Example: eyes
    - Example: organs for sound
  - A resource is just something that through knowledge you can convert from one thing to another.
    - To a caveman very few things are resources—just a few edible plants/animals.
    - Domestication, harvesting crops, metallurgy, chemistry, physics, developing engines and rockets—are all taking things that we thought were worthless and turning them into resources. Uranium has gone from being completely worthless to being an incredible resource.
  - The finite resource model of the world implicitly assumes finite knowledge, that knowledge creation has come to an end, we are stuck and therefore based on our current knowledge these are all the resources available to us. Now we must start conserving.
- compromise
  - Popper vs Plato: Democracy is the system which allows you to remove policies
    and rulers most efficiently without violence.
    - error-correction mechanism, like science
    - "via negativa"
  - the poverty of compromise: in a situation where person A has idea X and
    person B has idea Y, "compromise" is somewhere between X and Y: theory Z. No
    surprise if theory Z proves not to work, because neither person ever thought
    it was the best idea in the first place. Person A goes back to saying, “I
    always told you that X was the correct idea,” and person B goes back to
    saying, “I always told you that idea Y was the best idea.” They haven’t made
    any progress whatsoever. They’ve shown that Z is wrong, but no one ever
    thought that Z was correct in the first place. This happens in science
    sometimes, and everywhere in politics.
- groups, consensus
  - Groups search for consensus, individuals search for truth.
  - > Social sciences are completely corrupted.
    >
    > First, they need to appeal to society for funding, so they are politically
    > motivated. Then, they themselves are influenced in society because the
    > studies and models are used to drive policy. So, of course, that ends up
    > corrupted as well. Now even the natural sciences are under attack from the
    > social sciences, and they’re becoming more and more socialized.
    >
    > The more groupthink you see involved, the farther from the truth you
    > actually are. You can have an harmonious society while still allowing
    > truth seekers within the society to find truth and to find the means to
    > alter and improve reality for the entire group.
  - Rory Sutherland has a great quote: “Marketing is the science of knowing what
    economists are wrong about.”
  - Academics mistakes about ergodic reasoning: they assume what’s good for the
    ensemble is good for the individual.
  - Groups never admit failure, instead just make excuses.
  - A group that tries to change its mind has a schism (divergence, infighting).
  - Nonprofits tend to always declare victory. A lot of congratulations, but nothing gets done. Because there is no objective feedback, it's all "social profit". They can't fail, they misdirect resources.
  - If you want to improve the world, the best way it is a for-profit because they have to take feedback from reality.

================================================================================
20211022
How To Speak by Patrick Winston
https://www.youtube.com/watch?v=Unzc731iCUY
tags: public-speaking presentation talk
- start with a promise (value proposition)
- use props (extremely effective mnemonics)
- surprisingly, audience needs only ONE example to learn a concept
- how to stop: say what you have done (the takeaway).
  - last slide should always say the takeaway.
  - do NOT end with a "questions?" or "thank you" slide, it wastes opportunity to show the takeaway for as long as possible.

================================================================================
20211024
Putin Gets It. Why Don’t We?
https://www.theamericanconservative.com/dreher/putin-soft-totalitarianism-live-not-by-lies-wokeness/
tags: politics culture left progressive russia putin communism
Putin:
  “We see with bemusement the paralysis unfolding in countries that have grown accustomed to viewing themselves as the flagships of progress,” Putin said during an event where he spoke for a few hours. “Of course, it’s none of our business or what is happening, the social and cultural shocks that are happening in some countries in the Western countries, some believe that aggressive blotting out of whole pages of your own history, the affirmative action in the interest of minorities, and the requirement to renounce the traditional interpretation of such basic values as mother, father, family, and the distinction between sexes are a milestone … a renewal of society.”
  “The preparedness of the so called social progress believe that the bringing a new conscience, a new consciousness to humanity, something that is more correct,” Putin said. “But there is one thing I would like to say: The recipes they come up with are nothing new. Paradoxical as it may seem, but this is something we saw in Russia. It happened in our country before after the 1917 revolution, the Bolsheviks followed the dogmas of Marx and Engels. And they also declared that they would go into change the traditional lifestyle, the political, the economic lifestyle, as well as the very notion of morality, the basic principles for a healthy society. They were trying to destroy age and century long values, revisiting the relationship between the people, they were encouraging informing on one’s own beloved, and families. It was hailed as the march of progress. And it was very popular across the world and it was supported by many, as we see, it is happening right now.”
  “Incidentally, the Bolsheviks were absolutely intolerant of other opinions, different from their own,” Putin continued. “I think this should remind you of something that is happening. And we see what is happening in the Western countries, it is with puzzlement that we see the practices Russia used to have and that we left behind in distant path, the fight for equality and against discrimination turns into an aggressive dogmatism on the brink of absurdity, when great authors of the past such as Shakespeare are no longer taught in schools and universities because they announced as backward classics that did not understand the importance of gender or race.”
  “In Hollywood there are leaflets reminding what you should do in the cinema, in the films, how many personalities and actors you’ve got, what kind of color, what sex, and sometimes it’s even even tighter and stricter than what the Department of Propaganda of the Soviet Communist Party Central Committee did,” he said. “And the fight against racism, which is a lofty goal, turns into a new culture, cancel culture, and into reverse discrimination, racism on the obverse. And it brings people apart, whereas the true fighters for civic rights, they were trying to eliminate those differences. I asked my colleagues to find this quote from Martin Luther King, and he said, ‘I have a dream, that my four little children will one day live in a nation where they will not be judged by the color of their skin, but by the content of their character.’ That is a true value.”
  “You know, the Bolsheviks were speaking about nationalizing not just the property, but also women,” Putin continued. “The proponents of new approaches go so far as they want to eliminate the whole notions of men and women, and those who dare say that men and women exist and this is a biological fact, they are all but banished. Parent number one, parent number two, or the parent that has given birth, or instead of breast milk, you say human milk. And you say all of that, so the people who are not sure of their sexual agenda are not unhappy.”

================================================================================
20211105
Software Statement
https://datatracker.ietf.org/doc/html/rfc7591#page-14
tags: rfc oauth web json internet ietf
- Like a "signed user agent"?
- A software statement is a JSON Web Token (JWT) [RFC7519] that asserts
  metadata values about the client software as a bundle.
  - presented to the authorization server as part of a client registration request
  - MUST be digitally signed using JSON Web Signature (JWS) [RFC7515]
  - MUST contain an "iss" (issuer) claim denoting the party attesting to the
    claims in the software statement.
  - using the "RS256" signature algorithm
  - the "software_id" field allows authorization servers to correlate different
    instances of software using the same software statement.
- Example:
    {
      "software_id": "4NRB1-0XZABZI9E6-5SM3R",
      "client_name": "Example Statement-based Client",
      "client_uri": "https://client.example.net/"
    }

================================================================================
20211117
Ergodicity
https://en.wikipedia.org/wiki/Ergodicity
tags: physics concepts mental-model statistics
- Ergodicity expresses the idea that a point of a moving system, either
  a dynamical system or a stochastic process, will eventually visit all parts of
  the space that the system moves in, in a uniform and random sense. This
  implies that the average behavior of the system can be deduced from the
  trajectory of a "typical" point. Equivalently, a sufficiently large collection
  of random samples from a process can represent the average statistical
  properties of the entire process.
- Ergodicity is a property of the system; it is a statement that the system
  cannot be reduced or factored into smaller components.
- Ergodic systems capture the common-sense notions of randomness, such that
  smoke might come to fill all of a smoke-filled room, or that a block of metal
  might eventually come to have the same temperature throughout, or that coin
  flips coin may come up heads and tails half the time.
- Taleb: "Average of the function != function of the averages!"
- ~Law of Large Numbers?

================================================================================
20211121
FDR Writes a Policy in Blood - Thomas Fleming, 2009
https://www.historynet.com/fdr-writes-policy-blood.htm
tags: history foreign-policy politics history fdr eisenhower ww2
- FDR: "The elimination of German, Japanese and Italian war power means the unconditional surrender by Germany, Italy, and Japan"
  - Churchill was dumbfounded by Roosevelt’s announcement—and dismayed by its probable impact.
- At the close of World War I, Theodore Roosevelt insisted on unconditional surrender.
- From WW1, FDR acquired an intense hatred for Germany.
- Hitler's repudiation of the war guilt clause in the Treaty of Versailles and his reckless aggressions had convinced FDR that TR and General Pershing had been correct.
- the Germans offered to ... arrange for a peaceful surrender of the western front—if unconditional surrender were modified. Donovan rushed to the White House, only to discover FDR had no desire to negotiate with “these East German Junkers.”
- Churchill on Germans: "They combine in the most deadly manner the qualities of the warrior and the slave."
  Churchill on Prussia: "The core of the pestilence.”
- 1943 Stalin told FDR "unconditional surrender" policy was a very bad idea.
- 1944 Gen. George Marshall and the Joint Chiefs of Staff submitted a memorandum to the president, “a reassessment of the formula of unconditional surrender.”
- 1944 FDR: “We have got to be tough with Germany and I mean the German people, not just the Nazis. You either have to castrate [them] or you have got to treat them…so they can’t just go on reproducing people who want to continue…[as] in the past.”
  - Morgenthau Plan ... proposed to divide Germany into four parts, destroying all the industry in the Ruhr and Saar basins, and turning Central Europe and the German people into agriculturists. “I don’t care what happens to the population”.
  - Churchill agreed with Edmund Burke, that you cannot indict an entire nation. ... it would be like chaining England to a dead body.
- 1944: the Wehrmacht stunned the British and Americans by assembling 250000 men and 1000 tanks ... The fighting and dying in Battle of the Bulge became a saga of American courage. But in light of what we now know about unconditional surrender, it may have been unnecessary.
  - continued resistance cost Americans 418791 dead and wounded ... the bitter fruit of unconditional surrender.
- The last nine months of horror in Ohrdruf and the other camps might have been prevented had hatred not been the arbiter of Anglo-American diplomacy throughout the war.
- Germany was the economic heart of Europe ... to eviscerate it would have crippled the continent’s prosperity.

================================================================================
20211121
Notes on Software Development Waste - Henrique Carvalho Alves
https://hcarvalhoalves.github.io/software-development-waste/
tags: softwareengineering methodology project-management programming

================================================================================
20211121
Running a Star
https://operators.urbit.org/guides/running-a-star
tags: urbit app p2p programming technology network sysadmin

================================================================================
20211121
Urbit/ Network explorer
https://network.urbit.org/
tags: urbit app p2p programming technology network

================================================================================
20211122
Next big step for PLs?
https://graydon2.dreamwidth.org/253769.html
tags: programming softwareengineering language-design pl-design exceptions errors control-flow design failure-modes
- What next for PLs?
  - Modules
  - Errors: interlocking protocols that support error management
      - abstraction leakages / design tradeoffs in current approaches:
        modularity, compositionality, locality, synchronicity, soundness,
        cognitive load, implementation costs, interface costs.
  - Coroutines
  - Pattern-matching
  - Metaprogramming (+ simpler grammars, compilation models)
- why pattern-matching: users write shorter, simpler and less failure-prone
  programs when they can express a task in pattern/action form, and that
  pattern-sets are amenable to extremely helpful static analysis / diagnosis
  along the lines of exhaustiveness checking, equivalence checking, emptiness
  checking

================================================================================
20211127
Engineering Fundamentals Checklist
https://microsoft.github.io/code-with-engineering-playbook/ENG-FUNDAMENTALS-CHECKLIST/
tags: programming softwareengineering engineering project-management runbook guidelines

================================================================================
20211127
Google Technical writing style guide
https://developers.google.com/style/highlights
tags: documentation programming softwareengineering engineering project-management guidelines google
- no "please":
  https://developers.google.com/style/tone#politeness-and-use-of-please
  https://docs.microsoft.com/en-us/style-guide/a-z-word-list-term-collections/p/please
  https://github.com/rackerlabs/docs-aws/blob/master/docs/style-guidelines.md

================================================================================
20211127
Microsoft Writing Style Guide
https://docs.microsoft.com/en-us/style-guide/welcome/
tags: documentation programming softwareengineering engineering project-management guidelines microsoft

================================================================================
20211127
Don't Go Down the Rabbit Hole - Charlie Warzel
https://www.nytimes.com/2021/02/18/opinion/fake-news-media-attention.html
tags: research critical-thinking politics propaganda
> Critical thinking, as we’re taught to do it, isn’t helping in the fight against misinformation.
> SIFT:
>   1. Stop.
>   2. Investigate the source.
>   3. Find better coverage.
>   4. Trace claims, quotes and media to the original context.
>
> “The internet offers this illusion of explanatory depth,” he said. “Until 20
> seconds ago, you’d never thought about, say, race and IQ, but now, suddenly,
> somebody is treating you like an expert. It’s flattering your intellect, and
> so you engage, but you don’t really stand a chance.”
>
> SIFT is not an antidote to misinformation. ... If powerful, influential people
> with the ability to command vast quantities of attention use that power to
> warp reality and platforms don’t intervene, no mnemonic device can stop them.

================================================================================
20211128
To Firmly Drive Common Prosperity - Xi Jinping
https://www.neican.org/to-firmly-drive-common-prosperity/
tags: china economics history politics government
> Common prosperity is an essential requirement of socialism. ... [it] does not
> mean prosperity for a [selected] few, nor is it neat and tidy egalitarianism.
>
> - Encourage industriousness and innovation as means to prosperity. We must ...
>   enhance the human capital of the entire society and professional skills,
>   improve the people’s ability to find employment and start businesses, and
>   strengthen their capability to get rich. We must prevent social
>   stratification, open up channels for upward mobility, create opportunities
>   for more people to become rich, form a development environment with
>   participation from everyone, and avoid [the phenomena of] “involution” and
>   “lying flat”.
> - While giving full play to the important role of the public sector economy in
>   driving common prosperity, we must also promote the healthy development of
>   the non-public sector economy ... While we should allow some people to get
>   rich first, [they shall] lead and assist those who are not yet rich. We
>   shall focus on encouraging industriousness, legal business operations, and
>   those leaders of wealth acquisition who dare to pioneer.
> - We must base the protection and improvement of the livelihood of the people
>   on economic development and financial sustainability rather than unrealistic
>   pursuits and expectations, and promises that cannot be fulfilled. The
>   government cannot take care of everything. ... Even if we reach a higher
>   level of development and acquire stronger financial resources in the future,
>   we should not set aims that are excessively high, and/or provide excessive
>   guarantees. We must resolutely prevent [ourselves] from falling into the
>   trap of nurturing lazy people through “welfarism.”
> - Make sure [students] acquire specialisations and learn what is useful.
> - We must improve the business environment [for small business owners], reduce
>   their burden of taxes and fees.
> - After many years of exploration, we have a complete solution to the problem
>   of poverty, but we still have to explore and accumulate experience on how to
>   attain prosperity. We must protect property rights and intellectual property
>   rights, and protect legitimate wealth creation.
> - Not all people will become rich at the same time, nor will all regions reach
>   the same level of affluence at the same time.

================================================================================
20211130
Effective altruism and Xi Jinping Thought
https://graymirror.substack.com/p/effective-altruism-and-xi-jinping
tags: china economics curtis-yarvin history politics government democracy power machiavelli realpolitik systems anarchism
> Modern China exists because Mao created a dictatorship so strong that, when
> Deng inherited it, he found it could contain the economic aristocracy of
> capitalism. It was okay to get rich in China; the Party was strong, and rich
> men did not threaten it. The USSR was never strong enough to tolerate the
> imperium in imperio of capitalism—the secondary statelike structures of
> private businesses—so it died for economic reasons.
>
> But politically containing a cultural aristocracy, without suppressing it
> (thus creating a dangerous vacuum) is an even harder problem. China has no
> answer—nobody has an answer. It has never been done. Which doesn’t mean it
> can’t be done…
>
> Any regime is unstable if it does not contain and control all three forms of
> political power: monarchy, aristocracy, and democracy. A regime built on the
> Chinese model contains monarchy and controls democracy; it has no answer for
> aristocracy, other than to suppress it into some bourgeois democratic pattern.
>
> This worked in China because of its tremendous 20th-century aristocide;
> nothing similar has happened, or of course should happen, in the West. Yet the
> West’s aristocracy is eating it alive. If only they could all convert to Xi
> Jinping Thought…

================================================================================
20211220
Zeigarnik effect
https://en.wikipedia.org/wiki/Zeigarnik_effect
tags: work productivity focus concentration flow attention psychology
We tend to remember unfinished/interrupted tasks better than completed tasks.
Review your list of completed tasks helps counteract this.

================================================================================
20211221
European privacy-consciousness hypocrisy
https://news.ycombinator.com/item?id=29623512
tags: government europe germany privacy
> They champion getting rid off tax-privacy, they champion getting rid off
> non-digital currency, they champion blocking social-networks because of
> "foreign desinformation" (i.e. domestic opposition), they take no offense that
> a think-tank owned for-profit media-conglomerate does the domestic deletion
> and blocking of social media accounts (Bertelsmann > Arvato -> FB/Twitter/…).
>
> And most hilariously, progressive luminaries like Daniel Cohn-Bendit or Volker
> Beck – which during the 1980s gained political traction by "fighting" against
> having A NATIONAL CENSUS AT ALL – are nowadays championing throwing out
> medical-data privacy alltogether and having to hand out your unlocked phone to
> the police at their whim.

================================================================================
20211221
CIA (OSS) Simple Sabotage Field Manual (1944)
https://www.hsdl.org/?abstract&did=750070
tags: cia organization-theory organization coordination project-management leverage
http://svn.cacert.org/CAcert/CAcert_Inc/Board/oss/oss_sabotage.html
https://news.ycombinator.com/item?id=29597454
General Interference with Organizations and Production
1. Insist on doing everything through "channels." Never permit short-cuts to be taken in order to, expedite decisions.
2. Make "speeches." Talk as frequently as possible and at great length.
3. When possible, refer all matters to committees, for "further study and consideration."
4. Bring up irrelevant issues as frequently as possible.
5. Haggle over precise wordings of communications, minutes, resolutions.
6. Refer back to matters decided upon at the last meeting and attempt to reopen the question.
7. Advocate "caution." Be "reasonable" and urge your fellow-conferees to be "reasonable" and avoid haste which might result in embarrassments or difficulties later on.
8. Be worried about the propriety of any decision-raise the question of whether such action as is contemplated lies within the jurisdiction of the group or whether it might conflict with the policy of some higher echelon.

================================================================================
20211221
libtree
https://github.com/haampie/libtree
tags: c linker programming os library
- turns ldd into a tree
- explains how shared libraries are found or why they cannot be located

================================================================================
20211221
The leadership IQ dilemma: when super smart people are perceived as ineffective leaders
https://wp.unil.ch/hecimpact/article/
tags: organization coordination startup business leadership perception psychology
- too high (or low) intelligence can have a negative impact on perceived leadership effectiveness.
- paper: Antonakis, J., House, R. J., & Simonton, D. K. (2017). Journal of Applied Psychology. Can super smart leaders suffer from too much of a good thing? The curvilinear effect of intelligence on perceived leadership behavior

================================================================================
20211221
Some of you are not yet clearpilled
https://graymirror.substack.com/p/some-of-you-are-not-yet-clearpilled
tags: curtis-yarvin history politics government democracy power machiavelli realpolitik systems anarchism activism
When power is doing the wrong thing for some dumb reason ... “be water.”
... Your action must not be reactive. Water does not push back. Water lets the enemy expend energy, expending no energy against him.
... When you are not following Bruce Lee’s wisdom, you always think you are fighting back. Usually, what you are doing is participating—giving your energy to the enemy.
Using energy against power, even successfully, does not create more energy. It just uses up energy. The main effect of Brexit was to dissipate the political energy that created Brexit. No power was created either by the symbolic victory or the tangible results.
when you are out of power, your goal is to build power, not use power.

================================================================================
20211221
Omicron and governance theater
https://graymirror.substack.com/p/omicron-and-governance-theater
tags: china economics curtis-yarvin history politics government democracy power machiavelli realpolitik systems anarchism
Governance theater:
In a world of oligarchical democracies, “press-run states” where power derives from institutional leadership of public opinion, flowing from Science to the Fourth Estate and thence out into the broadcast-media audience, the existential task of any regime is to persuade that audience that it’s doing a good job.
Governance theater displaces actual governance. In the West, where power depends on either managing or following public opinion, the idea of actual governance is almost unfamiliar. The wise experts who manage the public mind have one school of governance theater; the cynical sycophants who milk the populist mob have another.
... If our levers of power are held by the managers of public opinion, ie professors and journalists, we are an oligarchy (“liberal democracy”). If they are held by the servants of public opinion, ie politicians, we are a democracy (“authoritarian populism”).

================================================================================
20211221
horcrux
https://github.com/jesseduffield/horcrux
tags: security cryptography encryption
Split a file into encrypted fragments instead of remembering a passcode.

================================================================================
20220101
Speed matters: Why working quickly is more important than it seems
http://jsomers.net/blog/speed-matters
tags: work productivity focus concentration flow attention psychology
- If there’s something you want to do a lot of and get good at—like write, or fix bugs—you should try to do it faster.
- Being fast is fun: you’ll constantly be playing with new ideas.
- Part of the activation energy required to start a task comes from the picture you get when you imagine doing it.
- If you work quickly, the cost of doing something new will seem lower in your mind. So you’ll be inclined to do more.
  - Conversly if each blog post takes 6 months, you’ll probably avoid new blog posts because it’ll feel too expensive.
- Faster employees get assigned more work.
  - It’s exhausting merely thinking about giving work to someone slow. When you’re thinking about giving work to someone slow, you run through the likely quagmire in your head; you visualize days of halting progress.
- Systems which eat items quickly are fed more items. Slow systems starve.

================================================================================
20220101
The Gift of It's Your Problem Now
https://apenwarr.ca/log/20211229
tags: oss open-source maintenance software programming development
Healthy society is created through constant effort, by all of us, as a gift to our fellow members. It's not extracted from us as a mandatory payment to our overlords who will do all the work.
If there's one thing we know for sure about overlords, it's that they never do all the work.
Paying for gifts ... does not work: it stops being a gift. It becomes an inefficient, misdesigned, awkward market.
There's already a way to spend $100 to get the thing you want: a market.
Gifts will not, for heaven's sake, prevent developers from implementing bad ideas occasionally that turn into security holes. Nothing will. Have you met developers?
Code reviews are famously rare even in security-critical projects. Supply chain issues are rampant.
Software startups have taken off because:
1. Cloud computing has made it vastly cheaper to get started
2. Incubators like YCombinator have industrialized the process of assembling and running a small software company
3. Megacorps have become exponentially richer but no more creative, so they need to acquire.

================================================================================
20220102
Mini Tokyo 3D: realtime tokyo transportation map
https://minitokyo3d.com/
tags: transportation data visualization software web tools open-source

================================================================================
20220214
WebContainer
https://github.com/stackblitz/webcontainer-core
tags: wasm webassembly web api os portability software programming embed webbrowser javascript
(closed source / commercial)
small portable container and OS spec, secure by default, runs in the browser sandbox
Components
  - Virtual File System with lazy-loading capabilities
  - Virtual Networking
  - Multi-threaded/multi-process application support
  - Inter-Process communication/process signaling
  - POSIX-esque shell with ability to shell out between processes
Is this a Docker container?
  It's similar in the way that you can package and run Node.js code with
  minimal modifications, but your Browser serves as the OS instead of
  a separately managed virtual machine.

================================================================================
20220309
jscodeshift
https://github.com/facebook/jscodeshift
tags: tools programming ide refactor javascript typescript
jscodeshift is a toolkit for running codemods over multiple JavaScript or TypeScript files. It provides:
- A runner, which executes the provided transform for each file passed to it. It also outputs a summary of how many files have (not) been transformed.
- A wrapper around recast, providing a different API. Recast is an AST-to-AST transform tool and also tries to preserve the style of original code as much as possible.

================================================================================
20220108
Stagflation and neo-chartalism
https://graymirror.substack.com/p/stagflation-and-neo-chartalism
tags: economics finance curtis-yarvin history politics government power machiavelli realpolitik systems anarchism
as Clausewitz said, all conflicts are mainly about morale.
informal financial instruments: promises never written or stated, but known for political reasons to be good.
  An example would be the Fed’s promise to bail out FDIC—by issuing new shares. Of course, just as Microsoft can issue new shares, the Federal Reserve can create new dollars (Federal Reserve Notes). It doesn’t even need to print pieces of paper—they have computers now.
Because this promise is known to be good, it need not be tested, and the banks live. But they live by the grace of “virtual” Microsoft shares—which never need to be created, because they always can be created.
This is an extremely sneaky way to expand a balance sheet, because it means making promises which turn things that aren’t Microsoft shares (be they shares in some other company, or baseball cards, or fad NFTs) into Microsoft shares. It is bad accounting—and when governments get into bad accounting, usually other things are bad.
...
Stagflation is the near and medium future because the covid boom is unsustainable, for two reasons. One, covid is no longer a palpable emergency and will find it harder and harder to justify subsidies. Two, the Fed has pushed the dilution handle so hard that serious price inflation is actually happening.
The system, dependent on constant appreciation, is highly sensitive to a depreciative shock. Eventually this shock, a recession or depression, will elicit a political response and the whole cycle will repeat. A smart person might even be able to time it.
But the recession may not affect the causes of inflation as much as one might hope—since these causes are not the wages paid to a fully-employed domestic labor army, but global imbalances in the supply of commodities and other goods with inelastic supply (for the moment, even chips). An inflationary recession is stagflation.
So America can have huge armies of working-age people who have no idea what to do with their lives, while prices for both capital (especially houses in Malibu) and goods (whether made in China, or sucked out of the sand in Kuwait) go up and up and up. Also, New York is joining San Francisco in the ‘70s nostalgia trip. Good times!

================================================================================
20220206
Time to upgrade your monitor
https://tonsky.me/blog/monitors/
tags: workstation electronics
  recommended:
    Dell U2720Q  DP* Alt Mode    90 W    USB 2.0/3.0 **  3840 x 2160 @ 60 Hz
      https://www.dell.com/support/kbdoc/en-us/000131273/using-a-dell-ultrasharp-usb-c-monitor-with-a-mac?lwp=rt
  common resolutions:
    1080p is 1920x1080
    1440p is 2560x1440
    4k    is 3840x2160
  Should be at least 4k monitor. 5k and 6k are better, of course.
  Use the integer scaling factor:
    if you have a 4k monitor (3840×2160), and use 2× scaling, you’ll get an equivalent of 1920×1080 logical pixels. So it’s a basic 1080p monitor in terms of how much you can fit, but with much crisper UI and text in everything.
  I don’t see a problem with 24” 4k displays or even 27” displays. I use both with macOS and love both, never had any problems. Of course, 5k or 6k would be better, but those go in the “nice to have” category. 4k is a must-have, an absolute minimum for anyone working with text.
  120 Hz gives you a couple of significant improvements:
  Animations are smoother, up to the point where they start to appear like a continuous motion instead of a very fast slideshow.
  Scrolling is very smooth in particular. Browser, code editing, to name a few.
  The whole system feels much more responsive.
  This is what you can do to get the idea: switch to 30 Hz and try to work like that for a while.
  Running 4k at 120 Hz is simple on Windows. Make sure your graphics card has DisplayPort 1.4, use it, that’s it. Seriously, it just works.
  Officially none of the Apple computers support anything beyond 60 Hz, even on normal resolutions:
  My Macbook Pro 2019 had the correct port and with Thunderbolt 3 (USB-C) to DisplayPort adapter, everything worked. My understanding is, port versions on devices matter, but cables and adapters do not, as long as they physically fit into the hole. In my case, it was Xiaomi USB-C → miniDP converter and miniDP → DP cable.
https://discussions.apple.com/thread/252060552
  > I've managed to get the external display working using USB-C -> HDMI 2.0 cable. Full resolution, 75hz.
  > It looks like the reason for TB/USB-C -> DP cables not working properly, or at all, is that the ports on the macs do not support DP Alt Mode.

================================================================================
20220208
The Medieval Queens Whose Daring, Murderous Reigns Were Quickly Forgotten
https://www.smithsonianmag.com/history/medieval-queens-daring-reigns-quickly-forgotten-180979246/
tags: history germany france europe
Queen Brunhild
Fredegund, slave queen
she summoned two slave boys. Fredegund wanted them to slip into the gathering where the armies were celebrating Sigibert’s victory and assassinate Sigibert. ...
Chilperic made his queen one of his most trusted political advisers; soon Fredegund wielded influence over everything from taxation policy to military strategy.
Chilperic was assassinated by Brunhild.
“Weren’t there fields in those places over there yesterday? Why do we see woods?” Another sentry laughed off this alarm: “But of course you have been drunk, that is how you blotted it out. Do you not hear the bells of our horses grazing next to that forest?” So Brunhild’s forces slept. At daybreak, they found themselves surrounded, and then, slaughtered.
the queens took root in legends and myths. A “walking forest” strategy like Fredegund’s appeared more than a thousand years later in Shakespeare’sMacbeth.
Fredegund’s tomb is on display at the majestic Basilica of Saint-Denis in Paris

================================================================================
20220208
OSC-over-UDP: A Badass Way to Connect Programs Together
https://joearms.github.io/#2016-01-28%20A%20Badass%20Way%20to%20Connect%20Programs%20Together
tags: queue p2p distributed-systems systems network tcp udp protocol
Open Sound Control is a binary protocol for exchanging data between machines.
Despite "Sound" in the name, it is a generic protocol.
OSC-over-UDP is just OSC packed data sent over a UDP connection.
OSC encoding is Verb-Tag*-Value* (similar to Tag-Length-Value (TLV)):
  +-----+--------+-------+
  | Tag | Length | Value |
  +-----+--------+-------+
  - extremely efficient.
  - encoders/decoders can be implemented in a few lines of code.
  - strongly typed.
  - complex nested data structures cannot be represented. so messages must have "flat" data.
    - intrinsically flat. the internal representation of an OSC message in the
      programming language of your choice is easy - why is this? Precisely because
      OSC does not have deeply nested recursive data structures. To parse XML or
      JSON you need to map the parse tree onto some object structure in your
      language.
  - compare to JSON, which is flexible, untyped, tricky to parse/represent, and wasteful of space “on the wire“. In other words JSON has everything that a wire line protocol should not have.

================================================================================
20220210
MQTT: The Standard for IoT Messaging
https://mqtt.org/
tags: queue p2p distributed-systems systems network tcp udp protocol
extremely lightweight publish/subscribe messaging transport

================================================================================
20220211
Why the Soviets Slaughtered 180,000 Whales During the Cold War
https://fee.org/articles/why-the-soviets-slaughtered-180-000-whales-during-the-cold-war/
tags: history ussr soviet-union environment
https://psmag.com/social-justice/the-senseless-environment-crime-of-the-20th-century-russia-whaling-67774
https://en.wikipedia.org/wiki/Whaling_in_the_Soviet_Union_and_Russia
The Soviets killed some 180,000 whales illegally, driving several species to the brink of extinction.
Soviet Union had little real demand for whale products. Once the blubber was cut away for conversion into oil, the rest of the animal, as often as not, was left in the sea to rot.
The Soviet whalers, Berzin wrote, had been sent forth to kill whales for little reason other than to say they had killed them. They were motivated by an obligation to satisfy obscure line items in the five-year plans that drove the Soviet economy, which had been set with little regard for the Soviet Union’s actual demand for whale products.
Without prices, the Soviets had to calculate in very crude terms, most notably gross output.
When the Aleut fleet docked in Vladivostok in 1938, Dudnik was arrested by the secret police and thrown in jail.

================================================================================
20220215
AssemblyScript
https://www.assemblyscript.org/
tags: nodejs web webassembly wasm typescript javascript
Useless, limited TypeScript dialect for those who don't want to learn Go or any other language that supports WASM.
https://www.assemblyscript.org/status.html#promises
MISSING: closures, promises, exceptions: https://www.assemblyscript.org/status.html#promises

================================================================================
20220305
Numéraire
https://en.wikipedia.org/wiki/Numéraire
tags: concepts mental-model economics theory
The numéraire (or numeraire) is a basic standard by which value is computed. In
mathematical economics it is a tradable economic entity in terms of whose price
the relative prices of all other tradables are expressed. In a monetary economy,
acting as the numéraire is one of the functions of money, to serve as a unit of
account: to provide a common benchmark relative to which the worths of various
goods and services are measured. This concept was confused between the
properties of ‘money’ and ‘units of account’ until 1874-7, Leon Walras clarified
it. He showed that the price can be expressed without introducing "money." Price
can be translated in term of another.

================================================================================
20220305
Computational Irreducibility
https://mathworld.wolfram.com/ComputationalIrreducibility.html
tags: concepts mental-model economics theory
https://www.youtube.com/watch?v=_8j1XZ0N_wE
even if you have the complete rules for describing everything (complete model of
physics), it is much more efficient to observe a result (experiment/empiricism)
than to (a priori) compute the result.

================================================================================
20220314
OAuth 2.0 Authorization Framework: Bearer Token Usage
https://www.rfc-editor.org/rfc/rfc6750.html
tags: rfc oauth bearer-token web json internet ietf
Bearer Token
  A security token with the property that any party in possession of the token
  (a "bearer") can use the token in the same way as any other party. Bearer is
  not required to prove possession of cryptographic key material (proof-of-possession).
Error Codes
   Server responds with HTTP status code (400, 401, 403, 405, …) and
   includes one of the following error codes in the response:
     invalid_request
     invalid_token
     insufficient_scope
Example request:
  GET /resource HTTP/1.1
  Host: server.example.com
  Authorization: Bearer mF_9.B5f-4.1JqM
Example reponse: access denied (WWW-Authenticate header)
  HTTP/1.1 401 Unauthorized
  WWW-Authenticate: Bearer realm="example", error="invalid_token", error_description="The access token expired"
Example bearer token response (OAuth 2.0 [RFC6749]):
  HTTP/1.1 200 OK
  Content-Type: application/json;charset=UTF-8
  Cache-Control: no-store
  Pragma: no-cache
  {
    "access_token":"mF_9.B5f-4.1JqM",
    "token_type":"Bearer",
    "expires_in":3600,
    "refresh_token":"tGzv3JOkF0XG5Qx2TlKWIA"
  }

================================================================================
20220316
Putin expects the West to blink in the face of his threats - 6th letter from the Wind of Change inside the FSB
http://www.igorsushko.com/2022/03/putin-expects-west-to-blink-in-face-of.html
tags: foreign-policy history politics government strategy russia ukraine nato europe usa
The impending "exit" for Russia through our eyes (FSB as an organization, not #WindofChange individually) and the "courtiers" at the Kremlin
Operation “Gordian Knot”
  Stage 1: Most likely, Konashenkov (Major General, chief spokesman for the Russian Ministry of Defence) will officially declare at a briefing that Europe and the “collective West” have declared war on Russia by intervening in the Ukrainian conflict with their weapons and mercenaries, while simultaneously attacking Russia in the economic plane (sanctions). There will be an extended lecture that war is not contained to military operations on the battlefield, but it includes an array of aggressive actions aimed at causing direct damage to the opponent. That the West’s action de-facto unleashed a world war. That this war has not yet moved into the “hot stage” with missiles and tanks only because Putin, as the supreme commander in chief, did not give such an order. Nevertheless, Konashenkov will declare that the third world war has begun.
  Stage 2: Assessment of the reaction (by the West) – 1-2 days.
  Stage 3: Putin will make a speech. In this long lecture he will declare that the modern world is not as it was before, that war now includes cyber attacks, preparation of biological attacks, direct attacks, training of terrorist & saboteurs, and imposing of sanctions devastating to the economy. He [allegedly] does not want war, but the West has already started it (against Russia). As a result, (Russian) response need not be symmetrical and can respond to any act of aggression with any means available in a military confrontation. “I warned with Ukraine – but nobody listened” (Putin’s message). Russia has shown that its words (threats) are not empty.
           Putin will declare that he is ready to come to terms (forgive) with what the West has already done, but only if sanctions are lifted within 24 hours, all assistance to Ukraine is stopped, and that NATO will guarantee not to expand. (Still Putin’s upcoming speech) Otherwise, Russia will have no choice but to accept the war and respond with all available means.
  Stage 4: A fierce negotiation process (between Russia and the West) – in the initial hours Putin will be conspicuously unavailable for communication (with the West). Other countries’ presidents will be obliged to discuss issues with Putin’s aides – “or not at all.” Putin's demonstrative private phone calls will begin with the leaders of countries that Russia is betting on: Serbia, Hungary, China, the Arab world, African countries and Asian countries. Assessing the situation of the West’s readiness to respond to the challenge, agents of political influence will be activated. They will call to “immediately fulfill Russia’s just demands, and not drag the world into a new war” - here the task is to quickly propagate the message that “the war was unleashed by the West, but Russia cannot not to answer.”
  Stage 5: Based on the assessment over 24 hours, the following options are possible:
    1. West blinks and is prepared to make local concessions. In this instance the following position will be voiced: “we have been heard, there are positive signals and we consider this a factor that allows us to delay making a final decision." (Whether to start military operations against the West) Putin will set aside several days for the negotiation process, after which he will “make a decision.” In this scenario the West is given time to go through stages from denial to acceptance – practically all that will remain is to extract maximal concessions (from the West), which will turn out to be the most significant. The maximal objective is to sign a new international treaty of a global nature (total appeasement of Russia)
    2. The West does not comply, but openly does not want war. In this instance “military targets” will be demonstrably identified: Poland and the Baltic countries. Moreover, identification of “limited targets” in these countries is possible, with a public appeal to civilians not to be near these objects. Immediately after this, a super-intensive format of negotiations will start, with a key goal of forcing the West to reject all support for Ukraine and a possible “compelling of Ukraine to peace” by the West. Strategic aviation and nuclear triad will be activated, and a No Fly Zone may be declared over these countries (by Russia). Chances of success (for desired concessions from the West) are considered to be highly realistic (if it gets to this point). Otherwise, localized missile strikes (against Poland and Baltics) will be almost inevitable.
    3. The West does not comply and demonstrates readiness for war in response. This scenario is considered to be extremely unlikely. In this instance cyber attacks will be launched on key infrastructure facilities of Western countries. Russia will not take direct responsibility, while actively "moving" its forces of the (nuclear) triad. With this development of events, the risks of the West using military methods to respond are assessed as negligible, which gives Russia room to maneuver to conduct an indirect war to create unacceptable conditions for the West with the risk of total economic collapse. After this, negotiations are considered inevitable and will result in the scenario #2 above. And –
    4. In the case of an absence of clear coordinated signals (from the West), which is assessed as unlikely but acceptable, the (Russian) behavior will be similar to scenario #2 above (as well).
    5. A fundamental collapse of the West within the time allotted (by Putin) after the ultimatum was issued. Rejection of “collective security”: Withdrawal of several countries from NATO (and possibly European Union), each with separate appeals to Russia that they are not conducting aggressive actions against Russia and they are not part of the possible war. Then everything will default back to scenario #1 above, but Russia’s strength in position (for negotiations) will be comparable to that of the USSR. In the future, this will allow Russia to take political control of a number of countries that were part of the USSR. NATO as an integral structure will cease to exist.
    6. A fundamental collapse of the West, but with a clear separation of a number of countries [Poland and the Baltics] from the moderate position of other countries. (Here, #WindofChange means a scenario in which NATO tries to appease Russia but Poland and the Baltics refuse to stand down to Russia) In this case the “pro-Russian wing” of the Western countries will accuse these countries (Poland/Baltics) of fomenting conflict along with a demand “not to drag our governments into someone else’s conflict.” Russia's objective in this scenario is to apply maximum pressure on Western countries with a moderate position, demanding that they “keep the aggressors (Poland/Baltics) from reckless actions." In this situation, within a period of 3 to 7 days, Western countries with a moderate position will be ready to accept local strikes against countries with radically irreconcilable countries (Poland/Baltics), after which missile strikes [on military targets] will be launched on them (Poland/Baltics). Direct infantry invasion is considered acceptable but unlikely.
       For the above (six) scenarios, these assumptions are assessed as extremely probable:
         - Arab countries, Iran, China, some African countries, and [presumably] India and Brazil will take neutrality with a general condemnation of "mutual aggression";
         - Some European countries are guaranteed not to support military confrontation: Italy, Hungary, Serbia, possibly France;
         - Powerful movements will be activated inside Western countries aimed to both support Russia and recognize it as a “defending side.” A number of anti-war movements not necessarily in support of Russia but which will create an impossible environment for their governments to make a pro-war decision;
         - Global nuclear war will not happen;
         - The Ukraine question will be resolved with finality – by the West.

================================================================================
20220317
Zalando REST API and Event Guidelines
https://opensource.zalando.com/restful-api-guidelines/
tags: api design web rest programming

================================================================================
20220317
Google Web API design guide
https://cloud.google.com/apis/design
tags: api design web rest programming

================================================================================
20220317
RFC 3339 vs ISO 8601
https://ijmacd.github.io/rfc3339-iso8601/
tags: standards formatting programming datetime date time rfc iso rfc-3339 iso-8601
RFC 3339 is "profile" of ISO 8601.
Specifies a complete representation of date and time (only fractional seconds are optional).
Some small, subtle differences vs ISO 8601:
- requires 4-digit years
- only allows a period character to be used as the decimal point for fractional seconds.
- The RFC also allows the "T" to be replaced by a space (or other character), while the standard only allows it to be omitted (and only when there is agreement between all parties using the representation).

================================================================================
20220320
Ride or Die: George Hotz against the institutions
https://return.life/2022/03/07/george-hotz-comma-ride-or-die/
tags: george-hotz philosophy
“The enemy isn’t other people, the enemy is nature. We’re in competition with entropy.”
“My only strive is to be anti-modelable. As soon as someone starts to model me, I’ll do the opposite. If you’re, like, way smarter than me, you can actually beat this. If you’re not way smarter, then I’m going to be completely opaque to you. You can look at me in broad strokes the way you look at Kasparov in broad strokes: he’s probably going to win the chess game, but you can’t predict the next move he’s going to make.”
Opiate addiction and wireheading each destroy one’s life narrative by trading meaning for pleasure. “The problem with wireheading is, ‘Okay, now tell your story.’ ‘Well I sit there and I feel happy.’ ‘Okay, good sentence, bro.’”

================================================================================
20220320
Principia Discordia
http://principiadiscordia.com/book/45.php
tags: literature philosophy
Everywhere people are hurting one another, the planet is rampant with injustices, whole societies plunder groups of their own people, mothers imprison sons, children perish while brothers war. O, woe."
WHAT IS THE MATTER WITH THAT, IF IT IS WHAT YOU WANT TO DO?
"But nobody wants it! Everybody hates it."
OH. WELL, THEN STOP.

================================================================================
20220320
Justice Creep
https://astralcodexten.substack.com/p/justice-creep?
tags: philosophy politics
> "economic justice" suggests other assumptions. Current economic conditions are
> unjust. There is some particular way to make them just, or at least closer to
> just. We have some kind of obligation to pursue it. We are not helpers or
> saviors, who can pat ourselves on the back and feel heroic for leaving the
> world better than we found it. We are some weird superposition of criminals
> and cops, both responsible for breaking the moral law and responsible for
> restoring it, trying to redress some sort of violation. The end result isn’t
> utopia, it’s people getting what they deserve.
>
> the moral transition from other virtues to Justice mirrors the literary
> transition from utopian fiction to dystopian. In Utopia, people practice
> virtues like Charity, Industry, and Humanity, excelling at them and making
> their good world even better. In Dystopia, Justice is all you can hope for


================================================================================
20220325
Optimal autonomous organizations (OAO)
https://graymirror.substack.com/p/optimal-autonomous-organizations
tags: curtis-yarvin law legal corporation systems business economics bitcoin
- > An OAO is a DAO running a modern version of the joint-stock design.
  Eliminating the official rituals that slow down every official corporation,
  while maintaining the management structure that makes those corporations
  scalable and efficient, might produce a more equal competition between new and
  old management forms.
- > The basic design of the Anglo-American limited-liability joint-stock company
  has remained roughly unchanged since the start of the Industrial
  Revolution—which, a contrarian historian might argue, might actually have been
  a Corporate Revolution.
- > Vicarious conflicts of purpose often lead governors to push an organization
  "ultra vires"—outside its constitutional definition of success. For example,
  ... you may find meaning in directing the organization to do good rather than
  evil ... If the purpose of the organization is to do good rather than evil,
  this is not a conflict of purpose. If the purpose of the organization is to
  make widgets, or to make money by selling widgets, it is.

================================================================================
20220325
Permissive Action Link (PAL)
https://en.wikipedia.org/wiki/Permissive_Action_Link
tags: security operations opsec military weapons defense cryptography
"Positive control". Component of a nuclear weapon system to preclude arming or
launching until the insertion of a prescribed discrete code or combination.
- Encrypted firing parameters
- Anti-tamper systems which intentionally mis-detonate the weapon
- Two-man rule
- Fail-safe: activation-critical electronics within the weapon, such as
  capacitors, are selected so that they will fail before the safety device in
  the event of damage
- Critical signal detection: weapon will only respond to a specific arming
  signal, passed to the weapon by a unique signal generator. This output is
  specific and well-defined, precluding approximation, emulation, noise, or
  interference from being accepted as a false positive.
- Environmental sensing device (ESD): determines through environmental sensors
  whether the weapon is operating in its combat environment (acceleration curve,
  temperature, pressure, in the correct order).

================================================================================
20220331
Look to the Stars: Navigating the Urbit
https://messari.io/article/look-to-the-stars-navigating-the-urbit
tags: urbit p2p distributed-systems layer2 ethereum blockchain
Imagine an extensible, open source version of WeChat: Urbit is a one-stop-shop for cloud and community-based services.

================================================================================
20220407
The Cathedral or the Bizarre
https://...
tags: curtis-yarvin history politics government power machiavelli systems monarchy
three sets of governed society:
  1. regime: officials (non-public)
  2. clients: entitled public depends-on the regime
  3. commoners: taxed public, regime depends-on
"a regime that tolerates crime has just chosen to share its absolute power with crime."
"political formula": any thought that convinces the subject to love and obey the officials.
"politically correct" PC originates from 1934 essay "The Author as Producer"
the marketplace of ideas becomes a monoculture when it becomes official: power corrupts => selects for important ideas instead of true ideas.
journalism acts with public authority but private immunity.
press-controlled State:
  leaks form a relationship
  financial regulations (SEC) prohibit MNPI; if gov't did not allow leaks then journalism would not be an Official organ.
Department of Reality (decentralized)
  1. Ministry of Information (legitimate journalism)
  2. Ministry of Truth (universities/science)
Aristotle : 20th c. redefinition
------------------------
monarchy  : "dictatorship"
oligarchy : "democracy"
democracy : "populism"
.
"The modern desire to look to Athens for lessons or encouragement for modern
thought, government, or society must confront this strange paradox: the people
that gave rise to and practiced ancient democracy left us almost nothing but
criticism of this form of regime ... the actual history of Athens in the period
of its democratic government is marked by numerous failures."

================================================================================
20220407
The Red-Pill Prince: How computer programmer Curtis Yarvin became America’s most controversial political theorist
https://www.tabletmag.com/sections/news/articles/red-pill-prince-curtis-yarvin
tags: curtis-yarvin history politics government power machiavelli systems
- > Everywhere one looked in the Moldbuggian scheme, things were not what they
  seemed. Beneath the surface of modern progressivism, for instance, Yarvin
  found that the sacraments and dogmas of America’s founding Protestant religion
  had been preserved. The now common criticism that the liberal activist culture
  of wokeness is a kind of secular religion picks up on arguments Yarvin was
  making in 2007 about mainstream liberal universalism, which he dubbed
  “CryptoCalvinism.”
- > for Yarvin, even though libertarianism may be right about the best way to
  organize society, it fails because it is unserious about power.
- > The state, rather than tyrannizing its subjects or being controlled by
  citizens who endowed its authority, “should be operated as a profitable
  corporation governed proportionally by its beneficiaries.”
- > Power, according to Yarvin, is like computer code, binary. It is either on
  or off; final and absolute, or merely a glorified form of servitude.
- > [in 2021] the Taliban seized control of Afghanistan while barely firing
  a shot. America’s trillion-dollar investment in the Afghan Security Forces was
  exposed as a Ponzi scheme and collapsed overnight. ... No general or political
  leader was blamed ... No one was fired or resigned. Moreover, the total lack
  of accountability for a catastrophic systemwide failure is, according to
  Yarvin, not a problem that could be solved by electing better leaders or
  applying more political will, because it is an essential feature of the
  system’s design. “Why did this happen?” Yarvin asked. “Very simply: because no
  one is in charge of the government.” Not the wrong people; no one.

================================================================================
20220408
Paypal Co-Founder Peter Thiel - Bitcoin Keynote - Bitcoin 2022 Conference
https://www.youtube.com/watch?v=ko6K82pXcPA
tags: peter-thiel bitcoin federal-reserve central-bank ipo inflation monetary-policy esg
- "ESG is a factory for naming enemies. ... When you think ESG, think CCP."
- "Taking a company public is a de facto government takeover. When a company
  IPOs, some people who are effectively government bureaucrats become more
  empowered: the CFO, the general council, the accountants, the lawyers, the HR
  people--extensions of the State."

================================================================================
20220409
Coz profiler: Find Code that Counts with "Causal Profiling"
https://github.com/plasma-umass/coz
tags: debug profiling programming c performance
- Causal profiling measures optimization potential for serial, parallel, and
  asynchronous programs without instrumentation of special handling for library
  calls and concurrency primitives. Instead, a causal profiler uses performance
  experiments to predict the effect of optimizations. This allows the profiler
  to establish causality: "optimizing function X will have effect Y."
- "relativity" approach: "speed up" (isolate) a component by slowing down all others.
  https://youtu.be/r-TLSBdHe1A?t=1802

================================================================================
20220419
lexical: extensible text editor framework
https://lexical.dev/
tags: extensible text-editor application framework library facebook-meta
https://news.ycombinator.com/item?id=31019778
- deprecates draft.js https://github.com/facebook/draft-js
- Lexical is not strictly tied to collaboration but its plugin system was built to be extensible enough to cater all developers needs. Collaboration is just another plugin (@lexical/yjs) and does listen and perform the conversion every time there's changes in the EditorState.

================================================================================
20220509
Varoufakis and bitcoin maximalism
https://graymirror.substack.com/p/varoufakis-and-bitcoin-maximalism
tags: curtis-yarvin economics federal-reserve stock finance government banking money
> Another name for rolling over loans is maturity transformation. Because
> long-term interest rates are naturally higher than short-term interest rates,
> it is naturally profitable to borrow with short-term loans (payable in a month
> or even less) and lend in long-term loans (like a 30-year mortgage). When you
> do this, you are fooling the market ... that there is huge and inexhaustible
> marginal demand for profitably borrowing money for a month. This will create
> an amount of lending that is essentially unbounded—and since maturity
> transformation turns debt (future money) into cash (present money), an amount
> of money that is essentially unbounded. ... Sending, or even tolerating, false
> market signals creates false prices, false markets, and irrational economic
> activity.
> ...
> Any regular bank is paying back a loan with another loan. This loan is a loan
> from you. Your “deposit” is a promise from the bank to pay you
> back—immediately. This is the ultimate in maturity transformation: a zero-term
> loan. Say it renews every second.
> ...
> Usually this second you do not need the money. So you leave the money “in the
> bank.” What this means is that you are lending it back to the bank. This is
> a rollover and you are the lender.
> ...
> With maturity transformation, the supply of money can be arbitrarily
> manipulated. In a hard currency (like bitcoin or gold), such a bubble must
> inevitably collapse. In a soft or fiat currency, debt bubbles expand
> indefinitely—via covert government lending.
> ...
> Deposit insurance is hidden government lendingwhen you have a checking
> account, you actually own three promises. You have a formal promise by the
> bank to pay you, a formal promise by FDIC to pay you if the bank doesn’t, and
> an informal promise by the Fed that FDIC will always pay up.

================================================================================
20220530
NASA Active Fires Map (FIRMS: Fire Information for Resource Management System)
https://firms.modaps.eosdis.nasa.gov/map
tags: web tools world map geography

================================================================================
20220605
The blockchain and the whitechain
https://graymirror.substack.com/p/the-blockchain-and-the-whitechain
tags: curtis-yarvin economics federal-reserve finance government banking money currency bitcoin cryptocurrency
- > But once the state gets to know the classic blockchain, the state likes it
  quite a bit. The blockchain is a kind of technical perfection of the official
  record that lies at the heart of every civilized state. ... This attraction is
  a fatal one—because crypto is a more attractive currency than state equity.
  Namely, it is harder. Regulating it legitimizes it and makes it more
  dangerous.
- > Junk money is “smart beta”—it makes money by chasing market patterns and
  hoping they continue. This hope is also known as “risk.”
  ... If crypto can rise in a brutal bear market for yield-returning assets as
  fleeing investors bounce into coins instead of dollars, crypto will convince
  the robots that it is an asset that goes up in both kinds of markets.

================================================================================
20220605
Only a monarch can control the elites: Democracy enables the deep state to rule us
https://unherd.com/2022/06/only-a-monarch-can-control-the-elites/
tags: curtis-yarvin politics government realpolitik machiavelli monarchy oligarchy democracy
- > Bagehot, 19th-century theorist of the English Constitution, divided
  sovereigns into the "effective" ("operating", actually in control of the
  state) and the "dignified" ("ceremonial", a crowned Kardashian, a long-haired
  Merovingian man-doll).
- > One way to identify a ceremonial or dignified institution is to detect
  a situation in which a seeming organ of power is vestigial. ... If Elizabeth
  II passes away tomorrow, ... Whitehall would function as usual. If Parliament,
  the Cabinet, and the voters did not exist, Whitehall would function as usual.
- > Disruption [of bureaucracy] can be measured by number of jobs destroyed. How
  many elite jobs did Trump destroy?
- > Ultimately, the purpose of a ceremonial monarchy is to prevent the existence
  of a functional monarchy. Where a puppet reigns, no one else can reign [as
  opposed to "rule"] ... So a murky, distributed oligarchy can rule, unchallenged.

================================================================================
20220605
Quango (Quasi-NGO)
https://en.wikipedia.org/wiki/Quango
tags: concepts government
An organisation to which a government has devolved power, but which is still
partly controlled and/or financed by government bodies.

================================================================================
20220612
Please, don't build another Large Hadron Collider
https://news.ycombinator.com/item?id=31651557
tags: physics science funding politics misallocation
> As a low-energy quantum physicist, I completely agree: Experimental
> high-energy physics has become primarily an industrial subsidy scheme[1], and
> if we want the highest chance of reaching a grand unified theory, it seems the
> money would be much better spent elsewhere (cosmology, space-based
> observatories, research positions for young physicists without
> publish-or-perish incentives to run for the latest fad).
>
> ... Einstein and the quantum pioneers added abstractions to build physical
> theories with prediction power, whereas current high-energy physics theory
> seems to be mostly a mathematical exercise. This has been confirmed by
> numerous insiders, including by Hossenfelder as mentioned in the article, and
> Lee Smolin ("The trouble with physics") who is also a theoretical physicist.
>
> Things have changed a lot since accelerators became a must-have for
> high-energy physics: Today we have detectors and computing power that let us
> observe the natural experiment of the universe with a precision and diligence
> that would be impossible when LHC was commissioned. I find it much more likely
> that we would learn new physics by giving 10-year grants to 1000 young
> physicist of revolutionary spirit, and let them use the tools they could build
> themselves, than by handing that money to the old guard which has produced
> nothing of significance for the last two generations.
>
> [1]: The industrial subsidy angle is not touched upon in TFA, but it is clear
> that there is a large number of people and companies making a good living from
> mega-physics.

================================================================================
20220620
On the crypto blizzard (The Bubble Theory of Money)
https://graymirror.substack.com/p/on-the-crypto-blizzard
tags: curtis-yarvin theory bubble inflation economics federal-reserve finance government banking money currency bitcoin cryptocurrency
The Bubble Theory of Money: "money is a bubble that doesn't pop".
Two principles:
  1. The pool of savings—net demand to transfer purchasing power from the
     present to the future. (The existence of debt instruments does not change
     the demand for savings: once the loan is closed, the borrower now holds the
     savings of the lender.)
     The demand for savings is the demand for money. The demand to move
     purchasing power from present future is a human universal. Imagine a human
     society which knew it was about to be destroyed by an asteroid in a week.
     In such a society, though exchange might continue, who would take money in
     exchange for anything?
  2. The standardization of money. This is a very simple Schelling point or
     collective agreement problem. The solution is a Nash equilibrium: choose
     the action which is best for you if everyone else chooses it. This is the
     famous Keynesian beauty contest.
...In a sane financial system with a stable monetary standard, there would be no
such thing as “passive investing.” No beta, only alpha. “Beta” investing is just
how you avoid the monetary-dilution tax.

================================================================================
20220623
Biggest idea in software architecture: the "narrow waist"
https://www.oilshell.org/blog/2022/03/backlog-arch.html
tags: programming softwareengineering design compsci architecture oilshell
"narrow waist" (from networking theory but more generally applicable)
- important idea, because it describes the biggest and longest-lived systems.
- examples:
  - text
  - "Accidental" waists like Win32 and x86.
  - TCP/IP, HTTP
- related:
  - postel's law
  - interop
  - intermediate representation (IDL)
  - compression encoding?
- inertia:
  - XHTML and ECMAScript 4 both tried to break the web with radical changes, but they failed because of the inertia of narrow waists.
  - downside: narrow waists can inhibit innovation. For example, hardware-software co-design is inhibited because of decades-old ISAs.
- "A taste for minimalism that unlocks enormous functionality."
- "A few things that compose": Software with fewer concepts composes, scales, and evolves more easily.
- "Static types and metaprogramming are at odds. Rust favors type checking, Zig favors metaprogramming, and we don't know how to reconcile this."
- When models and reality collide, reality wins.
  - Rich Hickey "situated" software.
- The Lambda Calculus is a narrow waist.

================================================================================
20220728
The Desperate Lives Inside Ukraine’s “Dead Cities”
https://www.newyorker.com/magazine/2022/08/01/the-desperate-lives-inside-ukraines-dead-cities
tags: history war ukraine russia nato europe
“There were pieces of people everywhere,” the officer said. “When someone died,
we took their tourniquets off and put them on someone else. By the end, my boots
were filled with blood.”

================================================================================
20220801
More invested in nuclear fusion in last 12 months than past decade
https://news.ycombinator.com/item?id=32207152
tags: engineering science energy nuclear
> But where are the fusion neutrons? (See Voodoo Fusion [1])
> [1] https://vixra.org/pdf/1812.0382v1.pdf
>
> I'm a professional fission guy. I started out in fusion and switched to advanced fission. These days I don't see why we don't just build lots more regular old LWR fission reactors.
>
> Imagining that somehow fusion is going to a) work, b) be cheap (fuel cost is only 5% of total nuclear fission cost so who cares), and c) not have the same stigma as fission is kind of weird in my mind.
>
> For example, there are leaks of tiny amounts of tritium at some fission plants and people lose their minds. Fusion reactors will have many orders of mag more tritium. Will people not lose their minds just the same? Tritium is notoriously hard to contain since it's so small. It can permeate through metal like a hot knife through butter.
>
> Also, lots of people worry about fission and nuclear weapons proliferation. So does fusion get around this? Not really. In fact it's worse. Did you know that the two materials you need to make thermonuclear weapons are tritium and plutonium? Tritium breeding is required by almost all practical fusion power plants (the other reactions are 100s to 1000s of times harder, I don't care what x random fusion CEO says, they're in it for the sweet billionaire side project money).
>
> Plutonium is made by irradiating natural uranium from the dirt with neutrons. Practical fusion reactors have lots of neutrons. Really high energy ones too.
>
> Anyway let's just do fission you guys. It's way easier. It has been working fine since the 1950s. It's zero carbon. Waste problem is solved (see Onkalo, and reprocessing). It net saves millions of lives by displacing air pollution. It runs 24/7 on a tiny land and material footprint. We have enough uranium and thorium to run the whole world for 4 billion (with a b) years using breeder reactors (demonstrated in 1952 in Idaho). Get the Koreans over here to build some ARP1400s or the Chinese to build some Hualong Ones until we figure out how to project manage again and then call it good.

================================================================================
20220801
C23 #embed
https://thephd.dev/finally-embed-in-c23
tags: c legacy backwards-compatibility preprocessor build macros programming performance
- bug report in GCC where someone embedded a big xxd-generated array (one big
  list of numbers), and ultimately their response to the bug report was “We Will
  Simply Stop Keeping Error Information For All Arrays Past The 256th Element”.
- no, you can’t just “Use a String Literal”, because MSVC has an arbitrarily
  tiny limit of string literals in its compiler (64 kB, no they can’t raise it
  because ABI).
- utility of #embed and std::embed: No, You Cannot Just “implement your compiler/parser better”.
  - GCC had to sacrifice diagnostic information to get better speed (good luck
    if you’ve got a big array, 256 elements is enough for everybody, right?)
  - Clang had its own issue open for large array initializers (and has
    subsequently shrugged its shoulders);
  - MSVC is quite literally so bad at parsing a series of integer literals on
    its compilers that it not only ran out of memory faster than every other
    compiler, but it lost in both compile-time and memory usage to MinGW on the
    same computer!

================================================================================
20220801
The return of the Earl
https://graymirror.substack.com/p/the-return-of-the-earl
tags: concepts mental-model politics literature shakespeare
- Shakespeare =? Edward de Vere, 17th Earl of Oxford. https://shakespeareoxfordfellowship.org/
- Conquest’s law: “everyone is reactionary on the subjects they understand”
  https://en.wikipedia.org/wiki/Robert_Conquest#Three_Laws_of_Politics
  - many adopt a craven, but all too human, corollary: after taking a bold
    stance in their own specialty, they have no stomach for any other fight.
  - Reactionary enlightenment in one field should cast Bayesian doubt on other
    fields. Instead, local enlightenment reinforces global ignorance.
    - Logically, the specialist should reason that if his own field, which he
      knows closely, is corrupt, other fields which he cannot examine in detail
      may be corrupt as well.
    - But emotionally, the cost of a general dissidence far exceeds the value of
      extending the inference. The sweet spot is general compliance, local
      dissidence.

================================================================================
20220805
Neom
https://en.wikipedia.org/wiki/Neom
tags: saudi-arabia terraforming protopia planned-city
Neom (Arabic: نيوم) is a Saudi city being built in Tabuk Province in
northwestern Saudi Arabia. It is planned to incorporate smart city technologies
and to function as a tourist destination. The site is north of the Red Sea, east
of Egypt across the Gulf of Aqaba, and south of Jordan. It is planned to cover
a total area of 26,500 km2.
Estimated cost of $500 billion.
Linked with Travis Kalanick: https://en.wikipedia.org/wiki/Travis_Kalanick#Post-Uber_(2018%E2%80%93present)

================================================================================
20220809
Two strokes of state
https://graymirror.substack.com/p/two-strokes-of-state
tags: curtis-yarvin politics government realpolitik machiavelli monarchy oligarchy democracy
> _Humphrey_ https://en.wikipedia.org/wiki/Humphrey%27s_Executor_v._United_States
> says that Congress can establish “independent” agencies which are in the
> executive branch, but not under the full power of the chief executive. In
> specific, the President cannot just fire anyone in the executive branch he
> wants. Therefore, he is not actually the President—not the chief executive of
> the executive branch. And the Constitution is just a lie.
> ...
> The Hill micromanages their budget, policy, and personnel.
> The White House sends them press releases which they have to pretend to obey, and appoints a small legion of empty suits who will be either captured or destroyed by the permanent civil service.

================================================================================
20220813
Everything You Never Wanted to Know About CMake
https://izzys.casa/2019/02/everything-you-never-wanted-to-know-about-cmake/
tags: c build cmake programming softwareengineering

================================================================================
20220814
lambdaway: a web text-editor where you can write, compute and draw
http://lambdaway.free.fr/lambdawalks/
tags: wiki notes web hapax

================================================================================
20220821
Diablo 1 for web browsers
https://github.com/d07RiV/diabloweb
tags: web wasm webassembly game software programming embed webbrowser diablo blizzard

================================================================================
20220821
Ultima Online for the web
https://classicuo.org/
tags: web wasm webassembly game software programming embed webbrowser

================================================================================
20220821
Nobody wants to teach anymore
https://news.ycombinator.com/item?id=32542440
tags: economics budget government schooling education costs society
> I was a school board member and did exhaustive analysis of our budget. For primary education through high school, admin is NOT the root cause. If you take any school budget, and strip away everything that is not an actual classroom teacher, you will find
>   - 1/3 or less goes to "frontline" teaching costs.
>   - 1/3 goes to special ed and all that is attendant with that.
>     My district BOUGHT a car and hired a FULLTIME driver for one student who had to be taken to special programs.
>     You have 1:1 class aids for many kids.
>     Special ed is < 10% of kids, and even then the huge costs add up for the 1%.
>     This is a massively subscale operation where every school is legally obligated to deliver services.
>   - 1/3 is everything else. Food, facilities, sports, admin, transportation, etc. Admin is actually a leaner slice than most unless you are getting into really small schools where you have a principal on top of the teachers and that adds significant salary. In bigger schools this fades away with scale.
> This data is REALLY hard to get. I had to go line by line through the budget.
> For example, all the classroom aids are typically assigned as teaching costs. But the reality is that they are assigned to individual students with IEPs (individual education plans), ergo, they should be categorized as special ed.
> Same thing in pulling out transportation. Or tuition to other districts. Admin dealing with special ed grants and recordkeeping. It goes on and on...

================================================================================
20220821
The productivity tax you pay for context switching
https://async.twist.com/context-switching/
tags: work productivity habits focus concentration time-management attention
- Upon returning to a task after a distraction, it can take up to 23 minutes to re-focus.
  https://www.washingtonpost.com/news/inspired-life/wp/2015/06/01/interruptions-at-work-can-cost-you-up-to-6-hours-a-day-heres-how-to-avoid-them/
- Even “brief mental blocks” as a result of switching can take as much as 40% of a person’s productive time.
  https://www.apa.org/research/action/multitask
- Isaac Newton said: “If I have made any valuable discoveries, it has been owing more to patient attention than to any other talent.”
- When our attention is split, we struggle “to integrate fragmented information into cohesive task structures that make sense,”
  https://www.hcii.cmu.edu/news/event/2004/10/work-fragmentation-common-practice-paradox-it-support

================================================================================
20220405
OIDC spec (OpenID Connect Core 1.0)
https://openid.net/specs/openid-connect-core-1_0.html#UserInfo
tags: oidc oauth auth webapp web network softwareengineering rfc spec login
OpenID Connect 1.0 is a simple identity layer on top of the OAuth 2.0 protocol. It enables Clients to verify the identity of the End-User based on the authentication performed by an Authorization Server, as well as to obtain basic profile information about the End-User in an interoperable and REST-like manner.

================================================================================
20220908
The Success and Failure of Ninja
http://neugierig.org/software/blog/2020/05/ninja.html
tags: build-systems ninja programming softwareengineering exceptions errors design failure-modes
End-to-end / crash-only. ...: given that you need to run Ninja from scratch
sometimes, if you make that fast, then you don't need to build a second "online"
codepath. Projects that can stay memory-resident tend to eventually let their
startup performance languish.

================================================================================
20221007
Export tweets to markdown
tags: twitter data programming develop markdown formats archive
https://github.com/kbravh/tweet-to-markdown
$ npx tweet-to-markdown -b  --assets --assets-path "./images"

================================================================================
20221009
A Look at the Design of Lua
https://www.lua.org/doc/cacm2018.pdf
tags: lua c design pl programming-language runtime engineering
Lua offers exactly one general mechanism for each major aspect of programming:
tables for data; functions for abstraction; and coroutines for control.

================================================================================
20221010
ULID: Universally Unique Lexicographically Sortable Identifier
https://github.com/ulid/spec
tags: encoding number-theory compsci guid uuid ulid spec
improved alternative to UUID
ulid() // 01ARZ3NDEKTSV4RRFFQ69G5FAV
https://github.com/ulid/spec/issues/28
  > the monotonicity issue made me walk away from ulid. A number of the blessed
  > implementations with a checkmark indicating they conformed to the spec did
  > not implement the randomness increment whatsoever. I wasn't sure how
  > "serious" the conformance to spec was in general for ulid.
compare:
  "coordination-free ObjectIDs"
    https://github.com/ulid/spec/issues/55#issuecomment-859110202
    https://github.com/marrow/mongo/blob/next/marrow/mongo/util/oid.py?ts=4#L1

================================================================================
20221010
Open Location Code (OLC)
https://github.com/google/open-location-code
tags: encoding compression entropy gps map compsci guid uuid spec address-space
Open Location Code (OLC) https://plus.codes
Library to generate short codes, called "plus codes", that can be used as
digital addresses where street addresses don't exist.
compare:
  lat/lng
  Geohash
  What3Words

================================================================================
20221011
SCIP: a better code indexing format than LSIF
https://about.sourcegraph.com/blog/announcing-scip
tags: code-navigation lsp index format semantic-analysis
code indexing format to code navigation features
LSIF:
- https://github.com/microsoft/lsif-node
- https://github.com/Microsoft/language-server-protocol/blob/main/indexFormat/specification.md

================================================================================
20221012
Lite XL: lightweight text editor written in Lua
https://github.com/lite-xl/lite-xl
tags: text-editor software application text programming

================================================================================
20221016
Lindy effect
https://en.wikipedia.org/wiki/Lindy_effect
tags: concepts mental-model antifragile mathematics
- The future life expectancy of some non-perishable things, like a technology or
  an idea, is proportional to their current age. Thus, the longer something has
  survived to exist or be used in the present, the longer its remaining life
  expectancy. Longevity implies a resistance to change, obsolescence or
  competition and greater odds of continued existence into the future.
- Where the Lindy effect applies, mortality rate decreases with time.
- Mathematically the Lindy effect corresponds to lifetimes following a Pareto
  probability distribution.
- Nassim Nicholas Taleb has expressed the Lindy effect in terms of "distance
  from an absorbing barrier."

================================================================================
20221030
"Stop Writing Dead Programs" by Jack Rusher
https://www.youtube.com/watch?v=8Ab3ArE8W3s
tags: programming softwareengineering repl lisp smalltalk
1. batch processing
   has received by far the most PL investment
2. time and state
3. program representation
   still "batch mode" paradigm in all popular langs: C, Go, Rust, JS
4. pragmatics: studying the relationship betw language and its users
5. interactive programming (opposite of "batch processing")
   implies an "environment"

================================================================================
20221104
Markdown, Asciidoc, or reStructuredText
https://news.ycombinator.com/item?id=33468213
tags: documentation tech-writing markup markdown
- markdown:
  > Last year we (mozilla MDN) [changed the source format for MDN](https://openwebdocs.org/content/posts/markdown-conversion/) from some extremely messy, WYSIWYG-authored HTML to something that would be easier for authors to use. We considered Asciidoc and reST, and despite its limitations, we chose Markdown (GFM specifically) for two reasons:
  > 1. We get a _lot_ of casual contributors to MDN: about 180-200 unique contributors/month, most of whom we never see again. Almost all of them can contribute much more easily with Markdown than with anything else. Many of these people are unlikely to put even an half an hour into learning a new syntax.
  > 2. Markdown has great tooling support. For example, if we want to run Prettier over our embedded code samples, it's really easy if we are in Markdown. If we are in Markdown we will get nice formatting just about everywhere, including GitHub of course and most people's editors.
- asciidoc:
  > I love Asciidoc, but the tooling is pretty crummy.
  > Seems to have a problem with nesting.
- RsT (RestructuredText)
  > Originally reStructuredText was "a Python thing", ... nowadays (thanks to Sphinx?) reStructuredText is also used for big systems-y projects, including the Linux kernel docs and Envoy proxy.
  > I work in an academic setting ... we used reStructuredText ... [contributors] would get demotivated by having to learn the rST syntax and tooling.
  > I gave up and switched from rST and Sphinx to Markdown and MkDocs. We addressed the limitations of Markdown with PyMdown Extensions [3].
- djot
  - The creator of Pandoc is creating a markup language worth looking at: https://djot.net/
- markdoc.dev (stripe)
  - > Anything AsciiDoc can do, Markdoc can be extended to do, from variables through includes.
  - React or HTML output. AST transforms or functions. Upcoming editor support etc.
- MyST https://myst-parser.readthedocs.io/en/latest/index.html
  - > the jupyter devs created myst ([https://myst-parser.readthedocs.io/en/latest/syntax/syntax.h...](https://myst-parser.readthedocs.io/en/latest/syntax/syntax.html#syntax-core)), a superset of markdown that has almost all the features of rst, and can embed rst when it falls short.

================================================================================
20221108
Cat9: a user shell script for LASH - a command-line shell that discriminates against terminal emulators, written in Lua.
https://github.com/letoram/cat9
tags: lua shell
LASH just provides some basic shared infrastructure and a recovery shell.
    It then runs a user provided script that actually provides most of the rules for how the command line is supposed to look and behave.
Cat9 is such a script.
    Runs and cleanly separates multiple concurrent jobs asynchronously, with the results from 'out' and 'err' being kept until you decide to reuse or forget it.
Arcan: among its many subprojects are SHMIF and TUI.
    https://arcan-fe.com/2022/04/02/the-day-of-a-new-command-line-interface-shell/
    SHMIF is an IPC system -- initially to compartment and sandbox media parsing that quickly evolved to encompass all inter-process communication needed for something on the scale of a full desktop.
    TUI is an API layered on top of SHMIF client side, along with a text packing format (TPACK). It was first used to write a terminal emulator that came bundled with Arcan, and then evolved towards replacing all uses of ECMA-48 and related escape codes, as well as kernel-tty and userspace layers. The end goal being completely replacing all traces of ncurses, readline, in-band signalling and so on -- to get much needed improved CLIs and TUIs that cooperate with an outer graphical desktop shell rather than obliviously combat it.

================================================================================
20221214
Smithy Client Generator for TypeScript
https://github.com/awslabs/smithy-typescript
tags: aws smithy codegen typescript
generate HTTP server and client from smithy model
https://aws.amazon.com/blogs/devops/smithy-server-and-client-generator-for-typescript/
https://github.com/aws-samples/smithy-server-generator-typescript-sample

================================================================================
20221110
Effortless Language Servers
https://stefan-marr.de/2022/10/effortless-language-servers/
tags: code-navigation pl grammar language lsp semantic-analysis

================================================================================
20221113
Communist Party of Vietnam
https://en.wikipedia.org/wiki/Communist_Party_of_Vietnam
tags: socialism communism capitalism economics politics government vietnam marxism leninism
- Superiority of socialism
  - According to Marxism–Leninism, socialism is the second-to-last stage of socio-economic development before pure communism.
- Socialist-oriented market economy
  - Proponents claim that the system is neither socialist nor capitalist, but "socialist-oriented." The Communist Party rejects the view that a market economy has to be capitalist.
- Trần Bạch Đằng wrote: "The reality of Vietnam after the revolution is different from what I imagined when I joined the party ... Life has shown us that it is much more complicated. ...  we received Marxism in a theoretical sense ... through Stalin and Mao.

================================================================================
20221121
Climate Change Debate: Bjørn Lomborg and Andrew Revkin | Lex Fridman Podcast #339
https://www.youtube.com/watch?v=5Gk9gIpGvSE
tags: science global-warming climate weather environmentalism podcast
- 90 hurricanes/year, this rate has not changed in correlation with global warming

================================================================================
20221121
Copenhagen Consensus Center
https://www.copenhagenconsensus.com/
tags: science global-warming climate weather environmentalism podcast
> research and development for more effective and cheaper green technologies to
> combat climate change as well as increase agricultural productivity.

================================================================================
20221126
Azure has run out of compute [in Germany region]
https://news.ycombinator.com/item?id=33743870
tags: cloud azure aws
Unlike GCP and Azure, all AWS regions are (were) partitioned by design. This "blast radius" is (was) fantastic for resilience, security, and data sovereignty. It is (was) incredibly easy to be compliant in AWS, not to mention the ruggedness benefits.
AWS customers with more money than cloud engineers kept clamoring for cross-region capabilities ("Like GCP has!"), and in last couple years AWS has been adding some.
Cloud customers should be careful what they wish for. If you count on it in the data center, and you don't see it in a well-architected cloud service provider, perhaps it's a legacy pattern best left on the datacenter floor. In this case, at some point hard partitioning could become tough to prove to audit and impossible to count on for resilience.

================================================================================
20221126
Guide to Playing Myth in 2022
https://tain.totalcodex.net/forum/viewtopic.php?t=7461
tags: web game software webbrowser myth bungie

================================================================================
20221126
Rainier Mesa (Area 12)
https://en.wikipedia.org/wiki/Rainier_Mesa
tags: area12 area51 government usgov military aliens
Rainier Mesa is one of four major nuclear test regions within the Nevada National Security Site (NNSS).
It occupies approximately 40 square miles (100 km2) along the northern edge of the NNSS and corresponds to Area 12.

================================================================================
20221130
Tech Layoff Tracker
https://www.trueup.io/layoffs
tags: business economics economy

================================================================================
20221202
The road to AWS Lambda SnapStart - guide through the years of JVM "cold start" tinkering - JVM Weekly #115
https://vived.substack.com/p/the-road-to-aws-lambda-snapstart
tags: aws java linux cache graal
- CRIU: Checkpoint/Restore in Userspace  https://criu.org
  Linux feature that allows you to take a "snapshot" of an entire running application process and dump it to the disk.
- CRaC (Coordinated Restore at Checkpoint) is the aforementioned CRIU API OpenLibert was asking for. It allows you to create a "checkpoint" - given memory dumps - at any point in the application's operation as defined by the software developer, using a command:
  jcmd target/spring-boot-0.0.1-SNAPSHOT.jar JDK.checkpoint
  It allows you (as a CRaC API user) to manage its state.
    import jdk.crac.Context;
    import jdk.crac.Core;
    import jdk.crac.Resource;

    class ServerManager implements Resource {
    ...
       @Override
       public void beforeCheckpoint(Context<? extends Resource> context) throws Exception {
           server.stop();
       }

       @Override
       public void afterRestore(Context<? extends Resource> context) throws Exception {
           server.start();
       }
    }
- The OpenJDK mailing list had been leaking for some time that Amazon was working on improving support for Java in Serverless applications:
  https://mail.openjdk.org/pipermail/discuss/2021-July/005863.html
- Snapshotting mechanism provided by Firecracker:
  https://github.com/firecracker-microvm/firecracker/blob/main/docs/snapshotting/snapshot-support.md

================================================================================
20221204
ChatGPT: Optimizing Language Models for Dialogue
https://openai.com/blog/chatgpt/
tags: ai machine-learning chatgpt
We’ve trained a model called ChatGPT which interacts in a conversational way. The dialogue format makes it possible for ChatGPT to answer followup questions, admit its mistakes, challenge incorrect premises, and reject inappropriate requests. ChatGPT is a sibling model to InstructGPT, which is trained to follow an instruction in a prompt and provide a detailed response.
We trained this model using Reinforcement Learning from Human Feedback (RLHF), using the same methods as InstructGPT, but with slight differences in the data collection setup. We trained an initial model using supervised fine-tuning: human AI trainers provided conversations in which they played both sides—the user and an AI assistant. We gave the trainers access to model-written suggestions to help them compose their responses.
To create a reward model for reinforcement learning, we needed to collect comparison data, which consisted of two or more model responses ranked by quality. To collect this data, we took conversations that AI trainers had with the chatbot. We randomly selected a model-written message, sampled several alternative completions, and had AI trainers rank them. Using these reward models, we can fine-tune the model using Proximal Policy Optimization. We performed several iterations of this process.

================================================================================
20221214
World Military Expenditures and Arms Transfers
https://www.state.gov/world-military-expenditures-and-arms-transfers/
tags: government government-failure military logistics budget
> WMEAT Will No Longer be Published
> WMEAT 2021, which the Department of State published in December 2021, is the
> final edition of World Military Expenditures and Arms Transfers (WMEAT).
> Section 5114(b)(4) of the National Defense Authorization Act for Fiscal Year
> 2022 repealed the 1994 statutory provision that required the Department of
> State to publish an edition of WMEAT every year. Consistent with this repeal,
> the Department of State will cease to produce and publish WMEAT.

================================================================================
20221214
“Most transparent administration in history” stops publishing military expenditures, arms transfers report
https://www.lawenforcementtoday.com/biden-stops-publishing-military-expenditures-arms-transfers-report/
tags: government government-failure military logistics budget
> Joseph Patrick|August 27, 2022
> WASHINGTON, DC- From the “most transparent administration in American history,” we find one item that has largely been buried by the mainstream media.
> This week, the State Department announced that the World Military Expenditures and Arms Transfers report, which has been published for over 50 years, will no longer be produced. As usual, that provision was buried deep inside the National Defense Authorization Act for FY 2022 under Section 5114(b)(4).
> Under that federal law, 22 U.S.C. 2593b, it required:
>     No later than December 31 of each year, the Secretary of State shall publish an unclassified report on world military expenditures and arms transfers.
>     Such report shall provide detailed, comprehensive, and statistical information regarding military expenditures, arms transfers, armed forces, and related economic data for each country of the world.
>     In addition, such report shall include pertinent in-depth analyses as well as highlights with respect to arms transfers and proliferation trends and initiatives affecting such developments.
> Now, the State Department will no longer be reporting those transfers and expenditures after the language was buried inside the most recent National Defense Authorization Act.
> Why would the “most transparent administration in history” want to do that? Especially at a time when the money spigot has been opened to pour tens of billions of dollars in military aid to Ukraine.
> The elimination of this important program comes as sources say that the United States is virtually unable to track what happens to the military equipment and weapons being sent to Ukraine ostensibly to fight against Vladimir Putin’s invading Russian army.
> None other than CNN reported back in April that the U.S. “has few ways to track the substantial supply of anti-tank, anti-aircraft and other weaponry it has sent across the border into Ukraine.”
> And this was four months ago, and the United States has poured many more tens of billions of dollars in military aid to Ukraine since then.
> Meanwhile the administration doesn’t seem to be overly concerned by the lack of accountability, with a senior defense official telling CNN that the transfer of equipment to Ukraine was vital to holding off Russian aggression.
> However both current and US officials and defense analysts warned that in the long-term, some of the weapons being sent to that country could end up in the hands of other militaries or militias that may be hostile to the U.S. and our allies.
> “We have fidelity for a short time, but when it enters the fog of war, we have almost zero,” one source briefed on US intelligence told CNN. “It drops into a big black hole, and you have almost no sense of it at all after a short period of time.”
> Meanwhile most recently, Sean O’Donnell, Acting Inspector General of the Department of Defense told Bloomberg that Ukrainian officials are not able to specify the exact location of arms and other military equipment supplied by the United States, with all of their accounting done on paper.
> O’Donnell said Ukraine keeps track of all weapons using “hand receipts.”
> “It’s all paper,” he said, while saying he has doubts Ukraine’s leadership has “much fidelity” as to where the arms end up.
> He noted that “a lack of effective record keeping” also hindered efforts by the Pentagon to track weapons in both Afghanistan and Iraq.
> Meanwhile, O’Donnell acknowledged that NATO officials are “confident that the security was sufficient for the transfer of weapons.”
> O’Donnell’s office also promised to investigate the spending of Ukraine-related expenditures, along with intelligence sharing agreements between the Pentagon and NATO allies, the effectiveness of training of Ukrainian forces, and possible arms sales in black markets.

================================================================================
20221215
Git partial clone (vs shallow clone)
https://github.blog/2020-12-21-get-up-to-speed-with-partial-clone-and-shallow-clone/
tags: git dvcs compsci data-structure
Shallow clone (no commit history)
  - truncates the commit history
    git clone --depth=<N>
  - best combined --single-branch --branch=<branch> options, to ensure only download the data for the commit we plan to use.
  - unlike *partial* clone, commands such as `git merge-base` or `git log` show different results.
  - fetch is much more expensive than w/ partial clone.
  - use-case: NOT recommended (except for builds that don't later fetch).
Partial clone (no blobs/trees)
  - doc: https://git-scm.com/docs/git-clone#Documentation/git-clone.txt---filterltfilter-specgt
  - enabled by specifying the --filter option in your git clone command.
  - Blobless clones: git clone --filter=blob:none <url>
    - will trigger a blob download whenever you need the contents of a file, but not if you only need the OID of a file.
    - can perform commands like `git merge-base`, `git log`, or even `git log -- <path>` with the same performance as a full clone.
  - Treeless clones: git clone --filter=tree:0 <url>
    - downloads all reachable commits, then downloads trees and blobs on-demand.
    - initial clone _much_ faster in a treeless clone than in a blobless or full clone
    - use-case: for automated builds when you want to quickly clone, compile, then throw away the repository.
    - current? limitations:
      - a file history request such as git log -- <path>, will download root trees for almost every commit in the history!
      - submodules behave very poorly with treeless clones.

================================================================================
20221219
Git: Counting Objects: reachability bitmaps
https://github.blog/2015-09-22-counting-objects/
tags: git dvcs bitmap bloom-filter compsci data-structure
- Reachability queries: what objects in the graph can be reached from a set of commits?
- Indexes (stored as bitmaps) contain the information required to answer these queries
- To find a commit's reachable objects, we simply get its bitmap and check the
  marked bits on it; the graph doesn’t need to be traversed anymore.

================================================================================
20221216
vim_dev: Bug in patch 9.0.0907 causes E1312 in autocmd
https://groups.google.com/g/vim_dev/c/Cw8McBH6DDM
tags: vim mailing-list development text-editor history
Bram Moolenaar:
> At some point I thought I should drop auto commands completely, because
> it's just getting too complicated and too many crashes have had to be
> fixed. And there are probably a few more that we haven't found yet.
> .
> But users, and especialy plugin writers, depend on auto commands, and
> there is no good replacement, thus they are still here. But let it be
> clear that supporting auto commands is almost infeasible, thus you can
> expect some limitations. I currently tend to prevent things from going
> bad rather than deal with the problems caused by them. E.g. disallow
> closing and splitting windows rather than dealing with a window
> disappearing "under our fingers". Sometimes it's not at all clear what
> to do then.

================================================================================
20230101
The Power of Toys | David Nolen | Lambda Days 2022
https://www.youtube.com/watch?v=qDGTxyIrKJY
tags: clojure programming systems compsci spec engineering software-engineering
abstraction vs generalization
- "toy" abstraction more powerful
- generalization implies specification (risky, costly to change if it has consumers)
property-based testing (PBT)
- unlike fuzzing, can do "shrinking"

================================================================================
20230104
Ask HN: Why isn't JSON-RPC more widely adopted?
https://news.ycombinator.com/item?id=34211796
tags: json rpc protocol
JSON-RPC (vs HTTP):
- (main problem) Method Name is a part of the body, so you must parse it to decide how to dispatch it.
- Error Code is a part of the response, so you must parse it each time to decide if it's success.
- JSON-RPC can be batched, which introduces a lot of unspecified use cases.
  - how to dispatch those batched? Should they go to the same upstream? Or can it be parallelized? Should the order be preserved?
  - With batches, the slowest request always blocks the in-flight response. What if some of them never finish?
- ID can be a different type (int or string), which sometimes introduces two different handlers in the code.
  - No guarantees IDs are not repeating in the same batch.
  - Some clients rely only on request/response order ignoring the IDs.
- No Auth, Caching, etc. (compare HTTP)
HTTP has auth, routing, error handling, multiplexing, etc.

================================================================================
20230105
Easy, alternative "soft delete" (postgresql): `deleted_record_insert`
https://brandur.org/fragments/deleted-record-insert
tags: sql postgresql database archive undelete
    This function will generically insert a deleted record from _any_ source table:
        CREATE FUNCTION deleted_record_insert() RETURNS trigger
            LANGUAGE plpgsql
        AS $$
            BEGIN
                EXECUTE 'INSERT INTO deleted_record (data, object_id, table_name) VALUES ($1, $2, $3)'
                USING to_jsonb(OLD.*), OLD.id, TG_TABLE_NAME;

                RETURN OLD;
            END;
        $$;
    Invoke it as an AFTER DELETE trigger on any table for which you want to retain soft deletion records:
        CREATE TRIGGER deleted_record_insert AFTER DELETE ON credit
            FOR EACH ROW EXECUTE FUNCTION deleted_record_insert();
        CREATE TRIGGER deleted_record_insert AFTER DELETE ON discount
            FOR EACH ROW EXECUTE FUNCTION deleted_record_insert();
        CREATE TRIGGER deleted_record_insert AFTER DELETE ON invoice
            FOR EACH ROW EXECUTE FUNCTION deleted_record_insert();

================================================================================
20230105
Napoleon's Commentaries on the Wars of Julius Caesar
https://www.napoleon.org/en/magazine/publications/napoleons-commentaries-wars-julius-caesar/
tags: book caesar napoleon war tactics strategy
ISBN  1526716275, 9781526716279
on caesar's death:
  > if you destroy aristocracy, it will be recreated among the powerful families of the Third Estate.
  > it will resurface among successful artisans and the people.
  > a prince gains nothing by such a displacement of the aristocracy.
  > on the contrary, he restores orde by letting it continue in its natural state,
  > by reconstituting the ancient families on new principles. such a state of
  > affairs was more necessary than ever at Rome. Rome needed the magic attaching
  > to men with names like scipio, aemilius paulus, metellus, claudius, fabius.
on claims that ceasar wanted to be king:
  > he never thought of making himself king.
  > the sect to which Brutus adhered would not admit of any sentiment which might
  > cause him to hold back. Full of the notions hostile to tyranny which were
  > taught in the Greek schools of philosophy, the assassination of any man who
  > was effectively above the law was viewed by him as legitimate.
caesar "did nothing without a decree from the senate".
  > the statues of Pompey had been overturned; he restored them, to acclaim.

================================================================================
20230110
Hard to work with.
https://lethain.com/hard-to-work-with/
tags: people-management work industry career
> folks fail in an organization primarily because they want to hold others to a higher standard than their organization’s management is willing to enforce.
> A few examples:
> - An interim Vice-President of Engineering (VPE) at a company whose CEO won’t finalize the role because one peer is upset they didn’t get the role. That peer has been struggling for some time, but the CEO doesn’t want to “rock the boat” so leaves them both lingering. Attempts to hold their peer accountable are viewed as “evidence they’re not ready” for permanent VPE role
> - An engineering manager working with a product manager whose proposals are both very expensive to implement and misaligned with the company’s goals. The engineering manager flags the issue to product leadership and it gets reframed from a concern about the product manager’s performance into an issue of two peers not collaborating well. Both are pushed to “collaborate better” but the team’s impact remains poor
> - Engineering directors at a company who instituted company-wide bar raisers because one of their peers was unwilling to maintain the shared hiring bar. The CTO was unwilling to hold that director accountable, so the other directors followed the only solution they could think of that wouldn’t be interpreted as “interpersonal conflict” by the avoidant CTO
> common pattern: The main character is trying to do their job effectively, but can’t due to the low performance of a peer. They escalate to the appropriate manager to address the issue, but that manager transforms the performance issue into a relationship issue: it’s not that the peer isn’t performing, it’s just that the two of you don’t like each other. Instead of being the manager’s responsibility to resolve the performance issue, it’s now the main character’s responsibility. By attempting to drive accountability in their peer, the main character has blocked their own progress (“they’re just hard to work with”) without accomplishing anything.
> the manager is almost always aware of the underlying issue, and for some reason they’re simply unwilling to confront it.
>
> solution:
> - lead with constructive energy directed towards a positive outcome. Even if you can’t get your peer’s performance addressed directly, you can often overcome your peer’s bad performance by generating excitement in the direction you want to go.

================================================================================
20230115
Emmanuel Todd (French intellectual) claims that the "Third World War has started."
https://twitter.com/RnaudBertrand/status/1613924570725244928
tags: foreign-policy history politics government strategy russia ukraine china nato europe usa war reserve-currency
> Emmanuel Todd: «La Troisième Guerre mondiale a commencé»
> GRAND ENTRETIEN - Au-delà de l’affrontement militaire entre la Russie et l’Ukraine, l’anthropologue insiste sur la dimension idéologique et culturelle de cette guerre et sur l’opposition entre l’Occid…
> https://www.lefigaro.fr/vox/monde/emmanuel-todd-la-troisieme-guerre-mondiale-a-commence-20230112#Echobox=1673601494-1
> He says "it's obvious that the conflict, started as a limited territorial war and escalating to a global economic confrontation, between the whole of the West on the one hand and Russia and China on the other hand, has become a world war."
> He believes that "Putin made a big mistake early on, which is [that] on the eve of the war [everyone saw Ukraine] not as a fledgling democracy, but as a society in decay and a “failed state” in the making. [...] I think the Kremlin's calculation was that this decaying society...
>
> ... would crumble at the first shock. But what we have discovered, on the contrary, is that a society in decomposition, if it is fed by external financial and military resources, can find in war a new type of balance, and even a horizon, a hope."
> He says he agrees with Mearsheimer's analysis of the conflict: "Mearsheimer tells us that Ukraine, whose army had been overtaken by NATO soldiers (American, British and Polish) since at least 2014, was therefore a de facto member of the NATO, and that the Russians had...
> ... announced that they would never tolerate Ukraine in NATO. From their point of view, the Russians are therefore in a war that is defensive and preventive. Mearsheimer added that we would have no reason to rejoice in the eventual difficulties of the Russians because...
> ...since this is an existential question for them, the harder it would be, the harder they would strike. The analysis seems to hold true."
> He however has some criticism for Mearsheimer:
>
> "Mearsheimer, like a good American, overestimates his country. He considers that, if for the Russians the war in Ukraine is existential, for the Americans it is basically only one 'game' of power among others. After Vietnam...
> ...Iraq and Afghanistan, what's one more debacle? The basic axiom of American geopolitics is: 'We can do whatever we want because we are sheltered, far away, between two oceans, nothing will ever happen to us'. Nothing would be existential for America.
>
> Insufficient analysis which today leads Biden to proceed mindlessly. America is fragile. The resistance of the Russian economy is pushing the American imperial system towards the precipice. No one had expected that the Russian economy would hold up against the 'economic power'...
> ...of NATO. I believe that the Russians themselves did not anticipate it.
>
> If the Russian economy resisted the sanctions indefinitely and managed to exhaust the European economy, while it itself remained, backed by China, American monetary and financial controls of the world...
> ...would collapse, and with them the possibility for United States to fund their huge trade deficit for nothing. This war has therefore become existential for the United States. No more than Russia, they cannot withdraw from the conflict, they cannot let go. This is why we...
> ... are now in an endless war, in a confrontation whose outcome must be the collapse of one or the other."
> He firmly believes the US is in decline but sees it as bad news for the autonomy of vassal states:
>
> "I have just read a book by S. Jaishankar, Indian Minister of Foreign Affairs (The India Way), published just before the war, who sees American weakness, who knows that the...
> ...confrontation between China and the US will have no winner but will give space to a country like India, and to many others. I add: but not to Europeans. Everywhere we see the weakening of the US, but not in Europe and Japan because one of the effects of the retraction of...
>
> ...the imperial system is that the United States strengthens its hold on its initial protectorates. As the American system shrinks, it weighs ever more heavily on the local elites of the protectorates (and I include all of Europe here). The first to lose all national autonomy...
> ... will be (or already are) the English and the Australians. The Internet has produced human interaction with the US in the Anglosphere of such intensity that its academic, media and artistic elites are, so to speak, annexed. On the European continent we are somewhat...
> ... protected by our national languages, but the fall in our autonomy is considerable, and rapid. Let's remember the Iraq war, when Chirac, Schröder and Putin held joint anti-war press conferences."
> He underlines the importance of skills and education: "The US is now twice as populated as Russia (2.2 times in student age groups). But in the US only 7% are studying engineering, while in Russia it is 25%. Which means that with 2.2 times fewer people studying, Russia trains...
> ...30% more engineers. The US fills the gap with foreign students, but they're mainly Indians and even more Chinese. This is not safe and is already decreasing. It is a dilemma of the American economy: it can only face competition from China by importing skilled Chinese labor."
> On the ideological and cultural aspects of the war: "When we see the Russian Duma pass even more repressive legislation on 'LGBT propaganda', we feel superior. I can feel that as an ordinary Westerner. But from a geopolitical point of view, if we think in terms of...
> ... soft power, it is a mistake. On 75% of the planet, the kinship organization was patrilineal and one can sense a strong understanding of Russian attitudes. For the collective non-West, Russia affirms a reassuring moral conservatism."
> He continues: "The USSR had a certain form of soft power [but] communism basically horrified the whole Muslim world by its atheism and inspired nothing particular in India, outside of West Bengal and Kerala. However, today, Russia which repositioned itself as the archetype...
> ...of the great power, not only anti-colonialist, but also patrilineal and conservative of traditional mores, can seduce much further. [For instance] it's obvious that Putin's Russia, having become morally conservative, has become sympathetic to the Saudis who I'm sure have a...
> ...bit of a hard time with American debates over access for transgender women in the ladies' room.
>
> Western media are tragically funny, they keep saying, 'Russia is isolated, Russia is isolated'. But when we look at the votes at the UN, we see that 75% of the world does not...
> ...follow the West, which then seems very small.
>
> With an anthropologist reading of this [divide between the West and the rest] we find that countries in the West often have a nuclear family structure with bilateral kinship systems, that is to say where male and female kinship...
>
> ...are equivalent in the definition of the social status of the child. [Within the rest], with the bulk of the Afro-Euro-Asian mass, we find community and patrilineal family organizations. We then see that this conflict, described by our media as a conflict of political...
> ...values, is at a deeper level a conflict of anthropological values. It is this unconscious aspect of the divide and this depth that make the confrontation dangerous."

================================================================================
20230115
Database is faster than filesystem
https://www.sqlite.org/fasterthanfs.html
tags: compsci filesystem database
SQLite reads and writes small blobs (for example, thumbnail images) 35% faster¹ than the same blobs can be read from or written to individual files on disk using fread() or fwrite().
https://news.ycombinator.com/item?id=34387671
  > Database is faster than a nominal file system, though it can't quite replace them.
  > Microsoft tried (winfs) but ultimately it fizzled, why? Important edge cases (like swap) that databases do really poorly.
  > Database is But for complex and compound documents using a database is a really stellar way to go.
  > - doesn't have the "chunking" problem where allocation blocks are used for both
  >   data and metadata in file systems so you pick a size that is least bad for
  >   both, versus one "optimum" size for disk IO to keep the disk channel
  >   bandwidth highly utilized and the naming/chunking part as records inside that.

================================================================================
20230116
William Buckland
https://en.wikipedia.org/wiki/William_Buckland
tags: history england france louis-xiv
William Buckland (Dean of Westminster ca. 1845) ate the mummified heart of King Louis XIV.

================================================================================
20230130
Carbonyl: Chromium running inside your terminal
https://github.com/fathyb/carbonyl
tags: terminal tui webbrowser web
Does not require a window server (i.e. works in a safe-mode console), and even runs through SSH.
Carbonyl originally started as https://github.com/fathyb/html2svg and is now the runtime behind it.

================================================================================
20230131
"Gerade in dieser Krise sieht man doch den Wahnsinn der Atomkraft", Veröffentlicht am 30.10.2022, Von Claus Christian Malzahn
https://www.welt.de/politik/deutschland/plus241838411/Juergen-Trittin-Mit-diesem-Irrsinn-endlich-aufhoeren.html
tags: environmentalism energy nuclear-energy climate-change politics government-policy
https://twitter.com/ryan_pickering_/status/1616275474577231872
> In a recent interview, prominent German Green Party German Green Party
> politician Jürgen Trittin (Federal Minister for the Environment, Nature
> Conservation and Nuclear Safety from 1998 to 2005):
> "It was clear to us that we couldn't just prevent nuclear power by protesting
> on the street. As a result, we in the governments ... tried to make nuclear
> power plants unprofitable by increasing the safety requirements." -October 31,
> 2022 (translated from German)
> In the 1970s, Germany had a plan to power most of its economy with nuclear energy.

================================================================================
20230124
RFC 8628: Device Authorization Grant
https://noise.getoto.net/2022/11/30/making-unphishable-2fa-phishable/
tags: security phishing oidc oauth auth webapp web network softwareengineering rfc spec login
What is RFC 8628 Device Authorization Grant? Imagine a device that you don’t want to type a password into – either it has no input devices at all (eg, some IoT thing) or it’s awkward to type a complicated password (eg, a TV with an on-screen keyboard).
  You want that device to be able to access resources on behalf of a user, so you want to ensure that that user authenticates the device.
  RFC 8628 describes an approach where the device requests the credentials, and then presents a code to the user (either on screen or over Bluetooth or something), and starts polling an endpoint for a result.
  The user visits a URL and types in that code (or is given a URL that has the code pre-populated) and is then guided through a standard auth process.
  The key distinction is that if the user authenticates correctly, the issued credentials are passed back to the device rather than the user – on successful auth, the endpoint the device is polling will return an oauth token.
Vulnerability: what if an attacker obfuscates tricks a user into clicking such a URL?
  The user will then be prompted to approve the request, but the language used
  here is typically very generic: AWS simply says “An application or device
  requested authorization using your AWS sign-in” and has a big “Allow” button,
  giving the user no indication at all that hitting “Allow” may give a third
  party their credentials.

================================================================================
20230131
AWS SSO OpenID Connect (OIDC)
https://blog.christophetd.fr/phishing-for-aws-credentials-via-aws-sso-device-code-authentication/
tags: security oidc oauth auth webapp web network softwareengineering rfc spec login
The AWS SSO OpenID Connect (OIDC) service currently implements only the portions of the OAuth 2.0 Device Authorization Grant standard (https://tools.ietf.org/html/rfc8628) that are necessary to enable SSO authentication with the AWS CLI.
Support for other OIDC flows frequently needed for native applications, such as Authorization Code Flow (+ PKCE), will be addressed in future releases.
https://docs.aws.amazon.com/singlesignon/latest/OIDCAPIReference/Welcome.html
USING AWS SSO FROM THE CLI
    $ aws configure sso
    SSO start URL [None]: [None]: https://my-sso-portal.awsapps.com/start
    SSO region [None]:us-east-1
    Using a browser, open the following URL:
    https://device.sso.eu-central-1.amazonaws.com/
    and enter the following code:
    QCFK-N451
After this initial authentication flow, you can list your accessible AWS accounts and roles.
THE *DEVICE CODE* GRANT TYPE
  Under the hood, the following is happening:
  1. Client app (AWS CLI) registers an OIDC client by calling sso-oidc:RegisterClient. Does not need authentication!
  2. Client app calls sso-oidc:StartDeviceAuthorization. This generates a URL like https://device.sso.eu-central-1.amazonaws.com/?user_code=SPNB-NVKN
  3. User opens the link and is redirected to authenticate on their identity provider (IdP).
     If using AWS on a daily basis, it is likely they are already logged in and transparently redirected to the next step.
  4. User opens the URL and sees the following prompt on AWS website:
     "Are you sure? [Sign in to ...]"
  5. Once the end user has accepted the prompt, the client app calls sso-oidc:CreateToken to get an AWS SSO access token.
     With the access token, the client app can use the AWS SSO API to:
     - List available AWS accounts (sso:ListAccounts)
     - List available roles in those AWS accounts (sso:ListAccountRoles)
     - Assume any of those roles via temporary STS credentials (sso:GetRoleCredentials)

================================================================================
20230208
1932 Democratic Party (FDR) Platform
https://www.presidency.ucsb.edu/documents/1932-democratic-party-platform
tags: history foreign-policy politics history fdr eisenhower new-deal
> We advocate an immediate and drastic reduction of governmental expenditures by
> abolishing useless commissions and offices, consolidating departments and
> bureaus, and eliminating extravagance to accomplish a saving of not less than
> twenty-five per cent in the cost of the Federal Government. And we call upon
> the Democratic Party in the states to make a zealous effort to achieve
> a proportionate result.
> ...
> The removal of government from all fields of private enterprise except where
> necessary to develop public works and natural resources in the common
> interest.
> ...
> We advocate a firm foreign policy, including peace with all the world and the
> settlement of international disputes by arbitration; no interference in the
> internal affairs of other nations; ...
> ...
> Simplification of legal procedure and reorganization of the judicial system to
> make the attainment of justice speedy, certain, and at less cost.
>
> ... the doctrine which guides us now in the hour of our country's need: equal
> rights to all; special privilege to none.

================================================================================
20230209
How America Took Out The Nord Stream Pipeline
https://seymourhersh.substack.com/p/how-america-took-out-the-nord-stream
tags: us-govt russia politics war energy
> In the immediate aftermath of the pipeline bombing, the American media treated
> it like an unsolved mystery. Russia was repeatedly cited as a likely culprit,
> spurred on by calculated leaks from the White House—but without ever
> establishing a clear motive for such an act of self-sabotage, beyond simple
> retribution. A few months later, when it emerged that Russian authorities had
> been quietly getting estimates for the cost to repair the pipelines, the New
> York Times described the news as “complicating theories about who was behind”
> the attack. No major American newspaper dug into the earlier threats to the
> pipelines made by Biden and Undersecretary of State Nuland.

================================================================================
20230211
Everything I believed about nuclear waste was wrong
https://zionlights.substack.com/p/everything-i-believed-about-waste-was-wrong
tags: environmentalism energy nuclear-energy climate-change politics
- All the high-level nuclear waste produced in the world would fit in a single
  football field to a height of approximately ten yards.
- In France, where fuel is reprocessed, just 0.2% of all radioactive waste by
  volume is classified as high-level waste.
- Radioactive decay means that after only 40 years, radioactivity used fuel has
  decreased to about 1/1000 of when it was unloaded. Less than 1% is radioactive
  for 10,000 years.  That portion can be easily isolated and shielded to protect
  humans and wildlife.
- There is currently enough energy in US nuclear waste to power the entire
  country for 100 years with clean energy.

================================================================================
20230220
Gentle Introduction to CRDTs
https://vlcn.io/blog/gentle-intro-to-crdts.html
tags: todo crdt data-structure compsci
https://news.ycombinator.com/item?id=34746716

================================================================================
20230220
Did Insurance Fire Brigades let uninsured buildings burn?
https://www.tomscott.com/corrections/firemarks/
tags: history economics
> In the early years of fire insurance, insurance company fire brigades seemingly made little distinction between insured and uninsured properties. They were instructed to attend and help put out all fires. The grounds for this policy included the risk of fire-spread between uninsured and insured properties, the advertising value of the firemen and their engines, and charitable acts for those who could not afford insurance.
> In principle, this policy seems to have remained in force throughout the 18th century. In practice, though, changing circumstances led to keen rivalry between fire brigades, whether insurance company, parish or private. Firstly, monetary rewards were introduced for the earliest attendees at fires. That innovation led to engines racing each other through the streets. As the number of fire insurance companies grew, so, too, did the number of fire engines. Once at the fire, too many engines were too often competing for very limited water supplies.
> When the nature of the firemen is added to this situation, the scene is set for more competition, and chaos. This, in turn, can reasonably be imagined as having led to conflict – both verbal and physical. With no reward, no water, and no insurance interest in a burning building, it is not difficult to envisage firemen standing back on occasion, jeering and generally interfering with rival brigades fighting a fire in which they did have an interest. Or, alternatively, simply packing up and going home. Arguably, therefore, the legend of insurance fire brigades letting uninsured buildings burn originated in the first half of the 18th century.
> Reciprocal fire-fighting arrangements had long been made between insurance companies. They started to develop into more formal working arrangements in the decades around the turn of the 19th century. At the same time, insurance brigades continued to follow their employers’ directives to attend and extinguish all fires, whether insured or not. They were the de facto established fire service for most localities. Fire marks became redundant.
> Despite these more formalized joint arrangements, rivalry and discord are still ascribed to firemen as the 19th century progressed. They brought “notoriety” to their employers, and sometimes “evil” to the fire-grounds – including declining to put out fires in uninsured properties. Insurance companies themselves, though, were sometimes minded not to send engines to uninsured properties, unless their expenses were guaranteed to be met.
> Demands on the insurance brigades, and costs to their employers, grew as the 19th century progressed. Some brigades, including those for London, eventually handed over to newly established municipal fire forces. Otherwise, they soldiered on, but only on two recorded occasions did they threaten to stop attending fires in uninsured properties. These instances, in 1871 and 1895, cannot be regarded as the foundation of the legend.

================================================================================
20230220
Holepunch: powerful suite of independent components to effortlessly construct peer-to-peer applications.
https://docs.holepunch.to/
tags: distributed-systems p2p peer-to-peer
- Hypercore: A distributed, secure append-only log is a useful tool for creating fast and scalable applications without a backend, as it is entirely peer-to-peer.
- Corestore: A Hypercore factory designed to facilitate the management of sizable named Hypercore collections.
- Hyperswarm: A high-level API for finding and connecting to peers who are interested in a "topic." 
-   - @hyperswarm/dht: A DHT powering Hyperswarm. Through this DHT, each server is bound to a unique key pair, with the client connecting to the server using the server's public key.
-   - @hyperswarm/secretstream: Secretstream is used to securely create connections between two peers in Hyperswarm.
- Hyperbee: An append-only B-tree running on a Hypercore. It provides key-value store API, with methods for inserting and getting key/value pairs, atomic batch insertions, and creation of sorted iterators.
- Hyperdrive: A secure, real-time distributed file system that simplifies peer-to-peer (P2P) file sharing. It provides an efficient way to store and access data across multiple connected devices in a decentralized manner.

================================================================================
20230220
Linux Foundation purpose
https://news.ycombinator.com/item?id=34029488
tags: linux oss legal
> Linux Foundation employee here [0]. The value the Linux Foundation is
> providing the legal infrastructure for competitors to work together and stay
> clear of anti-trust problems. Every one of our meetings is supposed to start
> with this slide [1] or similar [2].
0: https://www.linkedin.com/in/ryjones/
1: https://wiki.hyperledger.org/download/attachments/20024102/H...
2: https://www.linuxfoundation.org/legal/antitrust-policy

================================================================================
20230220
Google Maps not profitable?
https://news.ycombinator.com/item?id=34029202
tags: google maps antitrust monopoly
@AlbertCory: "dominance" does not equal "profits." How do I know this?
> I was in Google Patent Litigation, and there were tons of suits against Maps.
> In all of these, the plaintiff strains as hard as they can to find some
> connection to Ads, because that's where the money is. Maps doesn't bring in
> much money.
>
> "Oh, but imputed revenue!" you say? Well, no one has ever succeeded in
> defining that and proving it. You can be certain that Google won't ever do it,
> even internally, because that would end up in Discovery.

================================================================================
20230220
You can have geothermal power everywhere if you drill deep enough
https://www.treehugger.com/geothermal-drilling-technology-quaise-energy-5219924
tags: energy geothermal
https://news.ycombinator.com/item?id=30476050
- Outdated geothermal energy that taps underground water reservoirs near heat sources has been shown to cause earthquakes and other not good side effects.
  All of those effects are associated with water being released from aquifers
  that were previously sealed, or ground changes due to water incursion into
  previously dry structures (which happened in the reference German town). These
  guys however are digging below all of that. In fact finding water that near
  the surface would likely cause them to determine the location unsuitable.
- *Modern* geothermal plants are "binary" in that they have their own water loop
  which goes down, gets heated, and then comes back as steam.
  https://www.eia.gov/energyexplained/geothermal/geothermal-power-plants.php
- What this proposes is essentially drilling into rock 6+ miles down. That is
  about 5 to 10 times deeper than current plants. Using the heat from the rock
  which is near 1000 degrees to heat water that they pump through it into steam
  and recover through the turbines. The whole "pipe" from well head to return is
  nominally sealed with the vitrified walls created by the microwaving process.
  - The risk of earthquakes and other geo-technical disturbances is minimized by
    what is essentially a closed loop system.
  - It is true that you're going to cool the crust (energy is conserved after
    all and if you're running turbines it means the crust is cooling) the
    question then is how quickly is that heat returned by other actions. And of
    course if you were to pull "all" the energy out fast enough this way you
    could presumably "freeze" the core of the Earth and that would be a bad
    thing, but we're talking about way more energy than the entire world
    consumes in centuries and I'm not sure how to judge that risk compared to
    the heat generation mechanisms inside the planet.

================================================================================
20230220
Realtime Collaborative Diagramming: Mermaid in Notion
https://www.happyandeffective.com/blog/realtime-collaborative-diagramming-in-notion-with-mermaidjs
tags: mermaid diagram ascii examples

================================================================================
20230220
Human flesh search engine
https://en.wikipedia.org/wiki/Human_flesh_search_engine
tags: concept internet network
Chinese term for "activist" distributed research, based on massive human
collaboration, using Internet media such as blogs and forums.
  1. strong offline elements including information acquisition through offline channels and activism.
  2. voluntary crowd sourcing: Web users gather together to share information, conduct investigations.
Similar to "doxing."
Can be used to expose government corruption, identify hit and run drivers, and
exposing scientific fraud.
2010 IEEE Computer Society paper A Study of the Human Flesh Search Engine: Crowd-Powered Expansion of Online Knowledge.

================================================================================
20230220
Garage, our self-hosted distributed object storage solution
https://garagehq.deuxfleurs.fr/blog/2022-introducing-garage/
tags: distributed-systems storage web-hosting network p2p decentralized crdt
https://news.ycombinator.com/item?id=30257041
- License: AGPL3
- "We are a hosting association that wanted to put their servers at home _and_
  sleep at night. This demanded inter-home redundancy of our data. But none of
  the existing solutions (MinIO, Ceph...) are designed for high inter-node
  latency. Hence Garage! Your cheap and proficient object store: designed to run
  on a toaster, through carrier-pigeon-grade networks, while still supporting
  a tons of workloads (static websites, backups, Nextcloud... you name it)"
- Garage is a distributed storage solution, that automatically replicates your
  data on several servers. Garage takes into account the geographical location
  of servers, and ensures that copies of your data are located at different
  locations when possible for maximal redundancy, a unique feature in the
  landscape of distributed storage systems.
- S3 protocol
- uses CRDTs to avoid unnecessary chit-chat between servers
- compare to SeaweedFS:
  - Garage is easier to deploy and to operate: you don't have to manage independent components like the filer, the volume manager, the master, etc.
    It also seems that a bucket must be pinned to a volume server on SeaweedFS.
    In Garage, all buckets are spread on the whole cluster.
    So you do not have to worry that your bucket fills one of your volume server.
  - Garage works better in presence of crashes?
  - Better scalability: because there is no special node, there is no bottlenecks.
    With SeaweedFS, all the requests have to pass through the master?
- design:
  > So let's take the example of a 9-nodes clusters with a 100ms RTT over the network to understand. In this specific (yet a little bit artificial) situation, Garage particularly shines compared to Minio or SeaweedFS (or any Raft-based object store) while providing the same consistency properties.
  > For a Raft-based object store, your gateway will receive the write request and forward it to the leader (+ 100ms, 2 messages). Then, the leader will forward in parallel this write to the 9 nodes of the cluster and wait that a majority answers (+ 100ms, 18 messages). Then the leader will confirm the write to all the cluster and wait for a majority again (+ 100ms, 18 messages). Finally, it will answer to your gateway (already counted in the first step). In the end, our write took 300ms and generated 38 messages over the cluster.
  > Another critical point with Raft is that your writes do not scale: they all have to go through your leader. So on the writes point of view, it is not very different from having a single server.
  > For a DynamoDB-like object store (Riak CS, Pithos, Openstack Swift, Garage), the gateway receives the request and know directly on which nodes it must store the writes. For Garage, we choose to store every writes on 3 different nodes. So the gateway sends the write request to the 3 nodes and waits that at least 2 nodes confirm the write (+ 100ms, 6 messages). In the end, our write took 100ms, generated 6 messages over the cluster, and the number of writes is not dependent on the number of (raft) nodes in the cluster.
  > With this model, we can still provide always up to date values. When performing a read request, we also query the 3 nodes that must contain the data and wait for 2 of them. Because we have 3 nodes, wrote at least on 2 of them, and read on 2 of them, we will necessarily get the last value. This algorithm is discussed in Amazon's DynamoDB paper[0].
  > I reasoned in a model where there is no bandwidth, no CPU limit, no contention at all. In real systems, these limits apply, and we think that's another argument in favor of Garage :-)
  > [0]: https://dl.acm.org/doi/abs/10.1145/1323293.1294281

================================================================================
20230220
SeaweedFS
https://github.com/seaweedfs/seaweedfs
tags: distributed-systems storage web-hosting network p2p decentralized crdt
- License: Apache-2.0
- not a "raft-based object store", hence not as chatty
- proxy node is a volume server itself, and uses simple replication to mirror
  its volume on another server. Raft consensus is not used for the writes. Upon
  replication failure, the data becomes read-only [1], thus giving up partition
  tolerance.
  [1] https://github.com/seaweedfs/seaweedfs/wiki/Replication

================================================================================
20230223
TypeScript Features to Avoid
https://www.executeprogram.com/blog/typescript-features-to-avoid
tags: programming javascript typescript
- Avoid namespaces.
  - Breaks the "type-level extension" rule. https://github.com/Microsoft/TypeScript/wiki/TypeScript-Design-Goals
  - Modules have the same fundamental functionality as namespaces.
- Avoid enums.
  - Breaks the "type-level extension" rule. https://github.com/Microsoft/TypeScript/wiki/TypeScript-Design-Goals
  - No advantage over union types with string literals.
  - Union types map better to JSON and are generally easier to understand,
    while still benefiting from type safety and typo protection.
- Avoid `private` keyword. EcmaScript now has "#foo".

================================================================================
20230226
The Reactive Manifesto: Back-Pressure
https://www.reactivemanifesto.org/glossary#Back-Pressure
tags: distributed-systems queue systems network performance scaling
Back-Pressure:
> When one component is struggling to keep-up, the system as a whole needs to respond in a sensible way. It is unacceptable for the component under stress to fail catastrophically or to drop messages in an uncontrolled fashion. Since it can’t cope and it can’t fail it should communicate the fact that it is under stress to upstream components and so get them to reduce the load. This back-pressure is an important feedback mechanism that allows systems to gracefully respond to load rather than collapse under it. The back-pressure may bubble all the way up to the user, at which point responsiveness may degrade, but this mechanism will ensure that the system is resilient under load, and will provide information that may allow the system itself to apply other resources to help distribute the load, see Elasticity.

================================================================================
20230227
Acorns for the culture war
https://graymirror.substack.com/p/acorns-for-the-culture-war
tags: curtis-yarvin culture influence power social-network
> Every idea is a social network—the network of people it has infected—and the
> quality of a social network can only decline. People only want to join
> a network of people who are cooler than them.

================================================================================
20230309
How "Diversity" Policing Fails Science
https://news.ycombinator.com/item?id=34723391
tags: politics culture left progressive mind-control dei esg
> Science is incidental. The purpose is to select candidates that will produce
> ammunition in the form of research (e.g. various marginalization studies) for
> your side, and exclude candidates that might produce research useful to your
> opponents. This has been the case for a while in social sciences [1], now it's
> taking over all fields, and being made explicit and open [2,3,4]. The result of
> "just stick to your research, they won't bother STEM" attitudes.
> [1] https://theweek.com/articles/441474/how-academias-liberal-bias-killing-social-science
>     "The authors also submitted different test studies to different peer-review
>     boards. The methodology was identical, and the variable was that the
>     purported findings either went for, or against, the liberal worldview (for
>     example, one found evidence of discrimination against minority groups, and
>     another found evidence of "reverse discrimination" against straight white
>     males). Despite equal methodological strengths, the studies that went
>     against the liberal worldview were criticized and rejected, and those that
>     went with it were not."
> [2] https://www.nature.com/articles/s41562-022-01443-2
>     "Advancing knowledge and understanding is a fundamental public good. In
>     some cases, however, potential harms to the populations studied may
>     outweigh the benefit of publication."
> [3] "Science Must Not Be Used to Foster White Supremacy"
>     https://www.scientificamerican.com/article/science-must-not-be-used-to-foster-white-supremacy/
> [4] "Study: Diversity Statements Required for One-Fifth of Academic Jobs"
>     https://freebeacon.com/campus/study-diversity-statements-required-for-one-fifth-of-academic-jobs/

================================================================================
20230309
How knitters got knotted in a purity spiral
https://unherd.com/2020/01/cast-out-how-knitting-fell-into-a-purity-spiral/
tags: concepts mental-model politics culture left progressive mind-control dei esg
- "moral outbidding"
- "purity spiral"
- "In game theory terms, objecting to something was now always a dominant
  strategy, and rejecting an allegation of racism was always a losing strategy."

================================================================================
20230302
Meetings *are* the work
https://medium.com/@ElizAyer/meetings-are-the-work-9e429dde6aa3
tags: work meetings organization-theory organization communication collaboration coordination project-management leverage human-scaling
- In a healthy workplace, the whole system promotes higher-quality knowledge production, above and beyond what any individual could achieve alone.
- hard-won experience visibly fed back into strategy or process. I’ve since learned that it’s really, really common to feel “my org just can’t learn.”
- organizational learning is not a simple by-product of individual learning. It’s significantly more complex for groups of people develop whole new theories-in-use and behaviors to better carry out the organization’s purpose
- consistent winners are embedded in groups that work together to improve their abilities to judge the truth of uncertain things.
- As you keep going with science, though, you find that “truth” is very much not a solid concept. The ongoing (and frankly terrifying) replication crisis in psychology, medicine, and social sciences highlights just how shaky the foundations are
- When Amazon established Bias for Action as a leadership principle, it was correcting what Bezos saw as too strict a standard of truth
- What if we put all our various knowledge tasks under the microscope: all the little choices we make to generate ideas, narrow choices, combine, reframe, highlight, focus, and decide? 
- If we recognize the ubiquity of knowledge choices, we open up so many new possibilities for manifesting intentionality in our work, it’s hard to take them all in. We have a constant stream of options of what to prioritize and where to draw attention. The aggregate dynamics from these localized choices is itself truth-making, not at a Bezos scale, but real nonetheless.
- Too often this work — the real work — has to fit in the margins of work systems designed for control and production. Our industry suffers from a deep association of work with structured productive toil, a framing that’s in every way a bad fit for knowledge work. Knowledge work is uncertain and messy (and sometimes enjoyable too). The messiness can be avoided, but only at the cost of sacrificing the power and dignity of the work itself.

================================================================================
20230309
Ramda: a practical functional library for JavaScript programmers
https://ramdajs.com/
tags: typescript javascript nodejs library
- Immutability and side-effect free functions
- Ramda functions are automatically curried. Easily build up new functions from old ones simply by not supplying the final parameters.
- Ramda functions are arranged to make it convenient for currying: the data to be operated on is generally supplied last.
"Works great with pipe which enables me to write highly reusable and composable functions in pointfree notation."
https://ramdajs.com/docs/#pipe
Example:
    // Pull traits dictionary out of tokens.
    const extractTraits = R.pipe(
      R.map(R.pipe(
        R.last,
        R.prop('attributes'))),
      R.reject(R.isNil),
      R.reduce(R.mergeWith(concatValues), {}),
      R.map(R.pipe(
        R.unless(R.is(Array), R.of),
        R.groupBy(R.identity),
        R.map(R.count(R.identity)),
        R.toPairs,
        R.sortBy(R.prop(0)),
        R.map(R.zipObj(['name', 'count'])))));

================================================================================
20230309
costs of Lodash
https://news.ycombinator.com/item?id=35056366
tags: typescript javascript nodejs library
Lodash is NOT tree-shakeable by default. So if you do `import { debounce } from
'lodash';`, you're actually including the entirety of lodash in your bundle.
More info here: https://lodash.com/per-method-packages
lodash recommends `babel-plugin-lodash` (including a babel plugin to use less code? no thanks)
or import the single modules directly like `import throttle from 'lodash/throttle';`.
There is also a `lodash-es` package with native ESM modules

================================================================================
20230312
Fennel vs Lua
https://www.reddit.com/r/neovim/comments/11nsxdu/comment/jbp9h42
tags: lua fennel lisp programming neovim nvim vim
- Fennel is still Lua. Same semantics + useful sugar.
- Destructuring, pattern-matching, nil-safe macros, expression-oriented.
- Names like pred?, side-eff!, deriv*, |length-of|, from->to, have surprising effect on readability.
Fennel:
    (fn foo [{: a : b : c : d : e}] ...)
    (foo {: A : B : C : D : E})
    (-?> foo bar baz qux)
Lua:
    local function foo (kwargs)
      local a = kwargs.a
      local b = kwargs.b
      local c = kwargs.c
      local d = kwargs.d
      local e = kwargs.e
      ...
    end
    foo { a = A, b = B, c = C, d = D, e = E }
    if foo then
      local res1 = bar(foo)
      if res1 then
        local res2 = baz(res1)
        if res2 then return qux(res2) end
      end
    end

================================================================================
20230313
FDIC Takes over Silicon Valley Bank
https://news.ycombinator.com/item?id=35098243
tags: finance banking federal-reserve
An explainer post [1] connected to that Tweet is something I found extremely informative (assuming it's accurate):
"- In 2021 SVB saw a mass influx in deposits, which jumped from $61.76bn at the end of 2019 to $189.20bn at the end of 2021.
- As deposits grew, SVB could not grow their loan book fast enough to generate the yield they wanted to see on this capital. As a result, they purchased a large amount (over $80bn!) in mortgage backed securities (MBS) with these deposits for their hold-to-maturity (HTM) portfolio.
- 97% of these MBS were 10+ year duration, with a weighted average yield of 1.56%.
- The issue is that as the Fed raised interest rates in 2022 and continued to do so through 2023, the value of SVB’s MBS plummeted. This is because investors can now purchase long-duration "risk-free" bonds from the Fed at a 2.5x higher yield.
- This is not a liquidity issue as long as SVB maintains their deposits, since these securities will pay out more than they cost eventually.
- However, yesterday afternoon, SVB announced that they had sold $21bn of their Available For Sale (AFS) securities at a $1.8bn loss, and were raising another $2.25bn in equity and debt. This came as a surprise to investors, who were under the impression that SVB had enough liquidity to avoid selling their AFS portfolio."
[1] - https://twitter.com/jamiequint/status/1633956163565002752

================================================================================
20230313
Regulators seize Signature Bank in third-biggest bank failure in U.S. history
https://www.cnbc.com/2023/03/13/signature-bank-third-biggest-bank-failure-in-us-history.html
tags: finance banking federal-reserve
Former congressman Barney Frank, co-author of the 2008 Dodd-Frank Act, is on the board of Signature Bank, a failed bank.
> On Friday, Signature Bank customers spooked by the sudden collapse of Silicon Valley Bank withdrew more than $10 billion in deposits, a board member told CNBC.
> That run on deposits quickly led to the third-largest bank failure in U.S. history. Regulators announced late Sunday that Signature was being taken over to protect its depositors and the stability of the U.S. financial system.
> “I think part of what happened was that regulators wanted to send a very strong anti-crypto message,” said board member and former congressman Barney Frank.
>
> Barney Frank, who helped draft the landmark Dodd-Frank Act after the 2008 financial crisis, said there was “no real objective reason” that Signature had to be seized.

================================================================================
20230321
Richard Werner (who pioneered "quantitative easing"): Central banks are too powerful and they’re to blame for inflation
https://fortune.com/2023/03/20/is-federal-reserve-too-powerful-inflation-quantitative-easing-richard-werner/
tags: finance banking federal-reserve monetary-policy inflation economics
- > more than 80% of those interviewed believed that most of the world’s money
  is created and allocated by either governments or central banks.
- > high-street or retail banks that produce the vast majority – around 97% – of
  the world’s money supply. Every time a bank grants a loan, it is creating new
  money that is added to the economy’s overall money supply.
- > In contrast, governments don’t create any money these days. The last time
  the US government issued money was in 1963, until President John F Kennedy’s
  assassination that year. The UK government stopped issuing money in 1927 and
  Germany even earlier, around 1910.
- > Central banks only create around 3% of the world’s money supply.
- > QE’s depiction as a form of “magic money tree” is misplaced. In my 1997
  paper and subsequent book, I stressed the difference between newly-created
  money when it is used for productive purposes – in other words, for business
  investment that creates new goods and services or increases productivity – and
  when it is used for unproductive purposes such as financial asset and real
  estate transactions. These merely transfer ownership from one party to another
  without adding to the nation’s income.
- > Unfortunately, there has been a significant shift of bank credit away from
  lending for productive business investment to lending for asset purchases.
  Bank lending for asset purchases now accounts for 75% of lending.
  - > In contrast, just before WW1 when there were many more small banks in the
    UK, more than 80% of bank lending was for productive business investment.
  - > Germany has maintained a system of many small, local retail banks, thus
    better levels of productivity.
- > in March 2001 the Bank of Japan announced the introduction of the world’s
  first programme of QE. Unfortunately, it did not follow the policy I had
  recommended. Its approach – buying well-performing assets such as government
  bonds from retail banks – had no effect on the Japanese economy, because it
  did not improve retail banks’ willingness to lend to businesses. In other
  words, no new money was being created for productive purposes.
- > In May 2020 I conducted my latest monthly analysis of the quantity of credit
  creation across 40 countries, ... The major central banks across the globe
  were boosting the money supply dramatically through coordinated QE. ... There
  is some evidence that it was sparked by a proposal presented to central
  bankers by Blackrock at Jackson Hole, Wyoming in August 2019. Soon after this,
  difficulties in the Fed’s repurchase agreement (“repo”) market in September
  2019, triggered by private banking giant JP Morgan, may have made up their
  minds.
- > Apparently agreeing with my critique that pure fiscal policy does not result
  in economic growth unless it is backed by credit creation, Blackrock had
  argued at Jackson Hole that the “next downturn” would require central banks to
  create new money and find “ways to get central bank money directly in the
  hands of public and private sector spenders” – what they called “going
  direct”, bypassing the retail banks. The Fed knew this would create inflation,
  as Blackrock later confirmed in a paper which stated that “the Fed is now
  committing to push inflation above target for some time”.
  - > However, this time the economic conditions were very different – there had
    been no recent slump in the supply of money via retail bank loans. Also, the
    policy differed in a crucial aspect: by “going direct”, the Fed was itself
    now massively expanding credit creation, the money supply and new spending.
  - > In parallel with unprecedented societal and business lockdowns (COVID),
    retail banks were instructed to increase lending to businesses with
    governments guaranteeing these loans. Stimulus checks were paid out ...
    added to the supply of money ... used for general consumption rather than
    productive purposes (loans to businesses).
  - > US’s “broad” money supply metric, M3, increased by 19.1% in 2020, the
    highest annual rise on record. In the eurozone, money supply M1 grew by
    15.6% in December 2020.
  - > boosted demand, while at the same time the supply of goods and services
    was limited by pandemic restrictions.
  - consumer price inflation duly followed ~18 months later, 2021-2022.
- CBDCs: Soviet-style monobank system, where the only bank in town is the
  central bank. The useful functions of retail banks are to create the money
  supply and allocate it efficiently via thousands of loan officers on the
  ground across the country.
  - This form of productive business investment, which creates non-inflationary
    growth and jobs, is best achieved via lending to small and medium-sized
    enterprises (SMEs).
- > Deng Xiaoping in 1978, recognised that Soviet-style monobank was holding
  back the country’s economic growth. ... switched to decentralisation by
  creating thousands of commercial banks over the following years – mostly small
  local banks that would lend to small firms, creating jobs and ensuring high
  productivity. 40 years of double-digit economic growth.
- > In Germany, local community banks have survived for 200 years because they
  use the co-operative voting system. ... prevents takeovers and hence explains
  why the German SMEs are by far the most successful in the world, contributing
  significantly to exports and Germany’s high productivity.

================================================================================
20230326
Lucius Junius Brutus
https://en.wikipedia.org/wiki/Lucius_Junius_Brutus
tags: rome history caesar
Long before the Brutus who killed Caesar, there was another Brutus:
Lucius Junius Brutus, famous since the early times of Rome.
https://news.ycombinator.com/item?id=35209758
> Romans according to legends swore to never have a king again.
>
> So these assassins who killed Caesar saw themselves as heroes, they didn't
> think they'll be regarded as criminals and condemned but expected to be the
> saviours of the republic and remembered for ages to come.
>
> Later in the revolutionary years, when e.g. french republicans were slaying
> king they too looked up to the legend of the very first Brutus and saw
> themselves not merely assassins but heroes of the people.
>
> In the case of the very first Brutus, they swore to kill the king after he
> raped and killed one of his companions wife, one can definitely argue he was
> a heroic figure. In the case of latter wannabe Brutuses it's very clear they
> aimed for power consciously or subconsciously hiding behind ideals. The
> subsequent genocides and thefts of property like in the case of French
> revolution or Lenin's who even died of syphilis are just too obvious.

================================================================================
20230419
How WebAssembly is accelerating new web functionality
https://blog.chromium.org/2023/04/how-webassembly-is-accelerating-new-web.html
tags: wasm wasi web webassembly portability browser chromium google
- "SQLite on WASM" will replace "Web SQL".
  https://developer.chrome.com/blog/sqlite-wasm-in-the-browser-backed-by-the-origin-private-file-system/
- DISADVANTAGES AND LIMITATIONS
  - Won’t replace JavaScript for most web development.
  - WebAssembly in the browser is still entirely dependent on JavaScript and needs
    to interface through JavaScript to access other web functionality.
    - Proposals to enable wasm-to-wasm module communication and direct interfacing
      with Web APIs are in the early stages.
  - Bundle size of pages. By moving more logic and functionality into userland,
    the size of pages will increase as well.
    - Potential mitigation: look at the popular functionality being shipped in
      userland and to decide what functionality should be standardized in the
      browser itself.
      - Example: WebCodecs replaced wasm-compiled FFMPEG
      - Example: handwriting-recognition API replaced the wasm-compiled option
  - Device capability access
    - WebAssembly and other primitives are largely computation mechanisms and
      don't give any kind of root system access to the OS or device itself.
      Functionality like hardware access (USB or Bluetooth), screen or window
      management, input controls, file system, clipboard, and much more still
      require platform level APIs to access.
      - "Fugu" project aims to enable all of these for Chromium-based browsers.
        https://www.chromium.org/teams/web-capabilities-fugu/
    - WASI?

================================================================================
20230501
vscode-wasm: WASI implementation that uses VS Code's extension host as the implementing API
https://github.com/microsoft/vscode-wasm
tags: webassembly wasm wasi vscode javascript nodejs
https://github.com/microsoft/vscode-wasm/commit/0cdb9997d83bae116bb7693ba6837ffa812425a7
  Implement a first version of a WebShell (#60)
  * Start of web shell
  * First cut of coreutils commands
  * Add more coreutils commands
  * Update dependencies
  * Add virtual root FS
  * Virtual FS fixes
  * Make virtual root file system a tree
  * Make VFS hierarchical.
  * Virtual FS fixes
  * Fix Python testbed
  * Minor fixes
  * Support a command history
  * Update testbeds
  * Fold equal history elements

================================================================================
20230423
zod: TypeScript-first schema validation with static type inference
https://github.com/colinhacks/zod
tags: typescript javascript nodejs library schemas types
Zod is a schema declaration and validation library, i.e. _data validation_ at runtime (like Clojure "Spec").
Declare a validator and Zod infers the static TypeScript type.
Easy to compose simpler types into complex types.
- Zero dependencies
- Works in Node.js and all modern browsers
- Tiny: 8kb minified + zipped
- Immutable: methods (e.g. .optional()) return a new instance
- Concise, chainable interface

================================================================================
20230502
Systems design explains the world: volume 1
https://apenwarr.ca/log/20201227
tags: systems architecture concepts mental-model
- "Systems design" is a branch of study that tries to find universal architectural patterns that are valid across disciplines.
- The Tyranny of Structurelessness by Jo Freeman https://www.jofreeman.com/joreen/tyranny.htm
  "This apparent lack of structure too often disguised an informal,
  unacknowledged and unaccountable leadership that was all the more pernicious
  because its very existence was denied."
- "Informal, unacknowledged, and unaccountable" control is just as common in
  distributed computing systems as it is in human social systems.
- Nearly every attempt to design a hierarchy-free, "flat" control system just
  moves the central control around until you can't see it anymore. Human
  structures all have leaders, whether implicit or explicit
  - The explicit ones tend to be _more_ diverse.
- with centralized vs distributed systems, at least make sure the control
  structure is explicit. When it's explicit, you can debug it.
- chicken-egg problem: Firefox and Ubuntu phones, distributed open source social
  networks, alternative app stores, Linux on the desktop, Netflix
  competitors. IPv6: it provides nearly no value to anyone until it is 100%
  deployed (so we can finally shut down IPv4!), but costs immediately in added
  complexity and maintenance (building and running a whole parallel Internet).
  Could IPv6 have been rolled out faster, if the designers had prioritized
  unwinding the chicken-egg problem? Absolutely yes. But they didn't acknowledge
  it as the absolute core of their design problem, the way Android, Xbox,
  Blu-Ray, and Facebook did.
- Innovator's Dilemma (also: IMPORTANCE OF THE "LONG TAIL"!):
  You (Intel in this case) make an awesome product in a highly profitable
  industrSome crappy startup appears (ARM in this case) and makes a crappy
  competing product with crappy specs. The only thing they seem to have going
  for them is they can make some low-end garbage for cheap. As a big successful
  company, your whole business is optimized for improving profits and margins.
  Your hard-working employees realize that if they cede the ultra-low-end
  garbage portion of the market to this competitor, they'll have more time to
  spend on high-valued customers. As a bonus, your average margin goes up!
  The next year, your competitor's product gets just a little bit better, and
  you give up the new bottom of your market, and your margins and profits
  further improve. This cycle repeats, year after year. (We call this
  "retreating upmarket." The crappy competitor has some kind of structural
  technical advantage that allows their performance to improve, year over year,
  at a higher percentage rate than your product can. And/or their product can do
  something yours can't do at all (in ARM's case: power efficiency) Eventually,
  one year, the crappy competitor's product finally exceeds the performance
  metrics of your own product, and promptly blows your entire fucking company
  instantly to smithereens.

================================================================================
20230502
Systems design 2: What we hope we know
https://apenwarr.ca/log/20230415
tags: systems architecture concepts

================================================================================
20230511
Give super powers to Java with WebAssembly by Philippe Charriere @ Wasm I/O 2023
https://www.youtube.com/watch?v=5HBglrvHtWg
tags: webassembly wasm library code-reuse code-sharing java
use Extism https://github.com/extism/extism to load WASM library in java

================================================================================
20230511
Extism: Universal Plug-in System. Extend anything with WebAssembly (wasm).
https://extism.org/
tags: webassembly wasm library code-reuse code-sharing
https://github.com/extism/extism
- Extism is a layer around wasmtime
    - except in the browser: there the browser-native impl is used instead of wasmtime
    - allows Extism to run the same plugins in browser and non-browser
- provides a quasi-ABI that helps you communicate with the plugin: get/send data, invoke functions.
- don't need to enable WASI to use a plugin.
- future: may replace some internal pieces of Extism with pieces of the Component Model spec.

================================================================================
20230515
Amazon’s quiet open source revolution
https://www.infoworld.com/article/3694090/amazon-s-quiet-open-source-revolution.html
tags: amazon aws open-source oss

================================================================================
20230515
Example of LLM prompting for programming
https://martinfowler.com/articles/2023-chatgpt-xu-hao.html
tags: llm ai machine-learning programming
Start with a prompt that sets the context for the application and how you want the code to be structured:
    The current system is an online whiteboard system. Tech stack: typescript, react, redux, konvajs and react-konva. And vitest, react testing library for model, view model and related hooks, cypress component tests for view.
    All codes should be written in the tech stack mentioned above. Requirements should be implemented as react components in the MVVM architecture pattern.
    There are 2 types of view model in the system.
    Shared view model. View model that represents states shared among local and remote users.
    Local view model. View model that represents states only applicable to local user
    Here are the common implementation strategy:
    Shared view model is implemented as Redux store slice. Tested in vitest.
    Local view model is implemented as React component props or states(by useState hook), unless for global local view model, which is also implemented as Redux store slice. Tested in vitest.
    Hooks are used as the major view helpers to retrieve data from shared view model. For most the case, it will use ‘createSelector’ and ‘useSelector’ for memorization. Tested in vitest and react testing library.
    Don’t dispatch action directly to change the states of shared view model, use an encapsulated view model interface instead. In the interface, each redux action is mapped to a method. Tested in vitest.
    View is consist of konva shapes, and implemented as react component via react-konva. Tested in cypress component tests
    Here are certain patterns should be followed when implement and test the component
    When write test, use describe instead of test
    Data-driven tests are preferred.
    When test the view component, fake view model via the view model interface
    Awareness Layer
    Requirement:
    Display other users’ awareness info(cursor, name and online information) on the whiteboard.
    AC1: Don’t display local user
    AC2: When remote user changes cursor location, display the change in animation.
    Provide an overall solution following the guidance mentioned above. Hint, keep all awareness information in a Konva layer, and an awareness info component to render cursor, and name. Don’t generate code. Describe the solution, and breaking the solution down as a task list based on the guidance mentioned above. And we will refer this task list as our master plan.
- The key element of the response is an ordered task list, with numbers for each
  step. We can use these numbers to refer to these tasks for the rest of the
  session.
- You can now look at the master plan and see if it makes sense. If there are
  problems with it, you can ask ChatGPT to re-write some of the tasks or the
  entire master plan by providing more information.

================================================================================
20230524
Mini.WebVM: Your own Linux box from Dockerfile, virtualized in the browser via WebAssembly
https://leaningtech.com/mini-webvm-your-linux-box-from-dockerfile-via-wasm/
https://github.com/leaningtech/webvm
tags: wasm webassembly vm web

================================================================================
20230520
MPT-7B: A New Standard for Open-Source, Commercially Usable LLMs
https://www.mosaicml.com/blog/mpt-7b
https://github.com/mosaicml/llm-foundry
tags: machine-learning llm chatgpt programming open-source
MPT-7B is a transformer trained from scratch on 1T tokens of text and code.
It is open source, available for commercial use, and matches the quality of LLaMA-7B.
MPT-7B was trained on the MosaicML platform in 9.5 days with zero human intervention at a cost of ~$200k.
You can train, finetune, and deploy your own private MPT models, either starting from one of our checkpoints or training from scratch.

================================================================================
20230520
The Deming Paradox: Operationally Rigorous Companies Aren't Very Nice Places to Work. — Cedric Chin
https://commoncog.com/deming-paradox-operational-rigour/
tags: concepts mental-model operations metrics team workplace
- W. Edwards Deming, the father of "Statistical Process Control" (SPC).
- Origin of Amazon’s operational rigour.
- Understanding variation is the beginning of ‘knowledge’.
  - routine variation is present in every natural process
  - setting a target does not in itself help you achieve that target
- Myths Deming saw in management practice: common sense tells us to rank
  children, employees, students, and teams; to reward the “best” and punish the
  “worst”; to have quotas and numerical goals for individuals or groups; to
  assume that a problem always is caused by the people doing the work instead of
  the system in which they operate.
- Run chart: "Dubose printed run charts for each vessel and posted them in the
  skippers’ cabins. Each skipper could then see for themselves where they were
  running up costs and where they were saving money. Dubose turned each skipper
  into his own manager. Skippers were free to make their own decisions based on
  the run chart. Then Dubose went further. He started tracking the profits and
  losses for each barge. This made each skipper a small-business owner and each
  barge a small business. The skipper had all the information he needed to boost
  profits and the freedom to act on that information. And Dubose had total
  visibility ... 'It got to the point where the boats were competing against
  each other.'"

================================================================================
20230520
High-performance tidy trees visualization
https://www.zxch3n.com/tidy/tidy/
https://github.com/zxch3n/tidy
https://news.ycombinator.com/item?id=35995953
tags: algorithm tree layout diagram
Algorithm to draw non-layered trees in linear time and re-layout partially when
some nodes change in O(d) time, where d is the maximum depth of the changed
node.

================================================================================
20230521
We Aren't Close To Creating A Rapidly Self-Improving AI
https://jacobbuckman.substack.com/p/we-arent-close-to-creating-a-rapidly
tags: ai llm machine-learning deep-learning chatgpt
- No known way to automatically construct datasets.
  - Solving this would be a field-changing breakthrough, comparable to transitioning from alchemy to chemistry.
  - Requires an actionable understanding of which datapoints are important for learning.
  - Therefore AIs are currently bottlenecked by the ability of humans to construct good datasets; this makes a rapid self-improving ascent to godhood impossible.
- Active deep learning / deep reinforcement learning (DRL): AI which can interact and collect own data (via simulation or other experiments).
  - The model itself is "in the loop".
  - Interleaving learning + interaction (simulation) allows AI abilities to grow indefinitely.
  - 2018 produced superhuman AIs on simulable tasks (*not* passive imitation): AlphaZero, OpenAI, self-driving cars, robotic hands.
    - Hype has since fizzled out.
    - DRL restricted to tasks that can be reliably and cheaply *simulated*.
- Passive learning (GPT-3/GPT-4): separate (human) data-collection and model-training phases.
- "We get a superintelligence explosion only if the model can collect its own data more efficiently than humans can create datasets."
- Efficient active learning is as hard as *understanding generalization*.
  - Active learning is difficult and unsolved, because all problems that require understanding generalization are difficult and unsolved (another such problem is preventing adversarial examples).
  - And they aren’t getting more-solved over time: we’ve made little-to-no progress on any problem of this sort in the last decade.
- The rules of reality are *not* logic/math/physics. Those are just approximations to the rules of reality that we inferred from *observing* reality. These things are our attempt to model the world, and they are accurate in some domains and invalid in others.
- Key human capability: reason *without* total knowledge / hyper-simulation.

================================================================================
20230521
Tesla, GPT-4, FSD - AI is a big deal w⧸ James Douma (Ep. 728)
https://youtu.be/Z9dlPsii4HM
tags: ai llm machine-learning deep-learning chatgpt tesla
James Douma: "The reason we've never understood intelligence is because
intelligence is an embodiment of the complexity of the world. Back-propagation,
the fundamental mechanism of neural networks, is extremely simple; the
complexity is embedded in the data [encoded as billions of neurons] captured
from reality."

================================================================================
20230521
The End of the Future - Peter Thiel
https://www.youtube.com/watch?v=ibR_ULHYirs
tags: technology engineering economics politics
- Could solve all of society's problems with just 4% GDP growth.
- Why science/tech progress so slow in the last ~50 years? Too dystopian,
  dual-use: MRNA vaccine conflated w/ gain-of-function, nuclear power conflated
  w/ nuclear bomb, etc.
- However dangerous technology is, global totalitarianism (WEF's answer to
  prevent dangerous technology) is more dangerous.
- "Optimism and pessimism are just forms of (bad) therapy. ... They both sum up
  to sloth, where you're not going to do anything."

================================================================================
20230521
Evolution of Wasm Standards: Building the Component Model for Wasm
https://cosmonic.com/blog/engineering/evolution-of-wasm-standards-building-the-component-model
tags: wasm webassembly wasi web plugin module
- > I expect components to make designing a LANGUAGE-NEUTRAL PLUGIN SYSTEM for
  a web application even easier. If there's a piece needed for a language
  runtime like python, multiple components that leverage that language runtime
  could use it. Compare this to today's world, where we only have Wasm modules
  (not components) and these are typically built with all of its compile-time
  dependencies baked into a single binary.
- For language interoperability nirvana, we need registries and package managers
  in various language ecosystems to interop with Wasm components.
  - warg registry protocol, part of SIG-Registries https://github.com/bytecodealliance/SIG-Registries
    enables any registry that implements the protocol to publish, consume,
    store, and share WASM components.

================================================================================
20230528
A Mathematician’s Lament, by Paul Lockhart
https://www.maa.org/external_archive/devlin/LockhartsLament.pdf
tags: math learning pedagogy
> TRIGONOMETRY. Two weeks of content are stretched to semester length by masturbatory definitional runarounds.
> Truly interesting and beautiful phenomena, such as the way the sides of a triangle depend on its angles,
> will be given the same emphasis as irrelevant abbreviations and obsolete notational conventions,
> ... The measurement of triangles will be discussed without mention of the transcendental nature of the trigonometric functions.
> PRE-CALCULUS. Technical definitions of ‘limits’ and ‘continuity’ are presented in order to
> obscure the intuitively clear notion of smooth change.
> CALCULUS. This course will explore the mathematics of motion, and the best ways to bury it
> under a mountain of unnecessary formalism. Despite being an introduction to both the
> differential and integral calculus, the simple and profound ideas of Newton and Leibniz will be
> discarded in favor of the more sophisticated function-based approach developed as a response to
> various analytic crises which do not really apply in this setting...

================================================================================
20230528
Buridan's ass
https://www.microsoft.com/en-us/research/publication/buridans-principle/
tags: philosophy compsci computation-theory information-theory mental-model concept electronics
- Buridan's ass
  - an ass that starves to death because it is placed equidistant between two bales of hay and has no reason to prefer one to the other.
  - an illustration of a paradox in philosophy in the conception of free will.
- Arbiter problem
  - "metastability" in digital electronics: when a circuit must decide between
    two states based on an input that is in itself undefined (neither zero nor
    one). Metastability becomes a problem if the circuit spends more time than
    it should in this "undecided" state (usually the clock speed).
  - In asynchronous circuits, arbiters guarantee that one outcome is selected at
    any given point in time, but may take an indeterminate (albeit typically
    extremely short) time to choose.

================================================================================
20230528
On the Glitch Phenomenon (aka the "Arbiter problem") - Leslie Lamport, Richard Palais
https://www.microsoft.com/en-us/research/publication/on-the-glitch-phenomenon/
tags: compsci computation-theory information-theory mental-model concept
- If two inputs can drive a flip-flop into two different states, then there must
  exist an input that makes the flip-flop hang.
- An arbiter cannot have a bounded response time.

================================================================================
20230528
A new theory of constitutional cynicism
https://graymirror.substack.com/p/a-new-theory-of-constitutional-cynicism
tags: curtis-yarvin history constitution usa
>> The Articles of this Confederation shall be inviolably observed by every
>> State, and the Union shall be perpetual; nor shall any alteration at any time
>> hereafter be made in any of them; unless such alteration be agreed to in
>> a Congress of the United States, and be afterwards confirmed by the
>> legislatures of every State.
>
> No such thing was done. The Constitution was ratified by the states under its
> own terms. Nice trick if you can get away with it. (Modern historians see that
> trick much the way the contemporary opponents of the Constitution did—as
> a right-wing coup to install a quasi-monarchical regime and rein in the
> turbulent and dysfunctional street democracy of the Confederation period.)

================================================================================
20230529
wazero: the zero dependency WebAssembly runtime for Go
https://wazero.io/
tags: go wasm webassembly

================================================================================
20230602
WASIX: posix compat (instead of WASI)
https://wasmer.io/posts/announcing-wasix
tags: wasm webassembly wasi web posix

================================================================================
20230602
directories-rs
https://github.com/dirs-dev/directories-rs
tags: os filesystem standards xdg
library that provides config/cache/data paths, following the respective
conventions on Linux, macOS and Windows, by leveraging:
- the XDG base directory and the XDG user directory specifications on Linux
- the Known Folder API on Windows
- the Standard Directories guidelines on macOS

================================================================================
20230606
Carthago delenda est
https://en.wikipedia.org/wiki/Carthago_delenda_est
tags: concepts quotation latin
Ceterum (autem) censeo Carthaginem esse delendam ("Furthermore, I consider that Carthage must be destroyed").
- Cato, a veteran of the Second Punic War, was shocked by Carthage's wealth, which he considered dangerous for Rome.
  He then relentlessly called for its destruction and ended all of his speeches with the phrase, even when the debate was on a completely different matter.
- Corculum opposed the war ... Like Cato, he ended all his speeches with
  "Carthage must be saved" (Carthago servanda est).
- Cato finally won the debate after Carthage had attacked Massinissa, which gave
  a casus belli to Rome.

================================================================================
20230606
Casus belli
https://en.wikipedia.org/wiki/Casus_belli
tags: concepts quotation latin
"Act of War"

================================================================================
20230614
vermicular, vermiform
https://en.wiktionary.org/wiki/vermicular
tags: words concepts latin
like a worm in form or movement

================================================================================
20230615
FANN: Vector Search in 200 Lines of Rust
https://fennel.ai/blog/vector-search-in-200-lines-of-rust/
tags: ai llm machine-learning deep-learning algorithm data-structure vector tensor
## Introduction to Vectors (aka Embeddings)
  Complex unstructured data like docs, images, videos, are difficult to represent and query in traditional databases – especially if the query intent is to find "similar" items.
  Advances in AI in early 2010s (starting with Word2Vec and GloVe) enabled us to build semantic representation of these objects in which they are represented as points in cartesian space. Say one video gets mapped to the point [0.1, -5.1, 7.55] and another gets mapped to the point [5.3, -0.1, 2.7]. Representations are chosen such that they maintain semantic information –  more similar two videos, smaller the distance is between their vectors.
  Note that these vectors ("embeddings") are N-dimensional (say 128 or 750). And the distance doesn't need to be euclidean - other forms of distances, like dot products, also work.
  How do we find the most similar video to a given starting video? Loop through all the videos, compute the distance between them and choose the video with the smallest distance - also known as finding the "nearest neighbours" of the query video. But a linear O(N) scan can be too costly. So we need a faster sub-linear way to find the nearest neighbours of any a query video. This is in general impossible.
  But we don't need to find _the_ nearest video, just _near-enough_: approximate nearest neighbor search.
  The goal is to sub-linearly (ideally in logarithmic time) find close enough nearest neighbours of any point in a space.
## How to Find Approximate Nearest Neighbours?
  The basic idea vector search algorithms is: do some pre-processing to identify  points that are close enough to each other (somewhat like building an index). At the query time, use this "index" to rule out large swath of points. And do a linear scan within the small number of points that weren't ruled out.
  But there are lots of ways to approach this. Several state-of-the-art vector search algorithms exist like [HNSW](https://github.com/nmslib/hnswlib?ref=fennel.ai) (a graph that connects close-proximity vertices and also maintains long-distance edges with a fixed entry point). There exist open-source efforts like Facebook’s [FAISS](https://github.com/facebookresearch/faiss?ref=fennel.ai) and several PaaS offerings for high-availability vector databases like [Pinecone](https://www.pinecone.io/?ref=fennel.ai) and [Weaviate](https://weaviate.io/?ref=fennel.ai).
In this post, we will build a simplified vector search index over the given "N" points as follows:
  1. Randomly take 2 arbitrary available vectors A and B.
  2. Calculate the midpoint C.
  3. Build a hyperplane (high-dimension analog of a "line") that passes through C and is perpendicular to the line segment AB.
  4. Classify all the vectors as being either “above” or “below” the hyperplane, splitting the available vectors into 2 groups.
  5. For each of the two groups: if the size of the group is higher than a configurable “maximum node size”, recursively call this process on that group to build a subtree.
     Else, build a single leaf node with all the vectors (or their unique ids).
We thus use this randomized process to build a tree where every internal node is a hyperplane definition with the left subtree being all the vectors “below” the hyperplane and the right subtree being all the vectors “above”.
The set of vectors are continuously recursively split until leaf nodes contain no more than “maximum node size” vectors.
Each region represents a leaf node and the intuition is that "close enough" points are likely to end up in the same leaf node.
So given a query point, we can traverse down the tree in logarithmic time to locate the leaf it belongs to and run a linear scan against all the (small number of) points in that leaf.
This is obviously not foolproof - it's totally possible that points that are actually close enough get separated by a hyperplane and end up very far off from each other.
But this problem can be tackled by building not one but many independent trees - so if two points are close enough, they are far more likely to be in the same leaf node in at least some trees.
At the query time, we traverse down all the trees to locate the relevant leaf nodes, take a union of all the candidates across all leaves, and do a linear scan on all of them.

================================================================================
20230622
The “false consensus effect”: An egocentric bias in social perception and attribution processes
https://www.sciencedirect.com/science/article/abs/pii/002210317790049X
tags: concepts psychology mental-model
False consensus effect: the belief that your own behavioral choices and
judgments are relatively common and appropriate to existing circumstances.
May cause you to do or avoid things because we assume other people think the same.

================================================================================
20230629
The Random Forest Algorithm
https://mlu-explain.github.io/random-forest/
tags: machine-learning statistics math concepts mental-model
- Random Forest is an example of ensemble learning where each model is
  a decision tree.
- If we ask two more decision trees each having 60% accuracy, and decide by the
  majority vote, then the probability of the vote being right goes up.
- Caveat: the accuracy may not improve if each model produces the same
  prediction, for example. The mistake of one model would not be caught by the
  other models.
- Condorcet's Jury Theorem: if each person is more than 50% correct, then adding
  more people to vote increases the probability that the majority is correct.
  - Marquis de Condorcet, 1785 political science theorem about the relative
    probability of a group of people to arrive at a correct majority decision.

================================================================================
20230705
metals LSP extensions
https://github.com/scalameta/metals/tree/7d0397b3f8fe016b92fd46fdfc1a39b68b3cd715/docs/integrations
tags: lsp scala rpc api protocol
- LSP extension: "Decoration Protocol" to display non-editable text in the text editor. https://github.com/scalameta/metals/blob/7d0397b3f8fe016b92fd46fdfc1a39b68b3cd715/docs/integrations/decoration-protocol.md
  - `initialize`
    The Decoration Protocol is only enabled when client declares support for the protocol by adding an decorationProvider: true field to the `initializationOptions` during the `initialize` request.
  - `metals/publishDecorations`
    Sent from the server to the client to notify that decorations have changes for a given text document.
- LSP extension: "Tree View Protocol": https://github.com/scalameta/metals/blob/7d0397b3f8fe016b92fd46fdfc1a39b68b3cd715/docs/integrations/tree-view-protocol.md
  - `initialize`
    The Tree View Protocol is only enabled when both the client and server declare
    support for the protocol by adding an `treeViewProvider: true` field to the
    experimental section of the server and client capabilities in the `initialize`
    response.
  - `metals/treeViewChildren`
    The tree view children request is sent from the client to the server to get the
    children nodes of a tree view node. The client is safe to cache the response of
    the children until server sends a `metals/treeViewDidChange` notification for
    the parent node or one of its ancestor nodes.
  - `metals/treeViewParent`
    The tree view parent request is sent from the client to the server to obtain the
    parent node of a child node. The `metals/treeViewParent` endpoint is required to
    support `metals/treeViewReveal`.
  - `metals/treeViewDidChange`
    The tree view did change notification is sent from the server to the client to
    notify that the metadata about a given tree view node has changed.
  - `metals/treeViewVisibilityDidChange`
    The visibility did change notification is sent from the client to the server to
    notify that the visibility of a tree view has changed.
  - `metals/treeViewNodeCollapseDidChange`
    The collapse did change notification is sent from the client to the server to
    notify that a tree node has either been collapsed or expanded.
  - `metals/treeViewReveal`
    The reveal request is sent from the client to the server to convert a text
    document position into it's corresponding tree view node.

================================================================================
20230625
My favorite things about working at companies with a culture of writing
https://news.ycombinator.com/item?id=30361655
https://web.archive.org/web/20220217150254/https://founder-fodder.ghost.io/writing-cultures-win/
tags: documentation communication work habits teams amazon
- Paul Graham: "Writing about something, even something you know well, usually
  shows you that you didn't know it as well as you thought. Putting ideas into
  words is a severe test."
- Less political orgs: companies without a culture of writing tend to be the
  most political.
- More backlinks to you and your work: Being the teammate that contributes to
  the system of knowledge shared shows how much you care about the success of
  the organization. And it helps you have more documented and attributable
  credibility for the value you create.
- counterpoint/caution: "optimization of x destroys the rest of the alphabet."
  - Rules are coordination mechanisms that carry the capacity to destroy value.
  - Due to the "culture of writing and reading" I spend most of my time mired in
    documents. Every breath we take produces a wall of text that must be
    reviewed and commented on.
    - Not every question deserves a one-pager. Not every potential code change
      must be foreshadowed by an exhaustive treatment.

================================================================================
20230626
fullmoon
https://github.com/pkulchenko/fullmoon
tags: lua web framework
Fast and minimalistic Redbean-based Lua web framework in one file.

================================================================================
20230626
A Pathway to Equitable Math Instruction Dismantling Racism in Mathematics Instruction
https://equitablemath.org/wp-content/uploads/sites/2/2020/11/1_STRIDE1.pdf
tags: politics dei progressivism math
- "Upholding the idea that there are always right and wrong answers perpetuates objectivity".
- "Terms used to identify white supremacy characteristics as defined by Jones and Okun (2001):"
  - Perfectionism
  - Sense of Urgency
  - Defensiveness
  - Quantity Over Quality
  - Worship of the Written Word
  - Paternalism
  - Either/Or Thinking
  - Power Hoarding
  - Fear of Open Conflict
  - Individualism
  - Only One Right Way
  - Progress is Bigger, More
  - Objectivity
  - Right to Comfort
CONTENT DEVELOPERS
Sonia Michelle Cintron, Math Content Specialist, UnboundEd
Dani Wadlington, Director of Mathematics Education, Quetzal Education Consulting
Andre ChenFeng, Ph.D. Student, Education at Claremont Graduate University
FEEDBACK ADVISORS
Kyndall Brown, Executive Director, California Mathematics Project
Denise Green, Educational Administrator, Mathematics, Monterey County Office of Education
Manuel Buenrostro, Policy Associate, Californians Together
Ana Benderas, Director of Humanities Education

================================================================================
20230626
Maximally Powerful, Minimally Useful
https://blog.higher-order.com/blog/2014/12/21/maximally-powerful/
tags: systems architecture concepts mental-model mathematics
- Expressiveness-analyzability tradeoff in language and systems design: the more expressive a language or system is, the less we can reason about it, and vice versa.
- In mathematics: either the *set* of things you’re working with has nice
  properties (e.g., for the reals, completeness) and supports nice constructions
  with no caveats (e.g., for the reals, limits); or each of the *things* in the
  set is individually nice and tractable (e.g. computable). https://news.ycombinator.com/item?id=36106629
  - Sometimes the direction of the axis is not obvious (real numbers lack
    solutions for algebraic equations; complex numbers lack smooth functions
    nonzero only in a finite region), but usually a simple family of "eldritch
    objects" is easier to deal with than a byzantine clan of "cuddly objects".
- "Generally: a restriction at one semantic level translates to freedom and power at another semantic level."

================================================================================
20230626
A Revolution in Mathematics? What Really Happened a Century Ago and Why It Matters Today - Frank Quinn
http://www.ams.org/notices/201201/rtx120100031p.pdf
tags: mathematics history concepts
Major components of the new methods are:
- Precise definitions: Old definitions usually described what things are
  supposed to be and what they mean, and extraction of properties relied to some
  degree on intuition and physical experience. Modern definitions are completely
  selfcontained, and the only properties that can be ascribed to an object are
  those that can be rigorously deduced from the definition.
- Logically complete proofs: Old proofs could include appeals to physical
  intuition (e.g., about continuity and real numbers), authority (e.g., “Euler
  did this so it must be OK”), and casual establishment of alternatives (“these
  must be all the possibilities because I can’t imagine any others”). Modern
  proofs requ

================================================================================
20230626
Tainter's theory of collapse
https://en.wikipedia.org/wiki/Joseph_Tainter
tags: history concepts civilization economics misallocation
Tainter argues that sustainability or collapse of societies follow from the
success or failure of problem-solving institutions and that societies collapse
when their investments in social complexity and their energy subsidies reach
a point of diminishing marginal returns.

================================================================================
20230627
Lithium controversy
https://news.ycombinator.com/item?id=36476337
tags: lithium electric-vehicles engineering politics environmentalism
> Compared to all other basic materials we use in our life, lithium is pretty mundane. No war has been faught over cobalt. It's a byproduct of other mining, and quickly being phased out for cheaper less controversial materials.
>
> Lithium mining gets a bad rap not because it's particularly environmentally devastating, but because of political narratives that try to prevent technological change. Lithium is really a mundane material. You never hear people complaining about potash mining or other similar salt extraction, lithium is just targeted because of the industries that it upsets, which are in turn orders of magnitude more damaging.
>
> Which isn't to say that we shouldn't make it as environmentally friendly as possible. I'm just saying that if you fill up a tank of gas, you have a hell of a lot more to answer for when it comes to environmental karma than if you fill an equivalent lithium battery.
>
> The wars in the Congo were fought over Nickel and Diamonds. No one cared about Cobalt in most centuries. It was the shiny waste product of Nickel mines that sometimes artists enjoyed painting with. Even at the peak of the worst of Lithium Ion battery formulations "demand" for Cobalt almost all of it was sourced from Nickel mining "waste". Cobalt is the "waste product". Nickel was always the primary reason for all the mining. (Nickel will likely always be the primary reason. Especially now as Lithium Ion formulations have mostly eliminated Cobalt in recent years.)
.
- https://en.wikipedia.org/wiki/Lithium_mining_in_Australia
  > Australia has one of the biggest lithium reserves and is the biggest producer of lithium by weight, with most of its production coming from mines in Western Australia. Most Australian lithium is produced from hard-rock spodumene, in contrast to other major producers like Argentina, Chile and China, which produce it mainly from salt lakes.
- https://www.epa.wa.gov.au/media-statements/expansion-greenbushes-lithium-mine-recommended-environmental-approval
  Processing can be very polluting, it can also be closely watched and contained with plant wide pads under layed with membranes that are regulalry monitored, inspected, fined for breach, etc.

================================================================================
20230717
timecraft: WebAssembly Time Machine
https://github.com/stealthrocket/timecraft
tags: webassembly wasm
License: AGPLv3
The Time Machine records the program execution, and can be accessed to get
insight from the program that was executed. It can reconstruct high level
context such as the HTTP requests and responses that were exchanged by the
application, for example:

    $ timecraft trace request -v ffe47142-c3ad-4f61-a5e9-739ebf456332
    2023/06/28 23:29:05.043455 HTTP 172.16.0.0:49152 > 44.206.52.165:443
    > GET / HTTP/1.1
    > Host: eo3qh2ncelpc9q0.m.pipedream.net
    > User-Agent: Go-http-client/1.1
    > Accept-Encoding: gzip
    >
    < HTTP/1.1 200 OK
    < Date: Thu, 29 Jun 2023 06:29:04 GMT
    < Content-Type: text/html; charset=utf-8
    < Content-Length: 14
    < Connection: keep-alive
    < X-Powered-By: Express
    < Access-Control-Allow-Origin: *
    <
    Hello, World!

================================================================================
20230717
Understanding WASM, Part 2: Whence WASM
https://www.neversaw.us/2023/06/30/understanding-wasm/part2/whence-wasm/
tags: webassembly wasm vm virtual-machine
- WebAssembly pulled the same magic trick C did: it extracted an existing,
  useful abstract machine definition from several concrete implementations, like
  finding David in the block of marble. Rather than requiring that browser
  vendors implement a second virtual machine, WebAssembly support could be added
  incrementally, sharing code between the JS and WASM runtimes.
- WebAssembly described a zero-capability system with no set system interface,
  making it an ideal sandbox. Riding along with the web platform meant a free
  ticket to just about every computer with a screen
- Because WASM describes a machine, not an implementation, it is not constrained
  to run only in browser JIT VMs. WASM has been successully used outside of the
  browser via runtimes like wasmtime and wasmer and as a sandboxing intermediate
  representation for 3rd-party C code via wasm2c and RLBox34. ("Has a" vs. "Is
  a": WebAssembly is not a "virtual machine" runtime, it has many indepedent
  virtual machine runtimes. The performance of browser WASM runtimes may not be
  indicative of overall performance boundaries for the ISA.)
- Prior to asm.js, JavaScript (and Smalltalk/Java) presented a virtual machine
  to programs that was attuned to the needs of the _host_ language. asm.js and
  WebAssembly discovered a virtual instruction set computer hiding in the
  optimizing virtual machine runtimes of JavaScript. A similar virtual
  instruction set computer could probably be found in the JVM or even the
  Strongtalk VM, but neither of those VMs had the advantage of riding along with
  the browser or being subject to the particular performance, isolation, and
  security requirements of the web platform.
- How does WebAssembly compare to LLVA's design goals for a virtual ISA?
  - ✅ Simple, low-level operations. WebAssembly operates in terms of functions and mathematical operations on machine types and memory.
  - ✅ No execution-oriented features. The stack is not visible from within the WebAssembly process runtime, no addressing modes are specified, compilers are free to generate whichever calling convention fits their needs.
  - ✅ Portability across processor designs.
  - ✅ High-level information to support optimization. Loops, branches, and function information is retained, allowing for function inlining, loop unrolling, loop-invariant-code-motion, and other optimizations.
  - ✅ Language independence. Any language that targets the C abstract machine can target WebAssembly.
    ❓ Garbage collected languages are difficult to implement efficiently on top of WASM, currently.
  - ❓ Operating system support. (future: WASI)

