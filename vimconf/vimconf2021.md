Neovim: the work continues
==========================

Neovim roadmap 2021

* What you will learn:
    * Neovim's upcoming plans
    * Neovim's raison d'etre
* Roadmap
    * moar Lua
    * LuaRocks?
    * API guidelines
        * reach maturity + faster iteration of frameworks like vim.diagnostics, vim.lsp
* Themes: Extensibility (Versatility), Usability (Minimalism), Leverage
    * Leverage:
        * Vim's legacy (plugins + popularity) = leverage.
        * Lua, Lua, Lua. Lua's maturity: multiple implementations, advanced JIT, community knowledge, bindings, transpilers, …
            * "Roblox is basically Neovim plugin bootcamp." — dundargoc
        * libuv (nodejs core, luv/vim.loop)
        * Elephant in the room: how to harness momentum?
            * Nvim has reached escape velocity, question is can we channel the
              energy productively, or will we end up with a PHP tangle of
              isolated features. The best projects have "conceptual integrity" https://wiki.c2.com/?ConceptualIntegrity
            * vim.lsp, nvim-lspconfig
            * vim.treesitter, nvim-treesitter
            * vim.diagnostic
        * Lack of process can actually be *slower*.
            * Lack of guidelines/patterns/practices causes us to spend time explaining and discussing expected practices.
            * Lack of automated formatting resulted 
        * Constraints Liberate, Liberties Constrain — Runar Bjarnason https://www.youtube.com/watch?v=GqmsQeSzMdw
    * Minimalism:
        * Ergonomics
        * Interfaces
            * Key point: humans can adapt to breaking changes, unlike
              downstream software. So changing UI to gain a permanent
              improvement, is worth the cost of a one-time downstream (human)
              rebuild.
                * Humans are fault-tolerant. https://en.wikipedia.org/wiki/Fault_tolerance
        * Deletion is synthesis. Don't accumulate indiscriminately.
            * Vim is _not_ minimalism. I'm interested in cutting away the dead
              parts and synthesizing concepts, because smaller scope helps
              users forever. (Whereas _keeping_ the dead parts only helps
              a fixed number of users temporarily. Wrong tradeoff.)
        * Vim9script is another 2+ years journey into NIH anti-minimalism.
          "More of the same". Nvim Lua again builds on _legacy_ (of Lua:
          fennel, teal, luarocks, …) + _minimalism_ of language design.
    * Versatility: Vim was weak in versatility:
        - poor UX for running scripts
        - weak embedding story
        - weak remote consumer story
* LSP
* Lua
    * https://github.com/nanotee/nvim-lua-guide
    * velocity: numerous new contributors, vim.diagnostic emerged quickly from the vim.lsp.diagnostic
        * https://github.com/neovim/neovim/issues/15154
            * "The rise of nvim-lint, null-ls, EFM, etc. has shown that users will take advantage of a common diagnostic interface. We should extract the diagnostic module into something more general."
            * "ALE and vim-lsp ... since Vim doesn't have a unified diagnostic API, they both display diagnostic in their own way."
            * implementation turnaround: ~2 weeks
            * bonus: namespace-driven
* Fork
    * Nvim's original goal was to restart Vim development (which had stalled for 2+ years).
    * Vimtory lap: Nvim's original goals were achieved. Nvim stands on its own.
      Users can choose Vim if they like Vim's direction (Vim9script), or Nvim
      if they like Nvim's trajectory (Lua, RPC UI, embedding, API, ergonomics).
    * Vim9script is an invitation to diverge.
    * Vim9script lacks Lua leverage (fennel, teal, etc.)
    * Vim9script type system is mostly a bolt-on and mishmash of javascript and python ideas.
        * With Lua, we can wait and see what emerges over time and potentially choose something like Teal if it gains maturity proportional to Typescript.
    * POSIX vi compat is 100% cost.
        * Doesn't gain anything for Vim: the presence of vim-tiny on Linux
          distributions doesn't bring any users to Vim. These are just vi
          users, and they would be happier with nvi anyways (which is faster).
        * Linux users have to install full Vim if they want to use full Vim.
        * BSD includes nvi, not vim-tiny.
        * It has a great cost (permanently bad CLI options/behavior, perpetual
          compromises to satisfy lack of `FEAT_EVAL`)
        * nvi exists and is much faster: https://github.com/neovim/neovim/issues/10338
        * POSIX vi is 1% of Vim's codebase.
* Energy
    * huge energy behind Lua, LSP, nvim-treesitter, RPC UIs, API. Our task is to channel that energy to maximize leverage.
    * code ownership / delegation
        * nvim-lspconfig
        * nvim-treesitter
    * Documentation: API guidelines, runbooks, quality checks, culture
        * Document patterns/practices for core contributors and plugin authors.
        * Document API patterns.
    * automation: automated PRs, automated formatting (uncrustify), automated vim-patch
* towards ACME/SAM...
    * small improvements to ancient commands allow using the editor as a true REPL environment (like ACME):
        * "echo foo|nvim"
        * :[range]source, :source without file, :source on Lua files
* Automation
    * formatting is undifferentiated effort
        * cf. PL design discussions: should spend that time building libraries, not language features...
* Plugin model (passive)
    * Lua plugins fully supported
* Theme: synthesis is high-value
    * Single source of truth:
        * users and contributors know where to find answers
        * consistent names
        * avoid redundant/overlapping mechanisms/concepts
        * economy of concepts
* Technical direction
    * core => Lua
        * api/*
        * eval.c
        * option.c
    * Lua standard plugins
    * Lua healthchecks
    * nvim -l
    * expose more internals from `nvim_get_context`
    * architectural gains from decoupled UI
        * more UI events/structure
* Break dance
    * Back-compat remains the prime directive for RPC API
    * But now we distinguish between "degraded UX" vs "broken UX".
        * "degraded UX" means you can still use the editor and most features.
    * So we are now electing to break some things in the Lua layer and modules like vim.diagnostic, vim.treesitter, vim.lsp
        * MITIGATION: Fast-follow stable releases with the breaking changes, to avoid community "split brain"
        * MITIGATION: clear deprecations (:help deprecated, error("foo is deprecated, use bar"))
        * MITIGATION: experimental/private APIs
        * GAIN: spend less time dithering and trying to predict the future
        * Again, we will never break RPC clients because this can be catastrophic.
    * Simulated annealing: the break dance chaos will converge and settle into
      a tranquile, calm, quasi-optimal interface. We think this is better than
      being stuck with bad interfaces forever, as long as the system degrades
      gracefully, not catastrophically.
    * 3+ half-working options APIs:
        * nvim_get_option
        * vim.o
        * vim.opt
        doesn't do whatever anyone wants, after we already knew that nvim_get_option didn't do what anyone wnats... so we added ANOTHER API, vim.opt
how many times are we going to get it wrong
btw vim.opt doesn't do what people expect, either :facepalm: 
anyways, it's fine to make mistakes if (1) we deprecate aggressively, and (2) try to make APIs future-proof as a habit (opt param)
* Connected graphs are combinatorially more valuable than
    * Memetic Evolution: "There’s a symmetry between the theory of epistemology and the theory of evolution." https://nav.al/evolution
    * structured data vs raw (unstructured)
    * code reuse: libuv + Lua + treesitter is combinatorially more valuable for the world than creating a new language (Vim9script)
        * Neovim:
            * contain Vim, shrink it where possible, build value vertically. Don't expand it horizontally.
            * use constraints (minimalism) to drive creative, reusable solutions.
    * air travel, internet connected humans and yield exponential value
    * instead of "standing on the shoulders of giants", "banding the folders of alliance"
        * recursing human intellects
* Vimscript: 30 years of bugs
    * Vim9script:
        * 1200 commits (git log --oneline --grep Vim9 | wc -l))
        * 2+ years
        * 20k lines of C code
    * Vimscript: 30 years, still fixing bugs in the core language
        * "8.2.3478: still crash with error in :catch and also in :finally"
* Treadmills: high-churn topics, time-sensitive "data"
    * Avoid treadmills in core: lspconfig, treesitterconfig, runtime/
    * Speaking of treadmills...
        patch 8.2.3484: crash when going through spell suggestions
        patch 8.2.3480: test does not fail without the fix for a crash
        patch 8.2.3479: crash when calling job_start with an invalid argument
        patch 8.2.3478: still crash with error in :catch and also in :finally
        patch 8.2.3472: other crashes with empty search pattern not tested
        patch 8.2.3471: crash when using CTRL-T after an empty search pattern
* "Avoiding treadmills" is immutability: eliminate entire classes of uncertainty/nondeterminism (branching is impossible)
    * Allows you to focus on smaller areas of interest
    * Allows you to focus on valuable activity instead of treadmill activity
