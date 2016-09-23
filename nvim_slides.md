nvim
====================================================
by et al.
based on Vim by Bram Moolenaar et al.
















about me
====================================================
- I am nobody. That's a feature.
- 10+ (???) years of software dev experience
- 5 years of "serious" Vim
- My goals for Nvim:
  - Ubiquity (IDE, browser, OS form-fields)
  - Remove friction (cross-plat inconsistencies,
    defaults).









nvim contributors: "et al."
====================================================
nvim
  contributors: 262
  6479 commits since January 2014

vim (3 years of VCS)
  contributors: ~323
    $ git log --since='3 years ago' \
      |sed -r 's/(Problem|Solution).*(\(.*\))/\2/'|grep -E '\(.*\)'

vim (12 years of VCS)
  6553 commits since 2004
  contributors: ~545
    $ git log |sed -r 's/(Problem|Solution).*(\(.*\))/\2/'|grep -E '\(.*\)'


nvim contributors: "et al."
====================================================
- 13 people on "core" team (can commit directly to
  master)
  - Trust networks *work* (cf. LKML)
- Contributors "behave" by default
  - no "activist" or "hostile" commits
- Some major features have been committed without
  my review.
  - Different contributors specialize in different
    components.







nvim maintainer
====================================================
Maintainer role is:
- unblock other contributors
  - cross-reference, institutional knowledge
  - build system, automation
- conceptual integrity ("bike-shedding")
  - insist on a polished UI (where "user" means "end
    user", "plugin author", "API consumer", and
    "core contributor")
- administration
- write code
- WIP: document maintainer role





things i like about vim
====================================================
- Ubiquity
- Conventions (quickfix, alt-buffer, :make,
  :compiler, ...)
- Culture (plugins have better back-compat than other
  editors)
- back-compat
- Community (relatively large)
  => more/better plugins








things i think can be improved
====================================================
- Ubiquity
- Embrace vim's own idioms more aggressively, and
  build on them (enhance :read, vimregex vs. logipat.vim)
- Community is accidental, and not growing much, if at all
  (relative to pop. growth)
  - Why care about popularity?
    - bug testers; more users => more robust
    - more plugins
    - more devs
- Remove baggage that benefits <1% of users
  (defaults, vim -N, defaults, <M-...>, terminal fiddling (t_*))
- API/UX consistency inconvenient for dev, but has
  far-reaching benefits

^... notice how there's nothing about "ugly code" up there

vi evolution
====================================================
ed:   line-addressable editing language
vi:   normal-mode (AKA ex 2.0)
vim:  +textobjects, +eval (VimL)
nvim: --embed, API

^... notice how job control, :terminal are not
mentioned; they are incremental, not inflections.
GUIs also aren't mentioned. No one (incl. vim_dev)
cares about the Vim GUI, it is a "checkbox".







nvim goals (initial fundraiser)
====================================================
~ New, modern multi-platform UI written using qtlua.
/ New curses UI written using luaposix.
+ New testing UI written in Lua
  ~ Migrate old tests to this interface.
+ New plugin architecture, with a python compat layer
  for legacy Vim `if_py` plugins.
+ Full port of the editor IO to libuv.
+ Cross-platform VimL job control.
~ Distributions for Windows, Linux, Mac.







nvim goals
====================================================
- First-class support for embedding
- Extend the editor in any programming language
- Support more powerful GUIs
- Vim plugin compatibility

Time estimate for the original fundraiser goal:
  1 month
Underestimated by 2 years, but in the history of
software projects (DNF, Perl 6) this isn't
too bad...?
Bonus: If Thiago had not underestimated the project
the task would have seemed insurmountable.




nvim goals
====================================================
- "Vim" => "vim": commoditize vim
- Provide a viable replacement for Vim source tree.
- Eliminate non-negligible *technical* reasons that
  differentiate Vim from Nvim
  1. Informs our decisions
  2. Signals to users and potential contributors the
     direction and intentions of the project.
- Preserve Vim's legacy: no other project, ever, has
  put more man-hours towards preserving Vim (instead
  of discarding the entire thing and starting from
  scratch).
  - Nvim passes Vim's own test suite. No other
    project does this.



refactoring outcomes
====================================================
painful. boring. necessary.
- attracts new devs
- encourages existing devs (fewer "broken windows")
- builds a foundation for long-term viability (vs.
  looming debt-bubble)
  - example: investing in libuv allows us to avoid
    solving platform problems for future platforms/OS
    versions/etc.: libuv solves them instead.
    (Bonus: libuv patches benefit other OSS, not just Nvim)

* Refactoring is not a goal in itself.





refactoring risks
====================================================
- introduce new bugs
- take too long, become irrelevant

If refactoring does not accelerate development
enough, n/vim will be replaced by better designs.
N/Vim has a head-start on solving the tedious details
of various edge-cases and use-cases. But if it isn't
*meaningfully* refactored by the time other editors
with better designs solve those tedious details, then
it will be replaced.

* IOW: A good outcome is inevitable. (Yay!)
  Nvim project is an attempt to solve the problem
  from one end (because no one else was doing it).
  Fancy-new-editor(s) may some day solve the problem
  from the other end.

criticism: Nvim removes support for platforms
====================================================
Comments bemoaned the removal of legacy platforms
like OS/2 and win16.

But no one actually used Vim on those platforms,
and Vim was not capable of running on those
platforms.

Vim removed OS/2 code in Dec 2015 (7.4.1008,1016)








criticism: Nvim vs Vim "rivalry"
====================================================
- No other project has done more to preserve core Vim.
  - Other vim-likes attempt total re-implementation.














criticism: Nvim "divides the developers"
====================================================
- Not a zero-sum outcome: 100s of new developers were
  introduced to the vim source code because of Nvim.
  - Past contrib. trends (and vim_dev ML activity)
    suggest that these new developers wouldn't have
    bothered if Nvim did not exist.
- No other project has done more to preserve core Vim.
  - Other vim-likes attempt total re-implementation.
- Nvim merges all relevant Vim patches.








criticism: Nvim "divides the community"
====================================================
- Not a zero-sum outcome!
- More vim discussion and collaboration has happened
  on the Neovim tracker in 2 years than on vim_use.
  - Most users don't bother with mailing lists.











criticism: bloat
====================================================
> ":terminal is bloat!"

  $ cat vim/src/gui*|wc -l
  56436

Imagine starting with the nvim core, and then,
"Let's add built-in GUIs!"

terminal.c is ~1k LOC.
Vim's screen.c:win_update() *function* is 1197 LOC.






criticism: bloat
====================================================
$ ohcount vim/src
Language          Files       Code
----------------  -----  ---------
c                   173     317691
vim                 117      10353

$ ohcount nvim/src
Language          Files       Code
----------------  -----  ---------
c                   238     174837
lua                   5       6461





criticism: Nvim will fail like Xemacs
====================================================
Steve Yegge on Xemacs:
> lots of features, lots of bugs
https://steve-yegge.blogspot.com/2008/xemacs-is-dead

Avoiding regressions has been a major focus of Nvim
since the beginning.
- CI
- advanced compiler features
- strict coding guidelines (+automation)







goal: first-class lua scripting for users
====================================================
RPC API supports plugins in any language, but
"ubiquity is king".
lua is designed for embedding
lua is fast; luajit is ridiculously fast












goal: script core features in lua
====================================================
C is fraught with subtle edge-cases that experts
get wrong[1], in major projects such as linux [2].

1: https://news.ycombinator.com/item?id=11606296
2: https://lkml.org/lkml/2015/9/3/428











nvim delegation
====================================================
legacy modules we want to own
- eval, screen
- misc, fileio, os layer (FKA "mch")
- mark
- messages, popupmnu
major modules we don't (currently) want to own (let
vim_dev fix and enhance these)
- normal
- syntax/regex
- quickfix, tags, cscope

...anything not mentioned above is just not on our
radar, yet



nvim risks
====================================================
- no one cares: niche (vim-likes) of a niche (vim) of a niche (text editors)
- too many bugs
- split audience
- inertia: incumbent wins if challenger is <10x better
  - viz.: java/C#, linux/bsd, unix/plan9, ...
- lack of expertise: Bram is most-qualified to refactor many modules
- AWOL founder









nvim strengths (non-technical)
====================================================
- distributed roles/authority
  - goal: everything is written down, including release-process
- methodology: PRs + discussion, not fixups
- community: proliferation of clients and UIs
- merge Vim patches
- CI
- positive interactions with package maintainers (helps adoption)
- generally favorable public reception
- lower bus-factor
- boxed-in (defined) the shape of Vim:
  - termcode handling is something most people don't touch, we now know that
    most users are using xterm-likes and a reasonable terminal application can
    be built with libtickit/unibilium
  - Vim's GUI code is not a legacy asset: nvim-qt is more performant,
    better-looking (less flicker), cross-platform, uses a modern framework
    (FWIW), much less code (compare Vim's win32+gtk GUI)--oh, and it works on
    macOS.

nvim strengths (technical)
====================================================
- utf8 always (important for sane RPC)
- test infrastructure (screen tests)
- "job" API: *simple* and powerful













nvim dev feature: tools matter
====================================================
- Did Vim see increased contributions after switch to
  git+github...?
- cmake generates makefiles for VS, Xcode, ninja, ...













nvim dev feature: tools matter
====================================================
actual screen test for wildmenu:

    screen:expect([[
                               |
      ~                        |
      ~                        |
      define  jump  list  >    |
      :sign define^             |
    ]])







nvim dev feature: development cycle
====================================================
PRs with design & feedback

compare:
  Nvim PR to add JSON support
  https://github.com/neovim/neovim/pull/4131











nvim dev feature: C99
====================================================
Concrete result of refactoring: C99 + new compiler
features.

https://github.com/neovim/neovim/blob/master/src/nvim/eval/decode.c#L241-L249
    FUNC_ATTR_NONNULL_ALL
    FUNC_ATTR_WARN_UNUSED_RESULT
    ...









nvim feature: remote plugins
====================================================
jobstart('netcat', 'nc', ['-l', '1234'])















nvim feature: remote plugins
====================================================
RPC API supports plugins in any language, even haskell:
https://github.com/neovimhaskell/nvim-hs














nvim feature: --embed
====================================================
> Who doesn’t want better plugin support, a better
> GUI and embedding?
> —Bram, http://www.binpress.com/blog/2014/11/19/vim-creator-bram-moolenaar-interview/

vim +'help design-not'
> Use Vim as a component from a shell or in an IDE.










nvim features: :terminal
====================================================
> "it has a terminal built in, why not a web browser
> too?" 

We need to keep the `nvim` binary small and fast (multi-process support is on
the roadmap, so VimL can run asynchronously via IPC).

common misconception:
- "terminals are hard"
because...
- terminals are *hard to configure*
- XTerm source is insane[1]
- terminal apps break on unexpected/weird terminals

1: http://st.suckless.org/



nvim features: :terminal
====================================================
...but *implementing* a terminal is ~minimal code.

    $ curl http://dl.suckless.org/st/st-0.7.tar.gz|tar xz
    $ wc -l < st-0.7/st.c
    4404

    $ curl http://www.leonerd.org.uk/code/libvterm/libvterm-0+bzr681.tar.gz|tar xz
    $ cat libvterm*/src/*.c|wc -l
    4828

cf. Vim's screen.c:win_line(): 2860 LOC

"Terminal" in this century is a *basic* component.
The concept of a terminal (pty) is even abstracted in POSIX!


C code in the Vim tree for GUI/if_py/if_lua/etc:
  XXX LOC
C code in the Vim tree for `:shell`:
  XXX LOC
C code in the Nvim tree for `:terminal`:
  XXX LOC

Terminal is an "elementary component" that can and should be used to build new
plugins and applications--using the "accidental composability" that falls out of
the primitivity of TTYs (e.g., you can do almost anything via keybindings, which
means even basic terminal apps are "accidentally scriptable").


feature: shada
====================================================
- extensible
- structured (standard msgpack), no custom parsing
  needed
- combine any two shadas by concatenating the files












feature: meta/alt chords: <M-z>omg
====================================================
> I wish we hadn't used all the keys on the keyboard.
> —Bill Joy, Unix Review, August 1984














feature: built-in bracketed-paste mode
====================================================
just paste it




















feature: xdg base-directories
====================================================
:help xdg















feature: :CheckHealth
====================================================
- built-in healthchecks
- framework for writing healthchecks














feature: TextYankPost
====================================================
- v:event







???
====================================================
- "nvim is so much faster!" (no)
- "vim 8 has all major nvim features" (no)
  - :help nvim-features
- "nvim wants to make vim into an ide/emacs" (no)
  - > A-A-P GUI IDE is a framework in which separate tools can
    > work together. http://www.agide.org










"Is Nvim still relevant (since Vim8)?"
====================================================
- Fun question: Should vim_dev adopt the nvim tree?
- Thought-experiment: What are the major _technical_
  reasons that Vim could not adopt Nvim source tree?
  (cygwin, +cryptv, ...)
- Nvim builds on most platforms incl. illumos, arm,
  dragonflybsd,
  nixOS, ...









nvim results
====================================================
- nvim-qt is the _only_ cross-platform vim GUI (no
  gtk/kde needed!)
  - also NyaoVim et al. are cross-platform
- dozens of other GUIs
- "Totally did not influence" urgency of job-control
  in Vim

