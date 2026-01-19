# Ensure at leat these are of mason
return {
  "mason-org/mason.nvim",
  opts = {
    ensure_installed = {
      -- --- LSPs (Language Servers) ---
      "bash-language-server",
      "clangd",
      "neocmakelsp",
      "docker-language-server",
      "json-lsp",
      "lua-language-server",
      "marksman",
      "pyright",
      "yaml-language-server",

      -- --- Debuggers (DAP) ---
      "codelldb", -- for C++
      "debugpy",  -- for Python

      -- --- Linters & Formatters ---
      "clang-format",    -- C++ Formatter
      "cmakelang",       -- CMake Formatter
      "cmakelint",       -- CMake Linter
      "hadolint",        -- Docker Linter
      "markdownlint-cli2",
      "markdown-toc",
      "mypy",            -- Python Linter
      "shellcheck",      -- Bash Linter
      "shfmt",           -- Bash Formatter
      "stylua",          -- Lua Formatter
    },
  },
}
