return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      -- Extend the default list from https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/plugins/treesitter.lua
      vim.list_extend(opts.ensure_installed, {
        "cpp",
        "cmake",
        "rust",
        "dockerfile",
      })
    end,
  },
}
