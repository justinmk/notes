vim: iskeyword+== textwidth=52

Nvim FFS!
====================================================
             Features, Future, :smile!


Nvim FFS!
====================================================
for Nvim background/motivation see last year's talk:

https://www.youtube.com/watch?v=9Yf3dJSYdEA

review: Nvim goals
====================================================
- push Vim into new territory
- more-hackable vim
- better UX
- make vim (really) ubiquitous
- grow the vim community
- crush emacs

Nvim activity in 2017
====================================================
nvim
  contributors: 330 (Sept 2016: 262)
  total commits: 9251 (Sept 2016: 6479) since 2014

vim
  total commits: 7732 (Sept 2016: 6553) since 2004

about me
====================================================
- Nvim maintainer.
- I'm nobody. That's a feature.

Nvim goals: initial fundraiser
====================================================
~ New, modern multi-platform UI.
  - oni?
+ New testing UI written in Lua
+ New plugin architecture, with legacy compat layer
+ Full port of the editor IO to libuv
+ Cross-platform job control
+ Distributions for Windows, Linux, Mac.  <<<<

Nvim 2017: hackable vim
====================================================
- hackable vim:
  https://github.com/neovim/neovim/wiki/Related-projects
  - 24 API clients
  - 18 UIs
- easiest way to install vim on any major OS
  https://github.com/neovim/neovim/releases


Nvim 2017: API clients
====================================================
- new API client for racket
  https://gitlab.com/HiPhish/neovim.rkt
- refactored node client:
  https://github.com/neovim/node-client

Nvim 2017: community
====================================================
- Drew Neil's _Modern Vim_
  http://vimcasts.org/blog/2017/05/working-title-modern-vim/
- Homebrew core formula
  http://formulae.brew.sh/formula/neovim
  - >100k installs https://brew.sh/analytics/install


Nvim major features  https://neovim.io
====================================================
- API
- decoupled, evented UI
- remote plugins, incl. lang host coprocesses
- XDG support
- Lua
- shada
- :terminal
- inccommand

Review: :terminal
====================================================
> "It has a terminal, why not a web browser too?"

Last year: Terminal is an elementary component (like
buffer, pipe, pty), not a sign of bloat.

terminal.c is ~1k LOC.
Vim's screen.c:win_update() *function* is 1197 LOC.

  $ ohcount nvim/src
  Language          Files       Code
  ----------------  -----  ---------
  c                   238     174837
  lua                   5       6461

  $ ohcount vim/src
  Language          Files       Code
  ----------------  -----  ---------
  c                   173     317691
  vim                 117      10353

vi evolution (identical slide from last year)
====================================================
ed:   line-addressable editing language
vi:   normal-mode (AKA ex 2.0)
vim:  +textobjects, +eval (VimL)
nvim: --embed, API

^ No mention of job control, :terminal.
  Those are features, not inflections.

Nvim goals: long-term
====================================================
- Ubiquity: Embed everywhere
  - "Vim" => "vim": commoditize vim
- Flexibility: Extensible in any programming language
- Flexibility: More powerful GUIs

https://neovim.io  <-- top of the page



Nvim 0.1.7 feature: 'inccommand'
====================================================
:help 'inccommand'
:%s/vim/Nnnnnnvim/g


Nvim 0.2.0 features
====================================================
Windows support
  - includes a GUI, curl.exe and other utilities
  - :terminal in 0.2.1
externalized widgets: popupmenu, tabline
'inccommand'
"Vim 8" features: partials, lambdas.


Nvim 0.2.0 feature: 'guicursor' in TUI
====================================================
How do you feel about Internet Explorer 6?
...

Nvim 0.2.0 feature: 'guicursor' in TUI
====================================================
How do you feel about urxvt, Konsole, and other
non-xterm-compliant terminal emulators?

TUI: the hot new user interface
====================================================
:help 'guicursor'

DECRQSS: a hot new vt100 terminal feature
supported by:
    - pangoterm
    - xterm
not supported by:
    - urxvt
    - libVTE
    - iTerm2
    - Konsole
    - alacritty

Lua: first-class alternative to VimL
====================================================
Goal from last year! Implemented.

RPC API supports plugins in any language, but
"ubiquity is king".
Lua is designed for embedding.
Lua is fast; LuaJit is ridiculously fast.

Ideas:
  - init.vim -> init.lua
  - multi-line statements/strings
  - coroutines

VimL: feature
====================================================
:help input()-highlight

VimL: future
====================================================
parser, expose AST
https://github.com/neovim/neovim/pull/7234


Nvim 0.2.1 feature: window-local syntax groups
====================================================
Reassign built-in syntax groups, per-window.
:help 'winhighlight'


Nvim 0.2.1 feature: improved UI API
====================================================
demo: ST ActualVim

Nvim 0.2.1 feature: improved UI API
====================================================
demo: VSCodeVim


Nvim 0.2.1 API feature: nvim_execute_lua()
====================================================
n.request('nvim_execute_lua', 'return "foo"', [])

Nvim 0.2.1 API feature: nvim_get_keymap()
====================================================
:help nvim_get_keymap('')
* Precursor to API for keymap docs.
* Useful for:
  - fuzzy finders/completion engines (fzf, denite)
  - GUIs
  - other clients


Nvim 0.2.1 API feature: menu_get()
====================================================
:help menu_get()

    :runtime menu.vim
    :echo menu_get('Syntax','')

* Useful for:
  - fuzzy finders/completion engines (fzf, denite)
  - GUIs
  - other clients

Nvim future: extended marks
====================================================
https://github.com/neovim/neovim/pull/5031
- unlimited marks
- namespaced
- marks follow line insertions/joins/deletes/splits,
  char inserts/deletes, blockwise inserts/deletes ...
API:
- create namespaced marks:
  nvim_buf_set_mark(buf, namespace, id)
- get marks in a line range:
  nvim_buf_get_marks(buf, namespace, {id or range})


Nvim future: floating window
====================================================
Show window at any (x,y) position.
Useful for:
- complex menus, selection UIs
- dialogs
https://github.com/neovim/neovim/pull/6619



Vim development lifecycle
====================================================
   receive bug report for :autocmd segfault
    \                                      \
     fix :autocmd segfaults                 |
     fix TINY build for Tony M.            /
      \                        ^._________/
       \
       Nvim designs, implements new feature
        that everyone wants but "no one needs".
         \
  ^       Goog coworkers ask about Neovim feature -.
  |        \                                    ^._/
   \        Have a look at Neovim impl.
    \        Don't like it.
     \        \
      `------- commit WIP to Vim master branch

:smile
====================================================
Feature that everyone wants but "no one needs":
                    job-control

:smile
====================================================
Feature that everyone wants but "no one needs":
                     :terminal

:smile
====================================================
Feature that everyone wants but "no one needs":
                    multicursor

multiple cursors
====================================================
You will love it. How do I know?
From the Sublime Text docs:
> Any praise for multiple cursors is an understatement.

multiple cursors
====================================================
- multicursors are vim-like: think of them as
  "enhanced marks"
- Like 'inccommand', it is a zero-cost net gain
- Semantic "ring" of recent actions is a killer
  feature.
- Serendipitous results:
  - Reuse shada work for save/restore of registers.
  - Reuse mark_ext work for tracking edits.
  - Manging "global state" as a context is key to
    p2p nvim ...

multiple ... contexts
====================================================
Replace "cursor" with "context", now it's obvious.
(call it "multiple marks", "enhanced macros", whatever.)

multicursor behavior
====================================================
undo
redo
dot-repeat
cursor-local registers
macro

multicursor behavior
====================================================
Q
q<BS>

multicursor design: atoms
====================================================
macro: lllljjj3jddukdiw
       ^^^ where are the atoms?

model: user actions are atoms
state machine: cascade atom at state transition

multicursor demo
====================================================
nvim_get_atoms()

:echo filter(nvim_get_atoms(),'v:val.keys!~#":"')[-1].keys

multicursor design: mode?
====================================================
Multicursor is not a "mode" in the Vim sense of
a mode (Normal, Insert, Visual, Terminal, ...).
Multicursor means only this:
1. Buffer has multiple cursors ("super marks")
2. Some (not all) user actions "cascade" to all
   cursors.

Normal-mode with multiple cursors is just normal-mode
with extra effects.

multicursor design: mode?
====================================================
- No new "multicursor mode".
- No `:mnoremap` mapping namespace
- No "-- MULTICURSOR --" message.

multicursor design: API
====================================================
There is an API, of course!
- User/scripts can add/remove cursors at any time.
- Mappings are subject to debate, but we'll offer
  mouse-placement by default, somehow.

multiple cursors
====================================================
:cursordo (todo: :markdo)

Q: How does it differ from :global, or
   `:for list_of_positions`?
A: each iteration tracks edits




Nvim future
====================================================
Muse for devs that want to implement major features
in vim.









------------end-----------
====================================================
homebrew stats
debian popcon:
https://qa.debian.org/popcon.php?package=vim
https://qa.debian.org/popcon.php?package=neovim
  - compare vim-nox, vim-gtk

`vim` debian pkg: no interpreters, no X
`vim-nox` debian pkg: all interpreters, no X
so ~90% of the people who install vim on debian don't have lua/ruby/python
`vim-runtime`     86680   43.28%  991     4384    2.34%
Best guesstimate for "explicitly installed" is probably vim-runtime: it is
pulled in by everything except vim-tiny.
    installs: https://qa.debian.org/popcon-graph.php?packages=vim-runtime%2Cneovim-runtime&show_installed=on&want_legend=on&want_ticks=on&from_date=&to_date=&hlght_date=&date_fmt=%25Y-%25m&beenhere=1
    regulars: https://qa.debian.org/popcon-graph.php?packages=vim-runtime%2Cneovim-runtime&show_vote=on&want_legend=on&from_date=&to_date=&hlght_date=&date_fmt=%25Y-%25m&beenhere=1


Nvim outcomes
====================================================
> 10: What does the future hold for Vim?
> "Nothing spectacular. Mainly small improvements.
> -- Bram Moolenaar, 2014 Nov.
https://www.binpress.com/blog/2014/11/19/vim-creator-bram-moolenaar-interview/

  \
   ... since then: jobs, :terminal
