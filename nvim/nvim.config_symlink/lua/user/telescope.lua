local status_ok, telescope = pcall(require, "telescope")
if not status_ok then
  return
end

local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')

local open_selected_as_buffers = function(prompt_bufnr)
  local picker = action_state.get_current_picker(prompt_bufnr)
  local selections = picker:get_multi_selection()

  if vim.tbl_isempty(selections) then
    actions.select_default(prompt_bufnr)
    return
  end

  actions.close(prompt_bufnr)
  for _, entry in ipairs(selections) do
    vim.cmd('edit ' .. vim.fn.fnameescape(entry.path or entry.filename))
  end
end

-- [[ Configure Telescope ]]
-- See `:help telescope` and `:help telescope.setup()`
telescope.setup {
  file_ignore_patterns = {".git"},
  pickers = {
    find_files = { find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*" } },
  },
  defaults = {
    vimgrep_arguments = { 'rg', '--hidden', '--color=never', '--no-heading', '--with-filename', '--line-number', '--column', '--smart-case', "--glob", "!**/.git/*" },
    mappings = {
      i = {
        ['<CR>']    = open_selected_as_buffers,
        ['<Tab>']   = actions.toggle_selection + actions.move_selection_next,
        ['<S-Tab>'] = actions.toggle_selection + actions.move_selection_previous,
        ['<C-a>']   = actions.select_all,
        ['<C-d>']   = actions.drop_all,
        ['<C-u>']   = false,
      },
      n = {
        ['<CR>']    = open_selected_as_buffers,
        ['<Tab>']   = actions.toggle_selection + actions.move_selection_next,
        ['<S-Tab>'] = actions.toggle_selection + actions.move_selection_previous,
        ['<C-a>']   = actions.select_all,
        ['<C-d>']   = actions.drop_all,
        ['<C-u>']   = false,
      },
    },
  },
}

-- Enable telescope fzf native, if installed
telescope.load_extension('fzf')
