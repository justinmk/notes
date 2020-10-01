vim: sw=2 ft=text comments=s1\:/*,mb\:*,ex\:*/,\://,b\:#,\:%,\:XCOMM,n\:>,fb\:-

Solving Problems the Clojure Way - Rafal Dittwald
================================================================================
https://www.youtube.com/watch?v=vK1DazRK_a0
tag="clojure functional-programming compsci"
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


Unraveling the JPEG
================================================================================
https://parametric.press/issue-01/unraveling-the-jpeg/
tag="todo image format encoding huffman"

Netflix Tech Blog: Linux Performance Analysis in 60,000 Milliseconds
================================================================================
  href="http://techblog.netflix.com/2015/11/linux-performance-analysis-in-60s.html"
  tag="performance checklist linux devops sysadmin"
  time="2016-01-18T06:02:33Z" 

Linux Performance Observability
================================================================================
http://www.brendangregg.com/linuxperf.html
tag="todo performance unix linux devops sysadmin"

Scaling to 100M: MySQL is a Better NoSQL
================================================================================
http://blog.wix.engineering/2015/12/10/scaling-to-100m-mysql-is-a-better-nosql/
https://news.ycombinator.com/item?id=11763287
tag="todo performance distributed-systems scaling mysql databases"

Common mistakes in PostgreSQL
================================================================================
https://wiki.postgresql.org/wiki/Don%27t_Do_This
tag="sql postgresql databases"
- `text` is equivalent to `varchar`. Just use `text`.
- Use `numeric` instead of `money`.

IOWait, hung IO tasks, "task foo:3450 blocked for more than 120 seconds", hung_task_timeout_secs
================================================================================
tag="kernel linux io os syscall error troubleshooting filesystem virtual-memory"
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

RCU (read-copy-update)
================================================================================
tag="rcu data-structure adt programming kernel linux compsci os operating-system"
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

What does an idle CPU do?
================================================================================
https://manybutfinite.com/post/what-does-an-idle-cpu-do/
tag="programming kernel linux compsci c os operating-system"
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

Disable Transparent Hugepages
================================================================================
https://blog.nelhage.com/post/transparent-hugepages/
https://alexandrnikitin.github.io/blog/transparent-hugepages-measuring-the-performance-impact/
tag="programming sysadmin devops kernel linux performance memory"
> When transparent hugepage support works well, it can garner up to about a 10% performance improvement on certain benchmarks. However, it also comes with at least two serious failure modes:
> Memory Leaks
> THP attempts to create 2MB mappings. However, it’s overly greedy in doing so, and too unwilling to break them back up if necessary. If an application maps a large range but only touches the first few bytes, it would traditionally consume only a single 4KB page of physical memory. With THP enabled, khugepaged can come and extend that 4KB page into a 2MB page, effectively bloating memory usage by 512x (An example reproducer on this bug report actually demonstrates the 512x worst case!).
> Go’s GC had to include an explicit workaround for it, and Digital Ocean documented their woes with Redis, THP, and the jemalloc allocator.
> Pauses and CPU usage
> In steady-state usage by applications with fairly static memory allocation, the work done by khugepaged is minimal. However, on certain workloads that involve aggressive memory remapping or short-lived processes, khugepaged can end up doing huge amounts of work to merge and/or split memory regions, which ends up being entirely short-lived and useless. This manifests as excessive CPU usage, and can also manifest as long pauses, as the kernel is forced to break up a 2MB page back into 4KB pages before performing what would otherwise have been a fast operation on a single page.
> Several applications have seen 30% performance degradations or worse with THP enabled, for these reasons.

Andy Chu comment on Python slow-startup, distribution/delivery, self-contained apps
================================================================================
https://news.ycombinator.com/item?id=16979544
tag="performance programming python init bootstrap"

Mike Pall comment on "Why Python, Ruby and JS are slow"
================================================================================
https://www.reddit.com/r/programming/comments/19gv4c/why_python_ruby_and_js_are_slow/c8o29zn/?context=3
tag="performance jit dynamic-pl pl programming python"

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

How Netflix Reinvented HR
================================================================================
https://hbr.org/2014/01/how-netflix-reinvented-hr
tag="work culture hiring"
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

The USE Method 
================================================================================
  href="http://www.brendangregg.com/usemethod.html" 
  
  tag="performance troubleshooting debug distributed-systems checklist"
  time="2016-01-18T05:59:59Z" 

U.S. defense lawyers to seek access to DEA hidden intelligence evidence | Reuters
================================================================================
  Internal training documents reported by Reuters this week instruct agents not to reveal information they get from a unit of the U.S. Drug Enforcement Administration, but instead to recreate the same information by other means. A similar set of instructions was included in an IRS manual in 2005 and 2006, Reuters reported. / The DEA unit, known as the Special Operations Division, or SOD, receives intelligence from intercepts, wiretaps, informants and phone records, and funnels tips to other law enforcement agencies, the documents said. Some but not all of the information is classified.
  href="http://www.reuters.com/article/us-dea-irs-idUSBRE9761AZ20130808"
    tag="police-state government politics"
  time="2016-01-09T19:11:55Z" 

SWAT-Team Nation - The New Yorker
================================================================================
  civil-forfeiture laws, which allow police to confiscate and keep property that is allegedly tied to criminal activity, are often enforced at gunpoint against, say, nonviolent partygoers. / 80,000 combat-style home raids per year. / U.S. Department of Defense program ... has redistributed billions of dollars‚Äô worth of surplus military gear to local police forces
  href="http://www.newyorker.com/news/daily-comment/swat-team-nation"
    tag="police-state politics government"
  time="2016-01-09T19:01:29Z" 

CONSENSUS: BRIDGING THEORY AND PRACTICE
================================================================================
  href="https://ramcloud.stanford.edu/~ongaro/thesis.pdf"
  tag="raft cap distributed-systems compsci todo papers"
  time="2016-01-07T22:10:02Z" 

Things we (finally) know about network queues
================================================================================
https://apenwarr.ca/log/20170814
tag="queue-theory network compsci"

The UNIX Time-Sharing System / Dennis M. Ritchie and Ken Thompson
================================================================================
https://people.eecs.berkeley.edu/~brewer/cs262/unix.pdf
tag="operating-system unix compsci papers"
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

The web of names, hashes and UUIDs
================================================================================
  Joe Armstrong's ‟reversing entropy plan”. As soon as we name something there is an implied context - take away the context, or use the name in a different context and we are lost.
  href="http://joearms.github.io/2015/03/12/The_web_of_names.html"

  tag="compsci content-addressable distributed-systems uuid"
  time="2015-12-30T03:39:36Z" 

PHP Sadness
================================================================================
http://phpsadness.com/
tag="programming"

Here are a few random things that come to mind as often missed by users
================================================================================
  - Multimaps.index() and Maps.uniqueIndex() - That all ImmutableCollections have deterministic iteration order and a no-cost asList() view - That there's very little reason to do integer arithmetic on the values of a map yourself -- if Multiset doesn't fit the bill, AtomicLongMap probably does
  href="https://www.reddit.com/r/java/comments/1y9e6t/ama_were_the_google_team_behind_guava_dagger/cfjfskk"
    tag="guava google programming"
  time="2015-12-29T21:33:40Z" 

TensorFlow
================================================================================
http://googleresearch.blogspot.com/2015/12/how-to-classify-images-with-tensorflow.html

> At Jetpac my colleagues and I built mustache detectors to recognize bars full of hipsters, blue sky detectors to find pubs with beer gardens, and dog detectors to spot canine-friendly cafes. At first, we used the traditional computer vision approaches that I'd used my whole career, writing a big ball of custom logic to laboriously recognize one object at a time. For example, to spot sky I'd first run a color detection filter over the whole image looking for shades of blue, and then look at the upper third. If it was mostly blue, and the lower portion of the image wasn't, then I'd classify that as probably a photo of the outdoors.
> I'd been an engineer working on vision problems since the late 90's, and the sad truth was that unless you had a research team and plenty of time behind you, this sort of hand-tailored hack was the only way to get usable results. As you can imagine, the results were far from perfect and each detector I wrote was a custom job, and didn't help me with the next thing I needed to recognize. This probably seems laughable to anybody who didn't work in computer vision in the recent past! It's such a primitive way of solving the problem, it sounds like it should have been superseded long ago.
> That's why I was so excited when I started to play around with deep learning. It became clear as I tried them out that the latest approaches using convolutional neural networks were producing far better results than my hand-tuned code on similar problems. Not only that, the process of training a detector for a new class of object was much easier. I didn't have to think about what features to detect, I'd just supply a network with new training examples and it would take it from there.

tag="deep-learning machine-learning random-forests compsci"

The Bitter Lesson, Rich Sutton, 2019
================================================================================
http://www.incompleteideas.net/IncIdeas/BitterLesson.html
tag="deep-learning machine-learning compsci engineering moores-law scale"
The bitter lesson:
> 1) AI researchers have often tried to build knowledge into their agents,
> 2) this always helps in the short term, and is personally satisfying to the researcher, but
> 3) in the long run it plateaus and even inhibits further progress, and
> 4) breakthrough progress eventually arrives by an opposing approach based on scaling computation by search and learning. The eventual success is tinged with bitterness, and often incompletely digested, because it is success over a favored, human-centric approach.
Takeaway:
> The great power of general purpose methods, of methods that continue to scale
> with increased computation.
> 2 methods that scale arbitrarily in this way: SEARCH and LEARNING.


Random forests
================================================================================
  http://research.microsoft.com/pubs/155552/decisionForests_MSR_TR_2011_114.pdf Random forests &quot;can handle classification, regression, semi-supervised learning, manifold learning, and density estimation. The paper gives an introduction to each of these topics as well as a unified framework to implement each algorithm.&quot; &quot;The paper is well-written and easy to understand for someone without a deep background in machine learning.&quot;
  href="https://news.ycombinator.com/item?id=4201374" 
   tag="todo machine-learning random-forests compsci"
  time="2015-10-27T04:36:13Z" 

N.S.A. Foils Basic Safeguards of Privacy on Web
================================================================================
  The agency has circumvented or cracked much of the encryption, or digital scrambling, that guards global commerce and banking systems, protects sensitive data like trade secrets and medical records, and automatically secures the e-mails, Web searches, Internet chats and phone calls of Americans and others around the world, the documents show. ... The N.S.A.‚Äôs Commercial Solutions Center, for instance, invites the makers of encryption technologies to present their products to the agency with the goal of improving American cybersecurity. But a top-secret N.S.A. document suggests that the agency‚Äôs hacking division uses that same program to develop and ‚Äúleverage sensitive, cooperative relationships with specific industry partners‚Äù to insert vulnerabilities into Internet security products. ... But by 2006, an N.S.A. document notes, the agency had broken into communications for three foreign airlines, one travel reservation system.
  href="http://www.nytimes.com/2013/09/06/us/nsa-foils-much-internet-encryption.html?_r=0"
   
  tag="police-state surveillance usgov government state security encryption"
  time="2015-09-23T18:37:42Z" 

U.S. directs agents to cover up program used to investigate Americans
================================================================================
  [&quot;SOD tips&quot; or &quot;SOD tip-offs&quot;, where intelligence-community information is &quot;laundered&quot; through a source that provides a tip to investigators] Law enforcement agents have been directed to conceal how such investigations truly begin - not only from defense lawyers but also sometimes from prosecutors and judges. federal agents are trained to &quot;recreate&quot; the investigative trail to effectively cover up where the information originated, ... If defendants don't know how an investigation began, they cannot know to ask to review potential sources of exculpatory evidence - information that could reveal entrapment, mistakes or biased witnesses.
  href="http://www.reuters.com/article/2013/08/05/us-dea-sod-idUSBRE97409R20130805"
   
  tag="police-state coverup government dea usgov"
  time="2015-09-23T18:05:02Z" 

This method is so acceptable, the DEA won't even release its name | Muckrock
================================================================================
  href="https://www.muckrock.com/news/archives/2014/feb/04/method-so-acceptable-dea-cant-even-tell-you-its-na/"
   
  tag="police-state politics government usgov dea security snowden"
  time="2015-09-23T18:02:11Z" 

GeekDesk¬Æ Adjustable Height Desks - Home
================================================================================
  href="http://www.geekdesk.com/"  
  tag="ergonomics health rsi work standingdesk desk"
  time="2015-09-23T15:25:52Z" 

www.versatables.com 
================================================================================
  href="http://www.versatables.com/"  
  tag="ergonomics health rsi work standingdesk desk"
  time="2015-09-23T15:25:18Z" 

What forces layout/reflow. The comprehensive list.
================================================================================
  href="https://gist.github.com/paulirish/5d52fb081b3570c81e3a"
   
  tag="web dom chrome layout reflow programming"
  time="2015-09-19T18:19:43Z" 

Kythe steve yegge grok
================================================================================
  href="http://www.kythe.io/"  
  tag="programming tools" time="2015-09-17T18:18:49Z" 

IPFS | The Permanent Web 
================================================================================
   href="https://ipfs.io/"
    tag="distributed-systems web filesystem"
  time="2015-09-09T05:32:33Z" 

Stanford Encyclopedia of Philosophy
================================================================================
  href="http://plato.stanford.edu/"  
  tag="philosophy reference academia"
  time="2015-08-04T23:38:31Z" 

TI Launchpads: $10 microcontrollers
================================================================================
  href="http://www.ti.com/ww/en/launchpad/launchpads.html"
   
  tag="uc electronics compsci circuits engineering"
  time="2015-06-15T14:30:37Z" 

Think Distributed: A Distributed Systems Podcast
================================================================================
  href="http://thinkdistributed.io/"  
  tag="distributed-systems podcast" time="2015-03-30T23:21:42Z" 

After seven years, exactly one person gets off the gov‚Äôt no-fly list | Ars Technica
================================================================================
  the government's official policy is to refuse to confirm or deny watchlist status. Nor is there any meaningful way to contest one's designation as a potential terrorist and ensure that the US government... removes or corrects inadequate records.
  href="http://arstechnica.com/tech-policy/2014/03/after-seven-years-exactly-one-person-gets-off-the-govt-no-fly-list/"
    tag="police-state government-failure"
  time="2015-03-26T04:45:02Z" 

Why not add an option for that?
================================================================================
http://neugierig.org/software/blog/2018/07/options.html
tag="programming softwareengineering design ux ui options"

Google's internal code review guidelines
================================================================================
https://news.ycombinator.com/item?id=20891738
tag="programming softwareengineering teams code-review google"
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

This Week In Startups | This Week In Startups
================================================================================
  href="http://thisweekinstartups.com/"  
  tag="podcast" time="2015-03-21T14:34:47Z" 

Podcast ‚Äì The Tim Ferriss Show 
================================================================================
  href="http://fourhourworkweek.com/podcast/" 
   tag="podcast" time="2015-03-21T14:32:48Z" 

Rich Hickey Q&amp;A, by Michael Fogus
================================================================================
  OO can seriously thwart reuse. ... the use of objects to represent simple informational data [generates] per-piece-of-information micro-languages, i.e. the class methods, versus far more powerful, declarative, and generic methods like relational algebra. / the great challenge for type systems in practical use is getting them to be more expressive without a corresponding‚Äîor worse‚Äîincrease in complexity. / The problems [with inheritance/hierarchy] come about when you attach something to the hierarchy. ... a method for partial overriding of the inheritance and thus, qualification of the isa implication. The implication is broken and your ability to reason about things turns to mud.
  href="http://codequarterly.com/2011/rich-hickey/" 
  
  tag="clojure richhickey programming type-systems compsci"
  time="2015-03-05T00:45:56Z" 

New research indicates ‘Unicorns’ are overvalued
================================================================================
https://news.ycombinator.com/item?id=14467869
tag="startup equity stock options"

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

Options vs. cash
================================================================================
https://danluu.com/startup-options/
https://news.ycombinator.com/item?id=14505378
tag="startup equity stock options"

> _Venture Deals_ by Brad Feld is a great read to understand different investment terms

What I Wish I'd Known About Equity Before Joining A Unicorn
================================================================================
https://gist.github.com/yossorion/4965df74fd6da6cdc280ec57e83a202d
tag="startup equity stock options"

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

Frequency illusion / Baader-Meinhof Phenomenon
================================================================================
  href="http://en.wikipedia.org/wiki/List_of_cognitive_biases#Frequency_illusion"
    tag="concepts psychology mental-model"
  time="2015-02-13T19:03:21Z" 


Habitat fragmentation
================================================================================
https://en.wikipedia.org/wiki/Habitat_fragmentation
Ecological thinning: https://en.wikipedia.org/wiki/Ecological_thinning
_Impact of forest paths upon adjacent vegetation_: S. Godefroid, N. Koedam, 2004
tag="concepts ecology mental-model"
.
> Edge effects alter the conditions of the outer areas of the fragment, greatly
> reducing the amount of true forest interior habitat.
>
> A large number of small forest "islands" typically cannot support the same
> biodiversity that a single contiguous forest would hold, even if their
> combined area is much greater than the single forest.


Apdex
================================================================================
  for a threshold of t: Apdex_t = (Satisfied Count + Tolerating Count / 2) / Total Samples // http://mvolo.com/why-average-latency-is-a-terrible-way-to-track-website-performance-and-how-to-fix-it/
  href="http://en.wikipedia.org/wiki/Apdex" 
  
  tag="monitoring performance apdex metrics measurement"
  time="2015-02-11T21:31:36Z" 

Introducing Project Mentat, a flexible embedded knowledge store
================================================================================
https://medium.com/project-tofino/introducing-datomish-a-flexible-embedded-knowledge-store-1d7976bff344
tag="system-design software-engineering scalability performance database"
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


FreeNAS Community Hardware Recommendations Guide
================================================================================
https://forums.freenas.org/index.php?resources/hardware-recommendations-guide.12/
tag="performance sysadmin devops hardware system"

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

Effective Engineer (AKA: Leverage)
================================================================================
http://www.effectiveengineer.com/
https://gist.github.com/rondy/af1dee1d28c02e9a225ae55da2674a6f
https://henrikwarne.com/2017/01/15/book-review-the-effective-engineer/
tag="engineering leverage mental-model"

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


How to Get Rich (without getting lucky): @naval
================================================================================
https://twitter.com/naval/status/1002103360646823936
https://pbs.twimg.com/media/DesoRB1V4AI6_3-.jpg:large
tag="economics business systems leverage mental-model"

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


Mental Models: The Best Way to Make Intelligent Decisions (109 Models Explained)
================================================================================
https://fs.blog/mental-models/
tag="concepts systems mental-model"

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

Pomodoro technique
================================================================================
http://baomee.info/pdf/technique/1.pdf
tag="work productivity habits focus concentration time-management"
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

Ambarella | Embedded Computer Vision SoCs
================================================================================
https://www.ambarella.com/
tag="machine-learning computer-vision software programming embedded soc"

tensorflow/cleverhans
================================================================================
https://github.com/tensorflow/cleverhans
tag="machine-learning software programming software-engineering"
An adversarial example library for constructing attacks, building defenses, and benchmarking both

osquery
================================================================================
https://github.com/facebook/osquery/
https://osquery.io/
tag="monitoring metrics sysadmin devops hardware system query sql facebook"
Relational (SQL) data-model for OS/system info.

netdata
================================================================================
https://github.com/firehol/netdata
tag="monitoring dashboard performance metrics sysadmin devops hardware"
server stats/dashboard

The log/event processing pipeline you can't have
================================================================================
https://apenwarr.ca/log/20190216
tag="log monitoring performance metrics sysadmin devops"
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

A Guide to the Deceptions, Misinformation, and Word Games Officials Use to Mislead the Public About NSA Surveillance | Electronic Frontier Foundation
================================================================================
  When government officials can‚Äôt directly answer a question with a secret definition, officials will often answer a different question than they were asked. For example, if asked, ‚Äúcan you read Americans‚Äô email without a warrant,‚Äù officials will answer: ‚Äúwe cannot target Americans‚Äô email without a warrant.‚Äù / Bush administration‚Äôs strategy for the ‚ÄúTerrorist Surveillance Program‚Äù: The term ‚ÄúTSP‚Äù ended up being a meaningless label, created by administration officials after the much larger warrantless surveillance program was exposed by the New York Times in 2005. They used it to give the misleading impression that the NSA‚Äôs spying program was narrow and aimed only at intercepting the communications of terrorists. In fact, the larger program affected all Americans.
  href="https://www.eff.org/deeplinks/2013/08/guide-deceptions-word-games-obfuscations-officials-use-mislead-public-about-nsa"
    tag="nsa surveillance eff police-state"
  time="2015-02-11T21:09:22Z" 

New Intel Doc: Do Not Be 'Led Astray' By 'Commonly Understood Definitions' - The Intercept
================================================================================
  Defense Intelligence Agency document that instructs analysts to use words that do not mean what they appear to mean. / one several documents about Executive Order 12333 the ACLU obtained / So, we see that ‚Äúcollection of information‚Äù for DoD 5240.1-R purposes is more than ‚Äúgathering‚Äù ‚Äì it could be described as ‚Äúgathering, plus ‚Ä¶ ‚Äú. For the purposes of DoD 5240.1-R, ‚Äúcollection‚Äù is officially gathering or receiving information, plus an affirmative act in the direction of use or retention of that information.
  href="https://firstlook.org/theintercept/2014/09/29/new-intel-doc-led-astray-commonly-understood-definitions"
    tag="nsa police-state politics"
  time="2015-02-11T21:00:18Z" 

VICTORY: Judge Releases Information about Police Use of Stingray Cell Phone Trackers | American Civil Liberties Union
================================================================================
  Stingrays ‚Äúemulate a cellphone tower‚Äù and ‚Äúforce‚Äù cell phones to register their location and identifying information with the stingray instead of with real cell towers in the area. / Stingrays force cell phones in range to transmit information back ‚Äúat full signal, consuming battery faster.‚Äù / When in use, stingrays are ‚Äúevaluating all the [cell phone] handsets in the area‚Äù / between spring of 2007 and August of 2010, the Tallahassee Police had used stingrays approximately ‚Äú200 or more times.‚Äù
  href="https://www.aclu.org/blog/national-security-technology-and-liberty/victory-judge-releases-information-about-police-use"
    tag="police-state government privacy"
  time="2015-01-28T04:03:34Z" 

IRS sends warning letters to more than 10k cryptocurrency holders
================================================================================
https://news.ycombinator.com/item?id=20536951
tag="police-state government taxes legal"
    https://www.irs.gov/newsroom/irs-has-begun-sending-letters-to-virtual-currency-owners-advising-them-to-pay-back-taxes-file-amended-returns-part-of-agencys-larger-efforts
    https://www.reddit.com/r/Bitcoin/comments/chupoe/irs_we_have_information_that_you_have_or_had_one/
    https://www.irsmind.com/audits/irs-begins-targeting-taxpayers-who-misreport-virtual-currency-transactions/
    > Letter 6174:   This is a soft notice informing the taxpayer that there is a likelihood that they did not report their virtual currency transactions. The notice asks them to check their return and, if necessary, file an amended return to correct the misreporting. The taxpayer is not required to respond to the notice and the IRS intends not to follow up on these notices. In short, this is information only to the taxpayer and education on how they comply.
    > Letter 6174-A: This is a “not so soft notice” from the IRS. As in Letter 6174, this letter tells the taxpayer that there is potential misreporting of virtual currency transactions. However, this notices states that the IRS may follow-up with future enforcement action. Again, no response is required if the taxpayer believes that they are in compliance. Taxpayers who receive this notice should be aware that they have been put on “notice” that they have been identified as a noncompliant taxpayer for potential future enforcement.
    > Letter 6173:   Requires a response. This notice requests a response from the taxpayer about the alleged noncompliance. The letter provides instructions on responding to the IRS. The IRS intends to follow up on these responses to determine if the taxpayer is in compliance.

Don’t Put Your Work Email on Your Personal Phone
================================================================================
https://news.ycombinator.com/item?id=20514833
tag="corporate workplace legal security"
Using *any* personal device for work makes *all* of your personal devices
subject to seizure if your employer is under investigation.

Noisebridge 
================================================================================
  href="https://www.noisebridge.net/"  
  tag="sanfrancisco travel hackerspace"
  time="2014-12-18T19:36:59Z" 

wat2do | A map of rad things to do today
================================================================================
  href="http://www.sfwat2do.com/"  
  tag="travel tools sanfrancisco" time="2014-12-18T19:36:03Z" 

How I Rewired My Brain to Become Fluent in Math - Issue 17: Big Bangs - Nautilus
================================================================================
  students can often grasp essentials of an important idea, but this understanding can quickly slip away without consolidation through practice and repetition. / well-ingrained chunks of expertise through practice and repetition / Understanding doesn‚Äôt build fluency; instead, fluency builds understanding. / understanding, after all, is facile, and can easily slip away.
  href="http://nautil.us/issue/17/big-bangs/how-i-rewired-my-brain-to-become-fluent-in-math-rd"
    tag="learning psychology math pedagogy"
  time="2014-12-17T00:55:04Z" 

Michael Pettis' CHINA FINANCIAL MARKETS
================================================================================
https://blog.mpettis.com/
tag="blog economics china" time="2014-12-02T01:05:58Z" 

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


UNQUALIFIED RESERVATIONS: The future of search
================================================================================
https://unqualified-reservations.blogspot.de/2010/03/future-of-search.html
tag="urbit p2p search future distributed-systems"

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

Urbit
================================================================================
https://urbit.org/blog/stable-arvo/
tag="urbit p2p versioning"
> "Continuity" or "permanence" is arguably Urbit's killer feature: you start
> your ship, it just works, forever.
.
> With the recent 0.9.0 release we’ve gotten to the point where we can make
> almost all our upgrades over the air. Even the language is now upgradeable
> over the wire.

Urbit explanation
================================================================================
https://news.ycombinator.com/item?id=21674120
tag="urbit p2p"
> The system being a top to bottom rewrite of the stack in such a way so as to sidestep the client/server relationship entirely. A lot of services rely upon positioning themselves as the server, as the big computer you have timeshared access to, and they monetise your usage. For things like photo storage, or basic communication, or permissioned access to your files, this is pointless. Any computer could do it, but the internet is itself based upon asking a server for something and getting it. And running a server sucks.
> Any other peer to peer solution is partial, and therefore not able to compete with the internet as is. Urbit basically plans around an identity system that prevents spam and abuse; a hierarchical packet routing structure for those identities that doubles as a de facto governance model (due to having a vested interest in the network, the higher up you go); a kernel designed to freeze, and its entire OS on top a series of event logs that mark down computations and new states; a functional language for this "internet where every computer is a database", and the encrypted networking protocol that uses UDP while still ensuring packets always find you.
> So if you wanted to, say, have a group of people set as a peer list that others can subscribe to or join, or build or use applications that lets that peer list join chats or see a set of files based upon some arbitrary marker (like giving you $5/mo?) ... you don't need a million services to spread the load, one task per service, each person joining each service. You can just use your own computer. It's a personal server platform for a peer to peer internet. It's an internet designed to resist bad actors, and to resist AOL, to resist Facebook and Google

Urbit: functional programming from scratch
================================================================================
http://moronlab.blogspot.co.uk/2010/01/urbit-functional-programming-from.html
tag="urbit p2p nock functional-programming"

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

Hoon and You - An FP Perspective
================================================================================
https://github.com/famousj/hoon-lc2018/blob/master/hoon-talk.md
tag="urbit p2p hoon functional-programming fp programming"

Why Hoon? - Ted Blackman ~rovnys-ricfer
================================================================================
https://urbit.org/blog/why-hoon/
tag="urbit p2p hoon functional-programming fp os system"
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

Ford Fusion
================================================================================
https://urbit.org/blog/ford-fusion/
tag="urbit p2p hoon functional-programming fp os system"
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

rote: flashcard app for Urbit Landscape
================================================================================
https://github.com/lukechampine/rote
tag="urbit p2p hoon functional-programming fp app"
- "immaculate backend code-style and documentation"
- also functions as a full "Hoon app" walkthrough
- Luke also kept a Notebook documenting his experience at ~watter-parter/hackathon.

A Founder's Farewell
================================================================================
https://urbit.org/posts/essays/a-founders-farewell/
tag="urbit p2p distributed-systems software-engineering programming compsci systems network interop"
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


urbit features
================================================================================
https://news.ycombinator.com/item?id=15300676
tag="urbit p2p distributed-systems systems network"
- All events are transactions, down to the VM level. There's no concept of an event that left garbage around because power was cut or the machine was rebooted. You can always crash an event, making it as if it never happened.
- Single-level store. Never worry about ORM because your in-memory state never goes away (because all events are transactions).
- Persistent connections with exactly-once messaging. Disconnection is just seen as long latency.
- Strict, purely functional language with a strong type system but no Hindley-Milner (so you don't need category theory).
- Sane indentation for a functional language, known as "backstep".
- The file system is a typed revision control system, which allows intelligent diffs on types other than plain text.


PGP and You 
================================================================================
  href="http://robots.thoughtbot.com/pgp-and-you" 
   tag="gpg todo tutorial reference"
  time="2014-11-04T22:28:46Z" 

Neural Networks, Manifolds, and Topology -- colah's blog
================================================================================
  href="http://colah.github.io/posts/2014-03-NN-Manifolds-Topology/"
    tag="machine-learning todo"
  time="2014-10-14T22:17:27Z" 

Visualizing Algorithms 
================================================================================
  href="http://bost.ocks.org/mike/algorithms/" 
   tag="todo algorithms compsci"
  time="2014-10-14T22:16:53Z" 

Hyperpolyglot
================================================================================
  similar to learnxinyminutes.com
  href="http://hyperpolyglot.org/"  
  tag="programming reference" time="2014-10-13T22:53:20Z" 

Markov Chains visualization
================================================================================
  The most important conceptual point regarding Markov chains is that they are memory-less: future states depend only on the current state and not a previous history of which states have been visited. This property makes them powerful and simple to analyze. ... But the movement of a person trying to exit a museum is not well modeled by a Markov chain because he will remember which hallways lead to dead ends and be less likely to travel down them again.
  href="http://setosa.io/blog/2014/07/26/markov-chains/index.html"
    tag="machine-learning statistics"
  time="2014-09-10T21:45:15Z" 

The Little Book of Semaphores [pdf]
================================================================================
http://www.greenteapress.com/semaphores/downey08semaphores.pdf
https://news.ycombinator.com/item?id=11277896
tag="todo distributed-systems programming"

Readings in Databases
================================================================================
  The Five-Minute Rule Ten Years Later / http://www.cs.berkeley.edu/~rxin/db-papers/5-min-rule.pdf /Paxos Made Simple / http://www.cs.berkeley.edu/~rxin/db-papers/Paxos.pdf / http://www.cs.berkeley.edu/~rxin/db-papers/OCC-Optimistic-Concurrency-Control.pdf / On Optimistic Methods for Concurrency Control / http://www.cs.berkeley.edu/~rxin/db-papers/CAP.pdf / Eric Brewer's writeup on CAP in retrospective, explaining &quot;'2 of 3' formulation was always misleading because it tended to oversimplify the tensions among properties.
  href="http://rxin.github.io/db-readings/" 
  
  tag="todo distributed-systems programming database cap concurrency"
  time="2014-08-29T02:21:56Z" 

Project Zero: The poisoned NUL byte, 2014 edition
================================================================================
  An odd malloc() size will always result in an off-by-one off the end being harmless, due to malloc() minimum alignment being sizeof(void*). / Memory leaks in setuid binaries are surprisingly dangerous because they can provide a heap spray primitive. / / http://seclists.org/bugtraq/1998/Oct/109 / With the stack having shifted down 0xec bytes, it picks up the return address from the local buffer containing the exploit code.
  href="http://googleprojectzero.blogspot.com/2014/08/the-poisoned-nul-byte-2014-edition.html"
    tag="security programming infosec c"
  time="2014-08-27T22:24:33Z" 

Thousand-robot swarm self-assembles into arbitrary shapes | Robohub
================================================================================
  decentralised, scalable, self-organizing autonomous robots. / No GPS-like system was available for them to know their location in the environment. Instead, robots had to form a virtual coordinate system using communication with, and measured distances to, neighbours. / Four specially programmed seed robots are then added to the edge of the group, marking the position and orientation of the shape. These seed robots emit a message that propagates to each robot in the blob and allows them to know how ‚Äúfar‚Äù away from the seed they are and their relative coordinates. Robots on the edge of the blob then follow the edge until they reach the desired location in the shape that is growing in successive layers from the seed. / [paper: justin.werfel@wyss.harvard.edu http://www.sciencemag.org/content/343/6172/754 ] https://news.ycombinator.com/item?id=8178978
  href="http://robohub.org/thousand-robot-swarm-self-assembles-into-arbitrary-shapes/"
    tag="cellular-automata"
  time="2014-08-14T19:52:45Z" 

Twenty Questions for Donald Knuth
================================================================================
  The supposedly &quot;most efficient&quot; algorithms [...] are too complicated to be trustworthy, even if I had a year to implement one of them. / The present state of research in algorithm design misunderstands the true nature of efficiency. / Although I was expecting your method to be the winner, because it examines much of the data only half as often as the others, it actually came out two to three times worse than Kruskal's venerable method. Part of the reason was poor cache interaction, but the main cause was a large constant factor hidden by O notation.
  href="http://www.informit.com/articles/article.aspx?p=2213858"
    tag="compsci knuth"
  time="2014-07-18T19:30:37Z" 

The Operating System: Should there be one? Stephen Kell
================================================================================
https://www.cl.cam.ac.uk/~srk31/research/papers/kell13operating.pdf
tag="smalltalk plan9 compsci os c programming"

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


"Less is exponentially more", Rob Pike
================================================================================
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


Hello World: USENIX Winter 1993 paper by Rob Pike and Ken Thompson on UTF-8 under Plan 9
================================================================================
  Unicode defines an adequate character set but an unreasonable representation. / UTF-1 advantages: It is a byte encoding and is therefore byte-order independent. ASCII control characters appear in the byte stream only as themselves, never as an element of a sequence encoding another character, so newline bytes separate lines of UTF text. / UTF-1 major disadvantage: not self-synchronizing =&gt; cannot find the character boundaries in a UTF string without reading from the beginning. / &quot;The actual encoding is relatively unimportant to the software; the adoption of large characters and a byte-stream encoding per se are much deeper issues.&quot;
  href="http://www.cl.cam.ac.uk/~mgk25/ucs/UTF-8-Plan9-paper.pdf"
   
  tag="unicode plan9 compsci strings os c programming"
  time="2014-07-15T22:23:52Z" 

What Every Programmer Absolutely, Positively Needs to Know About Encodings and Character Sets to Work With Text
================================================================================
  Unicode is not an encoding. Unicode defines a table of code points for characters. The character ·∏Ä has the Unicode code point U+1E00. UTF-32 is an encoding that encodes all Unicode code points using 32 bits: 4 bytes per character. UTF-16 and UTF-8 are variable-length encodings. &quot;Unicode support&quot; in a programming language or OS is not necessary as long as the runtime treats a string input as a bit stream and does not attempt to manipulate it as a specific encoding. You only need to be careful when _manipulating_ strings (slicing, trimming, counting), i.e. operations that happen on a _character_ level rather than a _byte_ level.
  href="http://kunststube.net/encoding/"  
  tag="unicode programming strings" time="2014-07-15T00:29:26Z" 

How SQL Server Generates the Query Plan
================================================================================
  SQL Server not any perform flow analysis, so local variables in a sproc can kill the query plan. / SET ARITHABORT ON doesn't really fix performance issues, it just appears to temporarily because it is a cache key, and setting it changes the query so that a new query plan is generated. So the next execution will appear fast because it is optimized, but then later executions (using _different_ parameters) will be slow again, because they are using the query plan that was cached for the previous parameter values. The _real_ problem is related to parameter sniffing.
  href="http://www.sommarskog.se/query-plan-mysteries.html#plangenerate"
    tag="sqlserver sql database rdbms"
  time="2014-07-01T15:30:09Z" 

Out of Prohibition's Reach: How Technology Cures Toxic Policy
================================================================================
  The shutdown also motivated improvements as new marketplaces started offering features like faster services, private messaging that requires encryption, and bitcoin escrow services that eliminate the possibility of the marketplace scamming users. / In terms of scam prevention, most marketplaces actively work to make scamming unattractive. Anyone that wants to sell as a vendor is required to post a bond until they reach a certain amount of sales and positive reviews. / Decentralized marketplaces like the experimental ‚ÄúDarkMarket‚Äù platform, recently renamed ‚ÄúOpenBazaar‚Äù, are the next step towards the cure. DarkMarket is peer-to-peer which means that every user serves up their own buyer or seller page, as opposed to that page being served up by a server like on traditional websites or current anonymous marketplaces.
  href="http://stanfordreview.org/article/out-of-prohibitions-reach-how-technology-cures-toxic-policy/"
   
  tag="libertarianism free-market economics"
  time="2014-06-07T19:16:44Z" 

What happens when patients find out how good their doctors are? (2004)
================================================================================
https://news.ycombinator.com/item?id=15840525
tag="science medicine health data measurement metrics quantification"
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

cancer
================================================================================
  Cancer is a disease that combines the trickiest parts of aging with the trickiest parts of infectious disease. Cell replication ... several trillions of times per day ... essentially copying 1 billion TB of data while detecting and fixing every error. Everybody will get cancer ... then you have a cell that your immune system has carefully trained for decades not to engage, invading and hogging every resource it can, with mutations that allow it to adapt to selective pressures, including drugs. Essentially, it's an infectious parasite, except it looks 99% like your own cells to your immune system, and is already perfectly suited to your metabolism. / From an evolutionary standpoint, no species would ever naturally develop perfect DNA replication because it would halt diversification. / [Imagine a billion nanobots...] You've basically described the immune system! Trillions of cells, thousands of genes controlling each one, hypermutations creating billions of different antibodies.
  href="https://news.ycombinator.com/item?id=7787688" 
   tag="cancer science medicine nanotech health"
  time="2014-06-07T18:36:52Z" 

Uncleftish Beholding
================================================================================
https://en.wikipedia.org/wiki/Uncleftish_Beholding
tag="concepts mental-model language"
written using almost exclusively words of Germanic origin
The title Uncleftish beholding calques "atomic theory".
Around, from Old French reond (Modern French rond), has completely displaced Old English ymbe (cognate to German um), leaving no native English word for this concept.

Noisy-channel coding theorem
================================================================================
https://en.wikipedia.org/wiki/Noisy-channel_coding_theorem
tag="concepts mental-model compsci information-theory encoding"
Noisy-channel coding theorem: For any given degree of noise in a communication channel, it is possible to communicate discrete data (digital information) nearly error-free up to a computable maximum rate.
Shannon limit = maximum information-transfer rate of the channel, for a particular noise level.

Mutatis mutandis
================================================================================
https://en.m.wikipedia.org/wiki/Mutatis_mutandis
tag="concepts mental-model"
Medieval Latin phrase meaning "the necessary changes having been made".
    1. collect underpants
    2. mutatis mutandis
    3. profit

System dynamics
================================================================================
https://en.wikipedia.org/wiki/System_dynamics
https://www.anylogic.com/
tag="concepts model systems system-design stock-and-flow mental-model"
System dynamics (SD) is an approach to understanding the nonlinear behaviour of complex systems over time using stocks, flows, internal feedback loops, table functions and time delays.
- Teach "system-thinking" reflexes
- Analyze/compare assumptions and mental models
- Gain qualitative insight into the workings of a system or the consequences of a decision
- Recognize archetypes of dysfunctional systems in everyday practice

Pythagorean Cup (Greedy Cup)
================================================================================
  &quot;Hydrostatic pressure creates a siphon through the central column, causing the entire contents of the cup to be emptied through the hole at the bottom of the stem.&quot;
  href="http://en.wikipedia.org/wiki/Pythagorean_cup" 
   tag="concepts economics physics mental-model"
  time="2014-06-02T03:58:58Z" 

Gauss's Principle of Least Constraint
================================================================================
http://preetum.nakkiran.org/misc/gauss/
tag="concepts physics mental-model"
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

"Bitcoin's Academic Pedigree" Narayanan & Clark
================================================================================
http://queue.acm.org/detail.cfm?id=3136559
tag="bitcoin blockchain trust-network p2p cryptocurrency"
https://news.ycombinator.com/item?id=15135442
    "original Bitcoin codebase ... It's brilliant code. ... One of the earliest commits in the SVN repo contains 36 thousand lines of code. "Satoshi" (or this group of people) must have worked months or a year on this before putting it up on source control. The code also uses irc to find seed nodes, which is amusing. It just connects to #bitcoin and assumes that some of the people in the channel are running bitcoin nodes. That's a cool way around the "What if all the hardcoded seed nodes fail?" problem. I know it's probably a standard tactic, but bitcoin integrates so many standard tactics so well in addition to its academic work.
    "It's worth repeating: This is a C++ codebase. It listens to open ports on the public Internet. One single remote exploit and you lose all your money. The author basically threw code over the wall and the open source community where contributors come and go all the time took over. And one single remote exploit is all it takes. (This causation is perhaps less true today when it is more common to use encrypted or even hardware wallets, but before that everyone just used the standard wallet.) Yet none of this has happened. The odds of this seems vanishingly unlikely. Then there's the risk of consensus problems that would enable double spending, which is very difficult to test for. At the same time original Bitcoin was far from perfect. Someone wrote up a summary of important changes Hal Finney did which I can't seem to find. He pointed out a lot of problems which would have made Bitcoin not work at all which resulted in some early redesigns and the removal of many opcodes. Parts of Bitcoin also went nowhere, notably the marketplace, pay-to-IP and payment channels. The ideas live on as Openbazaar and Lightning but completely redesigned from the Satoshi origins. In so many ways it is an enigma."

Minimum Viable Block Chain - igvita.com
================================================================================
  https://news.ycombinator.com/item?id=7699332
  href="http://www.igvita.com/2014/05/05/minimum-viable-block-chain/"
   
  tag="bitcoin blockchain trust-network p2p cryptocurrency todo"
  time="2014-05-05T17:15:08Z" 

Call for a Temporary Moratorium on “The DAO”
================================================================================
  https://news.ycombinator.com/item?id=11788283
  https://docs.google.com/document/d/10kTyCmGPhvZy94F7VWyS-dQ4lsBacR2dUgGTtV98C40/mobilebasic
   
  tag="todo bitcoin cryptocurrency blockchain trust-network p2p DAO distributed-autonomous-organization"

NSA Spying Documents to be Released As Result of EFF Lawsuit
================================================================================
  href="https://www.eff.org/deeplinks/2013/09/hundreds-pages-nsa-spying-documents-be-released-result-eff-lawsuit"
   
  tag="nsa police-state surveillance paranoia"
  time="2014-03-13T00:12:50Z" 

How the NSA Plans to Infect 'Millions' of Computers with Malware - The Intercept
================================================================================
  https://news.ycombinator.com/item?id=7385390
  href="https://firstlook.org/theintercept/article/2014/03/12/nsa-plans-infect-millions-computers-malware/"
   
  tag="nsa police-state surveillance paranoia government infosec todo"
  time="2014-03-12T23:43:48Z" 

Build GIT - Learn GIT (P1) - Kushagra Gour- Creativity freak!
================================================================================
  href="http://kushagragour.in/blog/2014/01/build-git-learn-git/"
    tag="git tutorial todo programming"
  time="2014-01-20T17:41:13Z" 

Eclipse Java REPL / albertlatacz/java-repl ¬∑ GitHub
================================================================================
  FINALLY!!!!!!
  href="https://github.com/albertlatacz/java-repl" 
   tag="repl java eclipse"
  time="2013-12-09T18:43:22Z" 

Path dependence 
================================================================================
  href="http://en.wikipedia.org/wiki/Path_dependence" 
   tag="concepts economics compsci dynamics mental-model"
  time="2013-11-26T17:57:56Z" 

Advanced R programming 
================================================================================
  href="http://adv-r.had.co.nz/"  
  tag="r-lang programming statistics"
  time="2013-11-17T18:45:14Z" 

Kubernetes: The Surprisingly Affordable Platform for Personal Projects
================================================================================
https://www.doxsey.net/blog/kubernetes--the-surprisingly-affordable-platform-for-personal-projects
tag="kubernetes cloud orchestration sre paas dcos gce gcr google programming devops container virtualization sysadmin deployment"

Evaluating Bazel for building Firefox
================================================================================
https://news.ycombinator.com/item?id=21389206
tag="bazel build google programming devops dependencies"
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

Docker examples
================================================================================
https://github.com/jessfraz/dockerfiles/blob/master/irssi/Dockerfile
tag="docker programming devops container virtualization linux"

xperf Profiler 
================================================================================
  href="http://randomascii.wordpress.com/category/xperf/"
   
  tag="programming performance profiling windows"
  time="2013-11-08T22:33:39Z" 

PyParallel: How we removed the GIL and exploited all cores
================================================================================
  https://speakerdeck.com/trent/pyparallel-how-we-removed-the-gil-and-exploited-all-cores
  https://news.ycombinator.com/item?id=11866562
  tag="programming performance iocp io-completion-ports syscall windows"

I can't believe I'm praising Tcl
================================================================================
  href="http://www.yosefk.com/blog/i-cant-believe-im-praising-tcl.html"
    tag="programming tcl"
  time="2013-11-06T02:56:04Z" 

The Trouble With Types 
================================================================================
  href="http://www.infoq.com/presentations/data-types-issues"
   
  tag="type-systems functional-programming scala video martin-odersky"
  time="2013-11-05T22:11:11Z" 

Maybe Not - Rich Hickey
================================================================================
https://www.youtube.com/watch?v=YR5WdGrpoug
tag="type-systems functional-programming video rich-hickey concepts distributed-systems"

https://news.ycombinator.com/item?id=18565555
    > RDF got this surprisingly right. ... The idea of collections of
    > subject-predicate-object statements forming an isomorphism with graphs, and
    > sets of these statements form concrete "aggregates" plays extremely well with
    > the idea of unification through search.

Alfred North Whitehead: "reality as process-flows":
    https://en.wikipedia.org/wiki/Alfred_North_Whitehead#Whitehead's_conception_of_reality
Rich Hickey talk (2009) guided by Whitehead quotes:
    https://www.infoq.com/presentations/Are-We-There-Yet-Rich-Hickey


NSA infiltrates links to Yahoo, Google data centers worldwide, Snowden documents say
================================================================================
  National Security Agency secretly broke into the main communications links that connect Yahoo and Google data centers. ... the agency has positioned itself to collect at will from hundreds of millions of user accounts, many of them belonging to Americans ... project called MUSCULAR ... the NSA and the GCHQ are copying entire data flows across fiber-optic cables ... unusually aggressive use of NSA tradecraft against flagship American companies ... NSA documents about the effort refer directly to ‚Äúfull take,‚Äù ‚Äúbulk access‚Äù and ‚Äúhigh volume‚Äù ... Such large-scale collection of Internet content would be illegal in the United States, but the operations take place overseas. http://www.politico.com/story/2013/10/keith-alexander-nsa-report-google-yahoo-99103.html Gen. Keith Alexander, asked about it at a Bloomberg event, denied the accusations. &quot;I don't know what the report is,&quot; Alexander cautioned, adding the NSA does not &quot;have access to Google servers, Yahoo servers.&quot;
  href="http://www.washingtonpost.com/world/national-security/nsa-infiltrates-links-to-yahoo-google-data-centers-worldwide-snowden-documents-say/2013/10/30/e51d661e-4166-11e3-8b74-d89d714ca4dd_story.html"
   
  tag="police-state paranoia nsa surveillance privacy"
  time="2013-10-30T22:32:15Z" 

document.createDocumentFragment
================================================================================
  Since the document fragment is in memory and not part of the main DOM tree, appending children to it does not cause page reflow (computation of element's position and geometry).
  href="https://developer.mozilla.org/en-US/docs/Web/API/document.createDocumentFragment"
   
  tag="webdesign javascript programming performance"
  time="2013-10-15T19:18:16Z" 

ipinfo.io:
================================================================================
https://ipinfo.io/
IP address lookup, geolocation, API
ASN (Autonomous System Number) lookup, e.g.: https://ipinfo.io/AS32934

tag="tools web ip api internet"
2016-08-09 00:04:38

OpenRefine / fka Google Refine
================================================================================
  a tool for working with messy data, cleaning it up, transforming it from one format into another, extending it with web services, and linking it to databases like Freebase.
  href="https://github.com/OpenRefine"  
  tag="tools google data-mining statistics"
  time="2013-10-01T21:33:52Z" 

Herding Code 
================================================================================
  href="http://herdingcode.com/"  
  tag="podcast" time="2013-09-30T14:27:35Z" 

Software Engineering Radio | The Podcast for Professional Software Developers
================================================================================
  href="http://www.se-radio.net/"  
  tag="softwareengineering podcast" time="2013-09-30T14:27:13Z" 

The Pragmatic Bookshelf | Podcasts
================================================================================
  href="http://pragprog.com/podcasts"  
  tag="podcast" time="2013-09-30T14:26:44Z" 

FLOSS Weekly | TWiT.TV 
================================================================================
  href="http://twit.tv/show/floss-weekly"  
  tag="podcast" time="2013-09-30T14:26:16Z" 

On The Brink with Castle Island, Matt Walsh and Nic Carter
================================================================================
https://castleisland.libsyn.com/urbit-christian-lingales-and-logan-allen-ep17
tag="podcast bitcoin urbit decentralization"


Beyond Corp: The Access Proxy
================================================================================
https://research.google.com/pubs/pub45728.html
https://news.ycombinator.com/item?id=16204208
tag="security networks beyondcorp it sysadmin devops"

> - Instead of a single VPN that will expose your entire squishy corporate LAN to anyone who gets VPN access, each application gets its own protected proxy.
> - The protected proxies query a centrally-aggregated auth/authz database, which can work with client-side software to ensure qualities such as private key possession, full disk encryption, software updates, etc. In Google's case, this is combined with a host-rewriting browser extension for usability.
> - Access proxies can easily funnel HTTP traffic, but some more clever solutions involving tunnels exist for plain old TCP and UDP.
>
> By giving every application its own authentication and access control proxy, each application is secured on its own, hence "zero-trust."

BeyondCorp: The User Experience
================================================================================
https://research.google.com/pubs/pub46366.html
tag="security networks beyondcorp it sysadmin devops"


YubiKey via USB PCSC protocol
================================================================================
https://news.ycombinator.com/item?id=19567338
tag="security networks yubikey 2fa tfa"
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


pyu2f (USB HID protocol)
================================================================================
https://github.com/google/pyu2f
tag="security networks yubikey 2fa tfa"
python based U2F host library for interacting with a U2F device over USB.


Site to Site WireGuard: Part 1
================================================================================
https://christine.website/blog/site-to-site-wireguard-part-1-2019-04-02
https://lobste.rs/s/pje6iw/site_site_wireguard_part_1
tag="vpn wireguard security networks "
.
- VPN over a single UDP port.
- Custom TLS Certificate Authority: create TLS certificates for any domain.
- Expose TCP/UDP services to machines across network segments


UDP-based Data Transfer Protocol
================================================================================
https://en.wikipedia.org/wiki/UDP-based_Data_Transfer_Protocol
tag="networks tcp udp data-transfer"
High-performance data transfer protocol designed for transferring large
volumetric datasets over wide area networks.


TCP is an underspecified two-node consensus algorithm and what that means for your proxies
================================================================================
https://morsmachine.dk/tcp-consensus
tag="networks proxy tcp tcp-ip protocol"
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


IP Listen List
================================================================================
  Problems arise when third party applications (not using the HTTP Server APIs) bind to IP address and port 80 pairs on the machine. The HTTP Server API provides a way to configure the list of IP addresses that it binds and solves this coexistence issue. also: http://toastergremlin.com/?p=320
  href="http://msdn.microsoft.com/en-us/library/windows/desktop/aa364669(v=vs.85).aspx"
   
  tag="networks iis it http windows tcpip sysadmin"
  time="2013-09-05T20:45:27Z" 

Do You Really Know CORS?
================================================================================
http://performantcode.com/web/do-you-really-know-cors
tag="http web cors security interop"
CORS edge cases:
- either an unreleased safari version, or the most recent version will send preflight requests even if the request meets the spec (like if the Accept-Language is set to something they don't like).
- If you use the ReadableStream API with fetch in the browser, a preflight will be sent.
- If there are any events attached on the XMLHttpRequestUpload.upload listener, it will cause a preflight
- cross-domain @font-face urls, images drawn to a canvas using the drawImage stuff, and some webGL things will also obey CORS
- the crossorigin attribute will be required for cross-origin linked images or css, or the response will be opaque and js won't have access to anything about it.
- if you mess up CORS stuff, you get opaque responses, and opaque responses are "viral", so they can cause entire canvas elements to become "blacklisted" and extremely restricted.

Documenting your architecture: Wireshark, PlantUML and a REPL to glue them all
================================================================================
https://news.ycombinator.com/item?id=15325649
http://danlebrero.com/2017/04/06/documenting-your-architecture-wireshark-plantuml-and-a-repl/
tag="networks sysadmin devops"


Linux Raw Sockets
================================================================================
http://schoenitzer.de/blog/2018/Linux%20Raw%20Sockets.html<Paste>
tag="networks programming linux sockets"
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


favicon cheat sheet
================================================================================
  https://news.ycombinator.com/item?id=6315664
  href="https://github.com/audreyr/favicon-cheat-sheet"
    tag="webdev favicon"
  time="2013-09-02T17:52:34Z" 

The Changelog Podcast 
================================================================================
  href="http://thechangelog.com/podcast/"  
  tag="podcast" time="2013-08-27T20:06:09Z" 

In situ
================================================================================
  href="http://en.wikipedia.org/wiki/In_situ" 
   tag="pedantry latin concepts mental-model"
  time="2013-07-29T06:47:43Z" 

IPython Notebook
================================================================================
  "live" backpack-like document containing text, graphs, images, etc, resulting from python expressions.
  href="http://ipython.org/notebook.html"  
  tag="python programming repl" time="2013-07-28T23:30:49Z" 

git-annex
================================================================================
  cf. https://github.com/bup/bup
  href="https://git-annex.branchable.com/videos/" 
   tag="git backup" time="2013-07-20T05:19:30Z" 

go-wiki - Go Language Unofficial Community Wiki - Google Project Hosting
================================================================================
  href="https://code.google.com/p/go-wiki/" 
   tag="golang programming documentation"
  time="2013-07-17T04:27:09Z" 

description=""
================================================================================
  Mapp and White spent two years trying to prove McCormick knew his products didn‚Äôt work. They made inquiries in more than 20 countries and went to Belgium, France, Georgia, Lebanon, and Bahrain. They discovered he had sold more than 7,000 devices to agencies including the Hong Kong police, the Romanian airport authorities, the United Nations, and the M&amp;ouml;venpick hotel group. Most had been sold to Iraq, where an Interior Ministry investigation would eventually show that corruption on a titanic scale had made the ATSC contracts possible. In a 2011 Report to Congress, the Special Inspector General for Iraqi Reconstruction estimated that 75 percent of the value of McCormick‚Äôs sales had been spent on bribes.
  href="http://www.businessweek.com/articles/2013-07-11/in-iraq-the-bomb-detecting-device-that-didnt-work-except-to-make-money"
    tag="government-failure corruption dod"
  time="2013-07-15T00:58:21Z" 

‚ÄúWhy did you shoot me? I was reading a book‚Äù: The new warrior cop is out of control
================================================================================
  Excerpted from &amp;quot;Rise of the Warrior Cop: The Militarization of America's Police Forces&amp;quot; / Several months earlier at a local bar, Fairfax County, Virginia, detective David Baucum overheard the thirty-eight-year-old optometrist and some friends wagering on a college football game. ... After overhearing the men wagering, Baucum befriended Culosi as a cover to begin investigating him. ... Eventually Culosi and Baucum bet more than $2,000 in a single day. ... they brought in the SWAT team.
  href="http://www.salon.com/2013/07/07/%E2%80%9Cwhy_did_you_shoot_me_i_was_reading_a_book_the_new_warrior_cop_is_out_of_control/"
   
  tag="politics police-state habeas-corpus"
  time="2013-07-08T04:06:17Z" 

RockStarProgrammer - The Differences Between Mercurial and Git
================================================================================
  git is more granular than mercurial =&gt; very beneficial in creating new types of workflows mercurial: heads/branches are inferred by lack of children git: branches are &quot;namespaced&quot; per remote. All heads are explicit. A tag or a branch points to a particular node in the graph, and there are tools to compare the changes between two nodes; allows private branches. mercurial: history is immutable / changing history is discouraged git: mutability is normal part of workflow mercurial, the branch name is stored in the changeset. Easy to have duplicate/conflicting branch names. the branch name is in the changeset, so the branch lives forever =&gt; discourages throw-away branches / experimentation. In git, a branch is just a head. Changing a branch actually moves the pointer to the new changeset (hash/commit). This head must be _explicitly_ shared across repositories. - won't accidentally push code you don't mean to. - no fear of name collisions. / hg cannot shallow clone.
  href="http://www.rockstarprogrammer.org/post/2008/apr/06/differences-between-mercurial-and-git/"
    tag="programming mercurial dvcs git"
  time="2013-07-07T23:01:58Z" 

Brendan Eich 
================================================================================
  href="http://brendaneich.com/"  
  tag="blog" time="2013-06-26T05:17:23Z" 

Eric Lippert‚Äôs Blog 
================================================================================
  href="http://blogs.msdn.com/b/ericlippert/" 
   tag="blog" time="2013-06-26T05:16:13Z" 

The Old New Thing 
================================================================================
  href="http://blogs.msdn.com/b/oldnewthing/atom.aspx" 
   tag="rss blog" time="2013-06-26T04:25:26Z" 

TED talks 
================================================================================
  href="http://feeds.feedburner.com/tedtalks_audio" 
   tag="podcast" time="2013-06-26T04:20:22Z" 

The R-Podcast 
================================================================================
  href="http://r-podcast.org/feed/ogg/"  
  tag="podcast" time="2013-06-26T04:19:31Z" 

reason.tv podcast 
================================================================================
  href="http://reason.com/podcast/index.xml" 
   tag="podcast" time="2013-06-26T04:09:56Z" 

NPR: Planet Money Podcast 
================================================================================
  href="http://www.npr.org/rss/podcast.php?id=510289" 
   tag="podcast" time="2013-06-26T04:08:54Z" 

“DIAGNOSTIC WITH CODE FIX” USING ROSLYN API
================================================================================
tag=roslyn .net-compiler-platform programming visual-studio

hanselminutes 
================================================================================
  href="http://feeds.feedburner.com/Hanselminutes" 
   tag="podcast" time="2013-06-26T04:03:51Z" 

URL encoding
================================================================================
  The standards do not define any way by which a URI might specify the encoding it uses, so it has to be deduced from the surrounding information. For HTTP URLs it can be the HTML page encoding, or HTTP headers. reserved characters are different for each part encoding a fully constructed URL is impossible without a syntactical awareness of the URL structure.
  href="http://blog.lunatech.com/2009/02/03/what-every-web-developer-must-know-about-url-encoding"
   
  tag="programming webdev encoding uri rfc url"
  time="2013-06-24T14:21:50Z" 

History of the URL: Domain, Protocol, and Port
================================================================================
https://eager.io/blog/the-history-of-the-url-domain-and-protocol/
tag="todo programming webdev uri rfc url history"

History of the URL: Path, Fragment, Query, and Auth
================================================================================
https://eager.io/blog/the-history-of-the-url-path-fragment-query-auth/
tag="todo programming webdev uri rfc url history"

algernon web server
================================================================================
https://github.com/xyproto/algernon
tag="programming http web server lua go redis"
Small self-contained pure-Go web server with Lua, Markdown, HTTP/2, QUIC,
Redis and PostgreSQL support https://algernon.roboticoverlords.org/

Napoleon Bonaparte PBS Documentary
================================================================================
https://www.youtube.com/watch?v=MrbiSUgZEbg
tag="video history"
- Napoleon established the "Civil Code" which still underpins the French system.
- "I am the instrument of providence, she will use me as long as I accomplish
  her designs, then she will break me like a glass."
- British mothers would tell their children: "If you don't say your prayers,
  Boney will come and get you."
- "Conquest alone made me what I am. Conquest alone can keep me there."

modern.IE
================================================================================
  free official virtualbox images with internet explorer
  href="http://www.modern.ie/"  
  tag="vm tools programming webdev ie virtualbox windows microsoft"
  time="2013-06-14T06:02:44Z" 

EDWARD SNOWDEN, THE N.S.A. LEAKER, COMES FORWARD
================================================================================
  &amp;quot;I, sitting at my desk, certainly had the authorities to wiretap anyone, from you or your accountant, to a federal judge or even the President&amp;quot; another program, called Boundless Informant, processed billions of pieces of domestic data each month James Clapper, the Director of National Intelligence, flat-out lied to the Senate when he said that the N.S.A. did not ‚Äúwittingly‚Äù collect any sort of data on millions of Americans. [Americans are] protected, he said, only by ‚Äúpolicies,‚Äù and not by law: ‚ÄúIt‚Äôs only going to get worse, until eventually there comes a time when policies change,‚Äù and ‚Äúa new leader will be elected, they‚Äôll flip the switch.‚Äù
  href="http://www.newyorker.com/online/blogs/closeread/2013/06/edward-snowden-the-nsa-leaker-comes-forward.html"
   
  tag="authoritarianism paranoia politics police-state privacy"
  time="2013-06-10T05:33:06Z" 

Falsehoods programmers believe about time
================================================================================
  also: https://news.ycombinator.com/item?id=4128208 more: http://infiniteundo.com/post/25509354022/more-falsehoods-programmers-believe-about-time-wisdom
  href="http://infiniteundo.com/post/25326999628/falsehoods-programmers-believe-about-time"
    tag="programming edge-cases datetime"
  time="2013-06-07T19:21:33Z" 

Warning Signs in Experimental Design and Interpretation
================================================================================
  Psychology as a discipline has been especially stung by papers that cannot be reproduced. http://www.nytimes.com/2013/04/28/magazine/diederik-stapels-audacious-academic-fraud.html?pagewanted=all&amp;amp;_r=0 Uri Simonsohn &amp;quot;twenty-one word solution&amp;quot;: http://papers.ssrn.com/sol3/papers.cfm?abstract_id=2160588 &amp;quot;p-hacking&amp;quot;, an all too common practice in science that can be detected by statistical tests: http://www.p-curve.com/ http://papers.ssrn.com/sol3/papers.cfm?abstract_id=2259879 &amp;quot;Abstract: &amp;quot;When does a replication attempt fail? The most common standard is: when it obtains p&amp;gt;.05. Replication attempts fail when their results indicate that the effect, if it exists at all, is too small to have been detected by the original study. &amp;quot;Warning Signs in Experimental Design and Interpretation&amp;quot; http://norvig.com/experiment-design.html
  href="http://news.ycombinator.com/item?id=5680292" 
  
  tag="psychology skepticism scientific-error science"
  time="2013-05-09T18:08:55Z" 

Peter Norvig: pytudes: Python programs to practice or demonstrate skills.
================================================================================
https://github.com/norvig/pytudes
tag="programming todo"


Retraction Watch 
================================================================================
http://retractionwatch.com/

  tag="skepticism scientific-error medical-industrial-complex research science"
  time="2013-05-09T17:52:20Z" 

only 11% of 53 published cancer research papers were reproducible
================================================================================
  Amgen's findings are consistent with those of others in industry. A team at Bayer HealthCare in Germany last year reported4 that only about 25% of published preclinical studies could be validated to the point at which projects could continue. Notably, published cancer research represented 70% of the studies
  href="http://www.nature.com/nature/journal/v483/n7391/full/483531a.html"
   
  tag="skepticism scientific-error medical-industrial-complex research cancer science"
  time="2013-05-09T17:19:41Z" 

Voting paradox
================================================================================
  href="http://en.wikipedia.org/wiki/Voting_paradox" 
   tag="politics paradox psychology voting mental-model"
  time="2013-05-07T23:13:12Z" 

Arrow's impossibility theorem
================================================================================
  href="http://en.wikipedia.org/wiki/Arrow%27s_impossibility_theorem"
   
  tag="game-theory politics paradox psychology voting logic mental-model"
  time="2013-05-07T23:10:53Z" 

Windyty: weather visualizer
================================================================================
https://www.windyty.com
tag="visualization tools weather wind-patterns web"

Google Books Ngram Viewer
================================================================================
  corpus of text n-grams (contiguous sequence of n items) from the google books project http://books.google.com/ngrams/info raw datasets: http://books.google.com/ngrams/datasets
  href="http://books.google.com/ngrams/"  
  tag="books visualization tools google data-mining datasets data ngram machine-learning statistics"
  time="2013-04-25T22:40:25Z" 

Apache Arrow and the "10 Things I Hate About pandas"
================================================================================
http://wesmckinney.com/blog/apache-arrow-pandas-internals/
tag="pandas python data-science machine-learning statistics"

> my rule of thumb for pandas is that you should have 5 to 10 times as much RAM
  as the size of your dataset. So if you have a 10 GB dataset, you should really
  have about 64, preferably 128 GB of RAM if you want to avoid memory management
  problems.
> There are additional, hidden memory killers in the project, like the way that
  we use Python objects (like strings) for many internal details, so it's not
  unusual to see a dataset that is 5GB on disk take up 20GB or more in memory.
> Future (pandas2): Apache Arrow

Instaparse
================================================================================
  attempting to make context-free grammars as easy to use as regular expressions
  href="https://github.com/Engelberg/instaparse" 
   tag="clojure programming compiler cfg peg parser"
  time="2013-04-12T17:16:06Z" 

blockchain.info
================================================================================
  href="http://blockchain.info/"  
  tag="bitcoin cryptocurrency" time="2013-02-28T05:26:07Z" 

llex.c - Lua parser in c
================================================================================
  href="http://www.lua.org/source/5.1/llex.c.html" 
   tag="compiler lua parser"
  time="2013-02-01T01:18:10Z" 

ANTLR Parser Generator
================================================================================
  http://news.ycombinator.com/item?id=5056841 &quot;It can not only do the basic text-&gt;tree parsing from a file describing the grammar, but will also allow to specify additional grammars for traversing the generated tree and executing arbitrary code in your language of choice as particular nodes are recognized. ... Xpl.g grammar file for parsing the program text and creating the abstract syntax tree, a SemanticAnalysis.g grammar file for doing a first pass through the tree, annotating it with additional information, filling the symbol table, checking semantic correctness and then finally CodeGeneration.g for emitting JVM bytecode using the annotated tree.&quot;
  href="http://www.antlr.org/"  
  tag="programming compiler parser" time="2013-02-01T01:13:23Z" 

PEG.js: Parser Generator for JavaScript
================================================================================
  http://news.ycombinator.com/item?id=1198683 &quot;PEGs are a recent concept&quot; distinct from CFGs. http://news.ycombinator.com/item?id=1199271 &quot;the problem with PEGs: / implies ordering of the search (parsing) space. You need to order your / operators so that special cases (e.g. longer matches) appear first. Unfortunately, if you don't do this, nothing will tell you you have a problem with your grammar, it will simply not parse some inputs.&quot; =&gt; must exhaustively test PEG parser.
  href="http://pegjs.majda.cz/"  
  tag="hardware-dev programming compiler parser"
  time="2013-02-01T00:57:03Z" 

21 Compilers and 3 Orders of Magnitude in 60 Minutes
================================================================================
https://lobste.rs/s/fcm3dc/21_compilers_3_orders_magnitude_60
http://venge.net/graydon/talks/CompilerTalk-2019.pdf
tag="programming compiler optimization history"
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

Handling Growth with Postgres: 5 Tips From Instagram - Instagram Engineering
================================================================================
  href="http://instagram-engineering.tumblr.com/post/40781627982/handling-growth-with-postgres-5-tips-from-instagram"
   
  tag="sql scalability performance postgresql database"
  time="2013-02-01T00:55:01Z" 

kelly norton: On Layout &amp; Web Performance
================================================================================
  The following properties CAUSE LAYOUT: Element: clientHeight clientLeft clientTop clientWidth focus getBoundingClientRect getClientRects innerText offsetHeight offsetLeft offsetParent offsetTop offsetWidth outerText scrollByLines scrollByPages scrollHeight scrollIntoView scrollIntoViewIfNeeded scrollLeft scrollTop scrollWidth MouseEvent: layerX layerY offsetX offsetY Window: getComputedStyle scrollBy scrollTo scrollX scrollY Frame, Document, Image: height width
  href="http://kellegous.com/j/2013/01/26/layout-performance/"
   
  tag="programming webdev dev performance layout html web css"
  time="2013-02-01T00:51:48Z" 

AMP Camp 
================================================================================
  href="http://ampcamp.berkeley.edu/videos/" 
   tag="todo machine-learning"
  time="2012-11-05T02:25:13Z" 

guardianproject/haven
================================================================================
https://github.com/guardianproject/haven
Haven is for people who need a way to protect their personal spaces and possessions without compromising their own privacy, through an Android app and on-device sensors
tag="paranoia security app mobile phone"

================================================================================
Algo VPN: personal IPSEC VPN in the cloud
https://github.com/trailofbits/algo
https://blog.trailofbits.com/2016/12/12/meet-algo-the-vpn-that-works/
tag="anonymous privacy vpn paranoia security ipsec"
Does not require client software (unlike OpenVPN).

================================================================================
20200829
sinter: user-mode application authorization system for MacOS written in Swift
https://github.com/trailofbits/sinter
tag="macos security infosec os"
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

Color Scheme Designer 
================================================================================
  href="http://colorschemedesigner.com/"  
  tag="art web tools" time="2012-11-04T20:55:04Z" 

CircuitLab | sketch, simulate, and share your circuits
================================================================================
  online circuit simulator
  href="https://www.circuitlab.com/"  
  tag="engineering simulation electronics"
  time="2012-10-22T04:24:43Z" 

r twotorials 
================================================================================
  href="http://www.twotorials.com/"  
  tag="programming statistics r-lang tutorial"
  time="2012-10-17T04:47:56Z" 

CommonCrawl
================================================================================
  open source web crawl data
  href="http://commoncrawl.org/"  
  tag="datasets" time="2012-10-17T04:07:29Z" 

formlabs 
================================================================================
  href="http://www.formlabs.com/"  
  tag="electronics engineering self-replication 3d_printing"
  time="2012-09-20T04:28:56Z" 

noda-time - Project Hosting on Google Code
================================================================================
  href="http://code.google.com/p/noda-time/" 
   tag="programming .net datetime library"
  time="2012-09-13T18:28:36Z" 

Joda Time - Java date and time API - Home
================================================================================
  href="http://joda-time.sourceforge.net/" 
   tag="library programming java datetime"
  time="2012-09-13T18:27:35Z" 

Vert.x
================================================================================
https://vertx.io/
tag="library programming java concurrency"
Eclipse Vert.x is event driven and non blocking. This means your app can handle a lot of concurrency using a small number of kernel threads. Vert.x lets your app scale with minimal hardware.


TACK :: Trust Assertions for Certificate Keys
================================================================================
  dynamically activated public key pinning framework that provides a layer of indirection away from Certificate Authorities, but is fully backwards compatible with existing CA certificates, and doesn't require sites to modify their existing certificate chains.
   href="http://tack.io/"
   
  tag="cryptography certificate-authentication paranoia security"
  time="2012-08-30T05:35:44Z" 

Prediction Markets: When Do They Work?
================================================================================
https://thezvi.wordpress.com/2018/07/26/prediction-markets-when-do-they-work/
tag="market prediction-market economics mental-model"

Remember, if you can’t spot the sucker in your first half hour at the table,
then you are the sucker.
...
Another class of ‘natural’ traders are gamblers or noise traders, who demand
liquidity for no particular reason. They too can be the sucker.

Hybrid cryptosystem
================================================================================
https://en.wikipedia.org/wiki/Hybrid_cryptosystem
tag="security cryptography encryption"

Problem:  Public-key (asymmetric) cryptopgraphy is expensive (~1000x worse)
          compared to symmetric-key cryptopgraphy.
          Example: compare AES to RSA using `openssl speed`.
Solution: Hybrid cryptosystem:
            - key encapsulation scheme, which is a public-key cryptosystem, and
            - data encapsulation scheme, which is a symmetric-key cryptosystem.

All practical implementations of public-key cryptography employ a hybrid system.
Example: TLS = Diffie-Hellman + AES.


Convergence
================================================================================
  distributed, secure strategy for replacing Certificate Authorities
  href="http://convergence.io/"  
  tag="certificate-authentication distributed-systems paranoia security cryptography"
  time="2012-08-30T05:32:39Z" 

White House Worked With Buyout Firm to Save Plant - WSJ.com
================================================================================
  White House played a central role in encouraging another private-equity firm to rescue a Philadelphia oil refinery, whose imminent closure by owner Sunoco Inc. threatened to send gasoline prices higher before the election. Gene Sperling, director of Mr. Obama's National Economic Council, helped kick-start discussions to sell the refinery to Carlyle Group, CG -0.04% a well-connected Washington, D.C., private-equity firm. [...] regulators agreed to loosen certain environmental restrictions on the refinery. Pennsylvania's Republican governor, Tom Corbett, contributed $25 million in state subsidies and other incentives. [...] The White House referred the issue to the EPA, which along with state and local environmental officials agreed to modify the decree, allowing Carlyle to transfer emissions credits from the Marcus Hook refinery, in effect giving the Philadelphia refinery greater leeway to pollute.
  href="http://online.wsj.com/article/SB10000872396390443713704577603281330597966.html"
    tag="politics regulatory-capture"
  time="2012-08-23T03:53:45Z" 

Alistair.Cockburn.us | Characterizing people as non-linear, first-order components in software development
================================================================================
  People _failure modes_: - Since consistency of action is a common failure mode, we can safely predict that the documentation will not be up to date. - Individual personalities easily dominate a project. People _success modes_: - People are communicating beings, doing best face-to-face - People are highly variable, varying from day to day - People generally [...] are good at looking around, taking initiative --- - Low precision artifacts use the strengths of people to lower development costs. The most significant single factor is ‚Äúcommunication‚Äù.
  href="http://alistair.cockburn.us/Characterizing+people+as+non-linear%2c+first-order+components+in+software+development"
   
  tag="softwareengineering methodology project-management programming"
  time="2012-07-23T03:44:27Z" 

My 20-Year Experience of Software Development Methodologies
================================================================================
https://zwischenzugs.wordpress.com/2017/10/15/my-20-year-experience-of-software-development-methodologies/
tag="softwareengineering methodology project-management programming"

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

The Empty Promise of Data Moats / by Martin Casado and Peter Lauten
================================================================================
https://a16z.com/2019/05/09/data-network-effects-moats/
tag="startup network-effects dependencies data moat mental-model"
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

Stripe 
================================================================================
  href="https://stripe.com/"  
  tag="startup business api ecommerce"
  time="2012-07-19T05:32:06Z" 

Twilio | Build Scalable Voice, VoIP and SMS Applications in the Cloud
================================================================================
  href="http://www.twilio.com/"  
  tag="startup api telephony" time="2012-07-19T05:31:14Z" 

Dwolla 
================================================================================
  href="https://www.dwolla.com/"  
  tag="startup business ecommerce" time="2012-07-19T05:30:18Z" 

The If Works - Translation from Haskell to JavaScript of selected portions of the best introduction to monads I‚Äôve ever read
================================================================================
  monad: a design pattern. It says that whenever you have a class of functions that accept one type and return another type, there are two functions that can be applied across this class to make them composable: - 'bind' function: transforms any function to accept the same type as it returns, making it composable - 'unit' function: wraps a value in the type accepted by the composable functions. 'monad' pattern helps you spot accidental complexity: code that isn‚Äôt dealing directly with the problem at hand, but which is just glueing data types together.
  href="http://blog.jcoglan.com/2011/03/05/translation-from-haskell-to-javascript-of-selected-portions-of-the-best-introduction-to-monads-ive-ever-read/"
   
  tag="javascript monad functional-programming haskell"
  time="2012-07-19T05:23:04Z" 

C++ FAQ 
================================================================================
  href="http://www.parashift.com/c++-faq/" 
   tag="cpp programming faq"
  time="2012-07-18T17:30:30Z" 

WordNet - Princeton University Cognitive Science Laboratory
================================================================================
  lexical database of cognitive synonyms (synsets) interlinked by means of conceptual-semantic and lexical relations.
  href="http://wordnet.princeton.edu/"  
  tag="datasets data-mining" time="2012-07-05T03:55:32Z" 

Tcl Quick Reference
================================================================================
  also: http://www.fundza.com/tcl/quickref_2/ Yes, [expr] is a bit clunky - in Tcl8.5 arithmetic can also be done with prefix operators: % namespace import ::tcl::mathop::* % * 3 [+ 1 2] =&gt; 9
  href="http://www.fundza.com/tcl/quickref_1/" 
   tag="reference tcl programming"
  time="2012-06-20T02:36:55Z" 

OMG Ponies!!! (Aka Humanity: Epic Fail) - Jon Skeet: Coding Blog
================================================================================
  extended="- unicode &quot;composite characters&quot;: http://unicode.org/faq/char_combmark.html#7 - &quot;zero-width non-joiner&quot; \u200c - Turkey test java.util.Date and Calendar may or may not account for leap seconds depending on the host support CST timezone is one of { Central Standard Time US / UTC-6; Central Standard Time Australia / UTC+9.30; Central Summer Time Australia } &quot;Argentina announced that it wasn't going to use daylight saving time any more... 11 days before its next transition. The reason? Their dams are 90% full. I only heard about this due to one of my unit tests failing. For various complicated reasons, a unit test which expected to recognise the time zone for Godthab actually thought it was Buenos Aires. So due to rainfall thousands of miles away, my unit test had moved Greenland into Argentina.&quot;"
  href="http://msmvps.com/blogs/jon_skeet/archive/2009/11/02/omg-ponies-aka-humanity-epic-fail.aspx"
   
  tag="data-representation edge-cases datetime unicode programming"
  time="2012-06-18T16:58:06Z" 

C++ Frequently Questioned Answers 
================================================================================
  href="http://yosefk.com/c++fqa/"  
  tag="cpp faq programming" time="2012-06-16T17:46:41Z" 

My first month freelancing | Hacker News
================================================================================
  tptacek's excellent arguments for daily billing increments http://news.ycombinator.com/user?id=tptacek see also: http://news.ycombinator.com/item?id=3420303
  href="http://news.ycombinator.com/item?id=4101355" 
   tag="contracting freelancing"
  time="2012-06-13T03:25:41Z" 

AppHarbor - AppHarbor
================================================================================
  .NET host, build server, deployment
  href="https://appharbor.com/"  
  tag="build_server .net hosting" time="2012-06-12T17:49:32Z" 

A Quiz About Integers in C | Hacker News
================================================================================
  type coercion pathology
  href="http://news.ycombinator.com/item?id=4061815" 
   tag="programming c" time="2012-06-04T16:13:07Z" 

JRuby casting null support
================================================================================
  cast nulls in jruby. java_alias, java_method, java_send
  href="http://jira.codehaus.org/browse/JRUBY-3865" 
   tag="repl java jruby" time="2012-04-28T00:08:08Z" 

"java.lang.OutOfMemoryError: PermGen space" exception (classloader leaks)
================================================================================
  java PermGen = class definition heap avoid static references to class definitions &quot;The JDK's permanent memory behaves differently depending on whether a debugger is enabled&quot; http://wiki.caucho.com/Java.lang.OutOfMemoryError:_PermGen_space
  href="http://frankkieviet.blogspot.com/2006/10/how-to-fix-dreaded-permgen-space.html"
   
  tag="heap permgen debug profiling programming java"
  time="2012-04-20T23:06:14Z" 

Code, Collaborate, Compile - compilify.net
================================================================================
  href="http://compilify.net/"  
  tag="tools programming online repl"
  time="2012-04-11T22:42:28Z" 

Affordances - Interaction-Design.org: HCI, Usability, Information Architecture, User Experience, and more..
================================================================================
  affordance = an action possibility available to the user avoid &quot;false affordance&quot; (like a knob that cannot be turned, or a chair that cannot be sat in). an intelligent control interface is as a false affordance. http://unqualified-reservations.blogspot.com/2009/07/wolfram-alpha-and-hubristic-user.html
  href="http://www.interaction-design.org/encyclopedia/affordances.html"
    tag="design hci patterns ui usability"
  time="2012-04-10T05:35:50Z" 


convey the global structure (BIG PICTURE) of programs
================================================================================
http://akkartik.name/about
tag="software architecture programming project-management engineering complexity documentation"

- Deemphasize interfaces in favor of tests. Automated tests are great not just
  for avoiding regressions and encouraging a loosely-coupled architecture, but
  also for conveying the BIG PICTURE of a project.
- Deemphasize abstractions in favor of traces. For example, the repository for
  a text editor might guide new programmers first to a trace of the events that
  happen between pressing a key and printing a character to screen, demarcating
  the major sub-systems of the codebase in the process and allowing each line in
  the logs to point back at code, silently jumping past details like what the
  precise function boundaries happen to be at the moment.


Distributed Systems Programming. Which Level Are You? ¬´ Incubaid Research
================================================================================
  Partial Failure ... These failure modes are the very defining property of distributed systems. &quot;A distributed system is one in which the failure of a computer you didn‚Äôt even know existed can render your own computer unusable&quot; (Leslie Lamport) abandon the idea of network transparency, and attack the handling of partial failure distributed state machine: &quot;multi-paxos implementation on top of TCP&quot; Unit testing: The problem however is reproducing the failure scenario is difficult, if not impossible concurrency causes indeterminism, but you can‚Äôt abandon it--you just have to ban it from mingling with your distributed state machine (No IO, No Concurrency). you can only get to a new state via a new message. Benefits: Perfect control, reproducibility, tracibility. Costs: You‚Äôre forced to reify all your actions. You have to model every change that needs your attention into a message.
  href="http://blog.incubaid.com/2012/03/28/the-game-of-distributed-systems-programming-which-level-are-you/"
   
  tag="concurrency architecture programming distributed-systems"
  time="2012-04-04T16:48:46Z" 

UNDERSTANDING HASH FUNCTIONS by Geoff Pike
================================================================================
https://github.com/google/farmhash/blob/master/Understanding_Hash_Functions
tag="programming compsci algorithms hash-function"

More study of diff: Walter Tichy's papers
================================================================================
http://bryanpendleton.blogspot.de/2010/04/more-study-of-diff-walter-tichys-papers.html
tag="programming algorithms diff"
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

google-diff-match-patch - Google Code
================================================================================
robust diff/patch library Myer's diff algorithm Bitap matching algorithm more sophisticated than GNU patch
href="https://github.com/google/diff-match-patch"
tag="google library programming algorithms diff lua"

[Toybox] More than you really wanted to know about patch.
================================================================================
http://lists.landley.net/pipermail/toybox-landley.net/2019-January/010049.html
tag="programming tools unix algorithms diff patch"
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
tag="programming tools algorithms diff patch merge semantic-diff"
https://blog.trailofbits.com/2020/08/28/graphtage/
When paired with PolyFile, you can semantically diff arbitrary file formats.
https://blog.trailofbits.com/2019/11/01/two-new-tools-that-tame-the-treachery-of-files/

Data Laced with History: Causal Trees & Operational CRDTs
================================================================================
http://archagon.net/blog/2018/03/24/data-laced-with-history/
https://news.ycombinator.com/item?id=18477756
tag="algorithms compsci diff crdt"

"I See What You Mean" by Peter Alvaro
================================================================================
https://www.youtube.com/watch?v=R2Aa4PivG0g&t=2295s
tag="datalog query language"

Dedalus: Datalog in Time and Space
================================================================================
https://www2.eecs.berkeley.edu/Pubs/TechRpts/2009/EECS-2009-173.html
tag="datalog query language"

Bloom
================================================================================
https://github.com/bloom-lang/bud
Dedalus rewrite
tag="datalog query language"


High Scalability - 7 Years of YouTube Scalability Lessons in 30¬†Minutes
================================================================================
  Jitter - Add Entropy Back into Your System: If your system doesn‚Äôt jitter then you get thundering herds. Debugging distributed applications is as deterministic as predicting the weather. Jitter introduces more randomness because things tend to stack up. For example, cache expirations: If everything expires at one time this creates a thundering herd. To introduce &quot;jitter&quot; you might randomly expire between 18-30 hours. Each machine actually removes entropy from the system, so you have to add some back in. Cheating - Know How to Fake Data: The fastest function call is the one that doesn‚Äôt happen. A monotonically increasing counter, like movie view counts or profile view counts, could update by a random amount and as long as it changes from odd to even people would probably believe it‚Äôs real, and the actual transactions only need to happen occasionally.
  href="http://highscalability.com/blog/2012/3/26/7-years-of-youtube-scalability-lessons-in-30-minutes.html"
   
  tag="programming architecture scalability"
  time="2012-03-28T16:11:27Z" 

DOM Events, Memory Leaks, and You - Google Web Toolkit - Google Code
================================================================================
  &quot;any reference cycle that involves a JavaScript object and a DOM element (or other native object) has a nasty tendency to never get garbage-collected&quot; &quot;as long as you don't set up any reference cycles on your own using JSNI, you can't write an application in GWT that will leak.&quot;
  href="https://developers.google.com/web-toolkit/articles/dom_events_memory_leaks_and_you"
   
  tag="programming eventbus memoryleak gwt"
  time="2012-03-23T13:56:26Z" 

Understanding Memory Leaks - Google Web Toolkit (GWT)
================================================================================
  *widget/DOM* level, vs. application/global level. you don't need to to unregister event handlers at the widget level--only the application/global level.
  href="http://code.google.com/p/google-web-toolkit/wiki/UnderstandingMemoryLeaks"
   
  tag="eventbus memoryleak programming gwt"
  time="2012-03-22T16:39:22Z" 

GWT Handler Registrations
================================================================================
  memory leaks: application level vs. DOM/widget level removeHandler is *never* required to avoid DOM-/browser-level memory leaks removeHandler *is* required to avoid application-level memory leaks For global EventBus with a transient event listener, the transient listener will prevent its container object from being garbage-collected until the EventBus is also garbage collected. Instead of handing the application-wide EventBus directly to an activity, wrap the EventBus in a ResettableEventBus. Then when that activity is done, ResettableEventBus.removeHandlers().
  href="http://draconianoverlord.com/2010/11/23/gwt-handlers.html"
   
  tag="memoryleak eventbus programming gwt"
  time="2012-03-22T16:37:35Z" 

Baby's First Garbage Collector
================================================================================
http://journal.stuffwithstuff.com/2013/12/08/babys-first-garbage-collector/
tag="gc garbage-collector compsci programming-language"
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



Windows File System Redirection (Diagnosing weird problems - a Stack Overflow case study)
================================================================================
http://www.reddit.com/r/programming/comments/qzo96/diagnosing_weird_problems_a_stack_overflow_case/
tag="debug kernel windows"

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

Container isolation gone wrong / By Gianluca Borello on May 22, 2017
================================================================================
https://sysdig.com/blog/container-isolation-gone-wrong/
tag="debug kernel linux perf perf-tools"

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



A Rebase Workflow for Git | RandyFay.com
================================================================================
  use 'rebase' workflow instead of 'merge' workflow
  href="http://www.randyfay.com/node/91"  
  tag="dvcs dv git" time="2012-03-01T23:05:53Z" 

52 Things People Should Know To Do Cryptography
================================================================================
  href="http://www.cs.bris.ac.uk/Research/CryptographySecurity/knowledge.html"
    tag="compsci cryptography"
  time="2012-02-22T01:59:23Z" 

L. Gordon Crovitz: You Commit Three Felonies a Day - WSJ.com
================================================================================
  Harvey Silverglate book: &quot;Three Felonies a Day&quot; ...securities laws, which Congress leaves intentionally vague, encouraging regulators and prosecutors to try people even when the law is unclear. Prosecutors identify defendants to go after instead of finding a law that was broken and figuring out who did it.
  href="http://online.wsj.com/article/SB10001424052748704471504574438900830760842.html"
    tag="police-state politics"
  time="2012-02-20T05:53:54Z" 

Congresswoman who voted for the Patriot Act expresses outraged after being wiretapped
================================================================================
  href="https://www.youtube.com/watch?v=NFn4JXkcwLs" 
   tag="video politics police-state"
  time="2012-02-20T05:26:10Z" 

Use C# 4.0 dynamic to drastically simplify your private reflection code - Angle Bracket Percent - Site Home - MSDN Blogs
================================================================================
  Access private and internal members in other assemblies, using private reflection. foo1.AsDynamic()
  href="http://blogs.msdn.com/b/davidebb/archive/2010/01/18/use-c-4-0-dynamic-to-drastically-simplify-your-private-reflection-code.aspx"
    tag="programming reflection c# .net"
  time="2012-01-31T06:25:39Z" 

Things to Do | tampabay.com &amp; the St. Petersburg Times
================================================================================
  href="http://www.tampabay.com/things-to-do/" 
   tag="fun tampa" time="2012-01-23T08:03:38Z" 

The ultimate Vim configuration - vimrc
================================================================================
  href="http://amix.dk/vim/vimrc.html"  
  tag="vim" time="2012-01-20T19:06:53Z" 

Keeping a clean GitHub fork ‚Äì Part 1 ¬ª Evan's Blog
================================================================================
  - add a remote pointing to the canonical repository. - you may want to also add some other remotes of developers you follow. - your master branch should always be a mirror of the upstream master branch - --ff-only : &quot;the single safest way to update your local master branch&quot; - All work should be done in topic branches: feature/some-new-thing hotfix/BUGID-andor-description - generally, you want to branch from master - commit and push early and often
  href="http://blog.evan.pro/keeping-a-clean-github-fork-part-1"
    tag="programming git"
  time="2012-01-20T18:09:25Z" 

Joel Pobar's weblog
================================================================================
  series on HTML Data Extraction ~Mar 2010
  href="http://callvirt.net/blog/"  
  tag="f# blog machine-learning c# .net programming"
  time="2012-01-18T15:32:03Z" 

blueimp/jQuery-File-Upload - GitHub
================================================================================
  Excellent multiple/drag/drop file upload.
  href="https://github.com/blueimp/jQuery-File-Upload" 
   tag="programming web asp.net jquery"
  time="2011-12-31T22:50:34Z" 

Session_Start or Session_OnStart?
================================================================================
  Idiosyncrasies of global.asax event signatures... void Session_Start(object sender, EventArgs e) void Session_Start() void Session_OnStart(object sender, EventArgs e) void Session_OnStart() ALL will be called, in the order as listed.
  href="http://aspnetresources.com/articles/event_handlers_in_global_asax"
    tag="asp.net programming"
  time="2011-11-28T03:41:49Z" 

GoogleContainerTools/distroless
================================================================================
https://github.com/GoogleContainerTools/distroless/blob/master/base/README.md
tag="linux oss google gce cloud container distro"
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

3 Misconceptions That Need to Die
================================================================================
  Misconception: Most of what Americans spend their money on is made in China. Fact: Just 2.7% of personal consumption expenditures go to Chinese-made goods and services. Misconception: We owe most of our debt to China. Fact: China owns 7.8% of U.S. government debt outstanding. Misconception: We get most of our oil from the Middle East. Fact: Just 9.2% of oil consumed in the U.S. comes from the Middle East.
  href="http://www.fool.com/investing/general/2011/10/25/3-misconceptions-that-need-to-die.aspx"
    tag="politics economics"
  time="2011-11-07T02:37:34Z" 

Ilya Khrzhanovsky's Dau: &quot;The Movie Set That Ate Itself&quot;
================================================================================
  The fine system has also fostered a robust culture of snitching. &quot;In a totalitarian regime, mechanisms of suppression trigger mechanisms of betrayal,&quot; the director explains. ... The only acting professional in the cast is Radmila Shchegoleva ... before shooting began, she spent a full year working at a chocolate factory and a hospital, a regimen devised by Khrzhanovsky to beat the actress out of her. ... For the lead role, he had one stipulation: It had to be played by an actual genius, regardless of the discipline. ... &quot;All geniuses are foreigners,&quot; Khrzhanovsky tells me cryptically. ... Sveta, the film's comely &quot;executive producer,&quot; came here two years ago to interview Khrzhanovsky for a book on young Russian directors and stayed, divorcing her husband soon after.
  href="http://www.gq.com/entertainment/movies-and-tv/201111/movie-set-that-ate-itself-dau-ilya-khrzhanovsky"
    tag="film art bizarre"
  time="2011-10-31T22:46:25Z" 

Google Guava
================================================================================
  Google's core libraries that we rely on in our Java-based projects: collections, caching, primitives support, concurrency libraries, common annotations, string processing, I/O, etc.
  href="http://code.google.com/p/guava-libraries/" 
   tag="java google oss programming library"
  time="2011-10-19T22:53:36Z" 

Stephen Colebourne's blog: Time-zone database down
================================================================================
  href="http://blog.joda.org/2011/10/today-time-zone-database-was-closed.html"
    tag="ip law government-failure"
  time="2011-10-17T13:07:53Z" 

The (Illegal) Private Bus System That Works - Lisa Margonelli - National - The Atlantic
================================================================================
  The city's perverse policy of half-legalizing legal vans and failing to enforce laws against the unlicensed ones limits the growth of what could be a useful transit resource. --- Comment: The chief reason for the demise of privately owned mass transit and the decline of the succeeding publicly owned version was the inability of transit providers to raise fares. No politician wanted to preside over a fare increase, so fares were kept artificially and unrealistically low for decades until the 70s, when there was finally a crisis. Should the dollar vans be fully legalized, and therefore regulated, we can expect politicians -- who are universally devoid both of economic knowledge and of business sense -- to replay the former history, so that Winston and his fellows will be bankrupt within 10 years of achieving legality.
  href="http://www.theatlantic.com/national/archive/2011/10/the-illegal-private-bus-system-that-works/246166/"
   
  tag="economics transportation government-failure"
  time="2011-10-17T12:48:11Z" 

mergerfs
================================================================================
https://github.com/trapexit/mergerfs
tag="filesystem union jbod data-management raid fuse"
union filesystem (JBOD solution)
> mergerfs is a union filesystem geared towards simplifying storage and
> management of files across numerous commodity storage devices. It is similar
> to mhddfs, unionfs, and aufs.
>
> Works with heterogeneous filesystem types


Amazon six-pager
================================================================================
https://news.ycombinator.com/item?id=19115686
tag="documentation communication work habits teams"
principles of the 6-pager:
- 6 pages is the upper limit; the memo can be shorter
- The format is designed to drive the meeting structure by requiring attendees
  to read the memo in the first 10 minutes of a meeting, followed by discussion
- You can push extra information into the appendix if needed to convince those
  looking for more evidence
- The memo is self-sufficient as a unit of information, unlike a Powerpoint that
  relies on the presenter to contextualize and connect the information
The basic thrust is to bring the discipline of scientific style article writing
into office communications (and avoid Powerpoint anti-patterns in the process).
> "Writing is nature's way of letting you know how sloppy your thinking is." -Dick Guindon, via Leslie Lamport



Protocol Buffers - Google's data interchange format
================================================================================
  Protocol Buffers are a way of encoding structured data in an efficient yet extensible format. Google uses Protocol Buffers for almost all of its internal RPC protocols and file formats. also: http://code.google.com/p/protobuf-net/
  href="http://code.google.com/p/protobuf/" 
   tag="library google programming protocol"
  time="2011-10-13T07:18:54Z" 

s.tl() : Omniture ¬ª Custom Link Tracking: Capturing User Actions
================================================================================
  - based on s.tl() - used to track anything: button clicks, form values, etc. - does NOT count a page view. - Note from &quot;SiteCatalyst Implementation Guide&quot;: If linkTrackVars is set to &quot;&quot; ALL variables that have values will be sent with link data.
  href="http://blogs.omniture.com/2009/03/12/custom-link-tracking-capturing-user-actions/"
   
  tag="adobe omniture sitecatalyst webanalytics javascript"
  time="2011-10-04T19:10:14Z" 

Using System.Net Tracing - Durgaprasad Gorti's WebLog - MSDN Blogs
================================================================================
  You can see clearly that 1) The Remote Certificate is being clearly presented in the log file. 2) Any errors in the remote certificate are logged. 3) In this case we are returning true for NAME MISMATCH if the server is local or intranet [Please see the remore certificate validation callback code] 4) The fact that we accepted the certificate is also logged. 5) Then at the sockets level you can see encrypted data being sent 6) At the System.Net level (application level) you can see the decrypted data.
  href="http://blogs.msdn.com/b/dgorti/archive/2005/09/18/471003.aspx"
    tag="debug .net"
  time="2011-09-28T10:09:06Z" 

compute bricks – small-form-factor fanless PCs
================================================================================
http://esr.ibiblio.org/?p=8195
tag="hardware compute engineering small-form-factor fanless embedded soc"
Players in this space include Jetway, Logic Supply, Partaker, and Shuttle.
Poke a search engine with “fanless PC” to get good hits.

google-guice - Guice
================================================================================
  Guice is a lightweight dependency injection framework for Java.¬† Guice alleviates the need for factories and 'new'. Think of Guice's @Inject as the new 'new'. Your code will be easier to change, unit test and reuse in other contexts.
  href="http://code.google.com/p/google-guice/" 
   tag="programming java google"
  time="2011-09-26T17:32:21Z" 

SAP Community Network Wiki - ABAP Language and Runtime Environment
================================================================================
  href="http://wiki.sdn.sap.com/wiki/display/ABAP/ABAP+Language+and+Runtime+Environment"
    tag="sap programming"
  time="2011-09-26T17:26:14Z" 

SAP Developer Network (SDN) 
================================================================================
  href="http://www.sdn.sap.com/"  
  tag="sap programming" time="2011-09-26T17:17:14Z" 

Signals and Systems | MIT OpenCourseWare
================================================================================
  introduction to analog and digital signal processing¬† Fourier transform¬† Filtering and filter design, modulation, and sampling¬†
  href="http://ocw.mit.edu/resources/res-6-007-signals-and-systems-spring-2011/"
   
  tag="pedagogy todo science engineering courses"
  time="2011-09-12T16:31:57Z" 

Gundo - Visualize your Vim Undo Tree
================================================================================
  href="http://sjl.bitbucket.org/gundo.vim/" 
   tag="plugin vim oss" time="2011-09-09T18:44:00Z" 

Semantic Versioning
================================================================================
  Version numbers have three components: major.minor.bugfix. For example: 1.2.4 or 2.13.0.Versions with a major version of 0 (e.g. 0.2.3) make no guarantees about backwards compatibility. You are free to break anything you want. It‚Äôs only after you release 1.0.0 that you begin making promises.If a release introduces backwards-incompatible changes, increment the major version number.If a release is backwards-compatible, but adds new features, increment the minor version number.If a release simply fixes bugs, refactors code, or improves performance, increment the bugfix version number.
  href="http://stevelosh.com/blog/2011/09/writing-vim-plugins/#use-semantic-versioning-so-i-can-stay-sane"
    tag="programming project-management"
  time="2011-09-07T05:27:33Z" 

How to git-svn clone the last n revisions from a Subversion repository?
================================================================================
  use -r option to &quot;shallow clone&quot; big repositories: git svn clone -s -r123:HEAD http://svn.example.com/repos/ -T trunk -b branches -t tags
  href="http://stackoverflow.com/questions/747075/how-to-git-svn-clone-the-last-n-revisions-from-a-subversion-repository"
    tag="git svn programming"
  time="2011-09-06T04:24:42Z" 

Cygwin DLL Remapping Failure
================================================================================
  To handle repeated failures of 'rebaseall', instruct cygwin to avoid the area of memory where an external DLL is mapped.
  href="http://code.google.com/p/chromium/wiki/CygwinDllRemappingFailure"
    tag="cygwin windows git"
  time="2011-09-06T03:32:20Z" 

CO2 lags temperature - what does it mean?
================================================================================
  href="http://www.skepticalscience.com/co2-lags-temperature.htm"
    tag="agw science"
  time="2011-09-01T16:20:35Z" 

A Guide to Efficiently Using Irssi and Screen | quadpoint.org
================================================================================
  href="http://quadpoint.org/articles/irssi" 
   tag="oss irc linux screen"
  time="2011-08-29T18:15:35Z" 

Irssi /channel, /network, /server and /connect ‚Äì What It Means
================================================================================
  href="http://pthree.org/2010/02/02/irssis-channel-network-server-and-connect-what-it-means/"
    tag="irc oss linux"
  time="2011-08-29T18:14:49Z" 

Why do electron orbitals in the molecular orbital theory form in those specific shapes?
================================================================================
  Suppose I connect the ends of the string. All of a sudden, only certain vibrations make any sense on that string, because other wavelengths won't match up at the point where the string is connected together. We refer to this as a periodic boundary condition, that the value of the wave at x must be equal to the value of the wave at x+2pi. Now imagine the same thing all the way around the surface of a sphere. Start at any point, travel in any direction for one trip around the sphere, and the function has to return to the same value for the description to be logical. Then you can take another step and talk about the family of solutions on the surface of a sphere; in one case, the trivial one, there are no nodes, the whole sphere kind of &quot;breathes&quot; together. Then we introduce one equatorial node, the north pole vibrates out and the south pole vibrates in, and then the reverse. Then we add more and more nodes of vibration.
  href="http://www.reddit.com/r/askscience/comments/ju47b/why_do_electron_orbitals_in_the_molecular_orbital/"
    tag="science pedagogy learning"
  time="2011-08-26T02:37:22Z" 

asciinema
================================================================================
https://asciinema.org/
tag="video screencast"
.
SETUP
    pip3 install --upgrade asciinema
    npm install --global asciicast2gif
USAGE
    asciinema rec foo.json
    # https://github.com/asciinema/asciicast2gif
    asciicast2gif foo.json foo.gif


Data | The World Bank 
================================================================================
  href="http://data.worldbank.org/"  
  tag="datasets statistics data-mining"
  time="2011-08-21T02:36:00Z" 

http://setosa.io
================================================================================
Visual explanations. Victor Powell
tag="pedagogy mathematics learning"
2016-08-09 01:44:45

Cantor's enumeration of pairs
================================================================================
https://en.wikipedia.org/wiki/Pairing_function#Cantor_pairing_function
https://stackoverflow.com/a/682485/152142
tag="mathematics algorithm mental-model"
> a pairing function is a process to uniquely encode two natural numbers into a single natural number.


Machine Learning - Stanford University
================================================================================
  open-registration online offering similar to cs229
  href="http://ml-class.com/"  
  tag="pedagogy video machine-learning"
  time="2011-08-17T03:13:59Z" 

RStudio R IDE
================================================================================
  href="http://rstudio.org/"  
  tag="programming statistics r-lang"
  time="2011-08-07T19:05:02Z" 

Google Libraries API
================================================================================
  CDN and loading architecture for the most popular, open-source JavaScript libraries. Makes it easy to serve¬†the libraries, correctly set cache headers, and get bug-fix releases.
  href="https://developers.google.com/speed/libraries/"
   
  tag="programming google web javascript jquery"
  time="2011-08-05T14:16:46Z" 

Friendly Options: Better understand your stock option grants.
================================================================================
https://friendlyoptions.org/
  tag="finance employee employment work career options stock compensation"

What I Wish I'd Known About Equity Before Joining A Unicorn
================================================================================
https://gist.github.com/yossorion/4965df74fd6da6cdc280ec57e83a202d
https://news.ycombinator.com/item?id=13426494
tag="finance employee employment work career options stock compensation"

Ruxum Exchange 
================================================================================
  href="https://x.ruxum.com/"  
  tag="bitcoin finance exchange" time="2011-08-04T17:01:06Z" 

obfuscated-openssh
================================================================================
  A patch for OpenSSH which obfuscates the protocol handshake.
  href="https://github.com/brl/obfuscated-openssh" 
   tag="linux security ssh paranoia oss"
  time="2011-08-04T06:42:10Z" 

How to avoid SSH timeouts
================================================================================
  some routers time out idle connections. to fix, edit /etc/ssh/sshd_config on the server:¬† ClientAliveInterval 540 or edit /etc/ssh/ssh_config on the client:¬† ServerAliveInterval 540
  href="http://dan.hersam.com/2007/03/05/how-to-avoid-ssh-timeouts/"
    tag="ssh linux oss"
  time="2011-07-24T20:07:18Z" 

Vowpal Wabbit
================================================================================
  a fast out-of-core learning system sponsored by Yahoo! Research also:¬†http://hunch.net/~vw/
  href="https://github.com/JohnLangford/vowpal_wabbit/wiki"
    tag="machine-learning programming"
  time="2011-07-22T00:53:37Z" 

Machine Learning (Theory)
================================================================================
  a blog about academic research in machine learning and learning theory, by John Langford
   href="http://hunch.net/"
    tag="blog machine-learning statistics"
  time="2011-07-22T00:50:40Z" 

Ideone.com | Online IDE &amp; Debugging Tool
================================================================================
  online IDE for many languages
   href="http://ideone.com/"
    tag="repl online programming tools web"
  time="2011-07-21T09:49:08Z" 

Dynamic Dummy Image Generator - DummyImage.com
================================================================================
  href="http://dummyimage.com/"  
  tag="tools web webdesign" time="2011-07-21T09:48:06Z" 

google-code-prettify
================================================================================
  really good automatic syntax highlighting of source code snippets in an html page, using javascript and CSS.
  href="http://code.google.com/p/google-code-prettify/"
   
  tag="programming javascript editing documentation web"
  time="2011-07-21T04:28:56Z" 

Concatenating row values in T-SQL
================================================================================
  - Recursive CTE method - &quot;FOR XML with PATH&quot; method
  href="http://www.projectdmx.com/tsql/rowconcatenate.aspx"
    tag="sql programming"
  time="2011-07-21T01:43:39Z" 

Jon Skeet: Coding Blog 
================================================================================
  href="http://msmvps.com/blogs/jon_skeet/" 
   tag="blog programming .net c#"
  time="2011-07-20T16:56:46Z" 

the Data Hub (CKAN)
================================================================================
  Comprehensive Knowledge Archive Network (CKAN) a dedicated registry of open material¬†¬†
   href="http://ckan.net/"
    tag="statistics datasets"
  time="2011-07-20T07:04:14Z" 

theinfo.org data sets
================================================================================
  list of various data sets
  href="http://theinfo.org/get/data"  
  tag="datasets statistics" time="2011-07-20T07:00:19Z" 

How to fix Cygwin slow start up
================================================================================
  solution: in¬†/etc/profile.d/bash_completion.sh append an ampersand to the line that runs bash completion: ¬† ¬† . /etc/bash_completion &amp;
  href="http://cfc.kizzx2.com/index.php/cygwin-slow-start-up-the-culprit-discovered/"
    tag="cygwin bash windows"
  time="2011-07-20T01:33:29Z" 

Use Splatting to Simplify Your PowerShell Scripts
================================================================================
  interesting, unsung parts of Windows PowerShell: -¬†Escape char = backtick (`). Also continues a line. -¬†Splatting: ability to use a dictionary or list to supply to parameters to a command. ¬† ¬† $foo =¬†@{ p1 = &quot;a1&quot; p2 = &quot;a2&quot; ... } - use splatting to write functions that call other functions -¬†Windows Presentation Foundation PowerShell Kit (WPK) -¬†Import-Module PowerShellPack
  href="http://blogs.technet.com/b/heyscriptingguy/archive/2010/10/18/use-splatting-to-simplify-your-powershell-scripts.aspx"
   
  tag="powershell programming scripting windows"
  time="2011-07-14T19:00:45Z" 

Woman arrested for filming the police; supporters targeted by police.
================================================================================
  Video of police intimidation
  href="http://www.reddit.com/r/politics/comments/i83a8/remember_the_woman_who_was_arrested_for_filming/"
    tag="police-state video"
  time="2011-07-04T10:07:12Z" 

CopWatch and OpenWatch: covert recording apps for interactions with authority figures
================================================================================
  &quot;OpenWatch Recorder&quot; and &quot;CopRecorder&quot; covertly record audio and transmit it to the OpenWatch site. There, it is reviewed for significance, stripped of personal information, and published.¬† other:¬† http://www.justin.tv¬† http://qik.com/
  href="http://m.boingboing.net/2011/06/24/copwatch-and-openwat.html"
    tag="paranoia police-state tools"
  time="2011-07-04T09:59:41Z" 

Calculated Risk 
================================================================================
  href="http://www.calculatedriskblog.com/" 
   tag="finance blog" time="2011-06-30T21:43:19Z" 

Cop Block | Reporting Police Abuse
================================================================================
  href="http://www.copblock.org/"  
  tag="politics police-state" time="2011-06-29T18:56:51Z" 

Google Web Fonts 
================================================================================
  href="http://www.google.com/webfonts/v2" 
   tag="google font web css"
  time="2011-06-29T18:51:17Z" 

Holistic Numerical Methods 
================================================================================
  href="http://numericalmethods.eng.usf.edu/" 
   tag="learning mathematics pedagogy video"
  time="2011-06-27T19:15:50Z" 

Pi-Search: Search the first four billion binary digits of Pi for a string
================================================================================
  although pi is conjectured to contain all finite information, the index for locating a given string is usually longer than the information itself:¬† http://www.reddit.com/r/math/comments/hi719/does_pi_contain_all_information/c1vl0i6
  href="http://pi.nersc.gov/"  
  tag="mathematics information" time="2011-05-26T03:37:10Z" 

CATO: Map of Botched Paramilitary Police Raids
================================================================================
  href="http://www.cato.org/raidmap/"  
  tag="politics police-state" time="2011-05-18T00:06:16Z" 

Marine Survives Two Tours in Iraq, SWAT Kills Him
================================================================================
  Indiana Supreme Court decision: &quot;there is no right to reasonably resist unlawful entry by police officers&quot;. --- &quot;In reality, knock and announce raids aren't all that different than the very rare &quot;no knock&quot; raid.&quot;:¬†http://www.reddit.com/r/Libertarian/comments/hddts/marine_survives_two_tours_in_iraq_swat_kills_him/c1uj1nn
  href="http://reason.com/blog/2011/05/16/marine-survives-two-tours-in-i"
    tag="police-state politics"
  time="2011-05-18T00:03:54Z" 

Nassim N. Taleb Home &amp; Professional Page
================================================================================
  black swan theory; antifragility; small probabilities and model error¬†(convexity effects). &quot;All small probabilities are incomputable.&quot; &quot;There is no such thing as 'measurable risk' in the tails, no matter what model we use.&quot;
  href="http://www.fooledbyrandomness.com/" 
   tag="statistics finance"
  time="2011-04-27T15:56:54Z" 

CRAN Task Views 
================================================================================
  href="http://cran.r-project.org/web/views/" 
   tag="r-lang statistics programming"
  time="2011-04-26T04:58:23Z" 

CRAN Task View: Machine Learning &amp; Statistical Learning
================================================================================
  href="http://cran.r-project.org/web/views/MachineLearning.html"
   
  tag="statistics machine-learning ai r-lang programming"
  time="2011-04-26T04:57:00Z" 

Data Sets 
================================================================================
  href="http://www-users.cs.umn.edu/~kumar/dmbook/resources.htm"
   
  tag="data-mining datasets statistics machine-learning ai"
  time="2011-04-14T23:34:35Z" 

UCI Machine Learning Repository
================================================================================
  large collection of standard datasets for testing machine-learning algorithms
  href="http://archive.ics.uci.edu/ml/"  
  tag="machine-learning ai data-mining statistics datasets"
  time="2011-04-14T22:46:52Z" 

Snappy: a fast compressor/decompressor
================================================================================
  a compression/decompression library - aims for very high speeds and reasonable compression. - compresses at about 250+ MB/sec and decompresses at about 500+ MB/sec¬† - Snappy has previously been referred to as ‚ÄúZippy‚Äù in some presentations.
  href="http://code.google.com/p/snappy/"  
  tag="google programming oss algorithms"
  time="2011-04-12T18:33:19Z" 

How to smooth a plot in MATLAB? 
================================================================================
  href="http://stackoverflow.com/questions/1515977/how-to-smoothen-a-plot-in-matlab"
    tag="matlab statistics data-mining"
  time="2011-04-05T02:08:48Z" 

MIT OpenCourseWare
================================================================================
  Free video lectures.¬† See also: http://www.youtube.com/MIT¬†
  href="http://ocw.mit.edu/"  
  tag="learning engineering pedagogy video"
  time="2011-03-29T17:59:04Z" 

Stanford Engineering Everywhere
================================================================================
  Free video lectures.¬† See also: http://www.youtube.com/stanford¬†
  href="http://see.stanford.edu/"  
  tag="engineering learning pedagogy video"
  time="2011-03-29T17:52:51Z" 

Under-used features of Windows batch files
================================================================================
  - line continuation: ^ - open file manager in current dir: start .¬† - parsing with 'for' - substrings - path to script (as opposed to &quot;current directory&quot;): ~dp0 - wait N seconds using 'ping'
  href="http://stackoverflow.com/questions/245395/underused-features-of-windows-batch-files"
   
  tag="windows programming scripting cmd dos it"
  time="2011-03-24T18:10:47Z" 

DOS Batch files
================================================================================
  Windows CMD commands and their usage in .bat (.cmd) files.
  href="http://www.robvanderwoude.com/batchfiles.php" 
   tag="scripting windows programming it cmd dos"
  time="2011-03-24T18:01:42Z" 

DEA racketeering 
================================================================================
  href="http://www.reddit.com/r/politics/comments/g4zy6/the_dea_funds_itself_by_raiding_medical_marijuana/"
    tag="politics police-state"
  time="2011-03-16T17:18:23Z" 

Understanding Verilog Blocking and Nonblocking Assignments
================================================================================
  href="http://www.sutherland-hdl.com/papers/1996-CUG-presentation_nonblocking_assigns.pdf"
   
  tag="verilog engineering hardware-dev usf usf-csd filetype:pdf media:document"
  time="2011-03-09T03:14:40Z" 

How to write FSM in Verilog?
================================================================================
  Compare/contrast 3 approaches to implementing a FSM. 1. uses a function for the combinational part. next_state is a WIRE, concurrent assignment (not sequential).¬† 2. Two 'always' blocks: the comb. block is level-sensitive to certain signals, whereas the seq. block is edge-sensitive to the clock. next_state is a REG. 3. One 'always' block, edge-sensitive to clock only. No next_state variable. Signals checked before assigning state. Notice the sequential part 'always @ (posedge clock)' waits 1ns before assigning values (e.g., 'state &lt;= ¬†#1 ¬†next_state').¬†
  href="http://www.asic-world.com/tidbits/verilog_fsm.html"
   
  tag="verilog engineering hardware-dev usf usf-csd electronics"
  time="2011-03-09T03:03:31Z" 

College of Engineering Poster Printing Services
================================================================================
  href="http://www.eng.usf.edu/posters/"  
  tag="usf" time="2011-03-09T02:07:39Z" 

OpenCores
================================================================================
  Community for development of open-source digital hardware IP cores.
  href="http://opencores.org/"  
  tag="engineering electronics hardware-dev"
  time="2011-03-09T02:00:45Z" 

PS/2 interface :: Overview :: OpenCores
================================================================================
  verilog ps/2 driver
  href="http://opencores.org/project,ps2"  
  tag="usf usf-csd" time="2011-03-09T01:57:00Z" 

Logisim
================================================================================
  Logisim is an educational tool for designing and simulating digital logic circuits. Beats the hell out of Digital Works.
  href="http://ozark.hendrix.edu/~burch/logisim/" 
   tag="circuits electronics engineering pedagogy"
  time="2011-02-23T09:10:15Z" 

Command Line Gmail Using msmtp/mailx
================================================================================
  Send mail and attachments via heirloom-mailx or nail.
  href="http://klenwell.com/is/UbuntuCommandLineGmail" 
   tag="bash linux" time="2011-02-23T01:08:10Z" 

Google Prediction API
================================================================================
  The API accesses Google's machine learning algorithms to analyze your historic data and predict likely future outcomes. Recommendation systems¬† Spam detection Document and email classification Churn analysis Language identification
  href="https://developers.google.com/prediction/" 
   tag="google ai machine-learning data-mining"
  time="2011-02-23T00:55:56Z" 

StackExchange 
================================================================================
  href="http://stackexchange.com/"  
  tag="mega-search-engine" time="2011-02-22T22:41:53Z" 

Search Disqus comments using Google | Whole Map
================================================================================
  href="http://wholemap.com/blog/search-comments-on-disqus"
    tag="mega-search-engine"
  time="2011-02-22T22:41:28Z" 

Quora 
================================================================================
  href="http://www.quora.com/"  
  tag="mega-search-engine" time="2011-02-22T22:41:05Z" 

Brewer's CAP (Consistency, Availability, Partition Tolerance) Theorem
================================================================================
  &quot;whilst addressing the problems of scale might be an architectural concern, the initial discussions are not. They are business decisions.&quot;
  href="http://www.julianbrowne.com/article/viewer/brewers-cap-theorem"
    tag="web programming"
  time="2011-02-21T04:58:25Z" 

Khan Academy
================================================================================
  free, open source, video tutorials for math, science, statistics.¬†
  href="http://www.khanacademy.org/"  
  tag="learning mathematics" time="2011-02-14T01:46:34Z" 

What should a developer know before building a public web site?
================================================================================
  href="http://stackoverflow.com/questions/72394/what-should-a-developer-know-before-building-a-public-web-site"
    tag="seo programming web security"
  time="2011-02-11T13:36:36Z" 

Does the order of keywords matter in a page title?
================================================================================
  keyword _order_¬†matters.¬†putting important keywords closer to the beginning of a title improves SEO.
  href="http://webmasters.stackexchange.com/questions/6556/does-the-order-of-keywords-matter-in-a-page-title"
    tag="seo"
  time="2011-02-11T13:10:29Z" 

Weierstrass functions
================================================================================
  Very useful in EE for simulating noise on circuits. Famous for being continuous everywhere, but differentiable &quot;nowhere&quot;. As the graph is zoomed, it does not become smooth (or linear) as would a differentiable function.
  href="http://www.math.washington.edu/~conroy/general/weierstrass/weier.htm"
   
  tag="mathematics engineering electronics"
  time="2011-02-05T06:23:54Z" 

Investing Consultant Research 
================================================================================
  href="http://www.investingconsultantresearch.com/" 
   tag="blog finance" time="2011-02-01T23:44:57Z" 

The Markets Are Open 
================================================================================
  href="http://themarketsareopen.blogspot.com/" 
   tag="blog finance" time="2011-02-01T18:48:14Z" 

BoxCar2D: About
================================================================================
  The design of the chromosome is probably the most important step in making a successful genetic algorithm.At the end of each generation, pairs of parents are selected to produce the next generation.¬†
  href="http://www.boxcar2d.com/about.html" 
   tag="compsci algorithms data-mining"
  time="2011-02-01T05:59:50Z" 

orgtheory.net
================================================================================
  organization theory http://orgtheory.wordpress.com/
  href="http://orgtheory.net/"  
  tag="blog organization-theory economics"
  time="2011-01-20T08:18:24Z" 

http://timharford.com/2016/10/theres-magic-in-mess-why-you-should-embrace-a-disorderly-desk/
================================================================================
> Categorising documents of any kind is harder than it seems. ... Jorge Luis
> Borges once told of a fabled Chinese encyclopaedia, the “Celestial Emporium of
> Benevolent Knowledge”, which organised animals into categories such as: a)
> belonging to the emperor, c) tame, d) sucking pigs, f) fabulous, h) included
> in the present classification, and m) having just broken the water pitcher.

UNHOSTED - Freedom from web 2.0's monopoly platforms
================================================================================
  href="http://www.unhosted.org/"  
  tag="privacy web programming distributed-systems decentralization"
  time="2011-01-20T02:49:27Z" 

What is your most productive shortcut with Vim?
================================================================================
  href="http://stackoverflow.com/questions/1218390/what-is-your-most-productive-shortcut-with-vim/"
    tag="vim programming"
  time="2011-01-19T03:45:12Z" 

How to Track Ecommerce Transactions with Google Analytics
================================================================================
  href="http://blogs.sitepoint.com/2011/01/18/track-ecommerce-transactions-google-analytics-reports/"
    tag="ecommerce google webanalytics"
  time="2011-01-19T03:33:26Z" 

Research is communication
================================================================================
  Structure - Abstract (4 sentences) -¬†Introduction (1 page) - The problem (1 page) - My idea (2 pages) - The details (5 pages) - Related work (1-2 pages) - Conclusions and further work (0.5 pages)¬†¬† Abstract: Four sentences [Kent Beck] 1. State the problem 2. Say why it's an interesting problem 3. Say what your solution achieves 4. Say what follows from your solution
  href="http://research.microsoft.com/en-us/um/people/simonpj/papers/giving-a-talk/writing-a-paper-slides.pdf"
   
  tag="research engineering technical-writing filetype:pdf media:document"
  time="2011-01-17T08:40:52Z" 

Search engine gaming
================================================================================
  Human-readable paragraphs based on your keywords. Link a couple of times naturally to his site.Change description (automatically) every X number of page loads or Y number of weeks, whichever comes first.Do *not* have him do the same thing for you. Do this for him for ~6 months, then take it off of your site for a while and then have him do the same for you. You do *not* want to simply cross link.Content and context is important. You want the SE's to associate the link with the text around it.Doing this with a few friends (or a network of your own sites) can be effective if you don't tip the scale to spam. Keep it interesting for humans - measure the human CTR on the links, remove-low preforming paragraphs and add new ones in their place to refine the process. This is not only valuable for your community but this keeps the white hat on and Google happy. You also want a good human CTR, e.g. 1000 clicks for every auto-change.
  href="http://www.reddit.com/r/IAmA/comments/ev2zb/i_run_thathighcom_and_it_pays_my_rent_in_san/c1b7lp4"
    tag="seo"
  time="2011-01-12T23:30:23Z" 

Google Body - Google Labs 
================================================================================
  href="http://bodybrowser.googlelabs.com/" 
   tag="webgl google" time="2011-01-11T08:24:18Z" 

Learning WebGL 
================================================================================
  href="http://learningwebgl.com/"  
  tag="webgl programming" time="2011-01-11T08:19:49Z" 

Google Fusion Tables
================================================================================
  Visualize and publish your data as maps, timelines and charts¬† Host your data tables online¬† Combine data from multiple people¬†
  href="http://www.google.com/fusiontables" 
   tag="google tools statistics"
  time="2011-01-11T04:21:26Z" 

Data Liberation
================================================================================
  import/export data from any Google product.
  href="http://www.dataliberation.org/"  
  tag="google programming" time="2011-01-11T04:09:37Z" 

Macro Man 
================================================================================
  href="http://macro-man.blogspot.com/"  
  tag="blog finance forex" time="2011-01-11T02:19:20Z" 

Climate Audit 
================================================================================
  href="http://climateaudit.org/"  
  tag="science politics agw" time="2011-01-11T01:50:50Z" 

Charlie Rose - Janet Napolitano, Secretary, Department of Homeland Security
================================================================================
  &quot;I think the tighter we get on aviation, we have to also be thinking now about going on to mass transit or to train or maritime. &quot;
  href="http://www.charlierose.com/view/interview/11304"
    tag="politics police-state tsa"
  time="2011-01-11T01:32:06Z" 

Full-Body Scan Technology Deployed In Street-Roving Vans
================================================================================
  &quot;While the biggest buyer of AS&amp;E‚Äôs machines over the last seven years has been the Department of Defense operations in Afghanistan and Iraq, Reiss says law enforcement agencies have also deployed the vans to search for vehicle-based bombs in the U.S.&quot;
  href="http://blogs.forbes.com/andygreenberg/2010/08/24/full-body-scan-technology-deployed-in-street-roving-vans/"
    tag="politics police-state tsa"
  time="2011-01-11T01:02:42Z" 

EDITORIAL: TSA comes to your bus stop - Washington Times
================================================================================
  Washington's Metro Transit Police Department (MTPD) on Thursday announced new search policies developed in conjunction with the Transportation Security Administration (TSA). &quot;It is important to know that implementation of random bag inspection is not a reaction to any specific threats toward the Metro system,&quot; MTPD Chief Michael A. Taborn said.
  href="http://www.washingtontimes.com/news/2010/dec/17/tsa-comes-to-your-bus-stop/"
    tag="politics police-state tsa"
  time="2011-01-11T00:59:23Z" 


Spaced Repetition
================================================================================
https://ncase.me/remember/
tag="psychology neuroplasticity memory mnemonics anki spaced-repetition"
.
SPACED REPETITION is essentially "flashcards" with an emphasis on:
    1. time
    2. connections/mnemonics
       - best practice: "small (atomic), connected, meaningful"
.
* "Mnemonic" comes from "Mnemosyne" Greek "goddess of Memory" (mother of the Muses, "goddesses of inspiration").
* Hermann Ebbinghaus: you forget most of what you learn in the first 24 hours, then – if you don’t practice recall – your remaining memories decay exponentially.
* Memory “rate of decay” slows down each time you actively recall it. (versus passively re-reading it)

Augmenting Long-term Memory
================================================================================
http://augmentingcognition.com/ltm.html
tag="psychology neuroplasticity memory mnemonics anki spaced-repetition"
.
SYNTOPIC reading with Anki (grok an unfamiliar field/literature)
> Avoid orphan questions: questions too disconnected from your other interests lack the original motivating context.
> to really grok an unfamiliar field, you need to engage deeply with key papers – like the AlphaGo paper. What you get from deep engagement with important papers is more significant than any single fact or technique: you get a sense for what a powerful result in the field looks like. It helps you imbibe the healthiest norms and standards of the field. It helps you internalize how to ask good questions in the field, and how to put techniques together. You begin to understand what made something like AlphaGo a breakthrough – and also its limitations, and the sense in which it was really a natural evolution of the field. Such things aren't captured individually by any single Anki question. But they begin to be captured collectively by the questions one asks when engaged deeply enough with key papers.

AnkiWeb: Shared Decks
================================================================================
https://ankiweb.net/shared/decks/
tag="psychology neuroplasticity memory mnemonics anki spaced-repetition"
☃ german deck: https://ankiweb.net/shared/info/785874566


Every 7.8μs your computer’s memory has a hiccup
================================================================================
https://blog.cloudflare.com/every-7-8us-your-computers-memory-has-a-hiccup/
tag="dram hardware engineering performance computer telemetry measurement intrumentation statistics"
    Problem:    the data turns out to be very noisy. It's very hard to see if there is a noticeable delay related to the refresh cycles
    Solution:   Since we want to find a fixed-interval event, we can feed the data into the FFT (fast fourier transform) algorithm, which deciphers the underlying frequencies

Can You Build a Better Brain? - Newsweek
================================================================================
  neuroplasticity
  href="http://www.newsweek.com/2011/01/03/can-you-build-a-better-brain.html"
    tag="psychology"
  time="2011-01-04T10:21:18Z" 

Christopher Hitchens
================================================================================
  on social revolutions: &quot;Right away, one's in an argument, and there‚Äôs really nothing to do with utopia at all. And then temporary expedients become dogma very quickly--especially if they seem to work.&quot;
  href="http://reason.com/archives/2001/11/01/free-radical"
   
  tag="politics libertarian-role-models libertarianism"
  time="2011-01-04T07:14:52Z" 

Vietnam's Mammoth Cavern - Photo Gallery - National Geographic
================================================================================
  href="http://ngm.nationalgeographic.com/2011/01/largest-cave/peter-photography"
    tag="travel photography"
  time="2010-12-31T06:17:35Z" 

Panopticlick
================================================================================
  web browser identity, fingerprint.¬† browser configuration = web sites may be able to track you even if you disable cookies. see also:¬†http://hacks.mozilla.org/2010/03/privacy-related-changes-coming-to-css-vistited/
  href="http://panopticlick.eff.org/"  
  tag="privacy paranoia compsci statistics security fingerprinting webbrowser web"
  time="2010-12-21T06:33:11Z" 

How Teen Experiences Affect Your Brain for Life - Newsweek
================================================================================
  teen years are a period of crucial brain development. mid-20s, or later, for a brain to become fully developed. one of the last parts to mature is the frontal lobe ... modulating reward, planning, impulsiveness, attention, acceptable social behavior former adolescent drinkers had ... very exaggerated responses to mild stress. kids who smoked pot before age 16 had more lifelong cognitive problems than those who started smoking after 16
  href="http://www.newsweek.com/2010/12/16/the-kids-can-t-help-it.html"
    tag="psychology"
  time="2010-12-20T07:43:01Z" 

Google App Engine Pipeline API
================================================================================
  API for connecting complex, time-consuming workflows (including human tasks).¬†
  href="http://code.google.com/p/appengine-pipeline/" 
  
  tag="google google-appengine programming project-management"
  time="2010-12-20T06:09:29Z" 

Advancing in the Bash Shell
================================================================================
  bash history, bang bang !!, !$, :p
  href="http://samrowe.com/wordpress/advancing-in-the-bash-shell/"
    tag="bash linux"
  time="2010-12-10T08:46:27Z" 

Google Public Data Explorer
================================================================================
  Visualize/animate public data over a timeline. based on gapminder.org.
  href="http://www.google.com/publicdata/home" 
  
  tag="statistics information tools google data-mining"
  time="2010-12-10T04:21:25Z" 

Authorize.Net .NET SDK for AIM - Authorize.Net Developer Community
================================================================================
  href="http://community.developer.authorize.net/t5/The-Authorize-Net-Developer-Blog/The-Authorize-Net-NET-SDK-for-AIM/ba-p/7743"
    tag=".net programming ecommerce sdk"
  time="2010-12-07T19:51:10Z" 

Sua sponte: "on its own motion"
================================================================================
https://en.wikipedia.org/wiki/Sua_sponte
tag="concepts mental-model"

Simpson's paradox
================================================================================
  &amp;quot;an apparent paradox in which a correlation (trend) present in different groups is reversed when the groups are combined.&amp;quot; Q: why should a story, not data, dictate choices? A: the story encodes the causal relationships among the variables. Once we extract these relationships, we can represent them in a Causal Bayesian Network graph which we can test algorithmically. - Berkeley sex bias case - Kidney stone treatment
  href="http://en.wikipedia.org/wiki/Simpson_s_paradox"
   
  tag="paradox psychology mathematics statistics concepts mental-model"
  time="2010-11-30T05:00:20Z" 

DE(E)SU - Libert√© Linux
================================================================================
  secure, reliable, lightweight, and easy to use LiveUSB Linux distribution intended as a communication aid in hostile environments. installs as a regular directory on a USB/SD key, and after a single-click setup, boots on any desktop computer or laptop.
  href="http://dee.su/liberte"  
  tag="security paranoia privacy linux"
  time="2010-11-28T19:14:07Z" 

Seeking Alpha: Stock Market News, Opinion &amp; Analysis, Investing Ideas
================================================================================
  search for &quot;oversold&quot; or &quot;Contrarian Ideas&quot;
  href="http://seekingalpha.com/"  
  tag="blog finance" time="2010-11-11T01:43:59Z" 

Procrastination, hyperbolic discounting
================================================================================
  Misconception: You procrastinate because you are lazy and can‚Äôt manage your time well. Truth: Procrastination is fueled by weakness in the face of impulse and a failure to think about thinking. Now-you must trick future-you into doing what is right for both parties. ...why you keep adding movies you will never watch to your growing collection of future rentals ... the same reason you believe you will eventually do what‚Äôs best for yourself in all the other parts of your life, but rarely do. present bias = being unable to grasp that what you want will change over time hyperbolic discounting = the tendency to get more rational when you are forced to wait
  href="http://youarenotsosmart.com/2010/10/27/procrastination/"
    tag="psychology project-management"
  time="2010-10-28T11:47:52Z" 

Firesheep ... HTTP Session Hijacking
================================================================================
  Some sites support full encryption everywhere, but don‚Äôt implement it properly by failing to set the ‚ÄúSecure‚Äù flag on authentication cookies, negating most of the benefits ... any time you type the URL ... without explicitly typing https:// ... you will inadvertently leak your cookies with that first request, prior to being redirected to the HTTPS page. ... You can‚Äôt simply avoid visiting the sites that are being attacked here. There‚Äôs an enormous amount of mixed content on the web today, such as the Facebook ‚ÄúLike‚Äù button... ... People forget things. It‚Äôs easy to be logged in to many of these services, sleep your laptop, and wake it up somewhere where it will instantly ... start spewing your cookies over the air. ... A password-protected (WPA2) wireless network or even a wired network just requires that attackers perform one more step ... ARP poisoning or DNS spoofing, neither of which are difficult to carry out. Go and download Cain &amp; Abel and try it out on your network...
  href="http://codebutler.com/firesheep-a-day-later" 
   tag="privacy paranoia security"
  time="2010-10-26T21:49:51Z" 

7 tricks to simplify your programs with LINQ
================================================================================
  int[] c = Enumerable.Range(0, 10).Select(i =&gt; 100 + 10 * i).ToArray(); var randomSeq = Enumerable.Repeat(0, N).Select(i =&gt; rand.Next()); IEnumerable&lt;object&gt; objEnumerable = strEnumerable.Cast&lt;object&gt;(); You could construct an array of length 1, but I prefer the LINQ Repeat operator: IEnumerable&lt;int&gt; seq = Enumerable.Repeat(myValue, 1); Iterate over all subsets of a sequence...
  href="http://igoro.com/archive/7-tricks-to-simplify-your-programs-with-linq/"
    tag="c# linq .net programming"
  time="2010-10-26T03:01:04Z" 

Less Wrong 
================================================================================
  href="http://lesswrong.com/"  
  tag="blog economics" time="2010-10-26T02:36:13Z" 

Overcoming Bias 
================================================================================
  href="http://www.overcomingbias.com/"  
  tag="blog economics" time="2010-10-26T02:35:20Z" 

SEO Is Mostly Quack Science
================================================================================
  &quot;Non-brain-damaged web design and link building are 100% of SEO. Anyone who tells you different is a quack that is only trying to separate you from your money.&quot;
  href="http://teddziuba.com/2010/06/seo-is-mostly-quack-science.html"
    tag="seo"
  time="2010-10-25T00:03:02Z" 

Vi Cheat Sheet 
================================================================================
  href="http://www.lagmonster.org/docs/vi.html" 
   tag="vim" time="2010-10-24T07:14:16Z" 

Power Posing: Fake It Until You Make It
================================================================================
  holding one's body in expansive, &quot;high-power&quot; poses for as little as two minutes stimulates higher levels of testosterone ... and lower levels of cortisol.
  href="http://hbswk.hbs.edu/item/6461.html" 
   tag="psychology" time="2010-10-13T18:28:09Z" 

Feds are monitoring and tracking redditors for their comments, or &quot;How I learned to STFU and love the police state&quot;.
================================================================================
  href="http://www.reddit.com/r/Libertarian/comments/dot9b/feds_are_monitoring_and_tracking_redditors_for/"
    tag="politics police-state"
  time="2010-10-10T21:45:34Z" 

Redditor arrested a few months ago for filming the police. ... The video and audio was tampered with (erased) by the feds, but recovered with open source software
================================================================================
  href="http://www.reddit.com/r/reddit.com/comments/dhf6y/the_redditor_arrested_a_few_months_ago_for/"
    tag="police-state politics"
  time="2010-10-10T21:44:34Z" 

Simulate a Windows Service using ASP.NET to run scheduled jobs
================================================================================
  A hack to use ASP.NET cache expiration to schedule a task.
  href="http://www.codeproject.com/KB/aspnet/ASPNETService.aspx"
    tag="asp.net programming"
  time="2010-10-04T05:28:31Z" 

Mathematics formula sheet 
================================================================================
  href="http://www.tug.org/texshowcase/cheat.pdf" 
   tag="mathematics filetype:pdf media:document"
  time="2010-10-04T03:42:15Z" 

IEEE Computer Society Style Guide: References, Citations
================================================================================
  href="http://www.computer.org/portal/web/publications/style_refs"
    tag="technical-writing"
  time="2010-10-03T18:51:35Z" 

Basic Concepts of Mathematics - by Elias Zakon
================================================================================
  This book gives students the skills they need to succeed in the first courses in Real Analysis (it is designed specifically to prepare students for the author's Mathematical Analysis I and Mathematical Analysis II) and Abstract Algebra/Modern Algebra. Students who plan to advance to upper-level classes in computer science (discrete structures, algorithms, computability, automata theory, ...), economics, or electrical and computer engineering (signal and image processing, AI, circuit design, ...) will benefit from mastering the material in this text.
  href="http://www.trillia.com/zakon1.html" 
   tag="mathematics books"
  time="2010-09-19T22:27:42Z" 

Anonymous Pro 
================================================================================
  href="http://www.ms-studio.com/FontSales/anonymouspro.html"
    tag="programming font"
  time="2010-09-02T04:13:13Z" 

How to Think (Technology Review: Blogs: Ed Boyden's blog)
================================================================================
  &quot;1. Synthesize new ideas constantly. Never read passively. Annotate, model, think, and synthesize while you read...&quot; &quot;9. Document everything obsessively. If you don't record it, it may never have an impact on the world. Much of creativity is learning how to see things properly...&quot; &quot;time management... logarithmic time planning, in which events that are close at hand are scheduled with finer resolution than events that are far off.&quot;
  href="http://www.technologyreview.com/blog/boyden/21925/"
    tag="learning psychology"
  time="2010-09-01T00:13:29Z" 

Regexes For Life 
================================================================================
  href="http://rxfl.wordpress.com/"  
  tag="blog" time="2010-08-31T01:49:36Z" 

&gt;&gt; RIGHTSHIFT 
================================================================================
  href="http://rightshift.info/"  
  tag="blog" time="2010-08-31T01:33:26Z" 

Moserware 
================================================================================
  href="http://www.moserware.com/"  
  tag="blog" time="2010-08-31T01:32:17Z" 

Miguel de Icaza 
================================================================================
  href="http://tirania.org/blog/"  
  tag="blog" time="2010-08-31T01:20:33Z" 

Unqualified Reservations 
================================================================================
  href="http://unqualified-reservations.blogspot.com/" 
   tag="blog" time="2010-08-31T01:20:07Z" 

Labnotes 
================================================================================
  href="http://labnotes.org/"   tag="blog"
  time="2010-08-31T00:56:40Z" 

Chad Perrin: SOB 
================================================================================
  href="http://sob.apotheon.org/"  
  tag="blog" time="2010-08-31T00:48:41Z" 

Parosproxy.org - Web Application Security
================================================================================
  &quot;Through Paros's proxy nature, all HTTP and HTTPS data between server and client, including cookies and form fields, can be intercepted and modified.&quot;
  href="http://www.parosproxy.org/"  
  tag="paranoia security" time="2010-08-30T23:31:52Z" 

RetailMeNot.com - Coupon codes and discounts for 65,000 online stores!
================================================================================
  href="http://www.retailmenot.com/"  
  tag="haggle shopping" time="2010-08-27T07:18:24Z" 

Restaurant.com Coupon Codes - all coupons, discounts and promo codes ...
================================================================================
  restaurant coupons
  href="http://www.retailmenot.com/view/restaurant.com"
    tag="haggle food"
  time="2010-08-27T07:17:04Z" 

Really Really Free Market
================================================================================
  also: http://www.reallyreallyfree.org/ &quot;The NYC Really Really Free Market happens every last Sunday of every month! Located @ 55 Washington Square South at the Judson Memorial Church.&quot; http://www.facebook.com/pages/New-York-NY/Really-Really-Free-Market-NYC/288012211374
  href="http://en.wikipedia.org/wiki/Really_Really_Free_Market"
    tag="haggle shopping freeganism barter-economy"
  time="2010-08-27T06:20:05Z" 

Second-order simulacra
================================================================================
  A system whose legitimacy is implied by its complexity. E.g., psychology/psychoanalysis, alchemy, astrology, chiropractic are presumed valuable because they are complicated and have experts. The foundation of the system is not questioned because people are too busy debating the higher-order results of the system.
  href="http://en.wikipedia.org/wiki/Second-order_simulacra"
    tag="concepts psychology mental-model"
  time="2010-08-23T06:16:25Z" 

Blue Brain Project
================================================================================
attempt to reverse-engineer the mammalian brain, in order to understand brain function and dysfunction through detailed simulations.
https://www.epfl.ch/research/domains/bluebrain/
tag="ai psychology"

Antarctic Peninsula
================================================================================
  vacation to the Antarctic Peninsula in the Summer of 2008-9
  href="http://antarctic.fury.com/"  
  tag="travel" time="2010-08-09T06:54:31Z" 

The Cognitive Benefits of Nature : The Frontal Cortex
================================================================================
  &quot;interacting with nature ... improves cognitive function&quot;
  href="http://scienceblogs.com/cortex/2008/11/the_cognitive_benefits_of_natu.php"
    tag="psychology health"
  time="2010-07-15T00:39:17Z" 

App Inventor for Android 
================================================================================
  href="http://appinventor.googlelabs.com/about/" 
   tag="android programming"
  time="2010-07-12T16:23:01Z" 

As a 20-year-old female, I spent 4 months wandering through Indonesia ...
================================================================================
"friendly and safe people, perfect blue-green water, rainforests and a dirth of tourists".
"Bahasa Indonesia is also one of the easiest languages in the world".
Gear: http://www.reddit.com/r/IAmA/comments/cg60e/as_a_20yearold_female_i_spent_4_months_wandering/c0scahg &quot;STAY AWAY FROM KUTA. If you must go, just visit and then leave.&quot;. Cobra blood.
href="http://www.reddit.com/r/IAmA/comments/cg60e/as_a_20yearold_female_i_spent_4_months_wandering/"
tag="travel"

Lending Club Review 
================================================================================
  href="http://www.debtkid.com/lendingclub-overview" 
   tag="investment finance"
  time="2010-06-25T06:17:09Z" 

John Mackey - The New Yorker
================================================================================
  CEO of Whole Foods.
  href="http://www.newyorker.com/reporting/2010/01/04/100104fa_fact_paumgarten"
   
  tag="libertarian-role-models entrepreneurs"
  time="2010-06-25T06:03:27Z" 

Instant Verify Identity Verification - LexisNexis
================================================================================
  FraudPoint and Instant Verify make it very easy to go from an email address, name, basic but not identifiable information to being able to see what their SSN is.
  href="http://www.lexisnexis.com/risk/solutions/instant-identity-verification.aspx"
    tag="paranoia privacy"
  time="2010-06-25T02:23:07Z" 

FraudPoint Fraud Prevention Solution - LexisNexis
================================================================================
  FraudPoint and Instant Verify make it very easy to go from an email address, name, basic but not identifiable information to being able to see what their SSN is.
  href="http://www.lexisnexis.com/risk/solutions/fraudpoint-fraud-prevention.aspx"
    tag="paranoia privacy"
  time="2010-06-25T02:23:03Z" 

Lithium: Could It Become the Hottest Commodity of All?
================================================================================
  http://www.moneyweek.com/investments/commodities/two-ways-to-play-the-lithium-boom.aspx Sociedad Quimica y Minera NYSE:SQM (ADR) http://www.todaysfinancialnews.com/investment-strategies/lithium-the-commodity-with-a-profitable-future-7284.html JOHNSON CONTROL IND. [JCI]. &quot;building one of the largest lithium battery plants in the u.s.&quot;
  href="http://www.energyinvestmentstrategies.com/2008/02/02/lithium-could-it-become-the-hottest-commodity-of-all/"
    tag="stock-picks finance"
  time="2010-06-09T22:39:41Z" 

Al Gore, Kleiner Perkins, venture capital
================================================================================
  10 of Kleiner's &quot;green&quot; investment picks: http://money.cnn.com/galleries/2007/fortune/0711/gallery.kleiner_gore.fortune/index.html Silver Spring Networks: http://www.telegraph.co.uk/earth/energy/6491195/Al-Gore-could-become-worlds-first-carbon-billionaire.html
  href="http://money.cnn.com/2007/11/11/news/newsmakers/gore_kleiner.fortune/index.htm"
    tag="stock-picks finance"
  time="2010-06-09T02:02:48Z" 

Getting the most out of your Android phone
================================================================================
  href="http://www.reddit.com/r/Android/comments/ccuxg/andreddit_lets_collaborate_to_make_a_getting_the/"
    tag="android"
  time="2010-06-09T00:30:17Z" 

Kids for cash scandal
================================================================================
  transcript: http://www.reddit.com/r/politics/comments/c3nmv/two_astoundingly_corrupt_pennsylvania_judges_who/c0pxqs3
  href="http://en.wikipedia.org/wiki/Kids_for_cash_scandal"
    tag="corruption politics"
  time="2010-05-13T23:19:22Z" 

Motley Fool: Rick Aristotle Munarriz's Bio and Archive
================================================================================
  href="http://www.fool.com/about/staff/rickaristotlemunarriz/author.htm"
    tag="blog finance"
  time="2010-05-10T18:55:56Z" 

Nootropic
================================================================================
  smart drugs, memory enhancers, and cognitive enhancers: drugs, supplements, nutraceuticals, and functional foods that are purported to improve mental functions.
  href="http://en.wikipedia.org/wiki/Nootropic" 
   tag="psychology learning physiology" time="2010-05-07T21:33:38Z" 

FRPAX Franklin PA Tax-Free Income A
================================================================================
  href="http://quote.morningstar.com/fund/f.aspx?t=FRPAX"
    tag="stock-picks finance"
  time="2010-05-01T01:38:56Z" 

Southern Company SO 
================================================================================
  href="http://quote.morningstar.com/stock/s.aspx?t=SO"
    tag="stock-picks finance"
  time="2010-05-01T01:38:18Z" 

Fairholme FAIRX 
================================================================================
  href="http://quote.morningstar.com/fund/f.aspx?t=FAIRX"
    tag="stock-picks finance"
  time="2010-05-01T01:37:45Z" 

iSendr - On Demand P2P File Transfers
================================================================================
  href="http://www.isendr.com/"  
  tag="tools" time="2010-04-23T17:17:25Z" 

FilesOverMiles: send large files directly between computers for free
================================================================================
  p2p file-sharing.
  href="http://www.filesovermiles.com/"  
  tag="tools" time="2010-04-23T17:16:53Z" 

Vice Guide to North Korea | VBS.TV
================================================================================
  href="http://www.vbs.tv/watch/the-vice-guide-to-travel/vice-guide-to-north-korea-1-of-3"
    tag="politics"
  time="2010-04-18T22:40:10Z" 

Forex Trading Training | Forex Buy Sell Signals | Forex Market Analysis
================================================================================
  href="http://www.forexoma.com/"  
  tag="forex finance" time="2010-04-06T20:21:03Z" 

Confessions of a Car Salesman
================================================================================
  selling rooms are bugged (phones have intercoms). Buyers are so eager to get out of their old car and into a new one, they overlook the true value of the trade-in. The dealership is well aware of this weakness and exploits it. see also: http://www.reddit.com/r/business/comments/blaki/11_of_the_top_car_deal_tricks_to_make_sure_they/
  href="http://www.edmunds.com/advice/buying/articles/42962/article.html"
    tag="negotiation thrift"
  time="2010-04-02T17:39:07Z" 


How To Be Successful
================================================================================
tag="career startup entrepreneurship"
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

Don't Call Yourself A Programmer, And Other Career Advice
================================================================================
https://www.kalzumeus.com/2011/10/28/dont-call-yourself-a-programmer/
tag="negotiation business career compensation"
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

Salary Negotiation: Make More Money, Be More Valued
================================================================================
https://www.kalzumeus.com/2012/01/23/salary-negotiation/
tag="negotiation salary business hiring career game-theory compensation"

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

How Not to Bomb Your Offer Negotiation
================================================================================
https://haseebq.com/my-ten-rules-for-negotiating-a-job-offer/
https://haseebq.com/how-not-to-bomb-your-offer-negotiation/
tag="negotiation salary business hiring career game-theory compensation"

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

BLACK FLAMINGO: im coco for some choco chips!
================================================================================
  Ingredients: 40 saltine crackers 1 cup of rolled oats 1/2 cup of applesauce 1/4 cup of vegetable oil 3/4 cup of hazelnut milk 1/4 cup of agave nectar 1 tsp of cinnamon 1/4 cup of stevia 1 tbs of corn starch 1 tbs pure cocoa powder 1/2 cup dark choc chips 1/4 cup earth balance Directions: 0. preheat oven to 350 deg 1. crush saltine crackers into fine pieces 2. mix in oats, applesauce, and the rest of the ingredients. 3. fold in the oil and milk until it becomes a dough 4. spread out in cooking tin 5. bake for 24 minutes
  href="http://ablackflamingo.blogspot.com/2010/03/im-coco-for-some-choco-chips.html"
    tag="recipes"
  time="2010-03-31T20:44:57Z" 

Painless Functional Specifications - Part 2: What's a Spec? - Joel on Software
================================================================================
  Specs have a disclaimer, one author, scenarios, nongoals, an overview and a lot of details. It's ok to have open issues. Text for particular audiences go into side notes. Specs need to stay alive.
  href="http://www.joelonsoftware.com/articles/fog0000000035.html"
    tag="programming project-management"
  time="2010-03-31T02:37:14Z" 

&quot;I can say with some authority that PeerGaurdian never worked.&quot;
================================================================================
  &quot;There were very specific criteria that needed to be met by the person. Mainly an ISP that would play ball, this was a habitual seeder, meaning we were able to obtain a small % of at least 500-1000 different titles from that very person, and they had to be sharing a certain number of specifc titles.&quot; &quot;For the longest time people couldn't figure out why the download would stop at 98% and never finish, but it was because they had just spent the time downloading a fake file. That never happens on NNTP. ... We can't see who is downloading a file from some NNTP server, the only thing we could ever do was issue DMCA notices to the server admins to remove files when we found them, but those files would only be gone for a few minutes before someone would put them right back on.&quot;
  href="http://www.reddit.com/r/reddit.com/comments/9ubff/because_no_one_told_me_i_present_peerblock/c0ehd67"
    tag="paranoia security privacy"
  time="2010-03-31T00:31:43Z" 

Photoshop's CAF (content-aware fill) - unbelievable? Not quite.
================================================================================
  http://www.youtube.com/watch?v=NH0aEp1oDOI http://www.logarithmic.net/pfh/resynthesizer http://www.reddit.com/r/linux/comments/bipgn/photoshops_caf_contentaware_fill_unbelievable_not/
  href="http://o3.tumblr.com/post/470608946/photoshops-caf-content-aware-fill-unbelievable"
    tag="gimp graphic-design"
  time="2010-03-26T20:55:52Z" 

Elance | Outsource to freelancers, professionals, experts
================================================================================
  href="http://www.elance.com/"  
  tag="freelancing contracting" time="2010-03-24T05:25:01Z" 

Guru.com ‚Äì Find Freelancers for Hire. Get Your Project Done.
================================================================================
  href="http://www.guru.com/"  
  tag="freelancing contracting" time="2010-03-24T05:24:36Z" 

odesk.com: Outsource to Freelancers, IT Companies, Programmers, Web Designers
================================================================================
  href="http://www.odesk.com/"  
  tag="contracting freelancing" time="2010-03-24T05:17:20Z" 

Rent A Coder: How Software Gets Done
================================================================================
  href="http://www.rentacoder.com/"  
  tag="freelancing contracting" time="2010-03-24T05:11:39Z" 

IamA Top Coder at Rentacoder.com 
================================================================================
  href="http://www.reddit.com/r/iama/comments/a2485" 
   tag="freelancing contracting"
  time="2010-03-24T05:10:41Z" 

Irrational fears give nuclear power a bad name, says Oxford scientist
================================================================================
  href="http://www.reddit.com/r/science/comments/ao6gl/irrational_fears_give_nuclear_power_a_bad_name/"
    tag="science politics energy nuclear"
  time="2010-03-20T01:02:04Z" 

JQuery Cycle Plugin
================================================================================
  slideshow plugin that supports many different types of transition effects.
  href="http://malsup.com/jquery/cycle/"  
  tag="jquery programming" time="2010-03-16T06:55:35Z" 

Directed Edge - Blog - On Building a Stupidly Fast Graph Database
================================================================================
  href="http://blog.directededge.com/2009/02/27/on-building-a-stupidly-fast-graph-database/"
    tag="compsci todo"
  time="2010-03-14T01:32:05Z" 

Moserware: Wetware Refactorings 
================================================================================
  href="http://www.moserware.com/2009/01/wetware-refactorings.html"
    tag="todo learning psychology"
  time="2010-03-14T01:26:26Z" 


================================================================================
20200208
PyRobot: open source robotics platform
https://www.pyrobot.org/
tag="diy-project electronics engineering programming facebook"
getting a robot, current price points: https://news.ycombinator.com/item?id=22212035

================================================================================
20100313
en/MikroKopter - Wiki: MikroKopter.de
http://www.mikrokopter.de/ucwiki/en/MikroKopter
tag="diy-project electronics"
HexaKopter 6-propeller helicopter. ~1200 euros.

A Visual Git Reference 
================================================================================
  href="http://marklodato.github.com/visual-git-guide/"
    tag="git dvcs programming"
  time="2010-02-26T06:14:30Z" 

Git for Plan 9: git/fs
================================================================================
https://lobste.rs/s/bpzl12/git_fs_native_git_implementation_for_plan
https://bitbucket.org/oridb/git9
tag="git dvcs programming protocol"
Plan 9 C implementation of git file formats and wire formats.

HashRocket MSA (Master Services Agreement) - Obie Fernandez: (MSA Series #3) Work Provisions
================================================================================
  &quot;I prefer so-called &quot;Time and Materials&quot; (T&amp;M) engagements, and with a good MSA you can usually fit your SOW onto one page.&quot; http://blog.obiefernandez.com/content/2008/09/master-services-agreement-part-1.html http://blog.obiefernandez.com/content/2008/10/msa-series-2-cooperation-and-reliance.html http://blog.obiefernandez.com/content/2008/12/msa-series-3-work-provisions.html
  href="http://blog.obiefernandez.com/content/2008/12/msa-series-3-work-provisions.html"
    tag="programming contracting"
  time="2010-02-12T21:54:20Z" 

ASP.NET Chart Control - ScottGu's Blog
================================================================================
  href="http://weblogs.asp.net/scottgu/archive/2008/11/24/new-asp-net-charting-control-lt-asp-chart-runat-quot-server-quot-gt.aspx"
    tag=".net asp.net programming"
  time="2010-02-12T21:50:45Z" 

Google Chart Tools API 
================================================================================
  href="https://developers.google.com/chart/" 
   tag="web programming google"
  time="2010-02-12T21:49:18Z" 

Derek Powazek - Spammers, Evildoers, and Opportunists
================================================================================
  &quot;Search Engine Optimization is not a legitimate form of marketing. ... If someone charges you for SEO, you have been conned.&quot; &quot;The good advice is obvious, the rest doesn‚Äôt work.&quot; &quot;If [Google] determine that you‚Äôve been acting in bad faith (like hiding links or keywords or other deceptive practices) ... a temporary gain may result in a lifetime ban.&quot;
  href="http://powazek.com/posts/2090"  
  tag="seo" time="2010-02-10T21:24:07Z" 

Microsoft.VisualBasic.FileIO.TextFieldParser Class
================================================================================
  .NET CSV, tab delimited, and fixed-width text parser.
  href="http://msdn.microsoft.com/en-us/library/microsoft.visualbasic.fileio.textfieldparser.aspx"
    tag="programming .net"
  time="2010-02-02T06:10:53Z" 

Are Machine-Learned Models Prone to Catastrophic Errors?
================================================================================
  Nassim Taleb divides phenomena into two classes: Mediocristan, consisting of phenomena that fit the bell curve model, such as games of chance, height and weight in humans, and so on. Here future observations can be predicted by extrapolating from variations in statistics based on past observation (for example, sample means and standard deviations). Extremistan, consisting of phenomena that don't fit the bell curve model, such as the search queries, the stock market, the length of wars, and so on. Sometimes such phenomena can sometimes be modeled using power laws or fractal distributions, and sometimes not. In many cases, the very notion of a standard deviation is meaningless. The current generation of machine learning algorithms can work well in Mediocristan but not in Extremistan. The very metrics these algorithms use, such as precision, recall, and root-mean square error (RMSE), make sense only in Mediocristan.
  href="http://anand.typepad.com/datawocky/2008/05/are-human-experts-less-prone-to-catastrophic-errors-than-machine-learned-models.html"
   
  tag="compsci ai psychology machine-learning"
  time="2010-02-02T05:07:06Z" 

optionshouse.com - Stock Option Trading Broker, Online Options Trading Platform ...
================================================================================
  A powerful, virtual platform to test your stock and options trades.
  href="http://www.optionshouse.com/"  
  tag="investment finance" time="2010-01-29T21:42:45Z" 

Making Evidyon
================================================================================
  Open source C++ (Visual Studio 2008) MMORPG. http://www.reddit.com/r/programming/comments/auhiv/evidyon_goes_open_source_get_a_free_copy_of/
  href="http://unseenstudios.com/making-evidyon/" 
   tag="game-dev programming"
  time="2010-01-28T00:51:34Z" 

FINVIZ.com - Stock Screener
================================================================================
  technical indicators, insider trading.
   href="http://finviz.com/"
    tag="investment finance"
  time="2010-01-19T23:04:06Z" 

Journey of an Absolute Rookie: Paintings and Sketches - ConceptArt.org
================================================================================
  daily practice turns a novice into very good artist in a matter of months.
  href="http://www.conceptart.org/forums/showthread.php?t=870"
    tag="learning art"
  time="2010-01-14T17:27:23Z" 

The 31 Places to Go in 2010 - NYTimes.com
================================================================================
  href="http://www.nytimes.com/2010/01/10/travel/10places.html"
    tag="travel"
  time="2010-01-12T18:41:20Z" 

Best of VIM Tips, gVIM's Key Features zzapper
================================================================================
  href="http://rayninfo.co.uk/vimtips.html" 
   tag="vim programming" time="2010-01-07T22:55:02Z" 

Don't vote. Play the lottery instead. - By Steven E. Landsburg
================================================================================
  &amp;quot;If Kerry (or Bush) has just a slight edge, so that each of your fellow voters has a 51 percent likelihood of voting for him, then your chance of casting the tiebreaker is about one in 10^1046‚Äîapproximately the same chance you have of winning the Powerball jackpot 128 times in a row.&amp;quot;
  href="http://www.slate.com/id/2107240/"  
  tag="politics voting" time="2009-12-06T20:49:59Z" 


What is the probability your vote will make a difference?
================================================================================
http://www.nber.org/papers/w15220.pdf
tag="politics statistics"
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


Eastern Eyes
================================================================================
  &quot;When you have to manufacture your own bricks in order to build your own house, you are living in a society that has no effective division of labor.&quot;
  href="http://books.stpeter.im/rand/eyes.html" 
   tag="politics" time="2009-12-03T07:48:14Z" 

.NET Debugging 101 with Tess Ferrandez
================================================================================
  href="http://www.hanselminutes.com/default.aspx?showID=204"
    tag=".net debug todo"
  time="2009-11-22T20:57:29Z" 

The Dead Zone: The Implicit Marginal Tax Rate
================================================================================
  &quot;until you get past $40,000 a year, any raise might actually sink you deeper into poverty&quot;
  href="http://mises.org/daily/3822"  
  tag="economics politics todo" time="2009-11-22T20:55:53Z" 

The Henry Ford of Heart Surgery
================================================================================
  &quot;In India, a Factory Model for Hospitals Is Cutting Costs and Yielding Profits&quot;
  href="http://online.wsj.com/article/SB125875892887958111.html"
    tag="economics todo"
  time="2009-11-22T20:50:34Z" 

Cheap Fusion Power: Dr. Bussard's talk at Google
================================================================================
  Dr. Robert Bussard http://en.wikipedia.org/wiki/Bussard ... http://www.talk-polywell.org/bb/index.php
  href="http://video.google.com/videoplay?docid=1996321846673788606"
    tag="todo science energy nuclear"
  time="2009-11-16T03:43:42Z" 

The Eternal Value of Privacy - Bruce Schneier
================================================================================
  &quot;If I'm not doing anything wrong, then you have no cause to watch me.&quot; &quot;Because the government gets to define what's wrong, and they keep changing the definition.&quot; &quot;Because you might do something wrong with my information.&quot; ... The real choice is liberty versus control. ... Widespread police surveillance is the very definition of a police state.
  href="http://www.wired.com/politics/security/commentary/securitymatters/2006/05/70886"
    tag="politics privacy"
  time="2009-11-16T00:03:02Z" 

================================================================================
20091018
1000mm Quad Copter Design - RC Groups
http://www.rcgroups.com/forums/showthread.php?t=768115
tag="engineering electronics diy-project"

Vitamin D &quot;may vanquish cancer and heart disease ... autoimmune disease (rheumatoid arthritis, lupus), diminish the occurrence of diabetes, reduce obesity, treat multiple sclerosis, osteoporosis, Parkinson‚Äôs disease ... high blood pressure ... the comm...
================================================================================
  It‚Äôs difficult for most people to get optimal amounts of vitamin D. The diet, at best, will only provide a few hundred units of vitamin D. Milk is fortified with synthetic vitamin D2, which is not nearly as potent as natural D3, which is used in most dietary supplements. A glass of milk provides only 100 IU (2.5 micrograms). Fifteen minutes of sun exposure to 40-percent of the body is suggested daily for fair-skinned individuals. mortality rates for melanoma rose steeply after sunscreens came into common use, not before. Sunscreen lotion blocks the vitamin D-producing UV-B rays, while allowing the deeper-penetrating, cancer-causing UV-A rays to burn the skin. Many health food stores stock 1000 IU vitamin D pills. Most multivitamins provide no more than 400 IU .
  href="http://www.lewrockwell.com/sardi/sardi70.html" 
   tag="health" time="2009-10-08T21:33:15Z" 

Innovative Minds Don't Think Alike
================================================================================
  the &quot;curse of knowledge&quot;. &quot;It‚Äôs why engineers design products ultimately useful only to other engineers. It‚Äôs why managers have trouble convincing the rank and file to adopt new processes.&quot;
  href="http://www.nytimes.com/2007/12/30/business/30know.html"
  tag="learning engineering psychology business"
  time="2009-10-07T22:20:27Z" 

A Stick Figure Guide to the Advanced Encryption Standard (AES)
================================================================================
  good explanation of AES Rijndael.
  href="http://www.moserware.com/2009/09/stick-figure-guide-to-advanced.html"
    tag="compsci"
  time="2009-09-23T03:12:34Z" 

African American lives with middle class black families to study low test scores‚Äîis vilified for what he finds.
================================================================================
  &quot;Their project yielded an unexpected conclusion: It wasn't socioeconomics, school funding, or racism, that accounted for the students' poor academic performance; it was their own attitudes, and those of their parents.&quot;
  href="http://www.reddit.com/r/Economics/comments/9mg0f/african_american_lives_with_middle_class_black/"
    tag="politics"
  time="2009-09-21T05:38:30Z" 

The RFP Database: government, corporate, and non-profit Requests for Proposals
================================================================================
  You can gain credits by uploading RFPs to the website. Where can I find more RFPs? One of the easiest ways to find RFPs is by logging in and using our internet rfp search area. Or do a web search for &quot;tampa procurement&quot; or &quot;rfp 2009 web&quot; or &quot;rfp 2009 programming&quot;.
  href="http://www.rfpdb.com/"  
  tag="rfp contracting" time="2009-09-15T21:51:20Z" 

littlefs: fail-safe filesystem designed for microcontrollers
================================================================================
https://github.com/ARMmbed/littlefs
tag="software programming embedded soc microcontrollers filesystem tools"

Tahoe-LAFS: a secure, decentralized, fault-tolerant filesystem.
================================================================================
  The &quot;Tahoe&quot; project is a distributed filesystem, which safely stores files on multiple machines to protect against hardware failures. Cryptographic tools are used to ensure integrity and confidentiality, and a decentralized architecture minimizes single points of failure. http://allmydata.org/~warner/pycon-tahoe.html
  href="http://allmydata.org/"  
  tag="linux privacy security paranoia"
  time="2009-09-09T16:04:25Z" 

Bulgarian Split Squat 
================================================================================
  href="http://www.youtube.com/watch?v=q_Q8FKO7Ueg" 
   tag="exercise health" time="2009-09-09T05:44:08Z" 

Elon Musk - Wikipedia, the free encyclopedia
================================================================================
  Zip2, PayPal, SpaceX, Tesla Motors, SolarCity. &quot;SpaceX was awarded a $1.6 billion NASA contract for 12 flights of their Falcon 9 rocket and Dragon spacecraft to the International Space Station, replacing the Space Shuttle after it retires in 2010.&quot;
  href="http://en.wikipedia.org/wiki/Elon_Musk" 
   tag="entrepreneurs" time="2009-09-01T03:25:01Z" 

Starlink satellite tracker
================================================================================
https://james.darpinian.com/satellites/
tag="space spacex science satellites starlink isp internet network"
Tells you when to go outside to see satellites as they pass overhead.

How to Debug Bash Scripts 
================================================================================
  href="http://aymanh.com/how-debug-bash-scripts" 
   tag="bash programming linux"
  time="2009-08-25T15:49:00Z" 

Code generation with X-Macros in C :: The Brush Blog
================================================================================
  href="http://blog.brush.co.nz/2009/08/xmacros/" 
   tag="c programming" time="2009-08-25T04:24:34Z" 

TTL demo applets 
================================================================================
  href="http://tams-www.informatik.uni-hamburg.de/applets/hades/webdemos/toc.html"
    tag="engineering circuits electronics"
  time="2009-08-19T02:19:03Z" 

OASIS Login 
================================================================================
  href="https://usfonline.admin.usf.edu/"  
  tag="usf" time="2009-08-18T19:00:29Z" 

Class Schedule Search 
================================================================================
  href="http://www.registrar.usf.edu/ssearch/search.php"
    tag="usf"
  time="2009-08-18T18:59:44Z" 

ESR 
================================================================================
  href="http://esr.ibiblio.org/"  
  tag="blog oss politics" time="2009-08-15T18:54:43Z" 

Seeking: The powerful and mysterious brain circuitry that makes us love Google ...
================================================================================
  Seeking ... is the mammalian motivational engine that each day gets us out of the bed. dopamine circuits &quot;promote states of eagerness and directed purpose&quot;. Panksepp says a way to drive animals into a frenzy is to give them only tiny bits of food.
  href="http://www.slate.com/default.aspx?id=2224932" 
   tag="psychology learning" time="2009-08-15T18:42:29Z" 

An Intuitive Explanation of Fourier Theory
================================================================================
  href="http://enteos2.area.trieste.it/russo/LabInfoMM2005-2006/ProgrammaEMaterialeDidattico/daStudiare/009-FourierInSpace.html"
    tag="mathematics todo"
  time="2009-08-10T14:11:36Z" 

MakerBot Industries - Robots That Make Things.
================================================================================
  self-replicating machine. similar to RepRap.
  href="http://www.makerbot.com/"  
  tag="self-replication 3d_printing programming electronics engineering"
  time="2009-07-09T13:15:54Z" 

Motion Mountain: The Free Physics Textbook
================================================================================
  href="http://motionmountain.com/"  
  tag="physics books science" time="2009-07-06T17:28:21Z" 

"Concerning the Soul", Hermann Hesse
================================================================================
http://jsomers.net/concerning_the_soul.pdf
tag="literature books"
contemplation:
> At the moment when desire ceases and contemplation, pure seeing, and
> self-surrender begin, everything changes. Man ceases to be useful or
> dangerous, interesting or boring, genial or rude, strong or weak. He becomes
> nature, he becomes beautiful and remarkable as does everything that is an
> object of clear contemplation.

Cato Unbound: Beyond Folk Activism
================================================================================
  &quot;When we read in the evening paper that we‚Äôre footing the bill for another bailout, we react by complaining to our friends, suggesting alternatives, and trying to build coalitions for reform. This primal behavior is as good a guide for how to effectively reform modern political systems as our instinctive taste for sugar and fat is for how to eat nutritiously.&quot; ... &quot;Folk activism treats policies and institutions as the result of specific human intent. But policies are in large part an emergent behavior of institutions, and institutions are an emergent behavior of the global political ecosystem.&quot;
  href="http://www.cato-unbound.org/2009/04/06/patri-friedman/beyond-folk-activism/"
    tag="politics libertarianism"
  time="2009-06-26T03:04:01Z" 

the business cycle is a result of (federal reserve) market manipulation
================================================================================
  &quot;These two questions, that is, why businessmen seem to make periodic, not continuous, but periodic clusters of errors, and the question of why the errors always seem especially bad in the higher order stages, are the two questions that every economist has to answer if he/she is going to explain what happens in economic recessions and why they occur.&quot;
  href="http://www.reddit.com/r/Economics/comments/8uv04/peter_schiff_the_american_financial_system/c0ai9o1"
    tag="politics economics"
  time="2009-06-23T18:23:28Z" 

Pauls Online Math Notes
================================================================================
  calculus notes, formulae sheets.
  href="http://tutorial.math.lamar.edu/cheat_table.aspx"
    tag="mathematics pedagogy"
  time="2009-06-20T06:59:27Z" 

Elementary Cellular Automata 
================================================================================
  href="http://www.gmilburn.ca/2008/12/02/elementary-cellular-automata/"
   
  tag="cellular-automata mathematics todo compsci"
  time="2009-06-20T03:18:50Z" 

PolyPage
================================================================================
  ease the process of showing multiple page states in html mock-ups.
  href="http://code.new-bamboo.co.uk/polypage/" 
   tag="jquery wireframe programming"
  time="2009-06-18T22:48:29Z" 

An Illustrated Guide to SSH Agent Forwarding
================================================================================
  Password Authentication vs. Public Key Access. see also: http://www.reddit.com/r/linux/comments/8sjfv/if_you_use_ssh_to_do_remote_login_many_times_a/c0ab6js
  href="http://unixwiz.net/techtips/ssh-agent-forwarding.html"
    tag="security linux"
  time="2009-06-15T20:06:10Z" 

I2P Anonymous Network - I2P
================================================================================
  http://www.reddit.com/r/technology/comments/8sdcn/i2p_074_anonymous_email_browsing_chatting/ &quot;TOR is about anonymity. It reroutes packets so the source is obscured - there is no security. ... high-traffic stuff like P2P is strongly discouraged. I2P is anonymous AND secure. It's encrypted and separate from the regular internet.&quot;
  href="http://www.i2p2.de/"  
  tag="paranoia security privacy" time="2009-06-14T17:49:11Z" 

Ask /r/linux: Anyone have devices increment their number after cloning ...
================================================================================
  fix device names, viz., 'eth2' -&gt; 'eth0'. /etc/udev/rules.d/70-persistent-net.rules
  href="http://www.reddit.com/r/linux/comments/8h568/ask_rlinux_anyone_have_devices_increment_their/"
    tag="linux"
  time="2009-05-16T16:23:44Z" 

Robby on Rails : Installing Ruby on Rails and PostgreSQL on OS X
================================================================================
  href="http://www.robbyonrails.com/articles/2008/01/22/installing-ruby-on-rails-and-postgresql-on-os-x-third-edition"
    tag="rails osx programming"
  time="2009-05-16T16:02:39Z" 

Currency Forex Trading, Interbank Forex Broker, Low Spreads
================================================================================
  href="http://www.dukascopy.com/"  
  tag="forex finance investment" time="2009-05-14T21:01:30Z" 

50 Most Beautiful Icon Sets Created in 2008 | Noupe
================================================================================
  href="http://www.noupe.com/icons/50-most-beautiful-icon-sets-created-in-2008.html"
    tag="icons"
  time="2009-05-08T17:53:07Z" 

jQuery Corners
================================================================================
  easily create beautifully rounded corners
  href="http://www.atblabs.com/jquery.corners.html" 
   tag="jquery programming web"
  time="2009-05-08T17:44:51Z" 

haml (and Sass) - &quot;an external DSL for XHTML/CSS&quot;
================================================================================
  rails template templating framework superior to erb. can be used with ASP.NET via nhaml http://andrewpeters.net/category/nhaml/ . Sass is a CSS templating framework.
  href="http://haml.hamptoncatlin.com/"  
  tag="rails programming asp.net html css markup web"
  time="2009-05-08T03:01:40Z" 

Richard Branson - Wikipedia, the free encyclopedia
================================================================================
  href="http://en.wikipedia.org/wiki/Richard_Branson" 
   tag="entrepreneurs libertarian-role-models"
  time="2009-04-30T10:30:58Z" 

John D. Carmack - Wikipedia, the free encyclopedia
================================================================================
  href="http://en.wikipedia.org/wiki/John_D._Carmack" 
   tag="entrepreneurs libertarian-role-models"
  time="2009-04-30T10:29:36Z" 

Patri Friedman - Wikipedia, the free encyclopedia
================================================================================
  href="http://en.wikipedia.org/wiki/Patri_Friedman" 
   tag="entrepreneurs libertarian-role-models"
  time="2009-04-30T10:28:34Z" 

Peter Thiel: Cato Unbound: The Education of a Libertarian
================================================================================
  &quot;the founding vision of PayPal centered on the creation of a new world currency, free from all government control and dilution ‚Äî the end of monetary sovereignty ... we must resist the temptation of technological utopianism ‚Äî the notion that technology has a momentum or will of its own, that it will guarantee a more free future, and therefore that we can ignore the terrible arc of the political in our world. ... we are in a deadly race between politics and technology.&quot;
  href="http://www.cato-unbound.org/2009/04/13/peter-thiel/the-education-of-a-libertarian/"
   
  tag="politics libertarianism entrepreneurs libertarian-role-models"
  time="2009-04-30T10:27:41Z" 

Writer2LaTeX
================================================================================
  covert OpenOffice.org OpenDocument (ODF) document format to latex (tex) format.
  href="http://writer2latex.sourceforge.net/" 
   tag="oss" time="2009-04-30T09:58:13Z" 

ViewSourceWith :: Firefox Add-ons
================================================================================
  source, js, css view
  href="https://addons.mozilla.org/en-US/firefox/addon/394"
    tag="todo"
  time="2009-04-28T15:57:52Z" 

Why South Africa's Over the Rainbow - TIME
================================================================================
  &quot;History is full of revolutionaries who failed to make the switch. Most promised people's rule but, once in power, embraced a permanent state of revolution ‚Äî some, like Robert Mugabe and Hugo Ch√°vez, conjuring up fantastical foreign enemies to fight. (To those ranks, now add the leader of the influential ANC Youth League, Julius Malema, who told the East London rally that the young would &quot;never allow them to donate this country to Britain, to the hands of the colonizers.&quot;) To their people, this never-ending war is generally experienced as dictatorship. Too many liberation leaders leave office only when another revolutionary seizes power. ... Mobutu Sese Seko, ruler of Zaire for 32 years, who took the country as personal reward for &quot;liberating&quot; it. ... In India, the Gandhi family has towered over its democracy for 60 years. ... Henning Melber ... fought in Namibia against white rule. Watching his fellow liberators turn on their own people once the war was won...&quot;
  href="http://www.time.com/time/world/article/0,8599,1890334,00.html"
    tag="politics"
  time="2009-04-22T03:25:12Z" 

All About Circuits : Free Electric Circuits Textbooks
================================================================================
  href="http://www.allaboutcircuits.com/"  
  tag="engineering circuits" time="2009-04-20T04:50:01Z" 

gspread: Google Spreadsheets Python API
================================================================================
https://github.com/burnash/gspread
tag="python library programming development google spreadsheet data data-science"
http://tinaja.computer/2017/10/27/gspread.html

Official Google Webmaster Central Blog: How to start a multilingual site
================================================================================
  recommends putting the different language in the subdomain or subdirectory then set Webmaster Tools to reflect that so the appropriate content is served.
  href="http://googlewebmastercentral.blogspot.com/2008/08/how-to-start-multilingual-site.html"
    tag="seo programming"
  time="2009-04-15T18:31:27Z" 

Official Google Webmaster Central Blog: Specify your canonical
================================================================================
  explanation of canonical URL. Google answers to reader comments are provided down the page, here: http://googlewebmastercentral.blogspot.com/2009/02/specify-your-canonical.html Also: --- Q: http://mydomain.com/en/ http://mydomain.com/es/ http://mydomain.com/fr/ ...the same structure with different language content. A: Each language should have a separate URL because the content is unique. We‚Äôd advise against equating different languages using either 301s or link rel=&quot;canonical&quot;. --- http://www.seobythesea.com/?p=946 Using UTF-8 on pages may also help search engines determine a page's language: &lt;meta http-equiv=&quot;Content-Type&quot; content=&quot;text/html; charset=utf-8&quot;&gt; --- also use the xml:lang or lang attributes on the &lt;html&gt; tag: http://www.w3schools.com/tags/ref_standardattributes.asp
  href="http://googlewebmastercentral.blogspot.com/2009/02/specify-your-canonical.html"
    tag="seo programming"
  time="2009-04-14T20:27:38Z" 

It's 10PM: Do you know your RAID/BBU/consistency status? at time to bleed
================================================================================
  raid status check
  href="http://timetobleed.com/its-10pm-do-you-know-your-raid-status/"
    tag="todo linux"
  time="2009-04-14T18:16:30Z" 

Tess Ferrandez blog: If broken it is, fix it you should
================================================================================
  href="http://blogs.msdn.com/tess/"  
  tag="microsoft blog debug programming asp.net .net"
  time="2009-04-03T21:59:40Z" 

Tess Ferrandez blog: If broken it is, fix it you should
================================================================================
https://blogs.msdn.microsoft.com/tess/2006/04/12/asp-net-memory-if-your-application-is-in-production-then-why-is-debugtrue/
tag="microsoft deploy production debug programming asp.net .net"
If debug="true"...
  - asp.net requests will not time out
  - creates one dll per aspx, asax, or ascx page and this dll is compiled in debug mode
  - In order to be able to step through code line by line the JITter can’t really optimize the code
  - Much more memory is used within the application at runtime
  - Scripts and images downloaded from the WebResources.axd handler are not cached
http://blogs.msdn.com/tess/archive/2006/04/13/575364.aspx
http://weblogs.asp.net/scottgu/archive/2006/04/11/Don_1920_t-run-production-ASP.NET-Applications-with-debug_3D001D20_true_1D20_-enabled.aspx

fix OS X keyboard shortcuts
================================================================================
  fix OS X PgUp/PgDn/Home/End behaviour
  href="http://www.reddit.com/r/programming/comments/83jyb/proscons_of_using_a_mac_as_a_development/c085px4"
    tag="todo osx"
  time="2009-03-30T01:38:37Z" 

Things to do in Amsterdam‚Äîan unconventional guide
================================================================================
  href="http://thomer.com/amsterdam/"  
  tag="travel" time="2009-03-25T02:12:27Z" 

How to get a merchant account
================================================================================
  &quot;guide to obtaining a merchant account, from the cash-strapped start-up‚Äôs point of view&quot;. chargebacks, 3D-secure, AVS/CV2, PCI-DSS. Start the process early; Apply to several banks; Exaggerate your volumes (realistically); Know all about fraud; Be serious to ensure the bank feels you‚Äôre a trustworthy business; Read the fine print and negotiate the terms.
  href="http://danieltenner.com/posts/0006-how-to-get-a-merchant-account.html"
    tag="ecommerce business"
  time="2009-03-24T23:10:36Z" 

The Three20 Project
================================================================================
  open source iphone library. table view, data source, text editor, URL request. http://joehewitt.com/post/the-three20-project/
  href="http://github.com/joehewitt/three20/tree/master"
    tag="programming iphone"
  time="2009-03-24T14:47:40Z" 

Dot Net Perls - C# Problems and Solutions
================================================================================
  href="http://dotnetperls.com/"  
  tag="c# programming .net" time="2009-03-23T13:45:58Z" 

The Dangers of the Large Object Heap
================================================================================
  in .NET we can, for example, prevent memory from being recycled if we inadvertently hold references to objects that we are no longer using. Also, there is another serious memory problem in .NET that can happen out of the blue, especially if you are using large object arrays.
  href="http://www.simple-talk.com/dotnet/.net-framework/the-dangers-of-the-large-object-heap/"
    tag="todo .net programming"
  time="2009-03-23T13:32:37Z" 

25 Great Calvin and Hobbes Strips.
================================================================================
  href="http://progressiveboink.com/archive/calvinhobbes.htm"
    tag="art todo"
  time="2009-03-22T23:00:57Z" 

The Big Takeover: The global Economic Crisis Isn't About Money, It's About Power: How Wall Street Insiders Are Using The Bailout to Stage a Revolution
================================================================================
  href="http://www.reddit.com/r/politics/comments/8619y/the_big_takeover_the_global_economic_crisis_isnt/"
    tag="todo politics"
  time="2009-03-22T22:59:31Z" 

"You and your Research", Richard Hamming
================================================================================
http://www.cs.virginia.edu/~robins/YouAndYourResearch.html
tag="compsci engineering learning mental-model"
.
http://www.reddit.com/r/science/comments/862en/you_and_your_research_a_lecture_on_how_to_win_a/
> Be completely unafraid to utter whatever crazy idea you have at the moment and
> bounce it off someone--even if it turns out to be completely useless, which it
> usually will be, the kind of thoughts generated from such situations build
> over time to generate much greater work. If you think about something often
> and repeatedly approach it from different angles, you're far more likely to
> have that "lucky" strike of insight.

"Learning how to learn", Idries Shah
================================================================================
https://en.wikipedia.org/wiki/Learning_How_to_Learn
tag="learning pedagogy psychology"

Is there really such a thing as &quot;random&quot;?
================================================================================
  very good discussion about randomness, determinism.
  href="http://www.reddit.com/r/programming/comments/869bp/is_there_really_such_a_thing_as_random_ive_tried/"
    tag="todo compsci philosophy"
  time="2009-03-22T22:55:34Z" 

Computer science lectures on YouTube
================================================================================
  href="http://www.reddit.com/r/programming/comments/8271w/computer_science_lecturer_offers_lectures_on/"
    tag="compsci"
  time="2009-03-17T21:19:05Z" 

Fabulous Adventures In Coding : Locks and exceptions do not mix
================================================================================
  &quot;the body of a lock should do as little as possible&quot;, contention, deadlock, threading, concurrency
  href="http://blogs.msdn.com/ericlippert/archive/2009/03/06/locks-and-exceptions-do-not-mix.aspx"
    tag="concurrency c# programming .net"
  time="2009-03-16T18:12:35Z" 

Time Machine for every Unix out there - IMHO
================================================================================
  href="http://blog.interlinked.org/tutorials/rsync_time_machine.html"
    tag="linux"
  time="2009-03-07T20:32:59Z" 

deterministic finite automaton (DFA) minimization
================================================================================
  algorithm explanation
  href="http://useless-factor.blogspot.com/2009/02/dfa-minimization.html"
    tag="compsci todo"
  time="2009-02-19T21:38:14Z" 

Why you should never use rand()
================================================================================
  'tjw' comment: &quot;The proper alternative is to use the host operating system's random number generator. CryptGenRandom on Windows; /dev/urandom on everything else; fall back to rand() if all else fails.
  href="http://www.reddit.com/r/programming/comments/7yjlc/why_you_should_never_use_rand_plus_alternative/"
    tag="programming mathematics"
  time="2009-02-19T21:12:34Z" 

How Not To Sort By Average Rating
================================================================================
  using statistics to make a better rating system
  href="http://www.reddit.com/r/programming/comments/7ww4d/how_not_to_sort_by_average_rating/"
    tag="programming mathematics"
  time="2009-02-13T04:16:37Z" 

Pipl - People Search 
================================================================================
  href="http://www.pipl.com/"  
  tag="information tools privacy" time="2009-02-06T04:33:37Z" 

50 of the Best Ever Web Development, Design and Application Icon Sets
================================================================================
  href="http://speckyboy.com/2009/02/02/50-of-the-best-ever-web-development-design-and-application-icon-sets/"
    tag="icons"
  time="2009-02-03T22:58:03Z" 

The Freenet Project - /index 
================================================================================
  href="http://freenetproject.org/"  
  tag="paranoia privacy security" time="2009-01-25T21:30:12Z" 

Kinsella: Intellectual Property Information
================================================================================
  ip resources, criticism
  href="http://www.stephankinsella.com/ip/" 
   tag="law economics ip"
  time="2009-01-25T21:16:47Z" 

Can someone explain finger trees without referencing a functional programming language : programming
================================================================================
  href="http://www.reddit.com/r/programming/comments/7s948/can_someone_explain_finger_trees_without/"
    tag="compsci"
  time="2009-01-25T21:13:54Z" 

Nolo: Law Books, Legal Forms and Legal Software
================================================================================
  href="http://nolo.com/"   tag="law"
  time="2009-01-25T17:45:53Z" 

reAnimator: Regular Expression FSA Visualizer
================================================================================
  generates state diagrams for regular expressions.
  href="http://osteele.com/tools/reanimator/" 
   tag="compsci" time="2009-01-25T17:23:53Z" 

Are Frequent-Flier Miles About to Lose Value?
================================================================================
https://news.ycombinator.com/item?id=18752850
tag="life-hack credit-card finance airline"
> To anyone who wishes to simply not have to deal with airline miles earned on credit cards ever again, here's a great option I found: if you have $100k+ across checking + investment accounts at Bank of America + Merrill Edge (their low-cost brokerage arm) you get...
> 1. 2.625% cash back on BofA's Premium Rewards/Travel Rewards credit card. No messing around with airline miles. Just buy whatever ticket you want. Or, you know, pocket the cash.
> 2. 5.25% cash back on BofA's Cash Rewards card for "online purchases," up to $2500 per quarter.
> 3. 100 free trades per month at Merrill Edge. You're not locked into any fund companies and can buy whatever you want. I buy-and-hold Vanguard ETFs.
> 4. Free BofA checking account, with unlimited ATM rebates + a free safe deposit box. It pays negligible interest, so you may want to use another checking option if you hold larger cash balances, but it's helpful to have around just in case you need a physical branch for anything.

"The SRE regular-expression notation", Olin Shivers, August 1998
================================================================================
http://www.ccs.neu.edu/home/shivers/papers/sre.txt
tag="compsci regex automata lisp emacs"
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


Monoids and Finger Trees: sequences, priority queues, search trees and priority search queues for free
================================================================================
  &quot;...using monoids for annotations. The standard textbook treatment of annotated search trees would be greatly improved in precision, pedagogy and generality by introducing this abstraction.&quot;
  href="http://www.reddit.com/r/programming/comments/7r4bp/monoids_and_finger_trees_sequences_priority/"
    tag="programming compsci"
  time="2009-01-23T01:39:54Z" 

iPhone developer: App Store rewards &quot;crap&quot; apps
================================================================================
  href="http://www.appleinsider.com/articles/09/01/22/iphone_developer_app_store_rewards_crap_apps.html"
    tag="programming iphone"
  time="2009-01-22T21:45:25Z" 

LDAP (AD, Active Directory) Browser/Editor Java Applet
================================================================================
  A Java applet that you can use to browse LDAP/AD.
  href="http://www.mcs.anl.gov/~gawor/ldap/applet/applet.html"
    tag="programming"
  time="2009-01-13T15:46:11Z" 

22. U.S. Government Repressed Marijuana-Tumor Research | Project Censored
================================================================================
  href="http://www.projectcensored.org/top-stories/articles/22-us-government-repressed-marijuana-tumor-research/"
    tag="health politics"
  time="2009-01-11T19:47:30Z" 

A More Efficient Method for Paging Through Large Result Sets
================================================================================
  Using ROWCOUNT to Optimize Paging for SQL Server 2000
  href="http://www.4guysfromrolla.com/webtech/042606-1.shtml"
    tag="programming"
  time="2009-01-09T21:35:40Z" 

Red wine may ward off lung cancer: study | Health | Reuters
================================================================================
  href="http://in.reuters.com/article/health/idINTRE4987L120081009"
    tag="health"
  time="2008-12-28T22:03:33Z" 

C++ and the linker | copton.net
================================================================================
  Detailed analysis of C++ deficiencies. &quot;...I still believe that C++ is a dead end. The C heritage is a heavy burden. This article has lined out a mere few examples for this and on my blog there are some others (1, 2, 3, 4, 5). The fact that Bjarne Stroustrup et al. uncompromisingly pursued the design goals of efficiency and compatibility resulted in a language, which is very difficult to understand and use (6, 7, 8): Hundreds of special rules for special cases (9, 10, 11, 12, 13), language features that clash when used in particular combinations (14, 15), undefined and implementation-defined behavior everywhere (16, 17).&quot;
  href="http://blog.copton.net/articles/linker/index.html"
    tag="cpp programming"
  time="2008-12-16T03:55:48Z" 

Austrian School of Economics: The Concise Encyclopedia of Economics | Library of Economics and Liberty
================================================================================
  href="http://www.econlib.org/library/Enc/AustrianSchoolofEconomics.html"
    tag="todo politics"
  time="2008-12-05T09:48:03Z" 

Introduction &amp; overview to the Common Law subreddit : CommonLaw
================================================================================
  href="http://www.reddit.com/r/CommonLaw/comments/7erku/introduction_overview_to_the_common_law_subreddit/"
    tag="todo politics"
  time="2008-12-05T09:44:32Z" 

On the bankruptcy of the US FEDERAL GOVERNMENT, 1933 : AmericanGovernment
================================================================================
  href="http://www.reddit.com/r/AmericanGovernment/comments/7fpg2/on_the_bankruptcy_of_the_us_federal_government/"
    tag="todo politics"
  time="2008-12-05T09:43:45Z" 

Shorpy Photo Archive | History in HD
================================================================================
  high-quality prints of vintage ephemera.
  href="http://www.shorpy.com/"   tag="art"
  time="2008-11-19T06:45:22Z" 

GovTrack.us: Tracking the U.S. Congress
================================================================================
  href="http://www.govtrack.us/"  
  tag="politics law" time="2008-11-10T05:18:53Z" 

Native C &quot;Hello World&quot; working in emulator | Hello Android
================================================================================
  &quot;Next, I'm going to try and get busybox up &amp; running so we can have access to exciting programs such as 'cp'&quot;
  href="http://www.helloandroid.com/node/10" 
   tag="programming android"
  time="2008-11-10T02:09:03Z" 

Creative Loafing Tampa | Food &amp; Drink
================================================================================
  href="http://tampa.creativeloafing.com/food" 
   tag="food tampa" time="2008-10-09T01:55:58Z" 

Recovering Lawns, Failed States, and Reasons for Hope by William Norman Grigg
================================================================================
Somalia, anarchy
href="https://www.lewrockwell.com/2008/08/william-norman-grigg/failed-states-and-other-good-news/"
tag="politics"
time="2008-09-14T20:11:23Z" 

Obie Fernandez: Do the Hustle
================================================================================
  consulting, Master Services Agreement + Statement of Work, &quot;work for hire&quot; (domain-specific) vs. non-exclusive, references/case study, branding, define your products (name your services, viz., &quot;3-2-1 Launch&quot;, &quot;Rescue Mission&quot;), define your clients (viz., minimum budget, requirements readiness, travel to you vs. travel to them), be easy to contact (need a phone number), track your leads (Highrise) required reading: _Predictably_Irrational_ [Dan Ariely], _Never_Eat_Alone_ [Ferrazzi and Tahl Raz], _Secrets_of_Power_Negotiating_ [Roger Dawson]
  href="http://www.infoq.com/presentations/fernandez-sales-do-the-hustle"
    tag="work contracting"
  time="2008-09-14T18:49:57Z" 

Long-time nuclear waste warning messages
================================================================================
https://en.wikipedia.org/wiki/Long-time_nuclear_waste_warning_messages
tag="concepts history future weird semiotics iconography"
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


Regality theory and cultural selection theory
================================================================================
https://agner.org/cultsel/
tag="concepts history culture politics"
> Regality theory: people show a preference for strong leadership in times of
> war or collective danger, but a preference for an egalitarian political system
> in times of peace and safety. ... A society in danger will develop in the
> direction called regal, which includes strong nationalism, discipline, strict
> religiosity, patriarchy, strict sexual morals, and perfectionist art.
> A society in peace will develop in the opposite direction called kungic, which
> includes egalitarianism and tolerance.

Doing Business In Japan
================================================================================
https://www.kalzumeus.com/2014/11/07/doing-business-in-japan/
tag="culture japan travel"

Lesser Key of Solomon
================================================================================
https://en.wikipedia.org/wiki/Lesser_Key_of_Solomon
tag="concepts history occult"
aka Clavicula Salomonis Regis
aka Lemegeton
17th-century grimoire on demonology
divided into 5 books: Ars Goetia, Ars Theurgia-Goetia, Ars Paulina, Ars Almadel, Ars Notoria.
72 Demons


Transitus Fluvii
================================================================================
https://en.wikipedia.org/wiki/Transitus_Fluvii
tag="concepts history occult"
("passing through the river" in Latin), or Passage Du Fleuve (French).
occult alphabet of 22 characters described by Heinrich Cornelius
Agrippa in his Third Book of Occult Philosophy (Cologne, 1533)
derived from the Hebrew alphabet


Beej's Guide to Network Programming
================================================================================
http://beej.us/guide/bgnet/
tag="programming c network systems unix"

The Paintings of Fred Einaudi 
================================================================================
  href="http://fredeinaudi.blogspot.com/"  
  tag="art" time="2008-06-23T01:59:41Z" 

Better Explained
================================================================================
  difficult concepts explained intuitively
  href="http://betterexplained.com/"  
  tag="learning mathematics" time="2008-06-11T01:38:28Z" 

An Intuitive Guide To Exponential Functions &amp; e
================================================================================
  e is the base amount of growth shared by all continually growing processes. e is defined to be that rate of growth if we continually compound 100% return on smaller and smaller time periods:
  href="http://betterexplained.com/articles/an-intuitive-guide-to-exponential-functions-e/"
    tag="mathematics learning"
  time="2008-06-11T01:30:26Z" 

Ulrich Drepper: What Every Programmer Should Know About Memory
================================================================================
  href="http://www.reddit.com/r/programming/info/615x1/comments/"
    tag="todo programming virtual-memory"
  time="2008-05-27T02:32:11Z" 


The Unscalable, Deadlock-prone, Thread Pool
================================================================================
https://news.ycombinator.com/item?id=19251516
tag="kernel linux macos os syscall programming virtual-memory process job-control systems-programming containers threading multithreading concurrency"
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

TripIt - travel organizer
================================================================================
  Organize trip details into one master online itinerary. see: http://www.joelonsoftware.com/items/2008/01/31.html
  href="http://www.tripit.com/"  
  tag="travel tools" time="2008-04-02T00:24:44Z" 

Programming and Computation 
================================================================================
  href="http://okmij.org/ftp/Computation/" 
   tag="compsci todo" time="2008-03-31T06:34:44Z" 


Alan Kay
================================================================================
tag="compsci history"
Francis Bacon = origin of science.
Science= heuristics to get around bad brains.


regular expression generator 
================================================================================
  href="http://www.txt2re.com/index-ruby.php3" 
   tag="programming" time="2008-03-31T06:22:48Z" 

Pimp my Gedit (Was: Textmate for Linux)
================================================================================
  href="http://grigio.org/pimp_my_gedit_was_textmate_linux"
    tag="programming oss"
  time="2008-03-30T20:48:15Z" 

Good Agile, Bad Agile at Google
================================================================================
  most managers code at least half-time. developers can switch teams and/or projects any time. there aren't very many meetings. average 3 meetings a week, including their 1:1 with their lead. it's quiet. Engineers are quietly focused on their work, as indiv
  href="http://steve-yegge.blogspot.com/2006/09/good-agile-bad-agile_27.html"
    tag="programming management"
  time="2008-03-23T19:37:01Z" 

FOXNews.com - Radley Balko: Senseless Overkill - Opinion
================================================================================
  So in the raid where a citizen mistakenly shot a police officer, the citizen is facing a murder charge; in the raid where a police officer shot a citizen, prosecutors declined to press charges.
  href="http://www.foxnews.com/story/0,2933,336850,00.html"
    tag="politics"
  time="2008-03-16T19:48:24Z" 

What makes Mathematics hard to learn?
================================================================================
  It really is hard to think about something until one learns enough terms to express the ideas in that this subject. ... What's the word for when you should use addition? It‚Äôs when a phenomenon is linear. What's the word for when you should use multiplic
  href="http://wiki.laptop.org/go/Marvin_Minsky#What_makes_Mathematics_hard_to_learn.3F"
    tag="learning mathematics"
  time="2008-03-12T17:22:34Z" 

Legal Information Institute (LII)
================================================================================
  law resource
  href="http://www.law.cornell.edu/"  
  tag="law" time="2008-03-08T22:50:35Z" 

Banksy 
================================================================================
  href="http://www.banksy.co.uk/"  
  tag="art" time="2008-03-05T03:53:21Z" 

Will Wilkinson - More Misbehavioral Economics
================================================================================
  The ‚Äúrationality‚Äù of the outcome is more a function of the structure of the institution than of the ‚Äúrationality‚Äù of those acting inside it.
  href="http://www.willwilkinson.net/flybottle/2008/02/28/more-misbehavioral-economics/"
    tag="economics"
  time="2008-03-04T15:54:34Z" 

Immigration: No Correlation With Crime - TIME
================================================================================
  while the number of illegal immigrants in the country doubled between 1994 and 2005, violent crime declined by nearly 35% and property crimes by 26% over the same period
  href="http://www.time.com/time/nation/article/0,8599,1717575,00.html?xid=rss-topstories"
    tag="politics"
  time="2008-02-28T04:33:19Z" 

Healthy people place biggest burden on state - Telegraph
================================================================================
  study led by Pieter van Baal at the Netherlands‚Äô National Institute for Public Health and Environment
  href="http://www.telegraph.co.uk/news/main.jhtml?xml=/news/2008/02/05/nhealth105.xml"
    tag="politics"
  time="2008-02-26T03:54:42Z" 

Willamette Week | ‚ÄúA Brush With Measure 11‚Äù | February 20th, 2008
================================================================================
  A Washington County jury found Rodriguez guilty in 2005 of first-degree sexual assault after police accused her of running her hands through a 13-year-old boy‚Äôs hair and pulling the back of his head against her covered chest
  href="http://wweek.com/editorial/3415/10416/" 
   tag="politics" time="2008-02-25T10:39:14Z" 

giver - Google Code
================================================================================
  simple file sharing desktop application. Other people running Giver on your network are automatically discovered. no knowledge or set up needed
  href="http://code.google.com/p/giver/"  
  tag="oss tools" time="2008-02-24T04:24:42Z" 

Annals of Medicine: The Checklist: Reporting &amp; Essays: The New Yorker
================================================================================
  list-making. checklists improve quality.
  href="http://www.newyorker.com/reporting/2007/12/10/071210fa_fact_gawande"
    tag="information psychology"
  time="2008-02-08T02:15:08Z" 

Clarity Sought on Electronics Searches - washingtonpost.com
================================================================================
  govt. searches laptops, cellphones, mp3 players; demands passwords.
  href="http://www.washingtonpost.com/wp-dyn/content/article/2008/02/06/AR2008020604763.html"
    tag="politics"
  time="2008-02-07T22:48:50Z" 

WebUrbanist ¬ª 7 Underground Wonders of the World: Labyrinths, Crypts, Catacombs and More
================================================================================
  href="http://weburbanist.com/2007/09/30/7-underground-wonders-of-the-world-labyrinths-crypts-and-catacombs/"
    tag="travel"
  time="2008-02-03T18:24:03Z" 

How America Lost the War on Drugs : Rolling Stone
================================================================================
  href="http://www.rollingstone.com/politics/story/17438347/how_america_lost_the_war_on_drugs"
    tag="todo politics"
  time="2008-02-03T18:21:24Z" 

Holding a Program in One's Head 
================================================================================
  href="http://www.paulgraham.com/head.html" 
   tag="todo" time="2008-01-31T03:07:52Z" 

Beating the Averages 
================================================================================
  href="http://www.paulgraham.com/avg.html" 
   tag="todo" time="2008-01-31T03:07:40Z" 

News from the Front 
================================================================================
  href="http://paulgraham.com/colleges.html" 
   tag="todo" time="2008-01-30T07:19:32Z" 

The Equity Equation 
================================================================================
  href="http://www.paulgraham.com/equity.html" 
   tag="todo" time="2008-01-30T07:19:23Z" 

The Autumn of the Multitaskers 
================================================================================
  href="http://www.theatlantic.com/doc/200711/multitasking"
    tag="todo"
  time="2008-01-30T07:00:11Z" 

Shark pictures show amazing killing display - Telegraph
================================================================================
  href="http://www.telegraph.co.uk/earth/main.jhtml?xml=/earth/2007/11/17/eashark117.xml"
    tag="science"
  time="2008-01-27T23:26:23Z" 

Ten myths about nuclear power 
================================================================================
  href="http://www.spiked-online.com/index.php?/site/article/4259/"
    tag="politics science energy nuclear"
  time="2008-01-26T19:57:54Z" 

Going Nuclear
================================================================================
  founder of Greenpeace explains benefits of nuclear energy
  href="http://www.washingtonpost.com/wp-dyn/content/article/2006/04/14/AR2006041401209.html"
    tag="politics science nuclear"
  time="2008-01-26T18:54:33Z" 

Merb | Looking for a better framework?
================================================================================
  light, clean, modular Rails competitor
  href="http://merbivore.com/"  
  tag="programming" time="2008-01-22T02:55:56Z" 

How to Cash in on a Warming Planet
================================================================================
  href="http://www.businessweek.com/magazine/content/07_53/b4065050248104.htm?campaign_id=rss_daily"
    tag="investment finance stock-picks"
  time="2008-01-21T05:45:33Z" 

wellcare stock
================================================================================
  &quot;contracts will transfer to Patel's new ownership of Freedom and&quot;
  href="http://finance.google.com/group/google.finance.695596/browse_thread/thread/13567432f9ddfe73/a1edf88f6e698868#a1edf88f6e698868"
    tag="investment finance stock-picks"
  time="2008-01-21T02:06:21Z" 

Wesley Snipes to Go on Trial in Tax Case - New York Times
================================================================================
  acquitted Joseph Banister, a former criminal investigator for the I.R.S.
  href="http://www.nytimes.com/2008/01/14/business/14tax.html?_r=2&amp;ref=business&amp;oref=slogin&amp;oref=slogin"
    tag="politics"
  time="2008-01-15T06:19:38Z" 

American Letter Mail Company - Wikipedia, the free encyclopedia
================================================================================
  USPS competitor
  href="http://en.wikipedia.org/wiki/American_Letter_Mail_Company"
    tag="politics"
  time="2008-01-10T04:24:52Z" 

The Liberal Blogger 
================================================================================
  href="http://www.theliberalblogger.com/?pp_album=main&amp;pp_cat=gory-iraq-war-images"
    tag="politics"
  time="2008-01-07T03:03:14Z" 

G Edward Griffin - Creature From Jekyll Island A Second Look at the Federal Reserve
================================================================================
  href="http://video.google.com/videoplay?docid=638447372044116845"
    tag="politics economics"
  time="2007-12-31T03:54:01Z" 

The Hangover That Lasts - New York Times
================================================================================
  heavy drinking in early or middle adolescence ... can lead to diminished control over cravings for alcohol and to poor decision-making. exercise has been shown to stimulate the regrowth and development of normal neural tissue.
  href="http://www.nytimes.com/2007/12/29/opinion/29steinberg.html?_r=1&amp;oref=slogin"
  tag="health neuroplasticity"
  time="2007-12-30T22:38:32Z" 

RepRap
================================================================================
  self-copying 3D printer - a self-replicating machine. see also: http://angry-economist.russnelson.com/beads-not-teeth.html see also: http://vimeo.com/5202148 see also: http://www.reddit.com/r/technology/comments/8zd27/the_reprap_is_the_most_awesome_machine_ever_built/
  href="http://www.reprap.org/"  
  tag="3d_printing self-replication programming electronics engineering"
  time="2007-12-25T00:45:09Z" 

Got-It
================================================================================
https://news.ycombinator.com/item?id=21805248
time="20191216"
tag="design vlsi ise labels tags inventory rfid bluetooth proximity programming electronics engineering software startup"
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

Globalization and localization demystified in ASP.NET 2.0
================================================================================
  href="http://www.codeproject.com/KB/aspnet/localizationByVivekTakur.aspx"
    tag="asp.net programming todo"
  time="2007-12-18T05:17:25Z" 

REST: the quick pitch 
================================================================================
  href="http://www.megginson.com/blogs/quoderat/2007/02/15/rest-the-quick-pitch/"
    tag="programming rest"
  time="2007-09-30T19:36:41Z" 

Ergonomic products 
================================================================================
  href="http://www.ergomart.com/"  
  tag="health" time="2007-09-27T04:38:59Z" 

The GNU C Library 
================================================================================
  href="http://www.gnu.org/software/libc/manual/html_node/index.html"
    tag="c programming"
  time="2007-09-18T05:27:10Z" 

Teach Yourself C in 24 Hours 
================================================================================
  href="http://aelinik.free.fr/c/index.html" 
   tag="c programming" time="2007-09-18T05:25:52Z" 

The C Book 
================================================================================
  href="http://publications.gbdirect.co.uk/c_book/" 
   tag="c programming" time="2007-09-18T05:21:40Z" 

comp.lang.c FAQ 
================================================================================
   href="http://c-faq.com/"
    tag="c programming"
  time="2007-09-18T05:18:58Z" 

Mono and XPCOM: Scripting VirtualBox - Miguel de Icaza
================================================================================
  COM interop on Mono + *nix
  href="http://tirania.org/blog/archive/2007/Aug-28.html"
    tag="programming mono"
  time="2007-09-04T03:48:33Z" 

Yellow Icon : Crystal icon set 
================================================================================
  href="http://yellowicon.com/downloads/"  
  tag="icons" time="2007-08-26T08:35:24Z" 

Master Pages: Tips, Tricks, and Traps
================================================================================
  describing the control tree mechanics of how a master page and content page are merged together at runtime, how you can programmatically switch master pages on the fly from within a page, within a page base class, and even within an HttpModule (to enforce
  href="http://odetocode.com/Articles/450.aspx" 
   tag=".net asp.net programming"
  time="2007-06-05T00:00:11Z" 

How to use LINQ to do dynamic queries
================================================================================
  IEnumerable&lt;T&gt;.ToQueryable(), expression tree / QueryExpression
  href="http://blogs.gotdotnet.com/mattwar/archive/2006/05/10/594966.aspx"
    tag="programming .net linq"
  time="2007-05-29T18:04:35Z" 

Creating Trimmed Self Contained Executables in .NET Core
================================================================================
https://dev.to/jeremycmorgan/creating-trimmed-self-contained-executables-in-net-core-4m08
tag="programming .net deploy ship cross-platform"
command:
  dotnet publish -r win-x64 -c Release /p:PublishSingleFile=true /p:PublishTrimmed=true

Lightweight Invisible CAPTCHA Validator Control
================================================================================
  href="http://haacked.com/archive/2006/09/26/Lightweight_Invisible_CAPTCHA_Validator_Control.aspx"
    tag="asp.net programming"
  time="2007-05-22T16:32:55Z" 

fundamentals javascript concepts
================================================================================
  prototypes, namespacing
  href="http://odetocode.com/Articles/473.aspx" 
   tag="programming javascript"
  time="2007-05-17T19:27:53Z" 

Principality of Sealand
================================================================================
  In 1967‚Äì8 Britain's Royal Navy tried to remove Bates. As they entered territorial waters, Bates tried to scare them off by firing warning shots from the former fort.
  href="http://en.wikipedia.org/wiki/Principality_of_Sealand"
    tag="politics"
  time="2007-04-29T07:01:21Z" 

Slashdot | IT Worker Shortages Everywhere
================================================================================
  exporting of Indian tech jobs to the US
  href="http://it.slashdot.org/article.pl?sid=06/11/07/1926207&amp;tid=187"
    tag="politics it"
  time="2007-04-27T03:20:29Z" 

IMF admits disastrous love affair with the euro and apologises for the immolation of Greece
================================================================================
http://www.telegraph.co.uk/business/2016/07/28/imf-admits-disastrous-love-affair-with-euro-apologises-for-the-i/
tag="economics politics government-failure"
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


The Problem with Programming
================================================================================
  Bjarne Stroustrup, the inventor of the C++ programming language, defends his legacy and examines what's wrong with most software code.
  href="http://www.techreview.com/Infotech/17831/page1/"
    tag="cpp programming"
  time="2007-04-26T07:03:53Z" 

Articles on &quot;Electricity&quot;
================================================================================
  &quot;Babylonian approach to science understanding&quot; by William J. Beaty. intuitive explanations. addresses misconceptions.
  misconceptions: http://amasci.com/miscon/elect.html
  href="http://amasci.com/ele-edu.html"  
  tag="science learning pedagogy" time="2007-04-25T07:10:51Z" 

Google Song-Maker
================================================================================
https://musiclab.chromeexperiments.com/Song-Maker
tag="music learning pedagogy fun app webapp kids"
https://goo.gl/pf5Q9Y "Heroes Forever"

Europass: Curriculum Vitae
================================================================================
http://europass.cedefop.europa.eu/documents/curriculum-vitae
create CV online. import/export
tag="visa europe germany berlin immigration"

multi-armed bandit problem (explore/exploit dilemma)
================================================================================
https://en.wikipedia.org/wiki/Multi-armed_bandit
tag="concepts mental-model"
scheduling/operations theory.
Problem in which a fixed limited set of resources must be allocated between
competing (alternative) choices in a way that maximizes their expected gain,
when each choice's properties are only partially known at the time of
allocation, and may become better understood as time passes or by allocating
resources to the choice.

Pedophrasty, Bigoteering, and Other Modern Scams
================================================================================
https://medium.com/incerto/pedophrasty-bigoteering-and-other-modern-scams-c84bd70a29e8
tag="concepts psychology mental-model"
Pedophrasty: Argument involving children to prop up a rationalization and make the opponent look like an asshole, as people are defenseless and suspend all skepticism in front of suffering children: nobody has the heart to question the authenticity or source of the reporting. Often done with the aid of pictures.
Bigoteering: tagging someone (or someone’s opinions) as “racist”, “chauvinist” or somethinglikeit-ist in situations where these are not warranted. This is a shoddy manipulation to exploit the stigmas accompanying such labels and force the opponent to spent time and energy explaining “why he/she is not a bigot”.
Nabothizing: Production of false accusation, just as Jezebel did to dispossess Naboth.
Partializing: Exploiting the unsavory attributes of one party in a conflict without revealing those of the other party.


True Name
================================================================================
https://en.wikipedia.org/wiki/True_name
tag="concepts psychology mental-model"
> The notion that language, or some specific sacred language, refers to things by their true names has been central to philosophical study as well as various traditions of magic, religious invocation and mysticism (mantras) since antiquity.
> ...
> The true name of the Egyptian sun god Ra was revealed to Isis through an elaborate trick. This gave Isis complete power over Ra.
> ...
> the German fairytale of Rumpelstiltskin: within Rumpelstiltskin and all its variants, the girl can free herself from the power of a supernatural helper who demands her child by learning its name

Idioglossia
================================================================================
https://en.wikipedia.org/wiki/Idioglossia
tag="concepts psychology mental-model"

Principal–agent problem
================================================================================
https://en.wikipedia.org/wiki/Principal%E2%80%93agent_problem
tag="concepts politics economics mental-model"
> one person or entity (the "agent") is able to make decisions on behalf of another person or entity: the "principal".

Reality has a surprising amount of detail
================================================================================
http://johnsalvatier.org/blog/2017/reality-has-a-surprising-amount-of-detail
tag="concepts psychology emergence mental-model"
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

Emergence
================================================================================
https://en.wikipedia.org/wiki/Emergence
tag="concepts emergence mental-model"

L-system
================================================================================
https://en.wikipedia.org/wiki/L-system
https://onlinemathtools.com/l-system-generator
tag="cellular-automata cells tree graph compsci algorithm visualization"
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

Algorithm for Drawing Trees
================================================================================
https://rachel53461.wordpress.com/2014/04/20/algorithm-for-drawing-trees/
tag="tree graph compsci algorithm visualization"
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


Version SAT, Russ Cox
================================================================================
https://research.swtch.com/version-sat
VERSION is reducible to 3-SAT.
tag="dependency-management compsci sat-solver graph-theory"

Library for solving packages and reading repositories
================================================================================
https://github.com/openSUSE/libsolv
tag="dependency-management compsci sat-solver graph algorithm"

Pubgrub: Dart's version-solving algorithm
================================================================================
https://github.com/dart-lang/pub/blob/master/doc/solver.md
tag="dependency-management compsci sat-solver graph algorithm"
Pubgrub solves these issues by adapting state-of-the-art techniques for solving
Boolean satisfiability and related difficult search problems.

Modern SAT solvers: fast, neat and underused 
================================================================================
https://codingnest.com/modern-sat-solvers-fast-neat-underused-part-1-of-n/
tag="dependency-management compsci sat-solver graph algorithm"

SAT Solvers as Smart Search Engines
================================================================================
https://www.msoos.org/2019/02/sat-solvers-as-smart-search-engines/
tag="compsci sat-solver graph algorithm"
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


What I've Learned About Optimizing Python
================================================================================
https://gregoryszorc.com/blog/2019/01/10/what-i've-learned-about-optimizing-python/
tag="python optimization"

re2c: lexer generator for C/C++
================================================================================
http://re2c.org/
https://github.com/skvadrik/re2c
tag="dfa regex automata lexer optimization c programming"
.
> generates fast lexers. Instead of using traditional table-driven approach,
> re2c encodes the generated finite state automata directly in the form of
> conditional jumps and comparisons. The resulting programs are faster and often
> smaller than their table-driven analogues, and they are much easier to debug
> and understand.
.
Used by Oil shell: https://github.com/oilshell/oil


Google Optimization Tools
================================================================================
https://developers.google.com/optimization/
tag="compsci sat-solver graph optimization algorithm"
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


Cloud Foundry
================================================================================
https://news.ycombinator.com/item?id=14532127
tag="paas dcos orchestration deployment sre devops"

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

China uncovers massive underground network of Apple employees selling customers’ personal data
================================================================================
https://www.hongkongfp.com/2017/06/08/china-uncovers-massive-underground-network-apple-employees-selling-customers-personal-data/
tag="security infosec"

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


Co-routines as an alternative to state machines
================================================================================
https://eli.thegreenplace.net/2009/08/29/co-routines-as-an-alternative-to-state-machines
tag="programming compsci coroutine state-machine"
coroutines are to state machines what recursion is to stacks:
- recursion helps process nested data structures without employing explicit stacks.
- coroutines help solve problems involving state, without using explicit state machines.


DECYPHERING THE BUSINESS CARD RAYTRACER
================================================================================
tag="programming compsci c graphics ppm image ray-tracing"
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


AWS: compute the minimal permission set needed to perform some requests(s)?
================================================================================
https://news.ycombinator.com/item?id=21228386
tag="programming software-engineering debugging security amazon aws"
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


Kerbal Space Program: Create and Manage Your Own Space Program
================================================================================
https://www.kerbalspaceprogram.com
tag="game software kids learning science space pedagogy"

No nuances, just buggy code (was: related to Spinlock implementation and the Linux Scheduler)
================================================================================
https://news.ycombinator.com/item?id=21959692
https://www.realworldtech.com/forum/?threadid=189711&curpostid=189752
tag="linux scheduler rtos os"
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

Spanish flu
================================================================================
https://en.wikipedia.org/wiki/Spanish_flu
tag="concepts epidemic pandemic statistics exponential-growth infection bacteria superinfection"
1918 influenza pandemic: January 1918 – December 1920: colloquially known as Spanish flu.
First of the two pandemics involving H1N1 influenza virus, with the second being the swine flu in 2009.
- 500 million infected (~27% of world population).
- 17~50 million dead.
Wartime censors minimized early reports of illness and mortality in Germany/UK/France/USA.
Not censored in Spain, which created a false impression, giving rise to the nickname "Spanish flu".
Most deaths caused by bacterial superinfection (result of malnourishment, overcrowded hospitals, poor hygiene).

Scala War Stories with Paul Phillips (2013)
================================================================================
https://lobste.rs/s/tk0hjk/scala_war_stories_with_paul_phillips_2013
takeaways:
- > "Unification can burn":
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
tag="politics economics federal-reserve monetary-policy inflation"
> the Board has reduced reserve requirement ratios to zero percent effective on
> March 26, the beginning of the next reserve maintenance period. This action
> eliminates reserve requirements for thousands of depository institutions and
> will help to support lending to households and businesses.

================================================================================
20200324
Modern Monetary Theory
https://www.reddit.com/r/wallstreetbets/comments/fnkbdh/dont_bet_against_mmt_you_will_lose_even_if_you/fla4bve/
tag="economics mmt federal-reserve monetary-policy equity stock options"
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
tag="health medicine technology illegal stem-cell panama"
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
tag="politics equity stock options"

================================================================================
20200414
Kayfabe
https://en.wikipedia.org/wiki/Kayfabe
tag="concepts mental-model"
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
tag="learning psychology language pedagogy"
- deadlifts most effective if you start from ground and lift only ~5 inches.
- best temperature for coffee = 180 F
- play ~any song with 4 chords: https://www.youtube.com/watch?v=B_Smt1VsoqQ

================================================================================
20200421
Who’s Behind the “Reopen” Domain Surge?
https://krebsonsecurity.com/2020/04/whos-behind-the-reopen-domain-surge/
tag="urbit search reputation"
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
tag="concepts mental-model"
You should treasure every encounter, for it will never recur.

================================================================================
20200504
Daniel Schmachtenberger on The Portal (with host Eric Weinstein), Ep. #027 - On Avoiding Apocalypses
https://www.youtube.com/watch?v=_b4qKv1Ctv8
tag="economics concepts mental-model"
"Game B"
sense-making + choice-making
"multipolar trap"
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
tag="physics science academia institutions"
_The Road to Reality_ by Roger Penrose
  "This book is a self-contained invitation to understanding our deepest nature."

================================================================================
20200508
Secessio plebis
https://en.wikipedia.org/wiki/Secessio_plebis
tag="history economics politics state"
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
tag="startups concepts mental-model philosophy technology"
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
tag="distributed-systems filesystem"
https://news.ycombinator.com/item?id=23180572

================================================================================
20200515
Port knocking
https://en.wikipedia.org/wiki/Port_knocking
https://news.ycombinator.com/item?id=23187662
tag="security network protocol"
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
tag="politics state international-law"
> The state as a person of international law should possess the following qualifications:
> (a) a permanent population;
> (b) a defined territory;
> (c) government; and
> (d) capacity to enter into relations with the other states.

================================================================================
20200519
Python performance: it’s not just the interpreter
https://news.ycombinator.com/item?id=23235930
tag="performance programming python compiler interpreter optimization"
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
tag="diy-project electronics engineering programming"

================================================================================
20200525
"You and Your Research" Richard Hamming
http://www.cs.virginia.edu/~robins/YouAndYourResearch.html
tag="engineering science academia university study research invention innovation"
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
tag="concepts mental-model philosophy health"
> Kapil: A human being becomes his environment and that is why it’s absolutely
> critical to savagely and surgically arrange one’s environment in a way that is
> in accordance with where he wants to go. You become that which you are most
> consistently exposed to.

================================================================================
20200611
https://old.reddit.com/r/wallstreetbets/comments/grj5fa/the_mouthbreathers_guide_to_the_galaxy/
tag="economics mmt federal-reserve monetary-policy equity stock options"
> Yup, everyone got clapped on their stupidly leveraged derivatives books. It
> seems Citadel is “too big to fail”. On 3/18, the payout on 3/20 TQQQ puts
> alone if it went to 0 was $468m. And every single TQQQ put expiration would
> have had to be paid. Tens or hundreds of billions on TQQQ puts alone. I’d bet
> my ass Citadel was on the hook for a big chunk of those.

================================================================================
20200612
https://old.reddit.com/r/wallstreetbets/comments/h0ytcy/the_liquidity_trap_how_qe_and_low_rates_might_be/ftqgnj8/
tag="economics mmt federal-reserve monetary-policy equity stock options"
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
tag="investment finance startup"
> VC fund ... to create a new model for urban development where the city & its
> institutions is the product. ... work in partnership with countries to create
> new communities that seek - through good governance - to emulate the economic
> success of Dubai, Hong Kong, Shenzhen and Singapore. Our investors include
> Peter Thiel, Marc Andreessen, Balaji Srinivasan, Naval Ravikant, Joe

================================================================================
20200613
Founders Fund
https://foundersfund.com/
tag="investment finance startup"
stripe, twilio, spacex, airbnb, ...

================================================================================
20200615
vscode notebook UX
https://github.com/microsoft/vscode/issues/91987
tag="tools programming ide vscode javascript typescript text-editor"
design of vscode notebook experience (cf. jupyter): kernel/backend + cells

================================================================================
20200624
Peer-to-peer canvas app for Urbit
https://github.com/yosoyubik/canvas
tag="urbit app p2p programming"
https://news.ycombinator.com/item?id=23228058

================================================================================
20200627
xi-editor retrospective
https://raphlinus.github.io/xi/2020/06/27/xi-retrospective.html
tag="tools programming xi rope vim neovim rust text-editor"

================================================================================
20200627
Lezer (CodeMirror parsing system)
https://marijnhaverbeke.nl/blog/lezer.html
tag="programming parser syntax-highlighting text-editor"

================================================================================
20200628
Semantic: Haskell library and command line tool for parsing, analyzing, and comparing source code
https://github.com/github/semantic
tag="programming parser ast syntax-highlighting code-navigation treesitter"
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
tag="software-engineering programming communication technology engineering"
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
tag="politics tropes concepts"
> A mode of left-wing politics that eschews civility in order to convey
> a socialist or left-wing populist message using subversive vulgarity. It is
> most closely associated with American left-wing media that emerged in the
> mid-2010s, most notably the podcast Chapo Trap House.

================================================================================
20200630
Multi-channel network
https://en.wikipedia.org/wiki/Multi-channel_network
tag="software platform technology media"
> A multi-channel network (MCN) is an organization that works with video platforms to offer assistance to a channel owner in areas such as "product, programming, funding, cross-promotion, partner management, digital rights management, monetization/sales, and/or audience development" in exchange for a percentage of the ad revenue from the channel.
https://support.google.com/youtube/answer/2737059?hl=en
> Multi-Channel Networks (“MCNs” or “networks”) are third-party service providers that affiliate with multiple YouTube channels to offer services that may include audience development, content programming, creator collaborations, digital rights management, monetization, and/or sales.

================================================================================
20200630
Guy Who Reverse-Engineered TikTok Reveals the Scary Things He Learned
https://news.ycombinator.com/item?id=23684950
tag="security fingerprinting software technology machine-learning spam"
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
https://tools.ietf.org/html/rfc3031
tag="rfc network internet engineering ietf"
next generation internet protocol / replaces tcp/ip?

================================================================================
20200720
All of the World’s Money and Markets in One Visualization
https://www.visualcapitalist.com/all-of-the-worlds-money-and-markets-in-one-visualization-2020/
tag="economics finance stocks"
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
tag="concepts mental-model psychology"
> phenomenon of experts believing news articles on topics outside of their
> fields of expertise, even after acknowledging that articles written in the
> same publication that are within the experts' fields of expertise are
> error-ridden and full of misunderstanding.

================================================================================
20200720
Turning the IDE Inside Out with Datalog
https://news.ycombinator.com/item?id=23869592
tag="datalog query language ide programming database"
https://petevilter.me/post/datalog-typechecking/

================================================================================
20200720
QUANTUMINSERT (QI), QUANTUMHAND
https://news.ycombinator.com/item?id=23782093
tag="police-state surveillance usgov government state security encryption nsa"
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
tag="reddit security fingerprinting software technology webbrowser web"
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
tag="podcast prepper urban-explorer"
London's "lost rivers": underground rivers converted to tunnels/sewers in the 1800s
- River Tyburn
- River Effra

================================================================================
20200731
Harvard Study of Adult Development
https://news.harvard.edu/gazette/story/2017/04/over-nearly-80-years-harvard-study-has-been-showing-how-to-live-a-healthy-and-happy-life/
tag="psychology happiness life"
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
tag="art time clock amsterdam airport"
12-hour performance art film of Dutch artist Maarten Baas painting each minute
of the hands of a clock.  In Schiphol Airport since 2016.

================================================================================
20200802
GITenberg project
https://www.gitenberg.org/
tag="literature ebooks books pedagogy"
- Curated, usable, attractive ebooks in the public domain.
- Converts Project Gutenberg HTML to ePub.

================================================================================
20200827
QUIC: Quick UDP Internet Connections
tag="networks proxy quic tcp udp protocol http spdy cryptopgraphy tls ssl"
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

================================================================================
20200809
interview with Elon Musk about SpaceX Starship
https://www.youtube.com/watch?v=cIQ36Kt7UVg
tag="space spacex science starship nasa"
"If a design is taking too long, the design is wrong. ... Strive to delete parts and processes. ... Question the constraints."
- Elon Musk

================================================================================
20200809
WebAuthn guide
https://webauthn.guide/
tag="security infosec webauthn u2f fido mfa software-engineering"
implementing MFA on a new website:
- implement WebAuthn, not U2F (older, non-standard hack)

================================================================================
20200809
Security Keys, webauthn (27 Mar 2018)
https://www.imperialviolet.org/2018/03/27/webauthn.html
tag="security infosec webauthn u2f fido mfa software-engineering"
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
tag="djb filesystem kernel interface design compsci software-engineering"
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
tag="history quotation benjamin-franklin role-model"
> "I shall like to give my self ... Leisure to read, study, make Experiments,
> and converse at large with such ingenious and worthy Men as are pleas’d to
> honour me with their Friendship" - Benjamin Franklin

================================================================================
20200809
Poor Richard, 1736
https://founders.archives.gov/documents/Franklin/01-02-02-0019
tag="history quotation benjamin-franklin"
> Force shites upon Reason’s Back.
> Lovers, Travellers, and Poets, will give money to be heard.
> He that speaks much, is much mistaken.
> Creditors have better memories than debtors.
> Forwarn’d, forearm’d, unless in the case of Cuckolds, who are often forearm’d before warn’d.

================================================================================
20200810
Jeremy Howard: fast.ai Deep Learning Courses and Research | Artificial Intelligence (AI) Podcast
https://www.youtube.com/watch?v=J6XcP4JOHmk
tag="podcast video deep-learning machine-learning compsci engineering swift healthcare"
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
tag="compiler llvm"
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
tag="elf binary compression c"
portable, extendable, high-performance executable packer for several executable formats.
shrink executables by 50%

================================================================================
20200815
Review of Paul Graham's Bel, Chris Granger's Eve, and a Silly VR Rant
https://gist.github.com/wtaysom/7e5fda6d65807073c3fa6b92b1e25a32
tag="datalog query language programming-paradigm vm eve light-table"
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
tag="government-failure covid19 virus curtis-yarvin"
> Anyone repeating lines like “the Trump administration has failed” is spreading
> an Orwellian lie. There is no “Trump administration.” There is an elected
> showman and his cronies, fronting for an unaccountable permanent government.
> The celebrities are neither in charge of the bureaucrats, nor deserve to be.

================================================================================
20200824
Unregistered 116: Curtis Yarvin (AKA "Mencius Moldbug")
https://www.youtube.com/watch?v=6GW-YMa68o4
tag="concepts government politics philosophy curtis-yarvin history libertarianism monarchy"
- "Sovereignty is conserved."
- How DC works: "Everyone wants status but no one wants responsibility."

================================================================================
20200824
POAAS 03 - Surveying Ethiopian History w/ Curtis Yarvin
https://www.youtube.com/watch?v=BKdOoR4zhOc
tag="concepts politics history curtis-yarvin"
- https://en.wikipedia.org/wiki/Cursus_honorum
  Latin for "course of honor", or colloquially "ladder of offices".
- "Unconsidered superiority" is the attitude of a parochial barbarian.
- "Atheist cold war Liberalism" is "secularized Christianity".
- atheist vs. anti-theist

================================================================================
20200826
Gray Mirror of the Nihilist Prince with Curtis Yarvin
https://www.youtube.com/watch?v=_8o0M24DrcE
tag="concepts government politics philosophy curtis-yarvin history libertarianism monarchy"
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
tag="concepts government politics philosophy curtis-yarvin history libertarianism monarchy"
- "Government _wasteful spending_ is really _disguised profits_ going to
  beneficiaries in the form of entitlements and overpaying."
- "There's a crucial difference between a bet and a vote." (skin in the game)

================================================================================
20200905
THINGS HIDDEN 17: The Glorious Yeast Infection of Christianity (Curtis Yarvin Interview)
https://www.youtube.com/watch?v=otXb3DVGvSI
tag="concepts government politics philosophy curtis-yarvin history libertarianism monarchy"
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
tag="concepts government politics philosophy curtis-yarvin history libertarianism monarchy"
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
tag="concepts government politics philosophy curtis-yarvin history libertarianism monarchy"
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
tag="concepts government politics philosophy curtis-yarvin history libertarianism monarchy"
> Better to know, than to see; better to see, than be seen; better to be seen, than noticed; better to be noticed, than feared; better to be feared, than hated; better to be hated, than beaten; better to be beaten, than killed; better you are killed, than your family. The fox has no illusions and is always, in principle, on the move.
> ...
> Absolutism, the yang of nihilism, means thinking ex nihilo: from scratch, from first principles, not relative to any specific past or present reality. Nihilists do care about reality. We care about it so much that we accept no substitutes. The motto of the Royal Society, crafted in happier times: nullius in verbum. We take no one’s word for it—that’s what it means to “believe in nothing.”

================================================================================
20200827
Interview with Zig language creator Andrew Kelley
https://news.ycombinator.com/item?id=24292437
tag="programming-language zig c low-level"
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
tag="sat-solver scheduling algorithms"

================================================================================
20200827
American fuzzy lop – a security-oriented fuzzer
https://lcamtuf.coredump.cx/afl/
tag="static-analysis fuzzer algorithms"
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
tag="security infosec gpg ssh yubikey u2f fido mfa"
> All YubiKeys except the blue "security key" model are compatible with this guide.

================================================================================
20200830
Reasons Not to Become Famous
https://tim.blog/2020/02/02/reasons-to-not-become-famous/
tag="security privacy paranoia identity-theft"
- Fame is for suckers (status games).
- Use a UPS Store or other off-site mailing address for receiving packages.
  Never have anything mailed to your address; your name/address will end up in
  company/government databases which are rented/traded/searchable.

================================================================================
20200922
Palantir products: Foundry, Gotham, Metropolis
https://www.quora.com/What-are-the-main-differences-between-the-Palantir-Metropolis-and-Gotham-platforms
tag="technology startup surveillance data data-mining datasets data-management data-science statistics visualization tools machine-learning"
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
tag="statistics game-theory power politics government systems nassim-taleb monarchy"
- Negative golden rule: don't do to others what you wouldn't want done to you.
- Accountability:
  - "Experts" of macro systems are not falsifiable; impossible to verify cause-effect in a macro system.
    - Thus such experts "do not have skin in the game" (unaccountable).
  - Progressive bureaucrats today can start horrific wars, are less accountable than monarchs.
- Any political opinion must have a scale attached to it.
- A public intellectual who doesn't take risks cannot be trusted.
  - "Why do I insult people in my books? Because it signals risk-taking."
- "Start a business. We're tired of people who want to work for NGOs."
- dynamic vs static
  - healthy economy if incumbent players are at risk
  - unhealthy economy if incumbent players are effectively permanent
- History tends to "revert to the truth", like "reversion to the mean".
