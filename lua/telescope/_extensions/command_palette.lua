local themes = require("telescope.themes")
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local entry_display = require("telescope.pickers.entry_display")
local conf = require("telescope.config").values
local resolve = require "telescope.config.resolve"

local CpMenu = require("command_palette").CpMenu

local function setup(cpMenu)
    require("command_palette").CpMenu = cpMenu or {}
    CpMenu = require("command_palette").CpMenu
end

function themes.vscode(opts)
    opts = opts or {}
    local theme_opts = {
        theme = "dropdown",
        results_title = false,
        sorting_strategy = "ascending",
        layout_strategy = "vertical",
        layout_config = {
            anchor = "N",
            prompt_position = "top",
            width = function(_, max_columns, _)
                return math.min(max_columns, 120)
            end,
            height = function(_, _, max_lines)
                return math.min(max_lines, 15)
            end,
        },
    }
    if opts.layout_config and opts.layout_config.prompt_position == "bottom" then
        theme_opts.borderchars = {
            prompt = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
            results = { "─", "│", "─", "│", "╭", "╮", "┤", "├" },
            preview = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
        }
    end
    return vim.tbl_deep_extend("force", theme_opts, opts)
end

local function list_of_commands()
    local results = {}
    for i, val in pairs(CpMenu) do
        results[i] = val
    end
    return results
end

local function commands(opts, table)
    opts = opts or {}
    pickers.new(opts, {
        prompt_title = "Command palette",
        finder = finders.new_table({
            results = table,
            entry_maker = function(entry)
                local results_win = vim.api.nvim_get_current_win()
                local w = vim.api.nvim_win_get_width(results_win)
                local h = vim.api.nvim_win_get_height(results_win)
                local width = conf.width or conf.layout_config.width or
                    conf.layout_config[conf.layout_strategy].width or vim.o.columns
                local tel_win_width = resolve.resolve_width(width)(nil, w, h) - #conf.selection_caret

                -- NOTE: the width calculating logic is not exact, but approx enough
                local displayer = entry_display.create({
                    items = {
                        { width = width },
                        { remaining = true },
                    },
                })

                local function make_display()
                    return displayer({
                        { entry[1] },
                    })
                end

                return {
                    value = entry,
                    display = make_display,
                    ordinal = string.format("%s", entry[1]),
                }
            end,
        }),
        sorter = conf.generic_sorter(opts),
        attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
                actions.close(prompt_bufnr)

                local selection = action_state.get_selected_entry()
                if selection.value[3] == 1 then
                    vim.schedule(function()
                        vim.cmd("startinsert! ")
                    end)
                end
                vim.api.nvim_exec(selection.value[2], true)
            end)
            return true
        end,
    }):find()
end


-- CpMenu = {
--     { "Debug: Pause",                          ":lua require'dap'.pause()" },
--     { "Debug: Step into",                      ":lua require'dap'.step_into()" },
--     { "Debug: Step back",                      ":lua require'dap'.step_back()" },
--     { "Debug: Step over",                      ":lua require'dap'.step_over()" },
--     { "Debug: Step out",                       ":lua require'dap'.step_out()" },
--     { "Debug: Frames",                         ":lua require'telescope'.extensions.dap.frames{}" },
--     { "Debug: Current scopes",                 ":lua ViewCurrentScopes(); vim.cmd(\"wincmd w|vertical resize 40\")" },
--     { "Debug: Current scopes floating window", ":lua ViewCurrentScopesFloatingWindow()" },
--     { "Debug: Current value floating window",  ":lua ViewCurrentValueFloatingWindow()" },
--     { "Debug: Commands",                       ":lua require'telescope'.extensions.dap.commands{}" },
--     { "Debug: Configurations",                 ":lua require'telescope'.extensions.dap.configurations{}" },
--     { "Debug: Repl",                           ":lua require'dap'.repl.open(); vim.cmd(\"wincmd w|resize 12\")" },
--     { "Debug: Close",                          ":lua require'dap'.close(); require'dap'.repl.close()" },
--     { "Debug: Run to cursor",                  ":lua require'dap'.run_to_cursor()" },
--     { "Debug: Continue",                       ":lua require'dap'.continue()" },
--     { "Debug: Clear breakpoints",              ":lua require('dap.breakpoints').clear()" },
--     { "Debug: Breakpoints",                    ":lua require'telescope'.extensions.dap.list_breakpoints{}" },
--     { "Debug: Toggle breakpoint",              ":lua require'dap'.toggle_breakpoint()" },
-- }

local function run()
    commands(require("telescope.themes").vscode({}), list_of_commands())
end

return require("telescope").register_extension({
    setup = setup,
    exports = {
        -- Default when to argument is given, i.e. :Telescope command_palette
        command_palette = run,
    },
})
