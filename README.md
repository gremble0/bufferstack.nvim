# bufferstack.nvim
A plugin that fixes the unintuitive behavior of the `:bprevious` and `:bnext` commands in vim by providing two "patched" commands `require("bufferstack").bprevious` and `require("bufferstack").bnext`. The plugin maintains an internal stack (hence the name) that is rotated left or right whenever the `bprevious` or `bnext` commands are invoked.

## Differences from default behavior
In default vim when you do `:bprevious` or `bnext` it will simply look at the list of open buffers and select the buffer with the closest buffer id to the one that is active. This means that if you for example have three open buffers - 1, 2, 3 - and you do `:bprevious` while in buffer 2 it will take you to buffer 1. If you then open buffer 3 and do `:bprevious` again it will take you to buffer 2, which is probably not what you wanted to do. With this plugin if you were in this same scenario, and you invoked `require("bufferstack").bprevious()` it would take you from buffer 3 to buffer 1, which i find more useful.

## Setup
Use your favourite package manager to import the plugin (following is how to do it with lazy.nvim)
```lua
{
  "gremble0/bufferstack.nvim",
  config = function()
    -- Here you have two alternatives for initializing the plugin and binding its functions
    -- Alternative 1 - using options in the setup function
    require("bufferstack").setup {
      -- NOTE: All these options are optional, meaning you could assign 0, 1 or 2 of the keybinds
      bprevious = "<C-p>", -- Automatically assigns this string to the modified bprevious function in normal mode
      bnext = "<C-n>", -- Automatically assigns this string to the modified bnext function in normal mode
    }
    
    -- Alternative 2 - plain setup and manual keybinding:
    require("bufferstack").setup()
    vim.keymap.set("n", "<C-p>", require("bufferstack").bprevious, { desc = "Changes to the previous buffer" })
    vim.keymap.set("n", "<C-n>", require("bufferstack").bnext, { desc = "Changes to the previous buffer" })
    -- assign in other modes as well if you wish...
  end
},
```
