# bufferstack.nvim
A plugin that fixes the unintuitive behavior of the `:bprevious` and `:bnext` commands in vim by providing two patched commands `require("bufferstack").bprevious` and `require("bufferstack").bnext`, alternatively you can use the user commands `:Bprevious` and `:Bnext`. The plugin maintains an internal stack (hence the name) that is rotated left or right whenever the `bprevious` or `bnext` commands are invoked.

## Differences from default behavior
In default vim when you do `:bprevious` or `bnext` it will simply look at the list of open buffers and select the buffer with the closest buffer id to the one that is active. This means that if you for example have three open buffers - 1, 2, 3 - and you do `:bprevious` while in buffer 2 it will take you to buffer 1. If you then open buffer 3 and do `:bprevious` again it will take you to buffer 2, which is probably not what you wanted to do.

With this plugin if you were in this same scenario, and you invoked `require("bufferstack").bprevious()` it would take you from buffer 3 to buffer 1, which i find more useful.

The plugin also allows for keeping track of more buffers than the normal buffer list in vim through the `filter_buffers_func` option. If you set this to `vim.api.nvim_buffer_is_valid` it will keep unloaded buffers in the bufferstack allowing you to reopen them with the bprevious command. If you don't set this option it will use `vim.api.nvim_buf_is_loaded` which will only select from the loaded buffers visible when you do `:buffers`

## Setup
Use your favourite package manager to import the plugin (following is how to do it with lazy.nvim) *Important: Do not lazy load this plugin*, it needs to call setup() immediately to keep track of what order buffers have been opened in.
```lua
{
  "gremble0/bufferstack.nvim",
  opts = {
    -- This is usually either vim.api.nvim_buffer_is_loaded or vim.api.nvim_buffer_is_valid,
    -- alternatively you could make your own variant. It decides what classifies an open buffer
    filter_buffers_func = vim.api.nvim_buf_is_loaded,

    -- Set keybinds in normal mode for the two functions
    bprevious = "<C-p>",
    bnext = "<C-n>",
  },
}

-- If you want to assign the keybinds manually (or want them in more modes
-- than just normal) you can omit them from `opts` and set them yourself like this:
local bufferstack = require("bufferstack")
vim.keymap.set({ "n", "v" }, "<C-p>", bufferstack.bprevious, { desc = "Changes to the previous buffer" })
vim.keymap.set({ "n", "v" }, "<C-n>", bufferstack.bnext, { desc = "Changes to the next buffer" })
```
