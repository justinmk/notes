- refactoring work
    - eliminate rbuffer.c (redundant/unnecessary indirection):
        - https://github.com/neovim/neovim/pull/29141
        - https://github.com/neovim/neovim/pull/29106
    - eliminate libmsgpack (in favor of libmpack)
        - eliminate msgpack_sbuffer https://github.com/neovim/neovim/pull/29241

- software engineering, m'fcker:
    - gen_vimdoc.lua (lewis)
    - eliminate libmsgpack in favor of libmpack (bfredl)
        - https://github.com/neovim/neovim/pull/29241
        - https://github.com/neovim/neovim/pull/29358
        - https://github.com/neovim/neovim/pull/29467
- high leverage:
    - vim.with()
        - lewis + dundar + echa!
