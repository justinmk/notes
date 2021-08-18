Neovim: the work continues
==========================

Neovim roadmap 2021

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
    * at this point, Nvim stands on its own. users can choose Vim if they like
      Vim's direction (Vim9script), or Nvim if they like Nvim's trajectory (Lua,
      embedding, API, ergonomics).
* Vimtory lap: Nvim's original goals were achieved.
* Energy
    * huge energy behind Lua, LSP, nvim-treesitter, RPC UIs, API. Our task is to channel that energy to maximize leverage.
    * code ownership / delegation
        * nvim-lspconfig
        * nvim-treesitter
    * automation: automated PRs, automated formatting (uncrustify), automated vim-patch
* towards ACME/SAM...
    * small improvements to ancient commands allow using the editor as a true REPL environment (like ACME):
        * "echo foo|nvim"
        * :[range]source, :source without file, :source on Lua files
* tabs-vs-spaces, formatting, is undifferentiated effort
    * very similar to PL design discussions: should spend that time building libraries, not language features...
