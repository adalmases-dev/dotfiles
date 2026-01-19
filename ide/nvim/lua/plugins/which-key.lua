return {
  "folke/which-key.nvim",
  opts = {
    -- ... your existing opts (preset = "classic", etc.)
    spec = {
      { "<leader>r", group = "ROS", icon = " " }, -- This renames the group from "Remap" (or whatever it was) to "ROS"
      { "<leader>cb", group = "CMake Build", icon = " " }, -- This renames the group from "Remap" (or whatever it was) to "ROS"
    },
  },
}
