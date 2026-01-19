return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      clangd = {
        capabilities = {
          offsetEncoding = { "utf-16" }, -- Fixes common "multiple different client offset_encodings" warning
        },
        -- filetypes = { "c", "cpp" },
        cmd = {
          "clangd",
          "--background-index",
          "--clang-tidy",
          "--header-insertion=iwyu",
          "--completion-style=detailed",
          "--function-arg-placeholders",
          "--fallback-style=llvm",
          -- essential to find std headers
          "--query-driver=/usr/bin/c++,/usr/bin/g++,/usr/bin/gcc",
        },
      },
      pyright = {
        settings = {
          python = {
            analysis = {
              extraPaths = (function()
                local paths = { "src" }
                -- Help pyright to find ROS packages in the install folder dynamically
                local lib_path = vim.fn.getcwd() .. "/install/lib"
                if vim.fn.isdirectory(lib_path) == 1 then
                  local handle = vim.uv.fs_scandir(lib_path)
                  if handle then
                    while true do
                      local name, type = vim.uv.fs_scandir_next(handle)
                      if not name then
                        break
                      end
                      if type == "directory" and name:match("^python") then
                        table.insert(paths, "install/lib/" .. name .. "/site-packages")
                      end
                    end
                  end
                end
                return paths
              end)(),
            },
          },
        },
      },
    },
  },
}
