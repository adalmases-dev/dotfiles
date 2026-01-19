-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

-- (Default) Interesting better up/down: "j/k" (j & gj at once)
-- (Default) Move to wingow with: "<Cntrl> + h/j/k/l"
-- (Default) Resize window: "<Cntrl> + arrows"
-- Move lines: Unsetting default for custom
vim.keymap.del({ "n", "i", "v" }, "<A-k>")
vim.keymap.del({ "n", "i", "v" }, "<A-j>")
map("n", "<D-j>", "<cmd>execute 'move .+' . v:count1<cr>==", { desc = "Move Down" })
map("n", "<D-k>", "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", { desc = "Move Up" })
map("v", "<D-j>", ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv", { desc = "Move Down", silent = true })
map("v", "<D-k>", ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv", { desc = "Move Up", silent = true })
-- (Default) Move buffers: "Shift + h/l" or "]/[ + b", Toggle back'n'forth: "<space> + bb", Delete current with "<space> + bd"
-- (Default) Escape and clear hlsearch with: "<Esc>"
-- (Default) Reset interface: "<Space> + ur"
-- (OVerwrite) Corrected n/N behaviour consistency using either "/" (forward search) or "?" (backward search) + Center
map("n", "n", "'Nn'[v:searchforward] . 'zzzv'", {
  expr = true,
  desc = "Next Search Result (Centered)",
})

map("n", "N", "'nN'[v:searchforward] . 'zzzv'", {
  expr = true,
  desc = "Prev Search Result (Centered)",
})
-- (Default) Add undo break-points on "," "." or ";"
-- Yank (copy) integration with clipboard:
map({ "n", "v" }, "y", '"+y', { desc = "Yank to system clipboard" })
map({ "n", "v" }, "Y", '"+Y', { desc = "Yank to end of line to system clipboard" })
map("n", "<C-c>", "<cmd>%y+<CR>", { desc = "Yank file to clipboard" })
-- Avoid ruining clipboard with x:
map({ "n", "v" }, "x", '"_x', { desc = "Deletion single char/ selection to void" })
-- Avoid runiing clipbarod with c:
map({ "n", "v" }, "c", '"_c', { desc = "Change single char / selection to void" })
-- Delete (not default Cut behaviour):
map({ "n", "v" }, "<leader>d", '"_d', { desc = "Delete to void" })
-- Paste without overwriting clipboard:
map("v", "p", '"_dP', { desc = "Paste without overwriting clipboard" })
-- yank to primary selection system
map("v", "<LeftRelease>", '<LeftRelease>"*ygv', { desc = "Yank mouse‐selection to primary selection register" })
-- (Default) Save file: "<Cntrl> + s"
-- (Default) keywordprg "<leader>K" - DON'T KNOW
-- (Default) Better indenting: "<" / ">"
-- (Default) Comenting: "gcc":
vim.keymap.del("n", "gcO")
vim.keymap.del("n", "gco")
-- (Default) Lazy: "<leader>l" ("<leader>L" for changelog)
-- (Default) New Empty File: "<leader>fn"
-- (Default) Diagnosis list toggle:
--          "<leader>xq" (Quickfix-- Quickfix list (Global)
map("n", "]q", "<cmd>cnext<CR>zz", { desc = "Next Quickfix Item" })
map("n", "[q", "<cmd>cprev<CR>zz", { desc = "Prev Quickfix Item" })
--          "<leader>xl" (Location list - local errors)
map("n", "]l", "<cmd>lnext<CR>zz", { desc = "Next Location Item" })
map("n", "[l", "<cmd>lprev<CR>zz", { desc = "Prev Location Item" }) --
--          "<leader>xx" (Diagnosis list)
local function diagnostic_goto_centered(next, severity)
  return function()
    vim.diagnostic.jump({
      count = (next and 1 or -1) * vim.v.count1,
      severity = severity and vim.diagnostic.severity[severity] or nil,
      float = true,
    })
    vim.schedule(function()
      vim.cmd("normal! zzzv")
    end)
  end
end
map("n", "]d", diagnostic_goto_centered(true), { desc = "Next Diagnostic" })
map("n", "[d", diagnostic_goto_centered(false), { desc = "Prev Diagnostic" })
map("n", "]e", diagnostic_goto_centered(true, "ERROR"), { desc = "Next Error" })
map("n", "[e", diagnostic_goto_centered(false, "ERROR"), { desc = "Prev Error" })
map("n", "]w", diagnostic_goto_centered(true, "WARN"), { desc = "Next Warning" })
map("n", "[w", diagnostic_goto_centered(false, "WARN"), { desc = "Prev Warning" })
-- (Default) Code Formatting: "<leader>cf"
-- (Default) UI Visible Stuff toggle options: "<leader>u..."
-- (Default) LazyGit plugin: "<leader>g..."
--
-- (Default) Quit session: "<leader>qq"
-- (Default) Open Terminal: "<leader>fT" (cwd) / "<leader>ft" (Root Dir)
-- (Default) Window options: "<leader>w..."
-- (Default) Tab options: "<leader><tab>..."
vim.keymap.del({ "n", "t" }, "<c-/>")
vim.keymap.del({ "n", "t" }, "<c-_>")

-- Extra escape combination
map({ "i", "v" }, "kj", "<Esc>", { desc = "<Esc>" })

-- Better Join Lines
map("n", "J", "mzJ`z", { desc = "Joint lines keeping the cursor" })

-- Centered down/up navigation:
map("n", "<C-d>", "<C-d>zz", { desc = "Scroll down and center" })
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll up and center" })

-- Re-indent paragraph keeping position:
map("n", "=ap", "ma=ap'a", { desc = "Reindent paragrpah (keep cursor position)" })

-- Add line(s) below
map("n", "<leader>o", function()
  local count = vim.v.count1
  local line = vim.fn.line(".")
  local lines = {}
  for i = 1, count do
    table.insert(lines, "")
  end
  vim.fn.append(line, lines)
end, { desc = "Add empty line(s) below" })

-- Add line(s) above
map("n", "<leader>O", function()
  local count = vim.v.count1
  local line = vim.fn.line(".") - 1
  local lines = {}
  for i = 1, count do
    table.insert(lines, "")
  end
  vim.fn.append(line, lines)
end, { desc = "Add empty line(s) above" })

-- Make file executable:
map("n", "<leader>fx", "<cmd>!chmod +x %<CR>", { desc = "Make current file executable", silent = true })

-- Insert mode (terminal like move)
map("i", "<C-a>", "<ESC>^i", { desc = "Move beginning of line" })
map("i", "<C-e>", "<End>", { desc = "Move end of line" })

-- THE ULTIMATE C++ BUILD KEYMAP!!!
local function cpp_build(mode)
  local root_dir = vim.fn.getcwd()
  if vim.fn.filereadable(root_dir .. "/CMakeLists.txt") == 0 then
    vim.notify("Not in a C++ project root (no 'CMakeLists.txt' found)", vim.log.levels.ERROR)
    return
  end

  -- Set build type
  local build_type = mode == "debug" and "Debug" or "RelWithDebInfo"
  vim.notify("🚀 C++ " .. build_type .. " Build Started...", vim.log.levels.INFO)

  -- Construct the CMake command
  local cmd = string.format(
    "cmake -B build -DCMAKE_BUILD_TYPE=%s -DCMAKE_EXPORT_COMPILE_COMMANDS=ON && cmake --build build -j",
    build_type
  )

  -- compile async
  vim.fn.jobstart(cmd, {
    stdout_buffered = true,
    stderr_buffered = true,
    on_exit = function(_, code)
      if code == 0 then
        -- Update symlink so clangd can find headers
        vim.fn.system("ln -sf build/compile_commands.json .")
        vim.cmd("LspRestart")
        vim.notify("✅ C++ " .. build_type .. " Build complete! LSP Refreshed.", vim.log.levels.INFO)
      else
        vim.notify("❌ C++ Build FAILED!", vim.log.levels.ERROR)
        -- Open terminal to show compile errors
        vim.cmd("belowright split | resize 15 | term " .. cmd)
      end
    end,
  })
end

map("n", "<leader>cbr", function()
  cpp_build("release")
end, { desc = "CMake Build (Release with Deb Info)" })

map("n", "<leader>cbd", function()
  cpp_build("debug")
end, { desc = "CMake Build (Debug Symbols)" })

-- THE ULTIMATE ROS COLCON BUILD KEYMAP!!!
local function ros2_build(mode)
  -- Check for workspace root
  local root_dir = vim.fn.getcwn()
  if vim.fn.isdirectory(root_dir .. "/src") == 0 then
    vim.notify("Not in a ROS 2 workspace root (no 'src' folder found)", vim.log.levels.ERROR)
    return
  end

  -- Set build type
  local build_type = mode == "debug" and "Debug" or "RelWithDebInfo"
  vim.notify("🚀 ROS 2 " .. build_type .. " Build Started...", vim.log.levels.INFO)

  -- Construct the colcon command
  local cmd = string.format(
    "colcon build --symlink-install --cmake-args -DCMAKE_BUILD_TYPE=%s -DCMAKE_EXPORT_COMPILE_COMMANDS=ON",
    build_type
  )

  -- complie async
  vim.fn.jobstart(cmd, {
    stdout_buffered = true,
    stderr_buffered = true,
    on_exit = function(_, code)
      if code == 0 then
        -- Update symlink so clangd can find headers
        vim.fn.system("ln -sf build/compile_commands.json .")
        vim.cmd("LspRestart")
        vim.notify("✅ROS 2 " .. build_type .. " Build complete! LSP Refreshed.", vim.log.levels.INFO)
      else
        vim.notify("❌ROS 2 Build FAILED!", vim.log.levels.ERROR)
        vim.cmd("belowright split | resize 15 | term " .. cmd)
      end
    end,
  })
end

map("n", "<leader>rb", function()
  ros2_build("release")
end, { desc = "Colcon Ros Build (Release with Deb Info)" })

map("n", "<leader>rd", function()
  ros2_build("debug")
end, { desc = "Colcon Ros Debug (Debug Symbols)" })
