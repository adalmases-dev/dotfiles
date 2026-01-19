-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- (Default) vim.g.mapleader = " "
-- (Default) vim.g.autoformat = true
-- Increase scrolloff
vim.opt.scrolloff = 10
-- Disable automatic pairs of "", ''. (), [],
vim.g.minipairs_disable = true
-- Handle ssh clipbaord through OSC 52 (Lazy vim sets clipbard to "" when SSH):
