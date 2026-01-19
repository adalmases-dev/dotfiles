-- Debug:
--  * Set a breakpoint with <leader>db.
--  * Run a node via your terminal (ros2 run ...).
--  * Press <leader>dc (Continue/Start) and choose "Attach to Running Node".
return {
  "mfussenegger/nvim-dap",
  opts = function()
    local dap = require("dap")

    --  Fallback in case C++ Extra didn't set the debbugger engine yet
    if not dap.adapters.codelldb then
      dap.adapters.codelldb = {
        type = "server",
        port = "${port}",
        executable = {
          command = "codelldb",
          args = { "--port", "${port}" },
        },
      }
    end

    -- Configurations for C/C++
    for _, lang in ipairs({ "c", "cpp" }) do
      dap.configurations[lang] = {

        -- Generic Launch
        {
          type = "codelldb",
          request = "launch",
          name = "C++ Executable",
          program = function()
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
          end,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
          runInTerminal = true, -- avoid DAP to swallow logs
        },

        -- ROS 2 Nodes
        -- (binaries are inside install/lib/<package_name>)
        {
          type = "codelldb",
          request = "launch",
          name = "Launch ROS Node (Install Dir)",
          program = function()
            -- Speeds up finding your ROS nodes
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/install/", "file")
          end,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
          runInTerminal = true, -- avoid DAP to swallow logs
          sourceMap = {
            ["/src"] = "${workspaceFolder}/src", -- find the code that sits in src!
          },
        },

        -- ROS 2 Launch Files
        -- ("Attach" Strategy)
        {
          type = "codelldb",
          request = "attach",
          name = "Attach to Process (For Launch Files/Running Nodes)",
          pid = require("dap.utils").pick_process,
          cwd = "${workspaceFolder}",
        },
      }
    end
  end,
}
