# FORKED
This is a fork which adjusts the plugin a little bit.
- You will not see the keymaps nor commands that the description executes. This means there is only one column: a textual description of the command.
- You no longer need to select a category first, which means that a much more speedy selection overall is achieved.
- You can now use the global lua variable `Previous_palette_command`, which contains the text inserted into the vim cmdline for the previously executed command.

# Setting it up

Assuming that you already have telescope.nvim, it's as simple as

```
require('telescope').setup({
  extensions = {
    command_palette = {
      { "Debug: Pause",                          ":lua require'dap'.pause()" },
      { "Debug: Step into",                      ":lua require'dap'.step_into()" },
      { "Debug: Step back",                      ":lua require'dap'.step_back()" },
      { "Debug: Step over",                      ":lua require'dap'.step_over()" },
      { "Debug: Step out",                       ":lua require'dap'.step_out()" },
      { "Debug: Frames",                         ":lua require'telescope'.extensions.dap.frames{}" },
      { "Debug: Current scopes",                 ":lua ViewCurrentScopes(); vim.cmd(\"wincmd w|vertical resize 40\")" },
      { "Debug: Current scopes floating window", ":lua ViewCurrentScopesFloatingWindow()" },
      { "Debug: Current value floating window",  ":lua ViewCurrentValueFloatingWindow()" },
      { "Debug: Commands",                       ":lua require'telescope'.extensions.dap.commands{}" },
      { "Debug: Configurations",                 ":lua require'telescope'.extensions.dap.configurations{}" },
      { "Debug: Repl",                           ":lua require'dap'.repl.open(); vim.cmd(\"wincmd w|resize 12\")" },
      { "Debug: Close",                          ":lua require'dap'.close(); require'dap'.repl.close()" },
      { "Debug: Run to cursor",                  ":lua require'dap'.run_to_cursor()" },
      { "Debug: Continue",                       ":lua require'dap'.continue()" },
      { "Debug: Clear breakpoints",              ":lua require('dap.breakpoints').clear()" },
      { "Debug: Breakpoints",                    ":lua require'telescope'.extensions.dap.list_breakpoints{}" },
      { "Debug: Toggle breakpoint",              ":lua require'dap'.toggle_breakpoint()" },
    }
  }
})

require('telescope').load_extension('command_palette')
```

Note that this example requires nvim-dap to work with the debug commands. You could then map something like

```
vim.keymap.set('n', '<D-P>', function() vim.cmd(":Telescope command_palette") end, {})
```

Which means `cmd+shift+P`. You are now ready to become a true VS-Coder!

The plugin also exports a global variable, `Previous_palette_command`, which simply contains whatever you just selected. It's good for repeating e.g. the command for running a test. You could map it to something like:

```
vim.keymap.set('n', '<D-;>', function() vim.cmd(Previous_palette_command) end, {})
```

You can now hit `cmd-;` to repeat the last command you executed using the plugin.
